
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
  54:	c7 04 24 0b 0b 00 00 	movl   $0xb0b,(%esp)
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
  a0:	e8 43 05 00 00       	call   5e8 <read>
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
  b8:	c7 44 24 04 11 0b 00 	movl   $0xb11,0x4(%esp)
  bf:	00 
  c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c7:	e8 7b 06 00 00       	call   747 <printf>
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
  ed:	c7 44 24 04 21 0b 00 	movl   $0xb21,0x4(%esp)
  f4:	00 
  f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fc:	e8 46 06 00 00       	call   747 <printf>
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
 112:	c7 44 24 04 2e 0b 00 	movl   $0xb2e,0x4(%esp)
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
 14c:	e8 bf 04 00 00       	call   610 <open>
 151:	89 44 24 18          	mov    %eax,0x18(%esp)
 155:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 15a:	79 29                	jns    185 <main+0x82>
      printf(1, "cat: cannot open %s\n", argv[i]);
 15c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 160:	c1 e0 02             	shl    $0x2,%eax
 163:	03 45 0c             	add    0xc(%ebp),%eax
 166:	8b 00                	mov    (%eax),%eax
 168:	89 44 24 08          	mov    %eax,0x8(%esp)
 16c:	c7 44 24 04 2f 0b 00 	movl   $0xb2f,0x4(%esp)
 173:	00 
 174:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17b:	e8 c7 05 00 00       	call   747 <printf>
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
 1a8:	e8 4b 04 00 00       	call   5f8 <close>
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
 2ff:	e8 e4 02 00 00       	call   5e8 <read>
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
 35d:	e8 ae 02 00 00       	call   610 <open>
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
 37f:	e8 a4 02 00 00       	call   628 <fstat>
 384:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 387:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38a:	89 04 24             	mov    %eax,(%esp)
 38d:	e8 66 02 00 00       	call   5f8 <close>
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

000005d8 <nice>:
SYSCALL(nice)
 5d8:	b8 17 00 00 00       	mov    $0x17,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <pipe>:
SYSCALL(pipe)
 5e0:	b8 04 00 00 00       	mov    $0x4,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <read>:
SYSCALL(read)
 5e8:	b8 05 00 00 00       	mov    $0x5,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <write>:
SYSCALL(write)
 5f0:	b8 10 00 00 00       	mov    $0x10,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <close>:
SYSCALL(close)
 5f8:	b8 15 00 00 00       	mov    $0x15,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <kill>:
SYSCALL(kill)
 600:	b8 06 00 00 00       	mov    $0x6,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <exec>:
SYSCALL(exec)
 608:	b8 07 00 00 00       	mov    $0x7,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <open>:
SYSCALL(open)
 610:	b8 0f 00 00 00       	mov    $0xf,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <mknod>:
SYSCALL(mknod)
 618:	b8 11 00 00 00       	mov    $0x11,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <unlink>:
SYSCALL(unlink)
 620:	b8 12 00 00 00       	mov    $0x12,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <fstat>:
SYSCALL(fstat)
 628:	b8 08 00 00 00       	mov    $0x8,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <link>:
SYSCALL(link)
 630:	b8 13 00 00 00       	mov    $0x13,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <mkdir>:
SYSCALL(mkdir)
 638:	b8 14 00 00 00       	mov    $0x14,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <chdir>:
SYSCALL(chdir)
 640:	b8 09 00 00 00       	mov    $0x9,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <dup>:
SYSCALL(dup)
 648:	b8 0a 00 00 00       	mov    $0xa,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <getpid>:
SYSCALL(getpid)
 650:	b8 0b 00 00 00       	mov    $0xb,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <sbrk>:
SYSCALL(sbrk)
 658:	b8 0c 00 00 00       	mov    $0xc,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <sleep>:
SYSCALL(sleep)
 660:	b8 0d 00 00 00       	mov    $0xd,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <uptime>:
