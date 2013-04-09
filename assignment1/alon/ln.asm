
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
   f:	c7 44 24 04 e1 09 00 	movl   $0x9e1,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 ee 05 00 00       	call   611 <printf>
    exit();
  23:	e8 5c 04 00 00       	call   484 <exit>
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
  3f:	e8 b0 04 00 00       	call   4f4 <link>
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
  60:	c7 44 24 04 f4 09 00 	movl   $0x9f4,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 9d 05 00 00       	call   611 <printf>
  exit();
  74:	e8 0b 04 00 00       	call   484 <exit>
  79:	66 90                	xchg   %ax,%ax
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
 129:	8b 55 fc             	mov    -0x4(%ebp),%edx
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	01 d0                	add    %edx,%eax
 131:	0f b6 00             	movzbl (%eax),%eax
 134:	84 c0                	test   %al,%al
 136:	75 ed                	jne    125 <strlen+0xf>
  return n;
 138:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13b:	c9                   	leave  
 13c:	c3                   	ret    

0000013d <memset>:

void*
memset(void *dst, int c, uint n)
{
 13d:	55                   	push   %ebp
 13e:	89 e5                	mov    %esp,%ebp
 140:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 143:	8b 45 10             	mov    0x10(%ebp),%eax
 146:	89 44 24 08          	mov    %eax,0x8(%esp)
 14a:	8b 45 0c             	mov    0xc(%ebp),%eax
 14d:	89 44 24 04          	mov    %eax,0x4(%esp)
 151:	8b 45 08             	mov    0x8(%ebp),%eax
 154:	89 04 24             	mov    %eax,(%esp)
 157:	e8 20 ff ff ff       	call   7c <stosb>
  return dst;
 15c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15f:	c9                   	leave  
 160:	c3                   	ret    

00000161 <strchr>:

char*
strchr(const char *s, char c)
{
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
 164:	83 ec 04             	sub    $0x4,%esp
 167:	8b 45 0c             	mov    0xc(%ebp),%eax
 16a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 16d:	eb 14                	jmp    183 <strchr+0x22>
    if(*s == c)
 16f:	8b 45 08             	mov    0x8(%ebp),%eax
 172:	0f b6 00             	movzbl (%eax),%eax
 175:	3a 45 fc             	cmp    -0x4(%ebp),%al
 178:	75 05                	jne    17f <strchr+0x1e>
      return (char*)s;
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	eb 13                	jmp    192 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 17f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 183:	8b 45 08             	mov    0x8(%ebp),%eax
 186:	0f b6 00             	movzbl (%eax),%eax
 189:	84 c0                	test   %al,%al
 18b:	75 e2                	jne    16f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 18d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 192:	c9                   	leave  
 193:	c3                   	ret    

00000194 <gets>:

char*
gets(char *buf, int max)
{
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a1:	eb 46                	jmp    1e9 <gets+0x55>
    cc = read(0, &c, 1);
 1a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1aa:	00 
 1ab:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b9:	e8 ee 02 00 00       	call   4ac <read>
 1be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c5:	7e 2f                	jle    1f6 <gets+0x62>
      break;
    buf[i++] = c;
 1c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	01 c2                	add    %eax,%edx
 1cf:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d3:	88 02                	mov    %al,(%edx)
 1d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1d9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1dd:	3c 0a                	cmp    $0xa,%al
 1df:	74 16                	je     1f7 <gets+0x63>
 1e1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e5:	3c 0d                	cmp    $0xd,%al
 1e7:	74 0e                	je     1f7 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ec:	83 c0 01             	add    $0x1,%eax
 1ef:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f2:	7c af                	jl     1a3 <gets+0xf>
 1f4:	eb 01                	jmp    1f7 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1f6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
 1fd:	01 d0                	add    %edx,%eax
 1ff:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 202:	8b 45 08             	mov    0x8(%ebp),%eax
}
 205:	c9                   	leave  
 206:	c3                   	ret    

00000207 <stat>:

int
stat(char *n, struct stat *st)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 214:	00 
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	89 04 24             	mov    %eax,(%esp)
 21b:	e8 b4 02 00 00       	call   4d4 <open>
 220:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 223:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 227:	79 07                	jns    230 <stat+0x29>
    return -1;
 229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22e:	eb 23                	jmp    253 <stat+0x4c>
  r = fstat(fd, st);
 230:	8b 45 0c             	mov    0xc(%ebp),%eax
 233:	89 44 24 04          	mov    %eax,0x4(%esp)
 237:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23a:	89 04 24             	mov    %eax,(%esp)
 23d:	e8 aa 02 00 00       	call   4ec <fstat>
 242:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 245:	8b 45 f4             	mov    -0xc(%ebp),%eax
 248:	89 04 24             	mov    %eax,(%esp)
 24b:	e8 6c 02 00 00       	call   4bc <close>
  return r;
 250:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 253:	c9                   	leave  
 254:	c3                   	ret    

00000255 <atoi>:

int
atoi(const char *s)
{
 255:	55                   	push   %ebp
 256:	89 e5                	mov    %esp,%ebp
 258:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 25b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 262:	eb 23                	jmp    287 <atoi+0x32>
    n = n*10 + *s++ - '0';
 264:	8b 55 fc             	mov    -0x4(%ebp),%edx
 267:	89 d0                	mov    %edx,%eax
 269:	c1 e0 02             	shl    $0x2,%eax
 26c:	01 d0                	add    %edx,%eax
 26e:	01 c0                	add    %eax,%eax
 270:	89 c2                	mov    %eax,%edx
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	0f b6 00             	movzbl (%eax),%eax
 278:	0f be c0             	movsbl %al,%eax
 27b:	01 d0                	add    %edx,%eax
 27d:	83 e8 30             	sub    $0x30,%eax
 280:	89 45 fc             	mov    %eax,-0x4(%ebp)
 283:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	0f b6 00             	movzbl (%eax),%eax
 28d:	3c 2f                	cmp    $0x2f,%al
 28f:	7e 0a                	jle    29b <atoi+0x46>
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	3c 39                	cmp    $0x39,%al
 299:	7e c9                	jle    264 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 29b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29e:	c9                   	leave  
 29f:	c3                   	ret    

000002a0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 2af:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b2:	eb 13                	jmp    2c7 <memmove+0x27>
    *dst++ = *src++;
 2b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2b7:	0f b6 10             	movzbl (%eax),%edx
 2ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2bd:	88 10                	mov    %dl,(%eax)
 2bf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2c3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2cb:	0f 9f c0             	setg   %al
 2ce:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2d2:	84 c0                	test   %al,%al
 2d4:	75 de                	jne    2b4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d9:	c9                   	leave  
 2da:	c3                   	ret    

000002db <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 2db:	55                   	push   %ebp
 2dc:	89 e5                	mov    %esp,%ebp
 2de:	83 ec 38             	sub    $0x38,%esp
 2e1:	8b 45 10             	mov    0x10(%ebp),%eax
 2e4:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 2e7:	8b 45 14             	mov    0x14(%ebp),%eax
 2ea:	8b 00                	mov    (%eax),%eax
 2ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 2f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2fa:	74 06                	je     302 <strtok+0x27>
 2fc:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 300:	75 5a                	jne    35c <strtok+0x81>
    return match;
 302:	8b 45 f0             	mov    -0x10(%ebp),%eax
 305:	eb 76                	jmp    37d <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 307:	8b 55 f4             	mov    -0xc(%ebp),%edx
 30a:	8b 45 0c             	mov    0xc(%ebp),%eax
 30d:	01 d0                	add    %edx,%eax
 30f:	0f b6 00             	movzbl (%eax),%eax
 312:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 315:	74 06                	je     31d <strtok+0x42>
      {
	index++;
 317:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 31b:	eb 40                	jmp    35d <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 31d:	8b 45 14             	mov    0x14(%ebp),%eax
 320:	8b 00                	mov    (%eax),%eax
 322:	8b 55 f4             	mov    -0xc(%ebp),%edx
 325:	29 c2                	sub    %eax,%edx
 327:	8b 45 14             	mov    0x14(%ebp),%eax
 32a:	8b 00                	mov    (%eax),%eax
 32c:	89 c1                	mov    %eax,%ecx
 32e:	8b 45 0c             	mov    0xc(%ebp),%eax
 331:	01 c8                	add    %ecx,%eax
 333:	89 54 24 08          	mov    %edx,0x8(%esp)
 337:	89 44 24 04          	mov    %eax,0x4(%esp)
 33b:	8b 45 08             	mov    0x8(%ebp),%eax
 33e:	89 04 24             	mov    %eax,(%esp)
 341:	e8 39 00 00 00       	call   37f <strncpy>
 346:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	0f b6 00             	movzbl (%eax),%eax
 34f:	84 c0                	test   %al,%al
 351:	74 1b                	je     36e <strtok+0x93>
	  match = 1;
 353:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 35a:	eb 12                	jmp    36e <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 35c:	90                   	nop
 35d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 360:	8b 45 0c             	mov    0xc(%ebp),%eax
 363:	01 d0                	add    %edx,%eax
 365:	0f b6 00             	movzbl (%eax),%eax
 368:	84 c0                	test   %al,%al
 36a:	75 9b                	jne    307 <strtok+0x2c>
 36c:	eb 01                	jmp    36f <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 36e:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 36f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 372:	8d 50 01             	lea    0x1(%eax),%edx
 375:	8b 45 14             	mov    0x14(%ebp),%eax
 378:	89 10                	mov    %edx,(%eax)
  return match;
 37a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 37d:	c9                   	leave  
 37e:	c3                   	ret    

0000037f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
 382:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 38b:	90                   	nop
 38c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 390:	0f 9f c0             	setg   %al
 393:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 397:	84 c0                	test   %al,%al
 399:	74 30                	je     3cb <strncpy+0x4c>
 39b:	8b 45 0c             	mov    0xc(%ebp),%eax
 39e:	0f b6 10             	movzbl (%eax),%edx
 3a1:	8b 45 08             	mov    0x8(%ebp),%eax
 3a4:	88 10                	mov    %dl,(%eax)
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	0f b6 00             	movzbl (%eax),%eax
 3ac:	84 c0                	test   %al,%al
 3ae:	0f 95 c0             	setne  %al
 3b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3b9:	84 c0                	test   %al,%al
 3bb:	75 cf                	jne    38c <strncpy+0xd>
    ;
  while(n-- > 0)
 3bd:	eb 0c                	jmp    3cb <strncpy+0x4c>
    *s++ = 0;
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	c6 00 00             	movb   $0x0,(%eax)
 3c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c9:	eb 01                	jmp    3cc <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3cb:	90                   	nop
 3cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3d0:	0f 9f c0             	setg   %al
 3d3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3d7:	84 c0                	test   %al,%al
 3d9:	75 e4                	jne    3bf <strncpy+0x40>
    *s++ = 0;
  return os;
 3db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3de:	c9                   	leave  
 3df:	c3                   	ret    

000003e0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 3e3:	eb 0c                	jmp    3f1 <strncmp+0x11>
    n--, p++, q++;
 3e5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3ed:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 3f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3f5:	74 1a                	je     411 <strncmp+0x31>
 3f7:	8b 45 08             	mov    0x8(%ebp),%eax
 3fa:	0f b6 00             	movzbl (%eax),%eax
 3fd:	84 c0                	test   %al,%al
 3ff:	74 10                	je     411 <strncmp+0x31>
 401:	8b 45 08             	mov    0x8(%ebp),%eax
 404:	0f b6 10             	movzbl (%eax),%edx
 407:	8b 45 0c             	mov    0xc(%ebp),%eax
 40a:	0f b6 00             	movzbl (%eax),%eax
 40d:	38 c2                	cmp    %al,%dl
 40f:	74 d4                	je     3e5 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 411:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 415:	75 07                	jne    41e <strncmp+0x3e>
    return 0;
 417:	b8 00 00 00 00       	mov    $0x0,%eax
 41c:	eb 18                	jmp    436 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 41e:	8b 45 08             	mov    0x8(%ebp),%eax
 421:	0f b6 00             	movzbl (%eax),%eax
 424:	0f b6 d0             	movzbl %al,%edx
 427:	8b 45 0c             	mov    0xc(%ebp),%eax
 42a:	0f b6 00             	movzbl (%eax),%eax
 42d:	0f b6 c0             	movzbl %al,%eax
 430:	89 d1                	mov    %edx,%ecx
 432:	29 c1                	sub    %eax,%ecx
 434:	89 c8                	mov    %ecx,%eax
}
 436:	5d                   	pop    %ebp
 437:	c3                   	ret    

00000438 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 438:	55                   	push   %ebp
 439:	89 e5                	mov    %esp,%ebp
  while(*p){
 43b:	eb 13                	jmp    450 <strcat+0x18>
    *dest++ = *p++;
 43d:	8b 45 0c             	mov    0xc(%ebp),%eax
 440:	0f b6 10             	movzbl (%eax),%edx
 443:	8b 45 08             	mov    0x8(%ebp),%eax
 446:	88 10                	mov    %dl,(%eax)
 448:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 44c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 450:	8b 45 0c             	mov    0xc(%ebp),%eax
 453:	0f b6 00             	movzbl (%eax),%eax
 456:	84 c0                	test   %al,%al
 458:	75 e3                	jne    43d <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 45a:	eb 13                	jmp    46f <strcat+0x37>
    *dest++ = *q++;
 45c:	8b 45 10             	mov    0x10(%ebp),%eax
 45f:	0f b6 10             	movzbl (%eax),%edx
 462:	8b 45 08             	mov    0x8(%ebp),%eax
 465:	88 10                	mov    %dl,(%eax)
 467:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 46b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 46f:	8b 45 10             	mov    0x10(%ebp),%eax
 472:	0f b6 00             	movzbl (%eax),%eax
 475:	84 c0                	test   %al,%al
 477:	75 e3                	jne    45c <strcat+0x24>
    *dest++ = *q++;
  }  
 479:	5d                   	pop    %ebp
 47a:	c3                   	ret    
 47b:	90                   	nop

0000047c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 47c:	b8 01 00 00 00       	mov    $0x1,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <exit>:
SYSCALL(exit)
 484:	b8 02 00 00 00       	mov    $0x2,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <wait>:
SYSCALL(wait)
 48c:	b8 03 00 00 00       	mov    $0x3,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <wait2>:
SYSCALL(wait2)
 494:	b8 16 00 00 00       	mov    $0x16,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <nice>:
SYSCALL(nice)
 49c:	b8 17 00 00 00       	mov    $0x17,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <pipe>:
SYSCALL(pipe)
 4a4:	b8 04 00 00 00       	mov    $0x4,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <read>:
SYSCALL(read)
 4ac:	b8 05 00 00 00       	mov    $0x5,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <write>:
SYSCALL(write)
 4b4:	b8 10 00 00 00       	mov    $0x10,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <close>:
SYSCALL(close)
 4bc:	b8 15 00 00 00       	mov    $0x15,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <kill>:
SYSCALL(kill)
 4c4:	b8 06 00 00 00       	mov    $0x6,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <exec>:
SYSCALL(exec)
 4cc:	b8 07 00 00 00       	mov    $0x7,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <open>:
SYSCALL(open)
 4d4:	b8 0f 00 00 00       	mov    $0xf,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <mknod>:
SYSCALL(mknod)
 4dc:	b8 11 00 00 00       	mov    $0x11,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <unlink>:
SYSCALL(unlink)
 4e4:	b8 12 00 00 00       	mov    $0x12,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <fstat>:
SYSCALL(fstat)
 4ec:	b8 08 00 00 00       	mov    $0x8,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <link>:
SYSCALL(link)
 4f4:	b8 13 00 00 00       	mov    $0x13,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <mkdir>:
SYSCALL(mkdir)
 4fc:	b8 14 00 00 00       	mov    $0x14,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <chdir>:
SYSCALL(chdir)
 504:	b8 09 00 00 00       	mov    $0x9,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <dup>:
SYSCALL(dup)
 50c:	b8 0a 00 00 00       	mov    $0xa,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <getpid>:
SYSCALL(getpid)
 514:	b8 0b 00 00 00       	mov    $0xb,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <sbrk>:
SYSCALL(sbrk)
 51c:	b8 0c 00 00 00       	mov    $0xc,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <sleep>:
SYSCALL(sleep)
 524:	b8 0d 00 00 00       	mov    $0xd,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <uptime>:
SYSCALL(uptime)
 52c:	b8 0e 00 00 00       	mov    $0xe,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 534:	55                   	push   %ebp
 535:	89 e5                	mov    %esp,%ebp
 537:	83 ec 28             	sub    $0x28,%esp
 53a:	8b 45 0c             	mov    0xc(%ebp),%eax
 53d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 540:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 547:	00 
 548:	8d 45 f4             	lea    -0xc(%ebp),%eax
 54b:	89 44 24 04          	mov    %eax,0x4(%esp)
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	89 04 24             	mov    %eax,(%esp)
 555:	e8 5a ff ff ff       	call   4b4 <write>
}
 55a:	c9                   	leave  
 55b:	c3                   	ret    

0000055c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 55c:	55                   	push   %ebp
 55d:	89 e5                	mov    %esp,%ebp
 55f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 562:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 569:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 56d:	74 17                	je     586 <printint+0x2a>
 56f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 573:	79 11                	jns    586 <printint+0x2a>
    neg = 1;
 575:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 57c:	8b 45 0c             	mov    0xc(%ebp),%eax
 57f:	f7 d8                	neg    %eax
 581:	89 45 ec             	mov    %eax,-0x14(%ebp)
 584:	eb 06                	jmp    58c <printint+0x30>
  } else {
    x = xx;
 586:	8b 45 0c             	mov    0xc(%ebp),%eax
 589:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 58c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 593:	8b 4d 10             	mov    0x10(%ebp),%ecx
 596:	8b 45 ec             	mov    -0x14(%ebp),%eax
 599:	ba 00 00 00 00       	mov    $0x0,%edx
 59e:	f7 f1                	div    %ecx
 5a0:	89 d0                	mov    %edx,%eax
 5a2:	0f b6 80 cc 0c 00 00 	movzbl 0xccc(%eax),%eax
 5a9:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 5ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5af:	01 ca                	add    %ecx,%edx
 5b1:	88 02                	mov    %al,(%edx)
 5b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5b7:	8b 55 10             	mov    0x10(%ebp),%edx
 5ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c0:	ba 00 00 00 00       	mov    $0x0,%edx
 5c5:	f7 75 d4             	divl   -0x2c(%ebp)
 5c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5cf:	75 c2                	jne    593 <printint+0x37>
  if(neg)
 5d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5d5:	74 2e                	je     605 <printint+0xa9>
    buf[i++] = '-';
 5d7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5dd:	01 d0                	add    %edx,%eax
 5df:	c6 00 2d             	movb   $0x2d,(%eax)
 5e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5e6:	eb 1d                	jmp    605 <printint+0xa9>
    putc(fd, buf[i]);
 5e8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ee:	01 d0                	add    %edx,%eax
 5f0:	0f b6 00             	movzbl (%eax),%eax
 5f3:	0f be c0             	movsbl %al,%eax
 5f6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5fa:	8b 45 08             	mov    0x8(%ebp),%eax
 5fd:	89 04 24             	mov    %eax,(%esp)
 600:	e8 2f ff ff ff       	call   534 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 605:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 609:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 60d:	79 d9                	jns    5e8 <printint+0x8c>
    putc(fd, buf[i]);
}
 60f:	c9                   	leave  
 610:	c3                   	ret    

00000611 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 611:	55                   	push   %ebp
 612:	89 e5                	mov    %esp,%ebp
 614:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 617:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 61e:	8d 45 0c             	lea    0xc(%ebp),%eax
 621:	83 c0 04             	add    $0x4,%eax
 624:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 627:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 62e:	e9 7d 01 00 00       	jmp    7b0 <printf+0x19f>
    c = fmt[i] & 0xff;
 633:	8b 55 0c             	mov    0xc(%ebp),%edx
 636:	8b 45 f0             	mov    -0x10(%ebp),%eax
 639:	01 d0                	add    %edx,%eax
 63b:	0f b6 00             	movzbl (%eax),%eax
 63e:	0f be c0             	movsbl %al,%eax
 641:	25 ff 00 00 00       	and    $0xff,%eax
 646:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 649:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64d:	75 2c                	jne    67b <printf+0x6a>
      if(c == '%'){
 64f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 653:	75 0c                	jne    661 <printf+0x50>
        state = '%';
 655:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 65c:	e9 4b 01 00 00       	jmp    7ac <printf+0x19b>
      } else {
        putc(fd, c);
 661:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 664:	0f be c0             	movsbl %al,%eax
 667:	89 44 24 04          	mov    %eax,0x4(%esp)
 66b:	8b 45 08             	mov    0x8(%ebp),%eax
 66e:	89 04 24             	mov    %eax,(%esp)
 671:	e8 be fe ff ff       	call   534 <putc>
 676:	e9 31 01 00 00       	jmp    7ac <printf+0x19b>
      }
    } else if(state == '%'){
 67b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 67f:	0f 85 27 01 00 00    	jne    7ac <printf+0x19b>
      if(c == 'd'){
 685:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 689:	75 2d                	jne    6b8 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 68b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68e:	8b 00                	mov    (%eax),%eax
 690:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 697:	00 
 698:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 69f:	00 
 6a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a4:	8b 45 08             	mov    0x8(%ebp),%eax
 6a7:	89 04 24             	mov    %eax,(%esp)
 6aa:	e8 ad fe ff ff       	call   55c <printint>
        ap++;
 6af:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b3:	e9 ed 00 00 00       	jmp    7a5 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6b8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6bc:	74 06                	je     6c4 <printf+0xb3>
 6be:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6c2:	75 2d                	jne    6f1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c7:	8b 00                	mov    (%eax),%eax
 6c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6d0:	00 
 6d1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6d8:	00 
 6d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6dd:	8b 45 08             	mov    0x8(%ebp),%eax
 6e0:	89 04 24             	mov    %eax,(%esp)
 6e3:	e8 74 fe ff ff       	call   55c <printint>
        ap++;
 6e8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ec:	e9 b4 00 00 00       	jmp    7a5 <printf+0x194>
      } else if(c == 's'){
 6f1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6f5:	75 46                	jne    73d <printf+0x12c>
        s = (char*)*ap;
 6f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6fa:	8b 00                	mov    (%eax),%eax
 6fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 703:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 707:	75 27                	jne    730 <printf+0x11f>
          s = "(null)";
 709:	c7 45 f4 08 0a 00 00 	movl   $0xa08,-0xc(%ebp)
        while(*s != 0){
 710:	eb 1e                	jmp    730 <printf+0x11f>
          putc(fd, *s);
 712:	8b 45 f4             	mov    -0xc(%ebp),%eax
 715:	0f b6 00             	movzbl (%eax),%eax
 718:	0f be c0             	movsbl %al,%eax
 71b:	89 44 24 04          	mov    %eax,0x4(%esp)
 71f:	8b 45 08             	mov    0x8(%ebp),%eax
 722:	89 04 24             	mov    %eax,(%esp)
 725:	e8 0a fe ff ff       	call   534 <putc>
          s++;
 72a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 72e:	eb 01                	jmp    731 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 730:	90                   	nop
 731:	8b 45 f4             	mov    -0xc(%ebp),%eax
 734:	0f b6 00             	movzbl (%eax),%eax
 737:	84 c0                	test   %al,%al
 739:	75 d7                	jne    712 <printf+0x101>
 73b:	eb 68                	jmp    7a5 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 73d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 741:	75 1d                	jne    760 <printf+0x14f>
        putc(fd, *ap);
 743:	8b 45 e8             	mov    -0x18(%ebp),%eax
 746:	8b 00                	mov    (%eax),%eax
 748:	0f be c0             	movsbl %al,%eax
 74b:	89 44 24 04          	mov    %eax,0x4(%esp)
 74f:	8b 45 08             	mov    0x8(%ebp),%eax
 752:	89 04 24             	mov    %eax,(%esp)
 755:	e8 da fd ff ff       	call   534 <putc>
        ap++;
 75a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 75e:	eb 45                	jmp    7a5 <printf+0x194>
      } else if(c == '%'){
 760:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 764:	75 17                	jne    77d <printf+0x16c>
        putc(fd, c);
 766:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 769:	0f be c0             	movsbl %al,%eax
 76c:	89 44 24 04          	mov    %eax,0x4(%esp)
 770:	8b 45 08             	mov    0x8(%ebp),%eax
 773:	89 04 24             	mov    %eax,(%esp)
 776:	e8 b9 fd ff ff       	call   534 <putc>
 77b:	eb 28                	jmp    7a5 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 77d:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 784:	00 
 785:	8b 45 08             	mov    0x8(%ebp),%eax
 788:	89 04 24             	mov    %eax,(%esp)
 78b:	e8 a4 fd ff ff       	call   534 <putc>
        putc(fd, c);
 790:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 793:	0f be c0             	movsbl %al,%eax
 796:	89 44 24 04          	mov    %eax,0x4(%esp)
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	89 04 24             	mov    %eax,(%esp)
 7a0:	e8 8f fd ff ff       	call   534 <putc>
      }
      state = 0;
 7a5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7ac:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7b0:	8b 55 0c             	mov    0xc(%ebp),%edx
 7b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b6:	01 d0                	add    %edx,%eax
 7b8:	0f b6 00             	movzbl (%eax),%eax
 7bb:	84 c0                	test   %al,%al
 7bd:	0f 85 70 fe ff ff    	jne    633 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7c3:	c9                   	leave  
 7c4:	c3                   	ret    
 7c5:	66 90                	xchg   %ax,%ax
 7c7:	90                   	nop

000007c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c8:	55                   	push   %ebp
 7c9:	89 e5                	mov    %esp,%ebp
 7cb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ce:	8b 45 08             	mov    0x8(%ebp),%eax
 7d1:	83 e8 08             	sub    $0x8,%eax
 7d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d7:	a1 e8 0c 00 00       	mov    0xce8,%eax
 7dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7df:	eb 24                	jmp    805 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e9:	77 12                	ja     7fd <free+0x35>
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f1:	77 24                	ja     817 <free+0x4f>
 7f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f6:	8b 00                	mov    (%eax),%eax
 7f8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7fb:	77 1a                	ja     817 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	89 45 fc             	mov    %eax,-0x4(%ebp)
 805:	8b 45 f8             	mov    -0x8(%ebp),%eax
 808:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 80b:	76 d4                	jbe    7e1 <free+0x19>
 80d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 815:	76 ca                	jbe    7e1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	8b 40 04             	mov    0x4(%eax),%eax
 81d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 824:	8b 45 f8             	mov    -0x8(%ebp),%eax
 827:	01 c2                	add    %eax,%edx
 829:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82c:	8b 00                	mov    (%eax),%eax
 82e:	39 c2                	cmp    %eax,%edx
 830:	75 24                	jne    856 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	8b 50 04             	mov    0x4(%eax),%edx
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	8b 40 04             	mov    0x4(%eax),%eax
 840:	01 c2                	add    %eax,%edx
 842:	8b 45 f8             	mov    -0x8(%ebp),%eax
 845:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 848:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84b:	8b 00                	mov    (%eax),%eax
 84d:	8b 10                	mov    (%eax),%edx
 84f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 852:	89 10                	mov    %edx,(%eax)
 854:	eb 0a                	jmp    860 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 856:	8b 45 fc             	mov    -0x4(%ebp),%eax
 859:	8b 10                	mov    (%eax),%edx
 85b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 860:	8b 45 fc             	mov    -0x4(%ebp),%eax
 863:	8b 40 04             	mov    0x4(%eax),%eax
 866:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 86d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 870:	01 d0                	add    %edx,%eax
 872:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 875:	75 20                	jne    897 <free+0xcf>
    p->s.size += bp->s.size;
 877:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87a:	8b 50 04             	mov    0x4(%eax),%edx
 87d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 880:	8b 40 04             	mov    0x4(%eax),%eax
 883:	01 c2                	add    %eax,%edx
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 88b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88e:	8b 10                	mov    (%eax),%edx
 890:	8b 45 fc             	mov    -0x4(%ebp),%eax
 893:	89 10                	mov    %edx,(%eax)
 895:	eb 08                	jmp    89f <free+0xd7>
  } else
    p->s.ptr = bp;
 897:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 89d:	89 10                	mov    %edx,(%eax)
  freep = p;
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	a3 e8 0c 00 00       	mov    %eax,0xce8
}
 8a7:	c9                   	leave  
 8a8:	c3                   	ret    

