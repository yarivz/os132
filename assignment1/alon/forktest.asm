
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
  22:	e8 25 05 00 00       	call   54c <write>
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
  2f:	c7 44 24 04 cc 05 00 	movl   $0x5cc,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 bd ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 1d                	jmp    69 <forktest+0x40>
    pid = fork();
  4c:	e8 c3 04 00 00       	call   514 <fork>
  51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  58:	78 1a                	js     74 <forktest+0x4b>
      break;
    if(pid == 0)
  5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5e:	75 05                	jne    65 <forktest+0x3c>
      exit();
  60:	e8 b7 04 00 00       	call   51c <exit>
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
  86:	c7 44 24 04 d8 05 00 	movl   $0x5d8,0x4(%esp)
  8d:	00 
  8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  95:	e8 66 ff ff ff       	call   0 <printf>
    exit();
  9a:	e8 7d 04 00 00       	call   51c <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
  9f:	e8 80 04 00 00       	call   524 <wait>
  a4:	85 c0                	test   %eax,%eax
  a6:	79 19                	jns    c1 <forktest+0x98>
      printf(1, "wait stopped early\n");
  a8:	c7 44 24 04 f7 05 00 	movl   $0x5f7,0x4(%esp)
  af:	00 
  b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b7:	e8 44 ff ff ff       	call   0 <printf>
      exit();
  bc:	e8 5b 04 00 00       	call   51c <exit>
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
  cb:	e8 54 04 00 00       	call   524 <wait>
  d0:	83 f8 ff             	cmp    $0xffffffff,%eax
  d3:	74 19                	je     ee <forktest+0xc5>
    printf(1, "wait got too many\n");
  d5:	c7 44 24 04 0b 06 00 	movl   $0x60b,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e4:	e8 17 ff ff ff       	call   0 <printf>
    exit();
  e9:	e8 2e 04 00 00       	call   51c <exit>
  }
  
  printf(1, "fork test OK\n");
  ee:	c7 44 24 04 1e 06 00 	movl   $0x61e,0x4(%esp)
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
 10f:	e8 08 04 00 00       	call   51c <exit>

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
 1c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
 1c7:	01 d0                	add    %edx,%eax
 1c9:	0f b6 00             	movzbl (%eax),%eax
 1cc:	84 c0                	test   %al,%al
 1ce:	75 ed                	jne    1bd <strlen+0xf>
  return n;
 1d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d3:	c9                   	leave  
 1d4:	c3                   	ret    

000001d5 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d5:	55                   	push   %ebp
 1d6:	89 e5                	mov    %esp,%ebp
 1d8:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1db:	8b 45 10             	mov    0x10(%ebp),%eax
 1de:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ec:	89 04 24             	mov    %eax,(%esp)
 1ef:	e8 20 ff ff ff       	call   114 <stosb>
  return dst;
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f7:	c9                   	leave  
 1f8:	c3                   	ret    

000001f9 <strchr>:

char*
strchr(const char *s, char c)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	83 ec 04             	sub    $0x4,%esp
 1ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 202:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 205:	eb 14                	jmp    21b <strchr+0x22>
    if(*s == c)
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	0f b6 00             	movzbl (%eax),%eax
 20d:	3a 45 fc             	cmp    -0x4(%ebp),%al
 210:	75 05                	jne    217 <strchr+0x1e>
      return (char*)s;
 212:	8b 45 08             	mov    0x8(%ebp),%eax
 215:	eb 13                	jmp    22a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 217:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	0f b6 00             	movzbl (%eax),%eax
 221:	84 c0                	test   %al,%al
 223:	75 e2                	jne    207 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 225:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22a:	c9                   	leave  
 22b:	c3                   	ret    

0000022c <gets>:

