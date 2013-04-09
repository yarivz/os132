
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 16 04 00 00       	call   424 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 ae 04 00 00       	call   4cc <sleep>
  exit();
  1e:	e8 09 04 00 00       	call   42c <exit>
  23:	90                   	nop

00000024 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	57                   	push   %edi
  28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2c:	8b 55 10             	mov    0x10(%ebp),%edx
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	89 cb                	mov    %ecx,%ebx
  34:	89 df                	mov    %ebx,%edi
  36:	89 d1                	mov    %edx,%ecx
  38:	fc                   	cld    
  39:	f3 aa                	rep stos %al,%es:(%edi)
  3b:	89 ca                	mov    %ecx,%edx
  3d:	89 fb                	mov    %edi,%ebx
  3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  45:	5b                   	pop    %ebx
  46:	5f                   	pop    %edi
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    

00000049 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  49:	55                   	push   %ebp
  4a:	89 e5                	mov    %esp,%ebp
  4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  4f:	8b 45 08             	mov    0x8(%ebp),%eax
  52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  55:	90                   	nop
  56:	8b 45 0c             	mov    0xc(%ebp),%eax
  59:	0f b6 10             	movzbl (%eax),%edx
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	88 10                	mov    %dl,(%eax)
  61:	8b 45 08             	mov    0x8(%ebp),%eax
  64:	0f b6 00             	movzbl (%eax),%eax
  67:	84 c0                	test   %al,%al
  69:	0f 95 c0             	setne  %al
  6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  74:	84 c0                	test   %al,%al
  76:	75 de                	jne    56 <strcpy+0xd>
    ;
  return os;
  78:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  7b:	c9                   	leave  
  7c:	c3                   	ret    

0000007d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  80:	eb 08                	jmp    8a <strcmp+0xd>
    p++, q++;
  82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  8a:	8b 45 08             	mov    0x8(%ebp),%eax
  8d:	0f b6 00             	movzbl (%eax),%eax
  90:	84 c0                	test   %al,%al
  92:	74 10                	je     a4 <strcmp+0x27>
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	0f b6 10             	movzbl (%eax),%edx
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	0f b6 00             	movzbl (%eax),%eax
  a0:	38 c2                	cmp    %al,%dl
  a2:	74 de                	je     82 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	0f b6 00             	movzbl (%eax),%eax
  aa:	0f b6 d0             	movzbl %al,%edx
  ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	0f b6 c0             	movzbl %al,%eax
  b6:	89 d1                	mov    %edx,%ecx
  b8:	29 c1                	sub    %eax,%ecx
  ba:	89 c8                	mov    %ecx,%eax
}
  bc:	5d                   	pop    %ebp
  bd:	c3                   	ret    

000000be <strlen>:

uint
strlen(char *s)
{
  be:	55                   	push   %ebp
  bf:	89 e5                	mov    %esp,%ebp
  c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
  c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  cb:	eb 04                	jmp    d1 <strlen+0x13>
  cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	01 d0                	add    %edx,%eax
  d9:	0f b6 00             	movzbl (%eax),%eax
  dc:	84 c0                	test   %al,%al
  de:	75 ed                	jne    cd <strlen+0xf>
  return n;
  e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e3:	c9                   	leave  
  e4:	c3                   	ret    

000000e5 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e5:	55                   	push   %ebp
  e6:	89 e5                	mov    %esp,%ebp
  e8:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  eb:	8b 45 10             	mov    0x10(%ebp),%eax
  ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  f9:	8b 45 08             	mov    0x8(%ebp),%eax
  fc:	89 04 24             	mov    %eax,(%esp)
  ff:	e8 20 ff ff ff       	call   24 <stosb>
  return dst;
 104:	8b 45 08             	mov    0x8(%ebp),%eax
}
 107:	c9                   	leave  
 108:	c3                   	ret    

00000109 <strchr>:

char*
strchr(const char *s, char c)
{
 109:	55                   	push   %ebp
 10a:	89 e5                	mov    %esp,%ebp
 10c:	83 ec 04             	sub    $0x4,%esp
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 115:	eb 14                	jmp    12b <strchr+0x22>
    if(*s == c)
 117:	8b 45 08             	mov    0x8(%ebp),%eax
 11a:	0f b6 00             	movzbl (%eax),%eax
 11d:	3a 45 fc             	cmp    -0x4(%ebp),%al
 120:	75 05                	jne    127 <strchr+0x1e>
      return (char*)s;
 122:	8b 45 08             	mov    0x8(%ebp),%eax
 125:	eb 13                	jmp    13a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 127:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 12b:	8b 45 08             	mov    0x8(%ebp),%eax
 12e:	0f b6 00             	movzbl (%eax),%eax
 131:	84 c0                	test   %al,%al
 133:	75 e2                	jne    117 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 135:	b8 00 00 00 00       	mov    $0x0,%eax
}
 13a:	c9                   	leave  
 13b:	c3                   	ret    