SYSCALL(uptime)
 668:	b8 0e 00 00 00       	mov    $0xe,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 670:	55                   	push   %ebp
 671:	89 e5                	mov    %esp,%ebp
 673:	83 ec 28             	sub    $0x28,%esp
 676:	8b 45 0c             	mov    0xc(%ebp),%eax
 679:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 67c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 683:	00 
 684:	8d 45 f4             	lea    -0xc(%ebp),%eax
 687:	89 44 24 04          	mov    %eax,0x4(%esp)
 68b:	8b 45 08             	mov    0x8(%ebp),%eax
 68e:	89 04 24             	mov    %eax,(%esp)
 691:	e8 5a ff ff ff       	call   5f0 <write>
}
 696:	c9                   	leave  
 697:	c3                   	ret    

00000698 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 698:	55                   	push   %ebp
 699:	89 e5                	mov    %esp,%ebp
 69b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 69e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6a5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6a9:	74 17                	je     6c2 <printint+0x2a>
 6ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6af:	79 11                	jns    6c2 <printint+0x2a>
    neg = 1;
 6b1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bb:	f7 d8                	neg    %eax
 6bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c0:	eb 06                	jmp    6c8 <printint+0x30>
  } else {
    x = xx;
 6c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d5:	ba 00 00 00 00       	mov    $0x0,%edx
 6da:	f7 f1                	div    %ecx
 6dc:	89 d0                	mov    %edx,%eax
 6de:	0f b6 90 28 0e 00 00 	movzbl 0xe28(%eax),%edx
 6e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6e8:	03 45 f4             	add    -0xc(%ebp),%eax
 6eb:	88 10                	mov    %dl,(%eax)
 6ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6f1:	8b 55 10             	mov    0x10(%ebp),%edx
 6f4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fa:	ba 00 00 00 00       	mov    $0x0,%edx
 6ff:	f7 75 d4             	divl   -0x2c(%ebp)
 702:	89 45 ec             	mov    %eax,-0x14(%ebp)
 705:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 709:	75 c4                	jne    6cf <printint+0x37>
  if(neg)
 70b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 70f:	74 2a                	je     73b <printint+0xa3>
    buf[i++] = '-';
 711:	8d 45 dc             	lea    -0x24(%ebp),%eax
 714:	03 45 f4             	add    -0xc(%ebp),%eax
 717:	c6 00 2d             	movb   $0x2d,(%eax)
 71a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 71e:	eb 1b                	jmp    73b <printint+0xa3>
    putc(fd, buf[i]);
 720:	8d 45 dc             	lea    -0x24(%ebp),%eax
 723:	03 45 f4             	add    -0xc(%ebp),%eax
 726:	0f b6 00             	movzbl (%eax),%eax
 729:	0f be c0             	movsbl %al,%eax
 72c:	89 44 24 04          	mov    %eax,0x4(%esp)
 730:	8b 45 08             	mov    0x8(%ebp),%eax
 733:	89 04 24             	mov    %eax,(%esp)
 736:	e8 35 ff ff ff       	call   670 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 73b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 73f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 743:	79 db                	jns    720 <printint+0x88>
    putc(fd, buf[i]);
}
 745:	c9                   	leave  
 746:	c3                   	ret    

