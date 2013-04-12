
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
  1e:	e8 19 05 00 00       	call   53c <write>
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
  39:	e8 f6 04 00 00       	call   534 <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 57 0a 00 	movl   $0xa57,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 32 06 00 00       	call   693 <printf>
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
  a9:	e8 ae 04 00 00       	call   55c <open>
  ae:	89 44 24 18          	mov    %eax,0x18(%esp)
  b2:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  b7:	79 29                	jns    e2 <main+0x7a>
      printf(1, "cat: cannot open %s\n", argv[i]);
  b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  bd:	c1 e0 02             	shl    $0x2,%eax
  c0:	03 45 0c             	add    0xc(%ebp),%eax
  c3:	8b 00                	mov    (%eax),%eax
  c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  c9:	c7 44 24 04 68 0a 00 	movl   $0xa68,0x4(%esp)
  d0:	00 
  d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d8:	e8 b6 05 00 00       	call   693 <printf>
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
  f5:	e8 4a 04 00 00       	call   544 <close>
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
 24b:	e8 e4 02 00 00       	call   534 <read>
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
 2a9:	e8 ae 02 00 00       	call   55c <open>
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
 2cb:	e8 a4 02 00 00       	call   574 <fstat>
 2d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d6:	89 04 24             	mov    %eax,(%esp)
 2d9:	e8 66 02 00 00       	call   544 <close>
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

00000524 <nice>:
SYSCALL(nice)
 524:	b8 17 00 00 00       	mov    $0x17,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <pipe>:
SYSCALL(pipe)
 52c:	b8 04 00 00 00       	mov    $0x4,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <read>:
SYSCALL(read)
 534:	b8 05 00 00 00       	mov    $0x5,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <write>:
SYSCALL(write)
 53c:	b8 10 00 00 00       	mov    $0x10,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <close>:
SYSCALL(close)
 544:	b8 15 00 00 00       	mov    $0x15,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <kill>:
SYSCALL(kill)
 54c:	b8 06 00 00 00       	mov    $0x6,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <exec>:
SYSCALL(exec)
 554:	b8 07 00 00 00       	mov    $0x7,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <open>:
SYSCALL(open)
 55c:	b8 0f 00 00 00       	mov    $0xf,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <mknod>:
SYSCALL(mknod)
 564:	b8 11 00 00 00       	mov    $0x11,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <unlink>:
SYSCALL(unlink)
 56c:	b8 12 00 00 00       	mov    $0x12,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <fstat>:
SYSCALL(fstat)
 574:	b8 08 00 00 00       	mov    $0x8,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <link>:
SYSCALL(link)
 57c:	b8 13 00 00 00       	mov    $0x13,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <mkdir>:
SYSCALL(mkdir)
 584:	b8 14 00 00 00       	mov    $0x14,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <chdir>:
SYSCALL(chdir)
 58c:	b8 09 00 00 00       	mov    $0x9,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <dup>:
SYSCALL(dup)
 594:	b8 0a 00 00 00       	mov    $0xa,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <getpid>:
SYSCALL(getpid)
 59c:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <sbrk>:
SYSCALL(sbrk)
 5a4:	b8 0c 00 00 00       	mov    $0xc,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <sleep>:
SYSCALL(sleep)
 5ac:	b8 0d 00 00 00       	mov    $0xd,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <uptime>:
SYSCALL(uptime)
 5b4:	b8 0e 00 00 00       	mov    $0xe,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	83 ec 28             	sub    $0x28,%esp
 5c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5cf:	00 
 5d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d7:	8b 45 08             	mov    0x8(%ebp),%eax
 5da:	89 04 24             	mov    %eax,(%esp)
 5dd:	e8 5a ff ff ff       	call   53c <write>
}
 5e2:	c9                   	leave  
 5e3:	c3                   	ret    