0000013c <gets>:

char*
gets(char *buf, int max)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 142:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 149:	eb 46                	jmp    191 <gets+0x55>
    cc = read(0, &c, 1);
 14b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 152:	00 
 153:	8d 45 ef             	lea    -0x11(%ebp),%eax
 156:	89 44 24 04          	mov    %eax,0x4(%esp)
 15a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 161:	e8 ee 02 00 00       	call   454 <read>
 166:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 169:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 16d:	7e 2f                	jle    19e <gets+0x62>
      break;
    buf[i++] = c;
 16f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	01 c2                	add    %eax,%edx
 177:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 17b:	88 02                	mov    %al,(%edx)
 17d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 181:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 185:	3c 0a                	cmp    $0xa,%al
 187:	74 16                	je     19f <gets+0x63>
 189:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 18d:	3c 0d                	cmp    $0xd,%al
 18f:	74 0e                	je     19f <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 191:	8b 45 f4             	mov    -0xc(%ebp),%eax
 194:	83 c0 01             	add    $0x1,%eax
 197:	3b 45 0c             	cmp    0xc(%ebp),%eax
 19a:	7c af                	jl     14b <gets+0xf>
 19c:	eb 01                	jmp    19f <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 19e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 19f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1a2:	8b 45 08             	mov    0x8(%ebp),%eax
 1a5:	01 d0                	add    %edx,%eax
 1a7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ad:	c9                   	leave  
 1ae:	c3                   	ret    

000001af <stat>:

int
stat(char *n, struct stat *st)
{
 1af:	55                   	push   %ebp
 1b0:	89 e5                	mov    %esp,%ebp
 1b2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1bc:	00 
 1bd:	8b 45 08             	mov    0x8(%ebp),%eax
 1c0:	89 04 24             	mov    %eax,(%esp)
 1c3:	e8 b4 02 00 00       	call   47c <open>
 1c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1cf:	79 07                	jns    1d8 <stat+0x29>
    return -1;
 1d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1d6:	eb 23                	jmp    1fb <stat+0x4c>
  r = fstat(fd, st);
 1d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1db:	89 44 24 04          	mov    %eax,0x4(%esp)
 1df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e2:	89 04 24             	mov    %eax,(%esp)
 1e5:	e8 aa 02 00 00       	call   494 <fstat>
 1ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f0:	89 04 24             	mov    %eax,(%esp)
 1f3:	e8 6c 02 00 00       	call   464 <close>
  return r;
 1f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1fb:	c9                   	leave  
 1fc:	c3                   	ret    

000001fd <atoi>:

int
atoi(const char *s)
{
 1fd:	55                   	push   %ebp
 1fe:	89 e5                	mov    %esp,%ebp
 200:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 203:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 20a:	eb 23                	jmp    22f <atoi+0x32>
    n = n*10 + *s++ - '0';
 20c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 20f:	89 d0                	mov    %edx,%eax
 211:	c1 e0 02             	shl    $0x2,%eax
 214:	01 d0                	add    %edx,%eax
 216:	01 c0                	add    %eax,%eax
 218:	89 c2                	mov    %eax,%edx
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	0f b6 00             	movzbl (%eax),%eax
 220:	0f be c0             	movsbl %al,%eax
 223:	01 d0                	add    %edx,%eax
 225:	83 e8 30             	sub    $0x30,%eax
 228:	89 45 fc             	mov    %eax,-0x4(%ebp)
 22b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	0f b6 00             	movzbl (%eax),%eax
 235:	3c 2f                	cmp    $0x2f,%al
 237:	7e 0a                	jle    243 <atoi+0x46>
 239:	8b 45 08             	mov    0x8(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	3c 39                	cmp    $0x39,%al
 241:	7e c9                	jle    20c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 243:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 246:	c9                   	leave  
 247:	c3                   	ret    

00000248 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 248:	55                   	push   %ebp
 249:	89 e5                	mov    %esp,%ebp
 24b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 254:	8b 45 0c             	mov    0xc(%ebp),%eax
 257:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 25a:	eb 13                	jmp    26f <memmove+0x27>
    *dst++ = *src++;
 25c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 25f:	0f b6 10             	movzbl (%eax),%edx
 262:	8b 45 fc             	mov    -0x4(%ebp),%eax
 265:	88 10                	mov    %dl,(%eax)
 267:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 26b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 26f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 273:	0f 9f c0             	setg   %al
 276:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 27a:	84 c0                	test   %al,%al
 27c:	75 de                	jne    25c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 281:	c9                   	leave  
 282:	c3                   	ret    

00000283 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 283:	55                   	push   %ebp
 284:	89 e5                	mov    %esp,%ebp
 286:	83 ec 38             	sub    $0x38,%esp
 289:	8b 45 10             	mov    0x10(%ebp),%eax
 28c:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 28f:	8b 45 14             	mov    0x14(%ebp),%eax
 292:	8b 00                	mov    (%eax),%eax
 294:	89 45 f4             	mov    %eax,-0xc(%ebp)
 297:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 29e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2a2:	74 06                	je     2aa <strtok+0x27>
 2a4:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 2a8:	75 5a                	jne    304 <strtok+0x81>
    return match;
 2aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2ad:	eb 76                	jmp    325 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 2af:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	01 d0                	add    %edx,%eax
 2b7:	0f b6 00             	movzbl (%eax),%eax
 2ba:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 2bd:	74 06                	je     2c5 <strtok+0x42>
      {
	index++;
 2bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2c3:	eb 40                	jmp    305 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 2c5:	8b 45 14             	mov    0x14(%ebp),%eax
 2c8:	8b 00                	mov    (%eax),%eax
 2ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2cd:	29 c2                	sub    %eax,%edx
 2cf:	8b 45 14             	mov    0x14(%ebp),%eax
 2d2:	8b 00                	mov    (%eax),%eax
 2d4:	89 c1                	mov    %eax,%ecx
 2d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d9:	01 c8                	add    %ecx,%eax
 2db:	89 54 24 08          	mov    %edx,0x8(%esp)
 2df:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	89 04 24             	mov    %eax,(%esp)
 2e9:	e8 39 00 00 00       	call   327 <strncpy>
 2ee:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 2f1:	8b 45 08             	mov    0x8(%ebp),%eax
 2f4:	0f b6 00             	movzbl (%eax),%eax
 2f7:	84 c0                	test   %al,%al
 2f9:	74 1b                	je     316 <strtok+0x93>
	  match = 1;
 2fb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 302:	eb 12                	jmp    316 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 304:	90                   	nop
 305:	8b 55 f4             	mov    -0xc(%ebp),%edx
 308:	8b 45 0c             	mov    0xc(%ebp),%eax
 30b:	01 d0                	add    %edx,%eax
 30d:	0f b6 00             	movzbl (%eax),%eax
 310:	84 c0                	test   %al,%al
 312:	75 9b                	jne    2af <strtok+0x2c>
 314:	eb 01                	jmp    317 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 316:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 317:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31a:	8d 50 01             	lea    0x1(%eax),%edx
 31d:	8b 45 14             	mov    0x14(%ebp),%eax
 320:	89 10                	mov    %edx,(%eax)
  return match;
 322:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 325:	c9                   	leave  
 326:	c3                   	ret    

00000327 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 327:	55                   	push   %ebp
 328:	89 e5                	mov    %esp,%ebp
 32a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 32d:	8b 45 08             	mov    0x8(%ebp),%eax
 330:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 333:	90                   	nop
 334:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 338:	0f 9f c0             	setg   %al
 33b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 33f:	84 c0                	test   %al,%al
 341:	74 30                	je     373 <strncpy+0x4c>
 343:	8b 45 0c             	mov    0xc(%ebp),%eax
 346:	0f b6 10             	movzbl (%eax),%edx
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	88 10                	mov    %dl,(%eax)
 34e:	8b 45 08             	mov    0x8(%ebp),%eax
 351:	0f b6 00             	movzbl (%eax),%eax
 354:	84 c0                	test   %al,%al
 356:	0f 95 c0             	setne  %al
 359:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 35d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 361:	84 c0                	test   %al,%al
 363:	75 cf                	jne    334 <strncpy+0xd>
    ;
  while(n-- > 0)
 365:	eb 0c                	jmp    373 <strncpy+0x4c>
    *s++ = 0;
 367:	8b 45 08             	mov    0x8(%ebp),%eax
 36a:	c6 00 00             	movb   $0x0,(%eax)
 36d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 371:	eb 01                	jmp    374 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 373:	90                   	nop
 374:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 378:	0f 9f c0             	setg   %al
 37b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 37f:	84 c0                	test   %al,%al
 381:	75 e4                	jne    367 <strncpy+0x40>
    *s++ = 0;
  return os;
 383:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 386:	c9                   	leave  
 387:	c3                   	ret    

00000388 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 388:	55                   	push   %ebp
 389:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 38b:	eb 0c                	jmp    399 <strncmp+0x11>
    n--, p++, q++;
 38d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 391:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 395:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 399:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 39d:	74 1a                	je     3b9 <strncmp+0x31>
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	0f b6 00             	movzbl (%eax),%eax
 3a5:	84 c0                	test   %al,%al
 3a7:	74 10                	je     3b9 <strncmp+0x31>
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	0f b6 10             	movzbl (%eax),%edx
 3af:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b2:	0f b6 00             	movzbl (%eax),%eax
 3b5:	38 c2                	cmp    %al,%dl
 3b7:	74 d4                	je     38d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 3b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3bd:	75 07                	jne    3c6 <strncmp+0x3e>
    return 0;
 3bf:	b8 00 00 00 00       	mov    $0x0,%eax
 3c4:	eb 18                	jmp    3de <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
 3c9:	0f b6 00             	movzbl (%eax),%eax
 3cc:	0f b6 d0             	movzbl %al,%edx
 3cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d2:	0f b6 00             	movzbl (%eax),%eax
 3d5:	0f b6 c0             	movzbl %al,%eax
 3d8:	89 d1                	mov    %edx,%ecx
 3da:	29 c1                	sub    %eax,%ecx
 3dc:	89 c8                	mov    %ecx,%eax
}
 3de:	5d                   	pop    %ebp
 3df:	c3                   	ret    

000003e0 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
  while(*p){
 3e3:	eb 13                	jmp    3f8 <strcat+0x18>
    *dest++ = *p++;
 3e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e8:	0f b6 10             	movzbl (%eax),%edx
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	88 10                	mov    %dl,(%eax)
 3f0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3f4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 3f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fb:	0f b6 00             	movzbl (%eax),%eax
 3fe:	84 c0                	test   %al,%al
 400:	75 e3                	jne    3e5 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 402:	eb 13                	jmp    417 <strcat+0x37>
    *dest++ = *q++;
 404:	8b 45 10             	mov    0x10(%ebp),%eax
 407:	0f b6 10             	movzbl (%eax),%edx
 40a:	8b 45 08             	mov    0x8(%ebp),%eax
 40d:	88 10                	mov    %dl,(%eax)
 40f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 413:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 417:	8b 45 10             	mov    0x10(%ebp),%eax
 41a:	0f b6 00             	movzbl (%eax),%eax
 41d:	84 c0                	test   %al,%al
 41f:	75 e3                	jne    404 <strcat+0x24>
    *dest++ = *q++;
  }  
 421:	5d                   	pop    %ebp
 422:	c3                   	ret    
 423:	90                   	nop

00000424 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 424:	b8 01 00 00 00       	mov    $0x1,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <exit>:
SYSCALL(exit)
 42c:	b8 02 00 00 00       	mov    $0x2,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <wait>:
SYSCALL(wait)
 434:	b8 03 00 00 00       	mov    $0x3,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <wait2>:
SYSCALL(wait2)
 43c:	b8 16 00 00 00       	mov    $0x16,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <nice>:
SYSCALL(nice)
 444:	b8 17 00 00 00       	mov    $0x17,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <pipe>:
SYSCALL(pipe)
 44c:	b8 04 00 00 00       	mov    $0x4,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <read>:
SYSCALL(read)
 454:	b8 05 00 00 00       	mov    $0x5,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <write>:
SYSCALL(write)
 45c:	b8 10 00 00 00       	mov    $0x10,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <close>:
SYSCALL(close)
 464:	b8 15 00 00 00       	mov    $0x15,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <kill>:
SYSCALL(kill)
 46c:	b8 06 00 00 00       	mov    $0x6,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <exec>:
SYSCALL(exec)
 474:	b8 07 00 00 00       	mov    $0x7,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <open>:
SYSCALL(open)
 47c:	b8 0f 00 00 00       	mov    $0xf,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <mknod>:
SYSCALL(mknod)
 484:	b8 11 00 00 00       	mov    $0x11,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <unlink>:
SYSCALL(unlink)
 48c:	b8 12 00 00 00       	mov    $0x12,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <fstat>:
SYSCALL(fstat)
 494:	b8 08 00 00 00       	mov    $0x8,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <link>:
SYSCALL(link)
 49c:	b8 13 00 00 00       	mov    $0x13,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <mkdir>:
SYSCALL(mkdir)
 4a4:	b8 14 00 00 00       	mov    $0x14,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <chdir>:
SYSCALL(chdir)
 4ac:	b8 09 00 00 00       	mov    $0x9,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <dup>:
SYSCALL(dup)
 4b4:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <getpid>:
SYSCALL(getpid)
 4bc:	b8 0b 00 00 00       	mov    $0xb,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <sbrk>:
SYSCALL(sbrk)
 4c4:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <sleep>:
SYSCALL(sleep)
 4cc:	b8 0d 00 00 00       	mov    $0xd,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <uptime>:
SYSCALL(uptime)
 4d4:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4dc:	55                   	push   %ebp
 4dd:	89 e5                	mov    %esp,%ebp
 4df:	83 ec 28             	sub    $0x28,%esp
 4e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4ef:	00 
 4f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f7:	8b 45 08             	mov    0x8(%ebp),%eax
 4fa:	89 04 24             	mov    %eax,(%esp)
 4fd:	e8 5a ff ff ff       	call   45c <write>
}
 502:	c9                   	leave  
 503:	c3                   	ret    

00000504 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 504:	55                   	push   %ebp
 505:	89 e5                	mov    %esp,%ebp
 507:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 50a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 511:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 515:	74 17                	je     52e <printint+0x2a>
 517:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 51b:	79 11                	jns    52e <printint+0x2a>
    neg = 1;
 51d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 524:	8b 45 0c             	mov    0xc(%ebp),%eax
 527:	f7 d8                	neg    %eax
 529:	89 45 ec             	mov    %eax,-0x14(%ebp)
 52c:	eb 06                	jmp    534 <printint+0x30>
  } else {
    x = xx;
 52e:	8b 45 0c             	mov    0xc(%ebp),%eax
 531:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 534:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 53b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 53e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 541:	ba 00 00 00 00       	mov    $0x0,%edx
 546:	f7 f1                	div    %ecx
 548:	89 d0                	mov    %edx,%eax
 54a:	0f b6 80 4c 0c 00 00 	movzbl 0xc4c(%eax),%eax
 551:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 554:	8b 55 f4             	mov    -0xc(%ebp),%edx
 557:	01 ca                	add    %ecx,%edx
 559:	88 02                	mov    %al,(%edx)
 55b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 55f:	8b 55 10             	mov    0x10(%ebp),%edx
 562:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 565:	8b 45 ec             	mov    -0x14(%ebp),%eax
 568:	ba 00 00 00 00       	mov    $0x0,%edx
 56d:	f7 75 d4             	divl   -0x2c(%ebp)
 570:	89 45 ec             	mov    %eax,-0x14(%ebp)
 573:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 577:	75 c2                	jne    53b <printint+0x37>
  if(neg)
 579:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 57d:	74 2e                	je     5ad <printint+0xa9>
    buf[i++] = '-';
 57f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 582:	8b 45 f4             	mov    -0xc(%ebp),%eax
 585:	01 d0                	add    %edx,%eax
 587:	c6 00 2d             	movb   $0x2d,(%eax)
 58a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 58e:	eb 1d                	jmp    5ad <printint+0xa9>
    putc(fd, buf[i]);
 590:	8d 55 dc             	lea    -0x24(%ebp),%edx
 593:	8b 45 f4             	mov    -0xc(%ebp),%eax
 596:	01 d0                	add    %edx,%eax
 598:	0f b6 00             	movzbl (%eax),%eax
 59b:	0f be c0             	movsbl %al,%eax
 59e:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a2:	8b 45 08             	mov    0x8(%ebp),%eax
 5a5:	89 04 24             	mov    %eax,(%esp)
 5a8:	e8 2f ff ff ff       	call   4dc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5ad:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5b5:	79 d9                	jns    590 <printint+0x8c>
    putc(fd, buf[i]);
}
 5b7:	c9                   	leave  
 5b8:	c3                   	ret    

000005b9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5b9:	55                   	push   %ebp
 5ba:	89 e5                	mov    %esp,%ebp
 5bc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5c6:	8d 45 0c             	lea    0xc(%ebp),%eax
 5c9:	83 c0 04             	add    $0x4,%eax
 5cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5d6:	e9 7d 01 00 00       	jmp    758 <printf+0x19f>
    c = fmt[i] & 0xff;
 5db:	8b 55 0c             	mov    0xc(%ebp),%edx
 5de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e1:	01 d0                	add    %edx,%eax
 5e3:	0f b6 00             	movzbl (%eax),%eax
 5e6:	0f be c0             	movsbl %al,%eax
 5e9:	25 ff 00 00 00       	and    $0xff,%eax
 5ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5f5:	75 2c                	jne    623 <printf+0x6a>
      if(c == '%'){
 5f7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5fb:	75 0c                	jne    609 <printf+0x50>
        state = '%';
 5fd:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 604:	e9 4b 01 00 00       	jmp    754 <printf+0x19b>
      } else {
        putc(fd, c);
 609:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 60c:	0f be c0             	movsbl %al,%eax
 60f:	89 44 24 04          	mov    %eax,0x4(%esp)
 613:	8b 45 08             	mov    0x8(%ebp),%eax
 616:	89 04 24             	mov    %eax,(%esp)
 619:	e8 be fe ff ff       	call   4dc <putc>
 61e:	e9 31 01 00 00       	jmp    754 <printf+0x19b>
      }
    } else if(state == '%'){
 623:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 627:	0f 85 27 01 00 00    	jne    754 <printf+0x19b>
      if(c == 'd'){
 62d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 631:	75 2d                	jne    660 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 633:	8b 45 e8             	mov    -0x18(%ebp),%eax
 636:	8b 00                	mov    (%eax),%eax
 638:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 63f:	00 
 640:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 647:	00 
 648:	89 44 24 04          	mov    %eax,0x4(%esp)
 64c:	8b 45 08             	mov    0x8(%ebp),%eax
 64f:	89 04 24             	mov    %eax,(%esp)
 652:	e8 ad fe ff ff       	call   504 <printint>
        ap++;
 657:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65b:	e9 ed 00 00 00       	jmp    74d <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 660:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 664:	74 06                	je     66c <printf+0xb3>
 666:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 66a:	75 2d                	jne    699 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 66c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66f:	8b 00                	mov    (%eax),%eax
 671:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 678:	00 
 679:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 680:	00 
 681:	89 44 24 04          	mov    %eax,0x4(%esp)
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	89 04 24             	mov    %eax,(%esp)
 68b:	e8 74 fe ff ff       	call   504 <printint>
        ap++;
 690:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 694:	e9 b4 00 00 00       	jmp    74d <printf+0x194>
      } else if(c == 's'){
 699:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 69d:	75 46                	jne    6e5 <printf+0x12c>
        s = (char*)*ap;
 69f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a2:	8b 00                	mov    (%eax),%eax
 6a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6a7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6af:	75 27                	jne    6d8 <printf+0x11f>
          s = "(null)";
 6b1:	c7 45 f4 89 09 00 00 	movl   $0x989,-0xc(%ebp)
        while(*s != 0){
 6b8:	eb 1e                	jmp    6d8 <printf+0x11f>
          putc(fd, *s);
 6ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bd:	0f b6 00             	movzbl (%eax),%eax
 6c0:	0f be c0             	movsbl %al,%eax
 6c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	89 04 24             	mov    %eax,(%esp)
 6cd:	e8 0a fe ff ff       	call   4dc <putc>
          s++;
 6d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6d6:	eb 01                	jmp    6d9 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6d8:	90                   	nop
 6d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6dc:	0f b6 00             	movzbl (%eax),%eax
 6df:	84 c0                	test   %al,%al
 6e1:	75 d7                	jne    6ba <printf+0x101>
 6e3:	eb 68                	jmp    74d <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6e5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6e9:	75 1d                	jne    708 <printf+0x14f>
        putc(fd, *ap);
 6eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ee:	8b 00                	mov    (%eax),%eax
 6f0:	0f be c0             	movsbl %al,%eax
 6f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f7:	8b 45 08             	mov    0x8(%ebp),%eax
 6fa:	89 04 24             	mov    %eax,(%esp)
 6fd:	e8 da fd ff ff       	call   4dc <putc>
        ap++;
 702:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 706:	eb 45                	jmp    74d <printf+0x194>
      } else if(c == '%'){
 708:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 70c:	75 17                	jne    725 <printf+0x16c>
        putc(fd, c);
 70e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 711:	0f be c0             	movsbl %al,%eax
 714:	89 44 24 04          	mov    %eax,0x4(%esp)
 718:	8b 45 08             	mov    0x8(%ebp),%eax
 71b:	89 04 24             	mov    %eax,(%esp)
 71e:	e8 b9 fd ff ff       	call   4dc <putc>
 723:	eb 28                	jmp    74d <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 725:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 72c:	00 
 72d:	8b 45 08             	mov    0x8(%ebp),%eax
 730:	89 04 24             	mov    %eax,(%esp)
 733:	e8 a4 fd ff ff       	call   4dc <putc>
        putc(fd, c);
 738:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73b:	0f be c0             	movsbl %al,%eax
 73e:	89 44 24 04          	mov    %eax,0x4(%esp)
 742:	8b 45 08             	mov    0x8(%ebp),%eax
 745:	89 04 24             	mov    %eax,(%esp)
 748:	e8 8f fd ff ff       	call   4dc <putc>
      }
      state = 0;
 74d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 754:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 758:	8b 55 0c             	mov    0xc(%ebp),%edx
 75b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75e:	01 d0                	add    %edx,%eax
 760:	0f b6 00             	movzbl (%eax),%eax
 763:	84 c0                	test   %al,%al
 765:	0f 85 70 fe ff ff    	jne    5db <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 76b:	c9                   	leave  
 76c:	c3                   	ret    
 76d:	66 90                	xchg   %ax,%ax
 76f:	90                   	nop

00000770 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 770:	55                   	push   %ebp
 771:	89 e5                	mov    %esp,%ebp
 773:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 776:	8b 45 08             	mov    0x8(%ebp),%eax
 779:	83 e8 08             	sub    $0x8,%eax
 77c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77f:	a1 68 0c 00 00       	mov    0xc68,%eax
 784:	89 45 fc             	mov    %eax,-0x4(%ebp)
 787:	eb 24                	jmp    7ad <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 00                	mov    (%eax),%eax
 78e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 791:	77 12                	ja     7a5 <free+0x35>
 793:	8b 45 f8             	mov    -0x8(%ebp),%eax
 796:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 799:	77 24                	ja     7bf <free+0x4f>
 79b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79e:	8b 00                	mov    (%eax),%eax
 7a0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a3:	77 1a                	ja     7bf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	8b 00                	mov    (%eax),%eax
 7aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b3:	76 d4                	jbe    789 <free+0x19>
 7b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7bd:	76 ca                	jbe    789 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c2:	8b 40 04             	mov    0x4(%eax),%eax
 7c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7cf:	01 c2                	add    %eax,%edx
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	39 c2                	cmp    %eax,%edx
 7d8:	75 24                	jne    7fe <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dd:	8b 50 04             	mov    0x4(%eax),%edx
 7e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e3:	8b 00                	mov    (%eax),%eax
 7e5:	8b 40 04             	mov    0x4(%eax),%eax
 7e8:	01 c2                	add    %eax,%edx
 7ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ed:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	8b 00                	mov    (%eax),%eax
 7f5:	8b 10                	mov    (%eax),%edx
 7f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fa:	89 10                	mov    %edx,(%eax)
 7fc:	eb 0a                	jmp    808 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 801:	8b 10                	mov    (%eax),%edx
 803:	8b 45 f8             	mov    -0x8(%ebp),%eax
 806:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 808:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80b:	8b 40 04             	mov    0x4(%eax),%eax
 80e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	01 d0                	add    %edx,%eax
 81a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 81d:	75 20                	jne    83f <free+0xcf>
    p->s.size += bp->s.size;
 81f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 822:	8b 50 04             	mov    0x4(%eax),%edx
 825:	8b 45 f8             	mov    -0x8(%ebp),%eax
 828:	8b 40 04             	mov    0x4(%eax),%eax
 82b:	01 c2                	add    %eax,%edx
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 833:	8b 45 f8             	mov    -0x8(%ebp),%eax
 836:	8b 10                	mov    (%eax),%edx
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	89 10                	mov    %edx,(%eax)
 83d:	eb 08                	jmp    847 <free+0xd7>
  } else
    p->s.ptr = bp;
 83f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 842:	8b 55 f8             	mov    -0x8(%ebp),%edx
 845:	89 10                	mov    %edx,(%eax)
  freep = p;
 847:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84a:	a3 68 0c 00 00       	mov    %eax,0xc68
}
 84f:	c9                   	leave  
 850:	c3                   	ret    