00000747 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 747:	55                   	push   %ebp
 748:	89 e5                	mov    %esp,%ebp
 74a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 74d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 754:	8d 45 0c             	lea    0xc(%ebp),%eax
 757:	83 c0 04             	add    $0x4,%eax
 75a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 75d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 764:	e9 7d 01 00 00       	jmp    8e6 <printf+0x19f>
    c = fmt[i] & 0xff;
 769:	8b 55 0c             	mov    0xc(%ebp),%edx
 76c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76f:	01 d0                	add    %edx,%eax
 771:	0f b6 00             	movzbl (%eax),%eax
 774:	0f be c0             	movsbl %al,%eax
 777:	25 ff 00 00 00       	and    $0xff,%eax
 77c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 77f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 783:	75 2c                	jne    7b1 <printf+0x6a>
      if(c == '%'){
 785:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 789:	75 0c                	jne    797 <printf+0x50>
        state = '%';
 78b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 792:	e9 4b 01 00 00       	jmp    8e2 <printf+0x19b>
      } else {
        putc(fd, c);
 797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79a:	0f be c0             	movsbl %al,%eax
 79d:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a1:	8b 45 08             	mov    0x8(%ebp),%eax
 7a4:	89 04 24             	mov    %eax,(%esp)
 7a7:	e8 c4 fe ff ff       	call   670 <putc>
 7ac:	e9 31 01 00 00       	jmp    8e2 <printf+0x19b>
      }
    } else if(state == '%'){
 7b1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7b5:	0f 85 27 01 00 00    	jne    8e2 <printf+0x19b>
      if(c == 'd'){
 7bb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7bf:	75 2d                	jne    7ee <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c4:	8b 00                	mov    (%eax),%eax
 7c6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7cd:	00 
 7ce:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7d5:	00 
 7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7da:	8b 45 08             	mov    0x8(%ebp),%eax
 7dd:	89 04 24             	mov    %eax,(%esp)
 7e0:	e8 b3 fe ff ff       	call   698 <printint>
        ap++;
 7e5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e9:	e9 ed 00 00 00       	jmp    8db <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7ee:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7f2:	74 06                	je     7fa <printf+0xb3>
 7f4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7f8:	75 2d                	jne    827 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fd:	8b 00                	mov    (%eax),%eax
 7ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 806:	00 
 807:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 80e:	00 
 80f:	89 44 24 04          	mov    %eax,0x4(%esp)
 813:	8b 45 08             	mov    0x8(%ebp),%eax
 816:	89 04 24             	mov    %eax,(%esp)
 819:	e8 7a fe ff ff       	call   698 <printint>
        ap++;
 81e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 822:	e9 b4 00 00 00       	jmp    8db <printf+0x194>
      } else if(c == 's'){
 827:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 82b:	75 46                	jne    873 <printf+0x12c>
        s = (char*)*ap;
 82d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 830:	8b 00                	mov    (%eax),%eax
 832:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 835:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 839:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 83d:	75 27                	jne    866 <printf+0x11f>
          s = "(null)";
 83f:	c7 45 f4 44 0b 00 00 	movl   $0xb44,-0xc(%ebp)
        while(*s != 0){
 846:	eb 1e                	jmp    866 <printf+0x11f>
          putc(fd, *s);
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	0f b6 00             	movzbl (%eax),%eax
 84e:	0f be c0             	movsbl %al,%eax
 851:	89 44 24 04          	mov    %eax,0x4(%esp)
 855:	8b 45 08             	mov    0x8(%ebp),%eax
 858:	89 04 24             	mov    %eax,(%esp)
 85b:	e8 10 fe ff ff       	call   670 <putc>
          s++;
 860:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 864:	eb 01                	jmp    867 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 866:	90                   	nop
 867:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86a:	0f b6 00             	movzbl (%eax),%eax
 86d:	84 c0                	test   %al,%al
 86f:	75 d7                	jne    848 <printf+0x101>
 871:	eb 68                	jmp    8db <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 873:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 877:	75 1d                	jne    896 <printf+0x14f>
        putc(fd, *ap);
 879:	8b 45 e8             	mov    -0x18(%ebp),%eax
 87c:	8b 00                	mov    (%eax),%eax
 87e:	0f be c0             	movsbl %al,%eax
 881:	89 44 24 04          	mov    %eax,0x4(%esp)
 885:	8b 45 08             	mov    0x8(%ebp),%eax
 888:	89 04 24             	mov    %eax,(%esp)
 88b:	e8 e0 fd ff ff       	call   670 <putc>
        ap++;
 890:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 894:	eb 45                	jmp    8db <printf+0x194>
      } else if(c == '%'){
 896:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 89a:	75 17                	jne    8b3 <printf+0x16c>
        putc(fd, c);
 89c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 89f:	0f be c0             	movsbl %al,%eax
 8a2:	89 44 24 04          	mov    %eax,0x4(%esp)
 8a6:	8b 45 08             	mov    0x8(%ebp),%eax
 8a9:	89 04 24             	mov    %eax,(%esp)
 8ac:	e8 bf fd ff ff       	call   670 <putc>
 8b1:	eb 28                	jmp    8db <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8b3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8ba:	00 
 8bb:	8b 45 08             	mov    0x8(%ebp),%eax
 8be:	89 04 24             	mov    %eax,(%esp)
 8c1:	e8 aa fd ff ff       	call   670 <putc>
        putc(fd, c);
 8c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c9:	0f be c0             	movsbl %al,%eax
 8cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d0:	8b 45 08             	mov    0x8(%ebp),%eax
 8d3:	89 04 24             	mov    %eax,(%esp)
 8d6:	e8 95 fd ff ff       	call   670 <putc>
      }
      state = 0;
 8db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8e2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8e6:	8b 55 0c             	mov    0xc(%ebp),%edx
 8e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ec:	01 d0                	add    %edx,%eax
 8ee:	0f b6 00             	movzbl (%eax),%eax
 8f1:	84 c0                	test   %al,%al
 8f3:	0f 85 70 fe ff ff    	jne    769 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8f9:	c9                   	leave  
 8fa:	c3                   	ret    
 8fb:	90                   	nop

000008fc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8fc:	55                   	push   %ebp
 8fd:	89 e5                	mov    %esp,%ebp
 8ff:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 902:	8b 45 08             	mov    0x8(%ebp),%eax
 905:	83 e8 08             	sub    $0x8,%eax
 908:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90b:	a1 48 0e 00 00       	mov    0xe48,%eax
 910:	89 45 fc             	mov    %eax,-0x4(%ebp)
 913:	eb 24                	jmp    939 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	8b 00                	mov    (%eax),%eax
 91a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 91d:	77 12                	ja     931 <free+0x35>
 91f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 922:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 925:	77 24                	ja     94b <free+0x4f>
 927:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92a:	8b 00                	mov    (%eax),%eax
 92c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 92f:	77 1a                	ja     94b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 931:	8b 45 fc             	mov    -0x4(%ebp),%eax
 934:	8b 00                	mov    (%eax),%eax
 936:	89 45 fc             	mov    %eax,-0x4(%ebp)
 939:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 93f:	76 d4                	jbe    915 <free+0x19>
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	8b 00                	mov    (%eax),%eax
 946:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 949:	76 ca                	jbe    915 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	8b 40 04             	mov    0x4(%eax),%eax
 951:	c1 e0 03             	shl    $0x3,%eax
 954:	89 c2                	mov    %eax,%edx
 956:	03 55 f8             	add    -0x8(%ebp),%edx
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	8b 00                	mov    (%eax),%eax
 95e:	39 c2                	cmp    %eax,%edx
 960:	75 24                	jne    986 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 962:	8b 45 f8             	mov    -0x8(%ebp),%eax
 965:	8b 50 04             	mov    0x4(%eax),%edx
 968:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96b:	8b 00                	mov    (%eax),%eax
 96d:	8b 40 04             	mov    0x4(%eax),%eax
 970:	01 c2                	add    %eax,%edx
 972:	8b 45 f8             	mov    -0x8(%ebp),%eax
 975:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 978:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97b:	8b 00                	mov    (%eax),%eax
 97d:	8b 10                	mov    (%eax),%edx
 97f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 982:	89 10                	mov    %edx,(%eax)
 984:	eb 0a                	jmp    990 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 986:	8b 45 fc             	mov    -0x4(%ebp),%eax
 989:	8b 10                	mov    (%eax),%edx
 98b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 990:	8b 45 fc             	mov    -0x4(%ebp),%eax
 993:	8b 40 04             	mov    0x4(%eax),%eax
 996:	c1 e0 03             	shl    $0x3,%eax
 999:	03 45 fc             	add    -0x4(%ebp),%eax
 99c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 99f:	75 20                	jne    9c1 <free+0xc5>
    p->s.size += bp->s.size;
 9a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a4:	8b 50 04             	mov    0x4(%eax),%edx
 9a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9aa:	8b 40 04             	mov    0x4(%eax),%eax
 9ad:	01 c2                	add    %eax,%edx
 9af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b8:	8b 10                	mov    (%eax),%edx
 9ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bd:	89 10                	mov    %edx,(%eax)
 9bf:	eb 08                	jmp    9c9 <free+0xcd>
  } else
    p->s.ptr = bp;
 9c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9c7:	89 10                	mov    %edx,(%eax)
  freep = p;
 9c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cc:	a3 48 0e 00 00       	mov    %eax,0xe48
}
 9d1:	c9                   	leave  
 9d2:	c3                   	ret    

