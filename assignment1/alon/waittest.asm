
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
  16:	c7 44 24 04 61 0a 00 	movl   $0xa61,0x4(%esp)
  1d:	00 
  1e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  25:	e8 67 06 00 00       	call   691 <printf>

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
  3b:	e8 64 05 00 00       	call   5a4 <sleep>
  for (i=0;i<100;i++)
  40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  47:	eb 1f                	jmp    68 <foo+0x68>
     printf(2, "wait test %d\n",i);
  49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  50:	c7 44 24 04 61 0a 00 	movl   $0xa61,0x4(%esp)
  57:	00 
  58:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  5f:	e8 2d 06 00 00       	call   691 <printf>
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
  76:	c7 44 24 04 6f 0a 00 	movl   $0xa6f,0x4(%esp)
  7d:	00 
  7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  85:	e8 07 06 00 00       	call   691 <printf>


    pid = fork();
  8a:	e8 6d 04 00 00       	call   4fc <fork>
  8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid == 0)
  92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  96:	75 0a                	jne    a2 <waittest+0x32>
    {
      foo();
  98:	e8 63 ff ff ff       	call   0 <foo>
      exit();      
  9d:	e8 62 04 00 00       	call   504 <exit>
    }
    wait2(&wTime,&rTime);
  a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  ac:	89 04 24             	mov    %eax,(%esp)
  af:	e8 60 04 00 00       	call   514 <wait2>
     printf(1, "hi \n");
  b4:	c7 44 24 04 7a 0a 00 	movl   $0xa7a,0x4(%esp)
  bb:	00 
  bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c3:	e8 c9 05 00 00       	call   691 <printf>
    printf(1, "wTime: %d rTime: %d \n",wTime,rTime);
  c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  d6:	c7 44 24 04 7f 0a 00 	movl   $0xa7f,0x4(%esp)
  dd:	00 
  de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e5:	e8 a7 05 00 00       	call   691 <printf>

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
  f7:	e8 08 04 00 00       	call   504 <exit>

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
 1a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	01 d0                	add    %edx,%eax
 1b1:	0f b6 00             	movzbl (%eax),%eax
 1b4:	84 c0                	test   %al,%al
 1b6:	75 ed                	jne    1a5 <strlen+0xf>
  return n;
 1b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1bb:	c9                   	leave  
 1bc:	c3                   	ret    

000001bd <memset>:

void*
memset(void *dst, int c, uint n)
{
 1bd:	55                   	push   %ebp
 1be:	89 e5                	mov    %esp,%ebp
 1c0:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1c3:	8b 45 10             	mov    0x10(%ebp),%eax
 1c6:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 1cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d1:	8b 45 08             	mov    0x8(%ebp),%eax
 1d4:	89 04 24             	mov    %eax,(%esp)
 1d7:	e8 20 ff ff ff       	call   fc <stosb>
  return dst;
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1df:	c9                   	leave  
 1e0:	c3                   	ret    

000001e1 <strchr>:

char*
strchr(const char *s, char c)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 04             	sub    $0x4,%esp
 1e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ea:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1ed:	eb 14                	jmp    203 <strchr+0x22>
    if(*s == c)
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	0f b6 00             	movzbl (%eax),%eax
 1f5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1f8:	75 05                	jne    1ff <strchr+0x1e>
      return (char*)s;
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
 1fd:	eb 13                	jmp    212 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	0f b6 00             	movzbl (%eax),%eax
 209:	84 c0                	test   %al,%al
 20b:	75 e2                	jne    1ef <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 20d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 212:	c9                   	leave  
 213:	c3                   	ret    

00000214 <gets>:

char*
gets(char *buf, int max)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 221:	eb 46                	jmp    269 <gets+0x55>
    cc = read(0, &c, 1);
 223:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 22a:	00 
 22b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 22e:	89 44 24 04          	mov    %eax,0x4(%esp)
 232:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 239:	e8 ee 02 00 00       	call   52c <read>
 23e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 241:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 245:	7e 2f                	jle    276 <gets+0x62>
      break;
    buf[i++] = c;
 247:	8b 55 f4             	mov    -0xc(%ebp),%edx
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	01 c2                	add    %eax,%edx
 24f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 253:	88 02                	mov    %al,(%edx)
 255:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 259:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 25d:	3c 0a                	cmp    $0xa,%al
 25f:	74 16                	je     277 <gets+0x63>
 261:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 265:	3c 0d                	cmp    $0xd,%al
 267:	74 0e                	je     277 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 269:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26c:	83 c0 01             	add    $0x1,%eax
 26f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 272:	7c af                	jl     223 <gets+0xf>
 274:	eb 01                	jmp    277 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 276:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 277:	8b 55 f4             	mov    -0xc(%ebp),%edx
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	01 d0                	add    %edx,%eax
 27f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 282:	8b 45 08             	mov    0x8(%ebp),%eax
}
 285:	c9                   	leave  
 286:	c3                   	ret    

