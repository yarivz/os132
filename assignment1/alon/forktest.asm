
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  write(fd, s, strlen(s));
   6:	8b 45 0c             	mov    0xc(%ebp),%eax
   9:	89 04 24             	mov    %eax,(%esp)
   c:	e8 9d 01 00 00       	call   1ae <strlen>
  11:	89 44 24 08          	mov    %eax,0x8(%esp)
  15:	8b 45 0c             	mov    0xc(%ebp),%eax
  18:	89 44 24 04          	mov    %eax,0x4(%esp)
  1c:	8b 45 08             	mov    0x8(%ebp),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 19 05 00 00       	call   540 <write>
}
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <forktest>:

void
forktest(void)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
  2f:	c7 44 24 04 c0 05 00 	movl   $0x5c0,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 bd ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 1d                	jmp    69 <forktest+0x40>
    pid = fork();
  4c:	e8 b7 04 00 00       	call   508 <fork>
  51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  58:	78 1a                	js     74 <forktest+0x4b>
      break;
    if(pid == 0)
  5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5e:	75 05                	jne    65 <forktest+0x3c>
      exit();
  60:	e8 ab 04 00 00       	call   510 <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<N; n++){
  65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  69:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
  70:	7e da                	jle    4c <forktest+0x23>
  72:	eb 01                	jmp    75 <forktest+0x4c>
    pid = fork();
    if(pid < 0)
      break;
  74:	90                   	nop
    if(pid == 0)
      exit();
  }
  
  if(n == N){
  75:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
  7c:	75 47                	jne    c5 <forktest+0x9c>
    printf(1, "fork claimed to work N times!\n", N);
  7e:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  85:	00 
  86:	c7 44 24 04 cc 05 00 	movl   $0x5cc,0x4(%esp)
  8d:	00 
  8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  95:	e8 66 ff ff ff       	call   0 <printf>
    exit();
  9a:	e8 71 04 00 00       	call   510 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
  9f:	e8 74 04 00 00       	call   518 <wait>
  a4:	85 c0                	test   %eax,%eax
  a6:	79 19                	jns    c1 <forktest+0x98>
      printf(1, "wait stopped early\n");
  a8:	c7 44 24 04 eb 05 00 	movl   $0x5eb,0x4(%esp)
  af:	00 
  b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b7:	e8 44 ff ff ff       	call   0 <printf>
      exit();
  bc:	e8 4f 04 00 00       	call   510 <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }
  
  for(; n > 0; n--){
  c1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  c9:	7f d4                	jg     9f <forktest+0x76>
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
  cb:	e8 48 04 00 00       	call   518 <wait>
  d0:	83 f8 ff             	cmp    $0xffffffff,%eax
  d3:	74 19                	je     ee <forktest+0xc5>
    printf(1, "wait got too many\n");
  d5:	c7 44 24 04 ff 05 00 	movl   $0x5ff,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e4:	e8 17 ff ff ff       	call   0 <printf>
    exit();
  e9:	e8 22 04 00 00       	call   510 <exit>
  }
  
  printf(1, "fork test OK\n");
  ee:	c7 44 24 04 12 06 00 	movl   $0x612,0x4(%esp)
  f5:	00 
  f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fd:	e8 fe fe ff ff       	call   0 <printf>
}
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <main>:

int
main(void)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	83 e4 f0             	and    $0xfffffff0,%esp
  forktest();
 10a:	e8 1a ff ff ff       	call   29 <forktest>
  exit();
 10f:	e8 fc 03 00 00       	call   510 <exit>

00000114 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	57                   	push   %edi
 118:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 119:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11c:	8b 55 10             	mov    0x10(%ebp),%edx
 11f:	8b 45 0c             	mov    0xc(%ebp),%eax
 122:	89 cb                	mov    %ecx,%ebx
 124:	89 df                	mov    %ebx,%edi
 126:	89 d1                	mov    %edx,%ecx
 128:	fc                   	cld    
 129:	f3 aa                	rep stos %al,%es:(%edi)
 12b:	89 ca                	mov    %ecx,%edx
 12d:	89 fb                	mov    %edi,%ebx
 12f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 132:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 135:	5b                   	pop    %ebx
 136:	5f                   	pop    %edi
 137:	5d                   	pop    %ebp
 138:	c3                   	ret    