000005e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5e4:	55                   	push   %ebp
 5e5:	89 e5                	mov    %esp,%ebp
 5e7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5f5:	74 17                	je     60e <printint+0x2a>
 5f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5fb:	79 11                	jns    60e <printint+0x2a>
    neg = 1;
 5fd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 604:	8b 45 0c             	mov    0xc(%ebp),%eax
 607:	f7 d8                	neg    %eax
 609:	89 45 ec             	mov    %eax,-0x14(%ebp)
 60c:	eb 06                	jmp    614 <printint+0x30>
  } else {
    x = xx;
 60e:	8b 45 0c             	mov    0xc(%ebp),%eax
 611:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 614:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 61b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 61e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 621:	ba 00 00 00 00       	mov    $0x0,%edx
 626:	f7 f1                	div    %ecx
 628:	89 d0                	mov    %edx,%eax
 62a:	0f b6 90 60 0d 00 00 	movzbl 0xd60(%eax),%edx
 631:	8d 45 dc             	lea    -0x24(%ebp),%eax
 634:	03 45 f4             	add    -0xc(%ebp),%eax
 637:	88 10                	mov    %dl,(%eax)
 639:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 63d:	8b 55 10             	mov    0x10(%ebp),%edx
 640:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 643:	8b 45 ec             	mov    -0x14(%ebp),%eax
 646:	ba 00 00 00 00       	mov    $0x0,%edx
 64b:	f7 75 d4             	divl   -0x2c(%ebp)
 64e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 651:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 655:	75 c4                	jne    61b <printint+0x37>
  if(neg)
 657:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 65b:	74 2a                	je     687 <printint+0xa3>
    buf[i++] = '-';
 65d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 660:	03 45 f4             	add    -0xc(%ebp),%eax
 663:	c6 00 2d             	movb   $0x2d,(%eax)
 666:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 66a:	eb 1b                	jmp    687 <printint+0xa3>
    putc(fd, buf[i]);
 66c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 66f:	03 45 f4             	add    -0xc(%ebp),%eax
 672:	0f b6 00             	movzbl (%eax),%eax
 675:	0f be c0             	movsbl %al,%eax
 678:	89 44 24 04          	mov    %eax,0x4(%esp)
 67c:	8b 45 08             	mov    0x8(%ebp),%eax
 67f:	89 04 24             	mov    %eax,(%esp)
 682:	e8 35 ff ff ff       	call   5bc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 687:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 68b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 68f:	79 db                	jns    66c <printint+0x88>
    putc(fd, buf[i]);
}
 691:	c9                   	leave  
 692:	c3                   	ret    

