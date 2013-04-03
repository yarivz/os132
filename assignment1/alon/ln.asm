
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
   f:	c7 44 24 04 bb 09 00 	movl   $0x9bb,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 d4 05 00 00       	call   5f7 <printf>
    exit();
  23:	e8 50 04 00 00       	call   478 <exit>
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
  3f:	e8 9c 04 00 00       	call   4e0 <link>
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
  60:	c7 44 24 04 ce 09 00 	movl   $0x9ce,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 83 05 00 00       	call   5f7 <printf>
  exit();
  74:	e8 ff 03 00 00       	call   478 <exit>
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
 1b7:	e8 dc 02 00 00       	call   498 <read>
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
 215:	e8 a6 02 00 00       	call   4c0 <open>
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
 237:	e8 9c 02 00 00       	call   4d8 <fstat>
 23c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 23f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 242:	89 04 24             	mov    %eax,(%esp)
 245:	e8 5e 02 00 00       	call   4a8 <close>
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
strcat(char *dest, const char *p, const char *q)
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
strcat(char *dest, const char *p, const char *q)
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
strcat(char *dest, const char *p, const char *q)
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
 46b:	5d                   	pop    %ebp
 46c:	c3                   	ret    
 46d:	90                   	nop
 46e:	90                   	nop
 46f:	90                   	nop

00000470 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 470:	b8 01 00 00 00       	mov    $0x1,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <exit>:
SYSCALL(exit)
 478:	b8 02 00 00 00       	mov    $0x2,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <wait>:
SYSCALL(wait)
 480:	b8 03 00 00 00       	mov    $0x3,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <wait2>:
SYSCALL(wait2)
 488:	b8 16 00 00 00       	mov    $0x16,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <pipe>:
SYSCALL(pipe)
 490:	b8 04 00 00 00       	mov    $0x4,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <read>:
SYSCALL(read)
 498:	b8 05 00 00 00       	mov    $0x5,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <write>:
SYSCALL(write)
 4a0:	b8 10 00 00 00       	mov    $0x10,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <close>:
SYSCALL(close)
 4a8:	b8 15 00 00 00       	mov    $0x15,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <kill>:
SYSCALL(kill)
 4b0:	b8 06 00 00 00       	mov    $0x6,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <exec>:
SYSCALL(exec)
 4b8:	b8 07 00 00 00       	mov    $0x7,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <open>:
SYSCALL(open)
 4c0:	b8 0f 00 00 00       	mov    $0xf,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <mknod>:
SYSCALL(mknod)
 4c8:	b8 11 00 00 00       	mov    $0x11,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <unlink>:
SYSCALL(unlink)
 4d0:	b8 12 00 00 00       	mov    $0x12,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <fstat>:
SYSCALL(fstat)
 4d8:	b8 08 00 00 00       	mov    $0x8,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <link>:
SYSCALL(link)
 4e0:	b8 13 00 00 00       	mov    $0x13,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <mkdir>:
SYSCALL(mkdir)
 4e8:	b8 14 00 00 00       	mov    $0x14,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <chdir>:
SYSCALL(chdir)
 4f0:	b8 09 00 00 00       	mov    $0x9,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <dup>:
SYSCALL(dup)
 4f8:	b8 0a 00 00 00       	mov    $0xa,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <getpid>:
SYSCALL(getpid)
 500:	b8 0b 00 00 00       	mov    $0xb,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <sbrk>:
SYSCALL(sbrk)
 508:	b8 0c 00 00 00       	mov    $0xc,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <sleep>:
SYSCALL(sleep)
 510:	b8 0d 00 00 00       	mov    $0xd,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <uptime>:
SYSCALL(uptime)
 518:	b8 0e 00 00 00       	mov    $0xe,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	83 ec 28             	sub    $0x28,%esp
 526:	8b 45 0c             	mov    0xc(%ebp),%eax
 529:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 52c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 533:	00 
 534:	8d 45 f4             	lea    -0xc(%ebp),%eax
 537:	89 44 24 04          	mov    %eax,0x4(%esp)
 53b:	8b 45 08             	mov    0x8(%ebp),%eax
 53e:	89 04 24             	mov    %eax,(%esp)
 541:	e8 5a ff ff ff       	call   4a0 <write>
}
 546:	c9                   	leave  
 547:	c3                   	ret    