00000287 <stat>:

int
stat(char *n, struct stat *st)
{
 287:	55                   	push   %ebp
 288:	89 e5                	mov    %esp,%ebp
 28a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 294:	00 
 295:	8b 45 08             	mov    0x8(%ebp),%eax
 298:	89 04 24             	mov    %eax,(%esp)
 29b:	e8 b4 02 00 00       	call   554 <open>
 2a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a7:	79 07                	jns    2b0 <stat+0x29>
    return -1;
 2a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ae:	eb 23                	jmp    2d3 <stat+0x4c>
  r = fstat(fd, st);
 2b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 aa 02 00 00       	call   56c <fstat>
 2c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c8:	89 04 24             	mov    %eax,(%esp)
 2cb:	e8 6c 02 00 00       	call   53c <close>
  return r;
 2d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d3:	c9                   	leave  
 2d4:	c3                   	ret    

000002d5 <atoi>:

int
atoi(const char *s)
{
 2d5:	55                   	push   %ebp
 2d6:	89 e5                	mov    %esp,%ebp
 2d8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2db:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e2:	eb 23                	jmp    307 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2e4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e7:	89 d0                	mov    %edx,%eax
 2e9:	c1 e0 02             	shl    $0x2,%eax
 2ec:	01 d0                	add    %edx,%eax
 2ee:	01 c0                	add    %eax,%eax
 2f0:	89 c2                	mov    %eax,%edx
 2f2:	8b 45 08             	mov    0x8(%ebp),%eax
 2f5:	0f b6 00             	movzbl (%eax),%eax
 2f8:	0f be c0             	movsbl %al,%eax
 2fb:	01 d0                	add    %edx,%eax
 2fd:	83 e8 30             	sub    $0x30,%eax
 300:	89 45 fc             	mov    %eax,-0x4(%ebp)
 303:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	0f b6 00             	movzbl (%eax),%eax
 30d:	3c 2f                	cmp    $0x2f,%al
 30f:	7e 0a                	jle    31b <atoi+0x46>
 311:	8b 45 08             	mov    0x8(%ebp),%eax
 314:	0f b6 00             	movzbl (%eax),%eax
 317:	3c 39                	cmp    $0x39,%al
 319:	7e c9                	jle    2e4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 31b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31e:	c9                   	leave  
 31f:	c3                   	ret    

00000320 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 32c:	8b 45 0c             	mov    0xc(%ebp),%eax
 32f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 332:	eb 13                	jmp    347 <memmove+0x27>
    *dst++ = *src++;
 334:	8b 45 f8             	mov    -0x8(%ebp),%eax
 337:	0f b6 10             	movzbl (%eax),%edx
 33a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 33d:	88 10                	mov    %dl,(%eax)
 33f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 343:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 347:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 34b:	0f 9f c0             	setg   %al
 34e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 352:	84 c0                	test   %al,%al
 354:	75 de                	jne    334 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 356:	8b 45 08             	mov    0x8(%ebp),%eax
}
 359:	c9                   	leave  
 35a:	c3                   	ret    

0000035b <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 35b:	55                   	push   %ebp
 35c:	89 e5                	mov    %esp,%ebp
 35e:	83 ec 38             	sub    $0x38,%esp
 361:	8b 45 10             	mov    0x10(%ebp),%eax
 364:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 367:	8b 45 14             	mov    0x14(%ebp),%eax
 36a:	8b 00                	mov    (%eax),%eax
 36c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 36f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 376:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 37a:	74 06                	je     382 <strtok+0x27>
 37c:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 380:	75 5a                	jne    3dc <strtok+0x81>
    return match;
 382:	8b 45 f0             	mov    -0x10(%ebp),%eax
 385:	eb 76                	jmp    3fd <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 387:	8b 55 f4             	mov    -0xc(%ebp),%edx
 38a:	8b 45 0c             	mov    0xc(%ebp),%eax
 38d:	01 d0                	add    %edx,%eax
 38f:	0f b6 00             	movzbl (%eax),%eax
 392:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 395:	74 06                	je     39d <strtok+0x42>
      {
	index++;
 397:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 39b:	eb 40                	jmp    3dd <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 39d:	8b 45 14             	mov    0x14(%ebp),%eax
 3a0:	8b 00                	mov    (%eax),%eax
 3a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3a5:	29 c2                	sub    %eax,%edx
 3a7:	8b 45 14             	mov    0x14(%ebp),%eax
 3aa:	8b 00                	mov    (%eax),%eax
 3ac:	89 c1                	mov    %eax,%ecx
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	01 c8                	add    %ecx,%eax
 3b3:	89 54 24 08          	mov    %edx,0x8(%esp)
 3b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	89 04 24             	mov    %eax,(%esp)
 3c1:	e8 39 00 00 00       	call   3ff <strncpy>
 3c6:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	84 c0                	test   %al,%al
 3d1:	74 1b                	je     3ee <strtok+0x93>
	  match = 1;
 3d3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 3da:	eb 12                	jmp    3ee <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 3dc:	90                   	nop
 3dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e3:	01 d0                	add    %edx,%eax
 3e5:	0f b6 00             	movzbl (%eax),%eax
 3e8:	84 c0                	test   %al,%al
 3ea:	75 9b                	jne    387 <strtok+0x2c>
 3ec:	eb 01                	jmp    3ef <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 3ee:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 3ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f2:	8d 50 01             	lea    0x1(%eax),%edx
 3f5:	8b 45 14             	mov    0x14(%ebp),%eax
 3f8:	89 10                	mov    %edx,(%eax)
  return match;
 3fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3fd:	c9                   	leave  
 3fe:	c3                   	ret    

000003ff <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 3ff:	55                   	push   %ebp
 400:	89 e5                	mov    %esp,%ebp
 402:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 405:	8b 45 08             	mov    0x8(%ebp),%eax
 408:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 40b:	90                   	nop
 40c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 410:	0f 9f c0             	setg   %al
 413:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 417:	84 c0                	test   %al,%al
 419:	74 30                	je     44b <strncpy+0x4c>
 41b:	8b 45 0c             	mov    0xc(%ebp),%eax
 41e:	0f b6 10             	movzbl (%eax),%edx
 421:	8b 45 08             	mov    0x8(%ebp),%eax
 424:	88 10                	mov    %dl,(%eax)
 426:	8b 45 08             	mov    0x8(%ebp),%eax
 429:	0f b6 00             	movzbl (%eax),%eax
 42c:	84 c0                	test   %al,%al
 42e:	0f 95 c0             	setne  %al
 431:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 435:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 439:	84 c0                	test   %al,%al
 43b:	75 cf                	jne    40c <strncpy+0xd>
    ;
  while(n-- > 0)
 43d:	eb 0c                	jmp    44b <strncpy+0x4c>
    *s++ = 0;
 43f:	8b 45 08             	mov    0x8(%ebp),%eax
 442:	c6 00 00             	movb   $0x0,(%eax)
 445:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 449:	eb 01                	jmp    44c <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 44b:	90                   	nop
 44c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 450:	0f 9f c0             	setg   %al
 453:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 457:	84 c0                	test   %al,%al
 459:	75 e4                	jne    43f <strncpy+0x40>
    *s++ = 0;
  return os;
 45b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 45e:	c9                   	leave  
 45f:	c3                   	ret    

00000460 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 463:	eb 0c                	jmp    471 <strncmp+0x11>
    n--, p++, q++;
 465:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 469:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 46d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 471:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 475:	74 1a                	je     491 <strncmp+0x31>
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	0f b6 00             	movzbl (%eax),%eax
 47d:	84 c0                	test   %al,%al
 47f:	74 10                	je     491 <strncmp+0x31>
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	0f b6 10             	movzbl (%eax),%edx
 487:	8b 45 0c             	mov    0xc(%ebp),%eax
 48a:	0f b6 00             	movzbl (%eax),%eax
 48d:	38 c2                	cmp    %al,%dl
 48f:	74 d4                	je     465 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 491:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 495:	75 07                	jne    49e <strncmp+0x3e>
    return 0;
 497:	b8 00 00 00 00       	mov    $0x0,%eax
 49c:	eb 18                	jmp    4b6 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 49e:	8b 45 08             	mov    0x8(%ebp),%eax
 4a1:	0f b6 00             	movzbl (%eax),%eax
 4a4:	0f b6 d0             	movzbl %al,%edx
 4a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4aa:	0f b6 00             	movzbl (%eax),%eax
 4ad:	0f b6 c0             	movzbl %al,%eax
 4b0:	89 d1                	mov    %edx,%ecx
 4b2:	29 c1                	sub    %eax,%ecx
 4b4:	89 c8                	mov    %ecx,%eax
}
 4b6:	5d                   	pop    %ebp
 4b7:	c3                   	ret    

000004b8 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 4b8:	55                   	push   %ebp
 4b9:	89 e5                	mov    %esp,%ebp
  while(*p){
 4bb:	eb 13                	jmp    4d0 <strcat+0x18>
    *dest++ = *p++;
 4bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c0:	0f b6 10             	movzbl (%eax),%edx
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	88 10                	mov    %dl,(%eax)
 4c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4cc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 4d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d3:	0f b6 00             	movzbl (%eax),%eax
 4d6:	84 c0                	test   %al,%al
 4d8:	75 e3                	jne    4bd <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 4da:	eb 13                	jmp    4ef <strcat+0x37>
    *dest++ = *q++;
 4dc:	8b 45 10             	mov    0x10(%ebp),%eax
 4df:	0f b6 10             	movzbl (%eax),%edx
 4e2:	8b 45 08             	mov    0x8(%ebp),%eax
 4e5:	88 10                	mov    %dl,(%eax)
 4e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4eb:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 4ef:	8b 45 10             	mov    0x10(%ebp),%eax
 4f2:	0f b6 00             	movzbl (%eax),%eax
 4f5:	84 c0                	test   %al,%al
 4f7:	75 e3                	jne    4dc <strcat+0x24>
    *dest++ = *q++;
  }  
 4f9:	5d                   	pop    %ebp
 4fa:	c3                   	ret    
 4fb:	90                   	nop

000004fc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4fc:	b8 01 00 00 00       	mov    $0x1,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <exit>:
SYSCALL(exit)
 504:	b8 02 00 00 00       	mov    $0x2,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <wait>:
SYSCALL(wait)
 50c:	b8 03 00 00 00       	mov    $0x3,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <wait2>:
SYSCALL(wait2)
 514:	b8 16 00 00 00       	mov    $0x16,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <nice>:
SYSCALL(nice)
 51c:	b8 17 00 00 00       	mov    $0x17,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <pipe>:
SYSCALL(pipe)
 524:	b8 04 00 00 00       	mov    $0x4,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <read>:
SYSCALL(read)
 52c:	b8 05 00 00 00       	mov    $0x5,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <write>:
SYSCALL(write)
 534:	b8 10 00 00 00       	mov    $0x10,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <close>:
SYSCALL(close)
 53c:	b8 15 00 00 00       	mov    $0x15,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <kill>:
SYSCALL(kill)
 544:	b8 06 00 00 00       	mov    $0x6,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <exec>:
SYSCALL(exec)
 54c:	b8 07 00 00 00       	mov    $0x7,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <open>:
SYSCALL(open)
 554:	b8 0f 00 00 00       	mov    $0xf,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <mknod>:
SYSCALL(mknod)
 55c:	b8 11 00 00 00       	mov    $0x11,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <unlink>:
SYSCALL(unlink)
 564:	b8 12 00 00 00       	mov    $0x12,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <fstat>:
SYSCALL(fstat)
 56c:	b8 08 00 00 00       	mov    $0x8,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <link>:
SYSCALL(link)
 574:	b8 13 00 00 00       	mov    $0x13,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <mkdir>:
SYSCALL(mkdir)
 57c:	b8 14 00 00 00       	mov    $0x14,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <chdir>:
SYSCALL(chdir)
 584:	b8 09 00 00 00       	mov    $0x9,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <dup>:
SYSCALL(dup)
 58c:	b8 0a 00 00 00       	mov    $0xa,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <getpid>:
SYSCALL(getpid)
 594:	b8 0b 00 00 00       	mov    $0xb,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <sbrk>:
SYSCALL(sbrk)
 59c:	b8 0c 00 00 00       	mov    $0xc,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <sleep>:
SYSCALL(sleep)
 5a4:	b8 0d 00 00 00       	mov    $0xd,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <uptime>:
SYSCALL(uptime)
 5ac:	b8 0e 00 00 00       	mov    $0xe,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5b4:	55                   	push   %ebp
 5b5:	89 e5                	mov    %esp,%ebp
 5b7:	83 ec 28             	sub    $0x28,%esp
 5ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 5bd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5c7:	00 
 5c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5cf:	8b 45 08             	mov    0x8(%ebp),%eax
 5d2:	89 04 24             	mov    %eax,(%esp)
 5d5:	e8 5a ff ff ff       	call   534 <write>
}
 5da:	c9                   	leave  
 5db:	c3                   	ret    

