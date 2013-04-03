
_waittest:     file format elf32-i386


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
  for (i=0;i<100;i++)
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
   d:	eb 1f                	jmp    2e <foo+0x2e>
     printf(2, "wait test %d\n",i);
   f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  12:	89 44 24 08          	mov    %eax,0x8(%esp)
  16:	c7 44 24 04 3b 0a 00 	movl   $0xa3b,0x4(%esp)
  1d:	00 
  1e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  25:	e8 4d 06 00 00       	call   677 <printf>

void
foo()
{
  int i;
  for (i=0;i<100;i++)
  2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  2e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
  32:	7e db                	jle    f <foo+0xf>
     printf(2, "wait test %d\n",i);
  sleep(20);
  34:	c7 04 24 14 00 00 00 	movl   $0x14,(%esp)
  3b:	e8 50 05 00 00       	call   590 <sleep>
  for (i=0;i<100;i++)
  40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  47:	eb 1f                	jmp    68 <foo+0x68>
     printf(2, "wait test %d\n",i);
  49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  50:	c7 44 24 04 3b 0a 00 	movl   $0xa3b,0x4(%esp)
  57:	00 
  58:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  5f:	e8 13 06 00 00       	call   677 <printf>
{
  int i;
  for (i=0;i<100;i++)
     printf(2, "wait test %d\n",i);
  sleep(20);
  for (i=0;i<100;i++)
  64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  68:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
  6c:	7e db                	jle    49 <foo+0x49>
     printf(2, "wait test %d\n",i);

}
  6e:	c9                   	leave  
  6f:	c3                   	ret    

00000070 <waittest>:

void
waittest(void)
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	83 ec 28             	sub    $0x28,%esp
  int wTime;
  int rTime;
  int pid;
  printf(1, "wait test\n");
  76:	c7 44 24 04 49 0a 00 	movl   $0xa49,0x4(%esp)
  7d:	00 
  7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  85:	e8 ed 05 00 00       	call   677 <printf>


    pid = fork();
  8a:	e8 61 04 00 00       	call   4f0 <fork>
  8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid == 0)
  92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  96:	75 0a                	jne    a2 <waittest+0x32>
    {
      foo();
  98:	e8 63 ff ff ff       	call   0 <foo>
      exit();      
  9d:	e8 56 04 00 00       	call   4f8 <exit>
    }
    wait2(&wTime,&rTime);
  a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  ac:	89 04 24             	mov    %eax,(%esp)
  af:	e8 54 04 00 00       	call   508 <wait2>
     printf(1, "hi \n");
  b4:	c7 44 24 04 54 0a 00 	movl   $0xa54,0x4(%esp)
  bb:	00 
  bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c3:	e8 af 05 00 00       	call   677 <printf>
    printf(1, "wTime: %d rTime: %d \n",wTime,rTime);
  c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  d6:	c7 44 24 04 59 0a 00 	movl   $0xa59,0x4(%esp)
  dd:	00 
  de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e5:	e8 8d 05 00 00       	call   677 <printf>

}
  ea:	c9                   	leave  
  eb:	c3                   	ret    

000000ec <main>:
int
main(void)
{
  ec:	55                   	push   %ebp
  ed:	89 e5                	mov    %esp,%ebp
  ef:	83 e4 f0             	and    $0xfffffff0,%esp
  waittest();
  f2:	e8 79 ff ff ff       	call   70 <waittest>
  exit();
  f7:	e8 fc 03 00 00       	call   4f8 <exit>

000000fc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	57                   	push   %edi
 100:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 101:	8b 4d 08             	mov    0x8(%ebp),%ecx
 104:	8b 55 10             	mov    0x10(%ebp),%edx
 107:	8b 45 0c             	mov    0xc(%ebp),%eax
 10a:	89 cb                	mov    %ecx,%ebx
 10c:	89 df                	mov    %ebx,%edi
 10e:	89 d1                	mov    %edx,%ecx
 110:	fc                   	cld    
 111:	f3 aa                	rep stos %al,%es:(%edi)
 113:	89 ca                	mov    %ecx,%edx
 115:	89 fb                	mov    %edi,%ebx
 117:	89 5d 08             	mov    %ebx,0x8(%ebp)
 11a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 11d:	5b                   	pop    %ebx
 11e:	5f                   	pop    %edi
 11f:	5d                   	pop    %ebp
 120:	c3                   	ret    

00000121 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 121:	55                   	push   %ebp
 122:	89 e5                	mov    %esp,%ebp
 124:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 127:	8b 45 08             	mov    0x8(%ebp),%eax
 12a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 12d:	90                   	nop
 12e:	8b 45 0c             	mov    0xc(%ebp),%eax
 131:	0f b6 10             	movzbl (%eax),%edx
 134:	8b 45 08             	mov    0x8(%ebp),%eax
 137:	88 10                	mov    %dl,(%eax)
 139:	8b 45 08             	mov    0x8(%ebp),%eax
 13c:	0f b6 00             	movzbl (%eax),%eax
 13f:	84 c0                	test   %al,%al
 141:	0f 95 c0             	setne  %al
 144:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 148:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 14c:	84 c0                	test   %al,%al
 14e:	75 de                	jne    12e <strcpy+0xd>
    ;
  return os;
 150:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 153:	c9                   	leave  
 154:	c3                   	ret    

00000155 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 155:	55                   	push   %ebp
 156:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 158:	eb 08                	jmp    162 <strcmp+0xd>
    p++, q++;
 15a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 15e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 162:	8b 45 08             	mov    0x8(%ebp),%eax
 165:	0f b6 00             	movzbl (%eax),%eax
 168:	84 c0                	test   %al,%al
 16a:	74 10                	je     17c <strcmp+0x27>
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	0f b6 10             	movzbl (%eax),%edx
 172:	8b 45 0c             	mov    0xc(%ebp),%eax
 175:	0f b6 00             	movzbl (%eax),%eax
 178:	38 c2                	cmp    %al,%dl
 17a:	74 de                	je     15a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	0f b6 00             	movzbl (%eax),%eax
 182:	0f b6 d0             	movzbl %al,%edx
 185:	8b 45 0c             	mov    0xc(%ebp),%eax
 188:	0f b6 00             	movzbl (%eax),%eax
 18b:	0f b6 c0             	movzbl %al,%eax
 18e:	89 d1                	mov    %edx,%ecx
 190:	29 c1                	sub    %eax,%ecx
 192:	89 c8                	mov    %ecx,%eax
}
 194:	5d                   	pop    %ebp
 195:	c3                   	ret    

