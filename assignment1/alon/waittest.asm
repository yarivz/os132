
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
  16:	c7 44 24 04 43 0a 00 	movl   $0xa43,0x4(%esp)
  1d:	00 
  1e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  25:	e8 55 06 00 00       	call   67f <printf>

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
  3b:	e8 58 05 00 00       	call   598 <sleep>
  for (i=0;i<100;i++)
  40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  47:	eb 1f                	jmp    68 <foo+0x68>
     printf(2, "wait test %d\n",i);
  49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  50:	c7 44 24 04 43 0a 00 	movl   $0xa43,0x4(%esp)
  57:	00 
  58:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  5f:	e8 1b 06 00 00       	call   67f <printf>
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
  76:	c7 44 24 04 51 0a 00 	movl   $0xa51,0x4(%esp)
  7d:	00 
  7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  85:	e8 f5 05 00 00       	call   67f <printf>


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
  b4:	c7 44 24 04 5c 0a 00 	movl   $0xa5c,0x4(%esp)
  bb:	00 
  bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c3:	e8 b7 05 00 00       	call   67f <printf>
    printf(1, "wTime: %d rTime: %d \n",wTime,rTime);
  c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  d6:	c7 44 24 04 61 0a 00 	movl   $0xa61,0x4(%esp)
  dd:	00 
  de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e5:	e8 95 05 00 00       	call   67f <printf>

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
 237:	e8 e4 02 00 00       	call   520 <read>
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
 295:	e8 ae 02 00 00       	call   548 <open>
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
 2b7:	e8 a4 02 00 00       	call   560 <fstat>
 2bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c2:	89 04 24             	mov    %eax,(%esp)
 2c5:	e8 66 02 00 00       	call   530 <close>
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

00000510 <nice>:
SYSCALL(nice)
 510:	b8 17 00 00 00       	mov    $0x17,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <pipe>:
SYSCALL(pipe)
 518:	b8 04 00 00 00       	mov    $0x4,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <read>:
SYSCALL(read)
 520:	b8 05 00 00 00       	mov    $0x5,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <write>:
SYSCALL(write)
 528:	b8 10 00 00 00       	mov    $0x10,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <close>:
SYSCALL(close)
 530:	b8 15 00 00 00       	mov    $0x15,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <kill>:
SYSCALL(kill)
 538:	b8 06 00 00 00       	mov    $0x6,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <exec>:
SYSCALL(exec)
 540:	b8 07 00 00 00       	mov    $0x7,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <open>:
SYSCALL(open)
 548:	b8 0f 00 00 00       	mov    $0xf,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <mknod>:
SYSCALL(mknod)
 550:	b8 11 00 00 00       	mov    $0x11,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <unlink>:
SYSCALL(unlink)
 558:	b8 12 00 00 00       	mov    $0x12,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <fstat>:
SYSCALL(fstat)
 560:	b8 08 00 00 00       	mov    $0x8,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <link>:
SYSCALL(link)
 568:	b8 13 00 00 00       	mov    $0x13,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <mkdir>:
SYSCALL(mkdir)
 570:	b8 14 00 00 00       	mov    $0x14,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <chdir>:
SYSCALL(chdir)
 578:	b8 09 00 00 00       	mov    $0x9,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <dup>:
SYSCALL(dup)
 580:	b8 0a 00 00 00       	mov    $0xa,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <getpid>:
SYSCALL(getpid)
 588:	b8 0b 00 00 00       	mov    $0xb,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <sbrk>:
SYSCALL(sbrk)
 590:	b8 0c 00 00 00       	mov    $0xc,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <sleep>:
SYSCALL(sleep)
 598:	b8 0d 00 00 00       	mov    $0xd,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <uptime>:
SYSCALL(uptime)
 5a0:	b8 0e 00 00 00       	mov    $0xe,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5a8:	55                   	push   %ebp
 5a9:	89 e5                	mov    %esp,%ebp
 5ab:	83 ec 28             	sub    $0x28,%esp
 5ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5bb:	00 
 5bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c3:	8b 45 08             	mov    0x8(%ebp),%eax
 5c6:	89 04 24             	mov    %eax,(%esp)
 5c9:	e8 5a ff ff ff       	call   528 <write>
}
 5ce:	c9                   	leave  
 5cf:	c3                   	ret    

