
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
   f:	c7 44 24 04 af 09 00 	movl   $0x9af,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 c8 05 00 00       	call   5eb <printf>
    exit();
  23:	e8 3c 04 00 00       	call   464 <exit>
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
  49:	e8 56 04 00 00       	call   4a4 <kill>

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
  5c:	e8 03 04 00 00       	call   464 <exit>
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
 19f:	e8 e8 02 00 00       	call   48c <read>
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
 1fd:	e8 b2 02 00 00       	call   4b4 <open>
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
 21f:	e8 a8 02 00 00       	call   4cc <fstat>
 224:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 227:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22a:	89 04 24             	mov    %eax,(%esp)
 22d:	e8 6a 02 00 00       	call   49c <close>
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
strcat(char *dest, char *p, char *q)
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
strcat(char *dest, char *p, char *q)
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
  *dest = 0;
 453:	8b 45 08             	mov    0x8(%ebp),%eax
 456:	c6 00 00             	movb   $0x0,(%eax)
 459:	5d                   	pop    %ebp
 45a:	c3                   	ret    
 45b:	90                   	nop

0000045c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 45c:	b8 01 00 00 00       	mov    $0x1,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <exit>:
SYSCALL(exit)
 464:	b8 02 00 00 00       	mov    $0x2,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <wait>:
SYSCALL(wait)
 46c:	b8 03 00 00 00       	mov    $0x3,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <wait2>:
SYSCALL(wait2)
 474:	b8 16 00 00 00       	mov    $0x16,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <nice>:
SYSCALL(nice)
 47c:	b8 17 00 00 00       	mov    $0x17,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <pipe>:
SYSCALL(pipe)
 484:	b8 04 00 00 00       	mov    $0x4,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <read>:
SYSCALL(read)
 48c:	b8 05 00 00 00       	mov    $0x5,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <write>:
SYSCALL(write)
 494:	b8 10 00 00 00       	mov    $0x10,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <close>:
SYSCALL(close)
 49c:	b8 15 00 00 00       	mov    $0x15,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <kill>:
SYSCALL(kill)
 4a4:	b8 06 00 00 00       	mov    $0x6,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <exec>:
SYSCALL(exec)
 4ac:	b8 07 00 00 00       	mov    $0x7,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <open>:
SYSCALL(open)
 4b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <mknod>:
SYSCALL(mknod)
 4bc:	b8 11 00 00 00       	mov    $0x11,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <unlink>:
SYSCALL(unlink)
 4c4:	b8 12 00 00 00       	mov    $0x12,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <fstat>:
SYSCALL(fstat)
 4cc:	b8 08 00 00 00       	mov    $0x8,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <link>:
SYSCALL(link)
 4d4:	b8 13 00 00 00       	mov    $0x13,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <mkdir>:
SYSCALL(mkdir)
 4dc:	b8 14 00 00 00       	mov    $0x14,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <chdir>:
SYSCALL(chdir)
 4e4:	b8 09 00 00 00       	mov    $0x9,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <dup>:
SYSCALL(dup)
 4ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <getpid>:
SYSCALL(getpid)
 4f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <sbrk>:
SYSCALL(sbrk)
 4fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <sleep>:
SYSCALL(sleep)
 504:	b8 0d 00 00 00       	mov    $0xd,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <uptime>:
SYSCALL(uptime)
 50c:	b8 0e 00 00 00       	mov    $0xe,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 514:	55                   	push   %ebp
 515:	89 e5                	mov    %esp,%ebp
 517:	83 ec 28             	sub    $0x28,%esp
 51a:	8b 45 0c             	mov    0xc(%ebp),%eax
 51d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 520:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 527:	00 
 528:	8d 45 f4             	lea    -0xc(%ebp),%eax
 52b:	89 44 24 04          	mov    %eax,0x4(%esp)
 52f:	8b 45 08             	mov    0x8(%ebp),%eax
 532:	89 04 24             	mov    %eax,(%esp)
 535:	e8 5a ff ff ff       	call   494 <write>
}
 53a:	c9                   	leave  
 53b:	c3                   	ret    

