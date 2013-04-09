
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
  32:	05 a0 0e 00 00       	add    $0xea0,%eax
  37:	0f b6 00             	movzbl (%eax),%eax
  3a:	3c 0a                	cmp    $0xa,%al
  3c:	75 04                	jne    42 <wc+0x42>
        l++;
  3e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  45:	05 a0 0e 00 00       	add    $0xea0,%eax
  4a:	0f b6 00             	movzbl (%eax),%eax
  4d:	0f be c0             	movsbl %al,%eax
  50:	89 44 24 04          	mov    %eax,0x4(%esp)
  54:	c7 04 24 41 0b 00 00 	movl   $0xb41,(%esp)
  5b:	e8 61 02 00 00       	call   2c1 <strchr>
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
  92:	c7 44 24 04 a0 0e 00 	movl   $0xea0,0x4(%esp)
  99:	00 
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 67 05 00 00       	call   60c <read>
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
  b8:	c7 44 24 04 47 0b 00 	movl   $0xb47,0x4(%esp)
  bf:	00 
  c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c7:	e8 a5 06 00 00       	call   771 <printf>
    exit();
  cc:	e8 13 05 00 00       	call   5e4 <exit>
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
  ed:	c7 44 24 04 57 0b 00 	movl   $0xb57,0x4(%esp)
  f4:	00 
  f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fc:	e8 70 06 00 00       	call   771 <printf>
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
 112:	c7 44 24 04 64 0b 00 	movl   $0xb64,0x4(%esp)
 119:	00 
 11a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 121:	e8 da fe ff ff       	call   0 <wc>
    exit();
 126:	e8 b9 04 00 00       	call   5e4 <exit>
  }

  for(i = 1; i < argc; i++){
 12b:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 132:	00 
 133:	e9 8f 00 00 00       	jmp    1c7 <main+0xc4>
    if((fd = open(argv[i], 0)) < 0){
 138:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 13c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 143:	8b 45 0c             	mov    0xc(%ebp),%eax
 146:	01 d0                	add    %edx,%eax
 148:	8b 00                	mov    (%eax),%eax
 14a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 151:	00 
 152:	89 04 24             	mov    %eax,(%esp)
 155:	e8 da 04 00 00       	call   634 <open>
 15a:	89 44 24 18          	mov    %eax,0x18(%esp)
 15e:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 163:	79 2f                	jns    194 <main+0x91>
      printf(1, "cat: cannot open %s\n", argv[i]);
 165:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 169:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 170:	8b 45 0c             	mov    0xc(%ebp),%eax
 173:	01 d0                	add    %edx,%eax
 175:	8b 00                	mov    (%eax),%eax
 177:	89 44 24 08          	mov    %eax,0x8(%esp)
 17b:	c7 44 24 04 65 0b 00 	movl   $0xb65,0x4(%esp)
 182:	00 
 183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18a:	e8 e2 05 00 00       	call   771 <printf>
      exit();
 18f:	e8 50 04 00 00       	call   5e4 <exit>
    }
    wc(fd, argv[i]);
 194:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 198:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 19f:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a2:	01 d0                	add    %edx,%eax
 1a4:	8b 00                	mov    (%eax),%eax
 1a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 1aa:	8b 44 24 18          	mov    0x18(%esp),%eax
 1ae:	89 04 24             	mov    %eax,(%esp)
 1b1:	e8 4a fe ff ff       	call   0 <wc>
    close(fd);
 1b6:	8b 44 24 18          	mov    0x18(%esp),%eax
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 5a 04 00 00       	call   61c <close>
  if(argc <= 1){
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
 1c2:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1cb:	3b 45 08             	cmp    0x8(%ebp),%eax
 1ce:	0f 8c 64 ff ff ff    	jl     138 <main+0x35>
      exit();
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit();
 1d4:	e8 0b 04 00 00       	call   5e4 <exit>
 1d9:	66 90                	xchg   %ax,%ax
 1db:	90                   	nop

000001dc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1dc:	55                   	push   %ebp
 1dd:	89 e5                	mov    %esp,%ebp
 1df:	57                   	push   %edi
 1e0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1e4:	8b 55 10             	mov    0x10(%ebp),%edx
 1e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ea:	89 cb                	mov    %ecx,%ebx
 1ec:	89 df                	mov    %ebx,%edi
 1ee:	89 d1                	mov    %edx,%ecx
 1f0:	fc                   	cld    
 1f1:	f3 aa                	rep stos %al,%es:(%edi)
 1f3:	89 ca                	mov    %ecx,%edx
 1f5:	89 fb                	mov    %edi,%ebx
 1f7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1fa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1fd:	5b                   	pop    %ebx
 1fe:	5f                   	pop    %edi
 1ff:	5d                   	pop    %ebp
 200:	c3                   	ret    

00000201 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 201:	55                   	push   %ebp
 202:	89 e5                	mov    %esp,%ebp
 204:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 20d:	90                   	nop
 20e:	8b 45 0c             	mov    0xc(%ebp),%eax
 211:	0f b6 10             	movzbl (%eax),%edx
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	88 10                	mov    %dl,(%eax)
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	0f b6 00             	movzbl (%eax),%eax
 21f:	84 c0                	test   %al,%al
 221:	0f 95 c0             	setne  %al
 224:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 228:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 22c:	84 c0                	test   %al,%al
 22e:	75 de                	jne    20e <strcpy+0xd>
    ;
  return os;
 230:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 233:	c9                   	leave  
 234:	c3                   	ret    

00000235 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 235:	55                   	push   %ebp
 236:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 238:	eb 08                	jmp    242 <strcmp+0xd>
    p++, q++;
 23a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 23e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 242:	8b 45 08             	mov    0x8(%ebp),%eax
 245:	0f b6 00             	movzbl (%eax),%eax
 248:	84 c0                	test   %al,%al
 24a:	74 10                	je     25c <strcmp+0x27>
 24c:	8b 45 08             	mov    0x8(%ebp),%eax
 24f:	0f b6 10             	movzbl (%eax),%edx
 252:	8b 45 0c             	mov    0xc(%ebp),%eax
 255:	0f b6 00             	movzbl (%eax),%eax
 258:	38 c2                	cmp    %al,%dl
 25a:	74 de                	je     23a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	0f b6 00             	movzbl (%eax),%eax
 262:	0f b6 d0             	movzbl %al,%edx
 265:	8b 45 0c             	mov    0xc(%ebp),%eax
 268:	0f b6 00             	movzbl (%eax),%eax
 26b:	0f b6 c0             	movzbl %al,%eax
 26e:	89 d1                	mov    %edx,%ecx
 270:	29 c1                	sub    %eax,%ecx
 272:	89 c8                	mov    %ecx,%eax
}
 274:	5d                   	pop    %ebp
 275:	c3                   	ret    

00000276 <strlen>:

uint
strlen(char *s)
{
 276:	55                   	push   %ebp
 277:	89 e5                	mov    %esp,%ebp
 279:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 27c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 283:	eb 04                	jmp    289 <strlen+0x13>
 285:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 289:	8b 55 fc             	mov    -0x4(%ebp),%edx
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	01 d0                	add    %edx,%eax
 291:	0f b6 00             	movzbl (%eax),%eax
 294:	84 c0                	test   %al,%al
 296:	75 ed                	jne    285 <strlen+0xf>
  return n;
 298:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29b:	c9                   	leave  
 29c:	c3                   	ret    

0000029d <memset>:

void*
memset(void *dst, int c, uint n)
{
 29d:	55                   	push   %ebp
 29e:	89 e5                	mov    %esp,%ebp
 2a0:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 2a3:	8b 45 10             	mov    0x10(%ebp),%eax
 2a6:	89 44 24 08          	mov    %eax,0x8(%esp)
 2aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	89 04 24             	mov    %eax,(%esp)
 2b7:	e8 20 ff ff ff       	call   1dc <stosb>
  return dst;
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    

000002c1 <strchr>:

char*
strchr(const char *s, char c)
{
 2c1:	55                   	push   %ebp
 2c2:	89 e5                	mov    %esp,%ebp
 2c4:	83 ec 04             	sub    $0x4,%esp
 2c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ca:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2cd:	eb 14                	jmp    2e3 <strchr+0x22>
    if(*s == c)
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	0f b6 00             	movzbl (%eax),%eax
 2d5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2d8:	75 05                	jne    2df <strchr+0x1e>
      return (char*)s;
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
 2dd:	eb 13                	jmp    2f2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2df:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	0f b6 00             	movzbl (%eax),%eax
 2e9:	84 c0                	test   %al,%al
 2eb:	75 e2                	jne    2cf <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2f2:	c9                   	leave  
 2f3:	c3                   	ret    

000002f4 <gets>:

char*
gets(char *buf, int max)
{
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
 2f7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 301:	eb 46                	jmp    349 <gets+0x55>
    cc = read(0, &c, 1);
 303:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 30a:	00 
 30b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 30e:	89 44 24 04          	mov    %eax,0x4(%esp)
 312:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 319:	e8 ee 02 00 00       	call   60c <read>
 31e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 321:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 325:	7e 2f                	jle    356 <gets+0x62>
      break;
    buf[i++] = c;
 327:	8b 55 f4             	mov    -0xc(%ebp),%edx
 32a:	8b 45 08             	mov    0x8(%ebp),%eax
 32d:	01 c2                	add    %eax,%edx
 32f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 333:	88 02                	mov    %al,(%edx)
 335:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 339:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 33d:	3c 0a                	cmp    $0xa,%al
 33f:	74 16                	je     357 <gets+0x63>
 341:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 345:	3c 0d                	cmp    $0xd,%al
 347:	74 0e                	je     357 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 349:	8b 45 f4             	mov    -0xc(%ebp),%eax
 34c:	83 c0 01             	add    $0x1,%eax
 34f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 352:	7c af                	jl     303 <gets+0xf>
 354:	eb 01                	jmp    357 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 356:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 357:	8b 55 f4             	mov    -0xc(%ebp),%edx
 35a:	8b 45 08             	mov    0x8(%ebp),%eax
 35d:	01 d0                	add    %edx,%eax
 35f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 362:	8b 45 08             	mov    0x8(%ebp),%eax
}
 365:	c9                   	leave  
 366:	c3                   	ret    

00000367 <stat>:

int
stat(char *n, struct stat *st)
{
 367:	55                   	push   %ebp
 368:	89 e5                	mov    %esp,%ebp
 36a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 36d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 374:	00 
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	89 04 24             	mov    %eax,(%esp)
 37b:	e8 b4 02 00 00       	call   634 <open>
 380:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 383:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 387:	79 07                	jns    390 <stat+0x29>
    return -1;
 389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 38e:	eb 23                	jmp    3b3 <stat+0x4c>
  r = fstat(fd, st);
 390:	8b 45 0c             	mov    0xc(%ebp),%eax
 393:	89 44 24 04          	mov    %eax,0x4(%esp)
 397:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39a:	89 04 24             	mov    %eax,(%esp)
 39d:	e8 aa 02 00 00       	call   64c <fstat>
 3a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a8:	89 04 24             	mov    %eax,(%esp)
 3ab:	e8 6c 02 00 00       	call   61c <close>
  return r;
 3b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3b3:	c9                   	leave  
 3b4:	c3                   	ret    

000003b5 <atoi>:

int
atoi(const char *s)
{
 3b5:	55                   	push   %ebp
 3b6:	89 e5                	mov    %esp,%ebp
 3b8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3bb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3c2:	eb 23                	jmp    3e7 <atoi+0x32>
    n = n*10 + *s++ - '0';
 3c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3c7:	89 d0                	mov    %edx,%eax
 3c9:	c1 e0 02             	shl    $0x2,%eax
 3cc:	01 d0                	add    %edx,%eax
 3ce:	01 c0                	add    %eax,%eax
 3d0:	89 c2                	mov    %eax,%edx
 3d2:	8b 45 08             	mov    0x8(%ebp),%eax
 3d5:	0f b6 00             	movzbl (%eax),%eax
 3d8:	0f be c0             	movsbl %al,%eax
 3db:	01 d0                	add    %edx,%eax
 3dd:	83 e8 30             	sub    $0x30,%eax
 3e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	0f b6 00             	movzbl (%eax),%eax
 3ed:	3c 2f                	cmp    $0x2f,%al
 3ef:	7e 0a                	jle    3fb <atoi+0x46>
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	0f b6 00             	movzbl (%eax),%eax
 3f7:	3c 39                	cmp    $0x39,%al
 3f9:	7e c9                	jle    3c4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3fe:	c9                   	leave  
 3ff:	c3                   	ret    

00000400 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 400:	55                   	push   %ebp
 401:	89 e5                	mov    %esp,%ebp
 403:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 406:	8b 45 08             	mov    0x8(%ebp),%eax
 409:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 40c:	8b 45 0c             	mov    0xc(%ebp),%eax
 40f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 412:	eb 13                	jmp    427 <memmove+0x27>
    *dst++ = *src++;
 414:	8b 45 f8             	mov    -0x8(%ebp),%eax
 417:	0f b6 10             	movzbl (%eax),%edx
 41a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 41d:	88 10                	mov    %dl,(%eax)
 41f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 423:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 427:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 42b:	0f 9f c0             	setg   %al
 42e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 432:	84 c0                	test   %al,%al
 434:	75 de                	jne    414 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 436:	8b 45 08             	mov    0x8(%ebp),%eax
}
 439:	c9                   	leave  
 43a:	c3                   	ret    

0000043b <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 43b:	55                   	push   %ebp
 43c:	89 e5                	mov    %esp,%ebp
 43e:	83 ec 38             	sub    $0x38,%esp
 441:	8b 45 10             	mov    0x10(%ebp),%eax
 444:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 447:	8b 45 14             	mov    0x14(%ebp),%eax
 44a:	8b 00                	mov    (%eax),%eax
 44c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 44f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 456:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 45a:	74 06                	je     462 <strtok+0x27>
 45c:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 460:	75 5a                	jne    4bc <strtok+0x81>
    return match;
 462:	8b 45 f0             	mov    -0x10(%ebp),%eax
 465:	eb 76                	jmp    4dd <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 467:	8b 55 f4             	mov    -0xc(%ebp),%edx
 46a:	8b 45 0c             	mov    0xc(%ebp),%eax
 46d:	01 d0                	add    %edx,%eax
 46f:	0f b6 00             	movzbl (%eax),%eax
 472:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 475:	74 06                	je     47d <strtok+0x42>
      {
	index++;
 477:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 47b:	eb 40                	jmp    4bd <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 47d:	8b 45 14             	mov    0x14(%ebp),%eax
 480:	8b 00                	mov    (%eax),%eax
 482:	8b 55 f4             	mov    -0xc(%ebp),%edx
 485:	29 c2                	sub    %eax,%edx
 487:	8b 45 14             	mov    0x14(%ebp),%eax
 48a:	8b 00                	mov    (%eax),%eax
 48c:	89 c1                	mov    %eax,%ecx
 48e:	8b 45 0c             	mov    0xc(%ebp),%eax
 491:	01 c8                	add    %ecx,%eax
 493:	89 54 24 08          	mov    %edx,0x8(%esp)
 497:	89 44 24 04          	mov    %eax,0x4(%esp)
 49b:	8b 45 08             	mov    0x8(%ebp),%eax
 49e:	89 04 24             	mov    %eax,(%esp)
 4a1:	e8 39 00 00 00       	call   4df <strncpy>
 4a6:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	0f b6 00             	movzbl (%eax),%eax
 4af:	84 c0                	test   %al,%al
 4b1:	74 1b                	je     4ce <strtok+0x93>
	  match = 1;
 4b3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 4ba:	eb 12                	jmp    4ce <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 4bc:	90                   	nop
 4bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c3:	01 d0                	add    %edx,%eax
 4c5:	0f b6 00             	movzbl (%eax),%eax
 4c8:	84 c0                	test   %al,%al
 4ca:	75 9b                	jne    467 <strtok+0x2c>
 4cc:	eb 01                	jmp    4cf <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 4ce:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 4cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d2:	8d 50 01             	lea    0x1(%eax),%edx
 4d5:	8b 45 14             	mov    0x14(%ebp),%eax
 4d8:	89 10                	mov    %edx,(%eax)
  return match;
 4da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4dd:	c9                   	leave  
 4de:	c3                   	ret    

000004df <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 4df:	55                   	push   %ebp
 4e0:	89 e5                	mov    %esp,%ebp
 4e2:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 4e5:	8b 45 08             	mov    0x8(%ebp),%eax
 4e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 4eb:	90                   	nop
 4ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4f0:	0f 9f c0             	setg   %al
 4f3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4f7:	84 c0                	test   %al,%al
 4f9:	74 30                	je     52b <strncpy+0x4c>
 4fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4fe:	0f b6 10             	movzbl (%eax),%edx
 501:	8b 45 08             	mov    0x8(%ebp),%eax
 504:	88 10                	mov    %dl,(%eax)
 506:	8b 45 08             	mov    0x8(%ebp),%eax
 509:	0f b6 00             	movzbl (%eax),%eax
 50c:	84 c0                	test   %al,%al
 50e:	0f 95 c0             	setne  %al
 511:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 515:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 519:	84 c0                	test   %al,%al
 51b:	75 cf                	jne    4ec <strncpy+0xd>
    ;
  while(n-- > 0)
 51d:	eb 0c                	jmp    52b <strncpy+0x4c>
    *s++ = 0;
 51f:	8b 45 08             	mov    0x8(%ebp),%eax
 522:	c6 00 00             	movb   $0x0,(%eax)
 525:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 529:	eb 01                	jmp    52c <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 52b:	90                   	nop
 52c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 530:	0f 9f c0             	setg   %al
 533:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 537:	84 c0                	test   %al,%al
 539:	75 e4                	jne    51f <strncpy+0x40>
    *s++ = 0;
  return os;
 53b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 53e:	c9                   	leave  
 53f:	c3                   	ret    

00000540 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 540:	55                   	push   %ebp
 541:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 543:	eb 0c                	jmp    551 <strncmp+0x11>
    n--, p++, q++;
 545:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 549:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 54d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 551:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 555:	74 1a                	je     571 <strncmp+0x31>
 557:	8b 45 08             	mov    0x8(%ebp),%eax
 55a:	0f b6 00             	movzbl (%eax),%eax
 55d:	84 c0                	test   %al,%al
 55f:	74 10                	je     571 <strncmp+0x31>
 561:	8b 45 08             	mov    0x8(%ebp),%eax
 564:	0f b6 10             	movzbl (%eax),%edx
 567:	8b 45 0c             	mov    0xc(%ebp),%eax
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	38 c2                	cmp    %al,%dl
 56f:	74 d4                	je     545 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 571:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 575:	75 07                	jne    57e <strncmp+0x3e>
    return 0;
 577:	b8 00 00 00 00       	mov    $0x0,%eax
 57c:	eb 18                	jmp    596 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 57e:	8b 45 08             	mov    0x8(%ebp),%eax
 581:	0f b6 00             	movzbl (%eax),%eax
 584:	0f b6 d0             	movzbl %al,%edx
 587:	8b 45 0c             	mov    0xc(%ebp),%eax
 58a:	0f b6 00             	movzbl (%eax),%eax
 58d:	0f b6 c0             	movzbl %al,%eax
 590:	89 d1                	mov    %edx,%ecx
 592:	29 c1                	sub    %eax,%ecx
 594:	89 c8                	mov    %ecx,%eax
}
 596:	5d                   	pop    %ebp
 597:	c3                   	ret    

00000598 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 598:	55                   	push   %ebp
 599:	89 e5                	mov    %esp,%ebp
  while(*p){
 59b:	eb 13                	jmp    5b0 <strcat+0x18>
    *dest++ = *p++;
 59d:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a0:	0f b6 10             	movzbl (%eax),%edx
 5a3:	8b 45 08             	mov    0x8(%ebp),%eax
 5a6:	88 10                	mov    %dl,(%eax)
 5a8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5ac:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 5b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b3:	0f b6 00             	movzbl (%eax),%eax
 5b6:	84 c0                	test   %al,%al
 5b8:	75 e3                	jne    59d <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 5ba:	eb 13                	jmp    5cf <strcat+0x37>
    *dest++ = *q++;
 5bc:	8b 45 10             	mov    0x10(%ebp),%eax
 5bf:	0f b6 10             	movzbl (%eax),%edx
 5c2:	8b 45 08             	mov    0x8(%ebp),%eax
 5c5:	88 10                	mov    %dl,(%eax)
 5c7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5cb:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 5cf:	8b 45 10             	mov    0x10(%ebp),%eax
 5d2:	0f b6 00             	movzbl (%eax),%eax
 5d5:	84 c0                	test   %al,%al
 5d7:	75 e3                	jne    5bc <strcat+0x24>
    *dest++ = *q++;
  }  
 5d9:	5d                   	pop    %ebp
 5da:	c3                   	ret    
 5db:	90                   	nop

000005dc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5dc:	b8 01 00 00 00       	mov    $0x1,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <exit>:
SYSCALL(exit)
 5e4:	b8 02 00 00 00       	mov    $0x2,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <wait>:
SYSCALL(wait)
 5ec:	b8 03 00 00 00       	mov    $0x3,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <wait2>:
SYSCALL(wait2)
 5f4:	b8 16 00 00 00       	mov    $0x16,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <nice>:
SYSCALL(nice)
 5fc:	b8 17 00 00 00       	mov    $0x17,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <pipe>:
SYSCALL(pipe)
 604:	b8 04 00 00 00       	mov    $0x4,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <read>:
SYSCALL(read)
 60c:	b8 05 00 00 00       	mov    $0x5,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <write>:
SYSCALL(write)
 614:	b8 10 00 00 00       	mov    $0x10,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <close>:
SYSCALL(close)
 61c:	b8 15 00 00 00       	mov    $0x15,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <kill>:
SYSCALL(kill)
 624:	b8 06 00 00 00       	mov    $0x6,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <exec>:
SYSCALL(exec)
 62c:	b8 07 00 00 00       	mov    $0x7,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <open>:
SYSCALL(open)
 634:	b8 0f 00 00 00       	mov    $0xf,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <mknod>:
SYSCALL(mknod)
 63c:	b8 11 00 00 00       	mov    $0x11,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <unlink>:
SYSCALL(unlink)
 644:	b8 12 00 00 00       	mov    $0x12,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <fstat>:
SYSCALL(fstat)
 64c:	b8 08 00 00 00       	mov    $0x8,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <link>:
SYSCALL(link)
 654:	b8 13 00 00 00       	mov    $0x13,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <mkdir>:
SYSCALL(mkdir)
 65c:	b8 14 00 00 00       	mov    $0x14,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <chdir>:
SYSCALL(chdir)
 664:	b8 09 00 00 00       	mov    $0x9,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <dup>:
SYSCALL(dup)
 66c:	b8 0a 00 00 00       	mov    $0xa,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <getpid>:
SYSCALL(getpid)
 674:	b8 0b 00 00 00       	mov    $0xb,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <sbrk>:
SYSCALL(sbrk)
 67c:	b8 0c 00 00 00       	mov    $0xc,%eax
 681:	cd 40                	int    $0x40
 683:	c3                   	ret    

00000684 <sleep>:
SYSCALL(sleep)
 684:	b8 0d 00 00 00       	mov    $0xd,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <uptime>:
SYSCALL(uptime)
 68c:	b8 0e 00 00 00       	mov    $0xe,%eax
 691:	cd 40                	int    $0x40
 693:	c3                   	ret    

00000694 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 694:	55                   	push   %ebp
 695:	89 e5                	mov    %esp,%ebp
 697:	83 ec 28             	sub    $0x28,%esp
 69a:	8b 45 0c             	mov    0xc(%ebp),%eax
 69d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6a0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6a7:	00 
 6a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 6af:	8b 45 08             	mov    0x8(%ebp),%eax
 6b2:	89 04 24             	mov    %eax,(%esp)
 6b5:	e8 5a ff ff ff       	call   614 <write>
}
 6ba:	c9                   	leave  
 6bb:	c3                   	ret    

000006bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6bc:	55                   	push   %ebp
 6bd:	89 e5                	mov    %esp,%ebp
 6bf:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6c9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6cd:	74 17                	je     6e6 <printint+0x2a>
 6cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6d3:	79 11                	jns    6e6 <printint+0x2a>
    neg = 1;
 6d5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6df:	f7 d8                	neg    %eax
 6e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6e4:	eb 06                	jmp    6ec <printint+0x30>
  } else {
    x = xx;
 6e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f9:	ba 00 00 00 00       	mov    $0x0,%edx
 6fe:	f7 f1                	div    %ecx
 700:	89 d0                	mov    %edx,%eax
 702:	0f b6 80 60 0e 00 00 	movzbl 0xe60(%eax),%eax
 709:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 70c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 70f:	01 ca                	add    %ecx,%edx
 711:	88 02                	mov    %al,(%edx)
 713:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 717:	8b 55 10             	mov    0x10(%ebp),%edx
 71a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 71d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 720:	ba 00 00 00 00       	mov    $0x0,%edx
 725:	f7 75 d4             	divl   -0x2c(%ebp)
 728:	89 45 ec             	mov    %eax,-0x14(%ebp)
 72b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 72f:	75 c2                	jne    6f3 <printint+0x37>
  if(neg)
 731:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 735:	74 2e                	je     765 <printint+0xa9>
    buf[i++] = '-';
 737:	8d 55 dc             	lea    -0x24(%ebp),%edx
 73a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73d:	01 d0                	add    %edx,%eax
 73f:	c6 00 2d             	movb   $0x2d,(%eax)
 742:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 746:	eb 1d                	jmp    765 <printint+0xa9>
    putc(fd, buf[i]);
 748:	8d 55 dc             	lea    -0x24(%ebp),%edx
 74b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74e:	01 d0                	add    %edx,%eax
 750:	0f b6 00             	movzbl (%eax),%eax
 753:	0f be c0             	movsbl %al,%eax
 756:	89 44 24 04          	mov    %eax,0x4(%esp)
 75a:	8b 45 08             	mov    0x8(%ebp),%eax
 75d:	89 04 24             	mov    %eax,(%esp)
 760:	e8 2f ff ff ff       	call   694 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 765:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 769:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 76d:	79 d9                	jns    748 <printint+0x8c>
    putc(fd, buf[i]);
}
 76f:	c9                   	leave  
 770:	c3                   	ret    

00000771 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 771:	55                   	push   %ebp
 772:	89 e5                	mov    %esp,%ebp
 774:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 777:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 77e:	8d 45 0c             	lea    0xc(%ebp),%eax
 781:	83 c0 04             	add    $0x4,%eax
 784:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 787:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 78e:	e9 7d 01 00 00       	jmp    910 <printf+0x19f>
    c = fmt[i] & 0xff;
 793:	8b 55 0c             	mov    0xc(%ebp),%edx
 796:	8b 45 f0             	mov    -0x10(%ebp),%eax
 799:	01 d0                	add    %edx,%eax
 79b:	0f b6 00             	movzbl (%eax),%eax
 79e:	0f be c0             	movsbl %al,%eax
 7a1:	25 ff 00 00 00       	and    $0xff,%eax
 7a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7ad:	75 2c                	jne    7db <printf+0x6a>
      if(c == '%'){
 7af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7b3:	75 0c                	jne    7c1 <printf+0x50>
        state = '%';
 7b5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7bc:	e9 4b 01 00 00       	jmp    90c <printf+0x19b>
      } else {
        putc(fd, c);
 7c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c4:	0f be c0             	movsbl %al,%eax
 7c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 7cb:	8b 45 08             	mov    0x8(%ebp),%eax
 7ce:	89 04 24             	mov    %eax,(%esp)
 7d1:	e8 be fe ff ff       	call   694 <putc>
 7d6:	e9 31 01 00 00       	jmp    90c <printf+0x19b>
      }
    } else if(state == '%'){
 7db:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7df:	0f 85 27 01 00 00    	jne    90c <printf+0x19b>
      if(c == 'd'){
 7e5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7e9:	75 2d                	jne    818 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ee:	8b 00                	mov    (%eax),%eax
 7f0:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7f7:	00 
 7f8:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7ff:	00 
 800:	89 44 24 04          	mov    %eax,0x4(%esp)
 804:	8b 45 08             	mov    0x8(%ebp),%eax
 807:	89 04 24             	mov    %eax,(%esp)
 80a:	e8 ad fe ff ff       	call   6bc <printint>
        ap++;
 80f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 813:	e9 ed 00 00 00       	jmp    905 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 818:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 81c:	74 06                	je     824 <printf+0xb3>
 81e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 822:	75 2d                	jne    851 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 824:	8b 45 e8             	mov    -0x18(%ebp),%eax
 827:	8b 00                	mov    (%eax),%eax
 829:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 830:	00 
 831:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 838:	00 
 839:	89 44 24 04          	mov    %eax,0x4(%esp)
 83d:	8b 45 08             	mov    0x8(%ebp),%eax
 840:	89 04 24             	mov    %eax,(%esp)
 843:	e8 74 fe ff ff       	call   6bc <printint>
        ap++;
 848:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 84c:	e9 b4 00 00 00       	jmp    905 <printf+0x194>
      } else if(c == 's'){
 851:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 855:	75 46                	jne    89d <printf+0x12c>
        s = (char*)*ap;
 857:	8b 45 e8             	mov    -0x18(%ebp),%eax
 85a:	8b 00                	mov    (%eax),%eax
 85c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 85f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 863:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 867:	75 27                	jne    890 <printf+0x11f>
          s = "(null)";
 869:	c7 45 f4 7a 0b 00 00 	movl   $0xb7a,-0xc(%ebp)
        while(*s != 0){
 870:	eb 1e                	jmp    890 <printf+0x11f>
          putc(fd, *s);
 872:	8b 45 f4             	mov    -0xc(%ebp),%eax
 875:	0f b6 00             	movzbl (%eax),%eax
 878:	0f be c0             	movsbl %al,%eax
 87b:	89 44 24 04          	mov    %eax,0x4(%esp)
 87f:	8b 45 08             	mov    0x8(%ebp),%eax
 882:	89 04 24             	mov    %eax,(%esp)
 885:	e8 0a fe ff ff       	call   694 <putc>
          s++;
 88a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 88e:	eb 01                	jmp    891 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 890:	90                   	nop
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	0f b6 00             	movzbl (%eax),%eax
 897:	84 c0                	test   %al,%al
 899:	75 d7                	jne    872 <printf+0x101>
 89b:	eb 68                	jmp    905 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 89d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8a1:	75 1d                	jne    8c0 <printf+0x14f>
        putc(fd, *ap);
 8a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a6:	8b 00                	mov    (%eax),%eax
 8a8:	0f be c0             	movsbl %al,%eax
 8ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 8af:	8b 45 08             	mov    0x8(%ebp),%eax
 8b2:	89 04 24             	mov    %eax,(%esp)
 8b5:	e8 da fd ff ff       	call   694 <putc>
        ap++;
 8ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8be:	eb 45                	jmp    905 <printf+0x194>
      } else if(c == '%'){
 8c0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8c4:	75 17                	jne    8dd <printf+0x16c>
        putc(fd, c);
 8c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c9:	0f be c0             	movsbl %al,%eax
 8cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d0:	8b 45 08             	mov    0x8(%ebp),%eax
 8d3:	89 04 24             	mov    %eax,(%esp)
 8d6:	e8 b9 fd ff ff       	call   694 <putc>
 8db:	eb 28                	jmp    905 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8dd:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8e4:	00 
 8e5:	8b 45 08             	mov    0x8(%ebp),%eax
 8e8:	89 04 24             	mov    %eax,(%esp)
 8eb:	e8 a4 fd ff ff       	call   694 <putc>
        putc(fd, c);
 8f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8f3:	0f be c0             	movsbl %al,%eax
 8f6:	89 44 24 04          	mov    %eax,0x4(%esp)
 8fa:	8b 45 08             	mov    0x8(%ebp),%eax
 8fd:	89 04 24             	mov    %eax,(%esp)
 900:	e8 8f fd ff ff       	call   694 <putc>
      }
      state = 0;
 905:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 90c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 910:	8b 55 0c             	mov    0xc(%ebp),%edx
 913:	8b 45 f0             	mov    -0x10(%ebp),%eax
 916:	01 d0                	add    %edx,%eax
 918:	0f b6 00             	movzbl (%eax),%eax
 91b:	84 c0                	test   %al,%al
 91d:	0f 85 70 fe ff ff    	jne    793 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 923:	c9                   	leave  
 924:	c3                   	ret    
 925:	66 90                	xchg   %ax,%ax
 927:	90                   	nop

00000928 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 928:	55                   	push   %ebp
 929:	89 e5                	mov    %esp,%ebp
 92b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 92e:	8b 45 08             	mov    0x8(%ebp),%eax
 931:	83 e8 08             	sub    $0x8,%eax
 934:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 937:	a1 88 0e 00 00       	mov    0xe88,%eax
 93c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 93f:	eb 24                	jmp    965 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	8b 00                	mov    (%eax),%eax
 946:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 949:	77 12                	ja     95d <free+0x35>
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 951:	77 24                	ja     977 <free+0x4f>
 953:	8b 45 fc             	mov    -0x4(%ebp),%eax
 956:	8b 00                	mov    (%eax),%eax
 958:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 95b:	77 1a                	ja     977 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 960:	8b 00                	mov    (%eax),%eax
 962:	89 45 fc             	mov    %eax,-0x4(%ebp)
 965:	8b 45 f8             	mov    -0x8(%ebp),%eax
 968:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 96b:	76 d4                	jbe    941 <free+0x19>
 96d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 970:	8b 00                	mov    (%eax),%eax
 972:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 975:	76 ca                	jbe    941 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 977:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97a:	8b 40 04             	mov    0x4(%eax),%eax
 97d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 984:	8b 45 f8             	mov    -0x8(%ebp),%eax
 987:	01 c2                	add    %eax,%edx
 989:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98c:	8b 00                	mov    (%eax),%eax
 98e:	39 c2                	cmp    %eax,%edx
 990:	75 24                	jne    9b6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 992:	8b 45 f8             	mov    -0x8(%ebp),%eax
 995:	8b 50 04             	mov    0x4(%eax),%edx
 998:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99b:	8b 00                	mov    (%eax),%eax
 99d:	8b 40 04             	mov    0x4(%eax),%eax
 9a0:	01 c2                	add    %eax,%edx
 9a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ab:	8b 00                	mov    (%eax),%eax
 9ad:	8b 10                	mov    (%eax),%edx
 9af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b2:	89 10                	mov    %edx,(%eax)
 9b4:	eb 0a                	jmp    9c0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b9:	8b 10                	mov    (%eax),%edx
 9bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9be:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c3:	8b 40 04             	mov    0x4(%eax),%eax
 9c6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d0:	01 d0                	add    %edx,%eax
 9d2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9d5:	75 20                	jne    9f7 <free+0xcf>
    p->s.size += bp->s.size;
 9d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9da:	8b 50 04             	mov    0x4(%eax),%edx
 9dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e0:	8b 40 04             	mov    0x4(%eax),%eax
 9e3:	01 c2                	add    %eax,%edx
 9e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ee:	8b 10                	mov    (%eax),%edx
 9f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f3:	89 10                	mov    %edx,(%eax)
 9f5:	eb 08                	jmp    9ff <free+0xd7>
  } else
    p->s.ptr = bp;
 9f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fa:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9fd:	89 10                	mov    %edx,(%eax)
  freep = p;
 9ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a02:	a3 88 0e 00 00       	mov    %eax,0xe88
}
 a07:	c9                   	leave  
 a08:	c3                   	ret    

00000a09 <morecore>:

static Header*
morecore(uint nu)
{
 a09:	55                   	push   %ebp
 a0a:	89 e5                	mov    %esp,%ebp
 a0c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a0f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a16:	77 07                	ja     a1f <morecore+0x16>
    nu = 4096;
 a18:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a1f:	8b 45 08             	mov    0x8(%ebp),%eax
 a22:	c1 e0 03             	shl    $0x3,%eax
 a25:	89 04 24             	mov    %eax,(%esp)
 a28:	e8 4f fc ff ff       	call   67c <sbrk>
 a2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a30:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a34:	75 07                	jne    a3d <morecore+0x34>
    return 0;
 a36:	b8 00 00 00 00       	mov    $0x0,%eax
 a3b:	eb 22                	jmp    a5f <morecore+0x56>
  hp = (Header*)p;
 a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a46:	8b 55 08             	mov    0x8(%ebp),%edx
 a49:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4f:	83 c0 08             	add    $0x8,%eax
 a52:	89 04 24             	mov    %eax,(%esp)
 a55:	e8 ce fe ff ff       	call   928 <free>
  return freep;
 a5a:	a1 88 0e 00 00       	mov    0xe88,%eax
}
 a5f:	c9                   	leave  
 a60:	c3                   	ret    

00000a61 <malloc>:

void*
malloc(uint nbytes)
{
 a61:	55                   	push   %ebp
 a62:	89 e5                	mov    %esp,%ebp
 a64:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a67:	8b 45 08             	mov    0x8(%ebp),%eax
 a6a:	83 c0 07             	add    $0x7,%eax
 a6d:	c1 e8 03             	shr    $0x3,%eax
 a70:	83 c0 01             	add    $0x1,%eax
 a73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a76:	a1 88 0e 00 00       	mov    0xe88,%eax
 a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a82:	75 23                	jne    aa7 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a84:	c7 45 f0 80 0e 00 00 	movl   $0xe80,-0x10(%ebp)
 a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8e:	a3 88 0e 00 00       	mov    %eax,0xe88
 a93:	a1 88 0e 00 00       	mov    0xe88,%eax
 a98:	a3 80 0e 00 00       	mov    %eax,0xe80
    base.s.size = 0;
 a9d:	c7 05 84 0e 00 00 00 	movl   $0x0,0xe84
 aa4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aaa:	8b 00                	mov    (%eax),%eax
 aac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab2:	8b 40 04             	mov    0x4(%eax),%eax
 ab5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ab8:	72 4d                	jb     b07 <malloc+0xa6>
      if(p->s.size == nunits)
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	8b 40 04             	mov    0x4(%eax),%eax
 ac0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ac3:	75 0c                	jne    ad1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac8:	8b 10                	mov    (%eax),%edx
 aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acd:	89 10                	mov    %edx,(%eax)
 acf:	eb 26                	jmp    af7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad4:	8b 40 04             	mov    0x4(%eax),%eax
 ad7:	89 c2                	mov    %eax,%edx
 ad9:	2b 55 ec             	sub    -0x14(%ebp),%edx
 adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae5:	8b 40 04             	mov    0x4(%eax),%eax
 ae8:	c1 e0 03             	shl    $0x3,%eax
 aeb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 af4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 afa:	a3 88 0e 00 00       	mov    %eax,0xe88
      return (void*)(p + 1);
 aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b02:	83 c0 08             	add    $0x8,%eax
 b05:	eb 38                	jmp    b3f <malloc+0xde>
    }
    if(p == freep)
 b07:	a1 88 0e 00 00       	mov    0xe88,%eax
 b0c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b0f:	75 1b                	jne    b2c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 b11:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b14:	89 04 24             	mov    %eax,(%esp)
 b17:	e8 ed fe ff ff       	call   a09 <morecore>
 b1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b23:	75 07                	jne    b2c <malloc+0xcb>
        return 0;
 b25:	b8 00 00 00 00       	mov    $0x0,%eax
 b2a:	eb 13                	jmp    b3f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b35:	8b 00                	mov    (%eax),%eax
 b37:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b3a:	e9 70 ff ff ff       	jmp    aaf <malloc+0x4e>
}
 b3f:	c9                   	leave  
 b40:	c3                   	ret    