000005d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5d0:	55                   	push   %ebp
 5d1:	89 e5                	mov    %esp,%ebp
 5d3:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5d6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5dd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5e1:	74 17                	je     5fa <printint+0x2a>
 5e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5e7:	79 11                	jns    5fa <printint+0x2a>
    neg = 1;
 5e9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f3:	f7 d8                	neg    %eax
 5f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f8:	eb 06                	jmp    600 <printint+0x30>
  } else {
    x = xx;
 5fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 5fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 600:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 607:	8b 4d 10             	mov    0x10(%ebp),%ecx
 60a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 60d:	ba 00 00 00 00       	mov    $0x0,%edx
 612:	f7 f1                	div    %ecx
 614:	89 d0                	mov    %edx,%eax
 616:	0f b6 90 7c 0d 00 00 	movzbl 0xd7c(%eax),%edx
 61d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 620:	03 45 f4             	add    -0xc(%ebp),%eax
 623:	88 10                	mov    %dl,(%eax)
 625:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 629:	8b 55 10             	mov    0x10(%ebp),%edx
 62c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 62f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 632:	ba 00 00 00 00       	mov    $0x0,%edx
 637:	f7 75 d4             	divl   -0x2c(%ebp)
 63a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 63d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 641:	75 c4                	jne    607 <printint+0x37>
  if(neg)
 643:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 647:	74 2a                	je     673 <printint+0xa3>
    buf[i++] = '-';
 649:	8d 45 dc             	lea    -0x24(%ebp),%eax
 64c:	03 45 f4             	add    -0xc(%ebp),%eax
 64f:	c6 00 2d             	movb   $0x2d,(%eax)
 652:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 656:	eb 1b                	jmp    673 <printint+0xa3>
    putc(fd, buf[i]);
 658:	8d 45 dc             	lea    -0x24(%ebp),%eax
 65b:	03 45 f4             	add    -0xc(%ebp),%eax
 65e:	0f b6 00             	movzbl (%eax),%eax
 661:	0f be c0             	movsbl %al,%eax
 664:	89 44 24 04          	mov    %eax,0x4(%esp)
 668:	8b 45 08             	mov    0x8(%ebp),%eax
 66b:	89 04 24             	mov    %eax,(%esp)
 66e:	e8 35 ff ff ff       	call   5a8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 673:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 677:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 67b:	79 db                	jns    658 <printint+0x88>
    putc(fd, buf[i]);
}
 67d:	c9                   	leave  
 67e:	c3                   	ret    

