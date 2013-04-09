
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
  2c:	c7 44 24 04 19 0b 00 	movl   $0xb19,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 09 07 00 00       	call   749 <printf>
  memset(data, 'a', sizeof(data));
  40:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  47:	00 
  48:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  4f:	00 
  50:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 19 02 00 00       	call   275 <memset>

  for(i = 0; i < 4; i++)
  5c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  63:	00 00 00 00 
  67:	eb 11                	jmp    7a <main+0x7a>
    if(fork() > 0)
  69:	e8 46 05 00 00       	call   5b4 <fork>
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
  92:	c7 44 24 04 2c 0b 00 	movl   $0xb2c,0x4(%esp)
  99:	00 
  9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a1:	e8 a3 06 00 00       	call   749 <printf>

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
  d2:	e8 35 05 00 00       	call   60c <open>
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
 105:	e8 e2 04 00 00       	call   5ec <write>

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
 126:	e8 c9 04 00 00       	call   5f4 <close>

  printf(1, "read\n");
 12b:	c7 44 24 04 36 0b 00 	movl   $0xb36,0x4(%esp)
 132:	00 
 133:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13a:	e8 0a 06 00 00       	call   749 <printf>

  fd = open(path, O_RDONLY);
 13f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 146:	00 
 147:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 b6 04 00 00       	call   60c <open>
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
 184:	e8 5b 04 00 00       	call   5e4 <read>
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
 1a5:	e8 4a 04 00 00       	call   5f4 <close>

  wait();
 1aa:	e8 15 04 00 00       	call   5c4 <wait>
  
  exit();
 1af:	e8 08 04 00 00       	call   5bc <exit>

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
 261:	8b 55 fc             	mov    -0x4(%ebp),%edx
 264:	8b 45 08             	mov    0x8(%ebp),%eax
 267:	01 d0                	add    %edx,%eax
 269:	0f b6 00             	movzbl (%eax),%eax
 26c:	84 c0                	test   %al,%al
 26e:	75 ed                	jne    25d <strlen+0xf>
  return n;
 270:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <memset>:

void*
memset(void *dst, int c, uint n)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 27b:	8b 45 10             	mov    0x10(%ebp),%eax
 27e:	89 44 24 08          	mov    %eax,0x8(%esp)
 282:	8b 45 0c             	mov    0xc(%ebp),%eax
 285:	89 44 24 04          	mov    %eax,0x4(%esp)
 289:	8b 45 08             	mov    0x8(%ebp),%eax
 28c:	89 04 24             	mov    %eax,(%esp)
 28f:	e8 20 ff ff ff       	call   1b4 <stosb>
  return dst;
 294:	8b 45 08             	mov    0x8(%ebp),%eax
}
 297:	c9                   	leave  
 298:	c3                   	ret    

00000299 <strchr>:

char*
strchr(const char *s, char c)
{
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	83 ec 04             	sub    $0x4,%esp
 29f:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a2:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2a5:	eb 14                	jmp    2bb <strchr+0x22>
    if(*s == c)
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	0f b6 00             	movzbl (%eax),%eax
 2ad:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2b0:	75 05                	jne    2b7 <strchr+0x1e>
      return (char*)s;
 2b2:	8b 45 08             	mov    0x8(%ebp),%eax
 2b5:	eb 13                	jmp    2ca <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	0f b6 00             	movzbl (%eax),%eax
 2c1:	84 c0                	test   %al,%al
 2c3:	75 e2                	jne    2a7 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2ca:	c9                   	leave  
 2cb:	c3                   	ret    

000002cc <gets>:

char*
gets(char *buf, int max)
{
 2cc:	55                   	push   %ebp
 2cd:	89 e5                	mov    %esp,%ebp
 2cf:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2d9:	eb 46                	jmp    321 <gets+0x55>
    cc = read(0, &c, 1);
 2db:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2e2:	00 
 2e3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2f1:	e8 ee 02 00 00       	call   5e4 <read>
 2f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2fd:	7e 2f                	jle    32e <gets+0x62>
      break;
    buf[i++] = c;
 2ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
 302:	8b 45 08             	mov    0x8(%ebp),%eax
 305:	01 c2                	add    %eax,%edx
 307:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30b:	88 02                	mov    %al,(%edx)
 30d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 311:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 315:	3c 0a                	cmp    $0xa,%al
 317:	74 16                	je     32f <gets+0x63>
 319:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 31d:	3c 0d                	cmp    $0xd,%al
 31f:	74 0e                	je     32f <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 321:	8b 45 f4             	mov    -0xc(%ebp),%eax
 324:	83 c0 01             	add    $0x1,%eax
 327:	3b 45 0c             	cmp    0xc(%ebp),%eax
 32a:	7c af                	jl     2db <gets+0xf>
 32c:	eb 01                	jmp    32f <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 32e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 32f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	01 d0                	add    %edx,%eax
 337:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33d:	c9                   	leave  
 33e:	c3                   	ret    

0000033f <stat>:

int
stat(char *n, struct stat *st)
{
 33f:	55                   	push   %ebp
 340:	89 e5                	mov    %esp,%ebp
 342:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 345:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 34c:	00 
 34d:	8b 45 08             	mov    0x8(%ebp),%eax
 350:	89 04 24             	mov    %eax,(%esp)
 353:	e8 b4 02 00 00       	call   60c <open>
 358:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 35b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 35f:	79 07                	jns    368 <stat+0x29>
    return -1;
 361:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 366:	eb 23                	jmp    38b <stat+0x4c>
  r = fstat(fd, st);
 368:	8b 45 0c             	mov    0xc(%ebp),%eax
 36b:	89 44 24 04          	mov    %eax,0x4(%esp)
 36f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 372:	89 04 24             	mov    %eax,(%esp)
 375:	e8 aa 02 00 00       	call   624 <fstat>
 37a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 37d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 380:	89 04 24             	mov    %eax,(%esp)
 383:	e8 6c 02 00 00       	call   5f4 <close>
  return r;
 388:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 38b:	c9                   	leave  
 38c:	c3                   	ret    

0000038d <atoi>:

int
atoi(const char *s)
{
 38d:	55                   	push   %ebp
 38e:	89 e5                	mov    %esp,%ebp
 390:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 393:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 39a:	eb 23                	jmp    3bf <atoi+0x32>
    n = n*10 + *s++ - '0';
 39c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 39f:	89 d0                	mov    %edx,%eax
 3a1:	c1 e0 02             	shl    $0x2,%eax
 3a4:	01 d0                	add    %edx,%eax
 3a6:	01 c0                	add    %eax,%eax
 3a8:	89 c2                	mov    %eax,%edx
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
 3ad:	0f b6 00             	movzbl (%eax),%eax
 3b0:	0f be c0             	movsbl %al,%eax
 3b3:	01 d0                	add    %edx,%eax
 3b5:	83 e8 30             	sub    $0x30,%eax
 3b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3bb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	0f b6 00             	movzbl (%eax),%eax
 3c5:	3c 2f                	cmp    $0x2f,%al
 3c7:	7e 0a                	jle    3d3 <atoi+0x46>
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	3c 39                	cmp    $0x39,%al
 3d1:	7e c9                	jle    39c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d6:	c9                   	leave  
 3d7:	c3                   	ret    

000003d8 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3d8:	55                   	push   %ebp
 3d9:	89 e5                	mov    %esp,%ebp
 3db:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3de:	8b 45 08             	mov    0x8(%ebp),%eax
 3e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3ea:	eb 13                	jmp    3ff <memmove+0x27>
    *dst++ = *src++;
 3ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3ef:	0f b6 10             	movzbl (%eax),%edx
 3f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3f5:	88 10                	mov    %dl,(%eax)
 3f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3fb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 403:	0f 9f c0             	setg   %al
 406:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 40a:	84 c0                	test   %al,%al
 40c:	75 de                	jne    3ec <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 40e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 411:	c9                   	leave  
 412:	c3                   	ret    

00000413 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 413:	55                   	push   %ebp
 414:	89 e5                	mov    %esp,%ebp
 416:	83 ec 38             	sub    $0x38,%esp
 419:	8b 45 10             	mov    0x10(%ebp),%eax
 41c:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 41f:	8b 45 14             	mov    0x14(%ebp),%eax
 422:	8b 00                	mov    (%eax),%eax
 424:	89 45 f4             	mov    %eax,-0xc(%ebp)
 427:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 42e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 432:	74 06                	je     43a <strtok+0x27>
 434:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 438:	75 5a                	jne    494 <strtok+0x81>
    return match;
 43a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 43d:	eb 76                	jmp    4b5 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 43f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 442:	8b 45 0c             	mov    0xc(%ebp),%eax
 445:	01 d0                	add    %edx,%eax
 447:	0f b6 00             	movzbl (%eax),%eax
 44a:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 44d:	74 06                	je     455 <strtok+0x42>
      {
	index++;
 44f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 453:	eb 40                	jmp    495 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 455:	8b 45 14             	mov    0x14(%ebp),%eax
 458:	8b 00                	mov    (%eax),%eax
 45a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 45d:	29 c2                	sub    %eax,%edx
 45f:	8b 45 14             	mov    0x14(%ebp),%eax
 462:	8b 00                	mov    (%eax),%eax
 464:	89 c1                	mov    %eax,%ecx
 466:	8b 45 0c             	mov    0xc(%ebp),%eax
 469:	01 c8                	add    %ecx,%eax
 46b:	89 54 24 08          	mov    %edx,0x8(%esp)
 46f:	89 44 24 04          	mov    %eax,0x4(%esp)
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	89 04 24             	mov    %eax,(%esp)
 479:	e8 39 00 00 00       	call   4b7 <strncpy>
 47e:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	0f b6 00             	movzbl (%eax),%eax
 487:	84 c0                	test   %al,%al
 489:	74 1b                	je     4a6 <strtok+0x93>
	  match = 1;
 48b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 492:	eb 12                	jmp    4a6 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 494:	90                   	nop
 495:	8b 55 f4             	mov    -0xc(%ebp),%edx
 498:	8b 45 0c             	mov    0xc(%ebp),%eax
 49b:	01 d0                	add    %edx,%eax
 49d:	0f b6 00             	movzbl (%eax),%eax
 4a0:	84 c0                	test   %al,%al
 4a2:	75 9b                	jne    43f <strtok+0x2c>
 4a4:	eb 01                	jmp    4a7 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 4a6:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 4a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4aa:	8d 50 01             	lea    0x1(%eax),%edx
 4ad:	8b 45 14             	mov    0x14(%ebp),%eax
 4b0:	89 10                	mov    %edx,(%eax)
  return match;
 4b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4b5:	c9                   	leave  
 4b6:	c3                   	ret    

000004b7 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 4b7:	55                   	push   %ebp
 4b8:	89 e5                	mov    %esp,%ebp
 4ba:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 4bd:	8b 45 08             	mov    0x8(%ebp),%eax
 4c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 4c3:	90                   	nop
 4c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4c8:	0f 9f c0             	setg   %al
 4cb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4cf:	84 c0                	test   %al,%al
 4d1:	74 30                	je     503 <strncpy+0x4c>
 4d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d6:	0f b6 10             	movzbl (%eax),%edx
 4d9:	8b 45 08             	mov    0x8(%ebp),%eax
 4dc:	88 10                	mov    %dl,(%eax)
 4de:	8b 45 08             	mov    0x8(%ebp),%eax
 4e1:	0f b6 00             	movzbl (%eax),%eax
 4e4:	84 c0                	test   %al,%al
 4e6:	0f 95 c0             	setne  %al
 4e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ed:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 4f1:	84 c0                	test   %al,%al
 4f3:	75 cf                	jne    4c4 <strncpy+0xd>
    ;
  while(n-- > 0)
 4f5:	eb 0c                	jmp    503 <strncpy+0x4c>
    *s++ = 0;
 4f7:	8b 45 08             	mov    0x8(%ebp),%eax
 4fa:	c6 00 00             	movb   $0x0,(%eax)
 4fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 501:	eb 01                	jmp    504 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 503:	90                   	nop
 504:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 508:	0f 9f c0             	setg   %al
 50b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 50f:	84 c0                	test   %al,%al
 511:	75 e4                	jne    4f7 <strncpy+0x40>
    *s++ = 0;
  return os;
 513:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 516:	c9                   	leave  
 517:	c3                   	ret    

00000518 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 518:	55                   	push   %ebp
 519:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 51b:	eb 0c                	jmp    529 <strncmp+0x11>
    n--, p++, q++;
 51d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 521:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 525:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 529:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 52d:	74 1a                	je     549 <strncmp+0x31>
 52f:	8b 45 08             	mov    0x8(%ebp),%eax
 532:	0f b6 00             	movzbl (%eax),%eax
 535:	84 c0                	test   %al,%al
 537:	74 10                	je     549 <strncmp+0x31>
 539:	8b 45 08             	mov    0x8(%ebp),%eax
 53c:	0f b6 10             	movzbl (%eax),%edx
 53f:	8b 45 0c             	mov    0xc(%ebp),%eax
 542:	0f b6 00             	movzbl (%eax),%eax
 545:	38 c2                	cmp    %al,%dl
 547:	74 d4                	je     51d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 549:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 54d:	75 07                	jne    556 <strncmp+0x3e>
    return 0;
 54f:	b8 00 00 00 00       	mov    $0x0,%eax
 554:	eb 18                	jmp    56e <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 556:	8b 45 08             	mov    0x8(%ebp),%eax
 559:	0f b6 00             	movzbl (%eax),%eax
 55c:	0f b6 d0             	movzbl %al,%edx
 55f:	8b 45 0c             	mov    0xc(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	0f b6 c0             	movzbl %al,%eax
 568:	89 d1                	mov    %edx,%ecx
 56a:	29 c1                	sub    %eax,%ecx
 56c:	89 c8                	mov    %ecx,%eax
}
 56e:	5d                   	pop    %ebp
 56f:	c3                   	ret    

00000570 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 570:	55                   	push   %ebp
 571:	89 e5                	mov    %esp,%ebp
  while(*p){
 573:	eb 13                	jmp    588 <strcat+0x18>
    *dest++ = *p++;
 575:	8b 45 0c             	mov    0xc(%ebp),%eax
 578:	0f b6 10             	movzbl (%eax),%edx
 57b:	8b 45 08             	mov    0x8(%ebp),%eax
 57e:	88 10                	mov    %dl,(%eax)
 580:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 584:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 588:	8b 45 0c             	mov    0xc(%ebp),%eax
 58b:	0f b6 00             	movzbl (%eax),%eax
 58e:	84 c0                	test   %al,%al
 590:	75 e3                	jne    575 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 592:	eb 13                	jmp    5a7 <strcat+0x37>
    *dest++ = *q++;
 594:	8b 45 10             	mov    0x10(%ebp),%eax
 597:	0f b6 10             	movzbl (%eax),%edx
 59a:	8b 45 08             	mov    0x8(%ebp),%eax
 59d:	88 10                	mov    %dl,(%eax)
 59f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5a3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 5a7:	8b 45 10             	mov    0x10(%ebp),%eax
 5aa:	0f b6 00             	movzbl (%eax),%eax
 5ad:	84 c0                	test   %al,%al
 5af:	75 e3                	jne    594 <strcat+0x24>
    *dest++ = *q++;
  }  
 5b1:	5d                   	pop    %ebp
 5b2:	c3                   	ret    
 5b3:	90                   	nop

000005b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b4:	b8 01 00 00 00       	mov    $0x1,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <exit>:
SYSCALL(exit)
 5bc:	b8 02 00 00 00       	mov    $0x2,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <wait>:
SYSCALL(wait)
 5c4:	b8 03 00 00 00       	mov    $0x3,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <wait2>:
SYSCALL(wait2)
 5cc:	b8 16 00 00 00       	mov    $0x16,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <nice>:
SYSCALL(nice)
 5d4:	b8 17 00 00 00       	mov    $0x17,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <pipe>:
SYSCALL(pipe)
 5dc:	b8 04 00 00 00       	mov    $0x4,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <read>:
SYSCALL(read)
 5e4:	b8 05 00 00 00       	mov    $0x5,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <write>:
SYSCALL(write)
 5ec:	b8 10 00 00 00       	mov    $0x10,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <close>:
SYSCALL(close)
 5f4:	b8 15 00 00 00       	mov    $0x15,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <kill>:
SYSCALL(kill)
 5fc:	b8 06 00 00 00       	mov    $0x6,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <exec>:
SYSCALL(exec)
 604:	b8 07 00 00 00       	mov    $0x7,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <open>:
SYSCALL(open)
 60c:	b8 0f 00 00 00       	mov    $0xf,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <mknod>:
SYSCALL(mknod)
 614:	b8 11 00 00 00       	mov    $0x11,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <unlink>:
SYSCALL(unlink)
 61c:	b8 12 00 00 00       	mov    $0x12,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <fstat>:
SYSCALL(fstat)
 624:	b8 08 00 00 00       	mov    $0x8,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <link>:
SYSCALL(link)
 62c:	b8 13 00 00 00       	mov    $0x13,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <mkdir>:
SYSCALL(mkdir)
 634:	b8 14 00 00 00       	mov    $0x14,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <chdir>:
SYSCALL(chdir)
 63c:	b8 09 00 00 00       	mov    $0x9,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <dup>:
SYSCALL(dup)
 644:	b8 0a 00 00 00       	mov    $0xa,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <getpid>:
SYSCALL(getpid)
 64c:	b8 0b 00 00 00       	mov    $0xb,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <sbrk>:
SYSCALL(sbrk)
 654:	b8 0c 00 00 00       	mov    $0xc,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <sleep>:
SYSCALL(sleep)
 65c:	b8 0d 00 00 00       	mov    $0xd,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <uptime>:
SYSCALL(uptime)
 664:	b8 0e 00 00 00       	mov    $0xe,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 66c:	55                   	push   %ebp
 66d:	89 e5                	mov    %esp,%ebp
 66f:	83 ec 28             	sub    $0x28,%esp
 672:	8b 45 0c             	mov    0xc(%ebp),%eax
 675:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 678:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 67f:	00 
 680:	8d 45 f4             	lea    -0xc(%ebp),%eax
 683:	89 44 24 04          	mov    %eax,0x4(%esp)
 687:	8b 45 08             	mov    0x8(%ebp),%eax
 68a:	89 04 24             	mov    %eax,(%esp)
 68d:	e8 5a ff ff ff       	call   5ec <write>
}
 692:	c9                   	leave  
 693:	c3                   	ret    

00000694 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 694:	55                   	push   %ebp
 695:	89 e5                	mov    %esp,%ebp
 697:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 69a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6a1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6a5:	74 17                	je     6be <printint+0x2a>
 6a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6ab:	79 11                	jns    6be <printint+0x2a>
    neg = 1;
 6ad:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b7:	f7 d8                	neg    %eax
 6b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6bc:	eb 06                	jmp    6c4 <printint+0x30>
  } else {
    x = xx;
 6be:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d1:	ba 00 00 00 00       	mov    $0x0,%edx
 6d6:	f7 f1                	div    %ecx
 6d8:	89 d0                	mov    %edx,%eax
 6da:	0f b6 80 00 0e 00 00 	movzbl 0xe00(%eax),%eax
 6e1:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 6e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6e7:	01 ca                	add    %ecx,%edx
 6e9:	88 02                	mov    %al,(%edx)
 6eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6ef:	8b 55 10             	mov    0x10(%ebp),%edx
 6f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f8:	ba 00 00 00 00       	mov    $0x0,%edx
 6fd:	f7 75 d4             	divl   -0x2c(%ebp)
 700:	89 45 ec             	mov    %eax,-0x14(%ebp)
 703:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 707:	75 c2                	jne    6cb <printint+0x37>
  if(neg)
 709:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 70d:	74 2e                	je     73d <printint+0xa9>
    buf[i++] = '-';
 70f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 712:	8b 45 f4             	mov    -0xc(%ebp),%eax
 715:	01 d0                	add    %edx,%eax
 717:	c6 00 2d             	movb   $0x2d,(%eax)
 71a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 71e:	eb 1d                	jmp    73d <printint+0xa9>
    putc(fd, buf[i]);
 720:	8d 55 dc             	lea    -0x24(%ebp),%edx
 723:	8b 45 f4             	mov    -0xc(%ebp),%eax
 726:	01 d0                	add    %edx,%eax
 728:	0f b6 00             	movzbl (%eax),%eax
 72b:	0f be c0             	movsbl %al,%eax
 72e:	89 44 24 04          	mov    %eax,0x4(%esp)
 732:	8b 45 08             	mov    0x8(%ebp),%eax
 735:	89 04 24             	mov    %eax,(%esp)
 738:	e8 2f ff ff ff       	call   66c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 73d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 741:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 745:	79 d9                	jns    720 <printint+0x8c>
    putc(fd, buf[i]);
}
 747:	c9                   	leave  
 748:	c3                   	ret    

00000749 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 749:	55                   	push   %ebp
 74a:	89 e5                	mov    %esp,%ebp
 74c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 74f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 756:	8d 45 0c             	lea    0xc(%ebp),%eax
 759:	83 c0 04             	add    $0x4,%eax
 75c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 75f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 766:	e9 7d 01 00 00       	jmp    8e8 <printf+0x19f>
    c = fmt[i] & 0xff;
 76b:	8b 55 0c             	mov    0xc(%ebp),%edx
 76e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 771:	01 d0                	add    %edx,%eax
 773:	0f b6 00             	movzbl (%eax),%eax
 776:	0f be c0             	movsbl %al,%eax
 779:	25 ff 00 00 00       	and    $0xff,%eax
 77e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 781:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 785:	75 2c                	jne    7b3 <printf+0x6a>
      if(c == '%'){
 787:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78b:	75 0c                	jne    799 <printf+0x50>
        state = '%';
 78d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 794:	e9 4b 01 00 00       	jmp    8e4 <printf+0x19b>
      } else {
        putc(fd, c);
 799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79c:	0f be c0             	movsbl %al,%eax
 79f:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a3:	8b 45 08             	mov    0x8(%ebp),%eax
 7a6:	89 04 24             	mov    %eax,(%esp)
 7a9:	e8 be fe ff ff       	call   66c <putc>
 7ae:	e9 31 01 00 00       	jmp    8e4 <printf+0x19b>
      }
    } else if(state == '%'){
 7b3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7b7:	0f 85 27 01 00 00    	jne    8e4 <printf+0x19b>
      if(c == 'd'){
 7bd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c1:	75 2d                	jne    7f0 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c6:	8b 00                	mov    (%eax),%eax
 7c8:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7cf:	00 
 7d0:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7d7:	00 
 7d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 7dc:	8b 45 08             	mov    0x8(%ebp),%eax
 7df:	89 04 24             	mov    %eax,(%esp)
 7e2:	e8 ad fe ff ff       	call   694 <printint>
        ap++;
 7e7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7eb:	e9 ed 00 00 00       	jmp    8dd <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7f0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7f4:	74 06                	je     7fc <printf+0xb3>
 7f6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7fa:	75 2d                	jne    829 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ff:	8b 00                	mov    (%eax),%eax
 801:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 808:	00 
 809:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 810:	00 
 811:	89 44 24 04          	mov    %eax,0x4(%esp)
 815:	8b 45 08             	mov    0x8(%ebp),%eax
 818:	89 04 24             	mov    %eax,(%esp)
 81b:	e8 74 fe ff ff       	call   694 <printint>
        ap++;
 820:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 824:	e9 b4 00 00 00       	jmp    8dd <printf+0x194>
      } else if(c == 's'){
 829:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 82d:	75 46                	jne    875 <printf+0x12c>
        s = (char*)*ap;
 82f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 832:	8b 00                	mov    (%eax),%eax
 834:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 837:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 83b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 83f:	75 27                	jne    868 <printf+0x11f>
          s = "(null)";
 841:	c7 45 f4 3c 0b 00 00 	movl   $0xb3c,-0xc(%ebp)
        while(*s != 0){
 848:	eb 1e                	jmp    868 <printf+0x11f>
          putc(fd, *s);
 84a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84d:	0f b6 00             	movzbl (%eax),%eax
 850:	0f be c0             	movsbl %al,%eax
 853:	89 44 24 04          	mov    %eax,0x4(%esp)
 857:	8b 45 08             	mov    0x8(%ebp),%eax
 85a:	89 04 24             	mov    %eax,(%esp)
 85d:	e8 0a fe ff ff       	call   66c <putc>
          s++;
 862:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 866:	eb 01                	jmp    869 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 868:	90                   	nop
 869:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86c:	0f b6 00             	movzbl (%eax),%eax
 86f:	84 c0                	test   %al,%al
 871:	75 d7                	jne    84a <printf+0x101>
 873:	eb 68                	jmp    8dd <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 875:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 879:	75 1d                	jne    898 <printf+0x14f>
        putc(fd, *ap);
 87b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 87e:	8b 00                	mov    (%eax),%eax
 880:	0f be c0             	movsbl %al,%eax
 883:	89 44 24 04          	mov    %eax,0x4(%esp)
 887:	8b 45 08             	mov    0x8(%ebp),%eax
 88a:	89 04 24             	mov    %eax,(%esp)
 88d:	e8 da fd ff ff       	call   66c <putc>
        ap++;
 892:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 896:	eb 45                	jmp    8dd <printf+0x194>
      } else if(c == '%'){
 898:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 89c:	75 17                	jne    8b5 <printf+0x16c>
        putc(fd, c);
 89e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a1:	0f be c0             	movsbl %al,%eax
 8a4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8a8:	8b 45 08             	mov    0x8(%ebp),%eax
 8ab:	89 04 24             	mov    %eax,(%esp)
 8ae:	e8 b9 fd ff ff       	call   66c <putc>
 8b3:	eb 28                	jmp    8dd <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8b5:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8bc:	00 
 8bd:	8b 45 08             	mov    0x8(%ebp),%eax
 8c0:	89 04 24             	mov    %eax,(%esp)
 8c3:	e8 a4 fd ff ff       	call   66c <putc>
        putc(fd, c);
 8c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8cb:	0f be c0             	movsbl %al,%eax
 8ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d2:	8b 45 08             	mov    0x8(%ebp),%eax
 8d5:	89 04 24             	mov    %eax,(%esp)
 8d8:	e8 8f fd ff ff       	call   66c <putc>
      }
      state = 0;
 8dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8e4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8e8:	8b 55 0c             	mov    0xc(%ebp),%edx
 8eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ee:	01 d0                	add    %edx,%eax
 8f0:	0f b6 00             	movzbl (%eax),%eax
 8f3:	84 c0                	test   %al,%al
 8f5:	0f 85 70 fe ff ff    	jne    76b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8fb:	c9                   	leave  
 8fc:	c3                   	ret    
 8fd:	66 90                	xchg   %ax,%ax
 8ff:	90                   	nop

00000900 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 900:	55                   	push   %ebp
 901:	89 e5                	mov    %esp,%ebp
 903:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 906:	8b 45 08             	mov    0x8(%ebp),%eax
 909:	83 e8 08             	sub    $0x8,%eax
 90c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90f:	a1 1c 0e 00 00       	mov    0xe1c,%eax
 914:	89 45 fc             	mov    %eax,-0x4(%ebp)
 917:	eb 24                	jmp    93d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 921:	77 12                	ja     935 <free+0x35>
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 929:	77 24                	ja     94f <free+0x4f>
 92b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92e:	8b 00                	mov    (%eax),%eax
 930:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 933:	77 1a                	ja     94f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 935:	8b 45 fc             	mov    -0x4(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 943:	76 d4                	jbe    919 <free+0x19>
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 00                	mov    (%eax),%eax
 94a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 94d:	76 ca                	jbe    919 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 94f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 95c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95f:	01 c2                	add    %eax,%edx
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	39 c2                	cmp    %eax,%edx
 968:	75 24                	jne    98e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 96a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96d:	8b 50 04             	mov    0x4(%eax),%edx
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	8b 00                	mov    (%eax),%eax
 975:	8b 40 04             	mov    0x4(%eax),%eax
 978:	01 c2                	add    %eax,%edx
 97a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 980:	8b 45 fc             	mov    -0x4(%ebp),%eax
 983:	8b 00                	mov    (%eax),%eax
 985:	8b 10                	mov    (%eax),%edx
 987:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98a:	89 10                	mov    %edx,(%eax)
 98c:	eb 0a                	jmp    998 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 98e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 991:	8b 10                	mov    (%eax),%edx
 993:	8b 45 f8             	mov    -0x8(%ebp),%eax
 996:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 998:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99b:	8b 40 04             	mov    0x4(%eax),%eax
 99e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a8:	01 d0                	add    %edx,%eax
 9aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9ad:	75 20                	jne    9cf <free+0xcf>
    p->s.size += bp->s.size;
 9af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b2:	8b 50 04             	mov    0x4(%eax),%edx
 9b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b8:	8b 40 04             	mov    0x4(%eax),%eax
 9bb:	01 c2                	add    %eax,%edx
 9bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c6:	8b 10                	mov    (%eax),%edx
 9c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cb:	89 10                	mov    %edx,(%eax)
 9cd:	eb 08                	jmp    9d7 <free+0xd7>
  } else
    p->s.ptr = bp;
 9cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9d5:	89 10                	mov    %edx,(%eax)
  freep = p;
 9d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9da:	a3 1c 0e 00 00       	mov    %eax,0xe1c
}
 9df:	c9                   	leave  
 9e0:	c3                   	ret    

000009e1 <morecore>:

static Header*
morecore(uint nu)
{
 9e1:	55                   	push   %ebp
 9e2:	89 e5                	mov    %esp,%ebp
 9e4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9e7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9ee:	77 07                	ja     9f7 <morecore+0x16>
    nu = 4096;
 9f0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9f7:	8b 45 08             	mov    0x8(%ebp),%eax
 9fa:	c1 e0 03             	shl    $0x3,%eax
 9fd:	89 04 24             	mov    %eax,(%esp)
 a00:	e8 4f fc ff ff       	call   654 <sbrk>
 a05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a08:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a0c:	75 07                	jne    a15 <morecore+0x34>
    return 0;
 a0e:	b8 00 00 00 00       	mov    $0x0,%eax
 a13:	eb 22                	jmp    a37 <morecore+0x56>
  hp = (Header*)p;
 a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1e:	8b 55 08             	mov    0x8(%ebp),%edx
 a21:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a27:	83 c0 08             	add    $0x8,%eax
 a2a:	89 04 24             	mov    %eax,(%esp)
 a2d:	e8 ce fe ff ff       	call   900 <free>
  return freep;
 a32:	a1 1c 0e 00 00       	mov    0xe1c,%eax
}
 a37:	c9                   	leave  
 a38:	c3                   	ret    

00000a39 <malloc>:

void*
malloc(uint nbytes)
{
 a39:	55                   	push   %ebp
 a3a:	89 e5                	mov    %esp,%ebp
 a3c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3f:	8b 45 08             	mov    0x8(%ebp),%eax
 a42:	83 c0 07             	add    $0x7,%eax
 a45:	c1 e8 03             	shr    $0x3,%eax
 a48:	83 c0 01             	add    $0x1,%eax
 a4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a4e:	a1 1c 0e 00 00       	mov    0xe1c,%eax
 a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a5a:	75 23                	jne    a7f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a5c:	c7 45 f0 14 0e 00 00 	movl   $0xe14,-0x10(%ebp)
 a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a66:	a3 1c 0e 00 00       	mov    %eax,0xe1c
 a6b:	a1 1c 0e 00 00       	mov    0xe1c,%eax
 a70:	a3 14 0e 00 00       	mov    %eax,0xe14
    base.s.size = 0;
 a75:	c7 05 18 0e 00 00 00 	movl   $0x0,0xe18
 a7c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a82:	8b 00                	mov    (%eax),%eax
 a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8a:	8b 40 04             	mov    0x4(%eax),%eax
 a8d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a90:	72 4d                	jb     adf <malloc+0xa6>
      if(p->s.size == nunits)
 a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a95:	8b 40 04             	mov    0x4(%eax),%eax
 a98:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a9b:	75 0c                	jne    aa9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa0:	8b 10                	mov    (%eax),%edx
 aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa5:	89 10                	mov    %edx,(%eax)
 aa7:	eb 26                	jmp    acf <malloc+0x96>
      else {
        p->s.size -= nunits;
 aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aac:	8b 40 04             	mov    0x4(%eax),%eax
 aaf:	89 c2                	mov    %eax,%edx
 ab1:	2b 55 ec             	sub    -0x14(%ebp),%edx
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	8b 40 04             	mov    0x4(%eax),%eax
 ac0:	c1 e0 03             	shl    $0x3,%eax
 ac3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 acc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad2:	a3 1c 0e 00 00       	mov    %eax,0xe1c
      return (void*)(p + 1);
 ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ada:	83 c0 08             	add    $0x8,%eax
 add:	eb 38                	jmp    b17 <malloc+0xde>
    }
    if(p == freep)
 adf:	a1 1c 0e 00 00       	mov    0xe1c,%eax
 ae4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ae7:	75 1b                	jne    b04 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 aec:	89 04 24             	mov    %eax,(%esp)
 aef:	e8 ed fe ff ff       	call   9e1 <morecore>
 af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 af7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 afb:	75 07                	jne    b04 <malloc+0xcb>
        return 0;
 afd:	b8 00 00 00 00       	mov    $0x0,%eax
 b02:	eb 13                	jmp    b17 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b07:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0d:	8b 00                	mov    (%eax),%eax
 b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b12:	e9 70 ff ff ff       	jmp    a87 <malloc+0x4e>
}
 b17:	c9                   	leave  
 b18:	c3                   	ret    