00000139 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 145:	90                   	nop
 146:	8b 45 0c             	mov    0xc(%ebp),%eax
 149:	0f b6 10             	movzbl (%eax),%edx
 14c:	8b 45 08             	mov    0x8(%ebp),%eax
 14f:	88 10                	mov    %dl,(%eax)
 151:	8b 45 08             	mov    0x8(%ebp),%eax
 154:	0f b6 00             	movzbl (%eax),%eax
 157:	84 c0                	test   %al,%al
 159:	0f 95 c0             	setne  %al
 15c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 160:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 164:	84 c0                	test   %al,%al
 166:	75 de                	jne    146 <strcpy+0xd>
    ;
  return os;
 168:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 16b:	c9                   	leave  
 16c:	c3                   	ret    

0000016d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16d:	55                   	push   %ebp
 16e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 170:	eb 08                	jmp    17a <strcmp+0xd>
    p++, q++;
 172:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 176:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	0f b6 00             	movzbl (%eax),%eax
 180:	84 c0                	test   %al,%al
 182:	74 10                	je     194 <strcmp+0x27>
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	0f b6 10             	movzbl (%eax),%edx
 18a:	8b 45 0c             	mov    0xc(%ebp),%eax
 18d:	0f b6 00             	movzbl (%eax),%eax
 190:	38 c2                	cmp    %al,%dl
 192:	74 de                	je     172 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	0f b6 d0             	movzbl %al,%edx
 19d:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	0f b6 c0             	movzbl %al,%eax
 1a6:	89 d1                	mov    %edx,%ecx
 1a8:	29 c1                	sub    %eax,%ecx
 1aa:	89 c8                	mov    %ecx,%eax
}
 1ac:	5d                   	pop    %ebp
 1ad:	c3                   	ret    

000001ae <strlen>:

uint
strlen(char *s)
{
 1ae:	55                   	push   %ebp
 1af:	89 e5                	mov    %esp,%ebp
 1b1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 1b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1bb:	eb 04                	jmp    1c1 <strlen+0x13>
 1bd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1c4:	03 45 08             	add    0x8(%ebp),%eax
 1c7:	0f b6 00             	movzbl (%eax),%eax
 1ca:	84 c0                	test   %al,%al
 1cc:	75 ef                	jne    1bd <strlen+0xf>
  return n;
 1ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d1:	c9                   	leave  
 1d2:	c3                   	ret    

000001d3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d9:	8b 45 10             	mov    0x10(%ebp),%eax
 1dc:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	89 04 24             	mov    %eax,(%esp)
 1ed:	e8 22 ff ff ff       	call   114 <stosb>
  return dst;
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f5:	c9                   	leave  
 1f6:	c3                   	ret    

000001f7 <strchr>:

char*
strchr(const char *s, char c)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 04             	sub    $0x4,%esp
 1fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 200:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 203:	eb 14                	jmp    219 <strchr+0x22>
    if(*s == c)
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	0f b6 00             	movzbl (%eax),%eax
 20b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 20e:	75 05                	jne    215 <strchr+0x1e>
      return (char*)s;
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	eb 13                	jmp    228 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 215:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	0f b6 00             	movzbl (%eax),%eax
 21f:	84 c0                	test   %al,%al
 221:	75 e2                	jne    205 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 223:	b8 00 00 00 00       	mov    $0x0,%eax
}
 228:	c9                   	leave  
 229:	c3                   	ret    

0000022a <gets>:

char*
gets(char *buf, int max)
{
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
 22d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 230:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 237:	eb 44                	jmp    27d <gets+0x53>
    cc = read(0, &c, 1);
 239:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 240:	00 
 241:	8d 45 ef             	lea    -0x11(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 24f:	e8 e4 02 00 00       	call   538 <read>
 254:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 257:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 25b:	7e 2d                	jle    28a <gets+0x60>
      break;
    buf[i++] = c;
 25d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 260:	03 45 08             	add    0x8(%ebp),%eax
 263:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 267:	88 10                	mov    %dl,(%eax)
 269:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 26d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 271:	3c 0a                	cmp    $0xa,%al
 273:	74 16                	je     28b <gets+0x61>
 275:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 279:	3c 0d                	cmp    $0xd,%al
 27b:	74 0e                	je     28b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 280:	83 c0 01             	add    $0x1,%eax
 283:	3b 45 0c             	cmp    0xc(%ebp),%eax
 286:	7c b1                	jl     239 <gets+0xf>
 288:	eb 01                	jmp    28b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 28a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 28b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28e:	03 45 08             	add    0x8(%ebp),%eax
 291:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 294:	8b 45 08             	mov    0x8(%ebp),%eax
}
 297:	c9                   	leave  
 298:	c3                   	ret    

00000299 <stat>:

int
stat(char *n, struct stat *st)
{
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a6:	00 
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	89 04 24             	mov    %eax,(%esp)
 2ad:	e8 ae 02 00 00       	call   560 <open>
 2b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b9:	79 07                	jns    2c2 <stat+0x29>
    return -1;
 2bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2c0:	eb 23                	jmp    2e5 <stat+0x4c>
  r = fstat(fd, st);
 2c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cc:	89 04 24             	mov    %eax,(%esp)
 2cf:	e8 a4 02 00 00       	call   578 <fstat>
 2d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2da:	89 04 24             	mov    %eax,(%esp)
 2dd:	e8 66 02 00 00       	call   548 <close>
  return r;
 2e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e5:	c9                   	leave  
 2e6:	c3                   	ret    

000002e7 <atoi>:

int
atoi(const char *s)
{
 2e7:	55                   	push   %ebp
 2e8:	89 e5                	mov    %esp,%ebp
 2ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f4:	eb 23                	jmp    319 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f9:	89 d0                	mov    %edx,%eax
 2fb:	c1 e0 02             	shl    $0x2,%eax
 2fe:	01 d0                	add    %edx,%eax
 300:	01 c0                	add    %eax,%eax
 302:	89 c2                	mov    %eax,%edx
 304:	8b 45 08             	mov    0x8(%ebp),%eax
 307:	0f b6 00             	movzbl (%eax),%eax
 30a:	0f be c0             	movsbl %al,%eax
 30d:	01 d0                	add    %edx,%eax
 30f:	83 e8 30             	sub    $0x30,%eax
 312:	89 45 fc             	mov    %eax,-0x4(%ebp)
 315:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	3c 2f                	cmp    $0x2f,%al
 321:	7e 0a                	jle    32d <atoi+0x46>
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	3c 39                	cmp    $0x39,%al
 32b:	7e c9                	jle    2f6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33e:	8b 45 0c             	mov    0xc(%ebp),%eax
 341:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 344:	eb 13                	jmp    359 <memmove+0x27>
    *dst++ = *src++;
 346:	8b 45 f8             	mov    -0x8(%ebp),%eax
 349:	0f b6 10             	movzbl (%eax),%edx
 34c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 34f:	88 10                	mov    %dl,(%eax)
 351:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 355:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 359:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 35d:	0f 9f c0             	setg   %al
 360:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 364:	84 c0                	test   %al,%al
 366:	75 de                	jne    346 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 368:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36b:	c9                   	leave  
 36c:	c3                   	ret    

0000036d <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 36d:	55                   	push   %ebp
 36e:	89 e5                	mov    %esp,%ebp
 370:	83 ec 38             	sub    $0x38,%esp
 373:	8b 45 10             	mov    0x10(%ebp),%eax
 376:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 379:	8b 45 14             	mov    0x14(%ebp),%eax
 37c:	8b 00                	mov    (%eax),%eax
 37e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 381:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 388:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 38c:	74 06                	je     394 <strtok+0x27>
 38e:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 392:	75 54                	jne    3e8 <strtok+0x7b>
    return match;
 394:	8b 45 f0             	mov    -0x10(%ebp),%eax
 397:	eb 6e                	jmp    407 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 399:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39c:	03 45 0c             	add    0xc(%ebp),%eax
 39f:	0f b6 00             	movzbl (%eax),%eax
 3a2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3a5:	74 06                	je     3ad <strtok+0x40>
      {
	index++;
 3a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3ab:	eb 3c                	jmp    3e9 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 3ad:	8b 45 14             	mov    0x14(%ebp),%eax
 3b0:	8b 00                	mov    (%eax),%eax
 3b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3b5:	29 c2                	sub    %eax,%edx
 3b7:	8b 45 14             	mov    0x14(%ebp),%eax
 3ba:	8b 00                	mov    (%eax),%eax
 3bc:	03 45 0c             	add    0xc(%ebp),%eax
 3bf:	89 54 24 08          	mov    %edx,0x8(%esp)
 3c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ca:	89 04 24             	mov    %eax,(%esp)
 3cd:	e8 37 00 00 00       	call   409 <strncpy>
 3d2:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	0f b6 00             	movzbl (%eax),%eax
 3db:	84 c0                	test   %al,%al
 3dd:	74 19                	je     3f8 <strtok+0x8b>
	  match = 1;
 3df:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 3e6:	eb 10                	jmp    3f8 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 3e8:	90                   	nop
 3e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ec:	03 45 0c             	add    0xc(%ebp),%eax
 3ef:	0f b6 00             	movzbl (%eax),%eax
 3f2:	84 c0                	test   %al,%al
 3f4:	75 a3                	jne    399 <strtok+0x2c>
 3f6:	eb 01                	jmp    3f9 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 3f8:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 3f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fc:	8d 50 01             	lea    0x1(%eax),%edx
 3ff:	8b 45 14             	mov    0x14(%ebp),%eax
 402:	89 10                	mov    %edx,(%eax)
  return match;
 404:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 407:	c9                   	leave  
 408:	c3                   	ret    

00000409 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 409:	55                   	push   %ebp
 40a:	89 e5                	mov    %esp,%ebp
 40c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 40f:	8b 45 08             	mov    0x8(%ebp),%eax
 412:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 415:	90                   	nop
 416:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 41a:	0f 9f c0             	setg   %al
 41d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 421:	84 c0                	test   %al,%al
 423:	74 30                	je     455 <strncpy+0x4c>
 425:	8b 45 0c             	mov    0xc(%ebp),%eax
 428:	0f b6 10             	movzbl (%eax),%edx
 42b:	8b 45 08             	mov    0x8(%ebp),%eax
 42e:	88 10                	mov    %dl,(%eax)
 430:	8b 45 08             	mov    0x8(%ebp),%eax
 433:	0f b6 00             	movzbl (%eax),%eax
 436:	84 c0                	test   %al,%al
 438:	0f 95 c0             	setne  %al
 43b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 443:	84 c0                	test   %al,%al
 445:	75 cf                	jne    416 <strncpy+0xd>
    ;
  while(n-- > 0)
 447:	eb 0c                	jmp    455 <strncpy+0x4c>
    *s++ = 0;
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	c6 00 00             	movb   $0x0,(%eax)
 44f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 453:	eb 01                	jmp    456 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 455:	90                   	nop
 456:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 45a:	0f 9f c0             	setg   %al
 45d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 461:	84 c0                	test   %al,%al
 463:	75 e4                	jne    449 <strncpy+0x40>
    *s++ = 0;
  return os;
 465:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 468:	c9                   	leave  
 469:	c3                   	ret    

0000046a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 46a:	55                   	push   %ebp
 46b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 46d:	eb 0c                	jmp    47b <strncmp+0x11>
    n--, p++, q++;
 46f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 473:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 477:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 47b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 47f:	74 1a                	je     49b <strncmp+0x31>
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	0f b6 00             	movzbl (%eax),%eax
 487:	84 c0                	test   %al,%al
 489:	74 10                	je     49b <strncmp+0x31>
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	0f b6 10             	movzbl (%eax),%edx
 491:	8b 45 0c             	mov    0xc(%ebp),%eax
 494:	0f b6 00             	movzbl (%eax),%eax
 497:	38 c2                	cmp    %al,%dl
 499:	74 d4                	je     46f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 49b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 49f:	75 07                	jne    4a8 <strncmp+0x3e>
    return 0;
 4a1:	b8 00 00 00 00       	mov    $0x0,%eax
 4a6:	eb 18                	jmp    4c0 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4a8:	8b 45 08             	mov    0x8(%ebp),%eax
 4ab:	0f b6 00             	movzbl (%eax),%eax
 4ae:	0f b6 d0             	movzbl %al,%edx
 4b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b4:	0f b6 00             	movzbl (%eax),%eax
 4b7:	0f b6 c0             	movzbl %al,%eax
 4ba:	89 d1                	mov    %edx,%ecx
 4bc:	29 c1                	sub    %eax,%ecx
 4be:	89 c8                	mov    %ecx,%eax
}
 4c0:	5d                   	pop    %ebp
 4c1:	c3                   	ret    

000004c2 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 4c2:	55                   	push   %ebp
 4c3:	89 e5                	mov    %esp,%ebp
  while(*p){
 4c5:	eb 13                	jmp    4da <strcat+0x18>
    *dest++ = *p++;
 4c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ca:	0f b6 10             	movzbl (%eax),%edx
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	88 10                	mov    %dl,(%eax)
 4d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4d6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 4da:	8b 45 0c             	mov    0xc(%ebp),%eax
 4dd:	0f b6 00             	movzbl (%eax),%eax
 4e0:	84 c0                	test   %al,%al
 4e2:	75 e3                	jne    4c7 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 4e4:	eb 13                	jmp    4f9 <strcat+0x37>
    *dest++ = *q++;
 4e6:	8b 45 10             	mov    0x10(%ebp),%eax
 4e9:	0f b6 10             	movzbl (%eax),%edx
 4ec:	8b 45 08             	mov    0x8(%ebp),%eax
 4ef:	88 10                	mov    %dl,(%eax)
 4f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4f5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 4f9:	8b 45 10             	mov    0x10(%ebp),%eax
 4fc:	0f b6 00             	movzbl (%eax),%eax
 4ff:	84 c0                	test   %al,%al
 501:	75 e3                	jne    4e6 <strcat+0x24>
    *dest++ = *q++;
  }  
 503:	5d                   	pop    %ebp
 504:	c3                   	ret    
 505:	90                   	nop
 506:	90                   	nop
 507:	90                   	nop

00000508 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 508:	b8 01 00 00 00       	mov    $0x1,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <exit>:
SYSCALL(exit)
 510:	b8 02 00 00 00       	mov    $0x2,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <wait>:
SYSCALL(wait)
 518:	b8 03 00 00 00       	mov    $0x3,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <wait2>:
SYSCALL(wait2)
 520:	b8 16 00 00 00       	mov    $0x16,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <nice>:
SYSCALL(nice)
 528:	b8 17 00 00 00       	mov    $0x17,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <pipe>:
SYSCALL(pipe)
 530:	b8 04 00 00 00       	mov    $0x4,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <read>:
SYSCALL(read)
 538:	b8 05 00 00 00       	mov    $0x5,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <write>:
SYSCALL(write)
 540:	b8 10 00 00 00       	mov    $0x10,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <close>:
SYSCALL(close)
 548:	b8 15 00 00 00       	mov    $0x15,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <kill>:
SYSCALL(kill)
 550:	b8 06 00 00 00       	mov    $0x6,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <exec>:
SYSCALL(exec)
 558:	b8 07 00 00 00       	mov    $0x7,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <open>:
SYSCALL(open)
 560:	b8 0f 00 00 00       	mov    $0xf,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <mknod>:
SYSCALL(mknod)
 568:	b8 11 00 00 00       	mov    $0x11,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <unlink>:
SYSCALL(unlink)
 570:	b8 12 00 00 00       	mov    $0x12,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <fstat>:
SYSCALL(fstat)
 578:	b8 08 00 00 00       	mov    $0x8,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <link>:
SYSCALL(link)
 580:	b8 13 00 00 00       	mov    $0x13,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <mkdir>:
SYSCALL(mkdir)
 588:	b8 14 00 00 00       	mov    $0x14,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <chdir>:
SYSCALL(chdir)
 590:	b8 09 00 00 00       	mov    $0x9,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <dup>:
SYSCALL(dup)
 598:	b8 0a 00 00 00       	mov    $0xa,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <getpid>:
SYSCALL(getpid)
 5a0:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <sbrk>:
SYSCALL(sbrk)
 5a8:	b8 0c 00 00 00       	mov    $0xc,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <sleep>:
SYSCALL(sleep)
 5b0:	b8 0d 00 00 00       	mov    $0xd,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <uptime>:
SYSCALL(uptime)
 5b8:	b8 0e 00 00 00       	mov    $0xe,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    
