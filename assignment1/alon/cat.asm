
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
  1e:	e8 1d 05 00 00       	call   540 <write>
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
  39:	e8 fa 04 00 00       	call   538 <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 5b 0a 00 	movl   $0xa5b,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 36 06 00 00       	call   697 <printf>
    exit();
  61:	e8 aa 04 00 00       	call   510 <exit>
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
  83:	e8 88 04 00 00       	call   510 <exit>
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
  a9:	e8 b2 04 00 00       	call   560 <open>
  ae:	89 44 24 18          	mov    %eax,0x18(%esp)
  b2:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  b7:	79 29                	jns    e2 <main+0x7a>
      printf(1, "cat: cannot open %s\n", argv[i]);
  b9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  bd:	c1 e0 02             	shl    $0x2,%eax
  c0:	03 45 0c             	add    0xc(%ebp),%eax
  c3:	8b 00                	mov    (%eax),%eax
  c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  c9:	c7 44 24 04 6c 0a 00 	movl   $0xa6c,0x4(%esp)
  d0:	00 
  d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d8:	e8 ba 05 00 00       	call   697 <printf>
      exit();
  dd:	e8 2e 04 00 00       	call   510 <exit>
    }
    cat(fd);
  e2:	8b 44 24 18          	mov    0x18(%esp),%eax
  e6:	89 04 24             	mov    %eax,(%esp)
  e9:	e8 12 ff ff ff       	call   0 <cat>
    close(fd);
  ee:	8b 44 24 18          	mov    0x18(%esp),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 4e 04 00 00       	call   548 <close>
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
 108:	e8 03 04 00 00       	call   510 <exit>
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
 24b:	e8 e8 02 00 00       	call   538 <read>
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
 2a9:	e8 b2 02 00 00       	call   560 <open>
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
 2cb:	e8 a8 02 00 00       	call   578 <fstat>
 2d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d6:	89 04 24             	mov    %eax,(%esp)
 2d9:	e8 6a 02 00 00       	call   548 <close>
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
strcat(char *dest, char *p, char *q)
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
strcat(char *dest, char *p, char *q)
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
  *dest = 0;
 4ff:	8b 45 08             	mov    0x8(%ebp),%eax
 502:	c6 00 00             	movb   $0x0,(%eax)
 505:	5d                   	pop    %ebp
 506:	c3                   	ret    
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

000005c0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5c0:	55                   	push   %ebp
 5c1:	89 e5                	mov    %esp,%ebp
 5c3:	83 ec 28             	sub    $0x28,%esp
 5c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5d3:	00 
 5d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5d7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5db:	8b 45 08             	mov    0x8(%ebp),%eax
 5de:	89 04 24             	mov    %eax,(%esp)
 5e1:	e8 5a ff ff ff       	call   540 <write>
}
 5e6:	c9                   	leave  
 5e7:	c3                   	ret    

000005e8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5e8:	55                   	push   %ebp
 5e9:	89 e5                	mov    %esp,%ebp
 5eb:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5f5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5f9:	74 17                	je     612 <printint+0x2a>
 5fb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5ff:	79 11                	jns    612 <printint+0x2a>
    neg = 1;
 601:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 608:	8b 45 0c             	mov    0xc(%ebp),%eax
 60b:	f7 d8                	neg    %eax
 60d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 610:	eb 06                	jmp    618 <printint+0x30>
  } else {
    x = xx;
 612:	8b 45 0c             	mov    0xc(%ebp),%eax
 615:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 618:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 61f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 622:	8b 45 ec             	mov    -0x14(%ebp),%eax
 625:	ba 00 00 00 00       	mov    $0x0,%edx
 62a:	f7 f1                	div    %ecx
 62c:	89 d0                	mov    %edx,%eax
 62e:	0f b6 90 64 0d 00 00 	movzbl 0xd64(%eax),%edx
 635:	8d 45 dc             	lea    -0x24(%ebp),%eax
 638:	03 45 f4             	add    -0xc(%ebp),%eax
 63b:	88 10                	mov    %dl,(%eax)
 63d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 641:	8b 55 10             	mov    0x10(%ebp),%edx
 644:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 647:	8b 45 ec             	mov    -0x14(%ebp),%eax
 64a:	ba 00 00 00 00       	mov    $0x0,%edx
 64f:	f7 75 d4             	divl   -0x2c(%ebp)
 652:	89 45 ec             	mov    %eax,-0x14(%ebp)
 655:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 659:	75 c4                	jne    61f <printint+0x37>
  if(neg)
 65b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 65f:	74 2a                	je     68b <printint+0xa3>
    buf[i++] = '-';
 661:	8d 45 dc             	lea    -0x24(%ebp),%eax
 664:	03 45 f4             	add    -0xc(%ebp),%eax
 667:	c6 00 2d             	movb   $0x2d,(%eax)
 66a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 66e:	eb 1b                	jmp    68b <printint+0xa3>
    putc(fd, buf[i]);
 670:	8d 45 dc             	lea    -0x24(%ebp),%eax
 673:	03 45 f4             	add    -0xc(%ebp),%eax
 676:	0f b6 00             	movzbl (%eax),%eax
 679:	0f be c0             	movsbl %al,%eax
 67c:	89 44 24 04          	mov    %eax,0x4(%esp)
 680:	8b 45 08             	mov    0x8(%ebp),%eax
 683:	89 04 24             	mov    %eax,(%esp)
 686:	e8 35 ff ff ff       	call   5c0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 68b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 68f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 693:	79 db                	jns    670 <printint+0x88>
    putc(fd, buf[i]);
}
 695:	c9                   	leave  
 696:	c3                   	ret    

