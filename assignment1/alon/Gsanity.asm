
_Gsanity:     file format elf32-i386


Disassembly of section .text:

00000000 <foo>:
}
*/

void
foo()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int i;
  int pid = getpid();
   6:	e8 49 05 00 00       	call   554 <getpid>
   b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (i=0;i<50;i++)
   e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  15:	eb 29                	jmp    40 <foo+0x40>
     printf(2, "process %d is printing for the %d time\n",pid,i+1);
  17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1a:	83 c0 01             	add    $0x1,%eax
  1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  24:	89 44 24 08          	mov    %eax,0x8(%esp)
  28:	c7 44 24 04 24 0a 00 	movl   $0xa24,0x4(%esp)
  2f:	00 
  30:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  37:	e8 15 06 00 00       	call   651 <printf>
void
foo()
{
  int i;
  int pid = getpid();
  for (i=0;i<50;i++)
  3c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  40:	83 7d f4 31          	cmpl   $0x31,-0xc(%ebp)
  44:	7e d1                	jle    17 <foo+0x17>
     printf(2, "process %d is printing for the %d time\n",pid,i+1);
}
  46:	c9                   	leave  
  47:	c3                   	ret    

00000048 <Gsanity>:

void
Gsanity(void)
{
  48:	55                   	push   %ebp
  49:	89 e5                	mov    %esp,%ebp
  4b:	83 ec 18             	sub    $0x18,%esp
  printf(1, "Gsanity test\n");
  4e:	c7 44 24 04 4c 0a 00 	movl   $0xa4c,0x4(%esp)
  55:	00 
  56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5d:	e8 ef 05 00 00       	call   651 <printf>
  printf(1, "Father pid is %d\n",getpid());
  62:	e8 ed 04 00 00       	call   554 <getpid>
  67:	89 44 24 08          	mov    %eax,0x8(%esp)
  6b:	c7 44 24 04 5a 0a 00 	movl   $0xa5a,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 d2 05 00 00       	call   651 <printf>
  sleep(1000);
  7f:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
  86:	e8 d9 04 00 00       	call   564 <sleep>

  if(fork() == 0)
  8b:	e8 2c 04 00 00       	call   4bc <fork>
  90:	85 c0                	test   %eax,%eax
  92:	75 0a                	jne    9e <Gsanity+0x56>
  {
    foo();
  94:	e8 67 ff ff ff       	call   0 <foo>
    exit();      
  99:	e8 26 04 00 00       	call   4c4 <exit>
  }
  foo();
  9e:	e8 5d ff ff ff       	call   0 <foo>
  wait();
  a3:	e8 24 04 00 00       	call   4cc <wait>
}
  a8:	c9                   	leave  
  a9:	c3                   	ret    

000000aa <main>:
int
main(void)
{
  aa:	55                   	push   %ebp
  ab:	89 e5                	mov    %esp,%ebp
  ad:	83 e4 f0             	and    $0xfffffff0,%esp
  Gsanity();
  b0:	e8 93 ff ff ff       	call   48 <Gsanity>
  exit();
  b5:	e8 0a 04 00 00       	call   4c4 <exit>
  ba:	66 90                	xchg   %ax,%ax

000000bc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  bc:	55                   	push   %ebp
  bd:	89 e5                	mov    %esp,%ebp
  bf:	57                   	push   %edi
  c0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  c4:	8b 55 10             	mov    0x10(%ebp),%edx
  c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  ca:	89 cb                	mov    %ecx,%ebx
  cc:	89 df                	mov    %ebx,%edi
  ce:	89 d1                	mov    %edx,%ecx
  d0:	fc                   	cld    
  d1:	f3 aa                	rep stos %al,%es:(%edi)
  d3:	89 ca                	mov    %ecx,%edx
  d5:	89 fb                	mov    %edi,%ebx
  d7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  da:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  dd:	5b                   	pop    %ebx
  de:	5f                   	pop    %edi
  df:	5d                   	pop    %ebp
  e0:	c3                   	ret    

000000e1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  e1:	55                   	push   %ebp
  e2:	89 e5                	mov    %esp,%ebp
  e4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  e7:	8b 45 08             	mov    0x8(%ebp),%eax
  ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ed:	90                   	nop
  ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  f1:	0f b6 10             	movzbl (%eax),%edx
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	88 10                	mov    %dl,(%eax)
  f9:	8b 45 08             	mov    0x8(%ebp),%eax
  fc:	0f b6 00             	movzbl (%eax),%eax
  ff:	84 c0                	test   %al,%al
 101:	0f 95 c0             	setne  %al
 104:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 108:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 10c:	84 c0                	test   %al,%al
 10e:	75 de                	jne    ee <strcpy+0xd>
    ;
  return os;
 110:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 113:	c9                   	leave  
 114:	c3                   	ret    

00000115 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 115:	55                   	push   %ebp
 116:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 118:	eb 08                	jmp    122 <strcmp+0xd>
    p++, q++;
 11a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 11e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 122:	8b 45 08             	mov    0x8(%ebp),%eax
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	84 c0                	test   %al,%al
 12a:	74 10                	je     13c <strcmp+0x27>
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	0f b6 10             	movzbl (%eax),%edx
 132:	8b 45 0c             	mov    0xc(%ebp),%eax
 135:	0f b6 00             	movzbl (%eax),%eax
 138:	38 c2                	cmp    %al,%dl
 13a:	74 de                	je     11a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 13c:	8b 45 08             	mov    0x8(%ebp),%eax
 13f:	0f b6 00             	movzbl (%eax),%eax
 142:	0f b6 d0             	movzbl %al,%edx
 145:	8b 45 0c             	mov    0xc(%ebp),%eax
 148:	0f b6 00             	movzbl (%eax),%eax
 14b:	0f b6 c0             	movzbl %al,%eax
 14e:	89 d1                	mov    %edx,%ecx
 150:	29 c1                	sub    %eax,%ecx
 152:	89 c8                	mov    %ecx,%eax
}
 154:	5d                   	pop    %ebp
 155:	c3                   	ret    