000005dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5dc:	55                   	push   %ebp
 5dd:	89 e5                	mov    %esp,%ebp
 5df:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5e9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5ed:	74 17                	je     606 <printint+0x2a>
 5ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5f3:	79 11                	jns    606 <printint+0x2a>
    neg = 1;
 5f5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ff:	f7 d8                	neg    %eax
 601:	89 45 ec             	mov    %eax,-0x14(%ebp)
 604:	eb 06                	jmp    60c <printint+0x30>
  } else {
    x = xx;
 606:	8b 45 0c             	mov    0xc(%ebp),%eax
 609:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 60c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 613:	8b 4d 10             	mov    0x10(%ebp),%ecx
 616:	8b 45 ec             	mov    -0x14(%ebp),%eax
 619:	ba 00 00 00 00       	mov    $0x0,%edx
 61e:	f7 f1                	div    %ecx
 620:	89 d0                	mov    %edx,%eax
 622:	0f b6 80 98 0d 00 00 	movzbl 0xd98(%eax),%eax
 629:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 62c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 62f:	01 ca                	add    %ecx,%edx
 631:	88 02                	mov    %al,(%edx)
 633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 637:	8b 55 10             	mov    0x10(%ebp),%edx
 63a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 63d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 640:	ba 00 00 00 00       	mov    $0x0,%edx
 645:	f7 75 d4             	divl   -0x2c(%ebp)
 648:	89 45 ec             	mov    %eax,-0x14(%ebp)
 64b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64f:	75 c2                	jne    613 <printint+0x37>
  if(neg)
 651:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 655:	74 2e                	je     685 <printint+0xa9>
    buf[i++] = '-';
 657:	8d 55 dc             	lea    -0x24(%ebp),%edx
 65a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65d:	01 d0                	add    %edx,%eax
 65f:	c6 00 2d             	movb   $0x2d,(%eax)
 662:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 666:	eb 1d                	jmp    685 <printint+0xa9>
    putc(fd, buf[i]);
 668:	8d 55 dc             	lea    -0x24(%ebp),%edx
 66b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 66e:	01 d0                	add    %edx,%eax
 670:	0f b6 00             	movzbl (%eax),%eax
 673:	0f be c0             	movsbl %al,%eax
 676:	89 44 24 04          	mov    %eax,0x4(%esp)
 67a:	8b 45 08             	mov    0x8(%ebp),%eax
 67d:	89 04 24             	mov    %eax,(%esp)
 680:	e8 2f ff ff ff       	call   5b4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 685:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 689:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 68d:	79 d9                	jns    668 <printint+0x8c>
    putc(fd, buf[i]);
}
 68f:	c9                   	leave  
 690:	c3                   	ret    

