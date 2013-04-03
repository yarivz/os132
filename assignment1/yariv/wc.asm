
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 48             	sub    $0x48,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
   6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
   d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  inword = 0;
  19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  20:	eb 68                	jmp    8a <wc+0x8a>
    for(i=0; i<n; i++){
  22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  29:	eb 57                	jmp    82 <wc+0x82>
      c++;
  2b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
      if(buf[i] == '\n')
  2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  32:	05 60 0e 00 00       	add    $0xe60,%eax
  37:	0f b6 00             	movzbl (%eax),%eax
  3a:	3c 0a                	cmp    $0xa,%al
  3c:	75 04                	jne    42 <wc+0x42>
        l++;
  3e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  45:	05 60 0e 00 00       	add    $0xe60,%eax
  4a:	0f b6 00             	movzbl (%eax),%eax
  4d:	0f be c0             	movsbl %al,%eax
  50:	89 44 24 04          	mov    %eax,0x4(%esp)
  54:	c7 04 24 03 0b 00 00 	movl   $0xb03,(%esp)
  5b:	e8 47 02 00 00       	call   2a7 <strchr>
  60:	85 c0                	test   %eax,%eax
  62:	74 09                	je     6d <wc+0x6d>
        inword = 0;
  64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  6b:	eb 11                	jmp    7e <wc+0x7e>
      else if(!inword){
  6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  71:	75 0b                	jne    7e <wc+0x7e>
        w++;
  73:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
        inword = 1;
  77:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
  7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  88:	7c a1                	jl     2b <wc+0x2b>
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
  8a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  91:	00 
  92:	c7 44 24 04 60 0e 00 	movl   $0xe60,0x4(%esp)
  99:	00 
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 3b 05 00 00       	call   5e0 <read>
  a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  ac:	0f 8f 70 ff ff ff    	jg     22 <wc+0x22>
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
  b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  b6:	79 19                	jns    d1 <wc+0xd1>
    printf(1, "wc: read error\n");
  b8:	c7 44 24 04 09 0b 00 	movl   $0xb09,0x4(%esp)
  bf:	00 
  c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c7:	e8 73 06 00 00       	call   73f <printf>
    exit();
  cc:	e8 ef 04 00 00       	call   5c0 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  d4:	89 44 24 14          	mov    %eax,0x14(%esp)
  d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  db:	89 44 24 10          	mov    %eax,0x10(%esp)
  df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  ed:	c7 44 24 04 19 0b 00 	movl   $0xb19,0x4(%esp)
  f4:	00 
  f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fc:	e8 3e 06 00 00       	call   73f <printf>
}
 101:	c9                   	leave  
 102:	c3                   	ret    

00000103 <main>:

int
main(int argc, char *argv[])
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 e4 f0             	and    $0xfffffff0,%esp
 109:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
 10c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 110:	7f 19                	jg     12b <main+0x28>
    wc(0, "");
 112:	c7 44 24 04 26 0b 00 	movl   $0xb26,0x4(%esp)
 119:	00 
 11a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 121:	e8 da fe ff ff       	call   0 <wc>
    exit();
 126:	e8 95 04 00 00       	call   5c0 <exit>
  }

  for(i = 1; i < argc; i++){
 12b:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 132:	00 
 133:	eb 7d                	jmp    1b2 <main+0xaf>
    if((fd = open(argv[i], 0)) < 0){
 135:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 139:	c1 e0 02             	shl    $0x2,%eax
 13c:	03 45 0c             	add    0xc(%ebp),%eax
 13f:	8b 00                	mov    (%eax),%eax
 141:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 148:	00 
 149:	89 04 24             	mov    %eax,(%esp)
 14c:	e8 b7 04 00 00       	call   608 <open>
 151:	89 44 24 18          	mov    %eax,0x18(%esp)
 155:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 15a:	79 29                	jns    185 <main+0x82>
      printf(1, "cat: cannot open %s\n", argv[i]);
 15c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 160:	c1 e0 02             	shl    $0x2,%eax
 163:	03 45 0c             	add    0xc(%ebp),%eax
 166:	8b 00                	mov    (%eax),%eax
 168:	89 44 24 08          	mov    %eax,0x8(%esp)
 16c:	c7 44 24 04 27 0b 00 	movl   $0xb27,0x4(%esp)
 173:	00 
 174:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17b:	e8 bf 05 00 00       	call   73f <printf>
      exit();
 180:	e8 3b 04 00 00       	call   5c0 <exit>
    }
    wc(fd, argv[i]);
 185:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 189:	c1 e0 02             	shl    $0x2,%eax
 18c:	03 45 0c             	add    0xc(%ebp),%eax
 18f:	8b 00                	mov    (%eax),%eax
 191:	89 44 24 04          	mov    %eax,0x4(%esp)
 195:	8b 44 24 18          	mov    0x18(%esp),%eax
 199:	89 04 24             	mov    %eax,(%esp)
 19c:	e8 5f fe ff ff       	call   0 <wc>
    close(fd);
 1a1:	8b 44 24 18          	mov    0x18(%esp),%eax
 1a5:	89 04 24             	mov    %eax,(%esp)
 1a8:	e8 43 04 00 00       	call   5f0 <close>
  if(argc <= 1){
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
 1ad:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1b2:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1b6:	3b 45 08             	cmp    0x8(%ebp),%eax
 1b9:	0f 8c 76 ff ff ff    	jl     135 <main+0x32>
      exit();
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit();
 1bf:	e8 fc 03 00 00       	call   5c0 <exit>

000001c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
 1c7:	57                   	push   %edi
 1c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1cc:	8b 55 10             	mov    0x10(%ebp),%edx
 1cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d2:	89 cb                	mov    %ecx,%ebx
 1d4:	89 df                	mov    %ebx,%edi
 1d6:	89 d1                	mov    %edx,%ecx
 1d8:	fc                   	cld    
 1d9:	f3 aa                	rep stos %al,%es:(%edi)
 1db:	89 ca                	mov    %ecx,%edx
 1dd:	89 fb                	mov    %edi,%ebx
 1df:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1e5:	5b                   	pop    %ebx
 1e6:	5f                   	pop    %edi
 1e7:	5d                   	pop    %ebp
 1e8:	c3                   	ret    

000001e9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1f5:	90                   	nop
 1f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f9:	0f b6 10             	movzbl (%eax),%edx
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	88 10                	mov    %dl,(%eax)
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	0f b6 00             	movzbl (%eax),%eax
 207:	84 c0                	test   %al,%al
 209:	0f 95 c0             	setne  %al
 20c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 210:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 214:	84 c0                	test   %al,%al
 216:	75 de                	jne    1f6 <strcpy+0xd>
    ;
  return os;
 218:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 220:	eb 08                	jmp    22a <strcmp+0xd>
    p++, q++;
 222:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 226:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	0f b6 00             	movzbl (%eax),%eax
 230:	84 c0                	test   %al,%al
 232:	74 10                	je     244 <strcmp+0x27>
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	0f b6 10             	movzbl (%eax),%edx
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	0f b6 00             	movzbl (%eax),%eax
 240:	38 c2                	cmp    %al,%dl
 242:	74 de                	je     222 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 244:	8b 45 08             	mov    0x8(%ebp),%eax
 247:	0f b6 00             	movzbl (%eax),%eax
 24a:	0f b6 d0             	movzbl %al,%edx
 24d:	8b 45 0c             	mov    0xc(%ebp),%eax
 250:	0f b6 00             	movzbl (%eax),%eax
 253:	0f b6 c0             	movzbl %al,%eax
 256:	89 d1                	mov    %edx,%ecx
 258:	29 c1                	sub    %eax,%ecx
 25a:	89 c8                	mov    %ecx,%eax
}
 25c:	5d                   	pop    %ebp
 25d:	c3                   	ret    

0000025e <strlen>:

uint
strlen(char *s)
{
 25e:	55                   	push   %ebp
 25f:	89 e5                	mov    %esp,%ebp
 261:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 264:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 26b:	eb 04                	jmp    271 <strlen+0x13>
 26d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 271:	8b 45 fc             	mov    -0x4(%ebp),%eax
 274:	03 45 08             	add    0x8(%ebp),%eax
 277:	0f b6 00             	movzbl (%eax),%eax
 27a:	84 c0                	test   %al,%al
 27c:	75 ef                	jne    26d <strlen+0xf>
  return n;
 27e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 281:	c9                   	leave  
 282:	c3                   	ret    

00000283 <memset>:

void*
memset(void *dst, int c, uint n)
{
 283:	55                   	push   %ebp
 284:	89 e5                	mov    %esp,%ebp
 286:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 289:	8b 45 10             	mov    0x10(%ebp),%eax
 28c:	89 44 24 08          	mov    %eax,0x8(%esp)
 290:	8b 45 0c             	mov    0xc(%ebp),%eax
 293:	89 44 24 04          	mov    %eax,0x4(%esp)
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 22 ff ff ff       	call   1c4 <stosb>
  return dst;
 2a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a5:	c9                   	leave  
 2a6:	c3                   	ret    

000002a7 <strchr>:

char*
strchr(const char *s, char c)
{
 2a7:	55                   	push   %ebp
 2a8:	89 e5                	mov    %esp,%ebp
 2aa:	83 ec 04             	sub    $0x4,%esp
 2ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2b3:	eb 14                	jmp    2c9 <strchr+0x22>
    if(*s == c)
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2be:	75 05                	jne    2c5 <strchr+0x1e>
      return (char*)s;
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	eb 13                	jmp    2d8 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	0f b6 00             	movzbl (%eax),%eax
 2cf:	84 c0                	test   %al,%al
 2d1:	75 e2                	jne    2b5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2d8:	c9                   	leave  
 2d9:	c3                   	ret    

000002da <gets>:

char*
gets(char *buf, int max)
{
 2da:	55                   	push   %ebp
 2db:	89 e5                	mov    %esp,%ebp
 2dd:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e7:	eb 44                	jmp    32d <gets+0x53>
    cc = read(0, &c, 1);
 2e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f0:	00 
 2f1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2ff:	e8 dc 02 00 00       	call   5e0 <read>
 304:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 307:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 30b:	7e 2d                	jle    33a <gets+0x60>
      break;
    buf[i++] = c;
 30d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 310:	03 45 08             	add    0x8(%ebp),%eax
 313:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 317:	88 10                	mov    %dl,(%eax)
 319:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 31d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 321:	3c 0a                	cmp    $0xa,%al
 323:	74 16                	je     33b <gets+0x61>
 325:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 329:	3c 0d                	cmp    $0xd,%al
 32b:	74 0e                	je     33b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 330:	83 c0 01             	add    $0x1,%eax
 333:	3b 45 0c             	cmp    0xc(%ebp),%eax
 336:	7c b1                	jl     2e9 <gets+0xf>
 338:	eb 01                	jmp    33b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 33a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 33b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33e:	03 45 08             	add    0x8(%ebp),%eax
 341:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 344:	8b 45 08             	mov    0x8(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    

00000349 <stat>:

int
stat(char *n, struct stat *st)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
 34c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 356:	00 
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	89 04 24             	mov    %eax,(%esp)
 35d:	e8 a6 02 00 00       	call   608 <open>
 362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 365:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 369:	79 07                	jns    372 <stat+0x29>
    return -1;
 36b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 370:	eb 23                	jmp    395 <stat+0x4c>
  r = fstat(fd, st);
 372:	8b 45 0c             	mov    0xc(%ebp),%eax
 375:	89 44 24 04          	mov    %eax,0x4(%esp)
 379:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37c:	89 04 24             	mov    %eax,(%esp)
 37f:	e8 9c 02 00 00       	call   620 <fstat>
 384:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 387:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38a:	89 04 24             	mov    %eax,(%esp)
 38d:	e8 5e 02 00 00       	call   5f0 <close>
  return r;
 392:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 395:	c9                   	leave  
 396:	c3                   	ret    

00000397 <atoi>:

int
atoi(const char *s)
{
 397:	55                   	push   %ebp
 398:	89 e5                	mov    %esp,%ebp
 39a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 39d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3a4:	eb 23                	jmp    3c9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 3a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3a9:	89 d0                	mov    %edx,%eax
 3ab:	c1 e0 02             	shl    $0x2,%eax
 3ae:	01 d0                	add    %edx,%eax
 3b0:	01 c0                	add    %eax,%eax
 3b2:	89 c2                	mov    %eax,%edx
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	0f b6 00             	movzbl (%eax),%eax
 3ba:	0f be c0             	movsbl %al,%eax
 3bd:	01 d0                	add    %edx,%eax
 3bf:	83 e8 30             	sub    $0x30,%eax
 3c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	3c 2f                	cmp    $0x2f,%al
 3d1:	7e 0a                	jle    3dd <atoi+0x46>
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	0f b6 00             	movzbl (%eax),%eax
 3d9:	3c 39                	cmp    $0x39,%al
 3db:	7e c9                	jle    3a6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3e0:	c9                   	leave  
 3e1:	c3                   	ret    

000003e2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3e2:	55                   	push   %ebp
 3e3:	89 e5                	mov    %esp,%ebp
 3e5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3e8:	8b 45 08             	mov    0x8(%ebp),%eax
 3eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3f4:	eb 13                	jmp    409 <memmove+0x27>
    *dst++ = *src++;
 3f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3f9:	0f b6 10             	movzbl (%eax),%edx
 3fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ff:	88 10                	mov    %dl,(%eax)
 401:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 405:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 409:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 40d:	0f 9f c0             	setg   %al
 410:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 414:	84 c0                	test   %al,%al
 416:	75 de                	jne    3f6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 418:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41b:	c9                   	leave  
 41c:	c3                   	ret    

0000041d <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 41d:	55                   	push   %ebp
 41e:	89 e5                	mov    %esp,%ebp
 420:	83 ec 38             	sub    $0x38,%esp
 423:	8b 45 10             	mov    0x10(%ebp),%eax
 426:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 429:	8b 45 14             	mov    0x14(%ebp),%eax
 42c:	8b 00                	mov    (%eax),%eax
 42e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 431:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 438:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 43c:	74 06                	je     444 <strtok+0x27>
 43e:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 442:	75 54                	jne    498 <strtok+0x7b>
    return match;
 444:	8b 45 f0             	mov    -0x10(%ebp),%eax
 447:	eb 6e                	jmp    4b7 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 449:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44c:	03 45 0c             	add    0xc(%ebp),%eax
 44f:	0f b6 00             	movzbl (%eax),%eax
 452:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 455:	74 06                	je     45d <strtok+0x40>
      {
	index++;
 457:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 45b:	eb 3c                	jmp    499 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 45d:	8b 45 14             	mov    0x14(%ebp),%eax
 460:	8b 00                	mov    (%eax),%eax
 462:	8b 55 f4             	mov    -0xc(%ebp),%edx
 465:	29 c2                	sub    %eax,%edx
 467:	8b 45 14             	mov    0x14(%ebp),%eax
 46a:	8b 00                	mov    (%eax),%eax
 46c:	03 45 0c             	add    0xc(%ebp),%eax
 46f:	89 54 24 08          	mov    %edx,0x8(%esp)
 473:	89 44 24 04          	mov    %eax,0x4(%esp)
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	89 04 24             	mov    %eax,(%esp)
 47d:	e8 37 00 00 00       	call   4b9 <strncpy>
 482:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 485:	8b 45 08             	mov    0x8(%ebp),%eax
 488:	0f b6 00             	movzbl (%eax),%eax
 48b:	84 c0                	test   %al,%al
 48d:	74 19                	je     4a8 <strtok+0x8b>
	  match = 1;
 48f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 496:	eb 10                	jmp    4a8 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 498:	90                   	nop
 499:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49c:	03 45 0c             	add    0xc(%ebp),%eax
 49f:	0f b6 00             	movzbl (%eax),%eax
 4a2:	84 c0                	test   %al,%al
 4a4:	75 a3                	jne    449 <strtok+0x2c>
 4a6:	eb 01                	jmp    4a9 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 4a8:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 4a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ac:	8d 50 01             	lea    0x1(%eax),%edx
 4af:	8b 45 14             	mov    0x14(%ebp),%eax
 4b2:	89 10                	mov    %edx,(%eax)
  return match;
 4b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4b7:	c9                   	leave  
 4b8:	c3                   	ret    

000004b9 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 4b9:	55                   	push   %ebp
 4ba:	89 e5                	mov    %esp,%ebp
 4bc:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 4bf:	8b 45 08             	mov    0x8(%ebp),%eax
 4c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 4c5:	90                   	nop
 4c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4ca:	0f 9f c0             	setg   %al
 4cd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4d1:	84 c0                	test   %al,%al
 4d3:	74 30                	je     505 <strncpy+0x4c>
 4d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d8:	0f b6 10             	movzbl (%eax),%edx
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	88 10                	mov    %dl,(%eax)
 4e0:	8b 45 08             	mov    0x8(%ebp),%eax
 4e3:	0f b6 00             	movzbl (%eax),%eax
 4e6:	84 c0                	test   %al,%al
 4e8:	0f 95 c0             	setne  %al
 4eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ef:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 4f3:	84 c0                	test   %al,%al
 4f5:	75 cf                	jne    4c6 <strncpy+0xd>
    ;
  while(n-- > 0)
 4f7:	eb 0c                	jmp    505 <strncpy+0x4c>
    *s++ = 0;
 4f9:	8b 45 08             	mov    0x8(%ebp),%eax
 4fc:	c6 00 00             	movb   $0x0,(%eax)
 4ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 503:	eb 01                	jmp    506 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 505:	90                   	nop
 506:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 50a:	0f 9f c0             	setg   %al
 50d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 511:	84 c0                	test   %al,%al
 513:	75 e4                	jne    4f9 <strncpy+0x40>
    *s++ = 0;
  return os;
 515:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 518:	c9                   	leave  
 519:	c3                   	ret    

0000051a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 51a:	55                   	push   %ebp
 51b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 51d:	eb 0c                	jmp    52b <strncmp+0x11>
    n--, p++, q++;
 51f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 523:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 527:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 52b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 52f:	74 1a                	je     54b <strncmp+0x31>
 531:	8b 45 08             	mov    0x8(%ebp),%eax
 534:	0f b6 00             	movzbl (%eax),%eax
 537:	84 c0                	test   %al,%al
 539:	74 10                	je     54b <strncmp+0x31>
 53b:	8b 45 08             	mov    0x8(%ebp),%eax
 53e:	0f b6 10             	movzbl (%eax),%edx
 541:	8b 45 0c             	mov    0xc(%ebp),%eax
 544:	0f b6 00             	movzbl (%eax),%eax
 547:	38 c2                	cmp    %al,%dl
 549:	74 d4                	je     51f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 54b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 54f:	75 07                	jne    558 <strncmp+0x3e>
    return 0;
 551:	b8 00 00 00 00       	mov    $0x0,%eax
 556:	eb 18                	jmp    570 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 558:	8b 45 08             	mov    0x8(%ebp),%eax
 55b:	0f b6 00             	movzbl (%eax),%eax
 55e:	0f b6 d0             	movzbl %al,%edx
 561:	8b 45 0c             	mov    0xc(%ebp),%eax
 564:	0f b6 00             	movzbl (%eax),%eax
 567:	0f b6 c0             	movzbl %al,%eax
 56a:	89 d1                	mov    %edx,%ecx
 56c:	29 c1                	sub    %eax,%ecx
 56e:	89 c8                	mov    %ecx,%eax
}
 570:	5d                   	pop    %ebp
 571:	c3                   	ret    

00000572 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 572:	55                   	push   %ebp
 573:	89 e5                	mov    %esp,%ebp
  while(*p){
 575:	eb 13                	jmp    58a <strcat+0x18>
    *dest++ = *p++;
 577:	8b 45 0c             	mov    0xc(%ebp),%eax
 57a:	0f b6 10             	movzbl (%eax),%edx
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	88 10                	mov    %dl,(%eax)
 582:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 586:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 58a:	8b 45 0c             	mov    0xc(%ebp),%eax
 58d:	0f b6 00             	movzbl (%eax),%eax
 590:	84 c0                	test   %al,%al
 592:	75 e3                	jne    577 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 594:	eb 13                	jmp    5a9 <strcat+0x37>
    *dest++ = *q++;
 596:	8b 45 10             	mov    0x10(%ebp),%eax
 599:	0f b6 10             	movzbl (%eax),%edx
 59c:	8b 45 08             	mov    0x8(%ebp),%eax
 59f:	88 10                	mov    %dl,(%eax)
 5a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5a5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 5a9:	8b 45 10             	mov    0x10(%ebp),%eax
 5ac:	0f b6 00             	movzbl (%eax),%eax
 5af:	84 c0                	test   %al,%al
 5b1:	75 e3                	jne    596 <strcat+0x24>
    *dest++ = *q++;
  }  
 5b3:	5d                   	pop    %ebp
 5b4:	c3                   	ret    
 5b5:	90                   	nop
 5b6:	90                   	nop
 5b7:	90                   	nop

000005b8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b8:	b8 01 00 00 00       	mov    $0x1,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <exit>:
SYSCALL(exit)
 5c0:	b8 02 00 00 00       	mov    $0x2,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <wait>:
SYSCALL(wait)
 5c8:	b8 03 00 00 00       	mov    $0x3,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <wait2>:
SYSCALL(wait2)
 5d0:	b8 16 00 00 00       	mov    $0x16,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <pipe>:
SYSCALL(pipe)
 5d8:	b8 04 00 00 00       	mov    $0x4,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <read>:
SYSCALL(read)
 5e0:	b8 05 00 00 00       	mov    $0x5,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <write>:
SYSCALL(write)
 5e8:	b8 10 00 00 00       	mov    $0x10,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <close>:
SYSCALL(close)
 5f0:	b8 15 00 00 00       	mov    $0x15,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <kill>:
SYSCALL(kill)
 5f8:	b8 06 00 00 00       	mov    $0x6,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <exec>:
SYSCALL(exec)
 600:	b8 07 00 00 00       	mov    $0x7,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <open>:
SYSCALL(open)
 608:	b8 0f 00 00 00       	mov    $0xf,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <mknod>:
SYSCALL(mknod)
 610:	b8 11 00 00 00       	mov    $0x11,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <unlink>:
SYSCALL(unlink)
 618:	b8 12 00 00 00       	mov    $0x12,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <fstat>:
SYSCALL(fstat)
 620:	b8 08 00 00 00       	mov    $0x8,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <link>:
SYSCALL(link)
 628:	b8 13 00 00 00       	mov    $0x13,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <mkdir>:
SYSCALL(mkdir)
 630:	b8 14 00 00 00       	mov    $0x14,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <chdir>:
SYSCALL(chdir)
 638:	b8 09 00 00 00       	mov    $0x9,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <dup>:
SYSCALL(dup)
 640:	b8 0a 00 00 00       	mov    $0xa,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <getpid>:
SYSCALL(getpid)
 648:	b8 0b 00 00 00       	mov    $0xb,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <sbrk>:
SYSCALL(sbrk)
 650:	b8 0c 00 00 00       	mov    $0xc,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <sleep>:
SYSCALL(sleep)
 658:	b8 0d 00 00 00       	mov    $0xd,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <uptime>:
SYSCALL(uptime)
 660:	b8 0e 00 00 00       	mov    $0xe,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 668:	55                   	push   %ebp
 669:	89 e5                	mov    %esp,%ebp
 66b:	83 ec 28             	sub    $0x28,%esp
 66e:	8b 45 0c             	mov    0xc(%ebp),%eax
 671:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 674:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 67b:	00 
 67c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 67f:	89 44 24 04          	mov    %eax,0x4(%esp)
 683:	8b 45 08             	mov    0x8(%ebp),%eax
 686:	89 04 24             	mov    %eax,(%esp)
 689:	e8 5a ff ff ff       	call   5e8 <write>
}
 68e:	c9                   	leave  
 68f:	c3                   	ret    

00000690 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 690:	55                   	push   %ebp
 691:	89 e5                	mov    %esp,%ebp
 693:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 696:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 69d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6a1:	74 17                	je     6ba <printint+0x2a>
 6a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6a7:	79 11                	jns    6ba <printint+0x2a>
    neg = 1;
 6a9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b3:	f7 d8                	neg    %eax
 6b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6b8:	eb 06                	jmp    6c0 <printint+0x30>
  } else {
    x = xx;
 6ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6cd:	ba 00 00 00 00       	mov    $0x0,%edx
 6d2:	f7 f1                	div    %ecx
 6d4:	89 d0                	mov    %edx,%eax
 6d6:	0f b6 90 20 0e 00 00 	movzbl 0xe20(%eax),%edx
 6dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6e0:	03 45 f4             	add    -0xc(%ebp),%eax
 6e3:	88 10                	mov    %dl,(%eax)
 6e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6e9:	8b 55 10             	mov    0x10(%ebp),%edx
 6ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f2:	ba 00 00 00 00       	mov    $0x0,%edx
 6f7:	f7 75 d4             	divl   -0x2c(%ebp)
 6fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 701:	75 c4                	jne    6c7 <printint+0x37>
  if(neg)
 703:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 707:	74 2a                	je     733 <printint+0xa3>
    buf[i++] = '-';
 709:	8d 45 dc             	lea    -0x24(%ebp),%eax
 70c:	03 45 f4             	add    -0xc(%ebp),%eax
 70f:	c6 00 2d             	movb   $0x2d,(%eax)
 712:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 716:	eb 1b                	jmp    733 <printint+0xa3>
    putc(fd, buf[i]);
 718:	8d 45 dc             	lea    -0x24(%ebp),%eax
 71b:	03 45 f4             	add    -0xc(%ebp),%eax
 71e:	0f b6 00             	movzbl (%eax),%eax
 721:	0f be c0             	movsbl %al,%eax
 724:	89 44 24 04          	mov    %eax,0x4(%esp)
 728:	8b 45 08             	mov    0x8(%ebp),%eax
 72b:	89 04 24             	mov    %eax,(%esp)
 72e:	e8 35 ff ff ff       	call   668 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 733:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 737:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 73b:	79 db                	jns    718 <printint+0x88>
    putc(fd, buf[i]);
}
 73d:	c9                   	leave  
 73e:	c3                   	ret    

0000073f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 73f:	55                   	push   %ebp
 740:	89 e5                	mov    %esp,%ebp
 742:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 745:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 74c:	8d 45 0c             	lea    0xc(%ebp),%eax
 74f:	83 c0 04             	add    $0x4,%eax
 752:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 755:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 75c:	e9 7d 01 00 00       	jmp    8de <printf+0x19f>
    c = fmt[i] & 0xff;
 761:	8b 55 0c             	mov    0xc(%ebp),%edx
 764:	8b 45 f0             	mov    -0x10(%ebp),%eax
 767:	01 d0                	add    %edx,%eax
 769:	0f b6 00             	movzbl (%eax),%eax
 76c:	0f be c0             	movsbl %al,%eax
 76f:	25 ff 00 00 00       	and    $0xff,%eax
 774:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 777:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 77b:	75 2c                	jne    7a9 <printf+0x6a>
      if(c == '%'){
 77d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 781:	75 0c                	jne    78f <printf+0x50>
        state = '%';
 783:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 78a:	e9 4b 01 00 00       	jmp    8da <printf+0x19b>
      } else {
        putc(fd, c);
 78f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 792:	0f be c0             	movsbl %al,%eax
 795:	89 44 24 04          	mov    %eax,0x4(%esp)
 799:	8b 45 08             	mov    0x8(%ebp),%eax
 79c:	89 04 24             	mov    %eax,(%esp)
 79f:	e8 c4 fe ff ff       	call   668 <putc>
 7a4:	e9 31 01 00 00       	jmp    8da <printf+0x19b>
      }
    } else if(state == '%'){
 7a9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7ad:	0f 85 27 01 00 00    	jne    8da <printf+0x19b>
      if(c == 'd'){
 7b3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7b7:	75 2d                	jne    7e6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7c5:	00 
 7c6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7cd:	00 
 7ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d2:	8b 45 08             	mov    0x8(%ebp),%eax
 7d5:	89 04 24             	mov    %eax,(%esp)
 7d8:	e8 b3 fe ff ff       	call   690 <printint>
        ap++;
 7dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e1:	e9 ed 00 00 00       	jmp    8d3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7e6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ea:	74 06                	je     7f2 <printf+0xb3>
 7ec:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7f0:	75 2d                	jne    81f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f5:	8b 00                	mov    (%eax),%eax
 7f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7fe:	00 
 7ff:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 806:	00 
 807:	89 44 24 04          	mov    %eax,0x4(%esp)
 80b:	8b 45 08             	mov    0x8(%ebp),%eax
 80e:	89 04 24             	mov    %eax,(%esp)
 811:	e8 7a fe ff ff       	call   690 <printint>
        ap++;
 816:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 81a:	e9 b4 00 00 00       	jmp    8d3 <printf+0x194>
      } else if(c == 's'){
 81f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 823:	75 46                	jne    86b <printf+0x12c>
        s = (char*)*ap;
 825:	8b 45 e8             	mov    -0x18(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 82d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 831:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 835:	75 27                	jne    85e <printf+0x11f>
          s = "(null)";
 837:	c7 45 f4 3c 0b 00 00 	movl   $0xb3c,-0xc(%ebp)
        while(*s != 0){
 83e:	eb 1e                	jmp    85e <printf+0x11f>
          putc(fd, *s);
 840:	8b 45 f4             	mov    -0xc(%ebp),%eax
 843:	0f b6 00             	movzbl (%eax),%eax
 846:	0f be c0             	movsbl %al,%eax
 849:	89 44 24 04          	mov    %eax,0x4(%esp)
 84d:	8b 45 08             	mov    0x8(%ebp),%eax
 850:	89 04 24             	mov    %eax,(%esp)
 853:	e8 10 fe ff ff       	call   668 <putc>
          s++;
 858:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 85c:	eb 01                	jmp    85f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 85e:	90                   	nop
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	0f b6 00             	movzbl (%eax),%eax
 865:	84 c0                	test   %al,%al
 867:	75 d7                	jne    840 <printf+0x101>
 869:	eb 68                	jmp    8d3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 86b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 86f:	75 1d                	jne    88e <printf+0x14f>
        putc(fd, *ap);
 871:	8b 45 e8             	mov    -0x18(%ebp),%eax
 874:	8b 00                	mov    (%eax),%eax
 876:	0f be c0             	movsbl %al,%eax
 879:	89 44 24 04          	mov    %eax,0x4(%esp)
 87d:	8b 45 08             	mov    0x8(%ebp),%eax
 880:	89 04 24             	mov    %eax,(%esp)
 883:	e8 e0 fd ff ff       	call   668 <putc>
        ap++;
 888:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 88c:	eb 45                	jmp    8d3 <printf+0x194>
      } else if(c == '%'){
 88e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 892:	75 17                	jne    8ab <printf+0x16c>
        putc(fd, c);
 894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 897:	0f be c0             	movsbl %al,%eax
 89a:	89 44 24 04          	mov    %eax,0x4(%esp)
 89e:	8b 45 08             	mov    0x8(%ebp),%eax
 8a1:	89 04 24             	mov    %eax,(%esp)
 8a4:	e8 bf fd ff ff       	call   668 <putc>
 8a9:	eb 28                	jmp    8d3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8ab:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8b2:	00 
 8b3:	8b 45 08             	mov    0x8(%ebp),%eax
 8b6:	89 04 24             	mov    %eax,(%esp)
 8b9:	e8 aa fd ff ff       	call   668 <putc>
        putc(fd, c);
 8be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c1:	0f be c0             	movsbl %al,%eax
 8c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c8:	8b 45 08             	mov    0x8(%ebp),%eax
 8cb:	89 04 24             	mov    %eax,(%esp)
 8ce:	e8 95 fd ff ff       	call   668 <putc>
      }
      state = 0;
 8d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8de:	8b 55 0c             	mov    0xc(%ebp),%edx
 8e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e4:	01 d0                	add    %edx,%eax
 8e6:	0f b6 00             	movzbl (%eax),%eax
 8e9:	84 c0                	test   %al,%al
 8eb:	0f 85 70 fe ff ff    	jne    761 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8f1:	c9                   	leave  
 8f2:	c3                   	ret    
 8f3:	90                   	nop

000008f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f4:	55                   	push   %ebp
 8f5:	89 e5                	mov    %esp,%ebp
 8f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8fa:	8b 45 08             	mov    0x8(%ebp),%eax
 8fd:	83 e8 08             	sub    $0x8,%eax
 900:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 903:	a1 48 0e 00 00       	mov    0xe48,%eax
 908:	89 45 fc             	mov    %eax,-0x4(%ebp)
 90b:	eb 24                	jmp    931 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 00                	mov    (%eax),%eax
 912:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 915:	77 12                	ja     929 <free+0x35>
 917:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 91d:	77 24                	ja     943 <free+0x4f>
 91f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 922:	8b 00                	mov    (%eax),%eax
 924:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 927:	77 1a                	ja     943 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 931:	8b 45 f8             	mov    -0x8(%ebp),%eax
 934:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 937:	76 d4                	jbe    90d <free+0x19>
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 941:	76 ca                	jbe    90d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	8b 40 04             	mov    0x4(%eax),%eax
 949:	c1 e0 03             	shl    $0x3,%eax
 94c:	89 c2                	mov    %eax,%edx
 94e:	03 55 f8             	add    -0x8(%ebp),%edx
 951:	8b 45 fc             	mov    -0x4(%ebp),%eax
 954:	8b 00                	mov    (%eax),%eax
 956:	39 c2                	cmp    %eax,%edx
 958:	75 24                	jne    97e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 95a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95d:	8b 50 04             	mov    0x4(%eax),%edx
 960:	8b 45 fc             	mov    -0x4(%ebp),%eax
 963:	8b 00                	mov    (%eax),%eax
 965:	8b 40 04             	mov    0x4(%eax),%eax
 968:	01 c2                	add    %eax,%edx
 96a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	8b 00                	mov    (%eax),%eax
 975:	8b 10                	mov    (%eax),%edx
 977:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97a:	89 10                	mov    %edx,(%eax)
 97c:	eb 0a                	jmp    988 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 97e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 981:	8b 10                	mov    (%eax),%edx
 983:	8b 45 f8             	mov    -0x8(%ebp),%eax
 986:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 988:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98b:	8b 40 04             	mov    0x4(%eax),%eax
 98e:	c1 e0 03             	shl    $0x3,%eax
 991:	03 45 fc             	add    -0x4(%ebp),%eax
 994:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 997:	75 20                	jne    9b9 <free+0xc5>
    p->s.size += bp->s.size;
 999:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99c:	8b 50 04             	mov    0x4(%eax),%edx
 99f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a2:	8b 40 04             	mov    0x4(%eax),%eax
 9a5:	01 c2                	add    %eax,%edx
 9a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9aa:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b0:	8b 10                	mov    (%eax),%edx
 9b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b5:	89 10                	mov    %edx,(%eax)
 9b7:	eb 08                	jmp    9c1 <free+0xcd>
  } else
    p->s.ptr = bp;
 9b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9bf:	89 10                	mov    %edx,(%eax)
  freep = p;
 9c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c4:	a3 48 0e 00 00       	mov    %eax,0xe48
}
 9c9:	c9                   	leave  
 9ca:	c3                   	ret    

000009cb <morecore>:

static Header*
morecore(uint nu)
{
 9cb:	55                   	push   %ebp
 9cc:	89 e5                	mov    %esp,%ebp
 9ce:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9d1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9d8:	77 07                	ja     9e1 <morecore+0x16>
    nu = 4096;
 9da:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9e1:	8b 45 08             	mov    0x8(%ebp),%eax
 9e4:	c1 e0 03             	shl    $0x3,%eax
 9e7:	89 04 24             	mov    %eax,(%esp)
 9ea:	e8 61 fc ff ff       	call   650 <sbrk>
 9ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9f2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9f6:	75 07                	jne    9ff <morecore+0x34>
    return 0;
 9f8:	b8 00 00 00 00       	mov    $0x0,%eax
 9fd:	eb 22                	jmp    a21 <morecore+0x56>
  hp = (Header*)p;
 9ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a08:	8b 55 08             	mov    0x8(%ebp),%edx
 a0b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a11:	83 c0 08             	add    $0x8,%eax
 a14:	89 04 24             	mov    %eax,(%esp)
 a17:	e8 d8 fe ff ff       	call   8f4 <free>
  return freep;
 a1c:	a1 48 0e 00 00       	mov    0xe48,%eax
}
 a21:	c9                   	leave  
 a22:	c3                   	ret    

00000a23 <malloc>:

void*
malloc(uint nbytes)
{
 a23:	55                   	push   %ebp
 a24:	89 e5                	mov    %esp,%ebp
 a26:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a29:	8b 45 08             	mov    0x8(%ebp),%eax
 a2c:	83 c0 07             	add    $0x7,%eax
 a2f:	c1 e8 03             	shr    $0x3,%eax
 a32:	83 c0 01             	add    $0x1,%eax
 a35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a38:	a1 48 0e 00 00       	mov    0xe48,%eax
 a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a44:	75 23                	jne    a69 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a46:	c7 45 f0 40 0e 00 00 	movl   $0xe40,-0x10(%ebp)
 a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a50:	a3 48 0e 00 00       	mov    %eax,0xe48
 a55:	a1 48 0e 00 00       	mov    0xe48,%eax
 a5a:	a3 40 0e 00 00       	mov    %eax,0xe40
    base.s.size = 0;
 a5f:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
 a66:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6c:	8b 00                	mov    (%eax),%eax
 a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a74:	8b 40 04             	mov    0x4(%eax),%eax
 a77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a7a:	72 4d                	jb     ac9 <malloc+0xa6>
      if(p->s.size == nunits)
 a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7f:	8b 40 04             	mov    0x4(%eax),%eax
 a82:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a85:	75 0c                	jne    a93 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8a:	8b 10                	mov    (%eax),%edx
 a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8f:	89 10                	mov    %edx,(%eax)
 a91:	eb 26                	jmp    ab9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a96:	8b 40 04             	mov    0x4(%eax),%eax
 a99:	89 c2                	mov    %eax,%edx
 a9b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa7:	8b 40 04             	mov    0x4(%eax),%eax
 aaa:	c1 e0 03             	shl    $0x3,%eax
 aad:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ab6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abc:	a3 48 0e 00 00       	mov    %eax,0xe48
      return (void*)(p + 1);
 ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac4:	83 c0 08             	add    $0x8,%eax
 ac7:	eb 38                	jmp    b01 <malloc+0xde>
    }
    if(p == freep)
 ac9:	a1 48 0e 00 00       	mov    0xe48,%eax
 ace:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ad1:	75 1b                	jne    aee <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 ad3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ad6:	89 04 24             	mov    %eax,(%esp)
 ad9:	e8 ed fe ff ff       	call   9cb <morecore>
 ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae5:	75 07                	jne    aee <malloc+0xcb>
        return 0;
 ae7:	b8 00 00 00 00       	mov    $0x0,%eax
 aec:	eb 13                	jmp    b01 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af7:	8b 00                	mov    (%eax),%eax
 af9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 afc:	e9 70 ff ff ff       	jmp    a71 <malloc+0x4e>
}
 b01:	c9                   	leave  
 b02:	c3                   	ret    