00000548 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 548:	55                   	push   %ebp
 549:	89 e5                	mov    %esp,%ebp
 54b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 54e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 555:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 559:	74 17                	je     572 <printint+0x2a>
 55b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 55f:	79 11                	jns    572 <printint+0x2a>
    neg = 1;
 561:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 568:	8b 45 0c             	mov    0xc(%ebp),%eax
 56b:	f7 d8                	neg    %eax
 56d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 570:	eb 06                	jmp    578 <printint+0x30>
  } else {
    x = xx;
 572:	8b 45 0c             	mov    0xc(%ebp),%eax
 575:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 578:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 57f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 582:	8b 45 ec             	mov    -0x14(%ebp),%eax
 585:	ba 00 00 00 00       	mov    $0x0,%edx
 58a:	f7 f1                	div    %ecx
 58c:	89 d0                	mov    %edx,%eax
 58e:	0f b6 90 a8 0c 00 00 	movzbl 0xca8(%eax),%edx
 595:	8d 45 dc             	lea    -0x24(%ebp),%eax
 598:	03 45 f4             	add    -0xc(%ebp),%eax
 59b:	88 10                	mov    %dl,(%eax)
 59d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5a1:	8b 55 10             	mov    0x10(%ebp),%edx
 5a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5aa:	ba 00 00 00 00       	mov    $0x0,%edx
 5af:	f7 75 d4             	divl   -0x2c(%ebp)
 5b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5b9:	75 c4                	jne    57f <printint+0x37>
  if(neg)
 5bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5bf:	74 2a                	je     5eb <printint+0xa3>
    buf[i++] = '-';
 5c1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5c4:	03 45 f4             	add    -0xc(%ebp),%eax
 5c7:	c6 00 2d             	movb   $0x2d,(%eax)
 5ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5ce:	eb 1b                	jmp    5eb <printint+0xa3>
    putc(fd, buf[i]);
 5d0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5d3:	03 45 f4             	add    -0xc(%ebp),%eax
 5d6:	0f b6 00             	movzbl (%eax),%eax
 5d9:	0f be c0             	movsbl %al,%eax
 5dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e0:	8b 45 08             	mov    0x8(%ebp),%eax
 5e3:	89 04 24             	mov    %eax,(%esp)
 5e6:	e8 35 ff ff ff       	call   520 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5eb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f3:	79 db                	jns    5d0 <printint+0x88>
    putc(fd, buf[i]);
}
 5f5:	c9                   	leave  
 5f6:	c3                   	ret    

