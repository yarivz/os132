
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
   f:	c7 44 24 04 e0 0d 00 	movl   $0xde0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 35 05 00 00       	call   558 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2a:	00 
  2b:	c7 44 24 04 e0 0d 00 	movl   $0xde0,0x4(%esp)
  32:	00 
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 12 05 00 00       	call   550 <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 85 0a 00 	movl   $0xa85,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 54 06 00 00       	call   6b5 <printf>
    exit();
  61:	e8 c2 04 00 00       	call   528 <exit>
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
  83:	e8 a0 04 00 00       	call   528 <exit>
  }

  for(i = 1; i < argc; i++){
  88:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  8f:	00 
  90:	eb 79                	jmp    10b <main+0xa3>
    if((fd = open(argv[i], 0)) < 0){
  92:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  a0:	01 d0                	add    %edx,%eax
  a2:	8b 00                	mov    (%eax),%eax
  a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ab:	00 
  ac:	89 04 24             	mov    %eax,(%esp)
  af:	e8 c4 04 00 00       	call   578 <open>
  b4:	89 44 24 18          	mov    %eax,0x18(%esp)
  b8:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  bd:	79 2f                	jns    ee <main+0x86>
      printf(1, "cat: cannot open %s\n", argv[i]);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  cd:	01 d0                	add    %edx,%eax
  cf:	8b 00                	mov    (%eax),%eax
  d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  d5:	c7 44 24 04 96 0a 00 	movl   $0xa96,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e4:	e8 cc 05 00 00       	call   6b5 <printf>
      exit();
  e9:	e8 3a 04 00 00       	call   528 <exit>
    }
    cat(fd);
  ee:	8b 44 24 18          	mov    0x18(%esp),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 06 ff ff ff       	call   0 <cat>
    close(fd);
  fa:	8b 44 24 18          	mov    0x18(%esp),%eax
  fe:	89 04 24             	mov    %eax,(%esp)
 101:	e8 5a 04 00 00       	call   560 <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
 106:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 10b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 10f:	3b 45 08             	cmp    0x8(%ebp),%eax
 112:	0f 8c 7a ff ff ff    	jl     92 <main+0x2a>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 118:	e8 0b 04 00 00       	call   528 <exit>
 11d:	66 90                	xchg   %ax,%ax
 11f:	90                   	nop

00000120 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	57                   	push   %edi
 124:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 125:	8b 4d 08             	mov    0x8(%ebp),%ecx
 128:	8b 55 10             	mov    0x10(%ebp),%edx
 12b:	8b 45 0c             	mov    0xc(%ebp),%eax
 12e:	89 cb                	mov    %ecx,%ebx
 130:	89 df                	mov    %ebx,%edi
 132:	89 d1                	mov    %edx,%ecx
 134:	fc                   	cld    
 135:	f3 aa                	rep stos %al,%es:(%edi)
 137:	89 ca                	mov    %ecx,%edx
 139:	89 fb                	mov    %edi,%ebx
 13b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 141:	5b                   	pop    %ebx
 142:	5f                   	pop    %edi
 143:	5d                   	pop    %ebp
 144:	c3                   	ret    

00000145 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 145:	55                   	push   %ebp
 146:	89 e5                	mov    %esp,%ebp
 148:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
 14e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 151:	90                   	nop
 152:	8b 45 0c             	mov    0xc(%ebp),%eax
 155:	0f b6 10             	movzbl (%eax),%edx
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	88 10                	mov    %dl,(%eax)
 15d:	8b 45 08             	mov    0x8(%ebp),%eax
 160:	0f b6 00             	movzbl (%eax),%eax
 163:	84 c0                	test   %al,%al
 165:	0f 95 c0             	setne  %al
 168:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 170:	84 c0                	test   %al,%al
 172:	75 de                	jne    152 <strcpy+0xd>
    ;
  return os;
 174:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 177:	c9                   	leave  
 178:	c3                   	ret    

00000179 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 179:	55                   	push   %ebp
 17a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 17c:	eb 08                	jmp    186 <strcmp+0xd>
    p++, q++;
 17e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 182:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	84 c0                	test   %al,%al
 18e:	74 10                	je     1a0 <strcmp+0x27>
 190:	8b 45 08             	mov    0x8(%ebp),%eax
 193:	0f b6 10             	movzbl (%eax),%edx
 196:	8b 45 0c             	mov    0xc(%ebp),%eax
 199:	0f b6 00             	movzbl (%eax),%eax
 19c:	38 c2                	cmp    %al,%dl
 19e:	74 de                	je     17e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
 1a3:	0f b6 00             	movzbl (%eax),%eax
 1a6:	0f b6 d0             	movzbl %al,%edx
 1a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ac:	0f b6 00             	movzbl (%eax),%eax
 1af:	0f b6 c0             	movzbl %al,%eax
 1b2:	89 d1                	mov    %edx,%ecx
 1b4:	29 c1                	sub    %eax,%ecx
 1b6:	89 c8                	mov    %ecx,%eax
}
 1b8:	5d                   	pop    %ebp
 1b9:	c3                   	ret    