00000691 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 691:	55                   	push   %ebp
 692:	89 e5                	mov    %esp,%ebp
 694:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 697:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 69e:	8d 45 0c             	lea    0xc(%ebp),%eax
 6a1:	83 c0 04             	add    $0x4,%eax
 6a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ae:	e9 7d 01 00 00       	jmp    830 <printf+0x19f>
    c = fmt[i] & 0xff;
 6b3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b9:	01 d0                	add    %edx,%eax
 6bb:	0f b6 00             	movzbl (%eax),%eax
 6be:	0f be c0             	movsbl %al,%eax
 6c1:	25 ff 00 00 00       	and    $0xff,%eax
 6c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6cd:	75 2c                	jne    6fb <printf+0x6a>
      if(c == '%'){
 6cf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d3:	75 0c                	jne    6e1 <printf+0x50>
        state = '%';
 6d5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6dc:	e9 4b 01 00 00       	jmp    82c <printf+0x19b>
      } else {
        putc(fd, c);
 6e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e4:	0f be c0             	movsbl %al,%eax
 6e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6eb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ee:	89 04 24             	mov    %eax,(%esp)
 6f1:	e8 be fe ff ff       	call   5b4 <putc>
 6f6:	e9 31 01 00 00       	jmp    82c <printf+0x19b>
      }
    } else if(state == '%'){
 6fb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ff:	0f 85 27 01 00 00    	jne    82c <printf+0x19b>
      if(c == 'd'){
 705:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 709:	75 2d                	jne    738 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 70b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70e:	8b 00                	mov    (%eax),%eax
 710:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 717:	00 
 718:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 71f:	00 
 720:	89 44 24 04          	mov    %eax,0x4(%esp)
 724:	8b 45 08             	mov    0x8(%ebp),%eax
 727:	89 04 24             	mov    %eax,(%esp)
 72a:	e8 ad fe ff ff       	call   5dc <printint>
        ap++;
 72f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 733:	e9 ed 00 00 00       	jmp    825 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 738:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 73c:	74 06                	je     744 <printf+0xb3>
 73e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 742:	75 2d                	jne    771 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 744:	8b 45 e8             	mov    -0x18(%ebp),%eax
 747:	8b 00                	mov    (%eax),%eax
 749:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 750:	00 
 751:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 758:	00 
 759:	89 44 24 04          	mov    %eax,0x4(%esp)
 75d:	8b 45 08             	mov    0x8(%ebp),%eax
 760:	89 04 24             	mov    %eax,(%esp)
 763:	e8 74 fe ff ff       	call   5dc <printint>
        ap++;
 768:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76c:	e9 b4 00 00 00       	jmp    825 <printf+0x194>
      } else if(c == 's'){
 771:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 775:	75 46                	jne    7bd <printf+0x12c>
        s = (char*)*ap;
 777:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77a:	8b 00                	mov    (%eax),%eax
 77c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 77f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 783:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 787:	75 27                	jne    7b0 <printf+0x11f>
          s = "(null)";
 789:	c7 45 f4 95 0a 00 00 	movl   $0xa95,-0xc(%ebp)
        while(*s != 0){
 790:	eb 1e                	jmp    7b0 <printf+0x11f>
          putc(fd, *s);
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	0f b6 00             	movzbl (%eax),%eax
 798:	0f be c0             	movsbl %al,%eax
 79b:	89 44 24 04          	mov    %eax,0x4(%esp)
 79f:	8b 45 08             	mov    0x8(%ebp),%eax
 7a2:	89 04 24             	mov    %eax,(%esp)
 7a5:	e8 0a fe ff ff       	call   5b4 <putc>
          s++;
 7aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7ae:	eb 01                	jmp    7b1 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7b0:	90                   	nop
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	0f b6 00             	movzbl (%eax),%eax
 7b7:	84 c0                	test   %al,%al
 7b9:	75 d7                	jne    792 <printf+0x101>
 7bb:	eb 68                	jmp    825 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7bd:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c1:	75 1d                	jne    7e0 <printf+0x14f>
        putc(fd, *ap);
 7c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c6:	8b 00                	mov    (%eax),%eax
 7c8:	0f be c0             	movsbl %al,%eax
 7cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 7cf:	8b 45 08             	mov    0x8(%ebp),%eax
 7d2:	89 04 24             	mov    %eax,(%esp)
 7d5:	e8 da fd ff ff       	call   5b4 <putc>
        ap++;
 7da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7de:	eb 45                	jmp    825 <printf+0x194>
      } else if(c == '%'){
 7e0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e4:	75 17                	jne    7fd <printf+0x16c>
        putc(fd, c);
 7e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e9:	0f be c0             	movsbl %al,%eax
 7ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f0:	8b 45 08             	mov    0x8(%ebp),%eax
 7f3:	89 04 24             	mov    %eax,(%esp)
 7f6:	e8 b9 fd ff ff       	call   5b4 <putc>
 7fb:	eb 28                	jmp    825 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7fd:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 804:	00 
 805:	8b 45 08             	mov    0x8(%ebp),%eax
 808:	89 04 24             	mov    %eax,(%esp)
 80b:	e8 a4 fd ff ff       	call   5b4 <putc>
        putc(fd, c);
 810:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 813:	0f be c0             	movsbl %al,%eax
 816:	89 44 24 04          	mov    %eax,0x4(%esp)
 81a:	8b 45 08             	mov    0x8(%ebp),%eax
 81d:	89 04 24             	mov    %eax,(%esp)
 820:	e8 8f fd ff ff       	call   5b4 <putc>
      }
      state = 0;
 825:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 82c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 830:	8b 55 0c             	mov    0xc(%ebp),%edx
 833:	8b 45 f0             	mov    -0x10(%ebp),%eax
 836:	01 d0                	add    %edx,%eax
 838:	0f b6 00             	movzbl (%eax),%eax
 83b:	84 c0                	test   %al,%al
 83d:	0f 85 70 fe ff ff    	jne    6b3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 843:	c9                   	leave  
 844:	c3                   	ret    
 845:	66 90                	xchg   %ax,%ax
 847:	90                   	nop

00000848 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 848:	55                   	push   %ebp
 849:	89 e5                	mov    %esp,%ebp
 84b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84e:	8b 45 08             	mov    0x8(%ebp),%eax
 851:	83 e8 08             	sub    $0x8,%eax
 854:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 857:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 85c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85f:	eb 24                	jmp    885 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 869:	77 12                	ja     87d <free+0x35>
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 871:	77 24                	ja     897 <free+0x4f>
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	8b 00                	mov    (%eax),%eax
 878:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 87b:	77 1a                	ja     897 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 00                	mov    (%eax),%eax
 882:	89 45 fc             	mov    %eax,-0x4(%ebp)
 885:	8b 45 f8             	mov    -0x8(%ebp),%eax
 888:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 88b:	76 d4                	jbe    861 <free+0x19>
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	8b 00                	mov    (%eax),%eax
 892:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 895:	76 ca                	jbe    861 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	8b 40 04             	mov    0x4(%eax),%eax
 89d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a7:	01 c2                	add    %eax,%edx
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	8b 00                	mov    (%eax),%eax
 8ae:	39 c2                	cmp    %eax,%edx
 8b0:	75 24                	jne    8d6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b5:	8b 50 04             	mov    0x4(%eax),%edx
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	8b 00                	mov    (%eax),%eax
 8bd:	8b 40 04             	mov    0x4(%eax),%eax
 8c0:	01 c2                	add    %eax,%edx
 8c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cb:	8b 00                	mov    (%eax),%eax
 8cd:	8b 10                	mov    (%eax),%edx
 8cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d2:	89 10                	mov    %edx,(%eax)
 8d4:	eb 0a                	jmp    8e0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d9:	8b 10                	mov    (%eax),%edx
 8db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8de:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 40 04             	mov    0x4(%eax),%eax
 8e6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	01 d0                	add    %edx,%eax
 8f2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8f5:	75 20                	jne    917 <free+0xcf>
    p->s.size += bp->s.size;
 8f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fa:	8b 50 04             	mov    0x4(%eax),%edx
 8fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 900:	8b 40 04             	mov    0x4(%eax),%eax
 903:	01 c2                	add    %eax,%edx
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 90b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90e:	8b 10                	mov    (%eax),%edx
 910:	8b 45 fc             	mov    -0x4(%ebp),%eax
 913:	89 10                	mov    %edx,(%eax)
 915:	eb 08                	jmp    91f <free+0xd7>
  } else
    p->s.ptr = bp;
 917:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 91d:	89 10                	mov    %edx,(%eax)
  freep = p;
 91f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 922:	a3 b4 0d 00 00       	mov    %eax,0xdb4
}
 927:	c9                   	leave  
 928:	c3                   	ret    

