
_ln:     file format elf32-i386


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
   6:	83 ec 10             	sub    $0x10,%esp
  if(argc != 3){
   9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
   d:	74 19                	je     28 <main+0x28>
    printf(2, "Usage: ln old new\n");
   f:	c7 44 24 04 c7 09 00 	movl   $0x9c7,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 e0 05 00 00       	call   603 <printf>
    exit();
  23:	e8 54 04 00 00       	call   47c <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 08             	add    $0x8,%eax
  2e:	8b 10                	mov    (%eax),%edx
  30:	8b 45 0c             	mov    0xc(%ebp),%eax
  33:	83 c0 04             	add    $0x4,%eax
  36:	8b 00                	mov    (%eax),%eax
  38:	89 54 24 04          	mov    %edx,0x4(%esp)
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	e8 a8 04 00 00       	call   4ec <link>
  44:	85 c0                	test   %eax,%eax
  46:	79 2c                	jns    74 <main+0x74>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	8b 45 0c             	mov    0xc(%ebp),%eax
  4b:	83 c0 08             	add    $0x8,%eax
  4e:	8b 10                	mov    (%eax),%edx
  50:	8b 45 0c             	mov    0xc(%ebp),%eax
  53:	83 c0 04             	add    $0x4,%eax
  56:	8b 00                	mov    (%eax),%eax
  58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  60:	c7 44 24 04 da 09 00 	movl   $0x9da,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 8f 05 00 00       	call   603 <printf>
  exit();
  74:	e8 03 04 00 00       	call   47c <exit>
  79:	90                   	nop
  7a:	90                   	nop
  7b:	90                   	nop

0000007c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  7c:	55                   	push   %ebp
  7d:	89 e5                	mov    %esp,%ebp
  7f:	57                   	push   %edi
  80:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  84:	8b 55 10             	mov    0x10(%ebp),%edx
  87:	8b 45 0c             	mov    0xc(%ebp),%eax
  8a:	89 cb                	mov    %ecx,%ebx
  8c:	89 df                	mov    %ebx,%edi
  8e:	89 d1                	mov    %edx,%ecx
  90:	fc                   	cld    
  91:	f3 aa                	rep stos %al,%es:(%edi)
  93:	89 ca                	mov    %ecx,%edx
  95:	89 fb                	mov    %edi,%ebx
  97:	89 5d 08             	mov    %ebx,0x8(%ebp)
  9a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9d:	5b                   	pop    %ebx
  9e:	5f                   	pop    %edi
  9f:	5d                   	pop    %ebp
  a0:	c3                   	ret    

000000a1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  a1:	55                   	push   %ebp
  a2:	89 e5                	mov    %esp,%ebp
  a4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a7:	8b 45 08             	mov    0x8(%ebp),%eax
  aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ad:	90                   	nop
  ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  b1:	0f b6 10             	movzbl (%eax),%edx
  b4:	8b 45 08             	mov    0x8(%ebp),%eax
  b7:	88 10                	mov    %dl,(%eax)
  b9:	8b 45 08             	mov    0x8(%ebp),%eax
  bc:	0f b6 00             	movzbl (%eax),%eax
  bf:	84 c0                	test   %al,%al
  c1:	0f 95 c0             	setne  %al
  c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  cc:	84 c0                	test   %al,%al
  ce:	75 de                	jne    ae <strcpy+0xd>
    ;
  return os;
  d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d3:	c9                   	leave  
  d4:	c3                   	ret    

000000d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d5:	55                   	push   %ebp
  d6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d8:	eb 08                	jmp    e2 <strcmp+0xd>
    p++, q++;
  da:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  de:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  e2:	8b 45 08             	mov    0x8(%ebp),%eax
  e5:	0f b6 00             	movzbl (%eax),%eax
  e8:	84 c0                	test   %al,%al
  ea:	74 10                	je     fc <strcmp+0x27>
  ec:	8b 45 08             	mov    0x8(%ebp),%eax
  ef:	0f b6 10             	movzbl (%eax),%edx
  f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  f5:	0f b6 00             	movzbl (%eax),%eax
  f8:	38 c2                	cmp    %al,%dl
  fa:	74 de                	je     da <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  fc:	8b 45 08             	mov    0x8(%ebp),%eax
  ff:	0f b6 00             	movzbl (%eax),%eax
 102:	0f b6 d0             	movzbl %al,%edx
 105:	8b 45 0c             	mov    0xc(%ebp),%eax
 108:	0f b6 00             	movzbl (%eax),%eax
 10b:	0f b6 c0             	movzbl %al,%eax
 10e:	89 d1                	mov    %edx,%ecx
 110:	29 c1                	sub    %eax,%ecx
 112:	89 c8                	mov    %ecx,%eax
}
 114:	5d                   	pop    %ebp
 115:	c3                   	ret    

00000116 <strlen>:

uint
strlen(char *s)
{
 116:	55                   	push   %ebp
 117:	89 e5                	mov    %esp,%ebp
 119:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 11c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 123:	eb 04                	jmp    129 <strlen+0x13>
 125:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 129:	8b 45 fc             	mov    -0x4(%ebp),%eax
 12c:	03 45 08             	add    0x8(%ebp),%eax
 12f:	0f b6 00             	movzbl (%eax),%eax
 132:	84 c0                	test   %al,%al
 134:	75 ef                	jne    125 <strlen+0xf>
  return n;
 136:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 139:	c9                   	leave  
 13a:	c3                   	ret    

0000013b <memset>:

void*
memset(void *dst, int c, uint n)
{
 13b:	55                   	push   %ebp
 13c:	89 e5                	mov    %esp,%ebp
 13e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 141:	8b 45 10             	mov    0x10(%ebp),%eax
 144:	89 44 24 08          	mov    %eax,0x8(%esp)
 148:	8b 45 0c             	mov    0xc(%ebp),%eax
 14b:	89 44 24 04          	mov    %eax,0x4(%esp)
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	89 04 24             	mov    %eax,(%esp)
 155:	e8 22 ff ff ff       	call   7c <stosb>
  return dst;
 15a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15d:	c9                   	leave  
 15e:	c3                   	ret    

0000015f <strchr>:

char*
strchr(const char *s, char c)
{
 15f:	55                   	push   %ebp
 160:	89 e5                	mov    %esp,%ebp
 162:	83 ec 04             	sub    $0x4,%esp
 165:	8b 45 0c             	mov    0xc(%ebp),%eax
 168:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 16b:	eb 14                	jmp    181 <strchr+0x22>
    if(*s == c)
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	0f b6 00             	movzbl (%eax),%eax
 173:	3a 45 fc             	cmp    -0x4(%ebp),%al
 176:	75 05                	jne    17d <strchr+0x1e>
      return (char*)s;
 178:	8b 45 08             	mov    0x8(%ebp),%eax
 17b:	eb 13                	jmp    190 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 17d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 181:	8b 45 08             	mov    0x8(%ebp),%eax
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	84 c0                	test   %al,%al
 189:	75 e2                	jne    16d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 18b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 190:	c9                   	leave  
 191:	c3                   	ret    

00000192 <gets>:

char*
gets(char *buf, int max)
{
 192:	55                   	push   %ebp
 193:	89 e5                	mov    %esp,%ebp
 195:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 198:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19f:	eb 44                	jmp    1e5 <gets+0x53>
    cc = read(0, &c, 1);
 1a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1a8:	00 
 1a9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b7:	e8 e8 02 00 00       	call   4a4 <read>
 1bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c3:	7e 2d                	jle    1f2 <gets+0x60>
      break;
    buf[i++] = c;
 1c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c8:	03 45 08             	add    0x8(%ebp),%eax
 1cb:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1cf:	88 10                	mov    %dl,(%eax)
 1d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1d5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d9:	3c 0a                	cmp    $0xa,%al
 1db:	74 16                	je     1f3 <gets+0x61>
 1dd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e1:	3c 0d                	cmp    $0xd,%al
 1e3:	74 0e                	je     1f3 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e8:	83 c0 01             	add    $0x1,%eax
 1eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1ee:	7c b1                	jl     1a1 <gets+0xf>
 1f0:	eb 01                	jmp    1f3 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1f2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f6:	03 45 08             	add    0x8(%ebp),%eax
 1f9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ff:	c9                   	leave  
 200:	c3                   	ret    

00000201 <stat>:

int
stat(char *n, struct stat *st)
{
 201:	55                   	push   %ebp
 202:	89 e5                	mov    %esp,%ebp
 204:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 207:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 20e:	00 
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	89 04 24             	mov    %eax,(%esp)
 215:	e8 b2 02 00 00       	call   4cc <open>
 21a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 21d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 221:	79 07                	jns    22a <stat+0x29>
    return -1;
 223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 228:	eb 23                	jmp    24d <stat+0x4c>
  r = fstat(fd, st);
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	89 44 24 04          	mov    %eax,0x4(%esp)
 231:	8b 45 f4             	mov    -0xc(%ebp),%eax
 234:	89 04 24             	mov    %eax,(%esp)
 237:	e8 a8 02 00 00       	call   4e4 <fstat>
 23c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 23f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 242:	89 04 24             	mov    %eax,(%esp)
 245:	e8 6a 02 00 00       	call   4b4 <close>
  return r;
 24a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 24d:	c9                   	leave  
 24e:	c3                   	ret    

0000024f <atoi>:

int
atoi(const char *s)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
 252:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 255:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 25c:	eb 23                	jmp    281 <atoi+0x32>
    n = n*10 + *s++ - '0';
 25e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 261:	89 d0                	mov    %edx,%eax
 263:	c1 e0 02             	shl    $0x2,%eax
 266:	01 d0                	add    %edx,%eax
 268:	01 c0                	add    %eax,%eax
 26a:	89 c2                	mov    %eax,%edx
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	0f b6 00             	movzbl (%eax),%eax
 272:	0f be c0             	movsbl %al,%eax
 275:	01 d0                	add    %edx,%eax
 277:	83 e8 30             	sub    $0x30,%eax
 27a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 27d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 281:	8b 45 08             	mov    0x8(%ebp),%eax
 284:	0f b6 00             	movzbl (%eax),%eax
 287:	3c 2f                	cmp    $0x2f,%al
 289:	7e 0a                	jle    295 <atoi+0x46>
 28b:	8b 45 08             	mov    0x8(%ebp),%eax
 28e:	0f b6 00             	movzbl (%eax),%eax
 291:	3c 39                	cmp    $0x39,%al
 293:	7e c9                	jle    25e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 295:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 298:	c9                   	leave  
 299:	c3                   	ret    

0000029a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 29a:	55                   	push   %ebp
 29b:	89 e5                	mov    %esp,%ebp
 29d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
 2a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ac:	eb 13                	jmp    2c1 <memmove+0x27>
    *dst++ = *src++;
 2ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2b1:	0f b6 10             	movzbl (%eax),%edx
 2b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b7:	88 10                	mov    %dl,(%eax)
 2b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2bd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2c5:	0f 9f c0             	setg   %al
 2c8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2cc:	84 c0                	test   %al,%al
 2ce:	75 de                	jne    2ae <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d3:	c9                   	leave  
 2d4:	c3                   	ret    

000002d5 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 2d5:	55                   	push   %ebp
 2d6:	89 e5                	mov    %esp,%ebp
 2d8:	83 ec 38             	sub    $0x38,%esp
 2db:	8b 45 10             	mov    0x10(%ebp),%eax
 2de:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 2e1:	8b 45 14             	mov    0x14(%ebp),%eax
 2e4:	8b 00                	mov    (%eax),%eax
 2e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 2f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2f4:	74 06                	je     2fc <strtok+0x27>
 2f6:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 2fa:	75 54                	jne    350 <strtok+0x7b>
    return match;
 2fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2ff:	eb 6e                	jmp    36f <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 301:	8b 45 f4             	mov    -0xc(%ebp),%eax
 304:	03 45 0c             	add    0xc(%ebp),%eax
 307:	0f b6 00             	movzbl (%eax),%eax
 30a:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 30d:	74 06                	je     315 <strtok+0x40>
      {
	index++;
 30f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 313:	eb 3c                	jmp    351 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 315:	8b 45 14             	mov    0x14(%ebp),%eax
 318:	8b 00                	mov    (%eax),%eax
 31a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 31d:	29 c2                	sub    %eax,%edx
 31f:	8b 45 14             	mov    0x14(%ebp),%eax
 322:	8b 00                	mov    (%eax),%eax
 324:	03 45 0c             	add    0xc(%ebp),%eax
 327:	89 54 24 08          	mov    %edx,0x8(%esp)
 32b:	89 44 24 04          	mov    %eax,0x4(%esp)
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	89 04 24             	mov    %eax,(%esp)
 335:	e8 37 00 00 00       	call   371 <strncpy>
 33a:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
 340:	0f b6 00             	movzbl (%eax),%eax
 343:	84 c0                	test   %al,%al
 345:	74 19                	je     360 <strtok+0x8b>
	  match = 1;
 347:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 34e:	eb 10                	jmp    360 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 350:	90                   	nop
 351:	8b 45 f4             	mov    -0xc(%ebp),%eax
 354:	03 45 0c             	add    0xc(%ebp),%eax
 357:	0f b6 00             	movzbl (%eax),%eax
 35a:	84 c0                	test   %al,%al
 35c:	75 a3                	jne    301 <strtok+0x2c>
 35e:	eb 01                	jmp    361 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 360:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 361:	8b 45 f4             	mov    -0xc(%ebp),%eax
 364:	8d 50 01             	lea    0x1(%eax),%edx
 367:	8b 45 14             	mov    0x14(%ebp),%eax
 36a:	89 10                	mov    %edx,(%eax)
  return match;
 36c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 36f:	c9                   	leave  
 370:	c3                   	ret    

00000371 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 371:	55                   	push   %ebp
 372:	89 e5                	mov    %esp,%ebp
 374:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 377:	8b 45 08             	mov    0x8(%ebp),%eax
 37a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 37d:	90                   	nop
 37e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 382:	0f 9f c0             	setg   %al
 385:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 389:	84 c0                	test   %al,%al
 38b:	74 30                	je     3bd <strncpy+0x4c>
 38d:	8b 45 0c             	mov    0xc(%ebp),%eax
 390:	0f b6 10             	movzbl (%eax),%edx
 393:	8b 45 08             	mov    0x8(%ebp),%eax
 396:	88 10                	mov    %dl,(%eax)
 398:	8b 45 08             	mov    0x8(%ebp),%eax
 39b:	0f b6 00             	movzbl (%eax),%eax
 39e:	84 c0                	test   %al,%al
 3a0:	0f 95 c0             	setne  %al
 3a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3ab:	84 c0                	test   %al,%al
 3ad:	75 cf                	jne    37e <strncpy+0xd>
    ;
  while(n-- > 0)
 3af:	eb 0c                	jmp    3bd <strncpy+0x4c>
    *s++ = 0;
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	c6 00 00             	movb   $0x0,(%eax)
 3b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3bb:	eb 01                	jmp    3be <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3bd:	90                   	nop
 3be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3c2:	0f 9f c0             	setg   %al
 3c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3c9:	84 c0                	test   %al,%al
 3cb:	75 e4                	jne    3b1 <strncpy+0x40>
    *s++ = 0;
  return os;
 3cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d0:	c9                   	leave  
 3d1:	c3                   	ret    

000003d2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3d2:	55                   	push   %ebp
 3d3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 3d5:	eb 0c                	jmp    3e3 <strncmp+0x11>
    n--, p++, q++;
 3d7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3df:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 3e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3e7:	74 1a                	je     403 <strncmp+0x31>
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	0f b6 00             	movzbl (%eax),%eax
 3ef:	84 c0                	test   %al,%al
 3f1:	74 10                	je     403 <strncmp+0x31>
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	0f b6 10             	movzbl (%eax),%edx
 3f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fc:	0f b6 00             	movzbl (%eax),%eax
 3ff:	38 c2                	cmp    %al,%dl
 401:	74 d4                	je     3d7 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 403:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 407:	75 07                	jne    410 <strncmp+0x3e>
    return 0;
 409:	b8 00 00 00 00       	mov    $0x0,%eax
 40e:	eb 18                	jmp    428 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 410:	8b 45 08             	mov    0x8(%ebp),%eax
 413:	0f b6 00             	movzbl (%eax),%eax
 416:	0f b6 d0             	movzbl %al,%edx
 419:	8b 45 0c             	mov    0xc(%ebp),%eax
 41c:	0f b6 00             	movzbl (%eax),%eax
 41f:	0f b6 c0             	movzbl %al,%eax
 422:	89 d1                	mov    %edx,%ecx
 424:	29 c1                	sub    %eax,%ecx
 426:	89 c8                	mov    %ecx,%eax
}
 428:	5d                   	pop    %ebp
 429:	c3                   	ret    

0000042a <strcat>:

void
strcat(char *dest, char *p, char *q)
{  
 42a:	55                   	push   %ebp
 42b:	89 e5                	mov    %esp,%ebp
  while(*p){
 42d:	eb 13                	jmp    442 <strcat+0x18>
    *dest++ = *p++;
 42f:	8b 45 0c             	mov    0xc(%ebp),%eax
 432:	0f b6 10             	movzbl (%eax),%edx
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	88 10                	mov    %dl,(%eax)
 43a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, char *p, char *q)
{  
  while(*p){
 442:	8b 45 0c             	mov    0xc(%ebp),%eax
 445:	0f b6 00             	movzbl (%eax),%eax
 448:	84 c0                	test   %al,%al
 44a:	75 e3                	jne    42f <strcat+0x5>
    *dest++ = *p++;
  }

  while(*q){
 44c:	eb 13                	jmp    461 <strcat+0x37>
    *dest++ = *q++;
 44e:	8b 45 10             	mov    0x10(%ebp),%eax
 451:	0f b6 10             	movzbl (%eax),%edx
 454:	8b 45 08             	mov    0x8(%ebp),%eax
 457:	88 10                	mov    %dl,(%eax)
 459:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
{  
  while(*p){
    *dest++ = *p++;
  }

  while(*q){
 461:	8b 45 10             	mov    0x10(%ebp),%eax
 464:	0f b6 00             	movzbl (%eax),%eax
 467:	84 c0                	test   %al,%al
 469:	75 e3                	jne    44e <strcat+0x24>
    *dest++ = *q++;
  }
  *dest = 0;
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	c6 00 00             	movb   $0x0,(%eax)
 471:	5d                   	pop    %ebp
 472:	c3                   	ret    
 473:	90                   	nop

00000474 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 474:	b8 01 00 00 00       	mov    $0x1,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <exit>:
SYSCALL(exit)
 47c:	b8 02 00 00 00       	mov    $0x2,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <wait>:
SYSCALL(wait)
 484:	b8 03 00 00 00       	mov    $0x3,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <wait2>:
SYSCALL(wait2)
 48c:	b8 16 00 00 00       	mov    $0x16,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <nice>:
SYSCALL(nice)
 494:	b8 17 00 00 00       	mov    $0x17,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <pipe>:
SYSCALL(pipe)
 49c:	b8 04 00 00 00       	mov    $0x4,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <read>:
SYSCALL(read)
 4a4:	b8 05 00 00 00       	mov    $0x5,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <write>:
SYSCALL(write)
 4ac:	b8 10 00 00 00       	mov    $0x10,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <close>:
SYSCALL(close)
 4b4:	b8 15 00 00 00       	mov    $0x15,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <kill>:
SYSCALL(kill)
 4bc:	b8 06 00 00 00       	mov    $0x6,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <exec>:
SYSCALL(exec)
 4c4:	b8 07 00 00 00       	mov    $0x7,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <open>:
SYSCALL(open)
 4cc:	b8 0f 00 00 00       	mov    $0xf,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <mknod>:
SYSCALL(mknod)
 4d4:	b8 11 00 00 00       	mov    $0x11,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <unlink>:
SYSCALL(unlink)
 4dc:	b8 12 00 00 00       	mov    $0x12,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <fstat>:
SYSCALL(fstat)
 4e4:	b8 08 00 00 00       	mov    $0x8,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <link>:
SYSCALL(link)
 4ec:	b8 13 00 00 00       	mov    $0x13,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <mkdir>:
SYSCALL(mkdir)
 4f4:	b8 14 00 00 00       	mov    $0x14,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <chdir>:
SYSCALL(chdir)
 4fc:	b8 09 00 00 00       	mov    $0x9,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <dup>:
SYSCALL(dup)
 504:	b8 0a 00 00 00       	mov    $0xa,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <getpid>:
SYSCALL(getpid)
 50c:	b8 0b 00 00 00       	mov    $0xb,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <sbrk>:
SYSCALL(sbrk)
 514:	b8 0c 00 00 00       	mov    $0xc,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <sleep>:
SYSCALL(sleep)
 51c:	b8 0d 00 00 00       	mov    $0xd,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <uptime>:
SYSCALL(uptime)
 524:	b8 0e 00 00 00       	mov    $0xe,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 52c:	55                   	push   %ebp
 52d:	89 e5                	mov    %esp,%ebp
 52f:	83 ec 28             	sub    $0x28,%esp
 532:	8b 45 0c             	mov    0xc(%ebp),%eax
 535:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 538:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 53f:	00 
 540:	8d 45 f4             	lea    -0xc(%ebp),%eax
 543:	89 44 24 04          	mov    %eax,0x4(%esp)
 547:	8b 45 08             	mov    0x8(%ebp),%eax
 54a:	89 04 24             	mov    %eax,(%esp)
 54d:	e8 5a ff ff ff       	call   4ac <write>
}
 552:	c9                   	leave  
 553:	c3                   	ret    

00000554 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 554:	55                   	push   %ebp
 555:	89 e5                	mov    %esp,%ebp
 557:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 55a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 561:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 565:	74 17                	je     57e <printint+0x2a>
 567:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 56b:	79 11                	jns    57e <printint+0x2a>
    neg = 1;
 56d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 574:	8b 45 0c             	mov    0xc(%ebp),%eax
 577:	f7 d8                	neg    %eax
 579:	89 45 ec             	mov    %eax,-0x14(%ebp)
 57c:	eb 06                	jmp    584 <printint+0x30>
  } else {
    x = xx;
 57e:	8b 45 0c             	mov    0xc(%ebp),%eax
 581:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 584:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 58b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 58e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 591:	ba 00 00 00 00       	mov    $0x0,%edx
 596:	f7 f1                	div    %ecx
 598:	89 d0                	mov    %edx,%eax
 59a:	0f b6 90 b4 0c 00 00 	movzbl 0xcb4(%eax),%edx
 5a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5a4:	03 45 f4             	add    -0xc(%ebp),%eax
 5a7:	88 10                	mov    %dl,(%eax)
 5a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5ad:	8b 55 10             	mov    0x10(%ebp),%edx
 5b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b6:	ba 00 00 00 00       	mov    $0x0,%edx
 5bb:	f7 75 d4             	divl   -0x2c(%ebp)
 5be:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c5:	75 c4                	jne    58b <printint+0x37>
  if(neg)
 5c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5cb:	74 2a                	je     5f7 <printint+0xa3>
    buf[i++] = '-';
 5cd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5d0:	03 45 f4             	add    -0xc(%ebp),%eax
 5d3:	c6 00 2d             	movb   $0x2d,(%eax)
 5d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5da:	eb 1b                	jmp    5f7 <printint+0xa3>
    putc(fd, buf[i]);
 5dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5df:	03 45 f4             	add    -0xc(%ebp),%eax
 5e2:	0f b6 00             	movzbl (%eax),%eax
 5e5:	0f be c0             	movsbl %al,%eax
 5e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ec:	8b 45 08             	mov    0x8(%ebp),%eax
 5ef:	89 04 24             	mov    %eax,(%esp)
 5f2:	e8 35 ff ff ff       	call   52c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5f7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ff:	79 db                	jns    5dc <printint+0x88>
    putc(fd, buf[i]);
}
 601:	c9                   	leave  
 602:	c3                   	ret    

00000603 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 603:	55                   	push   %ebp
 604:	89 e5                	mov    %esp,%ebp
 606:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 609:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 610:	8d 45 0c             	lea    0xc(%ebp),%eax
 613:	83 c0 04             	add    $0x4,%eax
 616:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 619:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 620:	e9 7d 01 00 00       	jmp    7a2 <printf+0x19f>
    c = fmt[i] & 0xff;
 625:	8b 55 0c             	mov    0xc(%ebp),%edx
 628:	8b 45 f0             	mov    -0x10(%ebp),%eax
 62b:	01 d0                	add    %edx,%eax
 62d:	0f b6 00             	movzbl (%eax),%eax
 630:	0f be c0             	movsbl %al,%eax
 633:	25 ff 00 00 00       	and    $0xff,%eax
 638:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 63b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63f:	75 2c                	jne    66d <printf+0x6a>
      if(c == '%'){
 641:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 645:	75 0c                	jne    653 <printf+0x50>
        state = '%';
 647:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 64e:	e9 4b 01 00 00       	jmp    79e <printf+0x19b>
      } else {
        putc(fd, c);
 653:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 656:	0f be c0             	movsbl %al,%eax
 659:	89 44 24 04          	mov    %eax,0x4(%esp)
 65d:	8b 45 08             	mov    0x8(%ebp),%eax
 660:	89 04 24             	mov    %eax,(%esp)
 663:	e8 c4 fe ff ff       	call   52c <putc>
 668:	e9 31 01 00 00       	jmp    79e <printf+0x19b>
      }
    } else if(state == '%'){
 66d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 671:	0f 85 27 01 00 00    	jne    79e <printf+0x19b>
      if(c == 'd'){
 677:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 67b:	75 2d                	jne    6aa <printf+0xa7>
        printint(fd, *ap, 10, 1);
 67d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 680:	8b 00                	mov    (%eax),%eax
 682:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 689:	00 
 68a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 691:	00 
 692:	89 44 24 04          	mov    %eax,0x4(%esp)
 696:	8b 45 08             	mov    0x8(%ebp),%eax
 699:	89 04 24             	mov    %eax,(%esp)
 69c:	e8 b3 fe ff ff       	call   554 <printint>
        ap++;
 6a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a5:	e9 ed 00 00 00       	jmp    797 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6aa:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ae:	74 06                	je     6b6 <printf+0xb3>
 6b0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b4:	75 2d                	jne    6e3 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b9:	8b 00                	mov    (%eax),%eax
 6bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6c2:	00 
 6c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6ca:	00 
 6cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cf:	8b 45 08             	mov    0x8(%ebp),%eax
 6d2:	89 04 24             	mov    %eax,(%esp)
 6d5:	e8 7a fe ff ff       	call   554 <printint>
        ap++;
 6da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6de:	e9 b4 00 00 00       	jmp    797 <printf+0x194>
      } else if(c == 's'){
 6e3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e7:	75 46                	jne    72f <printf+0x12c>
        s = (char*)*ap;
 6e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ec:	8b 00                	mov    (%eax),%eax
 6ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f9:	75 27                	jne    722 <printf+0x11f>
          s = "(null)";
 6fb:	c7 45 f4 ee 09 00 00 	movl   $0x9ee,-0xc(%ebp)
        while(*s != 0){
 702:	eb 1e                	jmp    722 <printf+0x11f>
          putc(fd, *s);
 704:	8b 45 f4             	mov    -0xc(%ebp),%eax
 707:	0f b6 00             	movzbl (%eax),%eax
 70a:	0f be c0             	movsbl %al,%eax
 70d:	89 44 24 04          	mov    %eax,0x4(%esp)
 711:	8b 45 08             	mov    0x8(%ebp),%eax
 714:	89 04 24             	mov    %eax,(%esp)
 717:	e8 10 fe ff ff       	call   52c <putc>
          s++;
 71c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 720:	eb 01                	jmp    723 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 722:	90                   	nop
 723:	8b 45 f4             	mov    -0xc(%ebp),%eax
 726:	0f b6 00             	movzbl (%eax),%eax
 729:	84 c0                	test   %al,%al
 72b:	75 d7                	jne    704 <printf+0x101>
 72d:	eb 68                	jmp    797 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 72f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 733:	75 1d                	jne    752 <printf+0x14f>
        putc(fd, *ap);
 735:	8b 45 e8             	mov    -0x18(%ebp),%eax
 738:	8b 00                	mov    (%eax),%eax
 73a:	0f be c0             	movsbl %al,%eax
 73d:	89 44 24 04          	mov    %eax,0x4(%esp)
 741:	8b 45 08             	mov    0x8(%ebp),%eax
 744:	89 04 24             	mov    %eax,(%esp)
 747:	e8 e0 fd ff ff       	call   52c <putc>
        ap++;
 74c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 750:	eb 45                	jmp    797 <printf+0x194>
      } else if(c == '%'){
 752:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 756:	75 17                	jne    76f <printf+0x16c>
        putc(fd, c);
 758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75b:	0f be c0             	movsbl %al,%eax
 75e:	89 44 24 04          	mov    %eax,0x4(%esp)
 762:	8b 45 08             	mov    0x8(%ebp),%eax
 765:	89 04 24             	mov    %eax,(%esp)
 768:	e8 bf fd ff ff       	call   52c <putc>
 76d:	eb 28                	jmp    797 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 776:	00 
 777:	8b 45 08             	mov    0x8(%ebp),%eax
 77a:	89 04 24             	mov    %eax,(%esp)
 77d:	e8 aa fd ff ff       	call   52c <putc>
        putc(fd, c);
 782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 785:	0f be c0             	movsbl %al,%eax
 788:	89 44 24 04          	mov    %eax,0x4(%esp)
 78c:	8b 45 08             	mov    0x8(%ebp),%eax
 78f:	89 04 24             	mov    %eax,(%esp)
 792:	e8 95 fd ff ff       	call   52c <putc>
      }
      state = 0;
 797:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 79e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a8:	01 d0                	add    %edx,%eax
 7aa:	0f b6 00             	movzbl (%eax),%eax
 7ad:	84 c0                	test   %al,%al
 7af:	0f 85 70 fe ff ff    	jne    625 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b5:	c9                   	leave  
 7b6:	c3                   	ret    
 7b7:	90                   	nop

000007b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b8:	55                   	push   %ebp
 7b9:	89 e5                	mov    %esp,%ebp
 7bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7be:	8b 45 08             	mov    0x8(%ebp),%eax
 7c1:	83 e8 08             	sub    $0x8,%eax
 7c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c7:	a1 d0 0c 00 00       	mov    0xcd0,%eax
 7cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cf:	eb 24                	jmp    7f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d9:	77 12                	ja     7ed <free+0x35>
 7db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e1:	77 24                	ja     807 <free+0x4f>
 7e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e6:	8b 00                	mov    (%eax),%eax
 7e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7eb:	77 1a                	ja     807 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f0:	8b 00                	mov    (%eax),%eax
 7f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7fb:	76 d4                	jbe    7d1 <free+0x19>
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 805:	76 ca                	jbe    7d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	c1 e0 03             	shl    $0x3,%eax
 810:	89 c2                	mov    %eax,%edx
 812:	03 55 f8             	add    -0x8(%ebp),%edx
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	8b 00                	mov    (%eax),%eax
 81a:	39 c2                	cmp    %eax,%edx
 81c:	75 24                	jne    842 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 81e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 821:	8b 50 04             	mov    0x4(%eax),%edx
 824:	8b 45 fc             	mov    -0x4(%ebp),%eax
 827:	8b 00                	mov    (%eax),%eax
 829:	8b 40 04             	mov    0x4(%eax),%eax
 82c:	01 c2                	add    %eax,%edx
 82e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 831:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 834:	8b 45 fc             	mov    -0x4(%ebp),%eax
 837:	8b 00                	mov    (%eax),%eax
 839:	8b 10                	mov    (%eax),%edx
 83b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83e:	89 10                	mov    %edx,(%eax)
 840:	eb 0a                	jmp    84c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 842:	8b 45 fc             	mov    -0x4(%ebp),%eax
 845:	8b 10                	mov    (%eax),%edx
 847:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 84c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84f:	8b 40 04             	mov    0x4(%eax),%eax
 852:	c1 e0 03             	shl    $0x3,%eax
 855:	03 45 fc             	add    -0x4(%ebp),%eax
 858:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 85b:	75 20                	jne    87d <free+0xc5>
    p->s.size += bp->s.size;
 85d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 860:	8b 50 04             	mov    0x4(%eax),%edx
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	8b 40 04             	mov    0x4(%eax),%eax
 869:	01 c2                	add    %eax,%edx
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 871:	8b 45 f8             	mov    -0x8(%ebp),%eax
 874:	8b 10                	mov    (%eax),%edx
 876:	8b 45 fc             	mov    -0x4(%ebp),%eax
 879:	89 10                	mov    %edx,(%eax)
 87b:	eb 08                	jmp    885 <free+0xcd>
  } else
    p->s.ptr = bp;
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 55 f8             	mov    -0x8(%ebp),%edx
 883:	89 10                	mov    %edx,(%eax)
  freep = p;
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	a3 d0 0c 00 00       	mov    %eax,0xcd0
}
 88d:	c9                   	leave  
 88e:	c3                   	ret    

0000088f <morecore>:

static Header*
morecore(uint nu)
{
 88f:	55                   	push   %ebp
 890:	89 e5                	mov    %esp,%ebp
 892:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 895:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 89c:	77 07                	ja     8a5 <morecore+0x16>
    nu = 4096;
 89e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a5:	8b 45 08             	mov    0x8(%ebp),%eax
 8a8:	c1 e0 03             	shl    $0x3,%eax
 8ab:	89 04 24             	mov    %eax,(%esp)
 8ae:	e8 61 fc ff ff       	call   514 <sbrk>
 8b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8b6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8ba:	75 07                	jne    8c3 <morecore+0x34>
    return 0;
 8bc:	b8 00 00 00 00       	mov    $0x0,%eax
 8c1:	eb 22                	jmp    8e5 <morecore+0x56>
  hp = (Header*)p;
 8c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cc:	8b 55 08             	mov    0x8(%ebp),%edx
 8cf:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d5:	83 c0 08             	add    $0x8,%eax
 8d8:	89 04 24             	mov    %eax,(%esp)
 8db:	e8 d8 fe ff ff       	call   7b8 <free>
  return freep;
 8e0:	a1 d0 0c 00 00       	mov    0xcd0,%eax
}
 8e5:	c9                   	leave  
 8e6:	c3                   	ret    

000008e7 <malloc>:

void*
malloc(uint nbytes)
{
 8e7:	55                   	push   %ebp
 8e8:	89 e5                	mov    %esp,%ebp
 8ea:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ed:	8b 45 08             	mov    0x8(%ebp),%eax
 8f0:	83 c0 07             	add    $0x7,%eax
 8f3:	c1 e8 03             	shr    $0x3,%eax
 8f6:	83 c0 01             	add    $0x1,%eax
 8f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8fc:	a1 d0 0c 00 00       	mov    0xcd0,%eax
 901:	89 45 f0             	mov    %eax,-0x10(%ebp)
 904:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 908:	75 23                	jne    92d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 90a:	c7 45 f0 c8 0c 00 00 	movl   $0xcc8,-0x10(%ebp)
 911:	8b 45 f0             	mov    -0x10(%ebp),%eax
 914:	a3 d0 0c 00 00       	mov    %eax,0xcd0
 919:	a1 d0 0c 00 00       	mov    0xcd0,%eax
 91e:	a3 c8 0c 00 00       	mov    %eax,0xcc8
    base.s.size = 0;
 923:	c7 05 cc 0c 00 00 00 	movl   $0x0,0xccc
 92a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 930:	8b 00                	mov    (%eax),%eax
 932:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 935:	8b 45 f4             	mov    -0xc(%ebp),%eax
 938:	8b 40 04             	mov    0x4(%eax),%eax
 93b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 93e:	72 4d                	jb     98d <malloc+0xa6>
      if(p->s.size == nunits)
 940:	8b 45 f4             	mov    -0xc(%ebp),%eax
 943:	8b 40 04             	mov    0x4(%eax),%eax
 946:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 949:	75 0c                	jne    957 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 94b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94e:	8b 10                	mov    (%eax),%edx
 950:	8b 45 f0             	mov    -0x10(%ebp),%eax
 953:	89 10                	mov    %edx,(%eax)
 955:	eb 26                	jmp    97d <malloc+0x96>
      else {
        p->s.size -= nunits;
 957:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95a:	8b 40 04             	mov    0x4(%eax),%eax
 95d:	89 c2                	mov    %eax,%edx
 95f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 962:	8b 45 f4             	mov    -0xc(%ebp),%eax
 965:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	8b 40 04             	mov    0x4(%eax),%eax
 96e:	c1 e0 03             	shl    $0x3,%eax
 971:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 974:	8b 45 f4             	mov    -0xc(%ebp),%eax
 977:	8b 55 ec             	mov    -0x14(%ebp),%edx
 97a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 97d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 980:	a3 d0 0c 00 00       	mov    %eax,0xcd0
      return (void*)(p + 1);
 985:	8b 45 f4             	mov    -0xc(%ebp),%eax
 988:	83 c0 08             	add    $0x8,%eax
 98b:	eb 38                	jmp    9c5 <malloc+0xde>
    }
    if(p == freep)
 98d:	a1 d0 0c 00 00       	mov    0xcd0,%eax
 992:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 995:	75 1b                	jne    9b2 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 997:	8b 45 ec             	mov    -0x14(%ebp),%eax
 99a:	89 04 24             	mov    %eax,(%esp)
 99d:	e8 ed fe ff ff       	call   88f <morecore>
 9a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9a9:	75 07                	jne    9b2 <malloc+0xcb>
        return 0;
 9ab:	b8 00 00 00 00       	mov    $0x0,%eax
 9b0:	eb 13                	jmp    9c5 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bb:	8b 00                	mov    (%eax),%eax
 9bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9c0:	e9 70 ff ff ff       	jmp    935 <malloc+0x4e>
}
 9c5:	c9                   	leave  
 9c6:	c3                   	ret    