000001ba <strlen>:

uint
strlen(char *s)
{
 1ba:	55                   	push   %ebp
 1bb:	89 e5                	mov    %esp,%ebp
 1bd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 1c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c7:	eb 04                	jmp    1cd <strlen+0x13>
 1c9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
 1d3:	01 d0                	add    %edx,%eax
 1d5:	0f b6 00             	movzbl (%eax),%eax
 1d8:	84 c0                	test   %al,%al
 1da:	75 ed                	jne    1c9 <strlen+0xf>
  return n;
 1dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1df:	c9                   	leave  
 1e0:	c3                   	ret    

000001e1 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1e7:	8b 45 10             	mov    0x10(%ebp),%eax
 1ea:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f1:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f5:	8b 45 08             	mov    0x8(%ebp),%eax
 1f8:	89 04 24             	mov    %eax,(%esp)
 1fb:	e8 20 ff ff ff       	call   120 <stosb>
  return dst;
 200:	8b 45 08             	mov    0x8(%ebp),%eax
}
 203:	c9                   	leave  
 204:	c3                   	ret    

00000205 <strchr>:

char*
strchr(const char *s, char c)
{
 205:	55                   	push   %ebp
 206:	89 e5                	mov    %esp,%ebp
 208:	83 ec 04             	sub    $0x4,%esp
 20b:	8b 45 0c             	mov    0xc(%ebp),%eax
 20e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 211:	eb 14                	jmp    227 <strchr+0x22>
    if(*s == c)
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	0f b6 00             	movzbl (%eax),%eax
 219:	3a 45 fc             	cmp    -0x4(%ebp),%al
 21c:	75 05                	jne    223 <strchr+0x1e>
      return (char*)s;
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	eb 13                	jmp    236 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 223:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 227:	8b 45 08             	mov    0x8(%ebp),%eax
 22a:	0f b6 00             	movzbl (%eax),%eax
 22d:	84 c0                	test   %al,%al
 22f:	75 e2                	jne    213 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 231:	b8 00 00 00 00       	mov    $0x0,%eax
}
 236:	c9                   	leave  
 237:	c3                   	ret    

00000238 <gets>:

char*
gets(char *buf, int max)
{
 238:	55                   	push   %ebp
 239:	89 e5                	mov    %esp,%ebp
 23b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 245:	eb 46                	jmp    28d <gets+0x55>
    cc = read(0, &c, 1);
 247:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 24e:	00 
 24f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 252:	89 44 24 04          	mov    %eax,0x4(%esp)
 256:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 25d:	e8 ee 02 00 00       	call   550 <read>
 262:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 265:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 269:	7e 2f                	jle    29a <gets+0x62>
      break;
    buf[i++] = c;
 26b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26e:	8b 45 08             	mov    0x8(%ebp),%eax
 271:	01 c2                	add    %eax,%edx
 273:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 277:	88 02                	mov    %al,(%edx)
 279:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 27d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 281:	3c 0a                	cmp    $0xa,%al
 283:	74 16                	je     29b <gets+0x63>
 285:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 289:	3c 0d                	cmp    $0xd,%al
 28b:	74 0e                	je     29b <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 290:	83 c0 01             	add    $0x1,%eax
 293:	3b 45 0c             	cmp    0xc(%ebp),%eax
 296:	7c af                	jl     247 <gets+0xf>
 298:	eb 01                	jmp    29b <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 29a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 29b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	01 d0                	add    %edx,%eax
 2a3:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a9:	c9                   	leave  
 2aa:	c3                   	ret    

000002ab <stat>:

int
stat(char *n, struct stat *st)
{
 2ab:	55                   	push   %ebp
 2ac:	89 e5                	mov    %esp,%ebp
 2ae:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b8:	00 
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
 2bc:	89 04 24             	mov    %eax,(%esp)
 2bf:	e8 b4 02 00 00       	call   578 <open>
 2c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2cb:	79 07                	jns    2d4 <stat+0x29>
    return -1;
 2cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2d2:	eb 23                	jmp    2f7 <stat+0x4c>
  r = fstat(fd, st);
 2d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d7:	89 44 24 04          	mov    %eax,0x4(%esp)
 2db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2de:	89 04 24             	mov    %eax,(%esp)
 2e1:	e8 aa 02 00 00       	call   590 <fstat>
 2e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ec:	89 04 24             	mov    %eax,(%esp)
 2ef:	e8 6c 02 00 00       	call   560 <close>
  return r;
 2f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f7:	c9                   	leave  
 2f8:	c3                   	ret    

000002f9 <atoi>:

int
atoi(const char *s)
{
 2f9:	55                   	push   %ebp
 2fa:	89 e5                	mov    %esp,%ebp
 2fc:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 306:	eb 23                	jmp    32b <atoi+0x32>
    n = n*10 + *s++ - '0';
 308:	8b 55 fc             	mov    -0x4(%ebp),%edx
 30b:	89 d0                	mov    %edx,%eax
 30d:	c1 e0 02             	shl    $0x2,%eax
 310:	01 d0                	add    %edx,%eax
 312:	01 c0                	add    %eax,%eax
 314:	89 c2                	mov    %eax,%edx
 316:	8b 45 08             	mov    0x8(%ebp),%eax
 319:	0f b6 00             	movzbl (%eax),%eax
 31c:	0f be c0             	movsbl %al,%eax
 31f:	01 d0                	add    %edx,%eax
 321:	83 e8 30             	sub    $0x30,%eax
 324:	89 45 fc             	mov    %eax,-0x4(%ebp)
 327:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
 32e:	0f b6 00             	movzbl (%eax),%eax
 331:	3c 2f                	cmp    $0x2f,%al
 333:	7e 0a                	jle    33f <atoi+0x46>
 335:	8b 45 08             	mov    0x8(%ebp),%eax
 338:	0f b6 00             	movzbl (%eax),%eax
 33b:	3c 39                	cmp    $0x39,%al
 33d:	7e c9                	jle    308 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 33f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 342:	c9                   	leave  
 343:	c3                   	ret    

00000344 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 344:	55                   	push   %ebp
 345:	89 e5                	mov    %esp,%ebp
 347:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 34a:	8b 45 08             	mov    0x8(%ebp),%eax
 34d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 350:	8b 45 0c             	mov    0xc(%ebp),%eax
 353:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 356:	eb 13                	jmp    36b <memmove+0x27>
    *dst++ = *src++;
 358:	8b 45 f8             	mov    -0x8(%ebp),%eax
 35b:	0f b6 10             	movzbl (%eax),%edx
 35e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 361:	88 10                	mov    %dl,(%eax)
 363:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 367:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 36b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 36f:	0f 9f c0             	setg   %al
 372:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 376:	84 c0                	test   %al,%al
 378:	75 de                	jne    358 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 37a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37d:	c9                   	leave  
 37e:	c3                   	ret    

0000037f <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
 382:	83 ec 38             	sub    $0x38,%esp
 385:	8b 45 10             	mov    0x10(%ebp),%eax
 388:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 38b:	8b 45 14             	mov    0x14(%ebp),%eax
 38e:	8b 00                	mov    (%eax),%eax
 390:	89 45 f4             	mov    %eax,-0xc(%ebp)
 393:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 39a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 39e:	74 06                	je     3a6 <strtok+0x27>
 3a0:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 3a4:	75 5a                	jne    400 <strtok+0x81>
    return match;
 3a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 3a9:	eb 76                	jmp    421 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 3ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	01 d0                	add    %edx,%eax
 3b3:	0f b6 00             	movzbl (%eax),%eax
 3b6:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3b9:	74 06                	je     3c1 <strtok+0x42>
      {
	index++;
 3bb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3bf:	eb 40                	jmp    401 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 3c1:	8b 45 14             	mov    0x14(%ebp),%eax
 3c4:	8b 00                	mov    (%eax),%eax
 3c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3c9:	29 c2                	sub    %eax,%edx
 3cb:	8b 45 14             	mov    0x14(%ebp),%eax
 3ce:	8b 00                	mov    (%eax),%eax
 3d0:	89 c1                	mov    %eax,%ecx
 3d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d5:	01 c8                	add    %ecx,%eax
 3d7:	89 54 24 08          	mov    %edx,0x8(%esp)
 3db:	89 44 24 04          	mov    %eax,0x4(%esp)
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	89 04 24             	mov    %eax,(%esp)
 3e5:	e8 39 00 00 00       	call   423 <strncpy>
 3ea:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	0f b6 00             	movzbl (%eax),%eax
 3f3:	84 c0                	test   %al,%al
 3f5:	74 1b                	je     412 <strtok+0x93>
	  match = 1;
 3f7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 3fe:	eb 12                	jmp    412 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 400:	90                   	nop
 401:	8b 55 f4             	mov    -0xc(%ebp),%edx
 404:	8b 45 0c             	mov    0xc(%ebp),%eax
 407:	01 d0                	add    %edx,%eax
 409:	0f b6 00             	movzbl (%eax),%eax
 40c:	84 c0                	test   %al,%al
 40e:	75 9b                	jne    3ab <strtok+0x2c>
 410:	eb 01                	jmp    413 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 412:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 413:	8b 45 f4             	mov    -0xc(%ebp),%eax
 416:	8d 50 01             	lea    0x1(%eax),%edx
 419:	8b 45 14             	mov    0x14(%ebp),%eax
 41c:	89 10                	mov    %edx,(%eax)
  return match;
 41e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 421:	c9                   	leave  
 422:	c3                   	ret    

00000423 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 423:	55                   	push   %ebp
 424:	89 e5                	mov    %esp,%ebp
 426:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 429:	8b 45 08             	mov    0x8(%ebp),%eax
 42c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 42f:	90                   	nop
 430:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 434:	0f 9f c0             	setg   %al
 437:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 43b:	84 c0                	test   %al,%al
 43d:	74 30                	je     46f <strncpy+0x4c>
 43f:	8b 45 0c             	mov    0xc(%ebp),%eax
 442:	0f b6 10             	movzbl (%eax),%edx
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	88 10                	mov    %dl,(%eax)
 44a:	8b 45 08             	mov    0x8(%ebp),%eax
 44d:	0f b6 00             	movzbl (%eax),%eax
 450:	84 c0                	test   %al,%al
 452:	0f 95 c0             	setne  %al
 455:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 459:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 45d:	84 c0                	test   %al,%al
 45f:	75 cf                	jne    430 <strncpy+0xd>
    ;
  while(n-- > 0)
 461:	eb 0c                	jmp    46f <strncpy+0x4c>
    *s++ = 0;
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	c6 00 00             	movb   $0x0,(%eax)
 469:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 46d:	eb 01                	jmp    470 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 46f:	90                   	nop
 470:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 474:	0f 9f c0             	setg   %al
 477:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 47b:	84 c0                	test   %al,%al
 47d:	75 e4                	jne    463 <strncpy+0x40>
    *s++ = 0;
  return os;
 47f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 482:	c9                   	leave  
 483:	c3                   	ret    

00000484 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 484:	55                   	push   %ebp
 485:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 487:	eb 0c                	jmp    495 <strncmp+0x11>
    n--, p++, q++;
 489:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 48d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 491:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 495:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 499:	74 1a                	je     4b5 <strncmp+0x31>
 49b:	8b 45 08             	mov    0x8(%ebp),%eax
 49e:	0f b6 00             	movzbl (%eax),%eax
 4a1:	84 c0                	test   %al,%al
 4a3:	74 10                	je     4b5 <strncmp+0x31>
 4a5:	8b 45 08             	mov    0x8(%ebp),%eax
 4a8:	0f b6 10             	movzbl (%eax),%edx
 4ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	38 c2                	cmp    %al,%dl
 4b3:	74 d4                	je     489 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 4b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4b9:	75 07                	jne    4c2 <strncmp+0x3e>
    return 0;
 4bb:	b8 00 00 00 00       	mov    $0x0,%eax
 4c0:	eb 18                	jmp    4da <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	0f b6 00             	movzbl (%eax),%eax
 4c8:	0f b6 d0             	movzbl %al,%edx
 4cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ce:	0f b6 00             	movzbl (%eax),%eax
 4d1:	0f b6 c0             	movzbl %al,%eax
 4d4:	89 d1                	mov    %edx,%ecx
 4d6:	29 c1                	sub    %eax,%ecx
 4d8:	89 c8                	mov    %ecx,%eax
}
 4da:	5d                   	pop    %ebp
 4db:	c3                   	ret    

000004dc <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 4dc:	55                   	push   %ebp
 4dd:	89 e5                	mov    %esp,%ebp
  while(*p){
 4df:	eb 13                	jmp    4f4 <strcat+0x18>
    *dest++ = *p++;
 4e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e4:	0f b6 10             	movzbl (%eax),%edx
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	88 10                	mov    %dl,(%eax)
 4ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4f0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 4f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f7:	0f b6 00             	movzbl (%eax),%eax
 4fa:	84 c0                	test   %al,%al
 4fc:	75 e3                	jne    4e1 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 4fe:	eb 13                	jmp    513 <strcat+0x37>
    *dest++ = *q++;
 500:	8b 45 10             	mov    0x10(%ebp),%eax
 503:	0f b6 10             	movzbl (%eax),%edx
 506:	8b 45 08             	mov    0x8(%ebp),%eax
 509:	88 10                	mov    %dl,(%eax)
 50b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 50f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 513:	8b 45 10             	mov    0x10(%ebp),%eax
 516:	0f b6 00             	movzbl (%eax),%eax
 519:	84 c0                	test   %al,%al
 51b:	75 e3                	jne    500 <strcat+0x24>
    *dest++ = *q++;
  }  
 51d:	5d                   	pop    %ebp
 51e:	c3                   	ret    
 51f:	90                   	nop

00000520 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 520:	b8 01 00 00 00       	mov    $0x1,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <exit>:
SYSCALL(exit)
 528:	b8 02 00 00 00       	mov    $0x2,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <wait>:
SYSCALL(wait)
 530:	b8 03 00 00 00       	mov    $0x3,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <wait2>:
SYSCALL(wait2)
 538:	b8 16 00 00 00       	mov    $0x16,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <nice>:
SYSCALL(nice)
 540:	b8 17 00 00 00       	mov    $0x17,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <pipe>:
SYSCALL(pipe)
 548:	b8 04 00 00 00       	mov    $0x4,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <read>:
SYSCALL(read)
 550:	b8 05 00 00 00       	mov    $0x5,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <write>:
SYSCALL(write)
 558:	b8 10 00 00 00       	mov    $0x10,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <close>:
SYSCALL(close)
 560:	b8 15 00 00 00       	mov    $0x15,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <kill>:
SYSCALL(kill)
 568:	b8 06 00 00 00       	mov    $0x6,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <exec>:
SYSCALL(exec)
 570:	b8 07 00 00 00       	mov    $0x7,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <open>:
SYSCALL(open)
 578:	b8 0f 00 00 00       	mov    $0xf,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <mknod>:
SYSCALL(mknod)
 580:	b8 11 00 00 00       	mov    $0x11,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <unlink>:
SYSCALL(unlink)
 588:	b8 12 00 00 00       	mov    $0x12,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <fstat>:
SYSCALL(fstat)
 590:	b8 08 00 00 00       	mov    $0x8,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <link>:
SYSCALL(link)
 598:	b8 13 00 00 00       	mov    $0x13,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <mkdir>:
SYSCALL(mkdir)
 5a0:	b8 14 00 00 00       	mov    $0x14,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <chdir>:
SYSCALL(chdir)
 5a8:	b8 09 00 00 00       	mov    $0x9,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <dup>:
SYSCALL(dup)
 5b0:	b8 0a 00 00 00       	mov    $0xa,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <getpid>:
SYSCALL(getpid)
 5b8:	b8 0b 00 00 00       	mov    $0xb,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <sbrk>:
SYSCALL(sbrk)
 5c0:	b8 0c 00 00 00       	mov    $0xc,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <sleep>:
SYSCALL(sleep)
 5c8:	b8 0d 00 00 00       	mov    $0xd,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <uptime>:
SYSCALL(uptime)
 5d0:	b8 0e 00 00 00       	mov    $0xe,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5d8:	55                   	push   %ebp
 5d9:	89 e5                	mov    %esp,%ebp
 5db:	83 ec 28             	sub    $0x28,%esp
 5de:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5e4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5eb:	00 
 5ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f3:	8b 45 08             	mov    0x8(%ebp),%eax
 5f6:	89 04 24             	mov    %eax,(%esp)
 5f9:	e8 5a ff ff ff       	call   558 <write>
}
 5fe:	c9                   	leave  
 5ff:	c3                   	ret    

00000600 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 600:	55                   	push   %ebp
 601:	89 e5                	mov    %esp,%ebp
 603:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 606:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 60d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 611:	74 17                	je     62a <printint+0x2a>
 613:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 617:	79 11                	jns    62a <printint+0x2a>
    neg = 1;
 619:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 620:	8b 45 0c             	mov    0xc(%ebp),%eax
 623:	f7 d8                	neg    %eax
 625:	89 45 ec             	mov    %eax,-0x14(%ebp)
 628:	eb 06                	jmp    630 <printint+0x30>
  } else {
    x = xx;
 62a:	8b 45 0c             	mov    0xc(%ebp),%eax
 62d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 630:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 637:	8b 4d 10             	mov    0x10(%ebp),%ecx
 63a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 63d:	ba 00 00 00 00       	mov    $0x0,%edx
 642:	f7 f1                	div    %ecx
 644:	89 d0                	mov    %edx,%eax
 646:	0f b6 80 90 0d 00 00 	movzbl 0xd90(%eax),%eax
 64d:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 650:	8b 55 f4             	mov    -0xc(%ebp),%edx
 653:	01 ca                	add    %ecx,%edx
 655:	88 02                	mov    %al,(%edx)
 657:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 65b:	8b 55 10             	mov    0x10(%ebp),%edx
 65e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 661:	8b 45 ec             	mov    -0x14(%ebp),%eax
 664:	ba 00 00 00 00       	mov    $0x0,%edx
 669:	f7 75 d4             	divl   -0x2c(%ebp)
 66c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 66f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 673:	75 c2                	jne    637 <printint+0x37>
  if(neg)
 675:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 679:	74 2e                	je     6a9 <printint+0xa9>
    buf[i++] = '-';
 67b:	8d 55 dc             	lea    -0x24(%ebp),%edx
 67e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 681:	01 d0                	add    %edx,%eax
 683:	c6 00 2d             	movb   $0x2d,(%eax)
 686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 68a:	eb 1d                	jmp    6a9 <printint+0xa9>
    putc(fd, buf[i]);
 68c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 68f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 692:	01 d0                	add    %edx,%eax
 694:	0f b6 00             	movzbl (%eax),%eax
 697:	0f be c0             	movsbl %al,%eax
 69a:	89 44 24 04          	mov    %eax,0x4(%esp)
 69e:	8b 45 08             	mov    0x8(%ebp),%eax
 6a1:	89 04 24             	mov    %eax,(%esp)
 6a4:	e8 2f ff ff ff       	call   5d8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6a9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b1:	79 d9                	jns    68c <printint+0x8c>
    putc(fd, buf[i]);
}
 6b3:	c9                   	leave  
 6b4:	c3                   	ret    

000006b5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6b5:	55                   	push   %ebp
 6b6:	89 e5                	mov    %esp,%ebp
 6b8:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6c2:	8d 45 0c             	lea    0xc(%ebp),%eax
 6c5:	83 c0 04             	add    $0x4,%eax
 6c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6d2:	e9 7d 01 00 00       	jmp    854 <printf+0x19f>
    c = fmt[i] & 0xff;
 6d7:	8b 55 0c             	mov    0xc(%ebp),%edx
 6da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6dd:	01 d0                	add    %edx,%eax
 6df:	0f b6 00             	movzbl (%eax),%eax
 6e2:	0f be c0             	movsbl %al,%eax
 6e5:	25 ff 00 00 00       	and    $0xff,%eax
 6ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6f1:	75 2c                	jne    71f <printf+0x6a>
      if(c == '%'){
 6f3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6f7:	75 0c                	jne    705 <printf+0x50>
        state = '%';
 6f9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 700:	e9 4b 01 00 00       	jmp    850 <printf+0x19b>
      } else {
        putc(fd, c);
 705:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 708:	0f be c0             	movsbl %al,%eax
 70b:	89 44 24 04          	mov    %eax,0x4(%esp)
 70f:	8b 45 08             	mov    0x8(%ebp),%eax
 712:	89 04 24             	mov    %eax,(%esp)
 715:	e8 be fe ff ff       	call   5d8 <putc>
 71a:	e9 31 01 00 00       	jmp    850 <printf+0x19b>
      }
    } else if(state == '%'){
 71f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 723:	0f 85 27 01 00 00    	jne    850 <printf+0x19b>
      if(c == 'd'){
 729:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 72d:	75 2d                	jne    75c <printf+0xa7>
        printint(fd, *ap, 10, 1);
 72f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 732:	8b 00                	mov    (%eax),%eax
 734:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 73b:	00 
 73c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 743:	00 
 744:	89 44 24 04          	mov    %eax,0x4(%esp)
 748:	8b 45 08             	mov    0x8(%ebp),%eax
 74b:	89 04 24             	mov    %eax,(%esp)
 74e:	e8 ad fe ff ff       	call   600 <printint>
        ap++;
 753:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 757:	e9 ed 00 00 00       	jmp    849 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 75c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 760:	74 06                	je     768 <printf+0xb3>
 762:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 766:	75 2d                	jne    795 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 768:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76b:	8b 00                	mov    (%eax),%eax
 76d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 774:	00 
 775:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 77c:	00 
 77d:	89 44 24 04          	mov    %eax,0x4(%esp)
 781:	8b 45 08             	mov    0x8(%ebp),%eax
 784:	89 04 24             	mov    %eax,(%esp)
 787:	e8 74 fe ff ff       	call   600 <printint>
        ap++;
 78c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 790:	e9 b4 00 00 00       	jmp    849 <printf+0x194>
      } else if(c == 's'){
 795:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 799:	75 46                	jne    7e1 <printf+0x12c>
        s = (char*)*ap;
 79b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 79e:	8b 00                	mov    (%eax),%eax
 7a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ab:	75 27                	jne    7d4 <printf+0x11f>
          s = "(null)";
 7ad:	c7 45 f4 ab 0a 00 00 	movl   $0xaab,-0xc(%ebp)
        while(*s != 0){
 7b4:	eb 1e                	jmp    7d4 <printf+0x11f>
          putc(fd, *s);
 7b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b9:	0f b6 00             	movzbl (%eax),%eax
 7bc:	0f be c0             	movsbl %al,%eax
 7bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c3:	8b 45 08             	mov    0x8(%ebp),%eax
 7c6:	89 04 24             	mov    %eax,(%esp)
 7c9:	e8 0a fe ff ff       	call   5d8 <putc>
          s++;
 7ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7d2:	eb 01                	jmp    7d5 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7d4:	90                   	nop
 7d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d8:	0f b6 00             	movzbl (%eax),%eax
 7db:	84 c0                	test   %al,%al
 7dd:	75 d7                	jne    7b6 <printf+0x101>
 7df:	eb 68                	jmp    849 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7e1:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7e5:	75 1d                	jne    804 <printf+0x14f>
        putc(fd, *ap);
 7e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ea:	8b 00                	mov    (%eax),%eax
 7ec:	0f be c0             	movsbl %al,%eax
 7ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f3:	8b 45 08             	mov    0x8(%ebp),%eax
 7f6:	89 04 24             	mov    %eax,(%esp)
 7f9:	e8 da fd ff ff       	call   5d8 <putc>
        ap++;
 7fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 802:	eb 45                	jmp    849 <printf+0x194>
      } else if(c == '%'){
 804:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 808:	75 17                	jne    821 <printf+0x16c>
        putc(fd, c);
 80a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 80d:	0f be c0             	movsbl %al,%eax
 810:	89 44 24 04          	mov    %eax,0x4(%esp)
 814:	8b 45 08             	mov    0x8(%ebp),%eax
 817:	89 04 24             	mov    %eax,(%esp)
 81a:	e8 b9 fd ff ff       	call   5d8 <putc>
 81f:	eb 28                	jmp    849 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 821:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 828:	00 
 829:	8b 45 08             	mov    0x8(%ebp),%eax
 82c:	89 04 24             	mov    %eax,(%esp)
 82f:	e8 a4 fd ff ff       	call   5d8 <putc>
        putc(fd, c);
 834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 837:	0f be c0             	movsbl %al,%eax
 83a:	89 44 24 04          	mov    %eax,0x4(%esp)
 83e:	8b 45 08             	mov    0x8(%ebp),%eax
 841:	89 04 24             	mov    %eax,(%esp)
 844:	e8 8f fd ff ff       	call   5d8 <putc>
      }
      state = 0;
 849:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 850:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 854:	8b 55 0c             	mov    0xc(%ebp),%edx
 857:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85a:	01 d0                	add    %edx,%eax
 85c:	0f b6 00             	movzbl (%eax),%eax
 85f:	84 c0                	test   %al,%al
 861:	0f 85 70 fe ff ff    	jne    6d7 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 867:	c9                   	leave  
 868:	c3                   	ret    
 869:	66 90                	xchg   %ax,%ax
 86b:	90                   	nop

0000086c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 86c:	55                   	push   %ebp
 86d:	89 e5                	mov    %esp,%ebp
 86f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 872:	8b 45 08             	mov    0x8(%ebp),%eax
 875:	83 e8 08             	sub    $0x8,%eax
 878:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87b:	a1 c8 0d 00 00       	mov    0xdc8,%eax
 880:	89 45 fc             	mov    %eax,-0x4(%ebp)
 883:	eb 24                	jmp    8a9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	8b 00                	mov    (%eax),%eax
 88a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 88d:	77 12                	ja     8a1 <free+0x35>
 88f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 892:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 895:	77 24                	ja     8bb <free+0x4f>
 897:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89a:	8b 00                	mov    (%eax),%eax
 89c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 89f:	77 1a                	ja     8bb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	8b 00                	mov    (%eax),%eax
 8a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ac:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8af:	76 d4                	jbe    885 <free+0x19>
 8b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b4:	8b 00                	mov    (%eax),%eax
 8b6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b9:	76 ca                	jbe    885 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8be:	8b 40 04             	mov    0x4(%eax),%eax
 8c1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cb:	01 c2                	add    %eax,%edx
 8cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d0:	8b 00                	mov    (%eax),%eax
 8d2:	39 c2                	cmp    %eax,%edx
 8d4:	75 24                	jne    8fa <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d9:	8b 50 04             	mov    0x4(%eax),%edx
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 00                	mov    (%eax),%eax
 8e1:	8b 40 04             	mov    0x4(%eax),%eax
 8e4:	01 c2                	add    %eax,%edx
 8e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ef:	8b 00                	mov    (%eax),%eax
 8f1:	8b 10                	mov    (%eax),%edx
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	89 10                	mov    %edx,(%eax)
 8f8:	eb 0a                	jmp    904 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fd:	8b 10                	mov    (%eax),%edx
 8ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 902:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 904:	8b 45 fc             	mov    -0x4(%ebp),%eax
 907:	8b 40 04             	mov    0x4(%eax),%eax
 90a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 911:	8b 45 fc             	mov    -0x4(%ebp),%eax
 914:	01 d0                	add    %edx,%eax
 916:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 919:	75 20                	jne    93b <free+0xcf>
    p->s.size += bp->s.size;
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	8b 50 04             	mov    0x4(%eax),%edx
 921:	8b 45 f8             	mov    -0x8(%ebp),%eax
 924:	8b 40 04             	mov    0x4(%eax),%eax
 927:	01 c2                	add    %eax,%edx
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	8b 10                	mov    (%eax),%edx
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	89 10                	mov    %edx,(%eax)
 939:	eb 08                	jmp    943 <free+0xd7>
  } else
    p->s.ptr = bp;
 93b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 941:	89 10                	mov    %edx,(%eax)
  freep = p;
 943:	8b 45 fc             	mov    -0x4(%ebp),%eax
 946:	a3 c8 0d 00 00       	mov    %eax,0xdc8
}
 94b:	c9                   	leave  
 94c:	c3                   	ret    

