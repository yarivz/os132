
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
   6:	e8 41 05 00 00       	call   54c <getpid>
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
  28:	c7 44 24 04 08 0a 00 	movl   $0xa08,0x4(%esp)
  2f:	00 
  30:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  37:	e8 07 06 00 00       	call   643 <printf>
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
  4e:	c7 44 24 04 30 0a 00 	movl   $0xa30,0x4(%esp)
  55:	00 
  56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5d:	e8 e1 05 00 00       	call   643 <printf>
  printf(1, "Father pid is %d\n",getpid());
  62:	e8 e5 04 00 00       	call   54c <getpid>
  67:	89 44 24 08          	mov    %eax,0x8(%esp)
  6b:	c7 44 24 04 3e 0a 00 	movl   $0xa3e,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 c4 05 00 00       	call   643 <printf>
  sleep(1000);
  7f:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
  86:	e8 d1 04 00 00       	call   55c <sleep>

  if(fork() == 0)
  8b:	e8 24 04 00 00       	call   4b4 <fork>
  90:	85 c0                	test   %eax,%eax
  92:	75 0a                	jne    9e <Gsanity+0x56>
  {
    foo();
  94:	e8 67 ff ff ff       	call   0 <foo>
    exit();      
  99:	e8 1e 04 00 00       	call   4bc <exit>
  }
  foo();
  9e:	e8 5d ff ff ff       	call   0 <foo>
  wait();
  a3:	e8 1c 04 00 00       	call   4c4 <wait>
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
  b5:	e8 02 04 00 00       	call   4bc <exit>
  ba:	90                   	nop
  bb:	90                   	nop

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
 169:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16c:	03 45 08             	add    0x8(%ebp),%eax
 16f:	0f b6 00             	movzbl (%eax),%eax
 172:	84 c0                	test   %al,%al
 174:	75 ef                	jne    165 <strlen+0xf>
  return n;
 176:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 179:	c9                   	leave  
 17a:	c3                   	ret    

0000017b <memset>:

void*
memset(void *dst, int c, uint n)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 181:	8b 45 10             	mov    0x10(%ebp),%eax
 184:	89 44 24 08          	mov    %eax,0x8(%esp)
 188:	8b 45 0c             	mov    0xc(%ebp),%eax
 18b:	89 44 24 04          	mov    %eax,0x4(%esp)
 18f:	8b 45 08             	mov    0x8(%ebp),%eax
 192:	89 04 24             	mov    %eax,(%esp)
 195:	e8 22 ff ff ff       	call   bc <stosb>
  return dst;
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 19d:	c9                   	leave  
 19e:	c3                   	ret    

0000019f <strchr>:

char*
strchr(const char *s, char c)
{
 19f:	55                   	push   %ebp
 1a0:	89 e5                	mov    %esp,%ebp
 1a2:	83 ec 04             	sub    $0x4,%esp
 1a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1ab:	eb 14                	jmp    1c1 <strchr+0x22>
    if(*s == c)
 1ad:	8b 45 08             	mov    0x8(%ebp),%eax
 1b0:	0f b6 00             	movzbl (%eax),%eax
 1b3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1b6:	75 05                	jne    1bd <strchr+0x1e>
      return (char*)s;
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	eb 13                	jmp    1d0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
 1c4:	0f b6 00             	movzbl (%eax),%eax
 1c7:	84 c0                	test   %al,%al
 1c9:	75 e2                	jne    1ad <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d0:	c9                   	leave  
 1d1:	c3                   	ret    

000001d2 <gets>:

char*
gets(char *buf, int max)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1df:	eb 44                	jmp    225 <gets+0x53>
    cc = read(0, &c, 1);
 1e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1e8:	00 
 1e9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1f7:	e8 e8 02 00 00       	call   4e4 <read>
 1fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 203:	7e 2d                	jle    232 <gets+0x60>
      break;
    buf[i++] = c;
 205:	8b 45 f4             	mov    -0xc(%ebp),%eax
 208:	03 45 08             	add    0x8(%ebp),%eax
 20b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 20f:	88 10                	mov    %dl,(%eax)
 211:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 215:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 219:	3c 0a                	cmp    $0xa,%al
 21b:	74 16                	je     233 <gets+0x61>
 21d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 221:	3c 0d                	cmp    $0xd,%al
 223:	74 0e                	je     233 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 225:	8b 45 f4             	mov    -0xc(%ebp),%eax
 228:	83 c0 01             	add    $0x1,%eax
 22b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 22e:	7c b1                	jl     1e1 <gets+0xf>
 230:	eb 01                	jmp    233 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 232:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 233:	8b 45 f4             	mov    -0xc(%ebp),%eax
 236:	03 45 08             	add    0x8(%ebp),%eax
 239:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 23f:	c9                   	leave  
 240:	c3                   	ret    

00000241 <stat>:

int
stat(char *n, struct stat *st)
{
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
 244:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 247:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 24e:	00 
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
 252:	89 04 24             	mov    %eax,(%esp)
 255:	e8 b2 02 00 00       	call   50c <open>
 25a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 25d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 261:	79 07                	jns    26a <stat+0x29>
    return -1;
 263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 268:	eb 23                	jmp    28d <stat+0x4c>
  r = fstat(fd, st);
 26a:	8b 45 0c             	mov    0xc(%ebp),%eax
 26d:	89 44 24 04          	mov    %eax,0x4(%esp)
 271:	8b 45 f4             	mov    -0xc(%ebp),%eax
 274:	89 04 24             	mov    %eax,(%esp)
 277:	e8 a8 02 00 00       	call   524 <fstat>
 27c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 27f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 282:	89 04 24             	mov    %eax,(%esp)
 285:	e8 6a 02 00 00       	call   4f4 <close>
  return r;
 28a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 28d:	c9                   	leave  
 28e:	c3                   	ret    

0000028f <atoi>:

int
atoi(const char *s)
{
 28f:	55                   	push   %ebp
 290:	89 e5                	mov    %esp,%ebp
 292:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 295:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 29c:	eb 23                	jmp    2c1 <atoi+0x32>
    n = n*10 + *s++ - '0';
 29e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2a1:	89 d0                	mov    %edx,%eax
 2a3:	c1 e0 02             	shl    $0x2,%eax
 2a6:	01 d0                	add    %edx,%eax
 2a8:	01 c0                	add    %eax,%eax
 2aa:	89 c2                	mov    %eax,%edx
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
 2af:	0f b6 00             	movzbl (%eax),%eax
 2b2:	0f be c0             	movsbl %al,%eax
 2b5:	01 d0                	add    %edx,%eax
 2b7:	83 e8 30             	sub    $0x30,%eax
 2ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
 2bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c1:	8b 45 08             	mov    0x8(%ebp),%eax
 2c4:	0f b6 00             	movzbl (%eax),%eax
 2c7:	3c 2f                	cmp    $0x2f,%al
 2c9:	7e 0a                	jle    2d5 <atoi+0x46>
 2cb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ce:	0f b6 00             	movzbl (%eax),%eax
 2d1:	3c 39                	cmp    $0x39,%al
 2d3:	7e c9                	jle    29e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2d8:	c9                   	leave  
 2d9:	c3                   	ret    

000002da <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2da:	55                   	push   %ebp
 2db:	89 e5                	mov    %esp,%ebp
 2dd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ec:	eb 13                	jmp    301 <memmove+0x27>
    *dst++ = *src++;
 2ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2f1:	0f b6 10             	movzbl (%eax),%edx
 2f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2f7:	88 10                	mov    %dl,(%eax)
 2f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 301:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 305:	0f 9f c0             	setg   %al
 308:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 30c:	84 c0                	test   %al,%al
 30e:	75 de                	jne    2ee <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 310:	8b 45 08             	mov    0x8(%ebp),%eax
}
 313:	c9                   	leave  
 314:	c3                   	ret    

00000315 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 315:	55                   	push   %ebp
 316:	89 e5                	mov    %esp,%ebp
 318:	83 ec 38             	sub    $0x38,%esp
 31b:	8b 45 10             	mov    0x10(%ebp),%eax
 31e:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 321:	8b 45 14             	mov    0x14(%ebp),%eax
 324:	8b 00                	mov    (%eax),%eax
 326:	89 45 f4             	mov    %eax,-0xc(%ebp)
 329:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 330:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 334:	74 06                	je     33c <strtok+0x27>
 336:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 33a:	75 54                	jne    390 <strtok+0x7b>
    return match;
 33c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 33f:	eb 6e                	jmp    3af <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 341:	8b 45 f4             	mov    -0xc(%ebp),%eax
 344:	03 45 0c             	add    0xc(%ebp),%eax
 347:	0f b6 00             	movzbl (%eax),%eax
 34a:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 34d:	74 06                	je     355 <strtok+0x40>
      {
	index++;
 34f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 353:	eb 3c                	jmp    391 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 355:	8b 45 14             	mov    0x14(%ebp),%eax
 358:	8b 00                	mov    (%eax),%eax
 35a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 35d:	29 c2                	sub    %eax,%edx
 35f:	8b 45 14             	mov    0x14(%ebp),%eax
 362:	8b 00                	mov    (%eax),%eax
 364:	03 45 0c             	add    0xc(%ebp),%eax
 367:	89 54 24 08          	mov    %edx,0x8(%esp)
 36b:	89 44 24 04          	mov    %eax,0x4(%esp)
 36f:	8b 45 08             	mov    0x8(%ebp),%eax
 372:	89 04 24             	mov    %eax,(%esp)
 375:	e8 37 00 00 00       	call   3b1 <strncpy>
 37a:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	0f b6 00             	movzbl (%eax),%eax
 383:	84 c0                	test   %al,%al
 385:	74 19                	je     3a0 <strtok+0x8b>
	  match = 1;
 387:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 38e:	eb 10                	jmp    3a0 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 390:	90                   	nop
 391:	8b 45 f4             	mov    -0xc(%ebp),%eax
 394:	03 45 0c             	add    0xc(%ebp),%eax
 397:	0f b6 00             	movzbl (%eax),%eax
 39a:	84 c0                	test   %al,%al
 39c:	75 a3                	jne    341 <strtok+0x2c>
 39e:	eb 01                	jmp    3a1 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 3a0:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 3a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a4:	8d 50 01             	lea    0x1(%eax),%edx
 3a7:	8b 45 14             	mov    0x14(%ebp),%eax
 3aa:	89 10                	mov    %edx,(%eax)
  return match;
 3ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3af:	c9                   	leave  
 3b0:	c3                   	ret    

000003b1 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
 3b4:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 3bd:	90                   	nop
 3be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3c2:	0f 9f c0             	setg   %al
 3c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3c9:	84 c0                	test   %al,%al
 3cb:	74 30                	je     3fd <strncpy+0x4c>
 3cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d0:	0f b6 10             	movzbl (%eax),%edx
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	88 10                	mov    %dl,(%eax)
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	0f b6 00             	movzbl (%eax),%eax
 3de:	84 c0                	test   %al,%al
 3e0:	0f 95 c0             	setne  %al
 3e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3eb:	84 c0                	test   %al,%al
 3ed:	75 cf                	jne    3be <strncpy+0xd>
    ;
  while(n-- > 0)
 3ef:	eb 0c                	jmp    3fd <strncpy+0x4c>
    *s++ = 0;
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	c6 00 00             	movb   $0x0,(%eax)
 3f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3fb:	eb 01                	jmp    3fe <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3fd:	90                   	nop
 3fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 402:	0f 9f c0             	setg   %al
 405:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 409:	84 c0                	test   %al,%al
 40b:	75 e4                	jne    3f1 <strncpy+0x40>
    *s++ = 0;
  return os;
 40d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 410:	c9                   	leave  
 411:	c3                   	ret    

00000412 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 412:	55                   	push   %ebp
 413:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 415:	eb 0c                	jmp    423 <strncmp+0x11>
    n--, p++, q++;
 417:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 41b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 41f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 423:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 427:	74 1a                	je     443 <strncmp+0x31>
 429:	8b 45 08             	mov    0x8(%ebp),%eax
 42c:	0f b6 00             	movzbl (%eax),%eax
 42f:	84 c0                	test   %al,%al
 431:	74 10                	je     443 <strncmp+0x31>
 433:	8b 45 08             	mov    0x8(%ebp),%eax
 436:	0f b6 10             	movzbl (%eax),%edx
 439:	8b 45 0c             	mov    0xc(%ebp),%eax
 43c:	0f b6 00             	movzbl (%eax),%eax
 43f:	38 c2                	cmp    %al,%dl
 441:	74 d4                	je     417 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 443:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 447:	75 07                	jne    450 <strncmp+0x3e>
    return 0;
 449:	b8 00 00 00 00       	mov    $0x0,%eax
 44e:	eb 18                	jmp    468 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	0f b6 00             	movzbl (%eax),%eax
 456:	0f b6 d0             	movzbl %al,%edx
 459:	8b 45 0c             	mov    0xc(%ebp),%eax
 45c:	0f b6 00             	movzbl (%eax),%eax
 45f:	0f b6 c0             	movzbl %al,%eax
 462:	89 d1                	mov    %edx,%ecx
 464:	29 c1                	sub    %eax,%ecx
 466:	89 c8                	mov    %ecx,%eax
}
 468:	5d                   	pop    %ebp
 469:	c3                   	ret    

0000046a <strcat>:

void
strcat(char *dest, char *p, char *q)
{  
 46a:	55                   	push   %ebp
 46b:	89 e5                	mov    %esp,%ebp
  while(*p){
 46d:	eb 13                	jmp    482 <strcat+0x18>
    *dest++ = *p++;
 46f:	8b 45 0c             	mov    0xc(%ebp),%eax
 472:	0f b6 10             	movzbl (%eax),%edx
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	88 10                	mov    %dl,(%eax)
 47a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 47e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, char *p, char *q)
{  
  while(*p){
 482:	8b 45 0c             	mov    0xc(%ebp),%eax
 485:	0f b6 00             	movzbl (%eax),%eax
 488:	84 c0                	test   %al,%al
 48a:	75 e3                	jne    46f <strcat+0x5>
    *dest++ = *p++;
  }

  while(*q){
 48c:	eb 13                	jmp    4a1 <strcat+0x37>
    *dest++ = *q++;
 48e:	8b 45 10             	mov    0x10(%ebp),%eax
 491:	0f b6 10             	movzbl (%eax),%edx
 494:	8b 45 08             	mov    0x8(%ebp),%eax
 497:	88 10                	mov    %dl,(%eax)
 499:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 49d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
{  
  while(*p){
    *dest++ = *p++;
  }

  while(*q){
 4a1:	8b 45 10             	mov    0x10(%ebp),%eax
 4a4:	0f b6 00             	movzbl (%eax),%eax
 4a7:	84 c0                	test   %al,%al
 4a9:	75 e3                	jne    48e <strcat+0x24>
    *dest++ = *q++;
  }
  *dest = 0;
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	c6 00 00             	movb   $0x0,(%eax)
 4b1:	5d                   	pop    %ebp
 4b2:	c3                   	ret    
 4b3:	90                   	nop

000004b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4b4:	b8 01 00 00 00       	mov    $0x1,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <exit>:
SYSCALL(exit)
 4bc:	b8 02 00 00 00       	mov    $0x2,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <wait>:
SYSCALL(wait)
 4c4:	b8 03 00 00 00       	mov    $0x3,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <wait2>:
SYSCALL(wait2)
 4cc:	b8 16 00 00 00       	mov    $0x16,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <nice>:
SYSCALL(nice)
 4d4:	b8 17 00 00 00       	mov    $0x17,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <pipe>:
SYSCALL(pipe)
 4dc:	b8 04 00 00 00       	mov    $0x4,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <read>:
SYSCALL(read)
 4e4:	b8 05 00 00 00       	mov    $0x5,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <write>:
SYSCALL(write)
 4ec:	b8 10 00 00 00       	mov    $0x10,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <close>:
SYSCALL(close)
 4f4:	b8 15 00 00 00       	mov    $0x15,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <kill>:
SYSCALL(kill)
 4fc:	b8 06 00 00 00       	mov    $0x6,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <exec>:
SYSCALL(exec)
 504:	b8 07 00 00 00       	mov    $0x7,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <open>:
SYSCALL(open)
 50c:	b8 0f 00 00 00       	mov    $0xf,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <mknod>:
SYSCALL(mknod)
 514:	b8 11 00 00 00       	mov    $0x11,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <unlink>:
SYSCALL(unlink)
 51c:	b8 12 00 00 00       	mov    $0x12,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <fstat>:
SYSCALL(fstat)
 524:	b8 08 00 00 00       	mov    $0x8,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <link>:
SYSCALL(link)
 52c:	b8 13 00 00 00       	mov    $0x13,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <mkdir>:
SYSCALL(mkdir)
 534:	b8 14 00 00 00       	mov    $0x14,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <chdir>:
SYSCALL(chdir)
 53c:	b8 09 00 00 00       	mov    $0x9,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <dup>:
SYSCALL(dup)
 544:	b8 0a 00 00 00       	mov    $0xa,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <getpid>:
SYSCALL(getpid)
 54c:	b8 0b 00 00 00       	mov    $0xb,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <sbrk>:
SYSCALL(sbrk)
 554:	b8 0c 00 00 00       	mov    $0xc,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <sleep>:
SYSCALL(sleep)
 55c:	b8 0d 00 00 00       	mov    $0xd,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <uptime>:
SYSCALL(uptime)
 564:	b8 0e 00 00 00       	mov    $0xe,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 56c:	55                   	push   %ebp
 56d:	89 e5                	mov    %esp,%ebp
 56f:	83 ec 28             	sub    $0x28,%esp
 572:	8b 45 0c             	mov    0xc(%ebp),%eax
 575:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 578:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 57f:	00 
 580:	8d 45 f4             	lea    -0xc(%ebp),%eax
 583:	89 44 24 04          	mov    %eax,0x4(%esp)
 587:	8b 45 08             	mov    0x8(%ebp),%eax
 58a:	89 04 24             	mov    %eax,(%esp)
 58d:	e8 5a ff ff ff       	call   4ec <write>
}
 592:	c9                   	leave  
 593:	c3                   	ret    

00000594 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 594:	55                   	push   %ebp
 595:	89 e5                	mov    %esp,%ebp
 597:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 59a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5a1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5a5:	74 17                	je     5be <printint+0x2a>
 5a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5ab:	79 11                	jns    5be <printint+0x2a>
    neg = 1;
 5ad:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b7:	f7 d8                	neg    %eax
 5b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5bc:	eb 06                	jmp    5c4 <printint+0x30>
  } else {
    x = xx;
 5be:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d1:	ba 00 00 00 00       	mov    $0x0,%edx
 5d6:	f7 f1                	div    %ecx
 5d8:	89 d0                	mov    %edx,%eax
 5da:	0f b6 90 54 0d 00 00 	movzbl 0xd54(%eax),%edx
 5e1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5e4:	03 45 f4             	add    -0xc(%ebp),%eax
 5e7:	88 10                	mov    %dl,(%eax)
 5e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5ed:	8b 55 10             	mov    0x10(%ebp),%edx
 5f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5f6:	ba 00 00 00 00       	mov    $0x0,%edx
 5fb:	f7 75 d4             	divl   -0x2c(%ebp)
 5fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
 601:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 605:	75 c4                	jne    5cb <printint+0x37>
  if(neg)
 607:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 60b:	74 2a                	je     637 <printint+0xa3>
    buf[i++] = '-';
 60d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 610:	03 45 f4             	add    -0xc(%ebp),%eax
 613:	c6 00 2d             	movb   $0x2d,(%eax)
 616:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 61a:	eb 1b                	jmp    637 <printint+0xa3>
    putc(fd, buf[i]);
 61c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 61f:	03 45 f4             	add    -0xc(%ebp),%eax
 622:	0f b6 00             	movzbl (%eax),%eax
 625:	0f be c0             	movsbl %al,%eax
 628:	89 44 24 04          	mov    %eax,0x4(%esp)
 62c:	8b 45 08             	mov    0x8(%ebp),%eax
 62f:	89 04 24             	mov    %eax,(%esp)
 632:	e8 35 ff ff ff       	call   56c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 637:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 63b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 63f:	79 db                	jns    61c <printint+0x88>
    putc(fd, buf[i]);
}
 641:	c9                   	leave  
 642:	c3                   	ret    

00000643 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 643:	55                   	push   %ebp
 644:	89 e5                	mov    %esp,%ebp
 646:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 649:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 650:	8d 45 0c             	lea    0xc(%ebp),%eax
 653:	83 c0 04             	add    $0x4,%eax
 656:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 659:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 660:	e9 7d 01 00 00       	jmp    7e2 <printf+0x19f>
    c = fmt[i] & 0xff;
 665:	8b 55 0c             	mov    0xc(%ebp),%edx
 668:	8b 45 f0             	mov    -0x10(%ebp),%eax
 66b:	01 d0                	add    %edx,%eax
 66d:	0f b6 00             	movzbl (%eax),%eax
 670:	0f be c0             	movsbl %al,%eax
 673:	25 ff 00 00 00       	and    $0xff,%eax
 678:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 67b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 67f:	75 2c                	jne    6ad <printf+0x6a>
      if(c == '%'){
 681:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 685:	75 0c                	jne    693 <printf+0x50>
        state = '%';
 687:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 68e:	e9 4b 01 00 00       	jmp    7de <printf+0x19b>
      } else {
        putc(fd, c);
 693:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 696:	0f be c0             	movsbl %al,%eax
 699:	89 44 24 04          	mov    %eax,0x4(%esp)
 69d:	8b 45 08             	mov    0x8(%ebp),%eax
 6a0:	89 04 24             	mov    %eax,(%esp)
 6a3:	e8 c4 fe ff ff       	call   56c <putc>
 6a8:	e9 31 01 00 00       	jmp    7de <printf+0x19b>
      }
    } else if(state == '%'){
 6ad:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6b1:	0f 85 27 01 00 00    	jne    7de <printf+0x19b>
      if(c == 'd'){
 6b7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6bb:	75 2d                	jne    6ea <printf+0xa7>
        printint(fd, *ap, 10, 1);
 6bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6c9:	00 
 6ca:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6d1:	00 
 6d2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d6:	8b 45 08             	mov    0x8(%ebp),%eax
 6d9:	89 04 24             	mov    %eax,(%esp)
 6dc:	e8 b3 fe ff ff       	call   594 <printint>
        ap++;
 6e1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e5:	e9 ed 00 00 00       	jmp    7d7 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6ea:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ee:	74 06                	je     6f6 <printf+0xb3>
 6f0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6f4:	75 2d                	jne    723 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f9:	8b 00                	mov    (%eax),%eax
 6fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 702:	00 
 703:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 70a:	00 
 70b:	89 44 24 04          	mov    %eax,0x4(%esp)
 70f:	8b 45 08             	mov    0x8(%ebp),%eax
 712:	89 04 24             	mov    %eax,(%esp)
 715:	e8 7a fe ff ff       	call   594 <printint>
        ap++;
 71a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 71e:	e9 b4 00 00 00       	jmp    7d7 <printf+0x194>
      } else if(c == 's'){
 723:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 727:	75 46                	jne    76f <printf+0x12c>
        s = (char*)*ap;
 729:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72c:	8b 00                	mov    (%eax),%eax
 72e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 731:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 735:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 739:	75 27                	jne    762 <printf+0x11f>
          s = "(null)";
 73b:	c7 45 f4 50 0a 00 00 	movl   $0xa50,-0xc(%ebp)
        while(*s != 0){
 742:	eb 1e                	jmp    762 <printf+0x11f>
          putc(fd, *s);
 744:	8b 45 f4             	mov    -0xc(%ebp),%eax
 747:	0f b6 00             	movzbl (%eax),%eax
 74a:	0f be c0             	movsbl %al,%eax
 74d:	89 44 24 04          	mov    %eax,0x4(%esp)
 751:	8b 45 08             	mov    0x8(%ebp),%eax
 754:	89 04 24             	mov    %eax,(%esp)
 757:	e8 10 fe ff ff       	call   56c <putc>
          s++;
 75c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 760:	eb 01                	jmp    763 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 762:	90                   	nop
 763:	8b 45 f4             	mov    -0xc(%ebp),%eax
 766:	0f b6 00             	movzbl (%eax),%eax
 769:	84 c0                	test   %al,%al
 76b:	75 d7                	jne    744 <printf+0x101>
 76d:	eb 68                	jmp    7d7 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 76f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 773:	75 1d                	jne    792 <printf+0x14f>
        putc(fd, *ap);
 775:	8b 45 e8             	mov    -0x18(%ebp),%eax
 778:	8b 00                	mov    (%eax),%eax
 77a:	0f be c0             	movsbl %al,%eax
 77d:	89 44 24 04          	mov    %eax,0x4(%esp)
 781:	8b 45 08             	mov    0x8(%ebp),%eax
 784:	89 04 24             	mov    %eax,(%esp)
 787:	e8 e0 fd ff ff       	call   56c <putc>
        ap++;
 78c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 790:	eb 45                	jmp    7d7 <printf+0x194>
      } else if(c == '%'){
 792:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 796:	75 17                	jne    7af <printf+0x16c>
        putc(fd, c);
 798:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79b:	0f be c0             	movsbl %al,%eax
 79e:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a2:	8b 45 08             	mov    0x8(%ebp),%eax
 7a5:	89 04 24             	mov    %eax,(%esp)
 7a8:	e8 bf fd ff ff       	call   56c <putc>
 7ad:	eb 28                	jmp    7d7 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7af:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7b6:	00 
 7b7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ba:	89 04 24             	mov    %eax,(%esp)
 7bd:	e8 aa fd ff ff       	call   56c <putc>
        putc(fd, c);
 7c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c5:	0f be c0             	movsbl %al,%eax
 7c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 7cc:	8b 45 08             	mov    0x8(%ebp),%eax
 7cf:	89 04 24             	mov    %eax,(%esp)
 7d2:	e8 95 fd ff ff       	call   56c <putc>
      }
      state = 0;
 7d7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7de:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7e2:	8b 55 0c             	mov    0xc(%ebp),%edx
 7e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e8:	01 d0                	add    %edx,%eax
 7ea:	0f b6 00             	movzbl (%eax),%eax
 7ed:	84 c0                	test   %al,%al
 7ef:	0f 85 70 fe ff ff    	jne    665 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7f5:	c9                   	leave  
 7f6:	c3                   	ret    
 7f7:	90                   	nop

000007f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f8:	55                   	push   %ebp
 7f9:	89 e5                	mov    %esp,%ebp
 7fb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fe:	8b 45 08             	mov    0x8(%ebp),%eax
 801:	83 e8 08             	sub    $0x8,%eax
 804:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 807:	a1 70 0d 00 00       	mov    0xd70,%eax
 80c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 80f:	eb 24                	jmp    835 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 819:	77 12                	ja     82d <free+0x35>
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 821:	77 24                	ja     847 <free+0x4f>
 823:	8b 45 fc             	mov    -0x4(%ebp),%eax
 826:	8b 00                	mov    (%eax),%eax
 828:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 82b:	77 1a                	ja     847 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	8b 00                	mov    (%eax),%eax
 832:	89 45 fc             	mov    %eax,-0x4(%ebp)
 835:	8b 45 f8             	mov    -0x8(%ebp),%eax
 838:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83b:	76 d4                	jbe    811 <free+0x19>
 83d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 840:	8b 00                	mov    (%eax),%eax
 842:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 845:	76 ca                	jbe    811 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 847:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84a:	8b 40 04             	mov    0x4(%eax),%eax
 84d:	c1 e0 03             	shl    $0x3,%eax
 850:	89 c2                	mov    %eax,%edx
 852:	03 55 f8             	add    -0x8(%ebp),%edx
 855:	8b 45 fc             	mov    -0x4(%ebp),%eax
 858:	8b 00                	mov    (%eax),%eax
 85a:	39 c2                	cmp    %eax,%edx
 85c:	75 24                	jne    882 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 85e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 861:	8b 50 04             	mov    0x4(%eax),%edx
 864:	8b 45 fc             	mov    -0x4(%ebp),%eax
 867:	8b 00                	mov    (%eax),%eax
 869:	8b 40 04             	mov    0x4(%eax),%eax
 86c:	01 c2                	add    %eax,%edx
 86e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 871:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 874:	8b 45 fc             	mov    -0x4(%ebp),%eax
 877:	8b 00                	mov    (%eax),%eax
 879:	8b 10                	mov    (%eax),%edx
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	89 10                	mov    %edx,(%eax)
 880:	eb 0a                	jmp    88c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 882:	8b 45 fc             	mov    -0x4(%ebp),%eax
 885:	8b 10                	mov    (%eax),%edx
 887:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 88c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88f:	8b 40 04             	mov    0x4(%eax),%eax
 892:	c1 e0 03             	shl    $0x3,%eax
 895:	03 45 fc             	add    -0x4(%ebp),%eax
 898:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 89b:	75 20                	jne    8bd <free+0xc5>
    p->s.size += bp->s.size;
 89d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a0:	8b 50 04             	mov    0x4(%eax),%edx
 8a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a6:	8b 40 04             	mov    0x4(%eax),%eax
 8a9:	01 c2                	add    %eax,%edx
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b4:	8b 10                	mov    (%eax),%edx
 8b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b9:	89 10                	mov    %edx,(%eax)
 8bb:	eb 08                	jmp    8c5 <free+0xcd>
  } else
    p->s.ptr = bp;
 8bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8c3:	89 10                	mov    %edx,(%eax)
  freep = p;
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	a3 70 0d 00 00       	mov    %eax,0xd70
}
 8cd:	c9                   	leave  
 8ce:	c3                   	ret    

000008cf <morecore>:

static Header*
morecore(uint nu)
{
 8cf:	55                   	push   %ebp
 8d0:	89 e5                	mov    %esp,%ebp
 8d2:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8d5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8dc:	77 07                	ja     8e5 <morecore+0x16>
    nu = 4096;
 8de:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8e5:	8b 45 08             	mov    0x8(%ebp),%eax
 8e8:	c1 e0 03             	shl    $0x3,%eax
 8eb:	89 04 24             	mov    %eax,(%esp)
 8ee:	e8 61 fc ff ff       	call   554 <sbrk>
 8f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8f6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8fa:	75 07                	jne    903 <morecore+0x34>
    return 0;
 8fc:	b8 00 00 00 00       	mov    $0x0,%eax
 901:	eb 22                	jmp    925 <morecore+0x56>
  hp = (Header*)p;
 903:	8b 45 f4             	mov    -0xc(%ebp),%eax
 906:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 909:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90c:	8b 55 08             	mov    0x8(%ebp),%edx
 90f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 912:	8b 45 f0             	mov    -0x10(%ebp),%eax
 915:	83 c0 08             	add    $0x8,%eax
 918:	89 04 24             	mov    %eax,(%esp)
 91b:	e8 d8 fe ff ff       	call   7f8 <free>
  return freep;
 920:	a1 70 0d 00 00       	mov    0xd70,%eax
}
 925:	c9                   	leave  
 926:	c3                   	ret    

00000927 <malloc>:

void*
malloc(uint nbytes)
{
 927:	55                   	push   %ebp
 928:	89 e5                	mov    %esp,%ebp
 92a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92d:	8b 45 08             	mov    0x8(%ebp),%eax
 930:	83 c0 07             	add    $0x7,%eax
 933:	c1 e8 03             	shr    $0x3,%eax
 936:	83 c0 01             	add    $0x1,%eax
 939:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 93c:	a1 70 0d 00 00       	mov    0xd70,%eax
 941:	89 45 f0             	mov    %eax,-0x10(%ebp)
 944:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 948:	75 23                	jne    96d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 94a:	c7 45 f0 68 0d 00 00 	movl   $0xd68,-0x10(%ebp)
 951:	8b 45 f0             	mov    -0x10(%ebp),%eax
 954:	a3 70 0d 00 00       	mov    %eax,0xd70
 959:	a1 70 0d 00 00       	mov    0xd70,%eax
 95e:	a3 68 0d 00 00       	mov    %eax,0xd68
    base.s.size = 0;
 963:	c7 05 6c 0d 00 00 00 	movl   $0x0,0xd6c
 96a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 970:	8b 00                	mov    (%eax),%eax
 972:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 975:	8b 45 f4             	mov    -0xc(%ebp),%eax
 978:	8b 40 04             	mov    0x4(%eax),%eax
 97b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 97e:	72 4d                	jb     9cd <malloc+0xa6>
      if(p->s.size == nunits)
 980:	8b 45 f4             	mov    -0xc(%ebp),%eax
 983:	8b 40 04             	mov    0x4(%eax),%eax
 986:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 989:	75 0c                	jne    997 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98e:	8b 10                	mov    (%eax),%edx
 990:	8b 45 f0             	mov    -0x10(%ebp),%eax
 993:	89 10                	mov    %edx,(%eax)
 995:	eb 26                	jmp    9bd <malloc+0x96>
      else {
        p->s.size -= nunits;
 997:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99a:	8b 40 04             	mov    0x4(%eax),%eax
 99d:	89 c2                	mov    %eax,%edx
 99f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ab:	8b 40 04             	mov    0x4(%eax),%eax
 9ae:	c1 e0 03             	shl    $0x3,%eax
 9b1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ba:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c0:	a3 70 0d 00 00       	mov    %eax,0xd70
      return (void*)(p + 1);
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	83 c0 08             	add    $0x8,%eax
 9cb:	eb 38                	jmp    a05 <malloc+0xde>
    }
    if(p == freep)
 9cd:	a1 70 0d 00 00       	mov    0xd70,%eax
 9d2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9d5:	75 1b                	jne    9f2 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9da:	89 04 24             	mov    %eax,(%esp)
 9dd:	e8 ed fe ff ff       	call   8cf <morecore>
 9e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9e9:	75 07                	jne    9f2 <malloc+0xcb>
        return 0;
 9eb:	b8 00 00 00 00       	mov    $0x0,%eax
 9f0:	eb 13                	jmp    a05 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fb:	8b 00                	mov    (%eax),%eax
 9fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a00:	e9 70 ff ff ff       	jmp    975 <malloc+0x4e>
}
 a05:	c9                   	leave  
 a06:	c3                   	ret    