00000693 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 693:	55                   	push   %ebp
 694:	89 e5                	mov    %esp,%ebp
 696:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 699:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6a0:	8d 45 0c             	lea    0xc(%ebp),%eax
 6a3:	83 c0 04             	add    $0x4,%eax
 6a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6b0:	e9 7d 01 00 00       	jmp    832 <printf+0x19f>
    c = fmt[i] & 0xff;
 6b5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6bb:	01 d0                	add    %edx,%eax
 6bd:	0f b6 00             	movzbl (%eax),%eax
 6c0:	0f be c0             	movsbl %al,%eax
 6c3:	25 ff 00 00 00       	and    $0xff,%eax
 6c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6cf:	75 2c                	jne    6fd <printf+0x6a>
      if(c == '%'){
 6d1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d5:	75 0c                	jne    6e3 <printf+0x50>
        state = '%';
 6d7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6de:	e9 4b 01 00 00       	jmp    82e <printf+0x19b>
      } else {
        putc(fd, c);
 6e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e6:	0f be c0             	movsbl %al,%eax
 6e9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ed:	8b 45 08             	mov    0x8(%ebp),%eax
 6f0:	89 04 24             	mov    %eax,(%esp)
 6f3:	e8 c4 fe ff ff       	call   5bc <putc>
 6f8:	e9 31 01 00 00       	jmp    82e <printf+0x19b>
      }
    } else if(state == '%'){
 6fd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 701:	0f 85 27 01 00 00    	jne    82e <printf+0x19b>
      if(c == 'd'){
 707:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 70b:	75 2d                	jne    73a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 70d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 719:	00 
 71a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 721:	00 
 722:	89 44 24 04          	mov    %eax,0x4(%esp)
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	89 04 24             	mov    %eax,(%esp)
 72c:	e8 b3 fe ff ff       	call   5e4 <printint>
        ap++;
 731:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 735:	e9 ed 00 00 00       	jmp    827 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 73a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 73e:	74 06                	je     746 <printf+0xb3>
 740:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 744:	75 2d                	jne    773 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 746:	8b 45 e8             	mov    -0x18(%ebp),%eax
 749:	8b 00                	mov    (%eax),%eax
 74b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 752:	00 
 753:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 75a:	00 
 75b:	89 44 24 04          	mov    %eax,0x4(%esp)
 75f:	8b 45 08             	mov    0x8(%ebp),%eax
 762:	89 04 24             	mov    %eax,(%esp)
 765:	e8 7a fe ff ff       	call   5e4 <printint>
        ap++;
 76a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76e:	e9 b4 00 00 00       	jmp    827 <printf+0x194>
      } else if(c == 's'){
 773:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 777:	75 46                	jne    7bf <printf+0x12c>
        s = (char*)*ap;
 779:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77c:	8b 00                	mov    (%eax),%eax
 77e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 781:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 785:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 789:	75 27                	jne    7b2 <printf+0x11f>
          s = "(null)";
 78b:	c7 45 f4 7d 0a 00 00 	movl   $0xa7d,-0xc(%ebp)
        while(*s != 0){
 792:	eb 1e                	jmp    7b2 <printf+0x11f>
          putc(fd, *s);
 794:	8b 45 f4             	mov    -0xc(%ebp),%eax
 797:	0f b6 00             	movzbl (%eax),%eax
 79a:	0f be c0             	movsbl %al,%eax
 79d:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a1:	8b 45 08             	mov    0x8(%ebp),%eax
 7a4:	89 04 24             	mov    %eax,(%esp)
 7a7:	e8 10 fe ff ff       	call   5bc <putc>
          s++;
 7ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7b0:	eb 01                	jmp    7b3 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7b2:	90                   	nop
 7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b6:	0f b6 00             	movzbl (%eax),%eax
 7b9:	84 c0                	test   %al,%al
 7bb:	75 d7                	jne    794 <printf+0x101>
 7bd:	eb 68                	jmp    827 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7bf:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c3:	75 1d                	jne    7e2 <printf+0x14f>
        putc(fd, *ap);
 7c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	0f be c0             	movsbl %al,%eax
 7cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d1:	8b 45 08             	mov    0x8(%ebp),%eax
 7d4:	89 04 24             	mov    %eax,(%esp)
 7d7:	e8 e0 fd ff ff       	call   5bc <putc>
        ap++;
 7dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e0:	eb 45                	jmp    827 <printf+0x194>
      } else if(c == '%'){
 7e2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e6:	75 17                	jne    7ff <printf+0x16c>
        putc(fd, c);
 7e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7eb:	0f be c0             	movsbl %al,%eax
 7ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f2:	8b 45 08             	mov    0x8(%ebp),%eax
 7f5:	89 04 24             	mov    %eax,(%esp)
 7f8:	e8 bf fd ff ff       	call   5bc <putc>
 7fd:	eb 28                	jmp    827 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7ff:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 806:	00 
 807:	8b 45 08             	mov    0x8(%ebp),%eax
 80a:	89 04 24             	mov    %eax,(%esp)
 80d:	e8 aa fd ff ff       	call   5bc <putc>
        putc(fd, c);
 812:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 815:	0f be c0             	movsbl %al,%eax
 818:	89 44 24 04          	mov    %eax,0x4(%esp)
 81c:	8b 45 08             	mov    0x8(%ebp),%eax
 81f:	89 04 24             	mov    %eax,(%esp)
 822:	e8 95 fd ff ff       	call   5bc <putc>
      }
      state = 0;
 827:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 82e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 832:	8b 55 0c             	mov    0xc(%ebp),%edx
 835:	8b 45 f0             	mov    -0x10(%ebp),%eax
 838:	01 d0                	add    %edx,%eax
 83a:	0f b6 00             	movzbl (%eax),%eax
 83d:	84 c0                	test   %al,%al
 83f:	0f 85 70 fe ff ff    	jne    6b5 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 845:	c9                   	leave  
 846:	c3                   	ret    
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
 857:	a1 88 0d 00 00       	mov    0xd88,%eax
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
 89d:	c1 e0 03             	shl    $0x3,%eax
 8a0:	89 c2                	mov    %eax,%edx
 8a2:	03 55 f8             	add    -0x8(%ebp),%edx
 8a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a8:	8b 00                	mov    (%eax),%eax
 8aa:	39 c2                	cmp    %eax,%edx
 8ac:	75 24                	jne    8d2 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b1:	8b 50 04             	mov    0x4(%eax),%edx
 8b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b7:	8b 00                	mov    (%eax),%eax
 8b9:	8b 40 04             	mov    0x4(%eax),%eax
 8bc:	01 c2                	add    %eax,%edx
 8be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	8b 00                	mov    (%eax),%eax
 8c9:	8b 10                	mov    (%eax),%edx
 8cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ce:	89 10                	mov    %edx,(%eax)
 8d0:	eb 0a                	jmp    8dc <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d5:	8b 10                	mov    (%eax),%edx
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 40 04             	mov    0x4(%eax),%eax
 8e2:	c1 e0 03             	shl    $0x3,%eax
 8e5:	03 45 fc             	add    -0x4(%ebp),%eax
 8e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8eb:	75 20                	jne    90d <free+0xc5>
    p->s.size += bp->s.size;
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	8b 50 04             	mov    0x4(%eax),%edx
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	8b 40 04             	mov    0x4(%eax),%eax
 8f9:	01 c2                	add    %eax,%edx
 8fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fe:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 901:	8b 45 f8             	mov    -0x8(%ebp),%eax
 904:	8b 10                	mov    (%eax),%edx
 906:	8b 45 fc             	mov    -0x4(%ebp),%eax
 909:	89 10                	mov    %edx,(%eax)
 90b:	eb 08                	jmp    915 <free+0xcd>
  } else
    p->s.ptr = bp;
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 55 f8             	mov    -0x8(%ebp),%edx
 913:	89 10                	mov    %edx,(%eax)
  freep = p;
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	a3 88 0d 00 00       	mov    %eax,0xd88
}
 91d:	c9                   	leave  
 91e:	c3                   	ret    