char*
gets(char *buf, int max)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
 22f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 232:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 239:	eb 46                	jmp    281 <gets+0x55>
    cc = read(0, &c, 1);
 23b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 242:	00 
 243:	8d 45 ef             	lea    -0x11(%ebp),%eax
 246:	89 44 24 04          	mov    %eax,0x4(%esp)
 24a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 251:	e8 ee 02 00 00       	call   544 <read>
 256:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 259:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 25d:	7e 2f                	jle    28e <gets+0x62>
      break;
    buf[i++] = c;
 25f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	01 c2                	add    %eax,%edx
 267:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26b:	88 02                	mov    %al,(%edx)
 26d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 271:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 275:	3c 0a                	cmp    $0xa,%al
 277:	74 16                	je     28f <gets+0x63>
 279:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27d:	3c 0d                	cmp    $0xd,%al
 27f:	74 0e                	je     28f <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 281:	8b 45 f4             	mov    -0xc(%ebp),%eax
 284:	83 c0 01             	add    $0x1,%eax
 287:	3b 45 0c             	cmp    0xc(%ebp),%eax
 28a:	7c af                	jl     23b <gets+0xf>
 28c:	eb 01                	jmp    28f <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 28e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 28f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	01 d0                	add    %edx,%eax
 297:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29d:	c9                   	leave  
 29e:	c3                   	ret    

0000029f <stat>:

int
stat(char *n, struct stat *st)
{
 29f:	55                   	push   %ebp
 2a0:	89 e5                	mov    %esp,%ebp
 2a2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2ac:	00 
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	89 04 24             	mov    %eax,(%esp)
 2b3:	e8 b4 02 00 00       	call   56c <open>
 2b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2bf:	79 07                	jns    2c8 <stat+0x29>
    return -1;
 2c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2c6:	eb 23                	jmp    2eb <stat+0x4c>
  r = fstat(fd, st);
 2c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 2cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d2:	89 04 24             	mov    %eax,(%esp)
 2d5:	e8 aa 02 00 00       	call   584 <fstat>
 2da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e0:	89 04 24             	mov    %eax,(%esp)
 2e3:	e8 6c 02 00 00       	call   554 <close>
  return r;
 2e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2eb:	c9                   	leave  
 2ec:	c3                   	ret    

000002ed <atoi>:

int
atoi(const char *s)
{
 2ed:	55                   	push   %ebp
 2ee:	89 e5                	mov    %esp,%ebp
 2f0:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2fa:	eb 23                	jmp    31f <atoi+0x32>
    n = n*10 + *s++ - '0';
 2fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2ff:	89 d0                	mov    %edx,%eax
 301:	c1 e0 02             	shl    $0x2,%eax
 304:	01 d0                	add    %edx,%eax
 306:	01 c0                	add    %eax,%eax
 308:	89 c2                	mov    %eax,%edx
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	0f b6 00             	movzbl (%eax),%eax
 310:	0f be c0             	movsbl %al,%eax
 313:	01 d0                	add    %edx,%eax
 315:	83 e8 30             	sub    $0x30,%eax
 318:	89 45 fc             	mov    %eax,-0x4(%ebp)
 31b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	0f b6 00             	movzbl (%eax),%eax
 325:	3c 2f                	cmp    $0x2f,%al
 327:	7e 0a                	jle    333 <atoi+0x46>
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	3c 39                	cmp    $0x39,%al
 331:	7e c9                	jle    2fc <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 333:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 336:	c9                   	leave  
 337:	c3                   	ret    

00000338 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 338:	55                   	push   %ebp
 339:	89 e5                	mov    %esp,%ebp
 33b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 33e:	8b 45 08             	mov    0x8(%ebp),%eax
 341:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 344:	8b 45 0c             	mov    0xc(%ebp),%eax
 347:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 34a:	eb 13                	jmp    35f <memmove+0x27>
    *dst++ = *src++;
 34c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 34f:	0f b6 10             	movzbl (%eax),%edx
 352:	8b 45 fc             	mov    -0x4(%ebp),%eax
 355:	88 10                	mov    %dl,(%eax)
 357:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 35b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 363:	0f 9f c0             	setg   %al
 366:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 36a:	84 c0                	test   %al,%al
 36c:	75 de                	jne    34c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 371:	c9                   	leave  
 372:	c3                   	ret    

00000373 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 373:	55                   	push   %ebp
 374:	89 e5                	mov    %esp,%ebp
 376:	83 ec 38             	sub    $0x38,%esp
 379:	8b 45 10             	mov    0x10(%ebp),%eax
 37c:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 37f:	8b 45 14             	mov    0x14(%ebp),%eax
 382:	8b 00                	mov    (%eax),%eax
 384:	89 45 f4             	mov    %eax,-0xc(%ebp)
 387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 38e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 392:	74 06                	je     39a <strtok+0x27>
 394:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 398:	75 5a                	jne    3f4 <strtok+0x81>
    return match;
 39a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 39d:	eb 76                	jmp    415 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 39f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a5:	01 d0                	add    %edx,%eax
 3a7:	0f b6 00             	movzbl (%eax),%eax
 3aa:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3ad:	74 06                	je     3b5 <strtok+0x42>
      {
	index++;
 3af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3b3:	eb 40                	jmp    3f5 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 3b5:	8b 45 14             	mov    0x14(%ebp),%eax
 3b8:	8b 00                	mov    (%eax),%eax
 3ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3bd:	29 c2                	sub    %eax,%edx
 3bf:	8b 45 14             	mov    0x14(%ebp),%eax
 3c2:	8b 00                	mov    (%eax),%eax
 3c4:	89 c1                	mov    %eax,%ecx
 3c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c9:	01 c8                	add    %ecx,%eax
 3cb:	89 54 24 08          	mov    %edx,0x8(%esp)
 3cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	89 04 24             	mov    %eax,(%esp)
 3d9:	e8 39 00 00 00       	call   417 <strncpy>
 3de:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 3e1:	8b 45 08             	mov    0x8(%ebp),%eax
 3e4:	0f b6 00             	movzbl (%eax),%eax
 3e7:	84 c0                	test   %al,%al
 3e9:	74 1b                	je     406 <strtok+0x93>
	  match = 1;
 3eb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 3f2:	eb 12                	jmp    406 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 3f4:	90                   	nop
 3f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fb:	01 d0                	add    %edx,%eax
 3fd:	0f b6 00             	movzbl (%eax),%eax
 400:	84 c0                	test   %al,%al
 402:	75 9b                	jne    39f <strtok+0x2c>
 404:	eb 01                	jmp    407 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 406:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 407:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40a:	8d 50 01             	lea    0x1(%eax),%edx
 40d:	8b 45 14             	mov    0x14(%ebp),%eax
 410:	89 10                	mov    %edx,(%eax)
  return match;
 412:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 415:	c9                   	leave  
 416:	c3                   	ret    

00000417 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 417:	55                   	push   %ebp
 418:	89 e5                	mov    %esp,%ebp
 41a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
 420:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 423:	90                   	nop
 424:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 428:	0f 9f c0             	setg   %al
 42b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 42f:	84 c0                	test   %al,%al
 431:	74 30                	je     463 <strncpy+0x4c>
 433:	8b 45 0c             	mov    0xc(%ebp),%eax
 436:	0f b6 10             	movzbl (%eax),%edx
 439:	8b 45 08             	mov    0x8(%ebp),%eax
 43c:	88 10                	mov    %dl,(%eax)
 43e:	8b 45 08             	mov    0x8(%ebp),%eax
 441:	0f b6 00             	movzbl (%eax),%eax
 444:	84 c0                	test   %al,%al
 446:	0f 95 c0             	setne  %al
 449:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 44d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 451:	84 c0                	test   %al,%al
 453:	75 cf                	jne    424 <strncpy+0xd>
    ;
  while(n-- > 0)
 455:	eb 0c                	jmp    463 <strncpy+0x4c>
    *s++ = 0;
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	c6 00 00             	movb   $0x0,(%eax)
 45d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 461:	eb 01                	jmp    464 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 463:	90                   	nop
 464:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 468:	0f 9f c0             	setg   %al
 46b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 46f:	84 c0                	test   %al,%al
 471:	75 e4                	jne    457 <strncpy+0x40>
    *s++ = 0;
  return os;
 473:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 476:	c9                   	leave  
 477:	c3                   	ret    

00000478 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 478:	55                   	push   %ebp
 479:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 47b:	eb 0c                	jmp    489 <strncmp+0x11>
    n--, p++, q++;
 47d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 481:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 485:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 489:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 48d:	74 1a                	je     4a9 <strncmp+0x31>
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
 492:	0f b6 00             	movzbl (%eax),%eax
 495:	84 c0                	test   %al,%al
 497:	74 10                	je     4a9 <strncmp+0x31>
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	0f b6 10             	movzbl (%eax),%edx
 49f:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a2:	0f b6 00             	movzbl (%eax),%eax
 4a5:	38 c2                	cmp    %al,%dl
 4a7:	74 d4                	je     47d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 4a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4ad:	75 07                	jne    4b6 <strncmp+0x3e>
    return 0;
 4af:	b8 00 00 00 00       	mov    $0x0,%eax
 4b4:	eb 18                	jmp    4ce <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4b6:	8b 45 08             	mov    0x8(%ebp),%eax
 4b9:	0f b6 00             	movzbl (%eax),%eax
 4bc:	0f b6 d0             	movzbl %al,%edx
 4bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c2:	0f b6 00             	movzbl (%eax),%eax
 4c5:	0f b6 c0             	movzbl %al,%eax
 4c8:	89 d1                	mov    %edx,%ecx
 4ca:	29 c1                	sub    %eax,%ecx
 4cc:	89 c8                	mov    %ecx,%eax
}
 4ce:	5d                   	pop    %ebp
 4cf:	c3                   	ret    

000004d0 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
  while(*p){
 4d3:	eb 13                	jmp    4e8 <strcat+0x18>
    *dest++ = *p++;
 4d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d8:	0f b6 10             	movzbl (%eax),%edx
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	88 10                	mov    %dl,(%eax)
 4e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4e4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 4e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 4eb:	0f b6 00             	movzbl (%eax),%eax
 4ee:	84 c0                	test   %al,%al
 4f0:	75 e3                	jne    4d5 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 4f2:	eb 13                	jmp    507 <strcat+0x37>
    *dest++ = *q++;
 4f4:	8b 45 10             	mov    0x10(%ebp),%eax
 4f7:	0f b6 10             	movzbl (%eax),%edx
 4fa:	8b 45 08             	mov    0x8(%ebp),%eax
 4fd:	88 10                	mov    %dl,(%eax)
 4ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 503:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 507:	8b 45 10             	mov    0x10(%ebp),%eax
 50a:	0f b6 00             	movzbl (%eax),%eax
 50d:	84 c0                	test   %al,%al
 50f:	75 e3                	jne    4f4 <strcat+0x24>
    *dest++ = *q++;
  }  
 511:	5d                   	pop    %ebp
 512:	c3                   	ret    
 513:	90                   	nop

00000514 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 514:	b8 01 00 00 00       	mov    $0x1,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <exit>:
SYSCALL(exit)
 51c:	b8 02 00 00 00       	mov    $0x2,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <wait>:
SYSCALL(wait)
 524:	b8 03 00 00 00       	mov    $0x3,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <wait2>:
SYSCALL(wait2)
 52c:	b8 16 00 00 00       	mov    $0x16,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <nice>:
SYSCALL(nice)
 534:	b8 17 00 00 00       	mov    $0x17,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <pipe>:
SYSCALL(pipe)
 53c:	b8 04 00 00 00       	mov    $0x4,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <read>:
SYSCALL(read)
 544:	b8 05 00 00 00       	mov    $0x5,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <write>:
SYSCALL(write)
 54c:	b8 10 00 00 00       	mov    $0x10,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <close>:
SYSCALL(close)
 554:	b8 15 00 00 00       	mov    $0x15,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <kill>:
SYSCALL(kill)
 55c:	b8 06 00 00 00       	mov    $0x6,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <exec>:
SYSCALL(exec)
 564:	b8 07 00 00 00       	mov    $0x7,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <open>:
SYSCALL(open)
 56c:	b8 0f 00 00 00       	mov    $0xf,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <mknod>:
SYSCALL(mknod)
 574:	b8 11 00 00 00       	mov    $0x11,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <unlink>:
SYSCALL(unlink)
 57c:	b8 12 00 00 00       	mov    $0x12,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <fstat>:
SYSCALL(fstat)
 584:	b8 08 00 00 00       	mov    $0x8,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <link>:
SYSCALL(link)
 58c:	b8 13 00 00 00       	mov    $0x13,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <mkdir>:
SYSCALL(mkdir)
 594:	b8 14 00 00 00       	mov    $0x14,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <chdir>:
SYSCALL(chdir)
 59c:	b8 09 00 00 00       	mov    $0x9,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <dup>:
SYSCALL(dup)
 5a4:	b8 0a 00 00 00       	mov    $0xa,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <getpid>:
SYSCALL(getpid)
 5ac:	b8 0b 00 00 00       	mov    $0xb,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <sbrk>:
SYSCALL(sbrk)
 5b4:	b8 0c 00 00 00       	mov    $0xc,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <sleep>:
SYSCALL(sleep)
 5bc:	b8 0d 00 00 00       	mov    $0xd,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <uptime>:
SYSCALL(uptime)
 5c4:	b8 0e 00 00 00       	mov    $0xe,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    
