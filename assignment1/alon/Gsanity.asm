
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
   6:	e8 35 05 00 00       	call   540 <getpid>
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
  28:	c7 44 24 04 fc 09 00 	movl   $0x9fc,0x4(%esp)
  2f:	00 
  30:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  37:	e8 fb 05 00 00       	call   637 <printf>
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
  4e:	c7 44 24 04 24 0a 00 	movl   $0xa24,0x4(%esp)
  55:	00 
  56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5d:	e8 d5 05 00 00       	call   637 <printf>
  printf(1, "Father pid is %d\n",getpid());
  62:	e8 d9 04 00 00       	call   540 <getpid>
  67:	89 44 24 08          	mov    %eax,0x8(%esp)
  6b:	c7 44 24 04 32 0a 00 	movl   $0xa32,0x4(%esp)
  72:	00 
  73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7a:	e8 b8 05 00 00       	call   637 <printf>
  sleep(1);
  7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  86:	e8 c5 04 00 00       	call   550 <sleep>

  if(fork() == 0)
  8b:	e8 20 04 00 00       	call   4b0 <fork>
  90:	85 c0                	test   %eax,%eax
  92:	75 0a                	jne    9e <Gsanity+0x56>
  {
    foo();
  94:	e8 67 ff ff ff       	call   0 <foo>
    exit();      
  99:	e8 1a 04 00 00       	call   4b8 <exit>
  }
  foo();
  9e:	e8 5d ff ff ff       	call   0 <foo>
  wait();
  a3:	e8 18 04 00 00       	call   4c0 <wait>
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
  b5:	e8 fe 03 00 00       	call   4b8 <exit>
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
 1f7:	e8 dc 02 00 00       	call   4d8 <read>
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
 255:	e8 a6 02 00 00       	call   500 <open>
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
 277:	e8 9c 02 00 00       	call   518 <fstat>
 27c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 27f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 282:	89 04 24             	mov    %eax,(%esp)
 285:	e8 5e 02 00 00       	call   4e8 <close>
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
strcat(char *dest, const char *p, const char *q)
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
strcat(char *dest, const char *p, const char *q)
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
strcat(char *dest, const char *p, const char *q)
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
 4ab:	5d                   	pop    %ebp
 4ac:	c3                   	ret    
 4ad:	90                   	nop
 4ae:	90                   	nop
 4af:	90                   	nop

000004b0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4b0:	b8 01 00 00 00       	mov    $0x1,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <exit>:
SYSCALL(exit)
 4b8:	b8 02 00 00 00       	mov    $0x2,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <wait>:
SYSCALL(wait)
 4c0:	b8 03 00 00 00       	mov    $0x3,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <wait2>:
SYSCALL(wait2)
 4c8:	b8 16 00 00 00       	mov    $0x16,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <pipe>:
SYSCALL(pipe)
 4d0:	b8 04 00 00 00       	mov    $0x4,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <read>:
SYSCALL(read)
 4d8:	b8 05 00 00 00       	mov    $0x5,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <write>:
SYSCALL(write)
 4e0:	b8 10 00 00 00       	mov    $0x10,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <close>:
SYSCALL(close)
 4e8:	b8 15 00 00 00       	mov    $0x15,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <kill>:
SYSCALL(kill)
 4f0:	b8 06 00 00 00       	mov    $0x6,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <exec>:
SYSCALL(exec)
 4f8:	b8 07 00 00 00       	mov    $0x7,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <open>:
SYSCALL(open)
 500:	b8 0f 00 00 00       	mov    $0xf,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <mknod>:
SYSCALL(mknod)
 508:	b8 11 00 00 00       	mov    $0x11,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <unlink>:
SYSCALL(unlink)
 510:	b8 12 00 00 00       	mov    $0x12,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <fstat>:
SYSCALL(fstat)
 518:	b8 08 00 00 00       	mov    $0x8,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <link>:
SYSCALL(link)
 520:	b8 13 00 00 00       	mov    $0x13,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <mkdir>:
SYSCALL(mkdir)
 528:	b8 14 00 00 00       	mov    $0x14,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <chdir>:
SYSCALL(chdir)
 530:	b8 09 00 00 00       	mov    $0x9,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <dup>:
SYSCALL(dup)
 538:	b8 0a 00 00 00       	mov    $0xa,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <getpid>:
SYSCALL(getpid)
 540:	b8 0b 00 00 00       	mov    $0xb,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <sbrk>:
SYSCALL(sbrk)
 548:	b8 0c 00 00 00       	mov    $0xc,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <sleep>:
SYSCALL(sleep)
 550:	b8 0d 00 00 00       	mov    $0xd,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <uptime>:
SYSCALL(uptime)
 558:	b8 0e 00 00 00       	mov    $0xe,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 560:	55                   	push   %ebp
 561:	89 e5                	mov    %esp,%ebp
 563:	83 ec 28             	sub    $0x28,%esp
 566:	8b 45 0c             	mov    0xc(%ebp),%eax
 569:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 56c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 573:	00 
 574:	8d 45 f4             	lea    -0xc(%ebp),%eax
 577:	89 44 24 04          	mov    %eax,0x4(%esp)
 57b:	8b 45 08             	mov    0x8(%ebp),%eax
 57e:	89 04 24             	mov    %eax,(%esp)
 581:	e8 5a ff ff ff       	call   4e0 <write>
}
 586:	c9                   	leave  
 587:	c3                   	ret    

00000588 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 588:	55                   	push   %ebp
 589:	89 e5                	mov    %esp,%ebp
 58b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 58e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 595:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 599:	74 17                	je     5b2 <printint+0x2a>
 59b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 59f:	79 11                	jns    5b2 <printint+0x2a>
    neg = 1;
 5a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ab:	f7 d8                	neg    %eax
 5ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b0:	eb 06                	jmp    5b8 <printint+0x30>
  } else {
    x = xx;
 5b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c5:	ba 00 00 00 00       	mov    $0x0,%edx
 5ca:	f7 f1                	div    %ecx
 5cc:	89 d0                	mov    %edx,%eax
 5ce:	0f b6 90 48 0d 00 00 	movzbl 0xd48(%eax),%edx
 5d5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5d8:	03 45 f4             	add    -0xc(%ebp),%eax
 5db:	88 10                	mov    %dl,(%eax)
 5dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5e1:	8b 55 10             	mov    0x10(%ebp),%edx
 5e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ea:	ba 00 00 00 00       	mov    $0x0,%edx
 5ef:	f7 75 d4             	divl   -0x2c(%ebp)
 5f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5f9:	75 c4                	jne    5bf <printint+0x37>
  if(neg)
 5fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5ff:	74 2a                	je     62b <printint+0xa3>
    buf[i++] = '-';
 601:	8d 45 dc             	lea    -0x24(%ebp),%eax
 604:	03 45 f4             	add    -0xc(%ebp),%eax
 607:	c6 00 2d             	movb   $0x2d,(%eax)
 60a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 60e:	eb 1b                	jmp    62b <printint+0xa3>
    putc(fd, buf[i]);
 610:	8d 45 dc             	lea    -0x24(%ebp),%eax
 613:	03 45 f4             	add    -0xc(%ebp),%eax
 616:	0f b6 00             	movzbl (%eax),%eax
 619:	0f be c0             	movsbl %al,%eax
 61c:	89 44 24 04          	mov    %eax,0x4(%esp)
 620:	8b 45 08             	mov    0x8(%ebp),%eax
 623:	89 04 24             	mov    %eax,(%esp)
 626:	e8 35 ff ff ff       	call   560 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 62b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 62f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 633:	79 db                	jns    610 <printint+0x88>
    putc(fd, buf[i]);
}
 635:	c9                   	leave  
 636:	c3                   	ret    