000005f7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5f7:	55                   	push   %ebp
 5f8:	89 e5                	mov    %esp,%ebp
 5fa:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5fd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 604:	8d 45 0c             	lea    0xc(%ebp),%eax
 607:	83 c0 04             	add    $0x4,%eax
 60a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 60d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 614:	e9 7d 01 00 00       	jmp    796 <printf+0x19f>
    c = fmt[i] & 0xff;
 619:	8b 55 0c             	mov    0xc(%ebp),%edx
 61c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 61f:	01 d0                	add    %edx,%eax
 621:	0f b6 00             	movzbl (%eax),%eax
 624:	0f be c0             	movsbl %al,%eax
 627:	25 ff 00 00 00       	and    $0xff,%eax
 62c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 62f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 633:	75 2c                	jne    661 <printf+0x6a>
      if(c == '%'){
 635:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 639:	75 0c                	jne    647 <printf+0x50>
        state = '%';
 63b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 642:	e9 4b 01 00 00       	jmp    792 <printf+0x19b>
      } else {
        putc(fd, c);
 647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64a:	0f be c0             	movsbl %al,%eax
 64d:	89 44 24 04          	mov    %eax,0x4(%esp)
 651:	8b 45 08             	mov    0x8(%ebp),%eax
 654:	89 04 24             	mov    %eax,(%esp)
 657:	e8 c4 fe ff ff       	call   520 <putc>
 65c:	e9 31 01 00 00       	jmp    792 <printf+0x19b>
      }
    } else if(state == '%'){
 661:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 665:	0f 85 27 01 00 00    	jne    792 <printf+0x19b>
      if(c == 'd'){
 66b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 66f:	75 2d                	jne    69e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 671:	8b 45 e8             	mov    -0x18(%ebp),%eax
 674:	8b 00                	mov    (%eax),%eax
 676:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 67d:	00 
 67e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 685:	00 
 686:	89 44 24 04          	mov    %eax,0x4(%esp)
 68a:	8b 45 08             	mov    0x8(%ebp),%eax
 68d:	89 04 24             	mov    %eax,(%esp)
 690:	e8 b3 fe ff ff       	call   548 <printint>
        ap++;
 695:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 699:	e9 ed 00 00 00       	jmp    78b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 69e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6a2:	74 06                	je     6aa <printf+0xb3>
 6a4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6a8:	75 2d                	jne    6d7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ad:	8b 00                	mov    (%eax),%eax
 6af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6b6:	00 
 6b7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6be:	00 
 6bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c3:	8b 45 08             	mov    0x8(%ebp),%eax
 6c6:	89 04 24             	mov    %eax,(%esp)
 6c9:	e8 7a fe ff ff       	call   548 <printint>
        ap++;
 6ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d2:	e9 b4 00 00 00       	jmp    78b <printf+0x194>
      } else if(c == 's'){
 6d7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6db:	75 46                	jne    723 <printf+0x12c>
        s = (char*)*ap;
 6dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6e5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ed:	75 27                	jne    716 <printf+0x11f>
          s = "(null)";
 6ef:	c7 45 f4 e2 09 00 00 	movl   $0x9e2,-0xc(%ebp)
        while(*s != 0){
 6f6:	eb 1e                	jmp    716 <printf+0x11f>
          putc(fd, *s);
 6f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fb:	0f b6 00             	movzbl (%eax),%eax
 6fe:	0f be c0             	movsbl %al,%eax
 701:	89 44 24 04          	mov    %eax,0x4(%esp)
 705:	8b 45 08             	mov    0x8(%ebp),%eax
 708:	89 04 24             	mov    %eax,(%esp)
 70b:	e8 10 fe ff ff       	call   520 <putc>
          s++;
 710:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 714:	eb 01                	jmp    717 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 716:	90                   	nop
 717:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71a:	0f b6 00             	movzbl (%eax),%eax
 71d:	84 c0                	test   %al,%al
 71f:	75 d7                	jne    6f8 <printf+0x101>
 721:	eb 68                	jmp    78b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 723:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 727:	75 1d                	jne    746 <printf+0x14f>
        putc(fd, *ap);
 729:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72c:	8b 00                	mov    (%eax),%eax
 72e:	0f be c0             	movsbl %al,%eax
 731:	89 44 24 04          	mov    %eax,0x4(%esp)
 735:	8b 45 08             	mov    0x8(%ebp),%eax
 738:	89 04 24             	mov    %eax,(%esp)
 73b:	e8 e0 fd ff ff       	call   520 <putc>
        ap++;
 740:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 744:	eb 45                	jmp    78b <printf+0x194>
      } else if(c == '%'){
 746:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74a:	75 17                	jne    763 <printf+0x16c>
        putc(fd, c);
 74c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 74f:	0f be c0             	movsbl %al,%eax
 752:	89 44 24 04          	mov    %eax,0x4(%esp)
 756:	8b 45 08             	mov    0x8(%ebp),%eax
 759:	89 04 24             	mov    %eax,(%esp)
 75c:	e8 bf fd ff ff       	call   520 <putc>
 761:	eb 28                	jmp    78b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 763:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 76a:	00 
 76b:	8b 45 08             	mov    0x8(%ebp),%eax
 76e:	89 04 24             	mov    %eax,(%esp)
 771:	e8 aa fd ff ff       	call   520 <putc>
        putc(fd, c);
 776:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 779:	0f be c0             	movsbl %al,%eax
 77c:	89 44 24 04          	mov    %eax,0x4(%esp)
 780:	8b 45 08             	mov    0x8(%ebp),%eax
 783:	89 04 24             	mov    %eax,(%esp)
 786:	e8 95 fd ff ff       	call   520 <putc>
      }
      state = 0;
 78b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 792:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 796:	8b 55 0c             	mov    0xc(%ebp),%edx
 799:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79c:	01 d0                	add    %edx,%eax
 79e:	0f b6 00             	movzbl (%eax),%eax
 7a1:	84 c0                	test   %al,%al
 7a3:	0f 85 70 fe ff ff    	jne    619 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7a9:	c9                   	leave  
 7aa:	c3                   	ret    
 7ab:	90                   	nop

000007ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ac:	55                   	push   %ebp
 7ad:	89 e5                	mov    %esp,%ebp
 7af:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b2:	8b 45 08             	mov    0x8(%ebp),%eax
 7b5:	83 e8 08             	sub    $0x8,%eax
 7b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bb:	a1 c4 0c 00 00       	mov    0xcc4,%eax
 7c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c3:	eb 24                	jmp    7e9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7cd:	77 12                	ja     7e1 <free+0x35>
 7cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d5:	77 24                	ja     7fb <free+0x4f>
 7d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7da:	8b 00                	mov    (%eax),%eax
 7dc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7df:	77 1a                	ja     7fb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ef:	76 d4                	jbe    7c5 <free+0x19>
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7f9:	76 ca                	jbe    7c5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fe:	8b 40 04             	mov    0x4(%eax),%eax
 801:	c1 e0 03             	shl    $0x3,%eax
 804:	89 c2                	mov    %eax,%edx
 806:	03 55 f8             	add    -0x8(%ebp),%edx
 809:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80c:	8b 00                	mov    (%eax),%eax
 80e:	39 c2                	cmp    %eax,%edx
 810:	75 24                	jne    836 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 812:	8b 45 f8             	mov    -0x8(%ebp),%eax
 815:	8b 50 04             	mov    0x4(%eax),%edx
 818:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81b:	8b 00                	mov    (%eax),%eax
 81d:	8b 40 04             	mov    0x4(%eax),%eax
 820:	01 c2                	add    %eax,%edx
 822:	8b 45 f8             	mov    -0x8(%ebp),%eax
 825:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	8b 00                	mov    (%eax),%eax
 82d:	8b 10                	mov    (%eax),%edx
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	89 10                	mov    %edx,(%eax)
 834:	eb 0a                	jmp    840 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 836:	8b 45 fc             	mov    -0x4(%ebp),%eax
 839:	8b 10                	mov    (%eax),%edx
 83b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 840:	8b 45 fc             	mov    -0x4(%ebp),%eax
 843:	8b 40 04             	mov    0x4(%eax),%eax
 846:	c1 e0 03             	shl    $0x3,%eax
 849:	03 45 fc             	add    -0x4(%ebp),%eax
 84c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 84f:	75 20                	jne    871 <free+0xc5>
    p->s.size += bp->s.size;
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	8b 50 04             	mov    0x4(%eax),%edx
 857:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85a:	8b 40 04             	mov    0x4(%eax),%eax
 85d:	01 c2                	add    %eax,%edx
 85f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 862:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 865:	8b 45 f8             	mov    -0x8(%ebp),%eax
 868:	8b 10                	mov    (%eax),%edx
 86a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86d:	89 10                	mov    %edx,(%eax)
 86f:	eb 08                	jmp    879 <free+0xcd>
  } else
    p->s.ptr = bp;
 871:	8b 45 fc             	mov    -0x4(%ebp),%eax
 874:	8b 55 f8             	mov    -0x8(%ebp),%edx
 877:	89 10                	mov    %edx,(%eax)
  freep = p;
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	a3 c4 0c 00 00       	mov    %eax,0xcc4
}
 881:	c9                   	leave  
 882:	c3                   	ret    

