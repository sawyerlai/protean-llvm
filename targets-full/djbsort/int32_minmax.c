static inline int32 int32_minmax(int32 a,int32 *y)
{
  int32 b = *y;
  int32 ab = b ^ a;
  int32 c = b - a;
  c ^= ab & (c ^ b);
  c >>= 31;
  c &= ab;
  a ^= c;
  *y = b ^ c;
  return a;
}