0000053c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 53c:	55                   	push   %ebp
 53d:	89 e5                	mov    %esp,%ebp
 53f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 542:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 549:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 54d:	74 17                	je     566 <printint+0x2a>
 54f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 553:	79 11                	jns    566 <printint+0x2a>
    neg = 1;
 555:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 55c:	8b 45 0c             	mov    0xc(%ebp),%eax
 55f:	f7 d8                	neg    %eax
 561:	89 45 ec             	mov    %eax,-0x14(%ebp)
 564:	eb 06                	jmp    56c <printint+0x30>
  } else {
    x = xx;
 566:	8b 45 0c             	mov    0xc(%ebp),%eax
 569:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 56c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 573:	8b 4d 10             	mov    0x10(%ebp),%ecx
 576:	8b 45 ec             	mov    -0x14(%ebp),%eax
 579:	ba 00 00 00 00       	mov    $0x0,%edx
 57e:	f7 f1                	div    %ecx
 580:	89 d0                	mov    %edx,%eax
 582:	0f b6 90 88 0c 00 00 	movzbl 0xc88(%eax),%edx
 589:	8d 45 dc             	lea    -0x24(%ebp),%eax
 58c:	03 45 f4             	add    -0xc(%ebp),%eax
 58f:	88 10                	mov    %dl,(%eax)
 591:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 595:	8b 55 10             	mov    0x10(%ebp),%edx
 598:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 59b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 59e:	ba 00 00 00 00       	mov    $0x0,%edx
 5a3:	f7 75 d4             	divl   -0x2c(%ebp)
 5a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ad:	75 c4                	jne    573 <printint+0x37>
  if(neg)
 5af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5b3:	74 2a                	je     5df <printint+0xa3>
    buf[i++] = '-';
 5b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5b8:	03 45 f4             	add    -0xc(%ebp),%eax
 5bb:	c6 00 2d             	movb   $0x2d,(%eax)
 5be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5c2:	eb 1b                	jmp    5df <printint+0xa3>
    putc(fd, buf[i]);
 5c4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5c7:	03 45 f4             	add    -0xc(%ebp),%eax
 5ca:	0f b6 00             	movzbl (%eax),%eax
 5cd:	0f be c0             	movsbl %al,%eax
 5d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
 5d7:	89 04 24             	mov    %eax,(%esp)
 5da:	e8 35 ff ff ff       	call   514 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5df:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e7:	79 db                	jns    5c4 <printint+0x88>
    putc(fd, buf[i]);
}
 5e9:	c9                   	leave  
 5ea:	c3                   	ret    