0000067f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 67f:	55                   	push   %ebp
 680:	89 e5                	mov    %esp,%ebp
 682:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 685:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 68c:	8d 45 0c             	lea    0xc(%ebp),%eax
 68f:	83 c0 04             	add    $0x4,%eax
 692:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 695:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 69c:	e9 7d 01 00 00       	jmp    81e <printf+0x19f>
    c = fmt[i] & 0xff;
 6a1:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a7:	01 d0                	add    %edx,%eax
 6a9:	0f b6 00             	movzbl (%eax),%eax
 6ac:	0f be c0             	movsbl %al,%eax
 6af:	25 ff 00 00 00       	and    $0xff,%eax
 6b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6b7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6bb:	75 2c                	jne    6e9 <printf+0x6a>
      if(c == '%'){
 6bd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6c1:	75 0c                	jne    6cf <printf+0x50>
        state = '%';
 6c3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6ca:	e9 4b 01 00 00       	jmp    81a <printf+0x19b>
      } else {
        putc(fd, c);
 6cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d2:	0f be c0             	movsbl %al,%eax
 6d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d9:	8b 45 08             	mov    0x8(%ebp),%eax
 6dc:	89 04 24             	mov    %eax,(%esp)
 6df:	e8 c4 fe ff ff       	call   5a8 <putc>
 6e4:	e9 31 01 00 00       	jmp    81a <printf+0x19b>
      }
    } else if(state == '%'){
 6e9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ed:	0f 85 27 01 00 00    	jne    81a <printf+0x19b>
      if(c == 'd'){
 6f3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6f7:	75 2d                	jne    726 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 6f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6fc:	8b 00                	mov    (%eax),%eax
 6fe:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 705:	00 
 706:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 70d:	00 
 70e:	89 44 24 04          	mov    %eax,0x4(%esp)
 712:	8b 45 08             	mov    0x8(%ebp),%eax
 715:	89 04 24             	mov    %eax,(%esp)
 718:	e8 b3 fe ff ff       	call   5d0 <printint>
        ap++;
 71d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 721:	e9 ed 00 00 00       	jmp    813 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 726:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 72a:	74 06                	je     732 <printf+0xb3>
 72c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 730:	75 2d                	jne    75f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 732:	8b 45 e8             	mov    -0x18(%ebp),%eax
 735:	8b 00                	mov    (%eax),%eax
 737:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 73e:	00 
 73f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 746:	00 
 747:	89 44 24 04          	mov    %eax,0x4(%esp)
 74b:	8b 45 08             	mov    0x8(%ebp),%eax
 74e:	89 04 24             	mov    %eax,(%esp)
 751:	e8 7a fe ff ff       	call   5d0 <printint>
        ap++;
 756:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 75a:	e9 b4 00 00 00       	jmp    813 <printf+0x194>
      } else if(c == 's'){
 75f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 763:	75 46                	jne    7ab <printf+0x12c>
        s = (char*)*ap;
 765:	8b 45 e8             	mov    -0x18(%ebp),%eax
 768:	8b 00                	mov    (%eax),%eax
 76a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 76d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 775:	75 27                	jne    79e <printf+0x11f>
          s = "(null)";
 777:	c7 45 f4 77 0a 00 00 	movl   $0xa77,-0xc(%ebp)
        while(*s != 0){
 77e:	eb 1e                	jmp    79e <printf+0x11f>
          putc(fd, *s);
 780:	8b 45 f4             	mov    -0xc(%ebp),%eax
 783:	0f b6 00             	movzbl (%eax),%eax
 786:	0f be c0             	movsbl %al,%eax
 789:	89 44 24 04          	mov    %eax,0x4(%esp)
 78d:	8b 45 08             	mov    0x8(%ebp),%eax
 790:	89 04 24             	mov    %eax,(%esp)
 793:	e8 10 fe ff ff       	call   5a8 <putc>
          s++;
 798:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 79c:	eb 01                	jmp    79f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 79e:	90                   	nop
 79f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a2:	0f b6 00             	movzbl (%eax),%eax
 7a5:	84 c0                	test   %al,%al
 7a7:	75 d7                	jne    780 <printf+0x101>
 7a9:	eb 68                	jmp    813 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7ab:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7af:	75 1d                	jne    7ce <printf+0x14f>
        putc(fd, *ap);
 7b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b4:	8b 00                	mov    (%eax),%eax
 7b6:	0f be c0             	movsbl %al,%eax
 7b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7bd:	8b 45 08             	mov    0x8(%ebp),%eax
 7c0:	89 04 24             	mov    %eax,(%esp)
 7c3:	e8 e0 fd ff ff       	call   5a8 <putc>
        ap++;
 7c8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7cc:	eb 45                	jmp    813 <printf+0x194>
      } else if(c == '%'){
 7ce:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7d2:	75 17                	jne    7eb <printf+0x16c>
        putc(fd, c);
 7d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d7:	0f be c0             	movsbl %al,%eax
 7da:	89 44 24 04          	mov    %eax,0x4(%esp)
 7de:	8b 45 08             	mov    0x8(%ebp),%eax
 7e1:	89 04 24             	mov    %eax,(%esp)
 7e4:	e8 bf fd ff ff       	call   5a8 <putc>
 7e9:	eb 28                	jmp    813 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7eb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7f2:	00 
 7f3:	8b 45 08             	mov    0x8(%ebp),%eax
 7f6:	89 04 24             	mov    %eax,(%esp)
 7f9:	e8 aa fd ff ff       	call   5a8 <putc>
        putc(fd, c);
 7fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 801:	0f be c0             	movsbl %al,%eax
 804:	89 44 24 04          	mov    %eax,0x4(%esp)
 808:	8b 45 08             	mov    0x8(%ebp),%eax
 80b:	89 04 24             	mov    %eax,(%esp)
 80e:	e8 95 fd ff ff       	call   5a8 <putc>
      }
      state = 0;
 813:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 81a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 81e:	8b 55 0c             	mov    0xc(%ebp),%edx
 821:	8b 45 f0             	mov    -0x10(%ebp),%eax
 824:	01 d0                	add    %edx,%eax
 826:	0f b6 00             	movzbl (%eax),%eax
 829:	84 c0                	test   %al,%al
 82b:	0f 85 70 fe ff ff    	jne    6a1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 831:	c9                   	leave  
 832:	c3                   	ret    
 833:	90                   	nop

00000834 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 834:	55                   	push   %ebp
 835:	89 e5                	mov    %esp,%ebp
 837:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83a:	8b 45 08             	mov    0x8(%ebp),%eax
 83d:	83 e8 08             	sub    $0x8,%eax
 840:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 843:	a1 98 0d 00 00       	mov    0xd98,%eax
 848:	89 45 fc             	mov    %eax,-0x4(%ebp)
 84b:	eb 24                	jmp    871 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 850:	8b 00                	mov    (%eax),%eax
 852:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 855:	77 12                	ja     869 <free+0x35>
 857:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 85d:	77 24                	ja     883 <free+0x4f>
 85f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 862:	8b 00                	mov    (%eax),%eax
 864:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 867:	77 1a                	ja     883 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 869:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86c:	8b 00                	mov    (%eax),%eax
 86e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 871:	8b 45 f8             	mov    -0x8(%ebp),%eax
 874:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 877:	76 d4                	jbe    84d <free+0x19>
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 00                	mov    (%eax),%eax
 87e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 881:	76 ca                	jbe    84d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 883:	8b 45 f8             	mov    -0x8(%ebp),%eax
 886:	8b 40 04             	mov    0x4(%eax),%eax
 889:	c1 e0 03             	shl    $0x3,%eax
 88c:	89 c2                	mov    %eax,%edx
 88e:	03 55 f8             	add    -0x8(%ebp),%edx
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
 894:	8b 00                	mov    (%eax),%eax
 896:	39 c2                	cmp    %eax,%edx
 898:	75 24                	jne    8be <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 89a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89d:	8b 50 04             	mov    0x4(%eax),%edx
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	8b 00                	mov    (%eax),%eax
 8a5:	8b 40 04             	mov    0x4(%eax),%eax
 8a8:	01 c2                	add    %eax,%edx
 8aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ad:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b3:	8b 00                	mov    (%eax),%eax
 8b5:	8b 10                	mov    (%eax),%edx
 8b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ba:	89 10                	mov    %edx,(%eax)
 8bc:	eb 0a                	jmp    8c8 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c1:	8b 10                	mov    (%eax),%edx
 8c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cb:	8b 40 04             	mov    0x4(%eax),%eax
 8ce:	c1 e0 03             	shl    $0x3,%eax
 8d1:	03 45 fc             	add    -0x4(%ebp),%eax
 8d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8d7:	75 20                	jne    8f9 <free+0xc5>
    p->s.size += bp->s.size;
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	8b 50 04             	mov    0x4(%eax),%edx
 8df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e2:	8b 40 04             	mov    0x4(%eax),%eax
 8e5:	01 c2                	add    %eax,%edx
 8e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ea:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f0:	8b 10                	mov    (%eax),%edx
 8f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f5:	89 10                	mov    %edx,(%eax)
 8f7:	eb 08                	jmp    901 <free+0xcd>
  } else
    p->s.ptr = bp;
 8f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8ff:	89 10                	mov    %edx,(%eax)
  freep = p;
 901:	8b 45 fc             	mov    -0x4(%ebp),%eax
 904:	a3 98 0d 00 00       	mov    %eax,0xd98
}
 909:	c9                   	leave  
 90a:	c3                   	ret    