00000697 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 697:	55                   	push   %ebp
 698:	89 e5                	mov    %esp,%ebp
 69a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 69d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6a4:	8d 45 0c             	lea    0xc(%ebp),%eax
 6a7:	83 c0 04             	add    $0x4,%eax
 6aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6ad:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6b4:	e9 7d 01 00 00       	jmp    836 <printf+0x19f>
    c = fmt[i] & 0xff;
 6b9:	8b 55 0c             	mov    0xc(%ebp),%edx
 6bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6bf:	01 d0                	add    %edx,%eax
 6c1:	0f b6 00             	movzbl (%eax),%eax
 6c4:	0f be c0             	movsbl %al,%eax
 6c7:	25 ff 00 00 00       	and    $0xff,%eax
 6cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6d3:	75 2c                	jne    701 <printf+0x6a>
      if(c == '%'){
 6d5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d9:	75 0c                	jne    6e7 <printf+0x50>
        state = '%';
 6db:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6e2:	e9 4b 01 00 00       	jmp    832 <printf+0x19b>
      } else {
        putc(fd, c);
 6e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ea:	0f be c0             	movsbl %al,%eax
 6ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f1:	8b 45 08             	mov    0x8(%ebp),%eax
 6f4:	89 04 24             	mov    %eax,(%esp)
 6f7:	e8 c4 fe ff ff       	call   5c0 <putc>
 6fc:	e9 31 01 00 00       	jmp    832 <printf+0x19b>
      }
    } else if(state == '%'){
 701:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 705:	0f 85 27 01 00 00    	jne    832 <printf+0x19b>
      if(c == 'd'){
 70b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 70f:	75 2d                	jne    73e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 711:	8b 45 e8             	mov    -0x18(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 71d:	00 
 71e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 725:	00 
 726:	89 44 24 04          	mov    %eax,0x4(%esp)
 72a:	8b 45 08             	mov    0x8(%ebp),%eax
 72d:	89 04 24             	mov    %eax,(%esp)
 730:	e8 b3 fe ff ff       	call   5e8 <printint>
        ap++;
 735:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 739:	e9 ed 00 00 00       	jmp    82b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 73e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 742:	74 06                	je     74a <printf+0xb3>
 744:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 748:	75 2d                	jne    777 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 74a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74d:	8b 00                	mov    (%eax),%eax
 74f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 756:	00 
 757:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 75e:	00 
 75f:	89 44 24 04          	mov    %eax,0x4(%esp)
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	89 04 24             	mov    %eax,(%esp)
 769:	e8 7a fe ff ff       	call   5e8 <printint>
        ap++;
 76e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 772:	e9 b4 00 00 00       	jmp    82b <printf+0x194>
      } else if(c == 's'){
 777:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 77b:	75 46                	jne    7c3 <printf+0x12c>
        s = (char*)*ap;
 77d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 780:	8b 00                	mov    (%eax),%eax
 782:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 785:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 789:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 78d:	75 27                	jne    7b6 <printf+0x11f>
          s = "(null)";
 78f:	c7 45 f4 81 0a 00 00 	movl   $0xa81,-0xc(%ebp)
        while(*s != 0){
 796:	eb 1e                	jmp    7b6 <printf+0x11f>
          putc(fd, *s);
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	0f b6 00             	movzbl (%eax),%eax
 79e:	0f be c0             	movsbl %al,%eax
 7a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a5:	8b 45 08             	mov    0x8(%ebp),%eax
 7a8:	89 04 24             	mov    %eax,(%esp)
 7ab:	e8 10 fe ff ff       	call   5c0 <putc>
          s++;
 7b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7b4:	eb 01                	jmp    7b7 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7b6:	90                   	nop
 7b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ba:	0f b6 00             	movzbl (%eax),%eax
 7bd:	84 c0                	test   %al,%al
 7bf:	75 d7                	jne    798 <printf+0x101>
 7c1:	eb 68                	jmp    82b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7c3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c7:	75 1d                	jne    7e6 <printf+0x14f>
        putc(fd, *ap);
 7c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	0f be c0             	movsbl %al,%eax
 7d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d5:	8b 45 08             	mov    0x8(%ebp),%eax
 7d8:	89 04 24             	mov    %eax,(%esp)
 7db:	e8 e0 fd ff ff       	call   5c0 <putc>
        ap++;
 7e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e4:	eb 45                	jmp    82b <printf+0x194>
      } else if(c == '%'){
 7e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ea:	75 17                	jne    803 <printf+0x16c>
        putc(fd, c);
 7ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ef:	0f be c0             	movsbl %al,%eax
 7f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f6:	8b 45 08             	mov    0x8(%ebp),%eax
 7f9:	89 04 24             	mov    %eax,(%esp)
 7fc:	e8 bf fd ff ff       	call   5c0 <putc>
 801:	eb 28                	jmp    82b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 803:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 80a:	00 
 80b:	8b 45 08             	mov    0x8(%ebp),%eax
 80e:	89 04 24             	mov    %eax,(%esp)
 811:	e8 aa fd ff ff       	call   5c0 <putc>
        putc(fd, c);
 816:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 819:	0f be c0             	movsbl %al,%eax
 81c:	89 44 24 04          	mov    %eax,0x4(%esp)
 820:	8b 45 08             	mov    0x8(%ebp),%eax
 823:	89 04 24             	mov    %eax,(%esp)
 826:	e8 95 fd ff ff       	call   5c0 <putc>
      }
      state = 0;
 82b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 832:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 836:	8b 55 0c             	mov    0xc(%ebp),%edx
 839:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83c:	01 d0                	add    %edx,%eax
 83e:	0f b6 00             	movzbl (%eax),%eax
 841:	84 c0                	test   %al,%al
 843:	0f 85 70 fe ff ff    	jne    6b9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 849:	c9                   	leave  
 84a:	c3                   	ret    
 84b:	90                   	nop

0000084c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 84c:	55                   	push   %ebp
 84d:	89 e5                	mov    %esp,%ebp
 84f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 852:	8b 45 08             	mov    0x8(%ebp),%eax
 855:	83 e8 08             	sub    $0x8,%eax
 858:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85b:	a1 88 0d 00 00       	mov    0xd88,%eax
 860:	89 45 fc             	mov    %eax,-0x4(%ebp)
 863:	eb 24                	jmp    889 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86d:	77 12                	ja     881 <free+0x35>
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 875:	77 24                	ja     89b <free+0x4f>
 877:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87a:	8b 00                	mov    (%eax),%eax
 87c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 87f:	77 1a                	ja     89b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 00                	mov    (%eax),%eax
 886:	89 45 fc             	mov    %eax,-0x4(%ebp)
 889:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 88f:	76 d4                	jbe    865 <free+0x19>
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
 894:	8b 00                	mov    (%eax),%eax
 896:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 899:	76 ca                	jbe    865 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 89b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89e:	8b 40 04             	mov    0x4(%eax),%eax
 8a1:	c1 e0 03             	shl    $0x3,%eax
 8a4:	89 c2                	mov    %eax,%edx
 8a6:	03 55 f8             	add    -0x8(%ebp),%edx
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	8b 00                	mov    (%eax),%eax
 8ae:	39 c2                	cmp    %eax,%edx
 8b0:	75 24                	jne    8d6 <free+0x8a>
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
 8d4:	eb 0a                	jmp    8e0 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d9:	8b 10                	mov    (%eax),%edx
 8db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8de:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 40 04             	mov    0x4(%eax),%eax
 8e6:	c1 e0 03             	shl    $0x3,%eax
 8e9:	03 45 fc             	add    -0x4(%ebp),%eax
 8ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8ef:	75 20                	jne    911 <free+0xc5>
    p->s.size += bp->s.size;
 8f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f4:	8b 50 04             	mov    0x4(%eax),%edx
 8f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fa:	8b 40 04             	mov    0x4(%eax),%eax
 8fd:	01 c2                	add    %eax,%edx
 8ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 902:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 905:	8b 45 f8             	mov    -0x8(%ebp),%eax
 908:	8b 10                	mov    (%eax),%edx
 90a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90d:	89 10                	mov    %edx,(%eax)
 90f:	eb 08                	jmp    919 <free+0xcd>
  } else
    p->s.ptr = bp;
 911:	8b 45 fc             	mov    -0x4(%ebp),%eax
 914:	8b 55 f8             	mov    -0x8(%ebp),%edx
 917:	89 10                	mov    %edx,(%eax)
  freep = p;
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	a3 88 0d 00 00       	mov    %eax,0xd88
}
 921:	c9                   	leave  
 922:	c3                   	ret    

00000923 <morecore>:

static Header*
morecore(uint nu)
{
 923:	55                   	push   %ebp
 924:	89 e5                	mov    %esp,%ebp
 926:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 929:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 930:	77 07                	ja     939 <morecore+0x16>
    nu = 4096;
 932:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 939:	8b 45 08             	mov    0x8(%ebp),%eax
 93c:	c1 e0 03             	shl    $0x3,%eax
 93f:	89 04 24             	mov    %eax,(%esp)
 942:	e8 61 fc ff ff       	call   5a8 <sbrk>
 947:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 94a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 94e:	75 07                	jne    957 <morecore+0x34>
    return 0;
 950:	b8 00 00 00 00       	mov    $0x0,%eax
 955:	eb 22                	jmp    979 <morecore+0x56>
  hp = (Header*)p;
 957:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 95d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 960:	8b 55 08             	mov    0x8(%ebp),%edx
 963:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 966:	8b 45 f0             	mov    -0x10(%ebp),%eax
 969:	83 c0 08             	add    $0x8,%eax
 96c:	89 04 24             	mov    %eax,(%esp)
 96f:	e8 d8 fe ff ff       	call   84c <free>
  return freep;
 974:	a1 88 0d 00 00       	mov    0xd88,%eax
}
 979:	c9                   	leave  
 97a:	c3                   	ret    

0000097b <malloc>:

void*
malloc(uint nbytes)
{
 97b:	55                   	push   %ebp
 97c:	89 e5                	mov    %esp,%ebp
 97e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 981:	8b 45 08             	mov    0x8(%ebp),%eax
 984:	83 c0 07             	add    $0x7,%eax
 987:	c1 e8 03             	shr    $0x3,%eax
 98a:	83 c0 01             	add    $0x1,%eax
 98d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 990:	a1 88 0d 00 00       	mov    0xd88,%eax
 995:	89 45 f0             	mov    %eax,-0x10(%ebp)
 998:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 99c:	75 23                	jne    9c1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 99e:	c7 45 f0 80 0d 00 00 	movl   $0xd80,-0x10(%ebp)
 9a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a8:	a3 88 0d 00 00       	mov    %eax,0xd88
 9ad:	a1 88 0d 00 00       	mov    0xd88,%eax
 9b2:	a3 80 0d 00 00       	mov    %eax,0xd80
    base.s.size = 0;
 9b7:	c7 05 84 0d 00 00 00 	movl   $0x0,0xd84
 9be:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c4:	8b 00                	mov    (%eax),%eax
 9c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cc:	8b 40 04             	mov    0x4(%eax),%eax
 9cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9d2:	72 4d                	jb     a21 <malloc+0xa6>
      if(p->s.size == nunits)
 9d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d7:	8b 40 04             	mov    0x4(%eax),%eax
 9da:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9dd:	75 0c                	jne    9eb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e2:	8b 10                	mov    (%eax),%edx
 9e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e7:	89 10                	mov    %edx,(%eax)
 9e9:	eb 26                	jmp    a11 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ee:	8b 40 04             	mov    0x4(%eax),%eax
 9f1:	89 c2                	mov    %eax,%edx
 9f3:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	8b 40 04             	mov    0x4(%eax),%eax
 a02:	c1 e0 03             	shl    $0x3,%eax
 a05:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a0e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a14:	a3 88 0d 00 00       	mov    %eax,0xd88
      return (void*)(p + 1);
 a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1c:	83 c0 08             	add    $0x8,%eax
 a1f:	eb 38                	jmp    a59 <malloc+0xde>
    }
    if(p == freep)
 a21:	a1 88 0d 00 00       	mov    0xd88,%eax
 a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a29:	75 1b                	jne    a46 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a2e:	89 04 24             	mov    %eax,(%esp)
 a31:	e8 ed fe ff ff       	call   923 <morecore>
 a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a3d:	75 07                	jne    a46 <malloc+0xcb>
        return 0;
 a3f:	b8 00 00 00 00       	mov    $0x0,%eax
 a44:	eb 13                	jmp    a59 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a49:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4f:	8b 00                	mov    (%eax),%eax
 a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a54:	e9 70 ff ff ff       	jmp    9c9 <malloc+0x4e>
}
 a59:	c9                   	leave  
 a5a:	c3                   	ret    