000009d3 <morecore>:

static Header*
morecore(uint nu)
{
 9d3:	55                   	push   %ebp
 9d4:	89 e5                	mov    %esp,%ebp
 9d6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9d9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9e0:	77 07                	ja     9e9 <morecore+0x16>
    nu = 4096;
 9e2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9e9:	8b 45 08             	mov    0x8(%ebp),%eax
 9ec:	c1 e0 03             	shl    $0x3,%eax
 9ef:	89 04 24             	mov    %eax,(%esp)
 9f2:	e8 61 fc ff ff       	call   658 <sbrk>
 9f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9fa:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9fe:	75 07                	jne    a07 <morecore+0x34>
    return 0;
 a00:	b8 00 00 00 00       	mov    $0x0,%eax
 a05:	eb 22                	jmp    a29 <morecore+0x56>
  hp = (Header*)p;
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a10:	8b 55 08             	mov    0x8(%ebp),%edx
 a13:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a19:	83 c0 08             	add    $0x8,%eax
 a1c:	89 04 24             	mov    %eax,(%esp)
 a1f:	e8 d8 fe ff ff       	call   8fc <free>
  return freep;
 a24:	a1 48 0e 00 00       	mov    0xe48,%eax
}
 a29:	c9                   	leave  
 a2a:	c3                   	ret    

