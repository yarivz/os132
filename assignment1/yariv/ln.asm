
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
   f:	c7 44 24 04 c3 09 00 	movl   $0x9c3,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 dc 05 00 00       	call   5ff <printf>
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
  3f:	e8 a4 04 00 00       	call   4e8 <link>
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
  60:	c7 44 24 04 d6 09 00 	movl   $0x9d6,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 8b 05 00 00       	call   5ff <printf>
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
 1b7:	e8 e4 02 00 00       	call   4a0 <read>
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
 215:	e8 ae 02 00 00       	call   4c8 <open>
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
 237:	e8 a4 02 00 00       	call   4e0 <fstat>
 23c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 23f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 242:	89 04 24             	mov    %eax,(%esp)
 245:	e8 66 02 00 00       	call   4b0 <close>
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

00000490 <nice>:
SYSCALL(nice)
 490:	b8 17 00 00 00       	mov    $0x17,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <pipe>:
SYSCALL(pipe)
 498:	b8 04 00 00 00       	mov    $0x4,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <read>:
SYSCALL(read)
 4a0:	b8 05 00 00 00       	mov    $0x5,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <write>:
SYSCALL(write)
 4a8:	b8 10 00 00 00       	mov    $0x10,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <close>:
SYSCALL(close)
 4b0:	b8 15 00 00 00       	mov    $0x15,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <kill>:
SYSCALL(kill)
 4b8:	b8 06 00 00 00       	mov    $0x6,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <exec>:
SYSCALL(exec)
 4c0:	b8 07 00 00 00       	mov    $0x7,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <open>:
SYSCALL(open)
 4c8:	b8 0f 00 00 00       	mov    $0xf,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <mknod>:
SYSCALL(mknod)
 4d0:	b8 11 00 00 00       	mov    $0x11,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <unlink>:
SYSCALL(unlink)
 4d8:	b8 12 00 00 00       	mov    $0x12,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <fstat>:
SYSCALL(fstat)
 4e0:	b8 08 00 00 00       	mov    $0x8,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <link>:
SYSCALL(link)
 4e8:	b8 13 00 00 00       	mov    $0x13,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <mkdir>:
SYSCALL(mkdir)
 4f0:	b8 14 00 00 00       	mov    $0x14,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <chdir>:
SYSCALL(chdir)
 4f8:	b8 09 00 00 00       	mov    $0x9,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <dup>:
SYSCALL(dup)
 500:	b8 0a 00 00 00       	mov    $0xa,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <getpid>:
SYSCALL(getpid)
 508:	b8 0b 00 00 00       	mov    $0xb,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <sbrk>:
SYSCALL(sbrk)
 510:	b8 0c 00 00 00       	mov    $0xc,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <sleep>:
SYSCALL(sleep)
 518:	b8 0d 00 00 00       	mov    $0xd,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <uptime>:
SYSCALL(uptime)
 520:	b8 0e 00 00 00       	mov    $0xe,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 528:	55                   	push   %ebp
 529:	89 e5                	mov    %esp,%ebp
 52b:	83 ec 28             	sub    $0x28,%esp
 52e:	8b 45 0c             	mov    0xc(%ebp),%eax
 531:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 534:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 53b:	00 
 53c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 53f:	89 44 24 04          	mov    %eax,0x4(%esp)
 543:	8b 45 08             	mov    0x8(%ebp),%eax
 546:	89 04 24             	mov    %eax,(%esp)
 549:	e8 5a ff ff ff       	call   4a8 <write>
}
 54e:	c9                   	leave  
 54f:	c3                   	ret    

00000550 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 550:	55                   	push   %ebp
 551:	89 e5                	mov    %esp,%ebp
 553:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 556:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 55d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 561:	74 17                	je     57a <printint+0x2a>
 563:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 567:	79 11                	jns    57a <printint+0x2a>
    neg = 1;
 569:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 570:	8b 45 0c             	mov    0xc(%ebp),%eax
 573:	f7 d8                	neg    %eax
 575:	89 45 ec             	mov    %eax,-0x14(%ebp)
 578:	eb 06                	jmp    580 <printint+0x30>
  } else {
    x = xx;
 57a:	8b 45 0c             	mov    0xc(%ebp),%eax
 57d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 580:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 587:	8b 4d 10             	mov    0x10(%ebp),%ecx
 58a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 58d:	ba 00 00 00 00       	mov    $0x0,%edx
 592:	f7 f1                	div    %ecx
 594:	89 d0                	mov    %edx,%eax
 596:	0f b6 90 b0 0c 00 00 	movzbl 0xcb0(%eax),%edx
 59d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5a0:	03 45 f4             	add    -0xc(%ebp),%eax
 5a3:	88 10                	mov    %dl,(%eax)
 5a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5a9:	8b 55 10             	mov    0x10(%ebp),%edx
 5ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5af:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b2:	ba 00 00 00 00       	mov    $0x0,%edx
 5b7:	f7 75 d4             	divl   -0x2c(%ebp)
 5ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c1:	75 c4                	jne    587 <printint+0x37>
  if(neg)
 5c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c7:	74 2a                	je     5f3 <printint+0xa3>
    buf[i++] = '-';
 5c9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5cc:	03 45 f4             	add    -0xc(%ebp),%eax
 5cf:	c6 00 2d             	movb   $0x2d,(%eax)
 5d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5d6:	eb 1b                	jmp    5f3 <printint+0xa3>
    putc(fd, buf[i]);
 5d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5db:	03 45 f4             	add    -0xc(%ebp),%eax
 5de:	0f b6 00             	movzbl (%eax),%eax
 5e1:	0f be c0             	movsbl %al,%eax
 5e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e8:	8b 45 08             	mov    0x8(%ebp),%eax
 5eb:	89 04 24             	mov    %eax,(%esp)
 5ee:	e8 35 ff ff ff       	call   528 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5f3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fb:	79 db                	jns    5d8 <printint+0x88>
    putc(fd, buf[i]);
}
 5fd:	c9                   	leave  
 5fe:	c3                   	ret    