0000094d <morecore>:

static Header*
morecore(uint nu)
{
 94d:	55                   	push   %ebp
 94e:	89 e5                	mov    %esp,%ebp
 950:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 953:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 95a:	77 07                	ja     963 <morecore+0x16>
    nu = 4096;
 95c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 963:	8b 45 08             	mov    0x8(%ebp),%eax
 966:	c1 e0 03             	shl    $0x3,%eax
 969:	89 04 24             	mov    %eax,(%esp)
 96c:	e8 4f fc ff ff       	call   5c0 <sbrk>
 971:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 974:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 978:	75 07                	jne    981 <morecore+0x34>
    return 0;
 97a:	b8 00 00 00 00       	mov    $0x0,%eax
 97f:	eb 22                	jmp    9a3 <morecore+0x56>
  hp = (Header*)p;
 981:	8b 45 f4             	mov    -0xc(%ebp),%eax
 984:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 987:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98a:	8b 55 08             	mov    0x8(%ebp),%edx
 98d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 990:	8b 45 f0             	mov    -0x10(%ebp),%eax
 993:	83 c0 08             	add    $0x8,%eax
 996:	89 04 24             	mov    %eax,(%esp)
 999:	e8 ce fe ff ff       	call   86c <free>
  return freep;
 99e:	a1 c8 0d 00 00       	mov    0xdc8,%eax
}
 9a3:	c9                   	leave  
 9a4:	c3                   	ret    