00000196 <strlen>:

uint
strlen(char *s)
{
 196:	55                   	push   %ebp
 197:	89 e5                	mov    %esp,%ebp
 199:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 19c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1a3:	eb 04                	jmp    1a9 <strlen+0x13>
 1a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1ac:	03 45 08             	add    0x8(%ebp),%eax
 1af:	0f b6 00             	movzbl (%eax),%eax
 1b2:	84 c0                	test   %al,%al
 1b4:	75 ef                	jne    1a5 <strlen+0xf>
  return n;
 1b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1b9:	c9                   	leave  
 1ba:	c3                   	ret    

000001bb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1bb:	55                   	push   %ebp
 1bc:	89 e5                	mov    %esp,%ebp
 1be:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1c1:	8b 45 10             	mov    0x10(%ebp),%eax
 1c4:	89 44 24 08          	mov    %eax,0x8(%esp)
 1c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	89 04 24             	mov    %eax,(%esp)
 1d5:	e8 22 ff ff ff       	call   fc <stosb>
  return dst;
 1da:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1dd:	c9                   	leave  
 1de:	c3                   	ret    

000001df <strchr>:

char*
strchr(const char *s, char c)
{
 1df:	55                   	push   %ebp
 1e0:	89 e5                	mov    %esp,%ebp
 1e2:	83 ec 04             	sub    $0x4,%esp
 1e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1eb:	eb 14                	jmp    201 <strchr+0x22>
    if(*s == c)
 1ed:	8b 45 08             	mov    0x8(%ebp),%eax
 1f0:	0f b6 00             	movzbl (%eax),%eax
 1f3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1f6:	75 05                	jne    1fd <strchr+0x1e>
      return (char*)s;
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	eb 13                	jmp    210 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	0f b6 00             	movzbl (%eax),%eax
 207:	84 c0                	test   %al,%al
 209:	75 e2                	jne    1ed <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 20b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 210:	c9                   	leave  
 211:	c3                   	ret    

00000212 <gets>:

char*
gets(char *buf, int max)
{
 212:	55                   	push   %ebp
 213:	89 e5                	mov    %esp,%ebp
 215:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 218:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 21f:	eb 44                	jmp    265 <gets+0x53>
    cc = read(0, &c, 1);
 221:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 228:	00 
 229:	8d 45 ef             	lea    -0x11(%ebp),%eax
 22c:	89 44 24 04          	mov    %eax,0x4(%esp)
 230:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 237:	e8 dc 02 00 00       	call   518 <read>
 23c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 23f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 243:	7e 2d                	jle    272 <gets+0x60>
      break;
    buf[i++] = c;
 245:	8b 45 f4             	mov    -0xc(%ebp),%eax
 248:	03 45 08             	add    0x8(%ebp),%eax
 24b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 24f:	88 10                	mov    %dl,(%eax)
 251:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 255:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 259:	3c 0a                	cmp    $0xa,%al
 25b:	74 16                	je     273 <gets+0x61>
 25d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 261:	3c 0d                	cmp    $0xd,%al
 263:	74 0e                	je     273 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 265:	8b 45 f4             	mov    -0xc(%ebp),%eax
 268:	83 c0 01             	add    $0x1,%eax
 26b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 26e:	7c b1                	jl     221 <gets+0xf>
 270:	eb 01                	jmp    273 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 272:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 273:	8b 45 f4             	mov    -0xc(%ebp),%eax
 276:	03 45 08             	add    0x8(%ebp),%eax
 279:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27f:	c9                   	leave  
 280:	c3                   	ret    

00000281 <stat>:

int
stat(char *n, struct stat *st)
{
 281:	55                   	push   %ebp
 282:	89 e5                	mov    %esp,%ebp
 284:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 287:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 28e:	00 
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	89 04 24             	mov    %eax,(%esp)
 295:	e8 a6 02 00 00       	call   540 <open>
 29a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 29d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a1:	79 07                	jns    2aa <stat+0x29>
    return -1;
 2a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2a8:	eb 23                	jmp    2cd <stat+0x4c>
  r = fstat(fd, st);
 2aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b4:	89 04 24             	mov    %eax,(%esp)
 2b7:	e8 9c 02 00 00       	call   558 <fstat>
 2bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c2:	89 04 24             	mov    %eax,(%esp)
 2c5:	e8 5e 02 00 00       	call   528 <close>
  return r;
 2ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2cd:	c9                   	leave  
 2ce:	c3                   	ret    

000002cf <atoi>:

int
atoi(const char *s)
{
 2cf:	55                   	push   %ebp
 2d0:	89 e5                	mov    %esp,%ebp
 2d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2dc:	eb 23                	jmp    301 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2de:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e1:	89 d0                	mov    %edx,%eax
 2e3:	c1 e0 02             	shl    $0x2,%eax
 2e6:	01 d0                	add    %edx,%eax
 2e8:	01 c0                	add    %eax,%eax
 2ea:	89 c2                	mov    %eax,%edx
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	0f b6 00             	movzbl (%eax),%eax
 2f2:	0f be c0             	movsbl %al,%eax
 2f5:	01 d0                	add    %edx,%eax
 2f7:	83 e8 30             	sub    $0x30,%eax
 2fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 2fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	0f b6 00             	movzbl (%eax),%eax
 307:	3c 2f                	cmp    $0x2f,%al
 309:	7e 0a                	jle    315 <atoi+0x46>
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	0f b6 00             	movzbl (%eax),%eax
 311:	3c 39                	cmp    $0x39,%al
 313:	7e c9                	jle    2de <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 315:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 318:	c9                   	leave  
 319:	c3                   	ret    

0000031a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 31a:	55                   	push   %ebp
 31b:	89 e5                	mov    %esp,%ebp
 31d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 320:	8b 45 08             	mov    0x8(%ebp),%eax
 323:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 326:	8b 45 0c             	mov    0xc(%ebp),%eax
 329:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 32c:	eb 13                	jmp    341 <memmove+0x27>
    *dst++ = *src++;
 32e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 331:	0f b6 10             	movzbl (%eax),%edx
 334:	8b 45 fc             	mov    -0x4(%ebp),%eax
 337:	88 10                	mov    %dl,(%eax)
 339:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 33d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 341:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 345:	0f 9f c0             	setg   %al
 348:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 34c:	84 c0                	test   %al,%al
 34e:	75 de                	jne    32e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 350:	8b 45 08             	mov    0x8(%ebp),%eax
}
 353:	c9                   	leave  
 354:	c3                   	ret    

00000355 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 355:	55                   	push   %ebp
 356:	89 e5                	mov    %esp,%ebp
 358:	83 ec 38             	sub    $0x38,%esp
 35b:	8b 45 10             	mov    0x10(%ebp),%eax
 35e:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 361:	8b 45 14             	mov    0x14(%ebp),%eax
 364:	8b 00                	mov    (%eax),%eax
 366:	89 45 f4             	mov    %eax,-0xc(%ebp)
 369:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 370:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 374:	74 06                	je     37c <strtok+0x27>
 376:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 37a:	75 54                	jne    3d0 <strtok+0x7b>
    return match;
 37c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 37f:	eb 6e                	jmp    3ef <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 381:	8b 45 f4             	mov    -0xc(%ebp),%eax
 384:	03 45 0c             	add    0xc(%ebp),%eax
 387:	0f b6 00             	movzbl (%eax),%eax
 38a:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 38d:	74 06                	je     395 <strtok+0x40>
      {
	index++;
 38f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 393:	eb 3c                	jmp    3d1 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 395:	8b 45 14             	mov    0x14(%ebp),%eax
 398:	8b 00                	mov    (%eax),%eax
 39a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 39d:	29 c2                	sub    %eax,%edx
 39f:	8b 45 14             	mov    0x14(%ebp),%eax
 3a2:	8b 00                	mov    (%eax),%eax
 3a4:	03 45 0c             	add    0xc(%ebp),%eax
 3a7:	89 54 24 08          	mov    %edx,0x8(%esp)
 3ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	89 04 24             	mov    %eax,(%esp)
 3b5:	e8 37 00 00 00       	call   3f1 <strncpy>
 3ba:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	84 c0                	test   %al,%al
 3c5:	74 19                	je     3e0 <strtok+0x8b>
	  match = 1;
 3c7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 3ce:	eb 10                	jmp    3e0 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 3d0:	90                   	nop
 3d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d4:	03 45 0c             	add    0xc(%ebp),%eax
 3d7:	0f b6 00             	movzbl (%eax),%eax
 3da:	84 c0                	test   %al,%al
 3dc:	75 a3                	jne    381 <strtok+0x2c>
 3de:	eb 01                	jmp    3e1 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 3e0:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 3e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e4:	8d 50 01             	lea    0x1(%eax),%edx
 3e7:	8b 45 14             	mov    0x14(%ebp),%eax
 3ea:	89 10                	mov    %edx,(%eax)
  return match;
 3ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3ef:	c9                   	leave  
 3f0:	c3                   	ret    

000003f1 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 3f1:	55                   	push   %ebp
 3f2:	89 e5                	mov    %esp,%ebp
 3f4:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 3f7:	8b 45 08             	mov    0x8(%ebp),%eax
 3fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 3fd:	90                   	nop
 3fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 402:	0f 9f c0             	setg   %al
 405:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 409:	84 c0                	test   %al,%al
 40b:	74 30                	je     43d <strncpy+0x4c>
 40d:	8b 45 0c             	mov    0xc(%ebp),%eax
 410:	0f b6 10             	movzbl (%eax),%edx
 413:	8b 45 08             	mov    0x8(%ebp),%eax
 416:	88 10                	mov    %dl,(%eax)
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	0f b6 00             	movzbl (%eax),%eax
 41e:	84 c0                	test   %al,%al
 420:	0f 95 c0             	setne  %al
 423:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 427:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 42b:	84 c0                	test   %al,%al
 42d:	75 cf                	jne    3fe <strncpy+0xd>
    ;
  while(n-- > 0)
 42f:	eb 0c                	jmp    43d <strncpy+0x4c>
    *s++ = 0;
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	c6 00 00             	movb   $0x0,(%eax)
 437:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43b:	eb 01                	jmp    43e <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 43d:	90                   	nop
 43e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 442:	0f 9f c0             	setg   %al
 445:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 449:	84 c0                	test   %al,%al
 44b:	75 e4                	jne    431 <strncpy+0x40>
    *s++ = 0;
  return os;
 44d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 450:	c9                   	leave  
 451:	c3                   	ret    

00000452 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 452:	55                   	push   %ebp
 453:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 455:	eb 0c                	jmp    463 <strncmp+0x11>
    n--, p++, q++;
 457:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 45b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 463:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 467:	74 1a                	je     483 <strncmp+0x31>
 469:	8b 45 08             	mov    0x8(%ebp),%eax
 46c:	0f b6 00             	movzbl (%eax),%eax
 46f:	84 c0                	test   %al,%al
 471:	74 10                	je     483 <strncmp+0x31>
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	0f b6 10             	movzbl (%eax),%edx
 479:	8b 45 0c             	mov    0xc(%ebp),%eax
 47c:	0f b6 00             	movzbl (%eax),%eax
 47f:	38 c2                	cmp    %al,%dl
 481:	74 d4                	je     457 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 483:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 487:	75 07                	jne    490 <strncmp+0x3e>
    return 0;
 489:	b8 00 00 00 00       	mov    $0x0,%eax
 48e:	eb 18                	jmp    4a8 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 490:	8b 45 08             	mov    0x8(%ebp),%eax
 493:	0f b6 00             	movzbl (%eax),%eax
 496:	0f b6 d0             	movzbl %al,%edx
 499:	8b 45 0c             	mov    0xc(%ebp),%eax
 49c:	0f b6 00             	movzbl (%eax),%eax
 49f:	0f b6 c0             	movzbl %al,%eax
 4a2:	89 d1                	mov    %edx,%ecx
 4a4:	29 c1                	sub    %eax,%ecx
 4a6:	89 c8                	mov    %ecx,%eax
}
 4a8:	5d                   	pop    %ebp
 4a9:	c3                   	ret    

000004aa <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 4aa:	55                   	push   %ebp
 4ab:	89 e5                	mov    %esp,%ebp
  while(*p){
 4ad:	eb 13                	jmp    4c2 <strcat+0x18>
    *dest++ = *p++;
 4af:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b2:	0f b6 10             	movzbl (%eax),%edx
 4b5:	8b 45 08             	mov    0x8(%ebp),%eax
 4b8:	88 10                	mov    %dl,(%eax)
 4ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 4c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c5:	0f b6 00             	movzbl (%eax),%eax
 4c8:	84 c0                	test   %al,%al
 4ca:	75 e3                	jne    4af <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 4cc:	eb 13                	jmp    4e1 <strcat+0x37>
    *dest++ = *q++;
 4ce:	8b 45 10             	mov    0x10(%ebp),%eax
 4d1:	0f b6 10             	movzbl (%eax),%edx
 4d4:	8b 45 08             	mov    0x8(%ebp),%eax
 4d7:	88 10                	mov    %dl,(%eax)
 4d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4dd:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 4e1:	8b 45 10             	mov    0x10(%ebp),%eax
 4e4:	0f b6 00             	movzbl (%eax),%eax
 4e7:	84 c0                	test   %al,%al
 4e9:	75 e3                	jne    4ce <strcat+0x24>
    *dest++ = *q++;
  }  
 4eb:	5d                   	pop    %ebp
 4ec:	c3                   	ret    
 4ed:	90                   	nop
 4ee:	90                   	nop
 4ef:	90                   	nop

000004f0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4f0:	b8 01 00 00 00       	mov    $0x1,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <exit>:
SYSCALL(exit)
 4f8:	b8 02 00 00 00       	mov    $0x2,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <wait>:
SYSCALL(wait)
 500:	b8 03 00 00 00       	mov    $0x3,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <wait2>:
SYSCALL(wait2)
 508:	b8 16 00 00 00       	mov    $0x16,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <pipe>:
SYSCALL(pipe)
 510:	b8 04 00 00 00       	mov    $0x4,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <read>:
SYSCALL(read)
 518:	b8 05 00 00 00       	mov    $0x5,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <write>:
SYSCALL(write)
 520:	b8 10 00 00 00       	mov    $0x10,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <close>:
SYSCALL(close)
 528:	b8 15 00 00 00       	mov    $0x15,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <kill>:
SYSCALL(kill)
 530:	b8 06 00 00 00       	mov    $0x6,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <exec>:
SYSCALL(exec)
 538:	b8 07 00 00 00       	mov    $0x7,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <open>:
SYSCALL(open)
 540:	b8 0f 00 00 00       	mov    $0xf,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <mknod>:
SYSCALL(mknod)
 548:	b8 11 00 00 00       	mov    $0x11,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <unlink>:
SYSCALL(unlink)
 550:	b8 12 00 00 00       	mov    $0x12,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <fstat>:
SYSCALL(fstat)
 558:	b8 08 00 00 00       	mov    $0x8,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <link>:
SYSCALL(link)
 560:	b8 13 00 00 00       	mov    $0x13,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <mkdir>:
SYSCALL(mkdir)
 568:	b8 14 00 00 00       	mov    $0x14,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <chdir>:
SYSCALL(chdir)
 570:	b8 09 00 00 00       	mov    $0x9,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <dup>:
SYSCALL(dup)
 578:	b8 0a 00 00 00       	mov    $0xa,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <getpid>:
SYSCALL(getpid)
 580:	b8 0b 00 00 00       	mov    $0xb,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <sbrk>:
SYSCALL(sbrk)
 588:	b8 0c 00 00 00       	mov    $0xc,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <sleep>:
SYSCALL(sleep)
 590:	b8 0d 00 00 00       	mov    $0xd,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <uptime>:
SYSCALL(uptime)
 598:	b8 0e 00 00 00       	mov    $0xe,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5a0:	55                   	push   %ebp
 5a1:	89 e5                	mov    %esp,%ebp
 5a3:	83 ec 28             	sub    $0x28,%esp
 5a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5b3:	00 
 5b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	89 04 24             	mov    %eax,(%esp)
 5c1:	e8 5a ff ff ff       	call   520 <write>
}
 5c6:	c9                   	leave  
 5c7:	c3                   	ret    

000005c8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5c8:	55                   	push   %ebp
 5c9:	89 e5                	mov    %esp,%ebp
 5cb:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5d5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5d9:	74 17                	je     5f2 <printint+0x2a>
 5db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5df:	79 11                	jns    5f2 <printint+0x2a>
    neg = 1;
 5e1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5eb:	f7 d8                	neg    %eax
 5ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f0:	eb 06                	jmp    5f8 <printint+0x30>
  } else {
    x = xx;
 5f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
 602:	8b 45 ec             	mov    -0x14(%ebp),%eax
 605:	ba 00 00 00 00       	mov    $0x0,%edx
 60a:	f7 f1                	div    %ecx
 60c:	89 d0                	mov    %edx,%eax
 60e:	0f b6 90 74 0d 00 00 	movzbl 0xd74(%eax),%edx
 615:	8d 45 dc             	lea    -0x24(%ebp),%eax
 618:	03 45 f4             	add    -0xc(%ebp),%eax
 61b:	88 10                	mov    %dl,(%eax)
 61d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 621:	8b 55 10             	mov    0x10(%ebp),%edx
 624:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 627:	8b 45 ec             	mov    -0x14(%ebp),%eax
 62a:	ba 00 00 00 00       	mov    $0x0,%edx
 62f:	f7 75 d4             	divl   -0x2c(%ebp)
 632:	89 45 ec             	mov    %eax,-0x14(%ebp)
 635:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 639:	75 c4                	jne    5ff <printint+0x37>
  if(neg)
 63b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 63f:	74 2a                	je     66b <printint+0xa3>
    buf[i++] = '-';
 641:	8d 45 dc             	lea    -0x24(%ebp),%eax
 644:	03 45 f4             	add    -0xc(%ebp),%eax
 647:	c6 00 2d             	movb   $0x2d,(%eax)
 64a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 64e:	eb 1b                	jmp    66b <printint+0xa3>
    putc(fd, buf[i]);
 650:	8d 45 dc             	lea    -0x24(%ebp),%eax
 653:	03 45 f4             	add    -0xc(%ebp),%eax
 656:	0f b6 00             	movzbl (%eax),%eax
 659:	0f be c0             	movsbl %al,%eax
 65c:	89 44 24 04          	mov    %eax,0x4(%esp)
 660:	8b 45 08             	mov    0x8(%ebp),%eax
 663:	89 04 24             	mov    %eax,(%esp)
 666:	e8 35 ff ff ff       	call   5a0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 66b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 66f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 673:	79 db                	jns    650 <printint+0x88>
    putc(fd, buf[i]);
}
 675:	c9                   	leave  
 676:	c3                   	ret    

00000677 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 677:	55                   	push   %ebp
 678:	89 e5                	mov    %esp,%ebp
 67a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 67d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 684:	8d 45 0c             	lea    0xc(%ebp),%eax
 687:	83 c0 04             	add    $0x4,%eax
 68a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 68d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 694:	e9 7d 01 00 00       	jmp    816 <printf+0x19f>
    c = fmt[i] & 0xff;
 699:	8b 55 0c             	mov    0xc(%ebp),%edx
 69c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 69f:	01 d0                	add    %edx,%eax
 6a1:	0f b6 00             	movzbl (%eax),%eax
 6a4:	0f be c0             	movsbl %al,%eax
 6a7:	25 ff 00 00 00       	and    $0xff,%eax
 6ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6b3:	75 2c                	jne    6e1 <printf+0x6a>
      if(c == '%'){
 6b5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6b9:	75 0c                	jne    6c7 <printf+0x50>
        state = '%';
 6bb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6c2:	e9 4b 01 00 00       	jmp    812 <printf+0x19b>
      } else {
        putc(fd, c);
 6c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ca:	0f be c0             	movsbl %al,%eax
 6cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d1:	8b 45 08             	mov    0x8(%ebp),%eax
 6d4:	89 04 24             	mov    %eax,(%esp)
 6d7:	e8 c4 fe ff ff       	call   5a0 <putc>
 6dc:	e9 31 01 00 00       	jmp    812 <printf+0x19b>
      }
    } else if(state == '%'){
 6e1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6e5:	0f 85 27 01 00 00    	jne    812 <printf+0x19b>
      if(c == 'd'){
 6eb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6ef:	75 2d                	jne    71e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 6f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6fd:	00 
 6fe:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 705:	00 
 706:	89 44 24 04          	mov    %eax,0x4(%esp)
 70a:	8b 45 08             	mov    0x8(%ebp),%eax
 70d:	89 04 24             	mov    %eax,(%esp)
 710:	e8 b3 fe ff ff       	call   5c8 <printint>
        ap++;
 715:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 719:	e9 ed 00 00 00       	jmp    80b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 71e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 722:	74 06                	je     72a <printf+0xb3>
 724:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 728:	75 2d                	jne    757 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 72a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72d:	8b 00                	mov    (%eax),%eax
 72f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 736:	00 
 737:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 73e:	00 
 73f:	89 44 24 04          	mov    %eax,0x4(%esp)
 743:	8b 45 08             	mov    0x8(%ebp),%eax
 746:	89 04 24             	mov    %eax,(%esp)
 749:	e8 7a fe ff ff       	call   5c8 <printint>
        ap++;
 74e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 752:	e9 b4 00 00 00       	jmp    80b <printf+0x194>
      } else if(c == 's'){
 757:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 75b:	75 46                	jne    7a3 <printf+0x12c>
        s = (char*)*ap;
 75d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 760:	8b 00                	mov    (%eax),%eax
 762:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 765:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 769:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 76d:	75 27                	jne    796 <printf+0x11f>
          s = "(null)";
 76f:	c7 45 f4 6f 0a 00 00 	movl   $0xa6f,-0xc(%ebp)
        while(*s != 0){
 776:	eb 1e                	jmp    796 <printf+0x11f>
          putc(fd, *s);
 778:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77b:	0f b6 00             	movzbl (%eax),%eax
 77e:	0f be c0             	movsbl %al,%eax
 781:	89 44 24 04          	mov    %eax,0x4(%esp)
 785:	8b 45 08             	mov    0x8(%ebp),%eax
 788:	89 04 24             	mov    %eax,(%esp)
 78b:	e8 10 fe ff ff       	call   5a0 <putc>
          s++;
 790:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 794:	eb 01                	jmp    797 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 796:	90                   	nop
 797:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79a:	0f b6 00             	movzbl (%eax),%eax
 79d:	84 c0                	test   %al,%al
 79f:	75 d7                	jne    778 <printf+0x101>
 7a1:	eb 68                	jmp    80b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7a3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7a7:	75 1d                	jne    7c6 <printf+0x14f>
        putc(fd, *ap);
 7a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	0f be c0             	movsbl %al,%eax
 7b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b5:	8b 45 08             	mov    0x8(%ebp),%eax
 7b8:	89 04 24             	mov    %eax,(%esp)
 7bb:	e8 e0 fd ff ff       	call   5a0 <putc>
        ap++;
 7c0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c4:	eb 45                	jmp    80b <printf+0x194>
      } else if(c == '%'){
 7c6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ca:	75 17                	jne    7e3 <printf+0x16c>
        putc(fd, c);
 7cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7cf:	0f be c0             	movsbl %al,%eax
 7d2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d6:	8b 45 08             	mov    0x8(%ebp),%eax
 7d9:	89 04 24             	mov    %eax,(%esp)
 7dc:	e8 bf fd ff ff       	call   5a0 <putc>
 7e1:	eb 28                	jmp    80b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7e3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7ea:	00 
 7eb:	8b 45 08             	mov    0x8(%ebp),%eax
 7ee:	89 04 24             	mov    %eax,(%esp)
 7f1:	e8 aa fd ff ff       	call   5a0 <putc>
        putc(fd, c);
 7f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7f9:	0f be c0             	movsbl %al,%eax
 7fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 800:	8b 45 08             	mov    0x8(%ebp),%eax
 803:	89 04 24             	mov    %eax,(%esp)
 806:	e8 95 fd ff ff       	call   5a0 <putc>
      }
      state = 0;
 80b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 812:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 816:	8b 55 0c             	mov    0xc(%ebp),%edx
 819:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81c:	01 d0                	add    %edx,%eax
 81e:	0f b6 00             	movzbl (%eax),%eax
 821:	84 c0                	test   %al,%al
 823:	0f 85 70 fe ff ff    	jne    699 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 829:	c9                   	leave  
 82a:	c3                   	ret    
 82b:	90                   	nop

0000082c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82c:	55                   	push   %ebp
 82d:	89 e5                	mov    %esp,%ebp
 82f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 832:	8b 45 08             	mov    0x8(%ebp),%eax
 835:	83 e8 08             	sub    $0x8,%eax
 838:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83b:	a1 90 0d 00 00       	mov    0xd90,%eax
 840:	89 45 fc             	mov    %eax,-0x4(%ebp)
 843:	eb 24                	jmp    869 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	8b 00                	mov    (%eax),%eax
 84a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 84d:	77 12                	ja     861 <free+0x35>
 84f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 852:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 855:	77 24                	ja     87b <free+0x4f>
 857:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85a:	8b 00                	mov    (%eax),%eax
 85c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 85f:	77 1a                	ja     87b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	89 45 fc             	mov    %eax,-0x4(%ebp)
 869:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86f:	76 d4                	jbe    845 <free+0x19>
 871:	8b 45 fc             	mov    -0x4(%ebp),%eax
 874:	8b 00                	mov    (%eax),%eax
 876:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 879:	76 ca                	jbe    845 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	8b 40 04             	mov    0x4(%eax),%eax
 881:	c1 e0 03             	shl    $0x3,%eax
 884:	89 c2                	mov    %eax,%edx
 886:	03 55 f8             	add    -0x8(%ebp),%edx
 889:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88c:	8b 00                	mov    (%eax),%eax
 88e:	39 c2                	cmp    %eax,%edx
 890:	75 24                	jne    8b6 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 892:	8b 45 f8             	mov    -0x8(%ebp),%eax
 895:	8b 50 04             	mov    0x4(%eax),%edx
 898:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89b:	8b 00                	mov    (%eax),%eax
 89d:	8b 40 04             	mov    0x4(%eax),%eax
 8a0:	01 c2                	add    %eax,%edx
 8a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ab:	8b 00                	mov    (%eax),%eax
 8ad:	8b 10                	mov    (%eax),%edx
 8af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b2:	89 10                	mov    %edx,(%eax)
 8b4:	eb 0a                	jmp    8c0 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b9:	8b 10                	mov    (%eax),%edx
 8bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8be:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c3:	8b 40 04             	mov    0x4(%eax),%eax
 8c6:	c1 e0 03             	shl    $0x3,%eax
 8c9:	03 45 fc             	add    -0x4(%ebp),%eax
 8cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8cf:	75 20                	jne    8f1 <free+0xc5>
    p->s.size += bp->s.size;
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	8b 50 04             	mov    0x4(%eax),%edx
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	8b 40 04             	mov    0x4(%eax),%eax
 8dd:	01 c2                	add    %eax,%edx
 8df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e8:	8b 10                	mov    (%eax),%edx
 8ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ed:	89 10                	mov    %edx,(%eax)
 8ef:	eb 08                	jmp    8f9 <free+0xcd>
  } else
    p->s.ptr = bp;
 8f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8f7:	89 10                	mov    %edx,(%eax)
  freep = p;
 8f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fc:	a3 90 0d 00 00       	mov    %eax,0xd90
}
 901:	c9                   	leave  
 902:	c3                   	ret    

00000903 <morecore>:

static Header*
morecore(uint nu)
{
 903:	55                   	push   %ebp
 904:	89 e5                	mov    %esp,%ebp
 906:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 909:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 910:	77 07                	ja     919 <morecore+0x16>
    nu = 4096;
 912:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 919:	8b 45 08             	mov    0x8(%ebp),%eax
 91c:	c1 e0 03             	shl    $0x3,%eax
 91f:	89 04 24             	mov    %eax,(%esp)
 922:	e8 61 fc ff ff       	call   588 <sbrk>
 927:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 92a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 92e:	75 07                	jne    937 <morecore+0x34>
    return 0;
 930:	b8 00 00 00 00       	mov    $0x0,%eax
 935:	eb 22                	jmp    959 <morecore+0x56>
  hp = (Header*)p;
 937:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 93d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 940:	8b 55 08             	mov    0x8(%ebp),%edx
 943:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 946:	8b 45 f0             	mov    -0x10(%ebp),%eax
 949:	83 c0 08             	add    $0x8,%eax
 94c:	89 04 24             	mov    %eax,(%esp)
 94f:	e8 d8 fe ff ff       	call   82c <free>
  return freep;
 954:	a1 90 0d 00 00       	mov    0xd90,%eax
}
 959:	c9                   	leave  
 95a:	c3                   	ret    

0000095b <malloc>:

void*
malloc(uint nbytes)
{
 95b:	55                   	push   %ebp
 95c:	89 e5                	mov    %esp,%ebp
 95e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 961:	8b 45 08             	mov    0x8(%ebp),%eax
 964:	83 c0 07             	add    $0x7,%eax
 967:	c1 e8 03             	shr    $0x3,%eax
 96a:	83 c0 01             	add    $0x1,%eax
 96d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 970:	a1 90 0d 00 00       	mov    0xd90,%eax
 975:	89 45 f0             	mov    %eax,-0x10(%ebp)
 978:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 97c:	75 23                	jne    9a1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 97e:	c7 45 f0 88 0d 00 00 	movl   $0xd88,-0x10(%ebp)
 985:	8b 45 f0             	mov    -0x10(%ebp),%eax
 988:	a3 90 0d 00 00       	mov    %eax,0xd90
 98d:	a1 90 0d 00 00       	mov    0xd90,%eax
 992:	a3 88 0d 00 00       	mov    %eax,0xd88
    base.s.size = 0;
 997:	c7 05 8c 0d 00 00 00 	movl   $0x0,0xd8c
 99e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a4:	8b 00                	mov    (%eax),%eax
 9a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ac:	8b 40 04             	mov    0x4(%eax),%eax
 9af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9b2:	72 4d                	jb     a01 <malloc+0xa6>
      if(p->s.size == nunits)
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	8b 40 04             	mov    0x4(%eax),%eax
 9ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9bd:	75 0c                	jne    9cb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c2:	8b 10                	mov    (%eax),%edx
 9c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c7:	89 10                	mov    %edx,(%eax)
 9c9:	eb 26                	jmp    9f1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ce:	8b 40 04             	mov    0x4(%eax),%eax
 9d1:	89 c2                	mov    %eax,%edx
 9d3:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9df:	8b 40 04             	mov    0x4(%eax),%eax
 9e2:	c1 e0 03             	shl    $0x3,%eax
 9e5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ee:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f4:	a3 90 0d 00 00       	mov    %eax,0xd90
      return (void*)(p + 1);
 9f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fc:	83 c0 08             	add    $0x8,%eax
 9ff:	eb 38                	jmp    a39 <malloc+0xde>
    }
    if(p == freep)
 a01:	a1 90 0d 00 00       	mov    0xd90,%eax
 a06:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a09:	75 1b                	jne    a26 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a0e:	89 04 24             	mov    %eax,(%esp)
 a11:	e8 ed fe ff ff       	call   903 <morecore>
 a16:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a1d:	75 07                	jne    a26 <malloc+0xcb>
        return 0;
 a1f:	b8 00 00 00 00       	mov    $0x0,%eax
 a24:	eb 13                	jmp    a39 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2f:	8b 00                	mov    (%eax),%eax
 a31:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a34:	e9 70 ff ff ff       	jmp    9a9 <malloc+0x4e>
}
 a39:	c9                   	leave  
 a3a:	c3                   	ret    