000005ff <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5ff:	55                   	push   %ebp
 600:	89 e5                	mov    %esp,%ebp
 602:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 605:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 60c:	8d 45 0c             	lea    0xc(%ebp),%eax
 60f:	83 c0 04             	add    $0x4,%eax
 612:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 615:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 61c:	e9 7d 01 00 00       	jmp    79e <printf+0x19f>
    c = fmt[i] & 0xff;
 621:	8b 55 0c             	mov    0xc(%ebp),%edx
 624:	8b 45 f0             	mov    -0x10(%ebp),%eax
 627:	01 d0                	add    %edx,%eax
 629:	0f b6 00             	movzbl (%eax),%eax
 62c:	0f be c0             	movsbl %al,%eax
 62f:	25 ff 00 00 00       	and    $0xff,%eax
 634:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 637:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63b:	75 2c                	jne    669 <printf+0x6a>
      if(c == '%'){
 63d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 641:	75 0c                	jne    64f <printf+0x50>
        state = '%';
 643:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 64a:	e9 4b 01 00 00       	jmp    79a <printf+0x19b>
      } else {
        putc(fd, c);
 64f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 652:	0f be c0             	movsbl %al,%eax
 655:	89 44 24 04          	mov    %eax,0x4(%esp)
 659:	8b 45 08             	mov    0x8(%ebp),%eax
 65c:	89 04 24             	mov    %eax,(%esp)
 65f:	e8 c4 fe ff ff       	call   528 <putc>
 664:	e9 31 01 00 00       	jmp    79a <printf+0x19b>
      }
    } else if(state == '%'){
 669:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 66d:	0f 85 27 01 00 00    	jne    79a <printf+0x19b>
      if(c == 'd'){
 673:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 677:	75 2d                	jne    6a6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 679:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 685:	00 
 686:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 68d:	00 
 68e:	89 44 24 04          	mov    %eax,0x4(%esp)
 692:	8b 45 08             	mov    0x8(%ebp),%eax
 695:	89 04 24             	mov    %eax,(%esp)
 698:	e8 b3 fe ff ff       	call   550 <printint>
        ap++;
 69d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a1:	e9 ed 00 00 00       	jmp    793 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6a6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6aa:	74 06                	je     6b2 <printf+0xb3>
 6ac:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b0:	75 2d                	jne    6df <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b5:	8b 00                	mov    (%eax),%eax
 6b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6be:	00 
 6bf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6c6:	00 
 6c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ce:	89 04 24             	mov    %eax,(%esp)
 6d1:	e8 7a fe ff ff       	call   550 <printint>
        ap++;
 6d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6da:	e9 b4 00 00 00       	jmp    793 <printf+0x194>
      } else if(c == 's'){
 6df:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e3:	75 46                	jne    72b <printf+0x12c>
        s = (char*)*ap;
 6e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f5:	75 27                	jne    71e <printf+0x11f>
          s = "(null)";
 6f7:	c7 45 f4 ea 09 00 00 	movl   $0x9ea,-0xc(%ebp)
        while(*s != 0){
 6fe:	eb 1e                	jmp    71e <printf+0x11f>
          putc(fd, *s);
 700:	8b 45 f4             	mov    -0xc(%ebp),%eax
 703:	0f b6 00             	movzbl (%eax),%eax
 706:	0f be c0             	movsbl %al,%eax
 709:	89 44 24 04          	mov    %eax,0x4(%esp)
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	89 04 24             	mov    %eax,(%esp)
 713:	e8 10 fe ff ff       	call   528 <putc>
          s++;
 718:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 71c:	eb 01                	jmp    71f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 71e:	90                   	nop
 71f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 722:	0f b6 00             	movzbl (%eax),%eax
 725:	84 c0                	test   %al,%al
 727:	75 d7                	jne    700 <printf+0x101>
 729:	eb 68                	jmp    793 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 72b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 72f:	75 1d                	jne    74e <printf+0x14f>
        putc(fd, *ap);
 731:	8b 45 e8             	mov    -0x18(%ebp),%eax
 734:	8b 00                	mov    (%eax),%eax
 736:	0f be c0             	movsbl %al,%eax
 739:	89 44 24 04          	mov    %eax,0x4(%esp)
 73d:	8b 45 08             	mov    0x8(%ebp),%eax
 740:	89 04 24             	mov    %eax,(%esp)
 743:	e8 e0 fd ff ff       	call   528 <putc>
        ap++;
 748:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74c:	eb 45                	jmp    793 <printf+0x194>
      } else if(c == '%'){
 74e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 752:	75 17                	jne    76b <printf+0x16c>
        putc(fd, c);
 754:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 757:	0f be c0             	movsbl %al,%eax
 75a:	89 44 24 04          	mov    %eax,0x4(%esp)
 75e:	8b 45 08             	mov    0x8(%ebp),%eax
 761:	89 04 24             	mov    %eax,(%esp)
 764:	e8 bf fd ff ff       	call   528 <putc>
 769:	eb 28                	jmp    793 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 772:	00 
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	89 04 24             	mov    %eax,(%esp)
 779:	e8 aa fd ff ff       	call   528 <putc>
        putc(fd, c);
 77e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 781:	0f be c0             	movsbl %al,%eax
 784:	89 44 24 04          	mov    %eax,0x4(%esp)
 788:	8b 45 08             	mov    0x8(%ebp),%eax
 78b:	89 04 24             	mov    %eax,(%esp)
 78e:	e8 95 fd ff ff       	call   528 <putc>
      }
      state = 0;
 793:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 79a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 79e:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a4:	01 d0                	add    %edx,%eax
 7a6:	0f b6 00             	movzbl (%eax),%eax
 7a9:	84 c0                	test   %al,%al
 7ab:	0f 85 70 fe ff ff    	jne    621 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b1:	c9                   	leave  
 7b2:	c3                   	ret    
 7b3:	90                   	nop

000007b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b4:	55                   	push   %ebp
 7b5:	89 e5                	mov    %esp,%ebp
 7b7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ba:	8b 45 08             	mov    0x8(%ebp),%eax
 7bd:	83 e8 08             	sub    $0x8,%eax
 7c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c3:	a1 cc 0c 00 00       	mov    0xccc,%eax
 7c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cb:	eb 24                	jmp    7f1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d5:	77 12                	ja     7e9 <free+0x35>
 7d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7dd:	77 24                	ja     803 <free+0x4f>
 7df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e2:	8b 00                	mov    (%eax),%eax
 7e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e7:	77 1a                	ja     803 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f7:	76 d4                	jbe    7cd <free+0x19>
 7f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fc:	8b 00                	mov    (%eax),%eax
 7fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 801:	76 ca                	jbe    7cd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 803:	8b 45 f8             	mov    -0x8(%ebp),%eax
 806:	8b 40 04             	mov    0x4(%eax),%eax
 809:	c1 e0 03             	shl    $0x3,%eax
 80c:	89 c2                	mov    %eax,%edx
 80e:	03 55 f8             	add    -0x8(%ebp),%edx
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	39 c2                	cmp    %eax,%edx
 818:	75 24                	jne    83e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 81a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81d:	8b 50 04             	mov    0x4(%eax),%edx
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
 823:	8b 00                	mov    (%eax),%eax
 825:	8b 40 04             	mov    0x4(%eax),%eax
 828:	01 c2                	add    %eax,%edx
 82a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	8b 45 fc             	mov    -0x4(%ebp),%eax
 833:	8b 00                	mov    (%eax),%eax
 835:	8b 10                	mov    (%eax),%edx
 837:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83a:	89 10                	mov    %edx,(%eax)
 83c:	eb 0a                	jmp    848 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 83e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 841:	8b 10                	mov    (%eax),%edx
 843:	8b 45 f8             	mov    -0x8(%ebp),%eax
 846:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 848:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84b:	8b 40 04             	mov    0x4(%eax),%eax
 84e:	c1 e0 03             	shl    $0x3,%eax
 851:	03 45 fc             	add    -0x4(%ebp),%eax
 854:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 857:	75 20                	jne    879 <free+0xc5>
    p->s.size += bp->s.size;
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 50 04             	mov    0x4(%eax),%edx
 85f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 862:	8b 40 04             	mov    0x4(%eax),%eax
 865:	01 c2                	add    %eax,%edx
 867:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 86d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 870:	8b 10                	mov    (%eax),%edx
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	89 10                	mov    %edx,(%eax)
 877:	eb 08                	jmp    881 <free+0xcd>
  } else
    p->s.ptr = bp;
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 87f:	89 10                	mov    %edx,(%eax)
  freep = p;
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	a3 cc 0c 00 00       	mov    %eax,0xccc
}
 889:	c9                   	leave  
 88a:	c3                   	ret    