000009a5 <malloc>:

void*
malloc(uint nbytes)
{
 9a5:	55                   	push   %ebp
 9a6:	89 e5                	mov    %esp,%ebp
 9a8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ab:	8b 45 08             	mov    0x8(%ebp),%eax
 9ae:	83 c0 07             	add    $0x7,%eax
 9b1:	c1 e8 03             	shr    $0x3,%eax
 9b4:	83 c0 01             	add    $0x1,%eax
 9b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9ba:	a1 c8 0d 00 00       	mov    0xdc8,%eax
 9bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9c6:	75 23                	jne    9eb <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9c8:	c7 45 f0 c0 0d 00 00 	movl   $0xdc0,-0x10(%ebp)
 9cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d2:	a3 c8 0d 00 00       	mov    %eax,0xdc8
 9d7:	a1 c8 0d 00 00       	mov    0xdc8,%eax
 9dc:	a3 c0 0d 00 00       	mov    %eax,0xdc0
    base.s.size = 0;
 9e1:	c7 05 c4 0d 00 00 00 	movl   $0x0,0xdc4
 9e8:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ee:	8b 00                	mov    (%eax),%eax
 9f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f6:	8b 40 04             	mov    0x4(%eax),%eax
 9f9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9fc:	72 4d                	jb     a4b <malloc+0xa6>
      if(p->s.size == nunits)
 9fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a01:	8b 40 04             	mov    0x4(%eax),%eax
 a04:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a07:	75 0c                	jne    a15 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0c:	8b 10                	mov    (%eax),%edx
 a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a11:	89 10                	mov    %edx,(%eax)
 a13:	eb 26                	jmp    a3b <malloc+0x96>
      else {
        p->s.size -= nunits;
 a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a18:	8b 40 04             	mov    0x4(%eax),%eax
 a1b:	89 c2                	mov    %eax,%edx
 a1d:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a23:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a29:	8b 40 04             	mov    0x4(%eax),%eax
 a2c:	c1 e0 03             	shl    $0x3,%eax
 a2f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a35:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a38:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3e:	a3 c8 0d 00 00       	mov    %eax,0xdc8
      return (void*)(p + 1);
 a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a46:	83 c0 08             	add    $0x8,%eax
 a49:	eb 38                	jmp    a83 <malloc+0xde>
    }
    if(p == freep)
 a4b:	a1 c8 0d 00 00       	mov    0xdc8,%eax
 a50:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a53:	75 1b                	jne    a70 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a55:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a58:	89 04 24             	mov    %eax,(%esp)
 a5b:	e8 ed fe ff ff       	call   94d <morecore>
 a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a67:	75 07                	jne    a70 <malloc+0xcb>
        return 0;
 a69:	b8 00 00 00 00       	mov    $0x0,%eax
 a6e:	eb 13                	jmp    a83 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a79:	8b 00                	mov    (%eax),%eax
 a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a7e:	e9 70 ff ff ff       	jmp    9f3 <malloc+0x4e>
}
 a83:	c9                   	leave  
 a84:	c3                   	ret    
