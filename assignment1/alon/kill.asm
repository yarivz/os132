
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 1){
   9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "usage: kill pid...\n");
   f:	c7 44 24 04 cd 09 00 	movl   $0x9cd,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 da 05 00 00       	call   5fd <printf>
    exit();
  23:	e8 48 04 00 00       	call   470 <exit>
  }
  for(i=1; i<argc; i++)
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 27                	jmp    59 <main+0x59>
    kill(atoi(argv[i]));
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 f5 01 00 00       	call   241 <atoi>
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 5c 04 00 00       	call   4b0 <kill>

  if(argc < 1){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  54:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5d:	3b 45 08             	cmp    0x8(%ebp),%eax
  60:	7c d0                	jl     32 <main+0x32>
    kill(atoi(argv[i]));
  exit();
  62:	e8 09 04 00 00       	call   470 <exit>
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
 115:	8b 55 fc             	mov    -0x4(%ebp),%edx
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	01 d0                	add    %edx,%eax
 11d:	0f b6 00             	movzbl (%eax),%eax
 120:	84 c0                	test   %al,%al
 122:	75 ed                	jne    111 <strlen+0xf>
  return n;
 124:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 127:	c9                   	leave  
 128:	c3                   	ret    

00000129 <memset>:

void*
memset(void *dst, int c, uint n)
{
 129:	55                   	push   %ebp
 12a:	89 e5                	mov    %esp,%ebp
 12c:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 12f:	8b 45 10             	mov    0x10(%ebp),%eax
 132:	89 44 24 08          	mov    %eax,0x8(%esp)
 136:	8b 45 0c             	mov    0xc(%ebp),%eax
 139:	89 44 24 04          	mov    %eax,0x4(%esp)
 13d:	8b 45 08             	mov    0x8(%ebp),%eax
 140:	89 04 24             	mov    %eax,(%esp)
 143:	e8 20 ff ff ff       	call   68 <stosb>
  return dst;
 148:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14b:	c9                   	leave  
 14c:	c3                   	ret    

0000014d <strchr>:

char*
strchr(const char *s, char c)
{
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
 150:	83 ec 04             	sub    $0x4,%esp
 153:	8b 45 0c             	mov    0xc(%ebp),%eax
 156:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 159:	eb 14                	jmp    16f <strchr+0x22>
    if(*s == c)
 15b:	8b 45 08             	mov    0x8(%ebp),%eax
 15e:	0f b6 00             	movzbl (%eax),%eax
 161:	3a 45 fc             	cmp    -0x4(%ebp),%al
 164:	75 05                	jne    16b <strchr+0x1e>
      return (char*)s;
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	eb 13                	jmp    17e <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 16b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16f:	8b 45 08             	mov    0x8(%ebp),%eax
 172:	0f b6 00             	movzbl (%eax),%eax
 175:	84 c0                	test   %al,%al
 177:	75 e2                	jne    15b <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 179:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17e:	c9                   	leave  
 17f:	c3                   	ret    

00000180 <gets>:

char*
gets(char *buf, int max)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 18d:	eb 46                	jmp    1d5 <gets+0x55>
    cc = read(0, &c, 1);
 18f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 196:	00 
 197:	8d 45 ef             	lea    -0x11(%ebp),%eax
 19a:	89 44 24 04          	mov    %eax,0x4(%esp)
 19e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1a5:	e8 ee 02 00 00       	call   498 <read>
 1aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b1:	7e 2f                	jle    1e2 <gets+0x62>
      break;
    buf[i++] = c;
 1b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1b6:	8b 45 08             	mov    0x8(%ebp),%eax
 1b9:	01 c2                	add    %eax,%edx
 1bb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1bf:	88 02                	mov    %al,(%edx)
 1c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c9:	3c 0a                	cmp    $0xa,%al
 1cb:	74 16                	je     1e3 <gets+0x63>
 1cd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d1:	3c 0d                	cmp    $0xd,%al
 1d3:	74 0e                	je     1e3 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d8:	83 c0 01             	add    $0x1,%eax
 1db:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1de:	7c af                	jl     18f <gets+0xf>
 1e0:	eb 01                	jmp    1e3 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1e2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	01 d0                	add    %edx,%eax
 1eb:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f1:	c9                   	leave  
 1f2:	c3                   	ret    

000001f3 <stat>:

int
stat(char *n, struct stat *st)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 200:	00 
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	89 04 24             	mov    %eax,(%esp)
 207:	e8 b4 02 00 00       	call   4c0 <open>
 20c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 20f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 213:	79 07                	jns    21c <stat+0x29>
    return -1;
 215:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 21a:	eb 23                	jmp    23f <stat+0x4c>
  r = fstat(fd, st);
 21c:	8b 45 0c             	mov    0xc(%ebp),%eax
 21f:	89 44 24 04          	mov    %eax,0x4(%esp)
 223:	8b 45 f4             	mov    -0xc(%ebp),%eax
 226:	89 04 24             	mov    %eax,(%esp)
 229:	e8 aa 02 00 00       	call   4d8 <fstat>
 22e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 231:	8b 45 f4             	mov    -0xc(%ebp),%eax
 234:	89 04 24             	mov    %eax,(%esp)
 237:	e8 6c 02 00 00       	call   4a8 <close>
  return r;
 23c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 23f:	c9                   	leave  
 240:	c3                   	ret    

00000241 <atoi>:

int
atoi(const char *s)
{
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
 244:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 247:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24e:	eb 23                	jmp    273 <atoi+0x32>
    n = n*10 + *s++ - '0';
 250:	8b 55 fc             	mov    -0x4(%ebp),%edx
 253:	89 d0                	mov    %edx,%eax
 255:	c1 e0 02             	shl    $0x2,%eax
 258:	01 d0                	add    %edx,%eax
 25a:	01 c0                	add    %eax,%eax
 25c:	89 c2                	mov    %eax,%edx
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	0f b6 00             	movzbl (%eax),%eax
 264:	0f be c0             	movsbl %al,%eax
 267:	01 d0                	add    %edx,%eax
 269:	83 e8 30             	sub    $0x30,%eax
 26c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 26f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	0f b6 00             	movzbl (%eax),%eax
 279:	3c 2f                	cmp    $0x2f,%al
 27b:	7e 0a                	jle    287 <atoi+0x46>
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	0f b6 00             	movzbl (%eax),%eax
 283:	3c 39                	cmp    $0x39,%al
 285:	7e c9                	jle    250 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 287:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28a:	c9                   	leave  
 28b:	c3                   	ret    

0000028c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 28c:	55                   	push   %ebp
 28d:	89 e5                	mov    %esp,%ebp
 28f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 298:	8b 45 0c             	mov    0xc(%ebp),%eax
 29b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 29e:	eb 13                	jmp    2b3 <memmove+0x27>
    *dst++ = *src++;
 2a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2a3:	0f b6 10             	movzbl (%eax),%edx
 2a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a9:	88 10                	mov    %dl,(%eax)
 2ab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2af:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2b7:	0f 9f c0             	setg   %al
 2ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2be:	84 c0                	test   %al,%al
 2c0:	75 de                	jne    2a0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	83 ec 38             	sub    $0x38,%esp
 2cd:	8b 45 10             	mov    0x10(%ebp),%eax
 2d0:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 2d3:	8b 45 14             	mov    0x14(%ebp),%eax
 2d6:	8b 00                	mov    (%eax),%eax
 2d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 2e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2e6:	74 06                	je     2ee <strtok+0x27>
 2e8:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 2ec:	75 5a                	jne    348 <strtok+0x81>
    return match;
 2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2f1:	eb 76                	jmp    369 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 2f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f9:	01 d0                	add    %edx,%eax
 2fb:	0f b6 00             	movzbl (%eax),%eax
 2fe:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 301:	74 06                	je     309 <strtok+0x42>
      {
	index++;
 303:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 307:	eb 40                	jmp    349 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 309:	8b 45 14             	mov    0x14(%ebp),%eax
 30c:	8b 00                	mov    (%eax),%eax
 30e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 311:	29 c2                	sub    %eax,%edx
 313:	8b 45 14             	mov    0x14(%ebp),%eax
 316:	8b 00                	mov    (%eax),%eax
 318:	89 c1                	mov    %eax,%ecx
 31a:	8b 45 0c             	mov    0xc(%ebp),%eax
 31d:	01 c8                	add    %ecx,%eax
 31f:	89 54 24 08          	mov    %edx,0x8(%esp)
 323:	89 44 24 04          	mov    %eax,0x4(%esp)
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	89 04 24             	mov    %eax,(%esp)
 32d:	e8 39 00 00 00       	call   36b <strncpy>
 332:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 335:	8b 45 08             	mov    0x8(%ebp),%eax
 338:	0f b6 00             	movzbl (%eax),%eax
 33b:	84 c0                	test   %al,%al
 33d:	74 1b                	je     35a <strtok+0x93>
	  match = 1;
 33f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 346:	eb 12                	jmp    35a <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 348:	90                   	nop
 349:	8b 55 f4             	mov    -0xc(%ebp),%edx
 34c:	8b 45 0c             	mov    0xc(%ebp),%eax
 34f:	01 d0                	add    %edx,%eax
 351:	0f b6 00             	movzbl (%eax),%eax
 354:	84 c0                	test   %al,%al
 356:	75 9b                	jne    2f3 <strtok+0x2c>
 358:	eb 01                	jmp    35b <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 35a:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 35b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 35e:	8d 50 01             	lea    0x1(%eax),%edx
 361:	8b 45 14             	mov    0x14(%ebp),%eax
 364:	89 10                	mov    %edx,(%eax)
  return match;
 366:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 369:	c9                   	leave  
 36a:	c3                   	ret    

0000036b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 36b:	55                   	push   %ebp
 36c:	89 e5                	mov    %esp,%ebp
 36e:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 371:	8b 45 08             	mov    0x8(%ebp),%eax
 374:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 377:	90                   	nop
 378:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 37c:	0f 9f c0             	setg   %al
 37f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 383:	84 c0                	test   %al,%al
 385:	74 30                	je     3b7 <strncpy+0x4c>
 387:	8b 45 0c             	mov    0xc(%ebp),%eax
 38a:	0f b6 10             	movzbl (%eax),%edx
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	88 10                	mov    %dl,(%eax)
 392:	8b 45 08             	mov    0x8(%ebp),%eax
 395:	0f b6 00             	movzbl (%eax),%eax
 398:	84 c0                	test   %al,%al
 39a:	0f 95 c0             	setne  %al
 39d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3a5:	84 c0                	test   %al,%al
 3a7:	75 cf                	jne    378 <strncpy+0xd>
    ;
  while(n-- > 0)
 3a9:	eb 0c                	jmp    3b7 <strncpy+0x4c>
    *s++ = 0;
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	c6 00 00             	movb   $0x0,(%eax)
 3b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b5:	eb 01                	jmp    3b8 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3b7:	90                   	nop
 3b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3bc:	0f 9f c0             	setg   %al
 3bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3c3:	84 c0                	test   %al,%al
 3c5:	75 e4                	jne    3ab <strncpy+0x40>
    *s++ = 0;
  return os;
 3c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ca:	c9                   	leave  
 3cb:	c3                   	ret    

000003cc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3cc:	55                   	push   %ebp
 3cd:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 3cf:	eb 0c                	jmp    3dd <strncmp+0x11>
    n--, p++, q++;
 3d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3d9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 3dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3e1:	74 1a                	je     3fd <strncmp+0x31>
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
 3e6:	0f b6 00             	movzbl (%eax),%eax
 3e9:	84 c0                	test   %al,%al
 3eb:	74 10                	je     3fd <strncmp+0x31>
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	0f b6 10             	movzbl (%eax),%edx
 3f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f6:	0f b6 00             	movzbl (%eax),%eax
 3f9:	38 c2                	cmp    %al,%dl
 3fb:	74 d4                	je     3d1 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 3fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 401:	75 07                	jne    40a <strncmp+0x3e>
    return 0;
 403:	b8 00 00 00 00       	mov    $0x0,%eax
 408:	eb 18                	jmp    422 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 40a:	8b 45 08             	mov    0x8(%ebp),%eax
 40d:	0f b6 00             	movzbl (%eax),%eax
 410:	0f b6 d0             	movzbl %al,%edx
 413:	8b 45 0c             	mov    0xc(%ebp),%eax
 416:	0f b6 00             	movzbl (%eax),%eax
 419:	0f b6 c0             	movzbl %al,%eax
 41c:	89 d1                	mov    %edx,%ecx
 41e:	29 c1                	sub    %eax,%ecx
 420:	89 c8                	mov    %ecx,%eax
}
 422:	5d                   	pop    %ebp
 423:	c3                   	ret    

00000424 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
  while(*p){
 427:	eb 13                	jmp    43c <strcat+0x18>
    *dest++ = *p++;
 429:	8b 45 0c             	mov    0xc(%ebp),%eax
 42c:	0f b6 10             	movzbl (%eax),%edx
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	88 10                	mov    %dl,(%eax)
 434:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 438:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 43c:	8b 45 0c             	mov    0xc(%ebp),%eax
 43f:	0f b6 00             	movzbl (%eax),%eax
 442:	84 c0                	test   %al,%al
 444:	75 e3                	jne    429 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 446:	eb 13                	jmp    45b <strcat+0x37>
    *dest++ = *q++;
 448:	8b 45 10             	mov    0x10(%ebp),%eax
 44b:	0f b6 10             	movzbl (%eax),%edx
 44e:	8b 45 08             	mov    0x8(%ebp),%eax
 451:	88 10                	mov    %dl,(%eax)
 453:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 457:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 45b:	8b 45 10             	mov    0x10(%ebp),%eax
 45e:	0f b6 00             	movzbl (%eax),%eax
 461:	84 c0                	test   %al,%al
 463:	75 e3                	jne    448 <strcat+0x24>
    *dest++ = *q++;
  }  
 465:	5d                   	pop    %ebp
 466:	c3                   	ret    
 467:	90                   	nop

00000468 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 468:	b8 01 00 00 00       	mov    $0x1,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <exit>:
SYSCALL(exit)
 470:	b8 02 00 00 00       	mov    $0x2,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <wait>:
SYSCALL(wait)
 478:	b8 03 00 00 00       	mov    $0x3,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <wait2>:
SYSCALL(wait2)
 480:	b8 16 00 00 00       	mov    $0x16,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <nice>:
SYSCALL(nice)
 488:	b8 17 00 00 00       	mov    $0x17,%eax
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
 58e:	0f b6 80 a4 0c 00 00 	movzbl 0xca4(%eax),%eax
 595:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 598:	8b 55 f4             	mov    -0xc(%ebp),%edx
 59b:	01 ca                	add    %ecx,%edx
 59d:	88 02                	mov    %al,(%edx)
 59f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5a3:	8b 55 10             	mov    0x10(%ebp),%edx
 5a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ac:	ba 00 00 00 00       	mov    $0x0,%edx
 5b1:	f7 75 d4             	divl   -0x2c(%ebp)
 5b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5bb:	75 c2                	jne    57f <printint+0x37>
  if(neg)
 5bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c1:	74 2e                	je     5f1 <printint+0xa9>
    buf[i++] = '-';
 5c3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c9:	01 d0                	add    %edx,%eax
 5cb:	c6 00 2d             	movb   $0x2d,(%eax)
 5ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5d2:	eb 1d                	jmp    5f1 <printint+0xa9>
    putc(fd, buf[i]);
 5d4:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5da:	01 d0                	add    %edx,%eax
 5dc:	0f b6 00             	movzbl (%eax),%eax
 5df:	0f be c0             	movsbl %al,%eax
 5e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e6:	8b 45 08             	mov    0x8(%ebp),%eax
 5e9:	89 04 24             	mov    %eax,(%esp)
 5ec:	e8 2f ff ff ff       	call   520 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5f1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f9:	79 d9                	jns    5d4 <printint+0x8c>
    putc(fd, buf[i]);
}
 5fb:	c9                   	leave  
 5fc:	c3                   	ret    

000005fd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5fd:	55                   	push   %ebp
 5fe:	89 e5                	mov    %esp,%ebp
 600:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 603:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 60a:	8d 45 0c             	lea    0xc(%ebp),%eax
 60d:	83 c0 04             	add    $0x4,%eax
 610:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 613:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 61a:	e9 7d 01 00 00       	jmp    79c <printf+0x19f>
    c = fmt[i] & 0xff;
 61f:	8b 55 0c             	mov    0xc(%ebp),%edx
 622:	8b 45 f0             	mov    -0x10(%ebp),%eax
 625:	01 d0                	add    %edx,%eax
 627:	0f b6 00             	movzbl (%eax),%eax
 62a:	0f be c0             	movsbl %al,%eax
 62d:	25 ff 00 00 00       	and    $0xff,%eax
 632:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 635:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 639:	75 2c                	jne    667 <printf+0x6a>
      if(c == '%'){
 63b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 63f:	75 0c                	jne    64d <printf+0x50>
        state = '%';
 641:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 648:	e9 4b 01 00 00       	jmp    798 <printf+0x19b>
      } else {
        putc(fd, c);
 64d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 650:	0f be c0             	movsbl %al,%eax
 653:	89 44 24 04          	mov    %eax,0x4(%esp)
 657:	8b 45 08             	mov    0x8(%ebp),%eax
 65a:	89 04 24             	mov    %eax,(%esp)
 65d:	e8 be fe ff ff       	call   520 <putc>
 662:	e9 31 01 00 00       	jmp    798 <printf+0x19b>
      }
    } else if(state == '%'){
 667:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 66b:	0f 85 27 01 00 00    	jne    798 <printf+0x19b>
      if(c == 'd'){
 671:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 675:	75 2d                	jne    6a4 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 677:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67a:	8b 00                	mov    (%eax),%eax
 67c:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 683:	00 
 684:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 68b:	00 
 68c:	89 44 24 04          	mov    %eax,0x4(%esp)
 690:	8b 45 08             	mov    0x8(%ebp),%eax
 693:	89 04 24             	mov    %eax,(%esp)
 696:	e8 ad fe ff ff       	call   548 <printint>
        ap++;
 69b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69f:	e9 ed 00 00 00       	jmp    791 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6a4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6a8:	74 06                	je     6b0 <printf+0xb3>
 6aa:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6ae:	75 2d                	jne    6dd <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b3:	8b 00                	mov    (%eax),%eax
 6b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6bc:	00 
 6bd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6c4:	00 
 6c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c9:	8b 45 08             	mov    0x8(%ebp),%eax
 6cc:	89 04 24             	mov    %eax,(%esp)
 6cf:	e8 74 fe ff ff       	call   548 <printint>
        ap++;
 6d4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d8:	e9 b4 00 00 00       	jmp    791 <printf+0x194>
      } else if(c == 's'){
 6dd:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e1:	75 46                	jne    729 <printf+0x12c>
        s = (char*)*ap;
 6e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e6:	8b 00                	mov    (%eax),%eax
 6e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f3:	75 27                	jne    71c <printf+0x11f>
          s = "(null)";
 6f5:	c7 45 f4 e1 09 00 00 	movl   $0x9e1,-0xc(%ebp)
        while(*s != 0){
 6fc:	eb 1e                	jmp    71c <printf+0x11f>
          putc(fd, *s);
 6fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 701:	0f b6 00             	movzbl (%eax),%eax
 704:	0f be c0             	movsbl %al,%eax
 707:	89 44 24 04          	mov    %eax,0x4(%esp)
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	89 04 24             	mov    %eax,(%esp)
 711:	e8 0a fe ff ff       	call   520 <putc>
          s++;
 716:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 71a:	eb 01                	jmp    71d <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 71c:	90                   	nop
 71d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 720:	0f b6 00             	movzbl (%eax),%eax
 723:	84 c0                	test   %al,%al
 725:	75 d7                	jne    6fe <printf+0x101>
 727:	eb 68                	jmp    791 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 729:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 72d:	75 1d                	jne    74c <printf+0x14f>
        putc(fd, *ap);
 72f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 732:	8b 00                	mov    (%eax),%eax
 734:	0f be c0             	movsbl %al,%eax
 737:	89 44 24 04          	mov    %eax,0x4(%esp)
 73b:	8b 45 08             	mov    0x8(%ebp),%eax
 73e:	89 04 24             	mov    %eax,(%esp)
 741:	e8 da fd ff ff       	call   520 <putc>
        ap++;
 746:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74a:	eb 45                	jmp    791 <printf+0x194>
      } else if(c == '%'){
 74c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 750:	75 17                	jne    769 <printf+0x16c>
        putc(fd, c);
 752:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 755:	0f be c0             	movsbl %al,%eax
 758:	89 44 24 04          	mov    %eax,0x4(%esp)
 75c:	8b 45 08             	mov    0x8(%ebp),%eax
 75f:	89 04 24             	mov    %eax,(%esp)
 762:	e8 b9 fd ff ff       	call   520 <putc>
 767:	eb 28                	jmp    791 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 769:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 770:	00 
 771:	8b 45 08             	mov    0x8(%ebp),%eax
 774:	89 04 24             	mov    %eax,(%esp)
 777:	e8 a4 fd ff ff       	call   520 <putc>
        putc(fd, c);
 77c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77f:	0f be c0             	movsbl %al,%eax
 782:	89 44 24 04          	mov    %eax,0x4(%esp)
 786:	8b 45 08             	mov    0x8(%ebp),%eax
 789:	89 04 24             	mov    %eax,(%esp)
 78c:	e8 8f fd ff ff       	call   520 <putc>
      }
      state = 0;
 791:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 798:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 79c:	8b 55 0c             	mov    0xc(%ebp),%edx
 79f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a2:	01 d0                	add    %edx,%eax
 7a4:	0f b6 00             	movzbl (%eax),%eax
 7a7:	84 c0                	test   %al,%al
 7a9:	0f 85 70 fe ff ff    	jne    61f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7af:	c9                   	leave  
 7b0:	c3                   	ret    
 7b1:	66 90                	xchg   %ax,%ax
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
 7c3:	a1 c0 0c 00 00       	mov    0xcc0,%eax
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
 809:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 810:	8b 45 f8             	mov    -0x8(%ebp),%eax
 813:	01 c2                	add    %eax,%edx
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	8b 00                	mov    (%eax),%eax
 81a:	39 c2                	cmp    %eax,%edx
 81c:	75 24                	jne    842 <free+0x8e>
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
 840:	eb 0a                	jmp    84c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 842:	8b 45 fc             	mov    -0x4(%ebp),%eax
 845:	8b 10                	mov    (%eax),%edx
 847:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 84c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84f:	8b 40 04             	mov    0x4(%eax),%eax
 852:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	01 d0                	add    %edx,%eax
 85e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 861:	75 20                	jne    883 <free+0xcf>
    p->s.size += bp->s.size;
 863:	8b 45 fc             	mov    -0x4(%ebp),%eax
 866:	8b 50 04             	mov    0x4(%eax),%edx
 869:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86c:	8b 40 04             	mov    0x4(%eax),%eax
 86f:	01 c2                	add    %eax,%edx
 871:	8b 45 fc             	mov    -0x4(%ebp),%eax
 874:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 877:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87a:	8b 10                	mov    (%eax),%edx
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	89 10                	mov    %edx,(%eax)
 881:	eb 08                	jmp    88b <free+0xd7>
  } else
    p->s.ptr = bp;
 883:	8b 45 fc             	mov    -0x4(%ebp),%eax
 886:	8b 55 f8             	mov    -0x8(%ebp),%edx
 889:	89 10                	mov    %edx,(%eax)
  freep = p;
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	a3 c0 0c 00 00       	mov    %eax,0xcc0
}
 893:	c9                   	leave  
 894:	c3                   	ret    

00000895 <morecore>:

static Header*
morecore(uint nu)
{
 895:	55                   	push   %ebp
 896:	89 e5                	mov    %esp,%ebp
 898:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 89b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a2:	77 07                	ja     8ab <morecore+0x16>
    nu = 4096;
 8a4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ab:	8b 45 08             	mov    0x8(%ebp),%eax
 8ae:	c1 e0 03             	shl    $0x3,%eax
 8b1:	89 04 24             	mov    %eax,(%esp)
 8b4:	e8 4f fc ff ff       	call   508 <sbrk>
 8b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8bc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c0:	75 07                	jne    8c9 <morecore+0x34>
    return 0;
 8c2:	b8 00 00 00 00       	mov    $0x0,%eax
 8c7:	eb 22                	jmp    8eb <morecore+0x56>
  hp = (Header*)p;
 8c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d2:	8b 55 08             	mov    0x8(%ebp),%edx
 8d5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8db:	83 c0 08             	add    $0x8,%eax
 8de:	89 04 24             	mov    %eax,(%esp)
 8e1:	e8 ce fe ff ff       	call   7b4 <free>
  return freep;
 8e6:	a1 c0 0c 00 00       	mov    0xcc0,%eax
}
 8eb:	c9                   	leave  
 8ec:	c3                   	ret    

000008ed <malloc>:

void*
malloc(uint nbytes)
{
 8ed:	55                   	push   %ebp
 8ee:	89 e5                	mov    %esp,%ebp
 8f0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f3:	8b 45 08             	mov    0x8(%ebp),%eax
 8f6:	83 c0 07             	add    $0x7,%eax
 8f9:	c1 e8 03             	shr    $0x3,%eax
 8fc:	83 c0 01             	add    $0x1,%eax
 8ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 902:	a1 c0 0c 00 00       	mov    0xcc0,%eax
 907:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 90e:	75 23                	jne    933 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 910:	c7 45 f0 b8 0c 00 00 	movl   $0xcb8,-0x10(%ebp)
 917:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91a:	a3 c0 0c 00 00       	mov    %eax,0xcc0
 91f:	a1 c0 0c 00 00       	mov    0xcc0,%eax
 924:	a3 b8 0c 00 00       	mov    %eax,0xcb8
    base.s.size = 0;
 929:	c7 05 bc 0c 00 00 00 	movl   $0x0,0xcbc
 930:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 933:	8b 45 f0             	mov    -0x10(%ebp),%eax
 936:	8b 00                	mov    (%eax),%eax
 938:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93e:	8b 40 04             	mov    0x4(%eax),%eax
 941:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 944:	72 4d                	jb     993 <malloc+0xa6>
      if(p->s.size == nunits)
 946:	8b 45 f4             	mov    -0xc(%ebp),%eax
 949:	8b 40 04             	mov    0x4(%eax),%eax
 94c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 94f:	75 0c                	jne    95d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 951:	8b 45 f4             	mov    -0xc(%ebp),%eax
 954:	8b 10                	mov    (%eax),%edx
 956:	8b 45 f0             	mov    -0x10(%ebp),%eax
 959:	89 10                	mov    %edx,(%eax)
 95b:	eb 26                	jmp    983 <malloc+0x96>
      else {
        p->s.size -= nunits;
 95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 960:	8b 40 04             	mov    0x4(%eax),%eax
 963:	89 c2                	mov    %eax,%edx
 965:	2b 55 ec             	sub    -0x14(%ebp),%edx
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 96e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 971:	8b 40 04             	mov    0x4(%eax),%eax
 974:	c1 e0 03             	shl    $0x3,%eax
 977:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 980:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 983:	8b 45 f0             	mov    -0x10(%ebp),%eax
 986:	a3 c0 0c 00 00       	mov    %eax,0xcc0
      return (void*)(p + 1);
 98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98e:	83 c0 08             	add    $0x8,%eax
 991:	eb 38                	jmp    9cb <malloc+0xde>
    }
    if(p == freep)
 993:	a1 c0 0c 00 00       	mov    0xcc0,%eax
 998:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99b:	75 1b                	jne    9b8 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 99d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9a0:	89 04 24             	mov    %eax,(%esp)
 9a3:	e8 ed fe ff ff       	call   895 <morecore>
 9a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9af:	75 07                	jne    9b8 <malloc+0xcb>
        return 0;
 9b1:	b8 00 00 00 00       	mov    $0x0,%eax
 9b6:	eb 13                	jmp    9cb <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c1:	8b 00                	mov    (%eax),%eax
 9c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9c6:	e9 70 ff ff ff       	jmp    93b <malloc+0x4e>
}
 9cb:	c9                   	leave  
 9cc:	c3                   	ret    