0000088b <morecore>:

static Header*
morecore(uint nu)
{
 88b:	55                   	push   %ebp
 88c:	89 e5                	mov    %esp,%ebp
 88e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 891:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 898:	77 07                	ja     8a1 <morecore+0x16>
    nu = 4096;
 89a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a1:	8b 45 08             	mov    0x8(%ebp),%eax
 8a4:	c1 e0 03             	shl    $0x3,%eax
 8a7:	89 04 24             	mov    %eax,(%esp)
 8aa:	e8 61 fc ff ff       	call   510 <sbrk>
 8af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8b2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8b6:	75 07                	jne    8bf <morecore+0x34>
    return 0;
 8b8:	b8 00 00 00 00       	mov    $0x0,%eax
 8bd:	eb 22                	jmp    8e1 <morecore+0x56>
  hp = (Header*)p;
 8bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c8:	8b 55 08             	mov    0x8(%ebp),%edx
 8cb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d1:	83 c0 08             	add    $0x8,%eax
 8d4:	89 04 24             	mov    %eax,(%esp)
 8d7:	e8 d8 fe ff ff       	call   7b4 <free>
  return freep;
 8dc:	a1 cc 0c 00 00       	mov    0xccc,%eax
}
 8e1:	c9                   	leave  
 8e2:	c3                   	ret    