0000091f <morecore>:

static Header*
morecore(uint nu)
{
 91f:	55                   	push   %ebp
 920:	89 e5                	mov    %esp,%ebp
 922:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 925:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 92c:	77 07                	ja     935 <morecore+0x16>
    nu = 4096;
 92e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 935:	8b 45 08             	mov    0x8(%ebp),%eax
 938:	c1 e0 03             	shl    $0x3,%eax
 93b:	89 04 24             	mov    %eax,(%esp)
 93e:	e8 61 fc ff ff       	call   5a4 <sbrk>
 943:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 946:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 94a:	75 07                	jne    953 <morecore+0x34>
    return 0;
 94c:	b8 00 00 00 00       	mov    $0x0,%eax
 951:	eb 22                	jmp    975 <morecore+0x56>
  hp = (Header*)p;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 959:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95c:	8b 55 08             	mov    0x8(%ebp),%edx
 95f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 962:	8b 45 f0             	mov    -0x10(%ebp),%eax
 965:	83 c0 08             	add    $0x8,%eax
 968:	89 04 24             	mov    %eax,(%esp)
 96b:	e8 d8 fe ff ff       	call   848 <free>
  return freep;
 970:	a1 88 0d 00 00       	mov    0xd88,%eax
}
 975:	c9                   	leave  
 976:	c3                   	ret    

00000977 <malloc>:

void*
malloc(uint nbytes)
{
 977:	55                   	push   %ebp
 978:	89 e5                	mov    %esp,%ebp
 97a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 97d:	8b 45 08             	mov    0x8(%ebp),%eax
 980:	83 c0 07             	add    $0x7,%eax
 983:	c1 e8 03             	shr    $0x3,%eax
 986:	83 c0 01             	add    $0x1,%eax
 989:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 98c:	a1 88 0d 00 00       	mov    0xd88,%eax
 991:	89 45 f0             	mov    %eax,-0x10(%ebp)
 994:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 998:	75 23                	jne    9bd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 99a:	c7 45 f0 80 0d 00 00 	movl   $0xd80,-0x10(%ebp)
 9a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a4:	a3 88 0d 00 00       	mov    %eax,0xd88
 9a9:	a1 88 0d 00 00       	mov    0xd88,%eax
 9ae:	a3 80 0d 00 00       	mov    %eax,0xd80
    base.s.size = 0;
 9b3:	c7 05 84 0d 00 00 00 	movl   $0x0,0xd84
 9ba:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c0:	8b 00                	mov    (%eax),%eax
 9c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	8b 40 04             	mov    0x4(%eax),%eax
 9cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ce:	72 4d                	jb     a1d <malloc+0xa6>
      if(p->s.size == nunits)
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	8b 40 04             	mov    0x4(%eax),%eax
 9d6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9d9:	75 0c                	jne    9e7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9de:	8b 10                	mov    (%eax),%edx
 9e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e3:	89 10                	mov    %edx,(%eax)
 9e5:	eb 26                	jmp    a0d <malloc+0x96>
      else {
        p->s.size -= nunits;
 9e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ea:	8b 40 04             	mov    0x4(%eax),%eax
 9ed:	89 c2                	mov    %eax,%edx
 9ef:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fb:	8b 40 04             	mov    0x4(%eax),%eax
 9fe:	c1 e0 03             	shl    $0x3,%eax
 a01:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a07:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a0a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a10:	a3 88 0d 00 00       	mov    %eax,0xd88
      return (void*)(p + 1);
 a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a18:	83 c0 08             	add    $0x8,%eax
 a1b:	eb 38                	jmp    a55 <malloc+0xde>
    }
    if(p == freep)
 a1d:	a1 88 0d 00 00       	mov    0xd88,%eax
 a22:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a25:	75 1b                	jne    a42 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a2a:	89 04 24             	mov    %eax,(%esp)
 a2d:	e8 ed fe ff ff       	call   91f <morecore>
 a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a39:	75 07                	jne    a42 <malloc+0xcb>
        return 0;
 a3b:	b8 00 00 00 00       	mov    $0x0,%eax
 a40:	eb 13                	jmp    a55 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a45:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4b:	8b 00                	mov    (%eax),%eax
 a4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a50:	e9 70 ff ff ff       	jmp    9c5 <malloc+0x4e>
}
 a55:	c9                   	leave  
 a56:	c3                   	ret    
