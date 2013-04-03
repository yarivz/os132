
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  int fd, i;
  char path[] = "stressfs0";
   c:	c7 84 24 1e 02 00 00 	movl   $0x65727473,0x21e(%esp)
  13:	73 74 72 65 
  17:	c7 84 24 22 02 00 00 	movl   $0x73667373,0x222(%esp)
  1e:	73 73 66 73 
  22:	66 c7 84 24 26 02 00 	movw   $0x30,0x226(%esp)
  29:	00 30 00 
  char data[512];

  printf(1, "stressfs starting\n");
  2c:	c7 44 24 04 f3 0a 00 	movl   $0xaf3,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 ef 06 00 00       	call   72f <printf>
  memset(data, 'a', sizeof(data));
  40:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  47:	00 
  48:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  4f:	00 
  50:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 17 02 00 00       	call   273 <memset>

  for(i = 0; i < 4; i++)
  5c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  63:	00 00 00 00 
  67:	eb 11                	jmp    7a <main+0x7a>
    if(fork() > 0)
  69:	e8 3a 05 00 00       	call   5a8 <fork>
  6e:	85 c0                	test   %eax,%eax
  70:	7f 14                	jg     86 <main+0x86>
  char data[512];

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
  72:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
  79:	01 
  7a:	83 bc 24 2c 02 00 00 	cmpl   $0x3,0x22c(%esp)
  81:	03 
  82:	7e e5                	jle    69 <main+0x69>
  84:	eb 01                	jmp    87 <main+0x87>
    if(fork() > 0)
      break;
  86:	90                   	nop

  printf(1, "write %d\n", i);
  87:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  92:	c7 44 24 04 06 0b 00 	movl   $0xb06,0x4(%esp)
  99:	00 
  9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a1:	e8 89 06 00 00       	call   72f <printf>

  path[8] += i;
  a6:	0f b6 84 24 26 02 00 	movzbl 0x226(%esp),%eax
  ad:	00 
  ae:	89 c2                	mov    %eax,%edx
  b0:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  b7:	01 d0                	add    %edx,%eax
  b9:	88 84 24 26 02 00 00 	mov    %al,0x226(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  c0:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  c7:	00 
  c8:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
  cf:	89 04 24             	mov    %eax,(%esp)
  d2:	e8 21 05 00 00       	call   5f8 <open>
  d7:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for(i = 0; i < 20; i++)
  de:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  e5:	00 00 00 00 
  e9:	eb 27                	jmp    112 <main+0x112>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  eb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  f2:	00 
  f3:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  fb:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 102:	89 04 24             	mov    %eax,(%esp)
 105:	e8 ce 04 00 00       	call   5d8 <write>

  printf(1, "write %d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 20; i++)
 10a:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 111:	01 
 112:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 119:	13 
 11a:	7e cf                	jle    eb <main+0xeb>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  close(fd);
 11c:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 123:	89 04 24             	mov    %eax,(%esp)
 126:	e8 b5 04 00 00       	call   5e0 <close>

  printf(1, "read\n");
 12b:	c7 44 24 04 10 0b 00 	movl   $0xb10,0x4(%esp)
 132:	00 
 133:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13a:	e8 f0 05 00 00       	call   72f <printf>

  fd = open(path, O_RDONLY);
 13f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 146:	00 
 147:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 a2 04 00 00       	call   5f8 <open>
 156:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for (i = 0; i < 20; i++)
 15d:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
 164:	00 00 00 00 
 168:	eb 27                	jmp    191 <main+0x191>
    read(fd, data, sizeof(data));
 16a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 171:	00 
 172:	8d 44 24 1e          	lea    0x1e(%esp),%eax
 176:	89 44 24 04          	mov    %eax,0x4(%esp)
 17a:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 181:	89 04 24             	mov    %eax,(%esp)
 184:	e8 47 04 00 00       	call   5d0 <read>
  close(fd);

  printf(1, "read\n");

  fd = open(path, O_RDONLY);
  for (i = 0; i < 20; i++)
 189:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 190:	01 
 191:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 198:	13 
 199:	7e cf                	jle    16a <main+0x16a>
    read(fd, data, sizeof(data));
  close(fd);
 19b:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 1a2:	89 04 24             	mov    %eax,(%esp)
 1a5:	e8 36 04 00 00       	call   5e0 <close>

  wait();
 1aa:	e8 09 04 00 00       	call   5b8 <wait>
  
  exit();
 1af:	e8 fc 03 00 00       	call   5b0 <exit>

000001b4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	57                   	push   %edi
 1b8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1bc:	8b 55 10             	mov    0x10(%ebp),%edx
 1bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c2:	89 cb                	mov    %ecx,%ebx
 1c4:	89 df                	mov    %ebx,%edi
 1c6:	89 d1                	mov    %edx,%ecx
 1c8:	fc                   	cld    
 1c9:	f3 aa                	rep stos %al,%es:(%edi)
 1cb:	89 ca                	mov    %ecx,%edx
 1cd:	89 fb                	mov    %edi,%ebx
 1cf:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1d2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1d5:	5b                   	pop    %ebx
 1d6:	5f                   	pop    %edi
 1d7:	5d                   	pop    %ebp
 1d8:	c3                   	ret    

000001d9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d9:	55                   	push   %ebp
 1da:	89 e5                	mov    %esp,%ebp
 1dc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1e5:	90                   	nop
 1e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e9:	0f b6 10             	movzbl (%eax),%edx
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	88 10                	mov    %dl,(%eax)
 1f1:	8b 45 08             	mov    0x8(%ebp),%eax
 1f4:	0f b6 00             	movzbl (%eax),%eax
 1f7:	84 c0                	test   %al,%al
 1f9:	0f 95 c0             	setne  %al
 1fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 200:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 204:	84 c0                	test   %al,%al
 206:	75 de                	jne    1e6 <strcpy+0xd>
    ;
  return os;
 208:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 20b:	c9                   	leave  
 20c:	c3                   	ret    

0000020d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20d:	55                   	push   %ebp
 20e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 210:	eb 08                	jmp    21a <strcmp+0xd>
    p++, q++;
 212:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 216:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
 21d:	0f b6 00             	movzbl (%eax),%eax
 220:	84 c0                	test   %al,%al
 222:	74 10                	je     234 <strcmp+0x27>
 224:	8b 45 08             	mov    0x8(%ebp),%eax
 227:	0f b6 10             	movzbl (%eax),%edx
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	0f b6 00             	movzbl (%eax),%eax
 230:	38 c2                	cmp    %al,%dl
 232:	74 de                	je     212 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	0f b6 00             	movzbl (%eax),%eax
 23a:	0f b6 d0             	movzbl %al,%edx
 23d:	8b 45 0c             	mov    0xc(%ebp),%eax
 240:	0f b6 00             	movzbl (%eax),%eax
 243:	0f b6 c0             	movzbl %al,%eax
 246:	89 d1                	mov    %edx,%ecx
 248:	29 c1                	sub    %eax,%ecx
 24a:	89 c8                	mov    %ecx,%eax
}
 24c:	5d                   	pop    %ebp
 24d:	c3                   	ret    

0000024e <strlen>:

uint
strlen(char *s)
{
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 254:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 25b:	eb 04                	jmp    261 <strlen+0x13>
 25d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 261:	8b 45 fc             	mov    -0x4(%ebp),%eax
 264:	03 45 08             	add    0x8(%ebp),%eax
 267:	0f b6 00             	movzbl (%eax),%eax
 26a:	84 c0                	test   %al,%al
 26c:	75 ef                	jne    25d <strlen+0xf>
  return n;
 26e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 271:	c9                   	leave  
 272:	c3                   	ret    

00000273 <memset>:

void*
memset(void *dst, int c, uint n)
{
 273:	55                   	push   %ebp
 274:	89 e5                	mov    %esp,%ebp
 276:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 279:	8b 45 10             	mov    0x10(%ebp),%eax
 27c:	89 44 24 08          	mov    %eax,0x8(%esp)
 280:	8b 45 0c             	mov    0xc(%ebp),%eax
 283:	89 44 24 04          	mov    %eax,0x4(%esp)
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	89 04 24             	mov    %eax,(%esp)
 28d:	e8 22 ff ff ff       	call   1b4 <stosb>
  return dst;
 292:	8b 45 08             	mov    0x8(%ebp),%eax
}
 295:	c9                   	leave  
 296:	c3                   	ret    

00000297 <strchr>:

char*
strchr(const char *s, char c)
{
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 04             	sub    $0x4,%esp
 29d:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2a3:	eb 14                	jmp    2b9 <strchr+0x22>
    if(*s == c)
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	0f b6 00             	movzbl (%eax),%eax
 2ab:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2ae:	75 05                	jne    2b5 <strchr+0x1e>
      return (char*)s;
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	eb 13                	jmp    2c8 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2b5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
 2bc:	0f b6 00             	movzbl (%eax),%eax
 2bf:	84 c0                	test   %al,%al
 2c1:	75 e2                	jne    2a5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c8:	c9                   	leave  
 2c9:	c3                   	ret    

000002ca <gets>:

char*
gets(char *buf, int max)
{
 2ca:	55                   	push   %ebp
 2cb:	89 e5                	mov    %esp,%ebp
 2cd:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2d7:	eb 44                	jmp    31d <gets+0x53>
    cc = read(0, &c, 1);
 2d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2e0:	00 
 2e1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2ef:	e8 dc 02 00 00       	call   5d0 <read>
 2f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2fb:	7e 2d                	jle    32a <gets+0x60>
      break;
    buf[i++] = c;
 2fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 300:	03 45 08             	add    0x8(%ebp),%eax
 303:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 307:	88 10                	mov    %dl,(%eax)
 309:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 30d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 311:	3c 0a                	cmp    $0xa,%al
 313:	74 16                	je     32b <gets+0x61>
 315:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 319:	3c 0d                	cmp    $0xd,%al
 31b:	74 0e                	je     32b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 31d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 320:	83 c0 01             	add    $0x1,%eax
 323:	3b 45 0c             	cmp    0xc(%ebp),%eax
 326:	7c b1                	jl     2d9 <gets+0xf>
 328:	eb 01                	jmp    32b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 32a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 32b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32e:	03 45 08             	add    0x8(%ebp),%eax
 331:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 334:	8b 45 08             	mov    0x8(%ebp),%eax
}
 337:	c9                   	leave  
 338:	c3                   	ret    

00000339 <stat>:

int
stat(char *n, struct stat *st)
{
 339:	55                   	push   %ebp
 33a:	89 e5                	mov    %esp,%ebp
 33c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 346:	00 
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	89 04 24             	mov    %eax,(%esp)
 34d:	e8 a6 02 00 00       	call   5f8 <open>
 352:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 355:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 359:	79 07                	jns    362 <stat+0x29>
    return -1;
 35b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 360:	eb 23                	jmp    385 <stat+0x4c>
  r = fstat(fd, st);
 362:	8b 45 0c             	mov    0xc(%ebp),%eax
 365:	89 44 24 04          	mov    %eax,0x4(%esp)
 369:	8b 45 f4             	mov    -0xc(%ebp),%eax
 36c:	89 04 24             	mov    %eax,(%esp)
 36f:	e8 9c 02 00 00       	call   610 <fstat>
 374:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 377:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37a:	89 04 24             	mov    %eax,(%esp)
 37d:	e8 5e 02 00 00       	call   5e0 <close>
  return r;
 382:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 385:	c9                   	leave  
 386:	c3                   	ret    

00000387 <atoi>:

int
atoi(const char *s)
{
 387:	55                   	push   %ebp
 388:	89 e5                	mov    %esp,%ebp
 38a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 38d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 394:	eb 23                	jmp    3b9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 396:	8b 55 fc             	mov    -0x4(%ebp),%edx
 399:	89 d0                	mov    %edx,%eax
 39b:	c1 e0 02             	shl    $0x2,%eax
 39e:	01 d0                	add    %edx,%eax
 3a0:	01 c0                	add    %eax,%eax
 3a2:	89 c2                	mov    %eax,%edx
 3a4:	8b 45 08             	mov    0x8(%ebp),%eax
 3a7:	0f b6 00             	movzbl (%eax),%eax
 3aa:	0f be c0             	movsbl %al,%eax
 3ad:	01 d0                	add    %edx,%eax
 3af:	83 e8 30             	sub    $0x30,%eax
 3b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3b5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
 3bc:	0f b6 00             	movzbl (%eax),%eax
 3bf:	3c 2f                	cmp    $0x2f,%al
 3c1:	7e 0a                	jle    3cd <atoi+0x46>
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	0f b6 00             	movzbl (%eax),%eax
 3c9:	3c 39                	cmp    $0x39,%al
 3cb:	7e c9                	jle    396 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d0:	c9                   	leave  
 3d1:	c3                   	ret    

000003d2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3d2:	55                   	push   %ebp
 3d3:	89 e5                	mov    %esp,%ebp
 3d5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3de:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e4:	eb 13                	jmp    3f9 <memmove+0x27>
    *dst++ = *src++;
 3e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3e9:	0f b6 10             	movzbl (%eax),%edx
 3ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ef:	88 10                	mov    %dl,(%eax)
 3f1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3f5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3fd:	0f 9f c0             	setg   %al
 400:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 404:	84 c0                	test   %al,%al
 406:	75 de                	jne    3e6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 408:	8b 45 08             	mov    0x8(%ebp),%eax
}
 40b:	c9                   	leave  
 40c:	c3                   	ret    

0000040d <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 40d:	55                   	push   %ebp
 40e:	89 e5                	mov    %esp,%ebp
 410:	83 ec 38             	sub    $0x38,%esp
 413:	8b 45 10             	mov    0x10(%ebp),%eax
 416:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 419:	8b 45 14             	mov    0x14(%ebp),%eax
 41c:	8b 00                	mov    (%eax),%eax
 41e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 421:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 428:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 42c:	74 06                	je     434 <strtok+0x27>
 42e:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 432:	75 54                	jne    488 <strtok+0x7b>
    return match;
 434:	8b 45 f0             	mov    -0x10(%ebp),%eax
 437:	eb 6e                	jmp    4a7 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 439:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43c:	03 45 0c             	add    0xc(%ebp),%eax
 43f:	0f b6 00             	movzbl (%eax),%eax
 442:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 445:	74 06                	je     44d <strtok+0x40>
      {
	index++;
 447:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 44b:	eb 3c                	jmp    489 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 44d:	8b 45 14             	mov    0x14(%ebp),%eax
 450:	8b 00                	mov    (%eax),%eax
 452:	8b 55 f4             	mov    -0xc(%ebp),%edx
 455:	29 c2                	sub    %eax,%edx
 457:	8b 45 14             	mov    0x14(%ebp),%eax
 45a:	8b 00                	mov    (%eax),%eax
 45c:	03 45 0c             	add    0xc(%ebp),%eax
 45f:	89 54 24 08          	mov    %edx,0x8(%esp)
 463:	89 44 24 04          	mov    %eax,0x4(%esp)
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	89 04 24             	mov    %eax,(%esp)
 46d:	e8 37 00 00 00       	call   4a9 <strncpy>
 472:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	0f b6 00             	movzbl (%eax),%eax
 47b:	84 c0                	test   %al,%al
 47d:	74 19                	je     498 <strtok+0x8b>
	  match = 1;
 47f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 486:	eb 10                	jmp    498 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 488:	90                   	nop
 489:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48c:	03 45 0c             	add    0xc(%ebp),%eax
 48f:	0f b6 00             	movzbl (%eax),%eax
 492:	84 c0                	test   %al,%al
 494:	75 a3                	jne    439 <strtok+0x2c>
 496:	eb 01                	jmp    499 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 498:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 499:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49c:	8d 50 01             	lea    0x1(%eax),%edx
 49f:	8b 45 14             	mov    0x14(%ebp),%eax
 4a2:	89 10                	mov    %edx,(%eax)
  return match;
 4a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4a7:	c9                   	leave  
 4a8:	c3                   	ret    

000004a9 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 4a9:	55                   	push   %ebp
 4aa:	89 e5                	mov    %esp,%ebp
 4ac:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 4af:	8b 45 08             	mov    0x8(%ebp),%eax
 4b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 4b5:	90                   	nop
 4b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4ba:	0f 9f c0             	setg   %al
 4bd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4c1:	84 c0                	test   %al,%al
 4c3:	74 30                	je     4f5 <strncpy+0x4c>
 4c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c8:	0f b6 10             	movzbl (%eax),%edx
 4cb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ce:	88 10                	mov    %dl,(%eax)
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
 4d3:	0f b6 00             	movzbl (%eax),%eax
 4d6:	84 c0                	test   %al,%al
 4d8:	0f 95 c0             	setne  %al
 4db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4df:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 4e3:	84 c0                	test   %al,%al
 4e5:	75 cf                	jne    4b6 <strncpy+0xd>
    ;
  while(n-- > 0)
 4e7:	eb 0c                	jmp    4f5 <strncpy+0x4c>
    *s++ = 0;
 4e9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ec:	c6 00 00             	movb   $0x0,(%eax)
 4ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4f3:	eb 01                	jmp    4f6 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 4f5:	90                   	nop
 4f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4fa:	0f 9f c0             	setg   %al
 4fd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 501:	84 c0                	test   %al,%al
 503:	75 e4                	jne    4e9 <strncpy+0x40>
    *s++ = 0;
  return os;
 505:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 508:	c9                   	leave  
 509:	c3                   	ret    

0000050a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 50a:	55                   	push   %ebp
 50b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 50d:	eb 0c                	jmp    51b <strncmp+0x11>
    n--, p++, q++;
 50f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 513:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 517:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 51b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 51f:	74 1a                	je     53b <strncmp+0x31>
 521:	8b 45 08             	mov    0x8(%ebp),%eax
 524:	0f b6 00             	movzbl (%eax),%eax
 527:	84 c0                	test   %al,%al
 529:	74 10                	je     53b <strncmp+0x31>
 52b:	8b 45 08             	mov    0x8(%ebp),%eax
 52e:	0f b6 10             	movzbl (%eax),%edx
 531:	8b 45 0c             	mov    0xc(%ebp),%eax
 534:	0f b6 00             	movzbl (%eax),%eax
 537:	38 c2                	cmp    %al,%dl
 539:	74 d4                	je     50f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 53b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 53f:	75 07                	jne    548 <strncmp+0x3e>
    return 0;
 541:	b8 00 00 00 00       	mov    $0x0,%eax
 546:	eb 18                	jmp    560 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 548:	8b 45 08             	mov    0x8(%ebp),%eax
 54b:	0f b6 00             	movzbl (%eax),%eax
 54e:	0f b6 d0             	movzbl %al,%edx
 551:	8b 45 0c             	mov    0xc(%ebp),%eax
 554:	0f b6 00             	movzbl (%eax),%eax
 557:	0f b6 c0             	movzbl %al,%eax
 55a:	89 d1                	mov    %edx,%ecx
 55c:	29 c1                	sub    %eax,%ecx
 55e:	89 c8                	mov    %ecx,%eax
}
 560:	5d                   	pop    %ebp
 561:	c3                   	ret    

00000562 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 562:	55                   	push   %ebp
 563:	89 e5                	mov    %esp,%ebp
  while(*p){
 565:	eb 13                	jmp    57a <strcat+0x18>
    *dest++ = *p++;
 567:	8b 45 0c             	mov    0xc(%ebp),%eax
 56a:	0f b6 10             	movzbl (%eax),%edx
 56d:	8b 45 08             	mov    0x8(%ebp),%eax
 570:	88 10                	mov    %dl,(%eax)
 572:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 576:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 57a:	8b 45 0c             	mov    0xc(%ebp),%eax
 57d:	0f b6 00             	movzbl (%eax),%eax
 580:	84 c0                	test   %al,%al
 582:	75 e3                	jne    567 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 584:	eb 13                	jmp    599 <strcat+0x37>
    *dest++ = *q++;
 586:	8b 45 10             	mov    0x10(%ebp),%eax
 589:	0f b6 10             	movzbl (%eax),%edx
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
 58f:	88 10                	mov    %dl,(%eax)
 591:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 595:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 599:	8b 45 10             	mov    0x10(%ebp),%eax
 59c:	0f b6 00             	movzbl (%eax),%eax
 59f:	84 c0                	test   %al,%al
 5a1:	75 e3                	jne    586 <strcat+0x24>
    *dest++ = *q++;
  }  
 5a3:	5d                   	pop    %ebp
 5a4:	c3                   	ret    
 5a5:	90                   	nop
 5a6:	90                   	nop
 5a7:	90                   	nop

000005a8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5a8:	b8 01 00 00 00       	mov    $0x1,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <exit>:
SYSCALL(exit)
 5b0:	b8 02 00 00 00       	mov    $0x2,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <wait>:
SYSCALL(wait)
 5b8:	b8 03 00 00 00       	mov    $0x3,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <wait2>:
SYSCALL(wait2)
 5c0:	b8 16 00 00 00       	mov    $0x16,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <pipe>:
SYSCALL(pipe)
 5c8:	b8 04 00 00 00       	mov    $0x4,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <read>:
SYSCALL(read)
 5d0:	b8 05 00 00 00       	mov    $0x5,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <write>:
SYSCALL(write)
 5d8:	b8 10 00 00 00       	mov    $0x10,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <close>:
SYSCALL(close)
 5e0:	b8 15 00 00 00       	mov    $0x15,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <kill>:
SYSCALL(kill)
 5e8:	b8 06 00 00 00       	mov    $0x6,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <exec>:
SYSCALL(exec)
 5f0:	b8 07 00 00 00       	mov    $0x7,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <open>:
SYSCALL(open)
 5f8:	b8 0f 00 00 00       	mov    $0xf,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <mknod>:
SYSCALL(mknod)
 600:	b8 11 00 00 00       	mov    $0x11,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <unlink>:
SYSCALL(unlink)
 608:	b8 12 00 00 00       	mov    $0x12,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <fstat>:
SYSCALL(fstat)
 610:	b8 08 00 00 00       	mov    $0x8,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <link>:
SYSCALL(link)
 618:	b8 13 00 00 00       	mov    $0x13,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <mkdir>:
SYSCALL(mkdir)
 620:	b8 14 00 00 00       	mov    $0x14,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <chdir>:
SYSCALL(chdir)
 628:	b8 09 00 00 00       	mov    $0x9,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <dup>:
SYSCALL(dup)
 630:	b8 0a 00 00 00       	mov    $0xa,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <getpid>:
SYSCALL(getpid)
 638:	b8 0b 00 00 00       	mov    $0xb,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <sbrk>:
SYSCALL(sbrk)
 640:	b8 0c 00 00 00       	mov    $0xc,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <sleep>:
SYSCALL(sleep)
 648:	b8 0d 00 00 00       	mov    $0xd,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <uptime>:
SYSCALL(uptime)
 650:	b8 0e 00 00 00       	mov    $0xe,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 658:	55                   	push   %ebp
 659:	89 e5                	mov    %esp,%ebp
 65b:	83 ec 28             	sub    $0x28,%esp
 65e:	8b 45 0c             	mov    0xc(%ebp),%eax
 661:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 664:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 66b:	00 
 66c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 66f:	89 44 24 04          	mov    %eax,0x4(%esp)
 673:	8b 45 08             	mov    0x8(%ebp),%eax
 676:	89 04 24             	mov    %eax,(%esp)
 679:	e8 5a ff ff ff       	call   5d8 <write>
}
 67e:	c9                   	leave  
 67f:	c3                   	ret    

00000680 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 680:	55                   	push   %ebp
 681:	89 e5                	mov    %esp,%ebp
 683:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 686:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 68d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 691:	74 17                	je     6aa <printint+0x2a>
 693:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 697:	79 11                	jns    6aa <printint+0x2a>
    neg = 1;
 699:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a3:	f7 d8                	neg    %eax
 6a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a8:	eb 06                	jmp    6b0 <printint+0x30>
  } else {
    x = xx;
 6aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6bd:	ba 00 00 00 00       	mov    $0x0,%edx
 6c2:	f7 f1                	div    %ecx
 6c4:	89 d0                	mov    %edx,%eax
 6c6:	0f b6 90 dc 0d 00 00 	movzbl 0xddc(%eax),%edx
 6cd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6d0:	03 45 f4             	add    -0xc(%ebp),%eax
 6d3:	88 10                	mov    %dl,(%eax)
 6d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6d9:	8b 55 10             	mov    0x10(%ebp),%edx
 6dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6e2:	ba 00 00 00 00       	mov    $0x0,%edx
 6e7:	f7 75 d4             	divl   -0x2c(%ebp)
 6ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6f1:	75 c4                	jne    6b7 <printint+0x37>
  if(neg)
 6f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6f7:	74 2a                	je     723 <printint+0xa3>
    buf[i++] = '-';
 6f9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6fc:	03 45 f4             	add    -0xc(%ebp),%eax
 6ff:	c6 00 2d             	movb   $0x2d,(%eax)
 702:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 706:	eb 1b                	jmp    723 <printint+0xa3>
    putc(fd, buf[i]);
 708:	8d 45 dc             	lea    -0x24(%ebp),%eax
 70b:	03 45 f4             	add    -0xc(%ebp),%eax
 70e:	0f b6 00             	movzbl (%eax),%eax
 711:	0f be c0             	movsbl %al,%eax
 714:	89 44 24 04          	mov    %eax,0x4(%esp)
 718:	8b 45 08             	mov    0x8(%ebp),%eax
 71b:	89 04 24             	mov    %eax,(%esp)
 71e:	e8 35 ff ff ff       	call   658 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 723:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 727:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 72b:	79 db                	jns    708 <printint+0x88>
    putc(fd, buf[i]);
}
 72d:	c9                   	leave  
 72e:	c3                   	ret    

0000072f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 72f:	55                   	push   %ebp
 730:	89 e5                	mov    %esp,%ebp
 732:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 735:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 73c:	8d 45 0c             	lea    0xc(%ebp),%eax
 73f:	83 c0 04             	add    $0x4,%eax
 742:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 745:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 74c:	e9 7d 01 00 00       	jmp    8ce <printf+0x19f>
    c = fmt[i] & 0xff;
 751:	8b 55 0c             	mov    0xc(%ebp),%edx
 754:	8b 45 f0             	mov    -0x10(%ebp),%eax
 757:	01 d0                	add    %edx,%eax
 759:	0f b6 00             	movzbl (%eax),%eax
 75c:	0f be c0             	movsbl %al,%eax
 75f:	25 ff 00 00 00       	and    $0xff,%eax
 764:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 767:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 76b:	75 2c                	jne    799 <printf+0x6a>
      if(c == '%'){
 76d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 771:	75 0c                	jne    77f <printf+0x50>
        state = '%';
 773:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 77a:	e9 4b 01 00 00       	jmp    8ca <printf+0x19b>
      } else {
        putc(fd, c);
 77f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 782:	0f be c0             	movsbl %al,%eax
 785:	89 44 24 04          	mov    %eax,0x4(%esp)
 789:	8b 45 08             	mov    0x8(%ebp),%eax
 78c:	89 04 24             	mov    %eax,(%esp)
 78f:	e8 c4 fe ff ff       	call   658 <putc>
 794:	e9 31 01 00 00       	jmp    8ca <printf+0x19b>
      }
    } else if(state == '%'){
 799:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 79d:	0f 85 27 01 00 00    	jne    8ca <printf+0x19b>
      if(c == 'd'){
 7a3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7a7:	75 2d                	jne    7d6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7b5:	00 
 7b6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7bd:	00 
 7be:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c2:	8b 45 08             	mov    0x8(%ebp),%eax
 7c5:	89 04 24             	mov    %eax,(%esp)
 7c8:	e8 b3 fe ff ff       	call   680 <printint>
        ap++;
 7cd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7d1:	e9 ed 00 00 00       	jmp    8c3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7d6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7da:	74 06                	je     7e2 <printf+0xb3>
 7dc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7e0:	75 2d                	jne    80f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e5:	8b 00                	mov    (%eax),%eax
 7e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7ee:	00 
 7ef:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7f6:	00 
 7f7:	89 44 24 04          	mov    %eax,0x4(%esp)
 7fb:	8b 45 08             	mov    0x8(%ebp),%eax
 7fe:	89 04 24             	mov    %eax,(%esp)
 801:	e8 7a fe ff ff       	call   680 <printint>
        ap++;
 806:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 80a:	e9 b4 00 00 00       	jmp    8c3 <printf+0x194>
      } else if(c == 's'){
 80f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 813:	75 46                	jne    85b <printf+0x12c>
        s = (char*)*ap;
 815:	8b 45 e8             	mov    -0x18(%ebp),%eax
 818:	8b 00                	mov    (%eax),%eax
 81a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 81d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 821:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 825:	75 27                	jne    84e <printf+0x11f>
          s = "(null)";
 827:	c7 45 f4 16 0b 00 00 	movl   $0xb16,-0xc(%ebp)
        while(*s != 0){
 82e:	eb 1e                	jmp    84e <printf+0x11f>
          putc(fd, *s);
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	0f b6 00             	movzbl (%eax),%eax
 836:	0f be c0             	movsbl %al,%eax
 839:	89 44 24 04          	mov    %eax,0x4(%esp)
 83d:	8b 45 08             	mov    0x8(%ebp),%eax
 840:	89 04 24             	mov    %eax,(%esp)
 843:	e8 10 fe ff ff       	call   658 <putc>
          s++;
 848:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 84c:	eb 01                	jmp    84f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 84e:	90                   	nop
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	0f b6 00             	movzbl (%eax),%eax
 855:	84 c0                	test   %al,%al
 857:	75 d7                	jne    830 <printf+0x101>
 859:	eb 68                	jmp    8c3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 85b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 85f:	75 1d                	jne    87e <printf+0x14f>
        putc(fd, *ap);
 861:	8b 45 e8             	mov    -0x18(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	0f be c0             	movsbl %al,%eax
 869:	89 44 24 04          	mov    %eax,0x4(%esp)
 86d:	8b 45 08             	mov    0x8(%ebp),%eax
 870:	89 04 24             	mov    %eax,(%esp)
 873:	e8 e0 fd ff ff       	call   658 <putc>
        ap++;
 878:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 87c:	eb 45                	jmp    8c3 <printf+0x194>
      } else if(c == '%'){
 87e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 882:	75 17                	jne    89b <printf+0x16c>
        putc(fd, c);
 884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 887:	0f be c0             	movsbl %al,%eax
 88a:	89 44 24 04          	mov    %eax,0x4(%esp)
 88e:	8b 45 08             	mov    0x8(%ebp),%eax
 891:	89 04 24             	mov    %eax,(%esp)
 894:	e8 bf fd ff ff       	call   658 <putc>
 899:	eb 28                	jmp    8c3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 89b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8a2:	00 
 8a3:	8b 45 08             	mov    0x8(%ebp),%eax
 8a6:	89 04 24             	mov    %eax,(%esp)
 8a9:	e8 aa fd ff ff       	call   658 <putc>
        putc(fd, c);
 8ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8b1:	0f be c0             	movsbl %al,%eax
 8b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8b8:	8b 45 08             	mov    0x8(%ebp),%eax
 8bb:	89 04 24             	mov    %eax,(%esp)
 8be:	e8 95 fd ff ff       	call   658 <putc>
      }
      state = 0;
 8c3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8ca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8ce:	8b 55 0c             	mov    0xc(%ebp),%edx
 8d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d4:	01 d0                	add    %edx,%eax
 8d6:	0f b6 00             	movzbl (%eax),%eax
 8d9:	84 c0                	test   %al,%al
 8db:	0f 85 70 fe ff ff    	jne    751 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8e1:	c9                   	leave  
 8e2:	c3                   	ret    
 8e3:	90                   	nop

000008e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8e4:	55                   	push   %ebp
 8e5:	89 e5                	mov    %esp,%ebp
 8e7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ea:	8b 45 08             	mov    0x8(%ebp),%eax
 8ed:	83 e8 08             	sub    $0x8,%eax
 8f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f3:	a1 f8 0d 00 00       	mov    0xdf8,%eax
 8f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8fb:	eb 24                	jmp    921 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 905:	77 12                	ja     919 <free+0x35>
 907:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 90d:	77 24                	ja     933 <free+0x4f>
 90f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 912:	8b 00                	mov    (%eax),%eax
 914:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 917:	77 1a                	ja     933 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 921:	8b 45 f8             	mov    -0x8(%ebp),%eax
 924:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 927:	76 d4                	jbe    8fd <free+0x19>
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 931:	76 ca                	jbe    8fd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 933:	8b 45 f8             	mov    -0x8(%ebp),%eax
 936:	8b 40 04             	mov    0x4(%eax),%eax
 939:	c1 e0 03             	shl    $0x3,%eax
 93c:	89 c2                	mov    %eax,%edx
 93e:	03 55 f8             	add    -0x8(%ebp),%edx
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	8b 00                	mov    (%eax),%eax
 946:	39 c2                	cmp    %eax,%edx
 948:	75 24                	jne    96e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 94a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94d:	8b 50 04             	mov    0x4(%eax),%edx
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	8b 00                	mov    (%eax),%eax
 955:	8b 40 04             	mov    0x4(%eax),%eax
 958:	01 c2                	add    %eax,%edx
 95a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 960:	8b 45 fc             	mov    -0x4(%ebp),%eax
 963:	8b 00                	mov    (%eax),%eax
 965:	8b 10                	mov    (%eax),%edx
 967:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96a:	89 10                	mov    %edx,(%eax)
 96c:	eb 0a                	jmp    978 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 96e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 971:	8b 10                	mov    (%eax),%edx
 973:	8b 45 f8             	mov    -0x8(%ebp),%eax
 976:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 978:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97b:	8b 40 04             	mov    0x4(%eax),%eax
 97e:	c1 e0 03             	shl    $0x3,%eax
 981:	03 45 fc             	add    -0x4(%ebp),%eax
 984:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 987:	75 20                	jne    9a9 <free+0xc5>
    p->s.size += bp->s.size;
 989:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98c:	8b 50 04             	mov    0x4(%eax),%edx
 98f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 992:	8b 40 04             	mov    0x4(%eax),%eax
 995:	01 c2                	add    %eax,%edx
 997:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 99d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a0:	8b 10                	mov    (%eax),%edx
 9a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a5:	89 10                	mov    %edx,(%eax)
 9a7:	eb 08                	jmp    9b1 <free+0xcd>
  } else
    p->s.ptr = bp;
 9a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ac:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9af:	89 10                	mov    %edx,(%eax)
  freep = p;
 9b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b4:	a3 f8 0d 00 00       	mov    %eax,0xdf8
}
 9b9:	c9                   	leave  
 9ba:	c3                   	ret    

000009bb <morecore>:

static Header*
morecore(uint nu)
{
 9bb:	55                   	push   %ebp
 9bc:	89 e5                	mov    %esp,%ebp
 9be:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9c1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9c8:	77 07                	ja     9d1 <morecore+0x16>
    nu = 4096;
 9ca:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9d1:	8b 45 08             	mov    0x8(%ebp),%eax
 9d4:	c1 e0 03             	shl    $0x3,%eax
 9d7:	89 04 24             	mov    %eax,(%esp)
 9da:	e8 61 fc ff ff       	call   640 <sbrk>
 9df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9e2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9e6:	75 07                	jne    9ef <morecore+0x34>
    return 0;
 9e8:	b8 00 00 00 00       	mov    $0x0,%eax
 9ed:	eb 22                	jmp    a11 <morecore+0x56>
  hp = (Header*)p;
 9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f8:	8b 55 08             	mov    0x8(%ebp),%edx
 9fb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a01:	83 c0 08             	add    $0x8,%eax
 a04:	89 04 24             	mov    %eax,(%esp)
 a07:	e8 d8 fe ff ff       	call   8e4 <free>
  return freep;
 a0c:	a1 f8 0d 00 00       	mov    0xdf8,%eax
}
 a11:	c9                   	leave  
 a12:	c3                   	ret    

00000a13 <malloc>:

void*
malloc(uint nbytes)
{
 a13:	55                   	push   %ebp
 a14:	89 e5                	mov    %esp,%ebp
 a16:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a19:	8b 45 08             	mov    0x8(%ebp),%eax
 a1c:	83 c0 07             	add    $0x7,%eax
 a1f:	c1 e8 03             	shr    $0x3,%eax
 a22:	83 c0 01             	add    $0x1,%eax
 a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a28:	a1 f8 0d 00 00       	mov    0xdf8,%eax
 a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a34:	75 23                	jne    a59 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a36:	c7 45 f0 f0 0d 00 00 	movl   $0xdf0,-0x10(%ebp)
 a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a40:	a3 f8 0d 00 00       	mov    %eax,0xdf8
 a45:	a1 f8 0d 00 00       	mov    0xdf8,%eax
 a4a:	a3 f0 0d 00 00       	mov    %eax,0xdf0
    base.s.size = 0;
 a4f:	c7 05 f4 0d 00 00 00 	movl   $0x0,0xdf4
 a56:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5c:	8b 00                	mov    (%eax),%eax
 a5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a64:	8b 40 04             	mov    0x4(%eax),%eax
 a67:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a6a:	72 4d                	jb     ab9 <malloc+0xa6>
      if(p->s.size == nunits)
 a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6f:	8b 40 04             	mov    0x4(%eax),%eax
 a72:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a75:	75 0c                	jne    a83 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7a:	8b 10                	mov    (%eax),%edx
 a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7f:	89 10                	mov    %edx,(%eax)
 a81:	eb 26                	jmp    aa9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a86:	8b 40 04             	mov    0x4(%eax),%eax
 a89:	89 c2                	mov    %eax,%edx
 a8b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a91:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a97:	8b 40 04             	mov    0x4(%eax),%eax
 a9a:	c1 e0 03             	shl    $0x3,%eax
 a9d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 aa6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aac:	a3 f8 0d 00 00       	mov    %eax,0xdf8
      return (void*)(p + 1);
 ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab4:	83 c0 08             	add    $0x8,%eax
 ab7:	eb 38                	jmp    af1 <malloc+0xde>
    }
    if(p == freep)
 ab9:	a1 f8 0d 00 00       	mov    0xdf8,%eax
 abe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ac1:	75 1b                	jne    ade <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ac6:	89 04 24             	mov    %eax,(%esp)
 ac9:	e8 ed fe ff ff       	call   9bb <morecore>
 ace:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ad1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ad5:	75 07                	jne    ade <malloc+0xcb>
        return 0;
 ad7:	b8 00 00 00 00       	mov    $0x0,%eax
 adc:	eb 13                	jmp    af1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae7:	8b 00                	mov    (%eax),%eax
 ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 aec:	e9 70 ff ff ff       	jmp    a61 <malloc+0x4e>
}
 af1:	c9                   	leave  
 af2:	c3                   	ret    