00000929 <morecore>:

static Header*
morecore(uint nu)
{
 929:	55                   	push   %ebp
 92a:	89 e5                	mov    %esp,%ebp
 92c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 92f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 936:	77 07                	ja     93f <morecore+0x16>
    nu = 4096;
 938:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 93f:	8b 45 08             	mov    0x8(%ebp),%eax
 942:	c1 e0 03             	shl    $0x3,%eax
 945:	89 04 24             	mov    %eax,(%esp)
 948:	e8 4f fc ff ff       	call   59c <sbrk>
 94d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 950:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 954:	75 07                	jne    95d <morecore+0x34>
    return 0;
 956:	b8 00 00 00 00       	mov    $0x0,%eax
 95b:	eb 22                	jmp    97f <morecore+0x56>
  hp = (Header*)p;
 95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 960:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 963:	8b 45 f0             	mov    -0x10(%ebp),%eax
 966:	8b 55 08             	mov    0x8(%ebp),%edx
 969:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 96c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96f:	83 c0 08             	add    $0x8,%eax
 972:	89 04 24             	mov    %eax,(%esp)
 975:	e8 ce fe ff ff       	call   848 <free>
  return freep;
 97a:	a1 b4 0d 00 00       	mov    0xdb4,%eax
}
 97f:	c9                   	leave  
 980:	c3                   	ret    