00000156 <strlen>:

uint
strlen(char *s)
{
 156:	55                   	push   %ebp
 157:	89 e5                	mov    %esp,%ebp
 159:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 15c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 163:	eb 04                	jmp    169 <strlen+0x13>
 165:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 169:	8b 55 fc             	mov    -0x4(%ebp),%edx
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	01 d0                	add    %edx,%eax
 171:	0f b6 00             	movzbl (%eax),%eax
 174:	84 c0                	test   %al,%al
 176:	75 ed                	jne    165 <strlen+0xf>
  return n;
 178:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 17b:	c9                   	leave  
 17c:	c3                   	ret    

0000017d <memset>:

void*
memset(void *dst, int c, uint n)
{
 17d:	55                   	push   %ebp
 17e:	89 e5                	mov    %esp,%ebp
 180:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 183:	8b 45 10             	mov    0x10(%ebp),%eax
 186:	89 44 24 08          	mov    %eax,0x8(%esp)
 18a:	8b 45 0c             	mov    0xc(%ebp),%eax
 18d:	89 44 24 04          	mov    %eax,0x4(%esp)
 191:	8b 45 08             	mov    0x8(%ebp),%eax
 194:	89 04 24             	mov    %eax,(%esp)
 197:	e8 20 ff ff ff       	call   bc <stosb>
  return dst;
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 19f:	c9                   	leave  
 1a0:	c3                   	ret    

000001a1 <strchr>:

char*
strchr(const char *s, char c)
{
 1a1:	55                   	push   %ebp
 1a2:	89 e5                	mov    %esp,%ebp
 1a4:	83 ec 04             	sub    $0x4,%esp
 1a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1aa:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1ad:	eb 14                	jmp    1c3 <strchr+0x22>
    if(*s == c)
 1af:	8b 45 08             	mov    0x8(%ebp),%eax
 1b2:	0f b6 00             	movzbl (%eax),%eax
 1b5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1b8:	75 05                	jne    1bf <strchr+0x1e>
      return (char*)s;
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	eb 13                	jmp    1d2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1c3:	8b 45 08             	mov    0x8(%ebp),%eax
 1c6:	0f b6 00             	movzbl (%eax),%eax
 1c9:	84 c0                	test   %al,%al
 1cb:	75 e2                	jne    1af <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d2:	c9                   	leave  
 1d3:	c3                   	ret    

000001d4 <gets>:

char*
gets(char *buf, int max)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1e1:	eb 46                	jmp    229 <gets+0x55>
    cc = read(0, &c, 1);
 1e3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1ea:	00 
 1eb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1f9:	e8 ee 02 00 00       	call   4ec <read>
 1fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 201:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 205:	7e 2f                	jle    236 <gets+0x62>
      break;
    buf[i++] = c;
 207:	8b 55 f4             	mov    -0xc(%ebp),%edx
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	01 c2                	add    %eax,%edx
 20f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 213:	88 02                	mov    %al,(%edx)
 215:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 219:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 21d:	3c 0a                	cmp    $0xa,%al
 21f:	74 16                	je     237 <gets+0x63>
 221:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 225:	3c 0d                	cmp    $0xd,%al
 227:	74 0e                	je     237 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 229:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22c:	83 c0 01             	add    $0x1,%eax
 22f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 232:	7c af                	jl     1e3 <gets+0xf>
 234:	eb 01                	jmp    237 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 236:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 237:	8b 55 f4             	mov    -0xc(%ebp),%edx
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	01 d0                	add    %edx,%eax
 23f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 242:	8b 45 08             	mov    0x8(%ebp),%eax
}
 245:	c9                   	leave  
 246:	c3                   	ret    

00000247 <stat>:

int
stat(char *n, struct stat *st)
{
 247:	55                   	push   %ebp
 248:	89 e5                	mov    %esp,%ebp
 24a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 254:	00 
 255:	8b 45 08             	mov    0x8(%ebp),%eax
 258:	89 04 24             	mov    %eax,(%esp)
 25b:	e8 b4 02 00 00       	call   514 <open>
 260:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 263:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 267:	79 07                	jns    270 <stat+0x29>
    return -1;
 269:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 26e:	eb 23                	jmp    293 <stat+0x4c>
  r = fstat(fd, st);
 270:	8b 45 0c             	mov    0xc(%ebp),%eax
 273:	89 44 24 04          	mov    %eax,0x4(%esp)
 277:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27a:	89 04 24             	mov    %eax,(%esp)
 27d:	e8 aa 02 00 00       	call   52c <fstat>
 282:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 285:	8b 45 f4             	mov    -0xc(%ebp),%eax
 288:	89 04 24             	mov    %eax,(%esp)
 28b:	e8 6c 02 00 00       	call   4fc <close>
  return r;
 290:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <atoi>:

int
atoi(const char *s)
{
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 29b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2a2:	eb 23                	jmp    2c7 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2a4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2a7:	89 d0                	mov    %edx,%eax
 2a9:	c1 e0 02             	shl    $0x2,%eax
 2ac:	01 d0                	add    %edx,%eax
 2ae:	01 c0                	add    %eax,%eax
 2b0:	89 c2                	mov    %eax,%edx
 2b2:	8b 45 08             	mov    0x8(%ebp),%eax
 2b5:	0f b6 00             	movzbl (%eax),%eax
 2b8:	0f be c0             	movsbl %al,%eax
 2bb:	01 d0                	add    %edx,%eax
 2bd:	83 e8 30             	sub    $0x30,%eax
 2c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 2c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ca:	0f b6 00             	movzbl (%eax),%eax
 2cd:	3c 2f                	cmp    $0x2f,%al
 2cf:	7e 0a                	jle    2db <atoi+0x46>
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
 2d4:	0f b6 00             	movzbl (%eax),%eax
 2d7:	3c 39                	cmp    $0x39,%al
 2d9:	7e c9                	jle    2a4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2de:	c9                   	leave  
 2df:	c3                   	ret    

000002e0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2e6:	8b 45 08             	mov    0x8(%ebp),%eax
 2e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ef:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2f2:	eb 13                	jmp    307 <memmove+0x27>
    *dst++ = *src++;
 2f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2f7:	0f b6 10             	movzbl (%eax),%edx
 2fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2fd:	88 10                	mov    %dl,(%eax)
 2ff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 303:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 307:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 30b:	0f 9f c0             	setg   %al
 30e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 312:	84 c0                	test   %al,%al
 314:	75 de                	jne    2f4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 316:	8b 45 08             	mov    0x8(%ebp),%eax
}
 319:	c9                   	leave  
 31a:	c3                   	ret    

0000031b <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 31b:	55                   	push   %ebp
 31c:	89 e5                	mov    %esp,%ebp
 31e:	83 ec 38             	sub    $0x38,%esp
 321:	8b 45 10             	mov    0x10(%ebp),%eax
 324:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 327:	8b 45 14             	mov    0x14(%ebp),%eax
 32a:	8b 00                	mov    (%eax),%eax
 32c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 32f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 336:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 33a:	74 06                	je     342 <strtok+0x27>
 33c:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 340:	75 5a                	jne    39c <strtok+0x81>
    return match;
 342:	8b 45 f0             	mov    -0x10(%ebp),%eax
 345:	eb 76                	jmp    3bd <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 347:	8b 55 f4             	mov    -0xc(%ebp),%edx
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	01 d0                	add    %edx,%eax
 34f:	0f b6 00             	movzbl (%eax),%eax
 352:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 355:	74 06                	je     35d <strtok+0x42>
      {
	index++;
 357:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 35b:	eb 40                	jmp    39d <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 35d:	8b 45 14             	mov    0x14(%ebp),%eax
 360:	8b 00                	mov    (%eax),%eax
 362:	8b 55 f4             	mov    -0xc(%ebp),%edx
 365:	29 c2                	sub    %eax,%edx
 367:	8b 45 14             	mov    0x14(%ebp),%eax
 36a:	8b 00                	mov    (%eax),%eax
 36c:	89 c1                	mov    %eax,%ecx
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	01 c8                	add    %ecx,%eax
 373:	89 54 24 08          	mov    %edx,0x8(%esp)
 377:	89 44 24 04          	mov    %eax,0x4(%esp)
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	89 04 24             	mov    %eax,(%esp)
 381:	e8 39 00 00 00       	call   3bf <strncpy>
 386:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 389:	8b 45 08             	mov    0x8(%ebp),%eax
 38c:	0f b6 00             	movzbl (%eax),%eax
 38f:	84 c0                	test   %al,%al
 391:	74 1b                	je     3ae <strtok+0x93>
	  match = 1;
 393:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 39a:	eb 12                	jmp    3ae <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 39c:	90                   	nop
 39d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a3:	01 d0                	add    %edx,%eax
 3a5:	0f b6 00             	movzbl (%eax),%eax
 3a8:	84 c0                	test   %al,%al
 3aa:	75 9b                	jne    347 <strtok+0x2c>
 3ac:	eb 01                	jmp    3af <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 3ae:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 3af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b2:	8d 50 01             	lea    0x1(%eax),%edx
 3b5:	8b 45 14             	mov    0x14(%ebp),%eax
 3b8:	89 10                	mov    %edx,(%eax)
  return match;
 3ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3bd:	c9                   	leave  
 3be:	c3                   	ret    

000003bf <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 3bf:	55                   	push   %ebp
 3c0:	89 e5                	mov    %esp,%ebp
 3c2:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 3cb:	90                   	nop
 3cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3d0:	0f 9f c0             	setg   %al
 3d3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3d7:	84 c0                	test   %al,%al
 3d9:	74 30                	je     40b <strncpy+0x4c>
 3db:	8b 45 0c             	mov    0xc(%ebp),%eax
 3de:	0f b6 10             	movzbl (%eax),%edx
 3e1:	8b 45 08             	mov    0x8(%ebp),%eax
 3e4:	88 10                	mov    %dl,(%eax)
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	0f b6 00             	movzbl (%eax),%eax
 3ec:	84 c0                	test   %al,%al
 3ee:	0f 95 c0             	setne  %al
 3f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3f5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3f9:	84 c0                	test   %al,%al
 3fb:	75 cf                	jne    3cc <strncpy+0xd>
    ;
  while(n-- > 0)
 3fd:	eb 0c                	jmp    40b <strncpy+0x4c>
    *s++ = 0;
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
 402:	c6 00 00             	movb   $0x0,(%eax)
 405:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 409:	eb 01                	jmp    40c <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 40b:	90                   	nop
 40c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 410:	0f 9f c0             	setg   %al
 413:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 417:	84 c0                	test   %al,%al
 419:	75 e4                	jne    3ff <strncpy+0x40>
    *s++ = 0;
  return os;
 41b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 41e:	c9                   	leave  
 41f:	c3                   	ret    

00000420 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 420:	55                   	push   %ebp
 421:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 423:	eb 0c                	jmp    431 <strncmp+0x11>
    n--, p++, q++;
 425:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 429:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 42d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 431:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 435:	74 1a                	je     451 <strncmp+0x31>
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	0f b6 00             	movzbl (%eax),%eax
 43d:	84 c0                	test   %al,%al
 43f:	74 10                	je     451 <strncmp+0x31>
 441:	8b 45 08             	mov    0x8(%ebp),%eax
 444:	0f b6 10             	movzbl (%eax),%edx
 447:	8b 45 0c             	mov    0xc(%ebp),%eax
 44a:	0f b6 00             	movzbl (%eax),%eax
 44d:	38 c2                	cmp    %al,%dl
 44f:	74 d4                	je     425 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 451:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 455:	75 07                	jne    45e <strncmp+0x3e>
    return 0;
 457:	b8 00 00 00 00       	mov    $0x0,%eax
 45c:	eb 18                	jmp    476 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
 461:	0f b6 00             	movzbl (%eax),%eax
 464:	0f b6 d0             	movzbl %al,%edx
 467:	8b 45 0c             	mov    0xc(%ebp),%eax
 46a:	0f b6 00             	movzbl (%eax),%eax
 46d:	0f b6 c0             	movzbl %al,%eax
 470:	89 d1                	mov    %edx,%ecx
 472:	29 c1                	sub    %eax,%ecx
 474:	89 c8                	mov    %ecx,%eax
}
 476:	5d                   	pop    %ebp
 477:	c3                   	ret    

00000478 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 478:	55                   	push   %ebp
 479:	89 e5                	mov    %esp,%ebp
  while(*p){
 47b:	eb 13                	jmp    490 <strcat+0x18>
    *dest++ = *p++;
 47d:	8b 45 0c             	mov    0xc(%ebp),%eax
 480:	0f b6 10             	movzbl (%eax),%edx
 483:	8b 45 08             	mov    0x8(%ebp),%eax
 486:	88 10                	mov    %dl,(%eax)
 488:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 48c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 490:	8b 45 0c             	mov    0xc(%ebp),%eax
 493:	0f b6 00             	movzbl (%eax),%eax
 496:	84 c0                	test   %al,%al
 498:	75 e3                	jne    47d <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 49a:	eb 13                	jmp    4af <strcat+0x37>
    *dest++ = *q++;
 49c:	8b 45 10             	mov    0x10(%ebp),%eax
 49f:	0f b6 10             	movzbl (%eax),%edx
 4a2:	8b 45 08             	mov    0x8(%ebp),%eax
 4a5:	88 10                	mov    %dl,(%eax)
 4a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ab:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 4af:	8b 45 10             	mov    0x10(%ebp),%eax
 4b2:	0f b6 00             	movzbl (%eax),%eax
 4b5:	84 c0                	test   %al,%al
 4b7:	75 e3                	jne    49c <strcat+0x24>
    *dest++ = *q++;
  }  
 4b9:	5d                   	pop    %ebp
 4ba:	c3                   	ret    
 4bb:	90                   	nop

000004bc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4bc:	b8 01 00 00 00       	mov    $0x1,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <exit>:
SYSCALL(exit)
 4c4:	b8 02 00 00 00       	mov    $0x2,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <wait>:
SYSCALL(wait)
 4cc:	b8 03 00 00 00       	mov    $0x3,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <wait2>:
SYSCALL(wait2)
 4d4:	b8 16 00 00 00       	mov    $0x16,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <nice>:
SYSCALL(nice)
 4dc:	b8 17 00 00 00       	mov    $0x17,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <pipe>:
SYSCALL(pipe)
 4e4:	b8 04 00 00 00       	mov    $0x4,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <read>:
SYSCALL(read)
 4ec:	b8 05 00 00 00       	mov    $0x5,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <write>:
SYSCALL(write)
 4f4:	b8 10 00 00 00       	mov    $0x10,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <close>:
SYSCALL(close)
 4fc:	b8 15 00 00 00       	mov    $0x15,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <kill>:
SYSCALL(kill)
 504:	b8 06 00 00 00       	mov    $0x6,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <exec>:
SYSCALL(exec)
 50c:	b8 07 00 00 00       	mov    $0x7,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <open>:
SYSCALL(open)
 514:	b8 0f 00 00 00       	mov    $0xf,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <mknod>:
SYSCALL(mknod)
 51c:	b8 11 00 00 00       	mov    $0x11,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <unlink>:
SYSCALL(unlink)
 524:	b8 12 00 00 00       	mov    $0x12,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <fstat>:
SYSCALL(fstat)
 52c:	b8 08 00 00 00       	mov    $0x8,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <link>:
SYSCALL(link)
 534:	b8 13 00 00 00       	mov    $0x13,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <mkdir>:
SYSCALL(mkdir)
 53c:	b8 14 00 00 00       	mov    $0x14,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <chdir>:
SYSCALL(chdir)
 544:	b8 09 00 00 00       	mov    $0x9,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <dup>:
SYSCALL(dup)
 54c:	b8 0a 00 00 00       	mov    $0xa,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <getpid>:
SYSCALL(getpid)
 554:	b8 0b 00 00 00       	mov    $0xb,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <sbrk>:
SYSCALL(sbrk)
 55c:	b8 0c 00 00 00       	mov    $0xc,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <sleep>:
SYSCALL(sleep)
 564:	b8 0d 00 00 00       	mov    $0xd,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <uptime>:
SYSCALL(uptime)
 56c:	b8 0e 00 00 00       	mov    $0xe,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 574:	55                   	push   %ebp
 575:	89 e5                	mov    %esp,%ebp
 577:	83 ec 28             	sub    $0x28,%esp
 57a:	8b 45 0c             	mov    0xc(%ebp),%eax
 57d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 580:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 587:	00 
 588:	8d 45 f4             	lea    -0xc(%ebp),%eax
 58b:	89 44 24 04          	mov    %eax,0x4(%esp)
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 5a ff ff ff       	call   4f4 <write>
}
 59a:	c9                   	leave  
 59b:	c3                   	ret    

0000059c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 59c:	55                   	push   %ebp
 59d:	89 e5                	mov    %esp,%ebp
 59f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5a9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5ad:	74 17                	je     5c6 <printint+0x2a>
 5af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5b3:	79 11                	jns    5c6 <printint+0x2a>
    neg = 1;
 5b5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5bf:	f7 d8                	neg    %eax
 5c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5c4:	eb 06                	jmp    5cc <printint+0x30>
  } else {
    x = xx;
 5c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d9:	ba 00 00 00 00       	mov    $0x0,%edx
 5de:	f7 f1                	div    %ecx
 5e0:	89 d0                	mov    %edx,%eax
 5e2:	0f b6 80 70 0d 00 00 	movzbl 0xd70(%eax),%eax
 5e9:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 5ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5ef:	01 ca                	add    %ecx,%edx
 5f1:	88 02                	mov    %al,(%edx)
 5f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5f7:	8b 55 10             	mov    0x10(%ebp),%edx
 5fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 600:	ba 00 00 00 00       	mov    $0x0,%edx
 605:	f7 75 d4             	divl   -0x2c(%ebp)
 608:	89 45 ec             	mov    %eax,-0x14(%ebp)
 60b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 60f:	75 c2                	jne    5d3 <printint+0x37>
  if(neg)
 611:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 615:	74 2e                	je     645 <printint+0xa9>
    buf[i++] = '-';
 617:	8d 55 dc             	lea    -0x24(%ebp),%edx
 61a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61d:	01 d0                	add    %edx,%eax
 61f:	c6 00 2d             	movb   $0x2d,(%eax)
 622:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 626:	eb 1d                	jmp    645 <printint+0xa9>
    putc(fd, buf[i]);
 628:	8d 55 dc             	lea    -0x24(%ebp),%edx
 62b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62e:	01 d0                	add    %edx,%eax
 630:	0f b6 00             	movzbl (%eax),%eax
 633:	0f be c0             	movsbl %al,%eax
 636:	89 44 24 04          	mov    %eax,0x4(%esp)
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	89 04 24             	mov    %eax,(%esp)
 640:	e8 2f ff ff ff       	call   574 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 645:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 649:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 64d:	79 d9                	jns    628 <printint+0x8c>
    putc(fd, buf[i]);
}
 64f:	c9                   	leave  
 650:	c3                   	ret    

00000651 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 651:	55                   	push   %ebp
 652:	89 e5                	mov    %esp,%ebp
 654:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 657:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 65e:	8d 45 0c             	lea    0xc(%ebp),%eax
 661:	83 c0 04             	add    $0x4,%eax
 664:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 667:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 66e:	e9 7d 01 00 00       	jmp    7f0 <printf+0x19f>
    c = fmt[i] & 0xff;
 673:	8b 55 0c             	mov    0xc(%ebp),%edx
 676:	8b 45 f0             	mov    -0x10(%ebp),%eax
 679:	01 d0                	add    %edx,%eax
 67b:	0f b6 00             	movzbl (%eax),%eax
 67e:	0f be c0             	movsbl %al,%eax
 681:	25 ff 00 00 00       	and    $0xff,%eax
 686:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 689:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 68d:	75 2c                	jne    6bb <printf+0x6a>
      if(c == '%'){
 68f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 693:	75 0c                	jne    6a1 <printf+0x50>
        state = '%';
 695:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 69c:	e9 4b 01 00 00       	jmp    7ec <printf+0x19b>
      } else {
        putc(fd, c);
 6a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a4:	0f be c0             	movsbl %al,%eax
 6a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	89 04 24             	mov    %eax,(%esp)
 6b1:	e8 be fe ff ff       	call   574 <putc>
 6b6:	e9 31 01 00 00       	jmp    7ec <printf+0x19b>
      }
    } else if(state == '%'){
 6bb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6bf:	0f 85 27 01 00 00    	jne    7ec <printf+0x19b>
      if(c == 'd'){
 6c5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6c9:	75 2d                	jne    6f8 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 6cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ce:	8b 00                	mov    (%eax),%eax
 6d0:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6d7:	00 
 6d8:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6df:	00 
 6e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	89 04 24             	mov    %eax,(%esp)
 6ea:	e8 ad fe ff ff       	call   59c <printint>
        ap++;
 6ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f3:	e9 ed 00 00 00       	jmp    7e5 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6f8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6fc:	74 06                	je     704 <printf+0xb3>
 6fe:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 702:	75 2d                	jne    731 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 704:	8b 45 e8             	mov    -0x18(%ebp),%eax
 707:	8b 00                	mov    (%eax),%eax
 709:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 710:	00 
 711:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 718:	00 
 719:	89 44 24 04          	mov    %eax,0x4(%esp)
 71d:	8b 45 08             	mov    0x8(%ebp),%eax
 720:	89 04 24             	mov    %eax,(%esp)
 723:	e8 74 fe ff ff       	call   59c <printint>
        ap++;
 728:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72c:	e9 b4 00 00 00       	jmp    7e5 <printf+0x194>
      } else if(c == 's'){
 731:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 735:	75 46                	jne    77d <printf+0x12c>
        s = (char*)*ap;
 737:	8b 45 e8             	mov    -0x18(%ebp),%eax
 73a:	8b 00                	mov    (%eax),%eax
 73c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 73f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 743:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 747:	75 27                	jne    770 <printf+0x11f>
          s = "(null)";
 749:	c7 45 f4 6c 0a 00 00 	movl   $0xa6c,-0xc(%ebp)
        while(*s != 0){
 750:	eb 1e                	jmp    770 <printf+0x11f>
          putc(fd, *s);
 752:	8b 45 f4             	mov    -0xc(%ebp),%eax
 755:	0f b6 00             	movzbl (%eax),%eax
 758:	0f be c0             	movsbl %al,%eax
 75b:	89 44 24 04          	mov    %eax,0x4(%esp)
 75f:	8b 45 08             	mov    0x8(%ebp),%eax
 762:	89 04 24             	mov    %eax,(%esp)
 765:	e8 0a fe ff ff       	call   574 <putc>
          s++;
 76a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 76e:	eb 01                	jmp    771 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 770:	90                   	nop
 771:	8b 45 f4             	mov    -0xc(%ebp),%eax
 774:	0f b6 00             	movzbl (%eax),%eax
 777:	84 c0                	test   %al,%al
 779:	75 d7                	jne    752 <printf+0x101>
 77b:	eb 68                	jmp    7e5 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 77d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 781:	75 1d                	jne    7a0 <printf+0x14f>
        putc(fd, *ap);
 783:	8b 45 e8             	mov    -0x18(%ebp),%eax
 786:	8b 00                	mov    (%eax),%eax
 788:	0f be c0             	movsbl %al,%eax
 78b:	89 44 24 04          	mov    %eax,0x4(%esp)
 78f:	8b 45 08             	mov    0x8(%ebp),%eax
 792:	89 04 24             	mov    %eax,(%esp)
 795:	e8 da fd ff ff       	call   574 <putc>
        ap++;
 79a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 79e:	eb 45                	jmp    7e5 <printf+0x194>
      } else if(c == '%'){
 7a0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7a4:	75 17                	jne    7bd <printf+0x16c>
        putc(fd, c);
 7a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a9:	0f be c0             	movsbl %al,%eax
 7ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b0:	8b 45 08             	mov    0x8(%ebp),%eax
 7b3:	89 04 24             	mov    %eax,(%esp)
 7b6:	e8 b9 fd ff ff       	call   574 <putc>
 7bb:	eb 28                	jmp    7e5 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7bd:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7c4:	00 
 7c5:	8b 45 08             	mov    0x8(%ebp),%eax
 7c8:	89 04 24             	mov    %eax,(%esp)
 7cb:	e8 a4 fd ff ff       	call   574 <putc>
        putc(fd, c);
 7d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d3:	0f be c0             	movsbl %al,%eax
 7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7da:	8b 45 08             	mov    0x8(%ebp),%eax
 7dd:	89 04 24             	mov    %eax,(%esp)
 7e0:	e8 8f fd ff ff       	call   574 <putc>
      }
      state = 0;
 7e5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7ec:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7f0:	8b 55 0c             	mov    0xc(%ebp),%edx
 7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f6:	01 d0                	add    %edx,%eax
 7f8:	0f b6 00             	movzbl (%eax),%eax
 7fb:	84 c0                	test   %al,%al
 7fd:	0f 85 70 fe ff ff    	jne    673 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 803:	c9                   	leave  
 804:	c3                   	ret    
 805:	66 90                	xchg   %ax,%ax
 807:	90                   	nop

00000808 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 808:	55                   	push   %ebp
 809:	89 e5                	mov    %esp,%ebp
 80b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80e:	8b 45 08             	mov    0x8(%ebp),%eax
 811:	83 e8 08             	sub    $0x8,%eax
 814:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 817:	a1 8c 0d 00 00       	mov    0xd8c,%eax
 81c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 81f:	eb 24                	jmp    845 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 829:	77 12                	ja     83d <free+0x35>
 82b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 831:	77 24                	ja     857 <free+0x4f>
 833:	8b 45 fc             	mov    -0x4(%ebp),%eax
 836:	8b 00                	mov    (%eax),%eax
 838:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 83b:	77 1a                	ja     857 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 840:	8b 00                	mov    (%eax),%eax
 842:	89 45 fc             	mov    %eax,-0x4(%ebp)
 845:	8b 45 f8             	mov    -0x8(%ebp),%eax
 848:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 84b:	76 d4                	jbe    821 <free+0x19>
 84d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 850:	8b 00                	mov    (%eax),%eax
 852:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 855:	76 ca                	jbe    821 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 857:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85a:	8b 40 04             	mov    0x4(%eax),%eax
 85d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 864:	8b 45 f8             	mov    -0x8(%ebp),%eax
 867:	01 c2                	add    %eax,%edx
 869:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86c:	8b 00                	mov    (%eax),%eax
 86e:	39 c2                	cmp    %eax,%edx
 870:	75 24                	jne    896 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 872:	8b 45 f8             	mov    -0x8(%ebp),%eax
 875:	8b 50 04             	mov    0x4(%eax),%edx
 878:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87b:	8b 00                	mov    (%eax),%eax
 87d:	8b 40 04             	mov    0x4(%eax),%eax
 880:	01 c2                	add    %eax,%edx
 882:	8b 45 f8             	mov    -0x8(%ebp),%eax
 885:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 888:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88b:	8b 00                	mov    (%eax),%eax
 88d:	8b 10                	mov    (%eax),%edx
 88f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 892:	89 10                	mov    %edx,(%eax)
 894:	eb 0a                	jmp    8a0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 896:	8b 45 fc             	mov    -0x4(%ebp),%eax
 899:	8b 10                	mov    (%eax),%edx
 89b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	8b 40 04             	mov    0x4(%eax),%eax
 8a6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b0:	01 d0                	add    %edx,%eax
 8b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b5:	75 20                	jne    8d7 <free+0xcf>
    p->s.size += bp->s.size;
 8b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ba:	8b 50 04             	mov    0x4(%eax),%edx
 8bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c0:	8b 40 04             	mov    0x4(%eax),%eax
 8c3:	01 c2                	add    %eax,%edx
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ce:	8b 10                	mov    (%eax),%edx
 8d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d3:	89 10                	mov    %edx,(%eax)
 8d5:	eb 08                	jmp    8df <free+0xd7>
  } else
    p->s.ptr = bp;
 8d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8da:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8dd:	89 10                	mov    %edx,(%eax)
  freep = p;
 8df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e2:	a3 8c 0d 00 00       	mov    %eax,0xd8c
}
 8e7:	c9                   	leave  
 8e8:	c3                   	ret    

