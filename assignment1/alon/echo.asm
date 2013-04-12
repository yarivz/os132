
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  for(i = 1; i < argc; i++)
   9:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  10:	00 
  11:	eb 45                	jmp    58 <main+0x58>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  13:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  17:	83 c0 01             	add    $0x1,%eax
  1a:	3b 45 08             	cmp    0x8(%ebp),%eax
  1d:	7d 07                	jge    26 <main+0x26>
  1f:	b8 b3 09 00 00       	mov    $0x9b3,%eax
  24:	eb 05                	jmp    2b <main+0x2b>
  26:	b8 b5 09 00 00       	mov    $0x9b5,%eax
  2b:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  2f:	c1 e2 02             	shl    $0x2,%edx
  32:	03 55 0c             	add    0xc(%ebp),%edx
  35:	8b 12                	mov    (%edx),%edx
  37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  3f:	c7 44 24 04 b7 09 00 	movl   $0x9b7,0x4(%esp)
  46:	00 
  47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  4e:	e8 9c 05 00 00       	call   5ef <printf>
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
  53:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  58:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5c:	3b 45 08             	cmp    0x8(%ebp),%eax
  5f:	7c b2                	jl     13 <main+0x13>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  exit();
  61:	e8 02 04 00 00       	call   468 <exit>
  66:	90                   	nop
  67:	90                   	nop

00000068 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	57                   	push   %edi
  6c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  70:	8b 55 10             	mov    0x10(%ebp),%edx
  73:	8b 45 0c             	mov    0xc(%ebp),%eax
  76:	89 cb                	mov    %ecx,%ebx
  78:	89 df                	mov    %ebx,%edi
  7a:	89 d1                	mov    %edx,%ecx
  7c:	fc                   	cld    
  7d:	f3 aa                	rep stos %al,%es:(%edi)
  7f:	89 ca                	mov    %ecx,%edx
  81:	89 fb                	mov    %edi,%ebx
  83:	89 5d 08             	mov    %ebx,0x8(%ebp)
  86:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  89:	5b                   	pop    %ebx
  8a:	5f                   	pop    %edi
  8b:	5d                   	pop    %ebp
  8c:	c3                   	ret    

0000008d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  8d:	55                   	push   %ebp
  8e:	89 e5                	mov    %esp,%ebp
  90:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  93:	8b 45 08             	mov    0x8(%ebp),%eax
  96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  99:	90                   	nop
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	0f b6 10             	movzbl (%eax),%edx
  a0:	8b 45 08             	mov    0x8(%ebp),%eax
  a3:	88 10                	mov    %dl,(%eax)
  a5:	8b 45 08             	mov    0x8(%ebp),%eax
  a8:	0f b6 00             	movzbl (%eax),%eax
  ab:	84 c0                	test   %al,%al
  ad:	0f 95 c0             	setne  %al
  b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  b4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  b8:	84 c0                	test   %al,%al
  ba:	75 de                	jne    9a <strcpy+0xd>
    ;
  return os;
  bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  bf:	c9                   	leave  
  c0:	c3                   	ret    

000000c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c1:	55                   	push   %ebp
  c2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  c4:	eb 08                	jmp    ce <strcmp+0xd>
    p++, q++;
  c6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ca:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ce:	8b 45 08             	mov    0x8(%ebp),%eax
  d1:	0f b6 00             	movzbl (%eax),%eax
  d4:	84 c0                	test   %al,%al
  d6:	74 10                	je     e8 <strcmp+0x27>
  d8:	8b 45 08             	mov    0x8(%ebp),%eax
  db:	0f b6 10             	movzbl (%eax),%edx
  de:	8b 45 0c             	mov    0xc(%ebp),%eax
  e1:	0f b6 00             	movzbl (%eax),%eax
  e4:	38 c2                	cmp    %al,%dl
  e6:	74 de                	je     c6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e8:	8b 45 08             	mov    0x8(%ebp),%eax
  eb:	0f b6 00             	movzbl (%eax),%eax
  ee:	0f b6 d0             	movzbl %al,%edx
  f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  f4:	0f b6 00             	movzbl (%eax),%eax
  f7:	0f b6 c0             	movzbl %al,%eax
  fa:	89 d1                	mov    %edx,%ecx
  fc:	29 c1                	sub    %eax,%ecx
  fe:	89 c8                	mov    %ecx,%eax
}
 100:	5d                   	pop    %ebp
 101:	c3                   	ret    

00000102 <strlen>:

uint
strlen(char *s)
{
 102:	55                   	push   %ebp
 103:	89 e5                	mov    %esp,%ebp
 105:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 108:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 10f:	eb 04                	jmp    115 <strlen+0x13>
 111:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 115:	8b 45 fc             	mov    -0x4(%ebp),%eax
 118:	03 45 08             	add    0x8(%ebp),%eax
 11b:	0f b6 00             	movzbl (%eax),%eax
 11e:	84 c0                	test   %al,%al
 120:	75 ef                	jne    111 <strlen+0xf>
  return n;
 122:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 125:	c9                   	leave  
 126:	c3                   	ret    

00000127 <memset>:

void*
memset(void *dst, int c, uint n)
{
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 12d:	8b 45 10             	mov    0x10(%ebp),%eax
 130:	89 44 24 08          	mov    %eax,0x8(%esp)
 134:	8b 45 0c             	mov    0xc(%ebp),%eax
 137:	89 44 24 04          	mov    %eax,0x4(%esp)
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 04 24             	mov    %eax,(%esp)
 141:	e8 22 ff ff ff       	call   68 <stosb>
  return dst;
 146:	8b 45 08             	mov    0x8(%ebp),%eax
}
 149:	c9                   	leave  
 14a:	c3                   	ret    

0000014b <strchr>:

char*
strchr(const char *s, char c)
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	83 ec 04             	sub    $0x4,%esp
 151:	8b 45 0c             	mov    0xc(%ebp),%eax
 154:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 157:	eb 14                	jmp    16d <strchr+0x22>
    if(*s == c)
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	0f b6 00             	movzbl (%eax),%eax
 15f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 162:	75 05                	jne    169 <strchr+0x1e>
      return (char*)s;
 164:	8b 45 08             	mov    0x8(%ebp),%eax
 167:	eb 13                	jmp    17c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	0f b6 00             	movzbl (%eax),%eax
 173:	84 c0                	test   %al,%al
 175:	75 e2                	jne    159 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 177:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17c:	c9                   	leave  
 17d:	c3                   	ret    

0000017e <gets>:

char*
gets(char *buf, int max)
{
 17e:	55                   	push   %ebp
 17f:	89 e5                	mov    %esp,%ebp
 181:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 18b:	eb 44                	jmp    1d1 <gets+0x53>
    cc = read(0, &c, 1);
 18d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 194:	00 
 195:	8d 45 ef             	lea    -0x11(%ebp),%eax
 198:	89 44 24 04          	mov    %eax,0x4(%esp)
 19c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1a3:	e8 e8 02 00 00       	call   490 <read>
 1a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1af:	7e 2d                	jle    1de <gets+0x60>
      break;
    buf[i++] = c;
 1b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b4:	03 45 08             	add    0x8(%ebp),%eax
 1b7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1bb:	88 10                	mov    %dl,(%eax)
 1bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c5:	3c 0a                	cmp    $0xa,%al
 1c7:	74 16                	je     1df <gets+0x61>
 1c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cd:	3c 0d                	cmp    $0xd,%al
 1cf:	74 0e                	je     1df <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d4:	83 c0 01             	add    $0x1,%eax
 1d7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1da:	7c b1                	jl     18d <gets+0xf>
 1dc:	eb 01                	jmp    1df <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1de:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e2:	03 45 08             	add    0x8(%ebp),%eax
 1e5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1eb:	c9                   	leave  
 1ec:	c3                   	ret    

000001ed <stat>:

int
stat(char *n, struct stat *st)
{
 1ed:	55                   	push   %ebp
 1ee:	89 e5                	mov    %esp,%ebp
 1f0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1fa:	00 
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	89 04 24             	mov    %eax,(%esp)
 201:	e8 b2 02 00 00       	call   4b8 <open>
 206:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 209:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 20d:	79 07                	jns    216 <stat+0x29>
    return -1;
 20f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 214:	eb 23                	jmp    239 <stat+0x4c>
  r = fstat(fd, st);
 216:	8b 45 0c             	mov    0xc(%ebp),%eax
 219:	89 44 24 04          	mov    %eax,0x4(%esp)
 21d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 220:	89 04 24             	mov    %eax,(%esp)
 223:	e8 a8 02 00 00       	call   4d0 <fstat>
 228:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22e:	89 04 24             	mov    %eax,(%esp)
 231:	e8 6a 02 00 00       	call   4a0 <close>
  return r;
 236:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 239:	c9                   	leave  
 23a:	c3                   	ret    

0000023b <atoi>:

int
atoi(const char *s)
{
 23b:	55                   	push   %ebp
 23c:	89 e5                	mov    %esp,%ebp
 23e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 241:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 248:	eb 23                	jmp    26d <atoi+0x32>
    n = n*10 + *s++ - '0';
 24a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 24d:	89 d0                	mov    %edx,%eax
 24f:	c1 e0 02             	shl    $0x2,%eax
 252:	01 d0                	add    %edx,%eax
 254:	01 c0                	add    %eax,%eax
 256:	89 c2                	mov    %eax,%edx
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	0f b6 00             	movzbl (%eax),%eax
 25e:	0f be c0             	movsbl %al,%eax
 261:	01 d0                	add    %edx,%eax
 263:	83 e8 30             	sub    $0x30,%eax
 266:	89 45 fc             	mov    %eax,-0x4(%ebp)
 269:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	0f b6 00             	movzbl (%eax),%eax
 273:	3c 2f                	cmp    $0x2f,%al
 275:	7e 0a                	jle    281 <atoi+0x46>
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	0f b6 00             	movzbl (%eax),%eax
 27d:	3c 39                	cmp    $0x39,%al
 27f:	7e c9                	jle    24a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 281:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 284:	c9                   	leave  
 285:	c3                   	ret    

00000286 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 286:	55                   	push   %ebp
 287:	89 e5                	mov    %esp,%ebp
 289:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 292:	8b 45 0c             	mov    0xc(%ebp),%eax
 295:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 298:	eb 13                	jmp    2ad <memmove+0x27>
    *dst++ = *src++;
 29a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 29d:	0f b6 10             	movzbl (%eax),%edx
 2a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a3:	88 10                	mov    %dl,(%eax)
 2a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2a9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2b1:	0f 9f c0             	setg   %al
 2b4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2b8:	84 c0                	test   %al,%al
 2ba:	75 de                	jne    29a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    

000002c1 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 2c1:	55                   	push   %ebp
 2c2:	89 e5                	mov    %esp,%ebp
 2c4:	83 ec 38             	sub    $0x38,%esp
 2c7:	8b 45 10             	mov    0x10(%ebp),%eax
 2ca:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 2cd:	8b 45 14             	mov    0x14(%ebp),%eax
 2d0:	8b 00                	mov    (%eax),%eax
 2d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2d5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 2dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2e0:	74 06                	je     2e8 <strtok+0x27>
 2e2:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 2e6:	75 54                	jne    33c <strtok+0x7b>
    return match;
 2e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2eb:	eb 6e                	jmp    35b <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 2ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f0:	03 45 0c             	add    0xc(%ebp),%eax
 2f3:	0f b6 00             	movzbl (%eax),%eax
 2f6:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 2f9:	74 06                	je     301 <strtok+0x40>
      {
	index++;
 2fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2ff:	eb 3c                	jmp    33d <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 301:	8b 45 14             	mov    0x14(%ebp),%eax
 304:	8b 00                	mov    (%eax),%eax
 306:	8b 55 f4             	mov    -0xc(%ebp),%edx
 309:	29 c2                	sub    %eax,%edx
 30b:	8b 45 14             	mov    0x14(%ebp),%eax
 30e:	8b 00                	mov    (%eax),%eax
 310:	03 45 0c             	add    0xc(%ebp),%eax
 313:	89 54 24 08          	mov    %edx,0x8(%esp)
 317:	89 44 24 04          	mov    %eax,0x4(%esp)
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	89 04 24             	mov    %eax,(%esp)
 321:	e8 37 00 00 00       	call   35d <strncpy>
 326:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	84 c0                	test   %al,%al
 331:	74 19                	je     34c <strtok+0x8b>
	  match = 1;
 333:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 33a:	eb 10                	jmp    34c <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 33c:	90                   	nop
 33d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 340:	03 45 0c             	add    0xc(%ebp),%eax
 343:	0f b6 00             	movzbl (%eax),%eax
 346:	84 c0                	test   %al,%al
 348:	75 a3                	jne    2ed <strtok+0x2c>
 34a:	eb 01                	jmp    34d <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 34c:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 34d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 350:	8d 50 01             	lea    0x1(%eax),%edx
 353:	8b 45 14             	mov    0x14(%ebp),%eax
 356:	89 10                	mov    %edx,(%eax)
  return match;
 358:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 35b:	c9                   	leave  
 35c:	c3                   	ret    

0000035d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 35d:	55                   	push   %ebp
 35e:	89 e5                	mov    %esp,%ebp
 360:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 363:	8b 45 08             	mov    0x8(%ebp),%eax
 366:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 369:	90                   	nop
 36a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 36e:	0f 9f c0             	setg   %al
 371:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 375:	84 c0                	test   %al,%al
 377:	74 30                	je     3a9 <strncpy+0x4c>
 379:	8b 45 0c             	mov    0xc(%ebp),%eax
 37c:	0f b6 10             	movzbl (%eax),%edx
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	88 10                	mov    %dl,(%eax)
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	0f b6 00             	movzbl (%eax),%eax
 38a:	84 c0                	test   %al,%al
 38c:	0f 95 c0             	setne  %al
 38f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 393:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 397:	84 c0                	test   %al,%al
 399:	75 cf                	jne    36a <strncpy+0xd>
    ;
  while(n-- > 0)
 39b:	eb 0c                	jmp    3a9 <strncpy+0x4c>
    *s++ = 0;
 39d:	8b 45 08             	mov    0x8(%ebp),%eax
 3a0:	c6 00 00             	movb   $0x0,(%eax)
 3a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a7:	eb 01                	jmp    3aa <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3a9:	90                   	nop
 3aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3ae:	0f 9f c0             	setg   %al
 3b1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3b5:	84 c0                	test   %al,%al
 3b7:	75 e4                	jne    39d <strncpy+0x40>
    *s++ = 0;
  return os;
 3b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    

000003be <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 3c1:	eb 0c                	jmp    3cf <strncmp+0x11>
    n--, p++, q++;
 3c3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3c7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3cb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 3cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3d3:	74 1a                	je     3ef <strncmp+0x31>
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	0f b6 00             	movzbl (%eax),%eax
 3db:	84 c0                	test   %al,%al
 3dd:	74 10                	je     3ef <strncmp+0x31>
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	0f b6 10             	movzbl (%eax),%edx
 3e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	38 c2                	cmp    %al,%dl
 3ed:	74 d4                	je     3c3 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 3ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3f3:	75 07                	jne    3fc <strncmp+0x3e>
    return 0;
 3f5:	b8 00 00 00 00       	mov    $0x0,%eax
 3fa:	eb 18                	jmp    414 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
 3ff:	0f b6 00             	movzbl (%eax),%eax
 402:	0f b6 d0             	movzbl %al,%edx
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	0f b6 00             	movzbl (%eax),%eax
 40b:	0f b6 c0             	movzbl %al,%eax
 40e:	89 d1                	mov    %edx,%ecx
 410:	29 c1                	sub    %eax,%ecx
 412:	89 c8                	mov    %ecx,%eax
}
 414:	5d                   	pop    %ebp
 415:	c3                   	ret    

00000416 <strcat>:

void
strcat(char *dest, char *p, char *q)
{  
 416:	55                   	push   %ebp
 417:	89 e5                	mov    %esp,%ebp
  while(*p){
 419:	eb 13                	jmp    42e <strcat+0x18>
    *dest++ = *p++;
 41b:	8b 45 0c             	mov    0xc(%ebp),%eax
 41e:	0f b6 10             	movzbl (%eax),%edx
 421:	8b 45 08             	mov    0x8(%ebp),%eax
 424:	88 10                	mov    %dl,(%eax)
 426:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 42a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, char *p, char *q)
{  
  while(*p){
 42e:	8b 45 0c             	mov    0xc(%ebp),%eax
 431:	0f b6 00             	movzbl (%eax),%eax
 434:	84 c0                	test   %al,%al
 436:	75 e3                	jne    41b <strcat+0x5>
    *dest++ = *p++;
  }

  while(*q){
 438:	eb 13                	jmp    44d <strcat+0x37>
    *dest++ = *q++;
 43a:	8b 45 10             	mov    0x10(%ebp),%eax
 43d:	0f b6 10             	movzbl (%eax),%edx
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	88 10                	mov    %dl,(%eax)
 445:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 449:	83 45 10 01          	addl   $0x1,0x10(%ebp)
{  
  while(*p){
    *dest++ = *p++;
  }

  while(*q){
 44d:	8b 45 10             	mov    0x10(%ebp),%eax
 450:	0f b6 00             	movzbl (%eax),%eax
 453:	84 c0                	test   %al,%al
 455:	75 e3                	jne    43a <strcat+0x24>
    *dest++ = *q++;
  }
  *dest = 0;
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	c6 00 00             	movb   $0x0,(%eax)
 45d:	5d                   	pop    %ebp
 45e:	c3                   	ret    
 45f:	90                   	nop

00000460 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 460:	b8 01 00 00 00       	mov    $0x1,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <exit>:
SYSCALL(exit)
 468:	b8 02 00 00 00       	mov    $0x2,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <wait>:
SYSCALL(wait)
 470:	b8 03 00 00 00       	mov    $0x3,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <wait2>:
SYSCALL(wait2)
 478:	b8 16 00 00 00       	mov    $0x16,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <nice>:
SYSCALL(nice)
 480:	b8 17 00 00 00       	mov    $0x17,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <pipe>:
SYSCALL(pipe)
 488:	b8 04 00 00 00       	mov    $0x4,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <read>:
SYSCALL(read)
 490:	b8 05 00 00 00       	mov    $0x5,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <write>:
SYSCALL(write)
 498:	b8 10 00 00 00       	mov    $0x10,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <close>:
SYSCALL(close)
 4a0:	b8 15 00 00 00       	mov    $0x15,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <kill>:
SYSCALL(kill)
 4a8:	b8 06 00 00 00       	mov    $0x6,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <exec>:
SYSCALL(exec)
 4b0:	b8 07 00 00 00       	mov    $0x7,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <open>:
SYSCALL(open)
 4b8:	b8 0f 00 00 00       	mov    $0xf,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <mknod>:
SYSCALL(mknod)
 4c0:	b8 11 00 00 00       	mov    $0x11,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <unlink>:
SYSCALL(unlink)
 4c8:	b8 12 00 00 00       	mov    $0x12,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <fstat>:
SYSCALL(fstat)
 4d0:	b8 08 00 00 00       	mov    $0x8,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <link>:
SYSCALL(link)
 4d8:	b8 13 00 00 00       	mov    $0x13,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <mkdir>:
SYSCALL(mkdir)
 4e0:	b8 14 00 00 00       	mov    $0x14,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <chdir>:
SYSCALL(chdir)
 4e8:	b8 09 00 00 00       	mov    $0x9,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <dup>:
SYSCALL(dup)
 4f0:	b8 0a 00 00 00       	mov    $0xa,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <getpid>:
SYSCALL(getpid)
 4f8:	b8 0b 00 00 00       	mov    $0xb,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <sbrk>:
SYSCALL(sbrk)
 500:	b8 0c 00 00 00       	mov    $0xc,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <sleep>:
SYSCALL(sleep)
 508:	b8 0d 00 00 00       	mov    $0xd,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <uptime>:
SYSCALL(uptime)
 510:	b8 0e 00 00 00       	mov    $0xe,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 518:	55                   	push   %ebp
 519:	89 e5                	mov    %esp,%ebp
 51b:	83 ec 28             	sub    $0x28,%esp
 51e:	8b 45 0c             	mov    0xc(%ebp),%eax
 521:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 524:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 52b:	00 
 52c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 52f:	89 44 24 04          	mov    %eax,0x4(%esp)
 533:	8b 45 08             	mov    0x8(%ebp),%eax
 536:	89 04 24             	mov    %eax,(%esp)
 539:	e8 5a ff ff ff       	call   498 <write>
}
 53e:	c9                   	leave  
 53f:	c3                   	ret    

00000540 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 540:	55                   	push   %ebp
 541:	89 e5                	mov    %esp,%ebp
 543:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 546:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 54d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 551:	74 17                	je     56a <printint+0x2a>
 553:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 557:	79 11                	jns    56a <printint+0x2a>
    neg = 1;
 559:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 560:	8b 45 0c             	mov    0xc(%ebp),%eax
 563:	f7 d8                	neg    %eax
 565:	89 45 ec             	mov    %eax,-0x14(%ebp)
 568:	eb 06                	jmp    570 <printint+0x30>
  } else {
    x = xx;
 56a:	8b 45 0c             	mov    0xc(%ebp),%eax
 56d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 570:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 577:	8b 4d 10             	mov    0x10(%ebp),%ecx
 57a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 57d:	ba 00 00 00 00       	mov    $0x0,%edx
 582:	f7 f1                	div    %ecx
 584:	89 d0                	mov    %edx,%eax
 586:	0f b6 90 80 0c 00 00 	movzbl 0xc80(%eax),%edx
 58d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 590:	03 45 f4             	add    -0xc(%ebp),%eax
 593:	88 10                	mov    %dl,(%eax)
 595:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 599:	8b 55 10             	mov    0x10(%ebp),%edx
 59c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 59f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5a2:	ba 00 00 00 00       	mov    $0x0,%edx
 5a7:	f7 75 d4             	divl   -0x2c(%ebp)
 5aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5b1:	75 c4                	jne    577 <printint+0x37>
  if(neg)
 5b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5b7:	74 2a                	je     5e3 <printint+0xa3>
    buf[i++] = '-';
 5b9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5bc:	03 45 f4             	add    -0xc(%ebp),%eax
 5bf:	c6 00 2d             	movb   $0x2d,(%eax)
 5c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5c6:	eb 1b                	jmp    5e3 <printint+0xa3>
    putc(fd, buf[i]);
 5c8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5cb:	03 45 f4             	add    -0xc(%ebp),%eax
 5ce:	0f b6 00             	movzbl (%eax),%eax
 5d1:	0f be c0             	movsbl %al,%eax
 5d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d8:	8b 45 08             	mov    0x8(%ebp),%eax
 5db:	89 04 24             	mov    %eax,(%esp)
 5de:	e8 35 ff ff ff       	call   518 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5e3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5eb:	79 db                	jns    5c8 <printint+0x88>
    putc(fd, buf[i]);
}
 5ed:	c9                   	leave  
 5ee:	c3                   	ret    

000005ef <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5ef:	55                   	push   %ebp
 5f0:	89 e5                	mov    %esp,%ebp
 5f2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5f5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5fc:	8d 45 0c             	lea    0xc(%ebp),%eax
 5ff:	83 c0 04             	add    $0x4,%eax
 602:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 605:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 60c:	e9 7d 01 00 00       	jmp    78e <printf+0x19f>
    c = fmt[i] & 0xff;
 611:	8b 55 0c             	mov    0xc(%ebp),%edx
 614:	8b 45 f0             	mov    -0x10(%ebp),%eax
 617:	01 d0                	add    %edx,%eax
 619:	0f b6 00             	movzbl (%eax),%eax
 61c:	0f be c0             	movsbl %al,%eax
 61f:	25 ff 00 00 00       	and    $0xff,%eax
 624:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 627:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 62b:	75 2c                	jne    659 <printf+0x6a>
      if(c == '%'){
 62d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 631:	75 0c                	jne    63f <printf+0x50>
        state = '%';
 633:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 63a:	e9 4b 01 00 00       	jmp    78a <printf+0x19b>
      } else {
        putc(fd, c);
 63f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 642:	0f be c0             	movsbl %al,%eax
 645:	89 44 24 04          	mov    %eax,0x4(%esp)
 649:	8b 45 08             	mov    0x8(%ebp),%eax
 64c:	89 04 24             	mov    %eax,(%esp)
 64f:	e8 c4 fe ff ff       	call   518 <putc>
 654:	e9 31 01 00 00       	jmp    78a <printf+0x19b>
      }
    } else if(state == '%'){
 659:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 65d:	0f 85 27 01 00 00    	jne    78a <printf+0x19b>
      if(c == 'd'){
 663:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 667:	75 2d                	jne    696 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 669:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 675:	00 
 676:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 67d:	00 
 67e:	89 44 24 04          	mov    %eax,0x4(%esp)
 682:	8b 45 08             	mov    0x8(%ebp),%eax
 685:	89 04 24             	mov    %eax,(%esp)
 688:	e8 b3 fe ff ff       	call   540 <printint>
        ap++;
 68d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 691:	e9 ed 00 00 00       	jmp    783 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 696:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 69a:	74 06                	je     6a2 <printf+0xb3>
 69c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6a0:	75 2d                	jne    6cf <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a5:	8b 00                	mov    (%eax),%eax
 6a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6ae:	00 
 6af:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6b6:	00 
 6b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bb:	8b 45 08             	mov    0x8(%ebp),%eax
 6be:	89 04 24             	mov    %eax,(%esp)
 6c1:	e8 7a fe ff ff       	call   540 <printint>
        ap++;
 6c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ca:	e9 b4 00 00 00       	jmp    783 <printf+0x194>
      } else if(c == 's'){
 6cf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6d3:	75 46                	jne    71b <printf+0x12c>
        s = (char*)*ap;
 6d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d8:	8b 00                	mov    (%eax),%eax
 6da:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e5:	75 27                	jne    70e <printf+0x11f>
          s = "(null)";
 6e7:	c7 45 f4 bc 09 00 00 	movl   $0x9bc,-0xc(%ebp)
        while(*s != 0){
 6ee:	eb 1e                	jmp    70e <printf+0x11f>
          putc(fd, *s);
 6f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f3:	0f b6 00             	movzbl (%eax),%eax
 6f6:	0f be c0             	movsbl %al,%eax
 6f9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6fd:	8b 45 08             	mov    0x8(%ebp),%eax
 700:	89 04 24             	mov    %eax,(%esp)
 703:	e8 10 fe ff ff       	call   518 <putc>
          s++;
 708:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 70c:	eb 01                	jmp    70f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 70e:	90                   	nop
 70f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 712:	0f b6 00             	movzbl (%eax),%eax
 715:	84 c0                	test   %al,%al
 717:	75 d7                	jne    6f0 <printf+0x101>
 719:	eb 68                	jmp    783 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 71b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 71f:	75 1d                	jne    73e <printf+0x14f>
        putc(fd, *ap);
 721:	8b 45 e8             	mov    -0x18(%ebp),%eax
 724:	8b 00                	mov    (%eax),%eax
 726:	0f be c0             	movsbl %al,%eax
 729:	89 44 24 04          	mov    %eax,0x4(%esp)
 72d:	8b 45 08             	mov    0x8(%ebp),%eax
 730:	89 04 24             	mov    %eax,(%esp)
 733:	e8 e0 fd ff ff       	call   518 <putc>
        ap++;
 738:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73c:	eb 45                	jmp    783 <printf+0x194>
      } else if(c == '%'){
 73e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 742:	75 17                	jne    75b <printf+0x16c>
        putc(fd, c);
 744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 747:	0f be c0             	movsbl %al,%eax
 74a:	89 44 24 04          	mov    %eax,0x4(%esp)
 74e:	8b 45 08             	mov    0x8(%ebp),%eax
 751:	89 04 24             	mov    %eax,(%esp)
 754:	e8 bf fd ff ff       	call   518 <putc>
 759:	eb 28                	jmp    783 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 75b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 762:	00 
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	89 04 24             	mov    %eax,(%esp)
 769:	e8 aa fd ff ff       	call   518 <putc>
        putc(fd, c);
 76e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 771:	0f be c0             	movsbl %al,%eax
 774:	89 44 24 04          	mov    %eax,0x4(%esp)
 778:	8b 45 08             	mov    0x8(%ebp),%eax
 77b:	89 04 24             	mov    %eax,(%esp)
 77e:	e8 95 fd ff ff       	call   518 <putc>
      }
      state = 0;
 783:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 78a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 78e:	8b 55 0c             	mov    0xc(%ebp),%edx
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	01 d0                	add    %edx,%eax
 796:	0f b6 00             	movzbl (%eax),%eax
 799:	84 c0                	test   %al,%al
 79b:	0f 85 70 fe ff ff    	jne    611 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7a1:	c9                   	leave  
 7a2:	c3                   	ret    
 7a3:	90                   	nop

000007a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a4:	55                   	push   %ebp
 7a5:	89 e5                	mov    %esp,%ebp
 7a7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7aa:	8b 45 08             	mov    0x8(%ebp),%eax
 7ad:	83 e8 08             	sub    $0x8,%eax
 7b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b3:	a1 9c 0c 00 00       	mov    0xc9c,%eax
 7b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7bb:	eb 24                	jmp    7e1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c0:	8b 00                	mov    (%eax),%eax
 7c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c5:	77 12                	ja     7d9 <free+0x35>
 7c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7cd:	77 24                	ja     7f3 <free+0x4f>
 7cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d2:	8b 00                	mov    (%eax),%eax
 7d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d7:	77 1a                	ja     7f3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e7:	76 d4                	jbe    7bd <free+0x19>
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7f1:	76 ca                	jbe    7bd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f6:	8b 40 04             	mov    0x4(%eax),%eax
 7f9:	c1 e0 03             	shl    $0x3,%eax
 7fc:	89 c2                	mov    %eax,%edx
 7fe:	03 55 f8             	add    -0x8(%ebp),%edx
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	8b 00                	mov    (%eax),%eax
 806:	39 c2                	cmp    %eax,%edx
 808:	75 24                	jne    82e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80d:	8b 50 04             	mov    0x4(%eax),%edx
 810:	8b 45 fc             	mov    -0x4(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	8b 40 04             	mov    0x4(%eax),%eax
 818:	01 c2                	add    %eax,%edx
 81a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
 823:	8b 00                	mov    (%eax),%eax
 825:	8b 10                	mov    (%eax),%edx
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	89 10                	mov    %edx,(%eax)
 82c:	eb 0a                	jmp    838 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 82e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 831:	8b 10                	mov    (%eax),%edx
 833:	8b 45 f8             	mov    -0x8(%ebp),%eax
 836:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 40 04             	mov    0x4(%eax),%eax
 83e:	c1 e0 03             	shl    $0x3,%eax
 841:	03 45 fc             	add    -0x4(%ebp),%eax
 844:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 847:	75 20                	jne    869 <free+0xc5>
    p->s.size += bp->s.size;
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	8b 50 04             	mov    0x4(%eax),%edx
 84f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 852:	8b 40 04             	mov    0x4(%eax),%eax
 855:	01 c2                	add    %eax,%edx
 857:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 85d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 860:	8b 10                	mov    (%eax),%edx
 862:	8b 45 fc             	mov    -0x4(%ebp),%eax
 865:	89 10                	mov    %edx,(%eax)
 867:	eb 08                	jmp    871 <free+0xcd>
  } else
    p->s.ptr = bp;
 869:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 86f:	89 10                	mov    %edx,(%eax)
  freep = p;
 871:	8b 45 fc             	mov    -0x4(%ebp),%eax
 874:	a3 9c 0c 00 00       	mov    %eax,0xc9c
}
 879:	c9                   	leave  
 87a:	c3                   	ret    

0000087b <morecore>:

static Header*
morecore(uint nu)
{
 87b:	55                   	push   %ebp
 87c:	89 e5                	mov    %esp,%ebp
 87e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 881:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 888:	77 07                	ja     891 <morecore+0x16>
    nu = 4096;
 88a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 891:	8b 45 08             	mov    0x8(%ebp),%eax
 894:	c1 e0 03             	shl    $0x3,%eax
 897:	89 04 24             	mov    %eax,(%esp)
 89a:	e8 61 fc ff ff       	call   500 <sbrk>
 89f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8a2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8a6:	75 07                	jne    8af <morecore+0x34>
    return 0;
 8a8:	b8 00 00 00 00       	mov    $0x0,%eax
 8ad:	eb 22                	jmp    8d1 <morecore+0x56>
  hp = (Header*)p;
 8af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b8:	8b 55 08             	mov    0x8(%ebp),%edx
 8bb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8be:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c1:	83 c0 08             	add    $0x8,%eax
 8c4:	89 04 24             	mov    %eax,(%esp)
 8c7:	e8 d8 fe ff ff       	call   7a4 <free>
  return freep;
 8cc:	a1 9c 0c 00 00       	mov    0xc9c,%eax
}
 8d1:	c9                   	leave  
 8d2:	c3                   	ret    

000008d3 <malloc>:

void*
malloc(uint nbytes)
{
 8d3:	55                   	push   %ebp
 8d4:	89 e5                	mov    %esp,%ebp
 8d6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d9:	8b 45 08             	mov    0x8(%ebp),%eax
 8dc:	83 c0 07             	add    $0x7,%eax
 8df:	c1 e8 03             	shr    $0x3,%eax
 8e2:	83 c0 01             	add    $0x1,%eax
 8e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8e8:	a1 9c 0c 00 00       	mov    0xc9c,%eax
 8ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8f4:	75 23                	jne    919 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8f6:	c7 45 f0 94 0c 00 00 	movl   $0xc94,-0x10(%ebp)
 8fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 900:	a3 9c 0c 00 00       	mov    %eax,0xc9c
 905:	a1 9c 0c 00 00       	mov    0xc9c,%eax
 90a:	a3 94 0c 00 00       	mov    %eax,0xc94
    base.s.size = 0;
 90f:	c7 05 98 0c 00 00 00 	movl   $0x0,0xc98
 916:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 919:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 921:	8b 45 f4             	mov    -0xc(%ebp),%eax
 924:	8b 40 04             	mov    0x4(%eax),%eax
 927:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 92a:	72 4d                	jb     979 <malloc+0xa6>
      if(p->s.size == nunits)
 92c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92f:	8b 40 04             	mov    0x4(%eax),%eax
 932:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 935:	75 0c                	jne    943 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 937:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93a:	8b 10                	mov    (%eax),%edx
 93c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93f:	89 10                	mov    %edx,(%eax)
 941:	eb 26                	jmp    969 <malloc+0x96>
      else {
        p->s.size -= nunits;
 943:	8b 45 f4             	mov    -0xc(%ebp),%eax
 946:	8b 40 04             	mov    0x4(%eax),%eax
 949:	89 c2                	mov    %eax,%edx
 94b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 94e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 951:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 954:	8b 45 f4             	mov    -0xc(%ebp),%eax
 957:	8b 40 04             	mov    0x4(%eax),%eax
 95a:	c1 e0 03             	shl    $0x3,%eax
 95d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 960:	8b 45 f4             	mov    -0xc(%ebp),%eax
 963:	8b 55 ec             	mov    -0x14(%ebp),%edx
 966:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 969:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96c:	a3 9c 0c 00 00       	mov    %eax,0xc9c
      return (void*)(p + 1);
 971:	8b 45 f4             	mov    -0xc(%ebp),%eax
 974:	83 c0 08             	add    $0x8,%eax
 977:	eb 38                	jmp    9b1 <malloc+0xde>
    }
    if(p == freep)
 979:	a1 9c 0c 00 00       	mov    0xc9c,%eax
 97e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 981:	75 1b                	jne    99e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 983:	8b 45 ec             	mov    -0x14(%ebp),%eax
 986:	89 04 24             	mov    %eax,(%esp)
 989:	e8 ed fe ff ff       	call   87b <morecore>
 98e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 991:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 995:	75 07                	jne    99e <malloc+0xcb>
        return 0;
 997:	b8 00 00 00 00       	mov    $0x0,%eax
 99c:	eb 13                	jmp    9b1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a7:	8b 00                	mov    (%eax),%eax
 9a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9ac:	e9 70 ff ff ff       	jmp    921 <malloc+0x4e>
}
 9b1:	c9                   	leave  
 9b2:	c3                   	ret    