00000851 <morecore>:

static Header*
morecore(uint nu)
{
 851:	55                   	push   %ebp
 852:	89 e5                	mov    %esp,%ebp
 854:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 857:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 85e:	77 07                	ja     867 <morecore+0x16>
    nu = 4096;
 860:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 867:	8b 45 08             	mov    0x8(%ebp),%eax
 86a:	c1 e0 03             	shl    $0x3,%eax
 86d:	89 04 24             	mov    %eax,(%esp)
 870:	e8 4f fc ff ff       	call   4c4 <sbrk>
 875:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 878:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 87c:	75 07                	jne    885 <morecore+0x34>
    return 0;
 87e:	b8 00 00 00 00       	mov    $0x0,%eax
 883:	eb 22                	jmp    8a7 <morecore+0x56>
  hp = (Header*)p;
 885:	8b 45 f4             	mov    -0xc(%ebp),%eax
 888:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 88b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88e:	8b 55 08             	mov    0x8(%ebp),%edx
 891:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 894:	8b 45 f0             	mov    -0x10(%ebp),%eax
 897:	83 c0 08             	add    $0x8,%eax
 89a:	89 04 24             	mov    %eax,(%esp)
 89d:	e8 ce fe ff ff       	call   770 <free>
  return freep;
 8a2:	a1 68 0c 00 00       	mov    0xc68,%eax
}
 8a7:	c9                   	leave  
 8a8:	c3                   	ret    