000008a9 <morecore>:

static Header*
morecore(uint nu)
{
 8a9:	55                   	push   %ebp
 8aa:	89 e5                	mov    %esp,%ebp
 8ac:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8af:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8b6:	77 07                	ja     8bf <morecore+0x16>
    nu = 4096;
 8b8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8bf:	8b 45 08             	mov    0x8(%ebp),%eax
 8c2:	c1 e0 03             	shl    $0x3,%eax
 8c5:	89 04 24             	mov    %eax,(%esp)
 8c8:	e8 4f fc ff ff       	call   51c <sbrk>
 8cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8d0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8d4:	75 07                	jne    8dd <morecore+0x34>
    return 0;
 8d6:	b8 00 00 00 00       	mov    $0x0,%eax
 8db:	eb 22                	jmp    8ff <morecore+0x56>
  hp = (Header*)p;
 8dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e6:	8b 55 08             	mov    0x8(%ebp),%edx
 8e9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ef:	83 c0 08             	add    $0x8,%eax
 8f2:	89 04 24             	mov    %eax,(%esp)
 8f5:	e8 ce fe ff ff       	call   7c8 <free>
  return freep;
 8fa:	a1 e8 0c 00 00       	mov    0xce8,%eax
}
 8ff:	c9                   	leave  
 900:	c3                   	ret    