0000090b <morecore>:

static Header*
morecore(uint nu)
{
 90b:	55                   	push   %ebp
 90c:	89 e5                	mov    %esp,%ebp
 90e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 911:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 918:	77 07                	ja     921 <morecore+0x16>
    nu = 4096;
 91a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 921:	8b 45 08             	mov    0x8(%ebp),%eax
 924:	c1 e0 03             	shl    $0x3,%eax
 927:	89 04 24             	mov    %eax,(%esp)
 92a:	e8 61 fc ff ff       	call   590 <sbrk>
 92f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 932:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 936:	75 07                	jne    93f <morecore+0x34>
    return 0;
 938:	b8 00 00 00 00       	mov    $0x0,%eax
 93d:	eb 22                	jmp    961 <morecore+0x56>
  hp = (Header*)p;
 93f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 942:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 945:	8b 45 f0             	mov    -0x10(%ebp),%eax
 948:	8b 55 08             	mov    0x8(%ebp),%edx
 94b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 94e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 951:	83 c0 08             	add    $0x8,%eax
 954:	89 04 24             	mov    %eax,(%esp)
 957:	e8 d8 fe ff ff       	call   834 <free>
  return freep;
 95c:	a1 98 0d 00 00       	mov    0xd98,%eax
}
 961:	c9                   	leave  
 962:	c3                   	ret    

