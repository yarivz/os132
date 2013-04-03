
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 1){
   9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "usage: kill pid...\n");
   f:	c7 44 24 04 a3 09 00 	movl   $0x9a3,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 bc 05 00 00       	call   5df <printf>
    exit();
  23:	e8 38 04 00 00       	call   460 <exit>
  }
  for(i=1; i<argc; i++)
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 21                	jmp    53 <main+0x53>
    kill(atoi(argv[i]));
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	c1 e0 02             	shl    $0x2,%eax
  39:	03 45 0c             	add    0xc(%ebp),%eax
  3c:	8b 00                	mov    (%eax),%eax
  3e:	89 04 24             	mov    %eax,(%esp)
  41:	e8 f1 01 00 00       	call   237 <atoi>
  46:	89 04 24             	mov    %eax,(%esp)
  49:	e8 4a 04 00 00       	call   498 <kill>

  if(argc < 1){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  4e:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  53:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  57:	3b 45 08             	cmp    0x8(%ebp),%eax
  5a:	7c d6                	jl     32 <main+0x32>
    kill(atoi(argv[i]));
  exit();
  5c:	e8 ff 03 00 00       	call   460 <exit>
  61:	90                   	nop
  62:	90                   	nop
  63:	90                   	nop

00000064 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  64:	55                   	push   %ebp
  65:	89 e5                	mov    %esp,%ebp
  67:	57                   	push   %edi
  68:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6c:	8b 55 10             	mov    0x10(%ebp),%edx
  6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  72:	89 cb                	mov    %ecx,%ebx
  74:	89 df                	mov    %ebx,%edi
  76:	89 d1                	mov    %edx,%ecx
  78:	fc                   	cld    
  79:	f3 aa                	rep stos %al,%es:(%edi)
  7b:	89 ca                	mov    %ecx,%edx
  7d:	89 fb                	mov    %edi,%ebx
  7f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  82:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  85:	5b                   	pop    %ebx
  86:	5f                   	pop    %edi
  87:	5d                   	pop    %ebp
  88:	c3                   	ret    

00000089 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  89:	55                   	push   %ebp
  8a:	89 e5                	mov    %esp,%ebp
  8c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  8f:	8b 45 08             	mov    0x8(%ebp),%eax
  92:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  95:	90                   	nop
  96:	8b 45 0c             	mov    0xc(%ebp),%eax
  99:	0f b6 10             	movzbl (%eax),%edx
  9c:	8b 45 08             	mov    0x8(%ebp),%eax
  9f:	88 10                	mov    %dl,(%eax)
  a1:	8b 45 08             	mov    0x8(%ebp),%eax
  a4:	0f b6 00             	movzbl (%eax),%eax
  a7:	84 c0                	test   %al,%al
  a9:	0f 95 c0             	setne  %al
  ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  b4:	84 c0                	test   %al,%al
  b6:	75 de                	jne    96 <strcpy+0xd>
    ;
  return os;
  b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  bb:	c9                   	leave  
  bc:	c3                   	ret    

000000bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bd:	55                   	push   %ebp
  be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  c0:	eb 08                	jmp    ca <strcmp+0xd>
    p++, q++;
  c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	0f b6 00             	movzbl (%eax),%eax
  d0:	84 c0                	test   %al,%al
  d2:	74 10                	je     e4 <strcmp+0x27>
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 10             	movzbl (%eax),%edx
  da:	8b 45 0c             	mov    0xc(%ebp),%eax
  dd:	0f b6 00             	movzbl (%eax),%eax
  e0:	38 c2                	cmp    %al,%dl
  e2:	74 de                	je     c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e4:	8b 45 08             	mov    0x8(%ebp),%eax
  e7:	0f b6 00             	movzbl (%eax),%eax
  ea:	0f b6 d0             	movzbl %al,%edx
  ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  f0:	0f b6 00             	movzbl (%eax),%eax
  f3:	0f b6 c0             	movzbl %al,%eax
  f6:	89 d1                	mov    %edx,%ecx
  f8:	29 c1                	sub    %eax,%ecx
  fa:	89 c8                	mov    %ecx,%eax
}
  fc:	5d                   	pop    %ebp
  fd:	c3                   	ret    

000000fe <strlen>:

uint
strlen(char *s)
{
  fe:	55                   	push   %ebp
  ff:	89 e5                	mov    %esp,%ebp
 101:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 104:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 10b:	eb 04                	jmp    111 <strlen+0x13>
 10d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 111:	8b 45 fc             	mov    -0x4(%ebp),%eax
 114:	03 45 08             	add    0x8(%ebp),%eax
 117:	0f b6 00             	movzbl (%eax),%eax
 11a:	84 c0                	test   %al,%al
 11c:	75 ef                	jne    10d <strlen+0xf>
  return n;
 11e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 121:	c9                   	leave  
 122:	c3                   	ret    

00000123 <memset>:

void*
memset(void *dst, int c, uint n)
{
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
 126:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 129:	8b 45 10             	mov    0x10(%ebp),%eax
 12c:	89 44 24 08          	mov    %eax,0x8(%esp)
 130:	8b 45 0c             	mov    0xc(%ebp),%eax
 133:	89 44 24 04          	mov    %eax,0x4(%esp)
 137:	8b 45 08             	mov    0x8(%ebp),%eax
 13a:	89 04 24             	mov    %eax,(%esp)
 13d:	e8 22 ff ff ff       	call   64 <stosb>
  return dst;
 142:	8b 45 08             	mov    0x8(%ebp),%eax
}
 145:	c9                   	leave  
 146:	c3                   	ret    

00000147 <strchr>:

char*
strchr(const char *s, char c)
{
 147:	55                   	push   %ebp
 148:	89 e5                	mov    %esp,%ebp
 14a:	83 ec 04             	sub    $0x4,%esp
 14d:	8b 45 0c             	mov    0xc(%ebp),%eax
 150:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 153:	eb 14                	jmp    169 <strchr+0x22>
    if(*s == c)
 155:	8b 45 08             	mov    0x8(%ebp),%eax
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 15e:	75 05                	jne    165 <strchr+0x1e>
      return (char*)s;
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	eb 13                	jmp    178 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 165:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 169:	8b 45 08             	mov    0x8(%ebp),%eax
 16c:	0f b6 00             	movzbl (%eax),%eax
 16f:	84 c0                	test   %al,%al
 171:	75 e2                	jne    155 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 173:	b8 00 00 00 00       	mov    $0x0,%eax
}
 178:	c9                   	leave  
 179:	c3                   	ret    

0000017a <gets>:

char*
gets(char *buf, int max)
{
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 180:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 187:	eb 44                	jmp    1cd <gets+0x53>
    cc = read(0, &c, 1);
 189:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 190:	00 
 191:	8d 45 ef             	lea    -0x11(%ebp),%eax
 194:	89 44 24 04          	mov    %eax,0x4(%esp)
 198:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 19f:	e8 dc 02 00 00       	call   480 <read>
 1a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ab:	7e 2d                	jle    1da <gets+0x60>
      break;
    buf[i++] = c;
 1ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b0:	03 45 08             	add    0x8(%ebp),%eax
 1b3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1b7:	88 10                	mov    %dl,(%eax)
 1b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c1:	3c 0a                	cmp    $0xa,%al
 1c3:	74 16                	je     1db <gets+0x61>
 1c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c9:	3c 0d                	cmp    $0xd,%al
 1cb:	74 0e                	je     1db <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d0:	83 c0 01             	add    $0x1,%eax
 1d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1d6:	7c b1                	jl     189 <gets+0xf>
 1d8:	eb 01                	jmp    1db <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1da:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1de:	03 45 08             	add    0x8(%ebp),%eax
 1e1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e7:	c9                   	leave  
 1e8:	c3                   	ret    

000001e9 <stat>:

int
stat(char *n, struct stat *st)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1f6:	00 
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
 1fa:	89 04 24             	mov    %eax,(%esp)
 1fd:	e8 a6 02 00 00       	call   4a8 <open>
 202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 209:	79 07                	jns    212 <stat+0x29>
    return -1;
 20b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 210:	eb 23                	jmp    235 <stat+0x4c>
  r = fstat(fd, st);
 212:	8b 45 0c             	mov    0xc(%ebp),%eax
 215:	89 44 24 04          	mov    %eax,0x4(%esp)
 219:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21c:	89 04 24             	mov    %eax,(%esp)
 21f:	e8 9c 02 00 00       	call   4c0 <fstat>
 224:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 227:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22a:	89 04 24             	mov    %eax,(%esp)
 22d:	e8 5e 02 00 00       	call   490 <close>
  return r;
 232:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 235:	c9                   	leave  
 236:	c3                   	ret    

00000237 <atoi>:

int
atoi(const char *s)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 23d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 244:	eb 23                	jmp    269 <atoi+0x32>
    n = n*10 + *s++ - '0';
 246:	8b 55 fc             	mov    -0x4(%ebp),%edx
 249:	89 d0                	mov    %edx,%eax
 24b:	c1 e0 02             	shl    $0x2,%eax
 24e:	01 d0                	add    %edx,%eax
 250:	01 c0                	add    %eax,%eax
 252:	89 c2                	mov    %eax,%edx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	0f b6 00             	movzbl (%eax),%eax
 25a:	0f be c0             	movsbl %al,%eax
 25d:	01 d0                	add    %edx,%eax
 25f:	83 e8 30             	sub    $0x30,%eax
 262:	89 45 fc             	mov    %eax,-0x4(%ebp)
 265:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	0f b6 00             	movzbl (%eax),%eax
 26f:	3c 2f                	cmp    $0x2f,%al
 271:	7e 0a                	jle    27d <atoi+0x46>
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	0f b6 00             	movzbl (%eax),%eax
 279:	3c 39                	cmp    $0x39,%al
 27b:	7e c9                	jle    246 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 27d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 280:	c9                   	leave  
 281:	c3                   	ret    

00000282 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 282:	55                   	push   %ebp
 283:	89 e5                	mov    %esp,%ebp
 285:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 28e:	8b 45 0c             	mov    0xc(%ebp),%eax
 291:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 294:	eb 13                	jmp    2a9 <memmove+0x27>
    *dst++ = *src++;
 296:	8b 45 f8             	mov    -0x8(%ebp),%eax
 299:	0f b6 10             	movzbl (%eax),%edx
 29c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 29f:	88 10                	mov    %dl,(%eax)
 2a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2a5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2ad:	0f 9f c0             	setg   %al
 2b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2b4:	84 c0                	test   %al,%al
 2b6:	75 de                	jne    296 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bb:	c9                   	leave  
 2bc:	c3                   	ret    

000002bd <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 2bd:	55                   	push   %ebp
 2be:	89 e5                	mov    %esp,%ebp
 2c0:	83 ec 38             	sub    $0x38,%esp
 2c3:	8b 45 10             	mov    0x10(%ebp),%eax
 2c6:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 2c9:	8b 45 14             	mov    0x14(%ebp),%eax
 2cc:	8b 00                	mov    (%eax),%eax
 2ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 2d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2dc:	74 06                	je     2e4 <strtok+0x27>
 2de:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 2e2:	75 54                	jne    338 <strtok+0x7b>
    return match;
 2e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2e7:	eb 6e                	jmp    357 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 2e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ec:	03 45 0c             	add    0xc(%ebp),%eax
 2ef:	0f b6 00             	movzbl (%eax),%eax
 2f2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 2f5:	74 06                	je     2fd <strtok+0x40>
      {
	index++;
 2f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2fb:	eb 3c                	jmp    339 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 2fd:	8b 45 14             	mov    0x14(%ebp),%eax
 300:	8b 00                	mov    (%eax),%eax
 302:	8b 55 f4             	mov    -0xc(%ebp),%edx
 305:	29 c2                	sub    %eax,%edx
 307:	8b 45 14             	mov    0x14(%ebp),%eax
 30a:	8b 00                	mov    (%eax),%eax
 30c:	03 45 0c             	add    0xc(%ebp),%eax
 30f:	89 54 24 08          	mov    %edx,0x8(%esp)
 313:	89 44 24 04          	mov    %eax,0x4(%esp)
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	89 04 24             	mov    %eax,(%esp)
 31d:	e8 37 00 00 00       	call   359 <strncpy>
 322:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	0f b6 00             	movzbl (%eax),%eax
 32b:	84 c0                	test   %al,%al
 32d:	74 19                	je     348 <strtok+0x8b>
	  match = 1;
 32f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 336:	eb 10                	jmp    348 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 338:	90                   	nop
 339:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33c:	03 45 0c             	add    0xc(%ebp),%eax
 33f:	0f b6 00             	movzbl (%eax),%eax
 342:	84 c0                	test   %al,%al
 344:	75 a3                	jne    2e9 <strtok+0x2c>
 346:	eb 01                	jmp    349 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 348:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 349:	8b 45 f4             	mov    -0xc(%ebp),%eax
 34c:	8d 50 01             	lea    0x1(%eax),%edx
 34f:	8b 45 14             	mov    0x14(%ebp),%eax
 352:	89 10                	mov    %edx,(%eax)
  return match;
 354:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 357:	c9                   	leave  
 358:	c3                   	ret    

00000359 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp
 35c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 35f:	8b 45 08             	mov    0x8(%ebp),%eax
 362:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 365:	90                   	nop
 366:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 36a:	0f 9f c0             	setg   %al
 36d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 371:	84 c0                	test   %al,%al
 373:	74 30                	je     3a5 <strncpy+0x4c>
 375:	8b 45 0c             	mov    0xc(%ebp),%eax
 378:	0f b6 10             	movzbl (%eax),%edx
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	88 10                	mov    %dl,(%eax)
 380:	8b 45 08             	mov    0x8(%ebp),%eax
 383:	0f b6 00             	movzbl (%eax),%eax
 386:	84 c0                	test   %al,%al
 388:	0f 95 c0             	setne  %al
 38b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 38f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 393:	84 c0                	test   %al,%al
 395:	75 cf                	jne    366 <strncpy+0xd>
    ;
  while(n-- > 0)
 397:	eb 0c                	jmp    3a5 <strncpy+0x4c>
    *s++ = 0;
 399:	8b 45 08             	mov    0x8(%ebp),%eax
 39c:	c6 00 00             	movb   $0x0,(%eax)
 39f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a3:	eb 01                	jmp    3a6 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3a5:	90                   	nop
 3a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3aa:	0f 9f c0             	setg   %al
 3ad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3b1:	84 c0                	test   %al,%al
 3b3:	75 e4                	jne    399 <strncpy+0x40>
    *s++ = 0;
  return os;
 3b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b8:	c9                   	leave  
 3b9:	c3                   	ret    

000003ba <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3ba:	55                   	push   %ebp
 3bb:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 3bd:	eb 0c                	jmp    3cb <strncmp+0x11>
    n--, p++, q++;
 3bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 3cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3cf:	74 1a                	je     3eb <strncmp+0x31>
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	84 c0                	test   %al,%al
 3d9:	74 10                	je     3eb <strncmp+0x31>
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
 3de:	0f b6 10             	movzbl (%eax),%edx
 3e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e4:	0f b6 00             	movzbl (%eax),%eax
 3e7:	38 c2                	cmp    %al,%dl
 3e9:	74 d4                	je     3bf <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 3eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3ef:	75 07                	jne    3f8 <strncmp+0x3e>
    return 0;
 3f1:	b8 00 00 00 00       	mov    $0x0,%eax
 3f6:	eb 18                	jmp    410 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 3f8:	8b 45 08             	mov    0x8(%ebp),%eax
 3fb:	0f b6 00             	movzbl (%eax),%eax
 3fe:	0f b6 d0             	movzbl %al,%edx
 401:	8b 45 0c             	mov    0xc(%ebp),%eax
 404:	0f b6 00             	movzbl (%eax),%eax
 407:	0f b6 c0             	movzbl %al,%eax
 40a:	89 d1                	mov    %edx,%ecx
 40c:	29 c1                	sub    %eax,%ecx
 40e:	89 c8                	mov    %ecx,%eax
}
 410:	5d                   	pop    %ebp
 411:	c3                   	ret    

00000412 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 412:	55                   	push   %ebp
 413:	89 e5                	mov    %esp,%ebp
  while(*p){
 415:	eb 13                	jmp    42a <strcat+0x18>
    *dest++ = *p++;
 417:	8b 45 0c             	mov    0xc(%ebp),%eax
 41a:	0f b6 10             	movzbl (%eax),%edx
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
 420:	88 10                	mov    %dl,(%eax)
 422:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 426:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 42a:	8b 45 0c             	mov    0xc(%ebp),%eax
 42d:	0f b6 00             	movzbl (%eax),%eax
 430:	84 c0                	test   %al,%al
 432:	75 e3                	jne    417 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 434:	eb 13                	jmp    449 <strcat+0x37>
    *dest++ = *q++;
 436:	8b 45 10             	mov    0x10(%ebp),%eax
 439:	0f b6 10             	movzbl (%eax),%edx
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
 43f:	88 10                	mov    %dl,(%eax)
 441:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 445:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 449:	8b 45 10             	mov    0x10(%ebp),%eax
 44c:	0f b6 00             	movzbl (%eax),%eax
 44f:	84 c0                	test   %al,%al
 451:	75 e3                	jne    436 <strcat+0x24>
    *dest++ = *q++;
  }  
 453:	5d                   	pop    %ebp
 454:	c3                   	ret    
 455:	90                   	nop
 456:	90                   	nop
 457:	90                   	nop

00000458 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 458:	b8 01 00 00 00       	mov    $0x1,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <exit>:
SYSCALL(exit)
 460:	b8 02 00 00 00       	mov    $0x2,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <wait>:
SYSCALL(wait)
 468:	b8 03 00 00 00       	mov    $0x3,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <wait2>:
SYSCALL(wait2)
 470:	b8 16 00 00 00       	mov    $0x16,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <pipe>:
SYSCALL(pipe)
 478:	b8 04 00 00 00       	mov    $0x4,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <read>:
SYSCALL(read)
 480:	b8 05 00 00 00       	mov    $0x5,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <write>:
SYSCALL(write)
 488:	b8 10 00 00 00       	mov    $0x10,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <close>:
SYSCALL(close)
 490:	b8 15 00 00 00       	mov    $0x15,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <kill>:
SYSCALL(kill)
 498:	b8 06 00 00 00       	mov    $0x6,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <exec>:
SYSCALL(exec)
 4a0:	b8 07 00 00 00       	mov    $0x7,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <open>:
SYSCALL(open)
 4a8:	b8 0f 00 00 00       	mov    $0xf,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <mknod>:
SYSCALL(mknod)
 4b0:	b8 11 00 00 00       	mov    $0x11,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <unlink>:
SYSCALL(unlink)
 4b8:	b8 12 00 00 00       	mov    $0x12,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <fstat>:
SYSCALL(fstat)
 4c0:	b8 08 00 00 00       	mov    $0x8,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <link>:
SYSCALL(link)
 4c8:	b8 13 00 00 00       	mov    $0x13,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <mkdir>:
SYSCALL(mkdir)
 4d0:	b8 14 00 00 00       	mov    $0x14,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <chdir>:
SYSCALL(chdir)
 4d8:	b8 09 00 00 00       	mov    $0x9,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <dup>:
SYSCALL(dup)
 4e0:	b8 0a 00 00 00       	mov    $0xa,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <getpid>:
SYSCALL(getpid)
 4e8:	b8 0b 00 00 00       	mov    $0xb,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <sbrk>:
SYSCALL(sbrk)
 4f0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <sleep>:
SYSCALL(sleep)
 4f8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <uptime>:
SYSCALL(uptime)
 500:	b8 0e 00 00 00       	mov    $0xe,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 508:	55                   	push   %ebp
 509:	89 e5                	mov    %esp,%ebp
 50b:	83 ec 28             	sub    $0x28,%esp
 50e:	8b 45 0c             	mov    0xc(%ebp),%eax
 511:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 514:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 51b:	00 
 51c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 51f:	89 44 24 04          	mov    %eax,0x4(%esp)
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	89 04 24             	mov    %eax,(%esp)
 529:	e8 5a ff ff ff       	call   488 <write>
}
 52e:	c9                   	leave  
 52f:	c3                   	ret    

00000530 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 530:	55                   	push   %ebp
 531:	89 e5                	mov    %esp,%ebp
 533:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 536:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 53d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 541:	74 17                	je     55a <printint+0x2a>
 543:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 547:	79 11                	jns    55a <printint+0x2a>
    neg = 1;
 549:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 550:	8b 45 0c             	mov    0xc(%ebp),%eax
 553:	f7 d8                	neg    %eax
 555:	89 45 ec             	mov    %eax,-0x14(%ebp)
 558:	eb 06                	jmp    560 <printint+0x30>
  } else {
    x = xx;
 55a:	8b 45 0c             	mov    0xc(%ebp),%eax
 55d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 560:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 567:	8b 4d 10             	mov    0x10(%ebp),%ecx
 56a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 56d:	ba 00 00 00 00       	mov    $0x0,%edx
 572:	f7 f1                	div    %ecx
 574:	89 d0                	mov    %edx,%eax
 576:	0f b6 90 7c 0c 00 00 	movzbl 0xc7c(%eax),%edx
 57d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 580:	03 45 f4             	add    -0xc(%ebp),%eax
 583:	88 10                	mov    %dl,(%eax)
 585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 589:	8b 55 10             	mov    0x10(%ebp),%edx
 58c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 58f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 592:	ba 00 00 00 00       	mov    $0x0,%edx
 597:	f7 75 d4             	divl   -0x2c(%ebp)
 59a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 59d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5a1:	75 c4                	jne    567 <printint+0x37>
  if(neg)
 5a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a7:	74 2a                	je     5d3 <printint+0xa3>
    buf[i++] = '-';
 5a9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5ac:	03 45 f4             	add    -0xc(%ebp),%eax
 5af:	c6 00 2d             	movb   $0x2d,(%eax)
 5b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5b6:	eb 1b                	jmp    5d3 <printint+0xa3>
    putc(fd, buf[i]);
 5b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5bb:	03 45 f4             	add    -0xc(%ebp),%eax
 5be:	0f b6 00             	movzbl (%eax),%eax
 5c1:	0f be c0             	movsbl %al,%eax
 5c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	89 04 24             	mov    %eax,(%esp)
 5ce:	e8 35 ff ff ff       	call   508 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5d3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5db:	79 db                	jns    5b8 <printint+0x88>
    putc(fd, buf[i]);
}
 5dd:	c9                   	leave  
 5de:	c3                   	ret    

