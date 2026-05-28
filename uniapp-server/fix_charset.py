"""修复数据库字符集为utf8mb4以支持emoji"""
import pymysql

conn = pymysql.connect(
    host="120.48.35.53",
    port=3306,
    user="root",
    password="123321Frq",
    database="study_uniapp",
    charset="utf8mb4",
)

cursor = conn.cursor()

# 修改数据库字符集
cursor.execute("ALTER DATABASE study_uniapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
print("数据库字符集已修改为utf8mb4")

# 修改各表字符集
for table in ["users", "menus", "operation_logs"]:
    cursor.execute(f"ALTER TABLE {table} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
    print(f"表 {table} 已转换为utf8mb4")

conn.commit()
cursor.close()
conn.close()
print("\n字符集修复完成！")