00000963 <malloc>:

void*
malloc(uint nbytes)
{
 963:	55                   	push   %ebp
 964:	89 e5                	mov    %esp,%ebp
 966:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 969:	8b 45 08             	mov    0x8(%ebp),%eax
 96c:	83 c0 07             	add    $0x7,%eax
 96f:	c1 e8 03             	shr    $0x3,%eax
 972:	83 c0 01             	add    $0x1,%eax
 975:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 978:	a1 98 0d 00 00       	mov    0xd98,%eax
 97d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 984:	75 23                	jne    9a9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 986:	c7 45 f0 90 0d 00 00 	movl   $0xd90,-0x10(%ebp)
 98d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 990:	a3 98 0d 00 00       	mov    %eax,0xd98
 995:	a1 98 0d 00 00       	mov    0xd98,%eax
 99a:	a3 90 0d 00 00       	mov    %eax,0xd90
    base.s.size = 0;
 99f:	c7 05 94 0d 00 00 00 	movl   $0x0,0xd94
 9a6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ac:	8b 00                	mov    (%eax),%eax
 9ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	8b 40 04             	mov    0x4(%eax),%eax
 9b7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ba:	72 4d                	jb     a09 <malloc+0xa6>
      if(p->s.size == nunits)
 9bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bf:	8b 40 04             	mov    0x4(%eax),%eax
 9c2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9c5:	75 0c                	jne    9d3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ca:	8b 10                	mov    (%eax),%edx
 9cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cf:	89 10                	mov    %edx,(%eax)
 9d1:	eb 26                	jmp    9f9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d6:	8b 40 04             	mov    0x4(%eax),%eax
 9d9:	89 c2                	mov    %eax,%edx
 9db:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e7:	8b 40 04             	mov    0x4(%eax),%eax
 9ea:	c1 e0 03             	shl    $0x3,%eax
 9ed:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9f6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fc:	a3 98 0d 00 00       	mov    %eax,0xd98
      return (void*)(p + 1);
 a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a04:	83 c0 08             	add    $0x8,%eax
 a07:	eb 38                	jmp    a41 <malloc+0xde>
    }
    if(p == freep)
 a09:	a1 98 0d 00 00       	mov    0xd98,%eax
 a0e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a11:	75 1b                	jne    a2e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a16:	89 04 24             	mov    %eax,(%esp)
 a19:	e8 ed fe ff ff       	call   90b <morecore>
 a1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a25:	75 07                	jne    a2e <malloc+0xcb>
        return 0;
 a27:	b8 00 00 00 00       	mov    $0x0,%eax
 a2c:	eb 13                	jmp    a41 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a37:	8b 00                	mov    (%eax),%eax
 a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a3c:	e9 70 ff ff ff       	jmp    9b1 <malloc+0x4e>
}
 a41:	c9                   	leave  
 a42:	c3                   	ret    