000008e9 <morecore>:

static Header*
morecore(uint nu)
{
 8e9:	55                   	push   %ebp
 8ea:	89 e5                	mov    %esp,%ebp
 8ec:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8ef:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8f6:	77 07                	ja     8ff <morecore+0x16>
    nu = 4096;
 8f8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ff:	8b 45 08             	mov    0x8(%ebp),%eax
 902:	c1 e0 03             	shl    $0x3,%eax
 905:	89 04 24             	mov    %eax,(%esp)
 908:	e8 4f fc ff ff       	call   55c <sbrk>
 90d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 910:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 914:	75 07                	jne    91d <morecore+0x34>
    return 0;
 916:	b8 00 00 00 00       	mov    $0x0,%eax
 91b:	eb 22                	jmp    93f <morecore+0x56>
  hp = (Header*)p;
 91d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 920:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 923:	8b 45 f0             	mov    -0x10(%ebp),%eax
 926:	8b 55 08             	mov    0x8(%ebp),%edx
 929:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 92c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92f:	83 c0 08             	add    $0x8,%eax
 932:	89 04 24             	mov    %eax,(%esp)
 935:	e8 ce fe ff ff       	call   808 <free>
  return freep;
 93a:	a1 8c 0d 00 00       	mov    0xd8c,%eax
}
 93f:	c9                   	leave  
 940:	c3                   	ret    

