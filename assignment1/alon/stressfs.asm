
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
  2c:	c7 44 24 04 ff 0a 00 	movl   $0xaff,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 fb 06 00 00       	call   73b <printf>
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
  69:	e8 3e 05 00 00       	call   5ac <fork>
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
  92:	c7 44 24 04 12 0b 00 	movl   $0xb12,0x4(%esp)
  99:	00 
  9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a1:	e8 95 06 00 00       	call   73b <printf>

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
  d2:	e8 2d 05 00 00       	call   604 <open>
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
 105:	e8 da 04 00 00       	call   5e4 <write>

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
 126:	e8 c1 04 00 00       	call   5ec <close>

  printf(1, "read\n");
 12b:	c7 44 24 04 1c 0b 00 	movl   $0xb1c,0x4(%esp)
 132:	00 
 133:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13a:	e8 fc 05 00 00       	call   73b <printf>

  fd = open(path, O_RDONLY);
 13f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 146:	00 
 147:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 ae 04 00 00       	call   604 <open>
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
 184:	e8 53 04 00 00       	call   5dc <read>
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
 1a5:	e8 42 04 00 00       	call   5ec <close>

  wait();
 1aa:	e8 0d 04 00 00       	call   5bc <wait>
  
  exit();
 1af:	e8 00 04 00 00       	call   5b4 <exit>

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
 2ef:	e8 e8 02 00 00       	call   5dc <read>
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
 34d:	e8 b2 02 00 00       	call   604 <open>
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
 36f:	e8 a8 02 00 00       	call   61c <fstat>
 374:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 377:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37a:	89 04 24             	mov    %eax,(%esp)
 37d:	e8 6a 02 00 00       	call   5ec <close>
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
strcat(char *dest, char *p, char *q)
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
strcat(char *dest, char *p, char *q)
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
  *dest = 0;
 5a3:	8b 45 08             	mov    0x8(%ebp),%eax
 5a6:	c6 00 00             	movb   $0x0,(%eax)
 5a9:	5d                   	pop    %ebp
 5aa:	c3                   	ret    
 5ab:	90                   	nop

000005ac <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5ac:	b8 01 00 00 00       	mov    $0x1,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <exit>:
SYSCALL(exit)
 5b4:	b8 02 00 00 00       	mov    $0x2,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <wait>:
SYSCALL(wait)
 5bc:	b8 03 00 00 00       	mov    $0x3,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <wait2>:
SYSCALL(wait2)
 5c4:	b8 16 00 00 00       	mov    $0x16,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <nice>:
SYSCALL(nice)
 5cc:	b8 17 00 00 00       	mov    $0x17,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <pipe>:
SYSCALL(pipe)
 5d4:	b8 04 00 00 00       	mov    $0x4,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <read>:
SYSCALL(read)
 5dc:	b8 05 00 00 00       	mov    $0x5,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <write>:
SYSCALL(write)
 5e4:	b8 10 00 00 00       	mov    $0x10,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <close>:
SYSCALL(close)
 5ec:	b8 15 00 00 00       	mov    $0x15,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <kill>:
SYSCALL(kill)
 5f4:	b8 06 00 00 00       	mov    $0x6,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <exec>:
SYSCALL(exec)
 5fc:	b8 07 00 00 00       	mov    $0x7,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <open>:
SYSCALL(open)
 604:	b8 0f 00 00 00       	mov    $0xf,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <mknod>:
SYSCALL(mknod)
 60c:	b8 11 00 00 00       	mov    $0x11,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <unlink>:
SYSCALL(unlink)
 614:	b8 12 00 00 00       	mov    $0x12,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <fstat>:
SYSCALL(fstat)
 61c:	b8 08 00 00 00       	mov    $0x8,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <link>:
SYSCALL(link)
 624:	b8 13 00 00 00       	mov    $0x13,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <mkdir>:
SYSCALL(mkdir)
 62c:	b8 14 00 00 00       	mov    $0x14,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <chdir>:
SYSCALL(chdir)
 634:	b8 09 00 00 00       	mov    $0x9,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <dup>:
SYSCALL(dup)
 63c:	b8 0a 00 00 00       	mov    $0xa,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <getpid>:
SYSCALL(getpid)
 644:	b8 0b 00 00 00       	mov    $0xb,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <sbrk>:
SYSCALL(sbrk)
 64c:	b8 0c 00 00 00       	mov    $0xc,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <sleep>:
SYSCALL(sleep)
 654:	b8 0d 00 00 00       	mov    $0xd,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <uptime>:
SYSCALL(uptime)
 65c:	b8 0e 00 00 00       	mov    $0xe,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 664:	55                   	push   %ebp
 665:	89 e5                	mov    %esp,%ebp
 667:	83 ec 28             	sub    $0x28,%esp
 66a:	8b 45 0c             	mov    0xc(%ebp),%eax
 66d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 670:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 677:	00 
 678:	8d 45 f4             	lea    -0xc(%ebp),%eax
 67b:	89 44 24 04          	mov    %eax,0x4(%esp)
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
 682:	89 04 24             	mov    %eax,(%esp)
 685:	e8 5a ff ff ff       	call   5e4 <write>
}
 68a:	c9                   	leave  
 68b:	c3                   	ret    

0000068c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 68c:	55                   	push   %ebp
 68d:	89 e5                	mov    %esp,%ebp
 68f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 692:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 699:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 69d:	74 17                	je     6b6 <printint+0x2a>
 69f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6a3:	79 11                	jns    6b6 <printint+0x2a>
    neg = 1;
 6a5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 6af:	f7 d8                	neg    %eax
 6b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6b4:	eb 06                	jmp    6bc <printint+0x30>
  } else {
    x = xx;
 6b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6c9:	ba 00 00 00 00       	mov    $0x0,%edx
 6ce:	f7 f1                	div    %ecx
 6d0:	89 d0                	mov    %edx,%eax
 6d2:	0f b6 90 e8 0d 00 00 	movzbl 0xde8(%eax),%edx
 6d9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6dc:	03 45 f4             	add    -0xc(%ebp),%eax
 6df:	88 10                	mov    %dl,(%eax)
 6e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6e5:	8b 55 10             	mov    0x10(%ebp),%edx
 6e8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6ee:	ba 00 00 00 00       	mov    $0x0,%edx
 6f3:	f7 75 d4             	divl   -0x2c(%ebp)
 6f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6fd:	75 c4                	jne    6c3 <printint+0x37>
  if(neg)
 6ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 703:	74 2a                	je     72f <printint+0xa3>
    buf[i++] = '-';
 705:	8d 45 dc             	lea    -0x24(%ebp),%eax
 708:	03 45 f4             	add    -0xc(%ebp),%eax
 70b:	c6 00 2d             	movb   $0x2d,(%eax)
 70e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 712:	eb 1b                	jmp    72f <printint+0xa3>
    putc(fd, buf[i]);
 714:	8d 45 dc             	lea    -0x24(%ebp),%eax
 717:	03 45 f4             	add    -0xc(%ebp),%eax
 71a:	0f b6 00             	movzbl (%eax),%eax
 71d:	0f be c0             	movsbl %al,%eax
 720:	89 44 24 04          	mov    %eax,0x4(%esp)
 724:	8b 45 08             	mov    0x8(%ebp),%eax
 727:	89 04 24             	mov    %eax,(%esp)
 72a:	e8 35 ff ff ff       	call   664 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 72f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 733:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 737:	79 db                	jns    714 <printint+0x88>
    putc(fd, buf[i]);
}
 739:	c9                   	leave  
 73a:	c3                   	ret    