00000883 <morecore>:

static Header*
morecore(uint nu)
{
 883:	55                   	push   %ebp
 884:	89 e5                	mov    %esp,%ebp
 886:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 889:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 890:	77 07                	ja     899 <morecore+0x16>
    nu = 4096;
 892:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 899:	8b 45 08             	mov    0x8(%ebp),%eax
 89c:	c1 e0 03             	shl    $0x3,%eax
 89f:	89 04 24             	mov    %eax,(%esp)
 8a2:	e8 61 fc ff ff       	call   508 <sbrk>
 8a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8aa:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8ae:	75 07                	jne    8b7 <morecore+0x34>
    return 0;
 8b0:	b8 00 00 00 00       	mov    $0x0,%eax
 8b5:	eb 22                	jmp    8d9 <morecore+0x56>
  hp = (Header*)p;
 8b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c0:	8b 55 08             	mov    0x8(%ebp),%edx
 8c3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c9:	83 c0 08             	add    $0x8,%eax
 8cc:	89 04 24             	mov    %eax,(%esp)
 8cf:	e8 d8 fe ff ff       	call   7ac <free>
  return freep;
 8d4:	a1 c4 0c 00 00       	mov    0xcc4,%eax
}
 8d9:	c9                   	leave  
 8da:	c3                   	ret    

