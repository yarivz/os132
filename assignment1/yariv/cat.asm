
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   6:	eb 1b                	jmp    23 <cat+0x23>
    write(1, buf, n);
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 a0 0d 00 	movl   $0xda0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 11 05 00 00       	call   534 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2a:	00 
  2b:	c7 44 24 04 a0 0d 00 	movl   $0xda0,0x4(%esp)
  32:	00 
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 ee 04 00 00       	call   52c <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 4f 0a 00 	movl   $0xa4f,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 2a 06 00 00       	call   68b <printf>
    exit();
  61:	e8 a6 04 00 00       	call   50c <exit>
  }
}
  66:	c9                   	leave  
  67:	c3                   	ret    

00000068 <main>:

int
main(int argc, char *argv[])
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	83 e4 f0             	and    $0xfffffff0,%esp
  6e:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  71:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  75:	7f 11                	jg     88 <main+0x20>
    cat(0);
  77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  7e:	e8 7d ff ff ff       	call   0 <cat>
    exit();
  83:	e8 84 04 00 00       	call   50c <exit>
  }

  for(i = 1; i < argc; i++){
  88:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  8f:	00 
  90:	eb 6d                	jmp    ff <main+0x97>
    if((fd = open(argv[i], 0)) < 0){
  92:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  96:	c1 e0 02             	shl    $0x2,%eax
  99:	03 45 0c             	add    0xc(%ebp),%eax
  9c:	8b 00                	mov    (%eax),%eax
  9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  a5:	00 
  a6:	89 04 24             	mov    %eax,(%esp)
  a9:	e8 a6 04 00 00       	call   554 <open>
  ae:	89 44 24 18          	mov    %eax,0x18(%esp)
  b2:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  b7:	79 29                	jns    e2 <main+0x7a>
      printf(1, "cat: cannot open %s\n", argv[i]);
  b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  bd:	c1 e0 02             	shl    $0x2,%eax
  c0:	03 45 0c             	add    0xc(%ebp),%eax
  c3:	8b 00                	mov    (%eax),%eax
  c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  c9:	c7 44 24 04 60 0a 00 	movl   $0xa60,0x4(%esp)
  d0:	00 
  d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d8:	e8 ae 05 00 00       	call   68b <printf>
      exit();
  dd:	e8 2a 04 00 00       	call   50c <exit>
    }
    cat(fd);
  e2:	8b 44 24 18          	mov    0x18(%esp),%eax
  e6:	89 04 24             	mov    %eax,(%esp)
  e9:	e8 12 ff ff ff       	call   0 <cat>
    close(fd);
  ee:	8b 44 24 18          	mov    0x18(%esp),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 42 04 00 00       	call   53c <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  fa:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  ff:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 103:	3b 45 08             	cmp    0x8(%ebp),%eax
 106:	7c 8a                	jl     92 <main+0x2a>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 108:	e8 ff 03 00 00       	call   50c <exit>
 10d:	90                   	nop
 10e:	90                   	nop
 10f:	90                   	nop

00000110 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	57                   	push   %edi
 114:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 115:	8b 4d 08             	mov    0x8(%ebp),%ecx
 118:	8b 55 10             	mov    0x10(%ebp),%edx
 11b:	8b 45 0c             	mov    0xc(%ebp),%eax
 11e:	89 cb                	mov    %ecx,%ebx
 120:	89 df                	mov    %ebx,%edi
 122:	89 d1                	mov    %edx,%ecx
 124:	fc                   	cld    
 125:	f3 aa                	rep stos %al,%es:(%edi)
 127:	89 ca                	mov    %ecx,%edx
 129:	89 fb                	mov    %edi,%ebx
 12b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 131:	5b                   	pop    %ebx
 132:	5f                   	pop    %edi
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 141:	90                   	nop
 142:	8b 45 0c             	mov    0xc(%ebp),%eax
 145:	0f b6 10             	movzbl (%eax),%edx
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	88 10                	mov    %dl,(%eax)
 14d:	8b 45 08             	mov    0x8(%ebp),%eax
 150:	0f b6 00             	movzbl (%eax),%eax
 153:	84 c0                	test   %al,%al
 155:	0f 95 c0             	setne  %al
 158:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 15c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 160:	84 c0                	test   %al,%al
 162:	75 de                	jne    142 <strcpy+0xd>
    ;
  return os;
 164:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 167:	c9                   	leave  
 168:	c3                   	ret    

00000169 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 169:	55                   	push   %ebp
 16a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 16c:	eb 08                	jmp    176 <strcmp+0xd>
    p++, q++;
 16e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 172:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	0f b6 00             	movzbl (%eax),%eax
 17c:	84 c0                	test   %al,%al
 17e:	74 10                	je     190 <strcmp+0x27>
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	0f b6 10             	movzbl (%eax),%edx
 186:	8b 45 0c             	mov    0xc(%ebp),%eax
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	38 c2                	cmp    %al,%dl
 18e:	74 de                	je     16e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 190:	8b 45 08             	mov    0x8(%ebp),%eax
 193:	0f b6 00             	movzbl (%eax),%eax
 196:	0f b6 d0             	movzbl %al,%edx
 199:	8b 45 0c             	mov    0xc(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	0f b6 c0             	movzbl %al,%eax
 1a2:	89 d1                	mov    %edx,%ecx
 1a4:	29 c1                	sub    %eax,%ecx
 1a6:	89 c8                	mov    %ecx,%eax
}
 1a8:	5d                   	pop    %ebp
 1a9:	c3                   	ret    

000001aa <strlen>:

uint
strlen(char *s)
{
 1aa:	55                   	push   %ebp
 1ab:	89 e5                	mov    %esp,%ebp
 1ad:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 1b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b7:	eb 04                	jmp    1bd <strlen+0x13>
 1b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1c0:	03 45 08             	add    0x8(%ebp),%eax
 1c3:	0f b6 00             	movzbl (%eax),%eax
 1c6:	84 c0                	test   %al,%al
 1c8:	75 ef                	jne    1b9 <strlen+0xf>
  return n;
 1ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1cd:	c9                   	leave  
 1ce:	c3                   	ret    

000001cf <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
 1d2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d5:	8b 45 10             	mov    0x10(%ebp),%eax
 1d8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 1df:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
 1e6:	89 04 24             	mov    %eax,(%esp)
 1e9:	e8 22 ff ff ff       	call   110 <stosb>
  return dst;
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f1:	c9                   	leave  
 1f2:	c3                   	ret    

000001f3 <strchr>:

char*
strchr(const char *s, char c)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	83 ec 04             	sub    $0x4,%esp
 1f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fc:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1ff:	eb 14                	jmp    215 <strchr+0x22>
    if(*s == c)
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	0f b6 00             	movzbl (%eax),%eax
 207:	3a 45 fc             	cmp    -0x4(%ebp),%al
 20a:	75 05                	jne    211 <strchr+0x1e>
      return (char*)s;
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
 20f:	eb 13                	jmp    224 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 211:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	0f b6 00             	movzbl (%eax),%eax
 21b:	84 c0                	test   %al,%al
 21d:	75 e2                	jne    201 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 21f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 224:	c9                   	leave  
 225:	c3                   	ret    

00000226 <gets>:

char*
gets(char *buf, int max)
{
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
 229:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 233:	eb 44                	jmp    279 <gets+0x53>
    cc = read(0, &c, 1);
 235:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 23c:	00 
 23d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 240:	89 44 24 04          	mov    %eax,0x4(%esp)
 244:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 24b:	e8 dc 02 00 00       	call   52c <read>
 250:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 253:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 257:	7e 2d                	jle    286 <gets+0x60>
      break;
    buf[i++] = c;
 259:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25c:	03 45 08             	add    0x8(%ebp),%eax
 25f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 263:	88 10                	mov    %dl,(%eax)
 265:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 269:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26d:	3c 0a                	cmp    $0xa,%al
 26f:	74 16                	je     287 <gets+0x61>
 271:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 275:	3c 0d                	cmp    $0xd,%al
 277:	74 0e                	je     287 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 279:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27c:	83 c0 01             	add    $0x1,%eax
 27f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 282:	7c b1                	jl     235 <gets+0xf>
 284:	eb 01                	jmp    287 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 286:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 287:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28a:	03 45 08             	add    0x8(%ebp),%eax
 28d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 290:	8b 45 08             	mov    0x8(%ebp),%eax
}
 293:	c9                   	leave  
 294:	c3                   	ret    

00000295 <stat>:

int
stat(char *n, struct stat *st)
{
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a2:	00 
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	89 04 24             	mov    %eax,(%esp)
 2a9:	e8 a6 02 00 00       	call   554 <open>
 2ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b5:	79 07                	jns    2be <stat+0x29>
    return -1;
 2b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bc:	eb 23                	jmp    2e1 <stat+0x4c>
  r = fstat(fd, st);
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c8:	89 04 24             	mov    %eax,(%esp)
 2cb:	e8 9c 02 00 00       	call   56c <fstat>
 2d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d6:	89 04 24             	mov    %eax,(%esp)
 2d9:	e8 5e 02 00 00       	call   53c <close>
  return r;
 2de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e1:	c9                   	leave  
 2e2:	c3                   	ret    

000002e3 <atoi>:

int
atoi(const char *s)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f0:	eb 23                	jmp    315 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f5:	89 d0                	mov    %edx,%eax
 2f7:	c1 e0 02             	shl    $0x2,%eax
 2fa:	01 d0                	add    %edx,%eax
 2fc:	01 c0                	add    %eax,%eax
 2fe:	89 c2                	mov    %eax,%edx
 300:	8b 45 08             	mov    0x8(%ebp),%eax
 303:	0f b6 00             	movzbl (%eax),%eax
 306:	0f be c0             	movsbl %al,%eax
 309:	01 d0                	add    %edx,%eax
 30b:	83 e8 30             	sub    $0x30,%eax
 30e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 311:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	0f b6 00             	movzbl (%eax),%eax
 31b:	3c 2f                	cmp    $0x2f,%al
 31d:	7e 0a                	jle    329 <atoi+0x46>
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	0f b6 00             	movzbl (%eax),%eax
 325:	3c 39                	cmp    $0x39,%al
 327:	7e c9                	jle    2f2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 329:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32c:	c9                   	leave  
 32d:	c3                   	ret    

0000032e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 32e:	55                   	push   %ebp
 32f:	89 e5                	mov    %esp,%ebp
 331:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33a:	8b 45 0c             	mov    0xc(%ebp),%eax
 33d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 340:	eb 13                	jmp    355 <memmove+0x27>
    *dst++ = *src++;
 342:	8b 45 f8             	mov    -0x8(%ebp),%eax
 345:	0f b6 10             	movzbl (%eax),%edx
 348:	8b 45 fc             	mov    -0x4(%ebp),%eax
 34b:	88 10                	mov    %dl,(%eax)
 34d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 351:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 355:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 359:	0f 9f c0             	setg   %al
 35c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 360:	84 c0                	test   %al,%al
 362:	75 de                	jne    342 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 364:	8b 45 08             	mov    0x8(%ebp),%eax
}
 367:	c9                   	leave  
 368:	c3                   	ret    

00000369 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 369:	55                   	push   %ebp
 36a:	89 e5                	mov    %esp,%ebp
 36c:	83 ec 38             	sub    $0x38,%esp
 36f:	8b 45 10             	mov    0x10(%ebp),%eax
 372:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 375:	8b 45 14             	mov    0x14(%ebp),%eax
 378:	8b 00                	mov    (%eax),%eax
 37a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 37d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 384:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 388:	74 06                	je     390 <strtok+0x27>
 38a:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 38e:	75 54                	jne    3e4 <strtok+0x7b>
    return match;
 390:	8b 45 f0             	mov    -0x10(%ebp),%eax
 393:	eb 6e                	jmp    403 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 395:	8b 45 f4             	mov    -0xc(%ebp),%eax
 398:	03 45 0c             	add    0xc(%ebp),%eax
 39b:	0f b6 00             	movzbl (%eax),%eax
 39e:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3a1:	74 06                	je     3a9 <strtok+0x40>
      {
	index++;
 3a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3a7:	eb 3c                	jmp    3e5 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 3a9:	8b 45 14             	mov    0x14(%ebp),%eax
 3ac:	8b 00                	mov    (%eax),%eax
 3ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3b1:	29 c2                	sub    %eax,%edx
 3b3:	8b 45 14             	mov    0x14(%ebp),%eax
 3b6:	8b 00                	mov    (%eax),%eax
 3b8:	03 45 0c             	add    0xc(%ebp),%eax
 3bb:	89 54 24 08          	mov    %edx,0x8(%esp)
 3bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	89 04 24             	mov    %eax,(%esp)
 3c9:	e8 37 00 00 00       	call   405 <strncpy>
 3ce:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	84 c0                	test   %al,%al
 3d9:	74 19                	je     3f4 <strtok+0x8b>
	  match = 1;
 3db:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 3e2:	eb 10                	jmp    3f4 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 3e4:	90                   	nop
 3e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e8:	03 45 0c             	add    0xc(%ebp),%eax
 3eb:	0f b6 00             	movzbl (%eax),%eax
 3ee:	84 c0                	test   %al,%al
 3f0:	75 a3                	jne    395 <strtok+0x2c>
 3f2:	eb 01                	jmp    3f5 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 3f4:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 3f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f8:	8d 50 01             	lea    0x1(%eax),%edx
 3fb:	8b 45 14             	mov    0x14(%ebp),%eax
 3fe:	89 10                	mov    %edx,(%eax)
  return match;
 400:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 403:	c9                   	leave  
 404:	c3                   	ret    

00000405 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 405:	55                   	push   %ebp
 406:	89 e5                	mov    %esp,%ebp
 408:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 40b:	8b 45 08             	mov    0x8(%ebp),%eax
 40e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 411:	90                   	nop
 412:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 416:	0f 9f c0             	setg   %al
 419:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 41d:	84 c0                	test   %al,%al
 41f:	74 30                	je     451 <strncpy+0x4c>
 421:	8b 45 0c             	mov    0xc(%ebp),%eax
 424:	0f b6 10             	movzbl (%eax),%edx
 427:	8b 45 08             	mov    0x8(%ebp),%eax
 42a:	88 10                	mov    %dl,(%eax)
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
 42f:	0f b6 00             	movzbl (%eax),%eax
 432:	84 c0                	test   %al,%al
 434:	0f 95 c0             	setne  %al
 437:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 43f:	84 c0                	test   %al,%al
 441:	75 cf                	jne    412 <strncpy+0xd>
    ;
  while(n-- > 0)
 443:	eb 0c                	jmp    451 <strncpy+0x4c>
    *s++ = 0;
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	c6 00 00             	movb   $0x0,(%eax)
 44b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 44f:	eb 01                	jmp    452 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 451:	90                   	nop
 452:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 456:	0f 9f c0             	setg   %al
 459:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 45d:	84 c0                	test   %al,%al
 45f:	75 e4                	jne    445 <strncpy+0x40>
    *s++ = 0;
  return os;
 461:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 464:	c9                   	leave  
 465:	c3                   	ret    

00000466 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 466:	55                   	push   %ebp
 467:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 469:	eb 0c                	jmp    477 <strncmp+0x11>
    n--, p++, q++;
 46b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 46f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 473:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 477:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 47b:	74 1a                	je     497 <strncmp+0x31>
 47d:	8b 45 08             	mov    0x8(%ebp),%eax
 480:	0f b6 00             	movzbl (%eax),%eax
 483:	84 c0                	test   %al,%al
 485:	74 10                	je     497 <strncmp+0x31>
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	0f b6 10             	movzbl (%eax),%edx
 48d:	8b 45 0c             	mov    0xc(%ebp),%eax
 490:	0f b6 00             	movzbl (%eax),%eax
 493:	38 c2                	cmp    %al,%dl
 495:	74 d4                	je     46b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 497:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 49b:	75 07                	jne    4a4 <strncmp+0x3e>
    return 0;
 49d:	b8 00 00 00 00       	mov    $0x0,%eax
 4a2:	eb 18                	jmp    4bc <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4a4:	8b 45 08             	mov    0x8(%ebp),%eax
 4a7:	0f b6 00             	movzbl (%eax),%eax
 4aa:	0f b6 d0             	movzbl %al,%edx
 4ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b0:	0f b6 00             	movzbl (%eax),%eax
 4b3:	0f b6 c0             	movzbl %al,%eax
 4b6:	89 d1                	mov    %edx,%ecx
 4b8:	29 c1                	sub    %eax,%ecx
 4ba:	89 c8                	mov    %ecx,%eax
}
 4bc:	5d                   	pop    %ebp
 4bd:	c3                   	ret    

000004be <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 4be:	55                   	push   %ebp
 4bf:	89 e5                	mov    %esp,%ebp
  while(*p){
 4c1:	eb 13                	jmp    4d6 <strcat+0x18>
    *dest++ = *p++;
 4c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c6:	0f b6 10             	movzbl (%eax),%edx
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	88 10                	mov    %dl,(%eax)
 4ce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4d2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 4d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d9:	0f b6 00             	movzbl (%eax),%eax
 4dc:	84 c0                	test   %al,%al
 4de:	75 e3                	jne    4c3 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 4e0:	eb 13                	jmp    4f5 <strcat+0x37>
    *dest++ = *q++;
 4e2:	8b 45 10             	mov    0x10(%ebp),%eax
 4e5:	0f b6 10             	movzbl (%eax),%edx
 4e8:	8b 45 08             	mov    0x8(%ebp),%eax
 4eb:	88 10                	mov    %dl,(%eax)
 4ed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4f1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 4f5:	8b 45 10             	mov    0x10(%ebp),%eax
 4f8:	0f b6 00             	movzbl (%eax),%eax
 4fb:	84 c0                	test   %al,%al
 4fd:	75 e3                	jne    4e2 <strcat+0x24>
    *dest++ = *q++;
  }  
 4ff:	5d                   	pop    %ebp
 500:	c3                   	ret    
 501:	90                   	nop
 502:	90                   	nop
 503:	90                   	nop

00000504 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 504:	b8 01 00 00 00       	mov    $0x1,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <exit>:
SYSCALL(exit)
 50c:	b8 02 00 00 00       	mov    $0x2,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <wait>:
SYSCALL(wait)
 514:	b8 03 00 00 00       	mov    $0x3,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <wait2>:
SYSCALL(wait2)
 51c:	b8 16 00 00 00       	mov    $0x16,%eax
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
 622:	0f b6 90 58 0d 00 00 	movzbl 0xd58(%eax),%edx
 629:	8d 45 dc             	lea    -0x24(%ebp),%eax
 62c:	03 45 f4             	add    -0xc(%ebp),%eax
 62f:	88 10                	mov    %dl,(%eax)
 631:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 635:	8b 55 10             	mov    0x10(%ebp),%edx
 638:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 63b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 63e:	ba 00 00 00 00       	mov    $0x0,%edx
 643:	f7 75 d4             	divl   -0x2c(%ebp)
 646:	89 45 ec             	mov    %eax,-0x14(%ebp)
 649:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64d:	75 c4                	jne    613 <printint+0x37>
  if(neg)
 64f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 653:	74 2a                	je     67f <printint+0xa3>
    buf[i++] = '-';
 655:	8d 45 dc             	lea    -0x24(%ebp),%eax
 658:	03 45 f4             	add    -0xc(%ebp),%eax
 65b:	c6 00 2d             	movb   $0x2d,(%eax)
 65e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 662:	eb 1b                	jmp    67f <printint+0xa3>
    putc(fd, buf[i]);
 664:	8d 45 dc             	lea    -0x24(%ebp),%eax
 667:	03 45 f4             	add    -0xc(%ebp),%eax
 66a:	0f b6 00             	movzbl (%eax),%eax
 66d:	0f be c0             	movsbl %al,%eax
 670:	89 44 24 04          	mov    %eax,0x4(%esp)
 674:	8b 45 08             	mov    0x8(%ebp),%eax
 677:	89 04 24             	mov    %eax,(%esp)
 67a:	e8 35 ff ff ff       	call   5b4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 67f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 683:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 687:	79 db                	jns    664 <printint+0x88>
    putc(fd, buf[i]);
}
 689:	c9                   	leave  
 68a:	c3                   	ret    

0000068b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 68b:	55                   	push   %ebp
 68c:	89 e5                	mov    %esp,%ebp
 68e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 691:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 698:	8d 45 0c             	lea    0xc(%ebp),%eax
 69b:	83 c0 04             	add    $0x4,%eax
 69e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6a8:	e9 7d 01 00 00       	jmp    82a <printf+0x19f>
    c = fmt[i] & 0xff;
 6ad:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b3:	01 d0                	add    %edx,%eax
 6b5:	0f b6 00             	movzbl (%eax),%eax
 6b8:	0f be c0             	movsbl %al,%eax
 6bb:	25 ff 00 00 00       	and    $0xff,%eax
 6c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c7:	75 2c                	jne    6f5 <printf+0x6a>
      if(c == '%'){
 6c9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6cd:	75 0c                	jne    6db <printf+0x50>
        state = '%';
 6cf:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6d6:	e9 4b 01 00 00       	jmp    826 <printf+0x19b>
      } else {
        putc(fd, c);
 6db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6de:	0f be c0             	movsbl %al,%eax
 6e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e5:	8b 45 08             	mov    0x8(%ebp),%eax
 6e8:	89 04 24             	mov    %eax,(%esp)
 6eb:	e8 c4 fe ff ff       	call   5b4 <putc>
 6f0:	e9 31 01 00 00       	jmp    826 <printf+0x19b>
      }
    } else if(state == '%'){
 6f5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6f9:	0f 85 27 01 00 00    	jne    826 <printf+0x19b>
      if(c == 'd'){
 6ff:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 703:	75 2d                	jne    732 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 705:	8b 45 e8             	mov    -0x18(%ebp),%eax
 708:	8b 00                	mov    (%eax),%eax
 70a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 711:	00 
 712:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 719:	00 
 71a:	89 44 24 04          	mov    %eax,0x4(%esp)
 71e:	8b 45 08             	mov    0x8(%ebp),%eax
 721:	89 04 24             	mov    %eax,(%esp)
 724:	e8 b3 fe ff ff       	call   5dc <printint>
        ap++;
 729:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72d:	e9 ed 00 00 00       	jmp    81f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 732:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 736:	74 06                	je     73e <printf+0xb3>
 738:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 73c:	75 2d                	jne    76b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 73e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 741:	8b 00                	mov    (%eax),%eax
 743:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 74a:	00 
 74b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 752:	00 
 753:	89 44 24 04          	mov    %eax,0x4(%esp)
 757:	8b 45 08             	mov    0x8(%ebp),%eax
 75a:	89 04 24             	mov    %eax,(%esp)
 75d:	e8 7a fe ff ff       	call   5dc <printint>
        ap++;
 762:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 766:	e9 b4 00 00 00       	jmp    81f <printf+0x194>
      } else if(c == 's'){
 76b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 76f:	75 46                	jne    7b7 <printf+0x12c>
        s = (char*)*ap;
 771:	8b 45 e8             	mov    -0x18(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 779:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 77d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 781:	75 27                	jne    7aa <printf+0x11f>
          s = "(null)";
 783:	c7 45 f4 75 0a 00 00 	movl   $0xa75,-0xc(%ebp)
        while(*s != 0){
 78a:	eb 1e                	jmp    7aa <printf+0x11f>
          putc(fd, *s);
 78c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78f:	0f b6 00             	movzbl (%eax),%eax
 792:	0f be c0             	movsbl %al,%eax
 795:	89 44 24 04          	mov    %eax,0x4(%esp)
 799:	8b 45 08             	mov    0x8(%ebp),%eax
 79c:	89 04 24             	mov    %eax,(%esp)
 79f:	e8 10 fe ff ff       	call   5b4 <putc>
          s++;
 7a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7a8:	eb 01                	jmp    7ab <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7aa:	90                   	nop
 7ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ae:	0f b6 00             	movzbl (%eax),%eax
 7b1:	84 c0                	test   %al,%al
 7b3:	75 d7                	jne    78c <printf+0x101>
 7b5:	eb 68                	jmp    81f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7b7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7bb:	75 1d                	jne    7da <printf+0x14f>
        putc(fd, *ap);
 7bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c0:	8b 00                	mov    (%eax),%eax
 7c2:	0f be c0             	movsbl %al,%eax
 7c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c9:	8b 45 08             	mov    0x8(%ebp),%eax
 7cc:	89 04 24             	mov    %eax,(%esp)
 7cf:	e8 e0 fd ff ff       	call   5b4 <putc>
        ap++;
 7d4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7d8:	eb 45                	jmp    81f <printf+0x194>
      } else if(c == '%'){
 7da:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7de:	75 17                	jne    7f7 <printf+0x16c>
        putc(fd, c);
 7e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e3:	0f be c0             	movsbl %al,%eax
 7e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ea:	8b 45 08             	mov    0x8(%ebp),%eax
 7ed:	89 04 24             	mov    %eax,(%esp)
 7f0:	e8 bf fd ff ff       	call   5b4 <putc>
 7f5:	eb 28                	jmp    81f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7f7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7fe:	00 
 7ff:	8b 45 08             	mov    0x8(%ebp),%eax
 802:	89 04 24             	mov    %eax,(%esp)
 805:	e8 aa fd ff ff       	call   5b4 <putc>
        putc(fd, c);
 80a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 80d:	0f be c0             	movsbl %al,%eax
 810:	89 44 24 04          	mov    %eax,0x4(%esp)
 814:	8b 45 08             	mov    0x8(%ebp),%eax
 817:	89 04 24             	mov    %eax,(%esp)
 81a:	e8 95 fd ff ff       	call   5b4 <putc>
      }
      state = 0;
 81f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 826:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 82a:	8b 55 0c             	mov    0xc(%ebp),%edx
 82d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 830:	01 d0                	add    %edx,%eax
 832:	0f b6 00             	movzbl (%eax),%eax
 835:	84 c0                	test   %al,%al
 837:	0f 85 70 fe ff ff    	jne    6ad <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 83d:	c9                   	leave  
 83e:	c3                   	ret    
 83f:	90                   	nop

00000840 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 840:	55                   	push   %ebp
 841:	89 e5                	mov    %esp,%ebp
 843:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 846:	8b 45 08             	mov    0x8(%ebp),%eax
 849:	83 e8 08             	sub    $0x8,%eax
 84c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84f:	a1 88 0d 00 00       	mov    0xd88,%eax
 854:	89 45 fc             	mov    %eax,-0x4(%ebp)
 857:	eb 24                	jmp    87d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 00                	mov    (%eax),%eax
 85e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 861:	77 12                	ja     875 <free+0x35>
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 869:	77 24                	ja     88f <free+0x4f>
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	8b 00                	mov    (%eax),%eax
 870:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 873:	77 1a                	ja     88f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	8b 00                	mov    (%eax),%eax
 87a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 87d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 880:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 883:	76 d4                	jbe    859 <free+0x19>
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	8b 00                	mov    (%eax),%eax
 88a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 88d:	76 ca                	jbe    859 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 88f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 892:	8b 40 04             	mov    0x4(%eax),%eax
 895:	c1 e0 03             	shl    $0x3,%eax
 898:	89 c2                	mov    %eax,%edx
 89a:	03 55 f8             	add    -0x8(%ebp),%edx
 89d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a0:	8b 00                	mov    (%eax),%eax
 8a2:	39 c2                	cmp    %eax,%edx
 8a4:	75 24                	jne    8ca <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a9:	8b 50 04             	mov    0x4(%eax),%edx
 8ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8af:	8b 00                	mov    (%eax),%eax
 8b1:	8b 40 04             	mov    0x4(%eax),%eax
 8b4:	01 c2                	add    %eax,%edx
 8b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bf:	8b 00                	mov    (%eax),%eax
 8c1:	8b 10                	mov    (%eax),%edx
 8c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c6:	89 10                	mov    %edx,(%eax)
 8c8:	eb 0a                	jmp    8d4 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cd:	8b 10                	mov    (%eax),%edx
 8cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d7:	8b 40 04             	mov    0x4(%eax),%eax
 8da:	c1 e0 03             	shl    $0x3,%eax
 8dd:	03 45 fc             	add    -0x4(%ebp),%eax
 8e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e3:	75 20                	jne    905 <free+0xc5>
    p->s.size += bp->s.size;
 8e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e8:	8b 50 04             	mov    0x4(%eax),%edx
 8eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ee:	8b 40 04             	mov    0x4(%eax),%eax
 8f1:	01 c2                	add    %eax,%edx
 8f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fc:	8b 10                	mov    (%eax),%edx
 8fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 901:	89 10                	mov    %edx,(%eax)
 903:	eb 08                	jmp    90d <free+0xcd>
  } else
    p->s.ptr = bp;
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	8b 55 f8             	mov    -0x8(%ebp),%edx
 90b:	89 10                	mov    %edx,(%eax)
  freep = p;
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	a3 88 0d 00 00       	mov    %eax,0xd88
}
 915:	c9                   	leave  
 916:	c3                   	ret    

00000917 <morecore>:

static Header*
morecore(uint nu)
{
 917:	55                   	push   %ebp
 918:	89 e5                	mov    %esp,%ebp
 91a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 91d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 924:	77 07                	ja     92d <morecore+0x16>
    nu = 4096;
 926:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 92d:	8b 45 08             	mov    0x8(%ebp),%eax
 930:	c1 e0 03             	shl    $0x3,%eax
 933:	89 04 24             	mov    %eax,(%esp)
 936:	e8 61 fc ff ff       	call   59c <sbrk>
 93b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 93e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 942:	75 07                	jne    94b <morecore+0x34>
    return 0;
 944:	b8 00 00 00 00       	mov    $0x0,%eax
 949:	eb 22                	jmp    96d <morecore+0x56>
  hp = (Header*)p;
 94b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 951:	8b 45 f0             	mov    -0x10(%ebp),%eax
 954:	8b 55 08             	mov    0x8(%ebp),%edx
 957:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 95a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95d:	83 c0 08             	add    $0x8,%eax
 960:	89 04 24             	mov    %eax,(%esp)
 963:	e8 d8 fe ff ff       	call   840 <free>
  return freep;
 968:	a1 88 0d 00 00       	mov    0xd88,%eax
}
 96d:	c9                   	leave  
 96e:	c3                   	ret    

0000096f <malloc>:

void*
malloc(uint nbytes)
{
 96f:	55                   	push   %ebp
 970:	89 e5                	mov    %esp,%ebp
 972:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 975:	8b 45 08             	mov    0x8(%ebp),%eax
 978:	83 c0 07             	add    $0x7,%eax
 97b:	c1 e8 03             	shr    $0x3,%eax
 97e:	83 c0 01             	add    $0x1,%eax
 981:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 984:	a1 88 0d 00 00       	mov    0xd88,%eax
 989:	89 45 f0             	mov    %eax,-0x10(%ebp)
 98c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 990:	75 23                	jne    9b5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 992:	c7 45 f0 80 0d 00 00 	movl   $0xd80,-0x10(%ebp)
 999:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99c:	a3 88 0d 00 00       	mov    %eax,0xd88
 9a1:	a1 88 0d 00 00       	mov    0xd88,%eax
 9a6:	a3 80 0d 00 00       	mov    %eax,0xd80
    base.s.size = 0;
 9ab:	c7 05 84 0d 00 00 00 	movl   $0x0,0xd84
 9b2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b8:	8b 00                	mov    (%eax),%eax
 9ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c0:	8b 40 04             	mov    0x4(%eax),%eax
 9c3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9c6:	72 4d                	jb     a15 <malloc+0xa6>
      if(p->s.size == nunits)
 9c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cb:	8b 40 04             	mov    0x4(%eax),%eax
 9ce:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9d1:	75 0c                	jne    9df <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d6:	8b 10                	mov    (%eax),%edx
 9d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9db:	89 10                	mov    %edx,(%eax)
 9dd:	eb 26                	jmp    a05 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e2:	8b 40 04             	mov    0x4(%eax),%eax
 9e5:	89 c2                	mov    %eax,%edx
 9e7:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ed:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f3:	8b 40 04             	mov    0x4(%eax),%eax
 9f6:	c1 e0 03             	shl    $0x3,%eax
 9f9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a02:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a08:	a3 88 0d 00 00       	mov    %eax,0xd88
      return (void*)(p + 1);
 a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a10:	83 c0 08             	add    $0x8,%eax
 a13:	eb 38                	jmp    a4d <malloc+0xde>
    }
    if(p == freep)
 a15:	a1 88 0d 00 00       	mov    0xd88,%eax
 a1a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a1d:	75 1b                	jne    a3a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a22:	89 04 24             	mov    %eax,(%esp)
 a25:	e8 ed fe ff ff       	call   917 <morecore>
 a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a31:	75 07                	jne    a3a <malloc+0xcb>
        return 0;
 a33:	b8 00 00 00 00       	mov    $0x0,%eax
 a38:	eb 13                	jmp    a4d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a43:	8b 00                	mov    (%eax),%eax
 a45:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a48:	e9 70 ff ff ff       	jmp    9bd <malloc+0x4e>
}
 a4d:	c9                   	leave  
 a4e:	c3                   	ret    