000008e3 <malloc>:

void*
malloc(uint nbytes)
{
 8e3:	55                   	push   %ebp
 8e4:	89 e5                	mov    %esp,%ebp
 8e6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ec:	83 c0 07             	add    $0x7,%eax
 8ef:	c1 e8 03             	shr    $0x3,%eax
 8f2:	83 c0 01             	add    $0x1,%eax
 8f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8f8:	a1 cc 0c 00 00       	mov    0xccc,%eax
 8fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 900:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 904:	75 23                	jne    929 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 906:	c7 45 f0 c4 0c 00 00 	movl   $0xcc4,-0x10(%ebp)
 90d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 910:	a3 cc 0c 00 00       	mov    %eax,0xccc
 915:	a1 cc 0c 00 00       	mov    0xccc,%eax
 91a:	a3 c4 0c 00 00       	mov    %eax,0xcc4
    base.s.size = 0;
 91f:	c7 05 c8 0c 00 00 00 	movl   $0x0,0xcc8
 926:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 929:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 93a:	72 4d                	jb     989 <malloc+0xa6>
      if(p->s.size == nunits)
 93c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93f:	8b 40 04             	mov    0x4(%eax),%eax
 942:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 945:	75 0c                	jne    953 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 947:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94a:	8b 10                	mov    (%eax),%edx
 94c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94f:	89 10                	mov    %edx,(%eax)
 951:	eb 26                	jmp    979 <malloc+0x96>
      else {
        p->s.size -= nunits;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	8b 40 04             	mov    0x4(%eax),%eax
 959:	89 c2                	mov    %eax,%edx
 95b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 95e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 961:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 964:	8b 45 f4             	mov    -0xc(%ebp),%eax
 967:	8b 40 04             	mov    0x4(%eax),%eax
 96a:	c1 e0 03             	shl    $0x3,%eax
 96d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 55 ec             	mov    -0x14(%ebp),%edx
 976:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 979:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97c:	a3 cc 0c 00 00       	mov    %eax,0xccc
      return (void*)(p + 1);
 981:	8b 45 f4             	mov    -0xc(%ebp),%eax
 984:	83 c0 08             	add    $0x8,%eax
 987:	eb 38                	jmp    9c1 <malloc+0xde>
    }
    if(p == freep)
 989:	a1 cc 0c 00 00       	mov    0xccc,%eax
 98e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 991:	75 1b                	jne    9ae <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 993:	8b 45 ec             	mov    -0x14(%ebp),%eax
 996:	89 04 24             	mov    %eax,(%esp)
 999:	e8 ed fe ff ff       	call   88b <morecore>
 99e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9a5:	75 07                	jne    9ae <malloc+0xcb>
        return 0;
 9a7:	b8 00 00 00 00       	mov    $0x0,%eax
 9ac:	eb 13                	jmp    9c1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	8b 00                	mov    (%eax),%eax
 9b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9bc:	e9 70 ff ff ff       	jmp    931 <malloc+0x4e>
}
 9c1:	c9                   	leave  
 9c2:	c3                   	ret    