0000073b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 73b:	55                   	push   %ebp
 73c:	89 e5                	mov    %esp,%ebp
 73e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 741:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 748:	8d 45 0c             	lea    0xc(%ebp),%eax
 74b:	83 c0 04             	add    $0x4,%eax
 74e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 751:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 758:	e9 7d 01 00 00       	jmp    8da <printf+0x19f>
    c = fmt[i] & 0xff;
 75d:	8b 55 0c             	mov    0xc(%ebp),%edx
 760:	8b 45 f0             	mov    -0x10(%ebp),%eax
 763:	01 d0                	add    %edx,%eax
 765:	0f b6 00             	movzbl (%eax),%eax
 768:	0f be c0             	movsbl %al,%eax
 76b:	25 ff 00 00 00       	and    $0xff,%eax
 770:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 773:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 777:	75 2c                	jne    7a5 <printf+0x6a>
      if(c == '%'){
 779:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 77d:	75 0c                	jne    78b <printf+0x50>
        state = '%';
 77f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 786:	e9 4b 01 00 00       	jmp    8d6 <printf+0x19b>
      } else {
        putc(fd, c);
 78b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 78e:	0f be c0             	movsbl %al,%eax
 791:	89 44 24 04          	mov    %eax,0x4(%esp)
 795:	8b 45 08             	mov    0x8(%ebp),%eax
 798:	89 04 24             	mov    %eax,(%esp)
 79b:	e8 c4 fe ff ff       	call   664 <putc>
 7a0:	e9 31 01 00 00       	jmp    8d6 <printf+0x19b>
      }
    } else if(state == '%'){
 7a5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7a9:	0f 85 27 01 00 00    	jne    8d6 <printf+0x19b>
      if(c == 'd'){
 7af:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7b3:	75 2d                	jne    7e2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7c1:	00 
 7c2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7c9:	00 
 7ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ce:	8b 45 08             	mov    0x8(%ebp),%eax
 7d1:	89 04 24             	mov    %eax,(%esp)
 7d4:	e8 b3 fe ff ff       	call   68c <printint>
        ap++;
 7d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7dd:	e9 ed 00 00 00       	jmp    8cf <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7e2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7e6:	74 06                	je     7ee <printf+0xb3>
 7e8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7ec:	75 2d                	jne    81b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f1:	8b 00                	mov    (%eax),%eax
 7f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7fa:	00 
 7fb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 802:	00 
 803:	89 44 24 04          	mov    %eax,0x4(%esp)
 807:	8b 45 08             	mov    0x8(%ebp),%eax
 80a:	89 04 24             	mov    %eax,(%esp)
 80d:	e8 7a fe ff ff       	call   68c <printint>
        ap++;
 812:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 816:	e9 b4 00 00 00       	jmp    8cf <printf+0x194>
      } else if(c == 's'){
 81b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 81f:	75 46                	jne    867 <printf+0x12c>
        s = (char*)*ap;
 821:	8b 45 e8             	mov    -0x18(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 829:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 82d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 831:	75 27                	jne    85a <printf+0x11f>
          s = "(null)";
 833:	c7 45 f4 22 0b 00 00 	movl   $0xb22,-0xc(%ebp)
        while(*s != 0){
 83a:	eb 1e                	jmp    85a <printf+0x11f>
          putc(fd, *s);
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	0f b6 00             	movzbl (%eax),%eax
 842:	0f be c0             	movsbl %al,%eax
 845:	89 44 24 04          	mov    %eax,0x4(%esp)
 849:	8b 45 08             	mov    0x8(%ebp),%eax
 84c:	89 04 24             	mov    %eax,(%esp)
 84f:	e8 10 fe ff ff       	call   664 <putc>
          s++;
 854:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 858:	eb 01                	jmp    85b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 85a:	90                   	nop
 85b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85e:	0f b6 00             	movzbl (%eax),%eax
 861:	84 c0                	test   %al,%al
 863:	75 d7                	jne    83c <printf+0x101>
 865:	eb 68                	jmp    8cf <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 867:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 86b:	75 1d                	jne    88a <printf+0x14f>
        putc(fd, *ap);
 86d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 870:	8b 00                	mov    (%eax),%eax
 872:	0f be c0             	movsbl %al,%eax
 875:	89 44 24 04          	mov    %eax,0x4(%esp)
 879:	8b 45 08             	mov    0x8(%ebp),%eax
 87c:	89 04 24             	mov    %eax,(%esp)
 87f:	e8 e0 fd ff ff       	call   664 <putc>
        ap++;
 884:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 888:	eb 45                	jmp    8cf <printf+0x194>
      } else if(c == '%'){
 88a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 88e:	75 17                	jne    8a7 <printf+0x16c>
        putc(fd, c);
 890:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 893:	0f be c0             	movsbl %al,%eax
 896:	89 44 24 04          	mov    %eax,0x4(%esp)
 89a:	8b 45 08             	mov    0x8(%ebp),%eax
 89d:	89 04 24             	mov    %eax,(%esp)
 8a0:	e8 bf fd ff ff       	call   664 <putc>
 8a5:	eb 28                	jmp    8cf <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8a7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8ae:	00 
 8af:	8b 45 08             	mov    0x8(%ebp),%eax
 8b2:	89 04 24             	mov    %eax,(%esp)
 8b5:	e8 aa fd ff ff       	call   664 <putc>
        putc(fd, c);
 8ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8bd:	0f be c0             	movsbl %al,%eax
 8c0:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c4:	8b 45 08             	mov    0x8(%ebp),%eax
 8c7:	89 04 24             	mov    %eax,(%esp)
 8ca:	e8 95 fd ff ff       	call   664 <putc>
      }
      state = 0;
 8cf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8d6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8da:	8b 55 0c             	mov    0xc(%ebp),%edx
 8dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e0:	01 d0                	add    %edx,%eax
 8e2:	0f b6 00             	movzbl (%eax),%eax
 8e5:	84 c0                	test   %al,%al
 8e7:	0f 85 70 fe ff ff    	jne    75d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8ed:	c9                   	leave  
 8ee:	c3                   	ret    
 8ef:	90                   	nop

000008f0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f0:	55                   	push   %ebp
 8f1:	89 e5                	mov    %esp,%ebp
 8f3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f6:	8b 45 08             	mov    0x8(%ebp),%eax
 8f9:	83 e8 08             	sub    $0x8,%eax
 8fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ff:	a1 04 0e 00 00       	mov    0xe04,%eax
 904:	89 45 fc             	mov    %eax,-0x4(%ebp)
 907:	eb 24                	jmp    92d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 911:	77 12                	ja     925 <free+0x35>
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 919:	77 24                	ja     93f <free+0x4f>
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	8b 00                	mov    (%eax),%eax
 920:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 923:	77 1a                	ja     93f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	8b 00                	mov    (%eax),%eax
 92a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 92d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 930:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 933:	76 d4                	jbe    909 <free+0x19>
 935:	8b 45 fc             	mov    -0x4(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 93d:	76 ca                	jbe    909 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 93f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 942:	8b 40 04             	mov    0x4(%eax),%eax
 945:	c1 e0 03             	shl    $0x3,%eax
 948:	89 c2                	mov    %eax,%edx
 94a:	03 55 f8             	add    -0x8(%ebp),%edx
 94d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 950:	8b 00                	mov    (%eax),%eax
 952:	39 c2                	cmp    %eax,%edx
 954:	75 24                	jne    97a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 956:	8b 45 f8             	mov    -0x8(%ebp),%eax
 959:	8b 50 04             	mov    0x4(%eax),%edx
 95c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95f:	8b 00                	mov    (%eax),%eax
 961:	8b 40 04             	mov    0x4(%eax),%eax
 964:	01 c2                	add    %eax,%edx
 966:	8b 45 f8             	mov    -0x8(%ebp),%eax
 969:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 96c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96f:	8b 00                	mov    (%eax),%eax
 971:	8b 10                	mov    (%eax),%edx
 973:	8b 45 f8             	mov    -0x8(%ebp),%eax
 976:	89 10                	mov    %edx,(%eax)
 978:	eb 0a                	jmp    984 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 97a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97d:	8b 10                	mov    (%eax),%edx
 97f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 982:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 984:	8b 45 fc             	mov    -0x4(%ebp),%eax
 987:	8b 40 04             	mov    0x4(%eax),%eax
 98a:	c1 e0 03             	shl    $0x3,%eax
 98d:	03 45 fc             	add    -0x4(%ebp),%eax
 990:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 993:	75 20                	jne    9b5 <free+0xc5>
    p->s.size += bp->s.size;
 995:	8b 45 fc             	mov    -0x4(%ebp),%eax
 998:	8b 50 04             	mov    0x4(%eax),%edx
 99b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99e:	8b 40 04             	mov    0x4(%eax),%eax
 9a1:	01 c2                	add    %eax,%edx
 9a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ac:	8b 10                	mov    (%eax),%edx
 9ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b1:	89 10                	mov    %edx,(%eax)
 9b3:	eb 08                	jmp    9bd <free+0xcd>
  } else
    p->s.ptr = bp;
 9b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9bb:	89 10                	mov    %edx,(%eax)
  freep = p;
 9bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c0:	a3 04 0e 00 00       	mov    %eax,0xe04
}
 9c5:	c9                   	leave  
 9c6:	c3                   	ret    

000009c7 <morecore>:

static Header*
morecore(uint nu)
{
 9c7:	55                   	push   %ebp
 9c8:	89 e5                	mov    %esp,%ebp
 9ca:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9cd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9d4:	77 07                	ja     9dd <morecore+0x16>
    nu = 4096;
 9d6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9dd:	8b 45 08             	mov    0x8(%ebp),%eax
 9e0:	c1 e0 03             	shl    $0x3,%eax
 9e3:	89 04 24             	mov    %eax,(%esp)
 9e6:	e8 61 fc ff ff       	call   64c <sbrk>
 9eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9ee:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9f2:	75 07                	jne    9fb <morecore+0x34>
    return 0;
 9f4:	b8 00 00 00 00       	mov    $0x0,%eax
 9f9:	eb 22                	jmp    a1d <morecore+0x56>
  hp = (Header*)p;
 9fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a04:	8b 55 08             	mov    0x8(%ebp),%edx
 a07:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0d:	83 c0 08             	add    $0x8,%eax
 a10:	89 04 24             	mov    %eax,(%esp)
 a13:	e8 d8 fe ff ff       	call   8f0 <free>
  return freep;
 a18:	a1 04 0e 00 00       	mov    0xe04,%eax
}
 a1d:	c9                   	leave  
 a1e:	c3                   	ret    

00000a1f <malloc>:

void*
malloc(uint nbytes)
{
 a1f:	55                   	push   %ebp
 a20:	89 e5                	mov    %esp,%ebp
 a22:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a25:	8b 45 08             	mov    0x8(%ebp),%eax
 a28:	83 c0 07             	add    $0x7,%eax
 a2b:	c1 e8 03             	shr    $0x3,%eax
 a2e:	83 c0 01             	add    $0x1,%eax
 a31:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a34:	a1 04 0e 00 00       	mov    0xe04,%eax
 a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a40:	75 23                	jne    a65 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a42:	c7 45 f0 fc 0d 00 00 	movl   $0xdfc,-0x10(%ebp)
 a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4c:	a3 04 0e 00 00       	mov    %eax,0xe04
 a51:	a1 04 0e 00 00       	mov    0xe04,%eax
 a56:	a3 fc 0d 00 00       	mov    %eax,0xdfc
    base.s.size = 0;
 a5b:	c7 05 00 0e 00 00 00 	movl   $0x0,0xe00
 a62:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a68:	8b 00                	mov    (%eax),%eax
 a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a70:	8b 40 04             	mov    0x4(%eax),%eax
 a73:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a76:	72 4d                	jb     ac5 <malloc+0xa6>
      if(p->s.size == nunits)
 a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7b:	8b 40 04             	mov    0x4(%eax),%eax
 a7e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a81:	75 0c                	jne    a8f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a86:	8b 10                	mov    (%eax),%edx
 a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8b:	89 10                	mov    %edx,(%eax)
 a8d:	eb 26                	jmp    ab5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a92:	8b 40 04             	mov    0x4(%eax),%eax
 a95:	89 c2                	mov    %eax,%edx
 a97:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa3:	8b 40 04             	mov    0x4(%eax),%eax
 aa6:	c1 e0 03             	shl    $0x3,%eax
 aa9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ab2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab8:	a3 04 0e 00 00       	mov    %eax,0xe04
      return (void*)(p + 1);
 abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac0:	83 c0 08             	add    $0x8,%eax
 ac3:	eb 38                	jmp    afd <malloc+0xde>
    }
    if(p == freep)
 ac5:	a1 04 0e 00 00       	mov    0xe04,%eax
 aca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 acd:	75 1b                	jne    aea <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ad2:	89 04 24             	mov    %eax,(%esp)
 ad5:	e8 ed fe ff ff       	call   9c7 <morecore>
 ada:	89 45 f4             	mov    %eax,-0xc(%ebp)
 add:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae1:	75 07                	jne    aea <malloc+0xcb>
        return 0;
 ae3:	b8 00 00 00 00       	mov    $0x0,%eax
 ae8:	eb 13                	jmp    afd <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aed:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af3:	8b 00                	mov    (%eax),%eax
 af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 af8:	e9 70 ff ff ff       	jmp    a6d <malloc+0x4e>
}
 afd:	c9                   	leave  
 afe:	c3                   	ret    
