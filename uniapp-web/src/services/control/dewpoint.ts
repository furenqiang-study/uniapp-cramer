/** Magnus formula dew point */
export function calcDewPoint(tempC: number, humidity: number): number {
  const rh = Math.min(100, Math.max(1, humidity))
  const a = 17.62
  const b = 243.12
  const gamma = (a * tempC) / (b + tempC) + Math.log(rh / 100)
  return (b * gamma) / (a - gamma)
}