00000637 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 637:	55                   	push   %ebp
 638:	89 e5                	mov    %esp,%ebp
 63a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 63d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 644:	8d 45 0c             	lea    0xc(%ebp),%eax
 647:	83 c0 04             	add    $0x4,%eax
 64a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 64d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 654:	e9 7d 01 00 00       	jmp    7d6 <printf+0x19f>
    c = fmt[i] & 0xff;
 659:	8b 55 0c             	mov    0xc(%ebp),%edx
 65c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 65f:	01 d0                	add    %edx,%eax
 661:	0f b6 00             	movzbl (%eax),%eax
 664:	0f be c0             	movsbl %al,%eax
 667:	25 ff 00 00 00       	and    $0xff,%eax
 66c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 66f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 673:	75 2c                	jne    6a1 <printf+0x6a>
      if(c == '%'){
 675:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 679:	75 0c                	jne    687 <printf+0x50>
        state = '%';
 67b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 682:	e9 4b 01 00 00       	jmp    7d2 <printf+0x19b>
      } else {
        putc(fd, c);
 687:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68a:	0f be c0             	movsbl %al,%eax
 68d:	89 44 24 04          	mov    %eax,0x4(%esp)
 691:	8b 45 08             	mov    0x8(%ebp),%eax
 694:	89 04 24             	mov    %eax,(%esp)
 697:	e8 c4 fe ff ff       	call   560 <putc>
 69c:	e9 31 01 00 00       	jmp    7d2 <printf+0x19b>
      }
    } else if(state == '%'){
 6a1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6a5:	0f 85 27 01 00 00    	jne    7d2 <printf+0x19b>
      if(c == 'd'){
 6ab:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6af:	75 2d                	jne    6de <printf+0xa7>
        printint(fd, *ap, 10, 1);
 6b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b4:	8b 00                	mov    (%eax),%eax
 6b6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6bd:	00 
 6be:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6c5:	00 
 6c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ca:	8b 45 08             	mov    0x8(%ebp),%eax
 6cd:	89 04 24             	mov    %eax,(%esp)
 6d0:	e8 b3 fe ff ff       	call   588 <printint>
        ap++;
 6d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d9:	e9 ed 00 00 00       	jmp    7cb <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6de:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6e2:	74 06                	je     6ea <printf+0xb3>
 6e4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6e8:	75 2d                	jne    717 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ed:	8b 00                	mov    (%eax),%eax
 6ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6f6:	00 
 6f7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6fe:	00 
 6ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 703:	8b 45 08             	mov    0x8(%ebp),%eax
 706:	89 04 24             	mov    %eax,(%esp)
 709:	e8 7a fe ff ff       	call   588 <printint>
        ap++;
 70e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 712:	e9 b4 00 00 00       	jmp    7cb <printf+0x194>
      } else if(c == 's'){
 717:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 71b:	75 46                	jne    763 <printf+0x12c>
        s = (char*)*ap;
 71d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 725:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 729:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 72d:	75 27                	jne    756 <printf+0x11f>
          s = "(null)";
 72f:	c7 45 f4 44 0a 00 00 	movl   $0xa44,-0xc(%ebp)
        while(*s != 0){
 736:	eb 1e                	jmp    756 <printf+0x11f>
          putc(fd, *s);
 738:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73b:	0f b6 00             	movzbl (%eax),%eax
 73e:	0f be c0             	movsbl %al,%eax
 741:	89 44 24 04          	mov    %eax,0x4(%esp)
 745:	8b 45 08             	mov    0x8(%ebp),%eax
 748:	89 04 24             	mov    %eax,(%esp)
 74b:	e8 10 fe ff ff       	call   560 <putc>
          s++;
 750:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 754:	eb 01                	jmp    757 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 756:	90                   	nop
 757:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75a:	0f b6 00             	movzbl (%eax),%eax
 75d:	84 c0                	test   %al,%al
 75f:	75 d7                	jne    738 <printf+0x101>
 761:	eb 68                	jmp    7cb <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 763:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 767:	75 1d                	jne    786 <printf+0x14f>
        putc(fd, *ap);
 769:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76c:	8b 00                	mov    (%eax),%eax
 76e:	0f be c0             	movsbl %al,%eax
 771:	89 44 24 04          	mov    %eax,0x4(%esp)
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	89 04 24             	mov    %eax,(%esp)
 77b:	e8 e0 fd ff ff       	call   560 <putc>
        ap++;
 780:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 784:	eb 45                	jmp    7cb <printf+0x194>
      } else if(c == '%'){
 786:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78a:	75 17                	jne    7a3 <printf+0x16c>
        putc(fd, c);
 78c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 78f:	0f be c0             	movsbl %al,%eax
 792:	89 44 24 04          	mov    %eax,0x4(%esp)
 796:	8b 45 08             	mov    0x8(%ebp),%eax
 799:	89 04 24             	mov    %eax,(%esp)
 79c:	e8 bf fd ff ff       	call   560 <putc>
 7a1:	eb 28                	jmp    7cb <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7a3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7aa:	00 
 7ab:	8b 45 08             	mov    0x8(%ebp),%eax
 7ae:	89 04 24             	mov    %eax,(%esp)
 7b1:	e8 aa fd ff ff       	call   560 <putc>
        putc(fd, c);
 7b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b9:	0f be c0             	movsbl %al,%eax
 7bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c0:	8b 45 08             	mov    0x8(%ebp),%eax
 7c3:	89 04 24             	mov    %eax,(%esp)
 7c6:	e8 95 fd ff ff       	call   560 <putc>
      }
      state = 0;
 7cb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7d2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	01 d0                	add    %edx,%eax
 7de:	0f b6 00             	movzbl (%eax),%eax
 7e1:	84 c0                	test   %al,%al
 7e3:	0f 85 70 fe ff ff    	jne    659 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7e9:	c9                   	leave  
 7ea:	c3                   	ret    
 7eb:	90                   	nop

000007ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ec:	55                   	push   %ebp
 7ed:	89 e5                	mov    %esp,%ebp
 7ef:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f2:	8b 45 08             	mov    0x8(%ebp),%eax
 7f5:	83 e8 08             	sub    $0x8,%eax
 7f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fb:	a1 64 0d 00 00       	mov    0xd64,%eax
 800:	89 45 fc             	mov    %eax,-0x4(%ebp)
 803:	eb 24                	jmp    829 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 805:	8b 45 fc             	mov    -0x4(%ebp),%eax
 808:	8b 00                	mov    (%eax),%eax
 80a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 80d:	77 12                	ja     821 <free+0x35>
 80f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 812:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 815:	77 24                	ja     83b <free+0x4f>
 817:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81a:	8b 00                	mov    (%eax),%eax
 81c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 81f:	77 1a                	ja     83b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	89 45 fc             	mov    %eax,-0x4(%ebp)
 829:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 82f:	76 d4                	jbe    805 <free+0x19>
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 839:	76 ca                	jbe    805 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 83b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83e:	8b 40 04             	mov    0x4(%eax),%eax
 841:	c1 e0 03             	shl    $0x3,%eax
 844:	89 c2                	mov    %eax,%edx
 846:	03 55 f8             	add    -0x8(%ebp),%edx
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	8b 00                	mov    (%eax),%eax
 84e:	39 c2                	cmp    %eax,%edx
 850:	75 24                	jne    876 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 852:	8b 45 f8             	mov    -0x8(%ebp),%eax
 855:	8b 50 04             	mov    0x4(%eax),%edx
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
 85d:	8b 40 04             	mov    0x4(%eax),%eax
 860:	01 c2                	add    %eax,%edx
 862:	8b 45 f8             	mov    -0x8(%ebp),%eax
 865:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 868:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86b:	8b 00                	mov    (%eax),%eax
 86d:	8b 10                	mov    (%eax),%edx
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	89 10                	mov    %edx,(%eax)
 874:	eb 0a                	jmp    880 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 876:	8b 45 fc             	mov    -0x4(%ebp),%eax
 879:	8b 10                	mov    (%eax),%edx
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 880:	8b 45 fc             	mov    -0x4(%ebp),%eax
 883:	8b 40 04             	mov    0x4(%eax),%eax
 886:	c1 e0 03             	shl    $0x3,%eax
 889:	03 45 fc             	add    -0x4(%ebp),%eax
 88c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 88f:	75 20                	jne    8b1 <free+0xc5>
    p->s.size += bp->s.size;
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
 894:	8b 50 04             	mov    0x4(%eax),%edx
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	8b 40 04             	mov    0x4(%eax),%eax
 89d:	01 c2                	add    %eax,%edx
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a8:	8b 10                	mov    (%eax),%edx
 8aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ad:	89 10                	mov    %edx,(%eax)
 8af:	eb 08                	jmp    8b9 <free+0xcd>
  } else
    p->s.ptr = bp;
 8b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8b7:	89 10                	mov    %edx,(%eax)
  freep = p;
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	a3 64 0d 00 00       	mov    %eax,0xd64
}
 8c1:	c9                   	leave  
 8c2:	c3                   	ret    