00000981 <malloc>:

void*
malloc(uint nbytes)
{
 981:	55                   	push   %ebp
 982:	89 e5                	mov    %esp,%ebp
 984:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 987:	8b 45 08             	mov    0x8(%ebp),%eax
 98a:	83 c0 07             	add    $0x7,%eax
 98d:	c1 e8 03             	shr    $0x3,%eax
 990:	83 c0 01             	add    $0x1,%eax
 993:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 996:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 99b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 99e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9a2:	75 23                	jne    9c7 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9a4:	c7 45 f0 ac 0d 00 00 	movl   $0xdac,-0x10(%ebp)
 9ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ae:	a3 b4 0d 00 00       	mov    %eax,0xdb4
 9b3:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 9b8:	a3 ac 0d 00 00       	mov    %eax,0xdac
    base.s.size = 0;
 9bd:	c7 05 b0 0d 00 00 00 	movl   $0x0,0xdb0
 9c4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ca:	8b 00                	mov    (%eax),%eax
 9cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d2:	8b 40 04             	mov    0x4(%eax),%eax
 9d5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9d8:	72 4d                	jb     a27 <malloc+0xa6>
      if(p->s.size == nunits)
 9da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dd:	8b 40 04             	mov    0x4(%eax),%eax
 9e0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9e3:	75 0c                	jne    9f1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e8:	8b 10                	mov    (%eax),%edx
 9ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ed:	89 10                	mov    %edx,(%eax)
 9ef:	eb 26                	jmp    a17 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f4:	8b 40 04             	mov    0x4(%eax),%eax
 9f7:	89 c2                	mov    %eax,%edx
 9f9:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a05:	8b 40 04             	mov    0x4(%eax),%eax
 a08:	c1 e0 03             	shl    $0x3,%eax
 a0b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a14:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1a:	a3 b4 0d 00 00       	mov    %eax,0xdb4
      return (void*)(p + 1);
 a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a22:	83 c0 08             	add    $0x8,%eax
 a25:	eb 38                	jmp    a5f <malloc+0xde>
    }
    if(p == freep)
 a27:	a1 b4 0d 00 00       	mov    0xdb4,%eax
 a2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a2f:	75 1b                	jne    a4c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a34:	89 04 24             	mov    %eax,(%esp)
 a37:	e8 ed fe ff ff       	call   929 <morecore>
 a3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a43:	75 07                	jne    a4c <malloc+0xcb>
        return 0;
 a45:	b8 00 00 00 00       	mov    $0x0,%eax
 a4a:	eb 13                	jmp    a5f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a55:	8b 00                	mov    (%eax),%eax
 a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a5a:	e9 70 ff ff ff       	jmp    9cf <malloc+0x4e>
}
 a5f:	c9                   	leave  
 a60:	c3                   	ret    
