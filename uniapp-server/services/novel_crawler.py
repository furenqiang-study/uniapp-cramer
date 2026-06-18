"""小说爬虫服务 - 从 m.piquge.com 爬取小说数据

HTML 结构分析（基于实际抓取）：
- 搜索页: dl.book-view-box > dt.book-img > a[href] + dd.book-info > h4/a, p.tag, p.author, p.intro
- 详情页: div.book-main (书名/作者/封面/简介), ul.chapter-list (最新12章), p#bookintro (简介)
- 章节目录: ul.chapter-list > li > a (onclick="location.href='...'"), 分页 select option
- 章节内容: div.txt#chaptercontent > p (注意: 内容可能被JS截断，只返回前几段)
"""

import re
import logging
import httpx
from bs4 import BeautifulSoup
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)

BASE_URL = "https://m.piquge.com"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
    "Referer": "https://m.piquge.com/",
    "Upgrade-Insecure-Requests": "1",
}


def clean_html(text: str) -> str:
    """清理HTML标签和多余空白"""
    if not text:
        return ""
    text = re.sub(r'<[^>]+>', '', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()


def _extract_piquge_id(href: str) -> Optional[str]:
    """从 href 中提取 piquge_id，如 /96/96347/ -> 96/96347"""
    match = re.search(r'/(\d+)/(\d+)/', href)
    if match:
        return f"{match.group(1)}/{match.group(2)}"
    return None


def _extract_chapter_num(href: str) -> Optional[int]:
    """从章节链接提取章节号，如 /96/96347/1.html -> 1"""
    match = re.search(r'/(\d+)\.html', href)
    if match:
        return int(match.group(1))
    return None


async def search_novels(keyword: str, page: int = 1) -> List[Dict[str, Any]]:
    """搜索小说
    
    搜索结果页HTML结构:
    <dl class="book-view-box">
      <dt class="book-img"><a href="/96/96347/"><img data-src="..." /></a></dt>
      <dd class="book-info">
        <h4><a href="/96/96347/">完美世界</a></h4>
        <p class="tag"><span class="blue">玄幻</span><span class="green">连载</span><span class="orange">1048万字</span></p>
        <p class="author"><span>作者：</span>辰东</p>
        <p class="intro"><span>简介：</span>一粒尘可填海...</p>
      </dd>
    </dl>
    """
    url = f"{BASE_URL}/search/"
    params = {"searchkey": keyword, "page": page}
    
    try:
        async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
            resp = await client.get(url, params=params, headers=HEADERS)
            resp.raise_for_status()
            html = resp.text
    except Exception as e:
        logger.error(f"搜索请求失败: {e}")
        return []
    
    soup = BeautifulSoup(html, "html.parser")
    results = []
    
    for dl in soup.select("dl.book-view-box"):
        try:
            # 提取链接
            a_tag = dl.select_one("dt.book-img a")
            if not a_tag or not a_tag.get("href"):
                continue
            
            href = a_tag["href"]
            piquge_id = _extract_piquge_id(href)
            if not piquge_id:
                continue
            
            # 提取封面
            img = a_tag.select_one("img")
            cover = ""
            if img:
                src = img.get("data-src") or img.get("src", "")
                if src and "nocover" not in src:
                    cover = f"{BASE_URL}{src}" if src.startswith("/") else src
            
            # 提取书名（去掉高亮font标签的文字，只保留纯文本）
            info = dl.select_one("dd.book-info")
            if not info:
                continue
            
            title_el = info.select_one("h4 a")
            title = title_el.get_text(strip=True) if title_el else ""
            
            # 提取分类/状态/字数
            tag_spans = info.select("p.tag span")
            category = ""
            status = ""
            word_count = ""
            for span in tag_spans:
                cls = span.get("class", [])
                text = span.get_text(strip=True)
                if "blue" in cls:
                    category = text
                elif "green" in cls:
                    status = text
                elif "orange" in cls:
                    word_count = text
            
            # 提取作者
            author_el = info.select_one("p.author")
            author = ""
            if author_el:
                text = author_el.get_text(strip=True)
                author = text.replace("作者：", "").replace("作者:", "").strip()
            
            # 提取简介
            intro_el = info.select_one("p.intro")
            intro = ""
            if intro_el:
                text = intro_el.get_text(strip=True)
                intro = text.replace("简介：", "").replace("简介:", "").strip()
            
            if title:
                results.append({
                    "piquge_id": piquge_id,
                    "title": clean_html(title),
                    "author": clean_html(author),
                    "cover": cover,
                    "description": clean_html(intro)[:200],
                    "status": status,
                    "word_count": word_count,
                    "category": category,
                    "detail_url": f"{BASE_URL}{href}",
                })
        except Exception as e:
            logger.warning(f"解析搜索结果项失败: {e}")
            continue
    
    return results


async def get_novel_info(detail_url: str) -> Dict[str, Any]:
    """获取小说详情和章节目录
    
    详情页HTML结构:
    - div.book-main > div.book-img > img (封面)
    - div.book-main > div.book-info > h1 (书名), span.author > a (作者)
    - div.book-main > div.book-info > p.tag > span (分类/状态/字数)
    - div.book-main > div.book-info > p.update > a (最新章节)
    - div.book-detail-btn > ul.btn-group > li > a.btn-normal (开始阅读/章节目录)
    - div.wrap-box > p#bookintro (简介)
    - div#chapterlist > ul.chapter-list > li > a[href] (最新12章，用href而非onclick)
    """
    try:
        if not detail_url.startswith("http"):
            detail_url = f"{BASE_URL}{detail_url}"
        
        async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
            resp = await client.get(detail_url, headers=HEADERS)
            resp.raise_for_status()
            html = resp.text
        
        soup = BeautifulSoup(html, "html.parser")
        
        # 提取书名
        title_el = soup.select_one("div.book-info h1") or soup.select_one("div.bookname h1")
        title = title_el.get_text(strip=True) if title_el else ""
        
        # 提取作者
        author_el = soup.select_one("div.book-info span.author a") or soup.select_one("span.author a")
        author = author_el.get_text(strip=True) if author_el else ""
        
        # 提取封面
        cover_img = soup.select_one("div.book-img img")
        cover = ""
        if cover_img:
            src = cover_img.get("data-src") or cover_img.get("src", "")
            if src and "nocover" not in src:
                cover = f"{BASE_URL}{src}" if src.startswith("/") else src
        
        # 提取标签信息
        tag_spans = soup.select("div.book-info p.tag span")
        category = ""
        status = ""
        word_count = ""
        click_count = ""
        for span in tag_spans:
            cls = span.get("class", [])
            text = span.get_text(strip=True)
            if "blue" in cls:
                category = text
            elif "green" in cls:
                status = text
            elif "orange" in cls:
                if "字" in text:
                    word_count = text
                elif "点击" in text:
                    click_count = text
        
        # 提取最新章节
        update_el = soup.select_one("p.update a")
        latest_chapter = update_el.get_text(strip=True) if update_el else ""
        
        # 提取简介
        intro_el = soup.select_one("p#bookintro")
        description = intro_el.get_text(strip=True) if intro_el else ""
        
        # 提取章节数量
        chapter_count_el = soup.select_one("#chapterlist h3 span")
        chapter_count = 0
        if chapter_count_el:
            count_match = re.search(r'共(\d+)章', chapter_count_el.get_text())
            if count_match:
                chapter_count = int(count_match.group(1))
        
        # 提取章节目录URL - 找"章节目录"文字的链接
        chapters_url = ""
        for a_btn in soup.select("a.btn-normal"):
            if "章节目录" in a_btn.get_text():
                href = a_btn.get("href", "")
                if href and "void" not in href:
                    if href.startswith("/"):
                        chapters_url = f"{BASE_URL}{href}"
                    else:
                        chapters_url = href
                break
        
        # 如果没找到，从开始阅读链接推导
        if not chapters_url:
            start_read_el = soup.select_one("a.btn-normal-1")
            if start_read_el:
                href = start_read_el.get("href", "")
                piquge_id = _extract_piquge_id(href)
                if piquge_id:
                    chapters_url = f"{BASE_URL}/{piquge_id}/1/"
        
        # 从详情页获取最新章节作为预览（用href，不用onclick）
        preview_chapters = []
        for li in soup.select("#chapterlist ul.chapter-list li"):
            a = li.select_one("a")
            if not a:
                continue
            ch_href = a.get("href", "")
            if not ch_href or "void" in ch_href or "javascript" in ch_href:
                # 尝试从onclick提取
                onclick = a.get("onclick", "")
                url_match = re.search(r"location\.href='([^']+)'", onclick)
                if url_match:
                    ch_href = url_match.group(1)
                else:
                    continue
            
            ch_num = _extract_chapter_num(ch_href)
            preview_chapters.append({
                "chapter_num": ch_num or 0,
                "title": a.get_text(strip=True),
                "url": f"{BASE_URL}{ch_href}" if ch_href.startswith("/") else ch_href,
            })
        
        return {
            "title": title,
            "author": author,
            "cover": cover,
            "description": description,
            "category": category,
            "status": status,
            "word_count": word_count,
            "click_count": click_count,
            "latest_chapter": latest_chapter,
            "chapter_count": chapter_count,
            "detail_url": detail_url,
            "chapters_url": chapters_url,
            "preview_chapters": preview_chapters,
        }
    except Exception as e:
        logger.error(f"获取小说详情失败: {e}")
        return {"error": str(e)}


async def get_chapter_list(chapters_url: str) -> List[Dict[str, Any]]:
    """获取完整章节目录
    
    章节目录页HTML结构:
    ul.chapter-list > li > a[onclick="location.href='/96/96347/1.html'"]
    分页: select#indexselect > option[value="/96/96347/2/"]
    """
    all_chapters = []
    current_url = chapters_url
    
    try:
        async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
            while current_url:
                resp = await client.get(current_url, headers=HEADERS)
                resp.raise_for_status()
                html = resp.text
                soup = BeautifulSoup(html, "html.parser")
                
                for li in soup.select("ul.chapter-list li"):
                    a = li.select_one("a")
                    if not a:
                        continue
                    
                    # 从onclick提取URL
                    onclick = a.get("onclick", "")
                    url_match = re.search(r"location\.href='([^']+)'", onclick)
                    if url_match:
                        ch_href = url_match.group(1)
                    else:
                        ch_href = a.get("href", "")
                    
                    if not ch_href or ch_href == "javascript:void(0);":
                        continue
                    
                    ch_num = _extract_chapter_num(ch_href)
                    all_chapters.append({
                        "chapter_num": ch_num or (len(all_chapters) + 1),
                        "title": a.get_text(strip=True),
                        "url": f"{BASE_URL}{ch_href}" if ch_href.startswith("/") else ch_href,
                    })
                
                # 查找下一页
                next_link = soup.select_one("span.right a")
                if next_link and "下一页" in next_link.get_text():
                    onclick = next_link.get("onclick", "")
                    url_match = re.search(r"location\.href='([^']+)'", onclick)
                    if url_match:
                        next_href = url_match.group(1)
                        current_url = f"{BASE_URL}{next_href}" if next_href.startswith("/") else next_href
                    else:
                        current_url = None
                else:
                    current_url = None
        
        return all_chapters
    except Exception as e:
        logger.error(f"获取章节目录失败: {e}")
        return []


async def get_chapter_content(chapter_url: str) -> Dict[str, Any]:
    """获取章节正文内容
    
    章节内容页HTML结构:
    - div.txt#chaptercontent > p (正文段落)
    - div#morecontent (JS截断提示，需移除)
    - a.url_pre#prev_url (上一章)
    - a.url_next#next_url (下一章，onclick="location.href='...'")
    """
    try:
        if not chapter_url.startswith("http"):
            chapter_url = f"{BASE_URL}{chapter_url}"
        
        async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
            resp = await client.get(chapter_url, headers=HEADERS)
            resp.raise_for_status()
            html = resp.text
        
        soup = BeautifulSoup(html, "html.parser")
        
        # 从页面JS变量提取章节标题（更可靠）
        title = ""
        chaptername_match = re.search(r'const\s+chaptername\s*=\s*"([^"]+)"', html)
        if chaptername_match:
            title = chaptername_match.group(1)
        else:
            title_el = soup.select_one("h1#chaptername")
            title = title_el.get_text(strip=True) if title_el else ""
        
        # 提取正文内容
        content_el = soup.select_one("div#chaptercontent") or soup.select_one("div.txt")
        paragraphs = []
        if content_el:
            # 先移除广告div
            for ad in content_el.select("div#morecontent"):
                ad.decompose()
            # 移除空的p标签和提示文字
            for ad in content_el.select("p[style]"):
                ad.decompose()
            
            for p in content_el.find_all("p"):
                text = p.get_text(strip=True)
                # 过滤广告和提示文字
                if text and len(text) > 0 and not any(skip in text for skip in [
                    "提示您", "笔趣阁", "piquge.com", "更多内容加载中",
                    "本站只支持手机浏览器", "关闭浏览器的阅读模式", "广告屏蔽功能",
                    "复制网址到其他浏览器", "本章未完", "请点击下一章继续阅读",
                    "若浏览器显示没有新章节了", "退出阅读模式即可",
                    "请尝试点击", "的菜单",
                ]):
                    # 去掉开头的零宽空格
                    text = text.lstrip('\ufeff').strip()
                    if text:
                        paragraphs.append(text)
        
        content = "\n".join(paragraphs)
        
        # 提取上一章链接
        prev_url = ""
        prev_title = ""
        prev_link = soup.select_one("a#prev_url") or soup.select_one("a.url_pre")
        if prev_link:
            href = prev_link.get("href", "")
            if href and "void" not in href and "javascript" not in href:
                prev_url = f"{BASE_URL}{href}" if href.startswith("/") else href
                prev_title = "上一章"
        
        # 提取下一章链接
        next_url = ""
        next_title = ""
        next_link = soup.select_one("a#next_url") or soup.select_one("a.url_next")
        if next_link:
            onclick = next_link.get("onclick", "")
            url_match = re.search(r"location\.href='([^']+)'", onclick)
            if url_match:
                next_href = url_match.group(1)
                next_url = f"{BASE_URL}{next_href}" if next_href.startswith("/") else next_href
                next_title = "下一章"
            else:
                href = next_link.get("href", "")
                if href and "void" not in href and "javascript" not in href:
                    next_url = f"{BASE_URL}{href}" if href.startswith("/") else href
                    next_title = "下一章"
        
        chapter_num = _extract_chapter_num(chapter_url)
        
        return {
            "title": title,
            "content": content,
            "word_count": len(content),
            "chapter_num": chapter_num or 0,
            "prev_url": prev_url,
            "prev_title": prev_title,
            "next_url": next_url,
            "next_title": next_title,
            "url": chapter_url,
        }
    except Exception as e:
        logger.error(f"获取章节内容失败: {e}")
        return {"error": str(e)}