000008c3 <morecore>:

static Header*
morecore(uint nu)
{
 8c3:	55                   	push   %ebp
 8c4:	89 e5                	mov    %esp,%ebp
 8c6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8c9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8d0:	77 07                	ja     8d9 <morecore+0x16>
    nu = 4096;
 8d2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8d9:	8b 45 08             	mov    0x8(%ebp),%eax
 8dc:	c1 e0 03             	shl    $0x3,%eax
 8df:	89 04 24             	mov    %eax,(%esp)
 8e2:	e8 61 fc ff ff       	call   548 <sbrk>
 8e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ea:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8ee:	75 07                	jne    8f7 <morecore+0x34>
    return 0;
 8f0:	b8 00 00 00 00       	mov    $0x0,%eax
 8f5:	eb 22                	jmp    919 <morecore+0x56>
  hp = (Header*)p;
 8f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 900:	8b 55 08             	mov    0x8(%ebp),%edx
 903:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 906:	8b 45 f0             	mov    -0x10(%ebp),%eax
 909:	83 c0 08             	add    $0x8,%eax
 90c:	89 04 24             	mov    %eax,(%esp)
 90f:	e8 d8 fe ff ff       	call   7ec <free>
  return freep;
 914:	a1 64 0d 00 00       	mov    0xd64,%eax
}
 919:	c9                   	leave  
 91a:	c3                   	ret    