000005df <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5df:	55                   	push   %ebp
 5e0:	89 e5                	mov    %esp,%ebp
 5e2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5e5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5ec:	8d 45 0c             	lea    0xc(%ebp),%eax
 5ef:	83 c0 04             	add    $0x4,%eax
 5f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5fc:	e9 7d 01 00 00       	jmp    77e <printf+0x19f>
    c = fmt[i] & 0xff;
 601:	8b 55 0c             	mov    0xc(%ebp),%edx
 604:	8b 45 f0             	mov    -0x10(%ebp),%eax
 607:	01 d0                	add    %edx,%eax
 609:	0f b6 00             	movzbl (%eax),%eax
 60c:	0f be c0             	movsbl %al,%eax
 60f:	25 ff 00 00 00       	and    $0xff,%eax
 614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 617:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61b:	75 2c                	jne    649 <printf+0x6a>
      if(c == '%'){
 61d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 621:	75 0c                	jne    62f <printf+0x50>
        state = '%';
 623:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 62a:	e9 4b 01 00 00       	jmp    77a <printf+0x19b>
      } else {
        putc(fd, c);
 62f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 632:	0f be c0             	movsbl %al,%eax
 635:	89 44 24 04          	mov    %eax,0x4(%esp)
 639:	8b 45 08             	mov    0x8(%ebp),%eax
 63c:	89 04 24             	mov    %eax,(%esp)
 63f:	e8 c4 fe ff ff       	call   508 <putc>
 644:	e9 31 01 00 00       	jmp    77a <printf+0x19b>
      }
    } else if(state == '%'){
 649:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 64d:	0f 85 27 01 00 00    	jne    77a <printf+0x19b>
      if(c == 'd'){
 653:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 657:	75 2d                	jne    686 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 659:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 665:	00 
 666:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 66d:	00 
 66e:	89 44 24 04          	mov    %eax,0x4(%esp)
 672:	8b 45 08             	mov    0x8(%ebp),%eax
 675:	89 04 24             	mov    %eax,(%esp)
 678:	e8 b3 fe ff ff       	call   530 <printint>
        ap++;
 67d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 681:	e9 ed 00 00 00       	jmp    773 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 686:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 68a:	74 06                	je     692 <printf+0xb3>
 68c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 690:	75 2d                	jne    6bf <printf+0xe0>
        printint(fd, *ap, 16, 0);
 692:	8b 45 e8             	mov    -0x18(%ebp),%eax
 695:	8b 00                	mov    (%eax),%eax
 697:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 69e:	00 
 69f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6a6:	00 
 6a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	89 04 24             	mov    %eax,(%esp)
 6b1:	e8 7a fe ff ff       	call   530 <printint>
        ap++;
 6b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ba:	e9 b4 00 00 00       	jmp    773 <printf+0x194>
      } else if(c == 's'){
 6bf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6c3:	75 46                	jne    70b <printf+0x12c>
        s = (char*)*ap;
 6c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6cd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d5:	75 27                	jne    6fe <printf+0x11f>
          s = "(null)";
 6d7:	c7 45 f4 b7 09 00 00 	movl   $0x9b7,-0xc(%ebp)
        while(*s != 0){
 6de:	eb 1e                	jmp    6fe <printf+0x11f>
          putc(fd, *s);
 6e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e3:	0f b6 00             	movzbl (%eax),%eax
 6e6:	0f be c0             	movsbl %al,%eax
 6e9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ed:	8b 45 08             	mov    0x8(%ebp),%eax
 6f0:	89 04 24             	mov    %eax,(%esp)
 6f3:	e8 10 fe ff ff       	call   508 <putc>
          s++;
 6f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6fc:	eb 01                	jmp    6ff <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6fe:	90                   	nop
 6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 702:	0f b6 00             	movzbl (%eax),%eax
 705:	84 c0                	test   %al,%al
 707:	75 d7                	jne    6e0 <printf+0x101>
 709:	eb 68                	jmp    773 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 70b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 70f:	75 1d                	jne    72e <printf+0x14f>
        putc(fd, *ap);
 711:	8b 45 e8             	mov    -0x18(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	0f be c0             	movsbl %al,%eax
 719:	89 44 24 04          	mov    %eax,0x4(%esp)
 71d:	8b 45 08             	mov    0x8(%ebp),%eax
 720:	89 04 24             	mov    %eax,(%esp)
 723:	e8 e0 fd ff ff       	call   508 <putc>
        ap++;
 728:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72c:	eb 45                	jmp    773 <printf+0x194>
      } else if(c == '%'){
 72e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 732:	75 17                	jne    74b <printf+0x16c>
        putc(fd, c);
 734:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 737:	0f be c0             	movsbl %al,%eax
 73a:	89 44 24 04          	mov    %eax,0x4(%esp)
 73e:	8b 45 08             	mov    0x8(%ebp),%eax
 741:	89 04 24             	mov    %eax,(%esp)
 744:	e8 bf fd ff ff       	call   508 <putc>
 749:	eb 28                	jmp    773 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 74b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 752:	00 
 753:	8b 45 08             	mov    0x8(%ebp),%eax
 756:	89 04 24             	mov    %eax,(%esp)
 759:	e8 aa fd ff ff       	call   508 <putc>
        putc(fd, c);
 75e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 761:	0f be c0             	movsbl %al,%eax
 764:	89 44 24 04          	mov    %eax,0x4(%esp)
 768:	8b 45 08             	mov    0x8(%ebp),%eax
 76b:	89 04 24             	mov    %eax,(%esp)
 76e:	e8 95 fd ff ff       	call   508 <putc>
      }
      state = 0;
 773:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 77a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 77e:	8b 55 0c             	mov    0xc(%ebp),%edx
 781:	8b 45 f0             	mov    -0x10(%ebp),%eax
 784:	01 d0                	add    %edx,%eax
 786:	0f b6 00             	movzbl (%eax),%eax
 789:	84 c0                	test   %al,%al
 78b:	0f 85 70 fe ff ff    	jne    601 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 791:	c9                   	leave  
 792:	c3                   	ret    
 793:	90                   	nop

00000794 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 794:	55                   	push   %ebp
 795:	89 e5                	mov    %esp,%ebp
 797:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	83 e8 08             	sub    $0x8,%eax
 7a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a3:	a1 98 0c 00 00       	mov    0xc98,%eax
 7a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ab:	eb 24                	jmp    7d1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b0:	8b 00                	mov    (%eax),%eax
 7b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b5:	77 12                	ja     7c9 <free+0x35>
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bd:	77 24                	ja     7e3 <free+0x4f>
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	8b 00                	mov    (%eax),%eax
 7c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c7:	77 1a                	ja     7e3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d7:	76 d4                	jbe    7ad <free+0x19>
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e1:	76 ca                	jbe    7ad <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e6:	8b 40 04             	mov    0x4(%eax),%eax
 7e9:	c1 e0 03             	shl    $0x3,%eax
 7ec:	89 c2                	mov    %eax,%edx
 7ee:	03 55 f8             	add    -0x8(%ebp),%edx
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	39 c2                	cmp    %eax,%edx
 7f8:	75 24                	jne    81e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fd:	8b 50 04             	mov    0x4(%eax),%edx
 800:	8b 45 fc             	mov    -0x4(%ebp),%eax
 803:	8b 00                	mov    (%eax),%eax
 805:	8b 40 04             	mov    0x4(%eax),%eax
 808:	01 c2                	add    %eax,%edx
 80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 810:	8b 45 fc             	mov    -0x4(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	8b 10                	mov    (%eax),%edx
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	89 10                	mov    %edx,(%eax)
 81c:	eb 0a                	jmp    828 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 81e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 821:	8b 10                	mov    (%eax),%edx
 823:	8b 45 f8             	mov    -0x8(%ebp),%eax
 826:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	8b 40 04             	mov    0x4(%eax),%eax
 82e:	c1 e0 03             	shl    $0x3,%eax
 831:	03 45 fc             	add    -0x4(%ebp),%eax
 834:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 837:	75 20                	jne    859 <free+0xc5>
    p->s.size += bp->s.size;
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 50 04             	mov    0x4(%eax),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	8b 40 04             	mov    0x4(%eax),%eax
 845:	01 c2                	add    %eax,%edx
 847:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 84d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 850:	8b 10                	mov    (%eax),%edx
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	89 10                	mov    %edx,(%eax)
 857:	eb 08                	jmp    861 <free+0xcd>
  } else
    p->s.ptr = bp;
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 85f:	89 10                	mov    %edx,(%eax)
  freep = p;
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	a3 98 0c 00 00       	mov    %eax,0xc98
}
 869:	c9                   	leave  
 86a:	c3                   	ret    

0000086b <morecore>:

static Header*
morecore(uint nu)
{
 86b:	55                   	push   %ebp
 86c:	89 e5                	mov    %esp,%ebp
 86e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 871:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 878:	77 07                	ja     881 <morecore+0x16>
    nu = 4096;
 87a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 881:	8b 45 08             	mov    0x8(%ebp),%eax
 884:	c1 e0 03             	shl    $0x3,%eax
 887:	89 04 24             	mov    %eax,(%esp)
 88a:	e8 61 fc ff ff       	call   4f0 <sbrk>
 88f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 892:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 896:	75 07                	jne    89f <morecore+0x34>
    return 0;
 898:	b8 00 00 00 00       	mov    $0x0,%eax
 89d:	eb 22                	jmp    8c1 <morecore+0x56>
  hp = (Header*)p;
 89f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	8b 55 08             	mov    0x8(%ebp),%edx
 8ab:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b1:	83 c0 08             	add    $0x8,%eax
 8b4:	89 04 24             	mov    %eax,(%esp)
 8b7:	e8 d8 fe ff ff       	call   794 <free>
  return freep;
 8bc:	a1 98 0c 00 00       	mov    0xc98,%eax
}
 8c1:	c9                   	leave  
 8c2:	c3                   	ret    

000008c3 <malloc>:

void*
malloc(uint nbytes)
{
 8c3:	55                   	push   %ebp
 8c4:	89 e5                	mov    %esp,%ebp
 8c6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c9:	8b 45 08             	mov    0x8(%ebp),%eax
 8cc:	83 c0 07             	add    $0x7,%eax
 8cf:	c1 e8 03             	shr    $0x3,%eax
 8d2:	83 c0 01             	add    $0x1,%eax
 8d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d8:	a1 98 0c 00 00       	mov    0xc98,%eax
 8dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e4:	75 23                	jne    909 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8e6:	c7 45 f0 90 0c 00 00 	movl   $0xc90,-0x10(%ebp)
 8ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f0:	a3 98 0c 00 00       	mov    %eax,0xc98
 8f5:	a1 98 0c 00 00       	mov    0xc98,%eax
 8fa:	a3 90 0c 00 00       	mov    %eax,0xc90
    base.s.size = 0;
 8ff:	c7 05 94 0c 00 00 00 	movl   $0x0,0xc94
 906:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 909:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	8b 40 04             	mov    0x4(%eax),%eax
 917:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 91a:	72 4d                	jb     969 <malloc+0xa6>
      if(p->s.size == nunits)
 91c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91f:	8b 40 04             	mov    0x4(%eax),%eax
 922:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 925:	75 0c                	jne    933 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 927:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92a:	8b 10                	mov    (%eax),%edx
 92c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92f:	89 10                	mov    %edx,(%eax)
 931:	eb 26                	jmp    959 <malloc+0x96>
      else {
        p->s.size -= nunits;
 933:	8b 45 f4             	mov    -0xc(%ebp),%eax
 936:	8b 40 04             	mov    0x4(%eax),%eax
 939:	89 c2                	mov    %eax,%edx
 93b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 93e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 941:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 944:	8b 45 f4             	mov    -0xc(%ebp),%eax
 947:	8b 40 04             	mov    0x4(%eax),%eax
 94a:	c1 e0 03             	shl    $0x3,%eax
 94d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 950:	8b 45 f4             	mov    -0xc(%ebp),%eax
 953:	8b 55 ec             	mov    -0x14(%ebp),%edx
 956:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 959:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95c:	a3 98 0c 00 00       	mov    %eax,0xc98
      return (void*)(p + 1);
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	83 c0 08             	add    $0x8,%eax
 967:	eb 38                	jmp    9a1 <malloc+0xde>
    }
    if(p == freep)
 969:	a1 98 0c 00 00       	mov    0xc98,%eax
 96e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 971:	75 1b                	jne    98e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 973:	8b 45 ec             	mov    -0x14(%ebp),%eax
 976:	89 04 24             	mov    %eax,(%esp)
 979:	e8 ed fe ff ff       	call   86b <morecore>
 97e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 985:	75 07                	jne    98e <malloc+0xcb>
        return 0;
 987:	b8 00 00 00 00       	mov    $0x0,%eax
 98c:	eb 13                	jmp    9a1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 991:	89 45 f0             	mov    %eax,-0x10(%ebp)
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	8b 00                	mov    (%eax),%eax
 999:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 99c:	e9 70 ff ff ff       	jmp    911 <malloc+0x4e>
}
 9a1:	c9                   	leave  
 9a2:	c3                   	ret    