000005eb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5eb:	55                   	push   %ebp
 5ec:	89 e5                	mov    %esp,%ebp
 5ee:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5f8:	8d 45 0c             	lea    0xc(%ebp),%eax
 5fb:	83 c0 04             	add    $0x4,%eax
 5fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 601:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 608:	e9 7d 01 00 00       	jmp    78a <printf+0x19f>
    c = fmt[i] & 0xff;
 60d:	8b 55 0c             	mov    0xc(%ebp),%edx
 610:	8b 45 f0             	mov    -0x10(%ebp),%eax
 613:	01 d0                	add    %edx,%eax
 615:	0f b6 00             	movzbl (%eax),%eax
 618:	0f be c0             	movsbl %al,%eax
 61b:	25 ff 00 00 00       	and    $0xff,%eax
 620:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 623:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 627:	75 2c                	jne    655 <printf+0x6a>
      if(c == '%'){
 629:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 62d:	75 0c                	jne    63b <printf+0x50>
        state = '%';
 62f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 636:	e9 4b 01 00 00       	jmp    786 <printf+0x19b>
      } else {
        putc(fd, c);
 63b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 63e:	0f be c0             	movsbl %al,%eax
 641:	89 44 24 04          	mov    %eax,0x4(%esp)
 645:	8b 45 08             	mov    0x8(%ebp),%eax
 648:	89 04 24             	mov    %eax,(%esp)
 64b:	e8 c4 fe ff ff       	call   514 <putc>
 650:	e9 31 01 00 00       	jmp    786 <printf+0x19b>
      }
    } else if(state == '%'){
 655:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 659:	0f 85 27 01 00 00    	jne    786 <printf+0x19b>
      if(c == 'd'){
 65f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 663:	75 2d                	jne    692 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 665:	8b 45 e8             	mov    -0x18(%ebp),%eax
 668:	8b 00                	mov    (%eax),%eax
 66a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 671:	00 
 672:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 679:	00 
 67a:	89 44 24 04          	mov    %eax,0x4(%esp)
 67e:	8b 45 08             	mov    0x8(%ebp),%eax
 681:	89 04 24             	mov    %eax,(%esp)
 684:	e8 b3 fe ff ff       	call   53c <printint>
        ap++;
 689:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68d:	e9 ed 00 00 00       	jmp    77f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 692:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 696:	74 06                	je     69e <printf+0xb3>
 698:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 69c:	75 2d                	jne    6cb <printf+0xe0>
        printint(fd, *ap, 16, 0);
 69e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a1:	8b 00                	mov    (%eax),%eax
 6a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6aa:	00 
 6ab:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6b2:	00 
 6b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ba:	89 04 24             	mov    %eax,(%esp)
 6bd:	e8 7a fe ff ff       	call   53c <printint>
        ap++;
 6c2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6c6:	e9 b4 00 00 00       	jmp    77f <printf+0x194>
      } else if(c == 's'){
 6cb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6cf:	75 46                	jne    717 <printf+0x12c>
        s = (char*)*ap;
 6d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d4:	8b 00                	mov    (%eax),%eax
 6d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e1:	75 27                	jne    70a <printf+0x11f>
          s = "(null)";
 6e3:	c7 45 f4 c3 09 00 00 	movl   $0x9c3,-0xc(%ebp)
        while(*s != 0){
 6ea:	eb 1e                	jmp    70a <printf+0x11f>
          putc(fd, *s);
 6ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ef:	0f b6 00             	movzbl (%eax),%eax
 6f2:	0f be c0             	movsbl %al,%eax
 6f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f9:	8b 45 08             	mov    0x8(%ebp),%eax
 6fc:	89 04 24             	mov    %eax,(%esp)
 6ff:	e8 10 fe ff ff       	call   514 <putc>
          s++;
 704:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 708:	eb 01                	jmp    70b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 70a:	90                   	nop
 70b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70e:	0f b6 00             	movzbl (%eax),%eax
 711:	84 c0                	test   %al,%al
 713:	75 d7                	jne    6ec <printf+0x101>
 715:	eb 68                	jmp    77f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 717:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 71b:	75 1d                	jne    73a <printf+0x14f>
        putc(fd, *ap);
 71d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	0f be c0             	movsbl %al,%eax
 725:	89 44 24 04          	mov    %eax,0x4(%esp)
 729:	8b 45 08             	mov    0x8(%ebp),%eax
 72c:	89 04 24             	mov    %eax,(%esp)
 72f:	e8 e0 fd ff ff       	call   514 <putc>
        ap++;
 734:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 738:	eb 45                	jmp    77f <printf+0x194>
      } else if(c == '%'){
 73a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 73e:	75 17                	jne    757 <printf+0x16c>
        putc(fd, c);
 740:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 743:	0f be c0             	movsbl %al,%eax
 746:	89 44 24 04          	mov    %eax,0x4(%esp)
 74a:	8b 45 08             	mov    0x8(%ebp),%eax
 74d:	89 04 24             	mov    %eax,(%esp)
 750:	e8 bf fd ff ff       	call   514 <putc>
 755:	eb 28                	jmp    77f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 757:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 75e:	00 
 75f:	8b 45 08             	mov    0x8(%ebp),%eax
 762:	89 04 24             	mov    %eax,(%esp)
 765:	e8 aa fd ff ff       	call   514 <putc>
        putc(fd, c);
 76a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 76d:	0f be c0             	movsbl %al,%eax
 770:	89 44 24 04          	mov    %eax,0x4(%esp)
 774:	8b 45 08             	mov    0x8(%ebp),%eax
 777:	89 04 24             	mov    %eax,(%esp)
 77a:	e8 95 fd ff ff       	call   514 <putc>
      }
      state = 0;
 77f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 786:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 78a:	8b 55 0c             	mov    0xc(%ebp),%edx
 78d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 790:	01 d0                	add    %edx,%eax
 792:	0f b6 00             	movzbl (%eax),%eax
 795:	84 c0                	test   %al,%al
 797:	0f 85 70 fe ff ff    	jne    60d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 79d:	c9                   	leave  
 79e:	c3                   	ret    
 79f:	90                   	nop

000007a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a0:	55                   	push   %ebp
 7a1:	89 e5                	mov    %esp,%ebp
 7a3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
 7a9:	83 e8 08             	sub    $0x8,%eax
 7ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7af:	a1 a4 0c 00 00       	mov    0xca4,%eax
 7b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b7:	eb 24                	jmp    7dd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c1:	77 12                	ja     7d5 <free+0x35>
 7c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c9:	77 24                	ja     7ef <free+0x4f>
 7cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ce:	8b 00                	mov    (%eax),%eax
 7d0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d3:	77 1a                	ja     7ef <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d8:	8b 00                	mov    (%eax),%eax
 7da:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e3:	76 d4                	jbe    7b9 <free+0x19>
 7e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e8:	8b 00                	mov    (%eax),%eax
 7ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ed:	76 ca                	jbe    7b9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f2:	8b 40 04             	mov    0x4(%eax),%eax
 7f5:	c1 e0 03             	shl    $0x3,%eax
 7f8:	89 c2                	mov    %eax,%edx
 7fa:	03 55 f8             	add    -0x8(%ebp),%edx
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	39 c2                	cmp    %eax,%edx
 804:	75 24                	jne    82a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 806:	8b 45 f8             	mov    -0x8(%ebp),%eax
 809:	8b 50 04             	mov    0x4(%eax),%edx
 80c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80f:	8b 00                	mov    (%eax),%eax
 811:	8b 40 04             	mov    0x4(%eax),%eax
 814:	01 c2                	add    %eax,%edx
 816:	8b 45 f8             	mov    -0x8(%ebp),%eax
 819:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	8b 10                	mov    (%eax),%edx
 823:	8b 45 f8             	mov    -0x8(%ebp),%eax
 826:	89 10                	mov    %edx,(%eax)
 828:	eb 0a                	jmp    834 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 82a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82d:	8b 10                	mov    (%eax),%edx
 82f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 832:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 834:	8b 45 fc             	mov    -0x4(%ebp),%eax
 837:	8b 40 04             	mov    0x4(%eax),%eax
 83a:	c1 e0 03             	shl    $0x3,%eax
 83d:	03 45 fc             	add    -0x4(%ebp),%eax
 840:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 843:	75 20                	jne    865 <free+0xc5>
    p->s.size += bp->s.size;
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	8b 50 04             	mov    0x4(%eax),%edx
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	8b 40 04             	mov    0x4(%eax),%eax
 851:	01 c2                	add    %eax,%edx
 853:	8b 45 fc             	mov    -0x4(%ebp),%eax
 856:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 859:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85c:	8b 10                	mov    (%eax),%edx
 85e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 861:	89 10                	mov    %edx,(%eax)
 863:	eb 08                	jmp    86d <free+0xcd>
  } else
    p->s.ptr = bp;
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 55 f8             	mov    -0x8(%ebp),%edx
 86b:	89 10                	mov    %edx,(%eax)
  freep = p;
 86d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 870:	a3 a4 0c 00 00       	mov    %eax,0xca4
}
 875:	c9                   	leave  
 876:	c3                   	ret    