00000a2b <malloc>:

void*
malloc(uint nbytes)
{
 a2b:	55                   	push   %ebp
 a2c:	89 e5                	mov    %esp,%ebp
 a2e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a31:	8b 45 08             	mov    0x8(%ebp),%eax
 a34:	83 c0 07             	add    $0x7,%eax
 a37:	c1 e8 03             	shr    $0x3,%eax
 a3a:	83 c0 01             	add    $0x1,%eax
 a3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a40:	a1 48 0e 00 00       	mov    0xe48,%eax
 a45:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a4c:	75 23                	jne    a71 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a4e:	c7 45 f0 40 0e 00 00 	movl   $0xe40,-0x10(%ebp)
 a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a58:	a3 48 0e 00 00       	mov    %eax,0xe48
 a5d:	a1 48 0e 00 00       	mov    0xe48,%eax
 a62:	a3 40 0e 00 00       	mov    %eax,0xe40
    base.s.size = 0;
 a67:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
 a6e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a74:	8b 00                	mov    (%eax),%eax
 a76:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7c:	8b 40 04             	mov    0x4(%eax),%eax
 a7f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a82:	72 4d                	jb     ad1 <malloc+0xa6>
      if(p->s.size == nunits)
 a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a87:	8b 40 04             	mov    0x4(%eax),%eax
 a8a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a8d:	75 0c                	jne    a9b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a92:	8b 10                	mov    (%eax),%edx
 a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a97:	89 10                	mov    %edx,(%eax)
 a99:	eb 26                	jmp    ac1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9e:	8b 40 04             	mov    0x4(%eax),%eax
 aa1:	89 c2                	mov    %eax,%edx
 aa3:	2b 55 ec             	sub    -0x14(%ebp),%edx
 aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	8b 40 04             	mov    0x4(%eax),%eax
 ab2:	c1 e0 03             	shl    $0x3,%eax
 ab5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 abe:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac4:	a3 48 0e 00 00       	mov    %eax,0xe48
      return (void*)(p + 1);
 ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acc:	83 c0 08             	add    $0x8,%eax
 acf:	eb 38                	jmp    b09 <malloc+0xde>
    }
    if(p == freep)
 ad1:	a1 48 0e 00 00       	mov    0xe48,%eax
 ad6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ad9:	75 1b                	jne    af6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 adb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ade:	89 04 24             	mov    %eax,(%esp)
 ae1:	e8 ed fe ff ff       	call   9d3 <morecore>
 ae6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aed:	75 07                	jne    af6 <malloc+0xcb>
        return 0;
 aef:	b8 00 00 00 00       	mov    $0x0,%eax
 af4:	eb 13                	jmp    b09 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aff:	8b 00                	mov    (%eax),%eax
 b01:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b04:	e9 70 ff ff ff       	jmp    a79 <malloc+0x4e>
}
 b09:	c9                   	leave  
 b0a:	c3                   	ret    