0000091b <malloc>:

void*
malloc(uint nbytes)
{
 91b:	55                   	push   %ebp
 91c:	89 e5                	mov    %esp,%ebp
 91e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 921:	8b 45 08             	mov    0x8(%ebp),%eax
 924:	83 c0 07             	add    $0x7,%eax
 927:	c1 e8 03             	shr    $0x3,%eax
 92a:	83 c0 01             	add    $0x1,%eax
 92d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 930:	a1 64 0d 00 00       	mov    0xd64,%eax
 935:	89 45 f0             	mov    %eax,-0x10(%ebp)
 938:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 93c:	75 23                	jne    961 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 93e:	c7 45 f0 5c 0d 00 00 	movl   $0xd5c,-0x10(%ebp)
 945:	8b 45 f0             	mov    -0x10(%ebp),%eax
 948:	a3 64 0d 00 00       	mov    %eax,0xd64
 94d:	a1 64 0d 00 00       	mov    0xd64,%eax
 952:	a3 5c 0d 00 00       	mov    %eax,0xd5c
    base.s.size = 0;
 957:	c7 05 60 0d 00 00 00 	movl   $0x0,0xd60
 95e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 961:	8b 45 f0             	mov    -0x10(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 969:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96c:	8b 40 04             	mov    0x4(%eax),%eax
 96f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 972:	72 4d                	jb     9c1 <malloc+0xa6>
      if(p->s.size == nunits)
 974:	8b 45 f4             	mov    -0xc(%ebp),%eax
 977:	8b 40 04             	mov    0x4(%eax),%eax
 97a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 97d:	75 0c                	jne    98b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 97f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 982:	8b 10                	mov    (%eax),%edx
 984:	8b 45 f0             	mov    -0x10(%ebp),%eax
 987:	89 10                	mov    %edx,(%eax)
 989:	eb 26                	jmp    9b1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98e:	8b 40 04             	mov    0x4(%eax),%eax
 991:	89 c2                	mov    %eax,%edx
 993:	2b 55 ec             	sub    -0x14(%ebp),%edx
 996:	8b 45 f4             	mov    -0xc(%ebp),%eax
 999:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 99c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99f:	8b 40 04             	mov    0x4(%eax),%eax
 9a2:	c1 e0 03             	shl    $0x3,%eax
 9a5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ae:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b4:	a3 64 0d 00 00       	mov    %eax,0xd64
      return (void*)(p + 1);
 9b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bc:	83 c0 08             	add    $0x8,%eax
 9bf:	eb 38                	jmp    9f9 <malloc+0xde>
    }
    if(p == freep)
 9c1:	a1 64 0d 00 00       	mov    0xd64,%eax
 9c6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9c9:	75 1b                	jne    9e6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9ce:	89 04 24             	mov    %eax,(%esp)
 9d1:	e8 ed fe ff ff       	call   8c3 <morecore>
 9d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9dd:	75 07                	jne    9e6 <malloc+0xcb>
        return 0;
 9df:	b8 00 00 00 00       	mov    $0x0,%eax
 9e4:	eb 13                	jmp    9f9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ef:	8b 00                	mov    (%eax),%eax
 9f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9f4:	e9 70 ff ff ff       	jmp    969 <malloc+0x4e>
}
 9f9:	c9                   	leave  
 9fa:	c3                   	ret    