000008a9 <malloc>:

void*
malloc(uint nbytes)
{
 8a9:	55                   	push   %ebp
 8aa:	89 e5                	mov    %esp,%ebp
 8ac:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8af:	8b 45 08             	mov    0x8(%ebp),%eax
 8b2:	83 c0 07             	add    $0x7,%eax
 8b5:	c1 e8 03             	shr    $0x3,%eax
 8b8:	83 c0 01             	add    $0x1,%eax
 8bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8be:	a1 68 0c 00 00       	mov    0xc68,%eax
 8c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ca:	75 23                	jne    8ef <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8cc:	c7 45 f0 60 0c 00 00 	movl   $0xc60,-0x10(%ebp)
 8d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d6:	a3 68 0c 00 00       	mov    %eax,0xc68
 8db:	a1 68 0c 00 00       	mov    0xc68,%eax
 8e0:	a3 60 0c 00 00       	mov    %eax,0xc60
    base.s.size = 0;
 8e5:	c7 05 64 0c 00 00 00 	movl   $0x0,0xc64
 8ec:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f2:	8b 00                	mov    (%eax),%eax
 8f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fa:	8b 40 04             	mov    0x4(%eax),%eax
 8fd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 900:	72 4d                	jb     94f <malloc+0xa6>
      if(p->s.size == nunits)
 902:	8b 45 f4             	mov    -0xc(%ebp),%eax
 905:	8b 40 04             	mov    0x4(%eax),%eax
 908:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 90b:	75 0c                	jne    919 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 90d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 910:	8b 10                	mov    (%eax),%edx
 912:	8b 45 f0             	mov    -0x10(%ebp),%eax
 915:	89 10                	mov    %edx,(%eax)
 917:	eb 26                	jmp    93f <malloc+0x96>
      else {
        p->s.size -= nunits;
 919:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91c:	8b 40 04             	mov    0x4(%eax),%eax
 91f:	89 c2                	mov    %eax,%edx
 921:	2b 55 ec             	sub    -0x14(%ebp),%edx
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 92a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92d:	8b 40 04             	mov    0x4(%eax),%eax
 930:	c1 e0 03             	shl    $0x3,%eax
 933:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 936:	8b 45 f4             	mov    -0xc(%ebp),%eax
 939:	8b 55 ec             	mov    -0x14(%ebp),%edx
 93c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 93f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 942:	a3 68 0c 00 00       	mov    %eax,0xc68
      return (void*)(p + 1);
 947:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94a:	83 c0 08             	add    $0x8,%eax
 94d:	eb 38                	jmp    987 <malloc+0xde>
    }
    if(p == freep)
 94f:	a1 68 0c 00 00       	mov    0xc68,%eax
 954:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 957:	75 1b                	jne    974 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 959:	8b 45 ec             	mov    -0x14(%ebp),%eax
 95c:	89 04 24             	mov    %eax,(%esp)
 95f:	e8 ed fe ff ff       	call   851 <morecore>
 964:	89 45 f4             	mov    %eax,-0xc(%ebp)
 967:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 96b:	75 07                	jne    974 <malloc+0xcb>
        return 0;
 96d:	b8 00 00 00 00       	mov    $0x0,%eax
 972:	eb 13                	jmp    987 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 974:	8b 45 f4             	mov    -0xc(%ebp),%eax
 977:	89 45 f0             	mov    %eax,-0x10(%ebp)
 97a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97d:	8b 00                	mov    (%eax),%eax
 97f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 982:	e9 70 ff ff ff       	jmp    8f7 <malloc+0x4e>
}
 987:	c9                   	leave  
 988:	c3                   	ret    