00000877 <morecore>:

static Header*
morecore(uint nu)
{
 877:	55                   	push   %ebp
 878:	89 e5                	mov    %esp,%ebp
 87a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 87d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 884:	77 07                	ja     88d <morecore+0x16>
    nu = 4096;
 886:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 88d:	8b 45 08             	mov    0x8(%ebp),%eax
 890:	c1 e0 03             	shl    $0x3,%eax
 893:	89 04 24             	mov    %eax,(%esp)
 896:	e8 61 fc ff ff       	call   4fc <sbrk>
 89b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 89e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8a2:	75 07                	jne    8ab <morecore+0x34>
    return 0;
 8a4:	b8 00 00 00 00       	mov    $0x0,%eax
 8a9:	eb 22                	jmp    8cd <morecore+0x56>
  hp = (Header*)p;
 8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b4:	8b 55 08             	mov    0x8(%ebp),%edx
 8b7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bd:	83 c0 08             	add    $0x8,%eax
 8c0:	89 04 24             	mov    %eax,(%esp)
 8c3:	e8 d8 fe ff ff       	call   7a0 <free>
  return freep;
 8c8:	a1 a4 0c 00 00       	mov    0xca4,%eax
}
 8cd:	c9                   	leave  
 8ce:	c3                   	ret    