000008db <malloc>:

void*
malloc(uint nbytes)
{
 8db:	55                   	push   %ebp
 8dc:	89 e5                	mov    %esp,%ebp
 8de:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e1:	8b 45 08             	mov    0x8(%ebp),%eax
 8e4:	83 c0 07             	add    $0x7,%eax
 8e7:	c1 e8 03             	shr    $0x3,%eax
 8ea:	83 c0 01             	add    $0x1,%eax
 8ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8f0:	a1 c4 0c 00 00       	mov    0xcc4,%eax
 8f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8fc:	75 23                	jne    921 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8fe:	c7 45 f0 bc 0c 00 00 	movl   $0xcbc,-0x10(%ebp)
 905:	8b 45 f0             	mov    -0x10(%ebp),%eax
 908:	a3 c4 0c 00 00       	mov    %eax,0xcc4
 90d:	a1 c4 0c 00 00       	mov    0xcc4,%eax
 912:	a3 bc 0c 00 00       	mov    %eax,0xcbc
    base.s.size = 0;
 917:	c7 05 c0 0c 00 00 00 	movl   $0x0,0xcc0
 91e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 921:	8b 45 f0             	mov    -0x10(%ebp),%eax
 924:	8b 00                	mov    (%eax),%eax
 926:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 929:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92c:	8b 40 04             	mov    0x4(%eax),%eax
 92f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 932:	72 4d                	jb     981 <malloc+0xa6>
      if(p->s.size == nunits)
 934:	8b 45 f4             	mov    -0xc(%ebp),%eax
 937:	8b 40 04             	mov    0x4(%eax),%eax
 93a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 93d:	75 0c                	jne    94b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 93f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 942:	8b 10                	mov    (%eax),%edx
 944:	8b 45 f0             	mov    -0x10(%ebp),%eax
 947:	89 10                	mov    %edx,(%eax)
 949:	eb 26                	jmp    971 <malloc+0x96>
      else {
        p->s.size -= nunits;
 94b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94e:	8b 40 04             	mov    0x4(%eax),%eax
 951:	89 c2                	mov    %eax,%edx
 953:	2b 55 ec             	sub    -0x14(%ebp),%edx
 956:	8b 45 f4             	mov    -0xc(%ebp),%eax
 959:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 95c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95f:	8b 40 04             	mov    0x4(%eax),%eax
 962:	c1 e0 03             	shl    $0x3,%eax
 965:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 96e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 971:	8b 45 f0             	mov    -0x10(%ebp),%eax
 974:	a3 c4 0c 00 00       	mov    %eax,0xcc4
      return (void*)(p + 1);
 979:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97c:	83 c0 08             	add    $0x8,%eax
 97f:	eb 38                	jmp    9b9 <malloc+0xde>
    }
    if(p == freep)
 981:	a1 c4 0c 00 00       	mov    0xcc4,%eax
 986:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 989:	75 1b                	jne    9a6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 98b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 98e:	89 04 24             	mov    %eax,(%esp)
 991:	e8 ed fe ff ff       	call   883 <morecore>
 996:	89 45 f4             	mov    %eax,-0xc(%ebp)
 999:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 99d:	75 07                	jne    9a6 <malloc+0xcb>
        return 0;
 99f:	b8 00 00 00 00       	mov    $0x0,%eax
 9a4:	eb 13                	jmp    9b9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9af:	8b 00                	mov    (%eax),%eax
 9b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9b4:	e9 70 ff ff ff       	jmp    929 <malloc+0x4e>
}
 9b9:	c9                   	leave  
 9ba:	c3                   	ret    