00000901 <malloc>:

void*
malloc(uint nbytes)
{
 901:	55                   	push   %ebp
 902:	89 e5                	mov    %esp,%ebp
 904:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 907:	8b 45 08             	mov    0x8(%ebp),%eax
 90a:	83 c0 07             	add    $0x7,%eax
 90d:	c1 e8 03             	shr    $0x3,%eax
 910:	83 c0 01             	add    $0x1,%eax
 913:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 916:	a1 e8 0c 00 00       	mov    0xce8,%eax
 91b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 91e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 922:	75 23                	jne    947 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 924:	c7 45 f0 e0 0c 00 00 	movl   $0xce0,-0x10(%ebp)
 92b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92e:	a3 e8 0c 00 00       	mov    %eax,0xce8
 933:	a1 e8 0c 00 00       	mov    0xce8,%eax
 938:	a3 e0 0c 00 00       	mov    %eax,0xce0
    base.s.size = 0;
 93d:	c7 05 e4 0c 00 00 00 	movl   $0x0,0xce4
 944:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 947:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94a:	8b 00                	mov    (%eax),%eax
 94c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 94f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 958:	72 4d                	jb     9a7 <malloc+0xa6>
      if(p->s.size == nunits)
 95a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95d:	8b 40 04             	mov    0x4(%eax),%eax
 960:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 963:	75 0c                	jne    971 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 965:	8b 45 f4             	mov    -0xc(%ebp),%eax
 968:	8b 10                	mov    (%eax),%edx
 96a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96d:	89 10                	mov    %edx,(%eax)
 96f:	eb 26                	jmp    997 <malloc+0x96>
      else {
        p->s.size -= nunits;
 971:	8b 45 f4             	mov    -0xc(%ebp),%eax
 974:	8b 40 04             	mov    0x4(%eax),%eax
 977:	89 c2                	mov    %eax,%edx
 979:	2b 55 ec             	sub    -0x14(%ebp),%edx
 97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 982:	8b 45 f4             	mov    -0xc(%ebp),%eax
 985:	8b 40 04             	mov    0x4(%eax),%eax
 988:	c1 e0 03             	shl    $0x3,%eax
 98b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 98e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 991:	8b 55 ec             	mov    -0x14(%ebp),%edx
 994:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 997:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99a:	a3 e8 0c 00 00       	mov    %eax,0xce8
      return (void*)(p + 1);
 99f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a2:	83 c0 08             	add    $0x8,%eax
 9a5:	eb 38                	jmp    9df <malloc+0xde>
    }
    if(p == freep)
 9a7:	a1 e8 0c 00 00       	mov    0xce8,%eax
 9ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9af:	75 1b                	jne    9cc <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9b4:	89 04 24             	mov    %eax,(%esp)
 9b7:	e8 ed fe ff ff       	call   8a9 <morecore>
 9bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9c3:	75 07                	jne    9cc <malloc+0xcb>
        return 0;
 9c5:	b8 00 00 00 00       	mov    $0x0,%eax
 9ca:	eb 13                	jmp    9df <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d5:	8b 00                	mov    (%eax),%eax
 9d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9da:	e9 70 ff ff ff       	jmp    94f <malloc+0x4e>
}
 9df:	c9                   	leave  
 9e0:	c3                   	ret    