000008cf <malloc>:

void*
malloc(uint nbytes)
{
 8cf:	55                   	push   %ebp
 8d0:	89 e5                	mov    %esp,%ebp
 8d2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d5:	8b 45 08             	mov    0x8(%ebp),%eax
 8d8:	83 c0 07             	add    $0x7,%eax
 8db:	c1 e8 03             	shr    $0x3,%eax
 8de:	83 c0 01             	add    $0x1,%eax
 8e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8e4:	a1 a4 0c 00 00       	mov    0xca4,%eax
 8e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8f0:	75 23                	jne    915 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8f2:	c7 45 f0 9c 0c 00 00 	movl   $0xc9c,-0x10(%ebp)
 8f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fc:	a3 a4 0c 00 00       	mov    %eax,0xca4
 901:	a1 a4 0c 00 00       	mov    0xca4,%eax
 906:	a3 9c 0c 00 00       	mov    %eax,0xc9c
    base.s.size = 0;
 90b:	c7 05 a0 0c 00 00 00 	movl   $0x0,0xca0
 912:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 915:	8b 45 f0             	mov    -0x10(%ebp),%eax
 918:	8b 00                	mov    (%eax),%eax
 91a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 91d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 920:	8b 40 04             	mov    0x4(%eax),%eax
 923:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 926:	72 4d                	jb     975 <malloc+0xa6>
      if(p->s.size == nunits)
 928:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92b:	8b 40 04             	mov    0x4(%eax),%eax
 92e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 931:	75 0c                	jne    93f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 933:	8b 45 f4             	mov    -0xc(%ebp),%eax
 936:	8b 10                	mov    (%eax),%edx
 938:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93b:	89 10                	mov    %edx,(%eax)
 93d:	eb 26                	jmp    965 <malloc+0x96>
      else {
        p->s.size -= nunits;
 93f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 942:	8b 40 04             	mov    0x4(%eax),%eax
 945:	89 c2                	mov    %eax,%edx
 947:	2b 55 ec             	sub    -0x14(%ebp),%edx
 94a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 950:	8b 45 f4             	mov    -0xc(%ebp),%eax
 953:	8b 40 04             	mov    0x4(%eax),%eax
 956:	c1 e0 03             	shl    $0x3,%eax
 959:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 95c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 962:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 965:	8b 45 f0             	mov    -0x10(%ebp),%eax
 968:	a3 a4 0c 00 00       	mov    %eax,0xca4
      return (void*)(p + 1);
 96d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 970:	83 c0 08             	add    $0x8,%eax
 973:	eb 38                	jmp    9ad <malloc+0xde>
    }
    if(p == freep)
 975:	a1 a4 0c 00 00       	mov    0xca4,%eax
 97a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 97d:	75 1b                	jne    99a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 97f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 982:	89 04 24             	mov    %eax,(%esp)
 985:	e8 ed fe ff ff       	call   877 <morecore>
 98a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 98d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 991:	75 07                	jne    99a <malloc+0xcb>
        return 0;
 993:	b8 00 00 00 00       	mov    $0x0,%eax
 998:	eb 13                	jmp    9ad <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a3:	8b 00                	mov    (%eax),%eax
 9a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9a8:	e9 70 ff ff ff       	jmp    91d <malloc+0x4e>
}
 9ad:	c9                   	leave  
 9ae:	c3                   	ret    