00000941 <malloc>:

void*
malloc(uint nbytes)
{
 941:	55                   	push   %ebp
 942:	89 e5                	mov    %esp,%ebp
 944:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 947:	8b 45 08             	mov    0x8(%ebp),%eax
 94a:	83 c0 07             	add    $0x7,%eax
 94d:	c1 e8 03             	shr    $0x3,%eax
 950:	83 c0 01             	add    $0x1,%eax
 953:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 956:	a1 8c 0d 00 00       	mov    0xd8c,%eax
 95b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 95e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 962:	75 23                	jne    987 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 964:	c7 45 f0 84 0d 00 00 	movl   $0xd84,-0x10(%ebp)
 96b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96e:	a3 8c 0d 00 00       	mov    %eax,0xd8c
 973:	a1 8c 0d 00 00       	mov    0xd8c,%eax
 978:	a3 84 0d 00 00       	mov    %eax,0xd84
    base.s.size = 0;
 97d:	c7 05 88 0d 00 00 00 	movl   $0x0,0xd88
 984:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 987:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98a:	8b 00                	mov    (%eax),%eax
 98c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 98f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 992:	8b 40 04             	mov    0x4(%eax),%eax
 995:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 998:	72 4d                	jb     9e7 <malloc+0xa6>
      if(p->s.size == nunits)
 99a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99d:	8b 40 04             	mov    0x4(%eax),%eax
 9a0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9a3:	75 0c                	jne    9b1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a8:	8b 10                	mov    (%eax),%edx
 9aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ad:	89 10                	mov    %edx,(%eax)
 9af:	eb 26                	jmp    9d7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	8b 40 04             	mov    0x4(%eax),%eax
 9b7:	89 c2                	mov    %eax,%edx
 9b9:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c5:	8b 40 04             	mov    0x4(%eax),%eax
 9c8:	c1 e0 03             	shl    $0x3,%eax
 9cb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9d4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9da:	a3 8c 0d 00 00       	mov    %eax,0xd8c
      return (void*)(p + 1);
 9df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e2:	83 c0 08             	add    $0x8,%eax
 9e5:	eb 38                	jmp    a1f <malloc+0xde>
    }
    if(p == freep)
 9e7:	a1 8c 0d 00 00       	mov    0xd8c,%eax
 9ec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9ef:	75 1b                	jne    a0c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9f4:	89 04 24             	mov    %eax,(%esp)
 9f7:	e8 ed fe ff ff       	call   8e9 <morecore>
 9fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a03:	75 07                	jne    a0c <malloc+0xcb>
        return 0;
 a05:	b8 00 00 00 00       	mov    $0x0,%eax
 a0a:	eb 13                	jmp    a1f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a15:	8b 00                	mov    (%eax),%eax
 a17:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a1a:	e9 70 ff ff ff       	jmp    98f <malloc+0x4e>
}
 a1f:	c9                   	leave  
 a20:	c3                   	ret    
