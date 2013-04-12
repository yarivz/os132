
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 0a 04 00 00       	call   418 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 a2 04 00 00       	call   4c0 <sleep>
  exit();
  1e:	e8 fd 03 00 00       	call   420 <exit>
  23:	90                   	nop

00000024 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	57                   	push   %edi
  28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2c:	8b 55 10             	mov    0x10(%ebp),%edx
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	89 cb                	mov    %ecx,%ebx
  34:	89 df                	mov    %ebx,%edi
  36:	89 d1                	mov    %edx,%ecx
  38:	fc                   	cld    
  39:	f3 aa                	rep stos %al,%es:(%edi)
  3b:	89 ca                	mov    %ecx,%edx
  3d:	89 fb                	mov    %edi,%ebx
  3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  45:	5b                   	pop    %ebx
  46:	5f                   	pop    %edi
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    

00000049 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  49:	55                   	push   %ebp
  4a:	89 e5                	mov    %esp,%ebp
  4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  4f:	8b 45 08             	mov    0x8(%ebp),%eax
  52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  55:	90                   	nop
  56:	8b 45 0c             	mov    0xc(%ebp),%eax
  59:	0f b6 10             	movzbl (%eax),%edx
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	88 10                	mov    %dl,(%eax)
  61:	8b 45 08             	mov    0x8(%ebp),%eax
  64:	0f b6 00             	movzbl (%eax),%eax
  67:	84 c0                	test   %al,%al
  69:	0f 95 c0             	setne  %al
  6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  74:	84 c0                	test   %al,%al
  76:	75 de                	jne    56 <strcpy+0xd>
    ;
  return os;
  78:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  7b:	c9                   	leave  
  7c:	c3                   	ret    

0000007d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  80:	eb 08                	jmp    8a <strcmp+0xd>
    p++, q++;
  82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  8a:	8b 45 08             	mov    0x8(%ebp),%eax
  8d:	0f b6 00             	movzbl (%eax),%eax
  90:	84 c0                	test   %al,%al
  92:	74 10                	je     a4 <strcmp+0x27>
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	0f b6 10             	movzbl (%eax),%edx
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	0f b6 00             	movzbl (%eax),%eax
  a0:	38 c2                	cmp    %al,%dl
  a2:	74 de                	je     82 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	0f b6 00             	movzbl (%eax),%eax
  aa:	0f b6 d0             	movzbl %al,%edx
  ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	0f b6 c0             	movzbl %al,%eax
  b6:	89 d1                	mov    %edx,%ecx
  b8:	29 c1                	sub    %eax,%ecx
  ba:	89 c8                	mov    %ecx,%eax
}
  bc:	5d                   	pop    %ebp
  bd:	c3                   	ret    

000000be <strlen>:

uint
strlen(char *s)
{
  be:	55                   	push   %ebp
  bf:	89 e5                	mov    %esp,%ebp
  c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
  c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  cb:	eb 04                	jmp    d1 <strlen+0x13>
  cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  d4:	03 45 08             	add    0x8(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	84 c0                	test   %al,%al
  dc:	75 ef                	jne    cd <strlen+0xf>
  return n;
  de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e1:	c9                   	leave  
  e2:	c3                   	ret    

000000e3 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  e9:	8b 45 10             	mov    0x10(%ebp),%eax
  ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  f7:	8b 45 08             	mov    0x8(%ebp),%eax
  fa:	89 04 24             	mov    %eax,(%esp)
  fd:	e8 22 ff ff ff       	call   24 <stosb>
  return dst;
 102:	8b 45 08             	mov    0x8(%ebp),%eax
}
 105:	c9                   	leave  
 106:	c3                   	ret    

00000107 <strchr>:

char*
strchr(const char *s, char c)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 04             	sub    $0x4,%esp
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 113:	eb 14                	jmp    129 <strchr+0x22>
    if(*s == c)
 115:	8b 45 08             	mov    0x8(%ebp),%eax
 118:	0f b6 00             	movzbl (%eax),%eax
 11b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 11e:	75 05                	jne    125 <strchr+0x1e>
      return (char*)s;
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	eb 13                	jmp    138 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 125:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 129:	8b 45 08             	mov    0x8(%ebp),%eax
 12c:	0f b6 00             	movzbl (%eax),%eax
 12f:	84 c0                	test   %al,%al
 131:	75 e2                	jne    115 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 133:	b8 00 00 00 00       	mov    $0x0,%eax
}
 138:	c9                   	leave  
 139:	c3                   	ret    

0000013a <gets>:

char*
gets(char *buf, int max)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 140:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 147:	eb 44                	jmp    18d <gets+0x53>
    cc = read(0, &c, 1);
 149:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 150:	00 
 151:	8d 45 ef             	lea    -0x11(%ebp),%eax
 154:	89 44 24 04          	mov    %eax,0x4(%esp)
 158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 15f:	e8 e4 02 00 00       	call   448 <read>
 164:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 167:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 16b:	7e 2d                	jle    19a <gets+0x60>
      break;
    buf[i++] = c;
 16d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 170:	03 45 08             	add    0x8(%ebp),%eax
 173:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 177:	88 10                	mov    %dl,(%eax)
 179:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 17d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 181:	3c 0a                	cmp    $0xa,%al
 183:	74 16                	je     19b <gets+0x61>
 185:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 189:	3c 0d                	cmp    $0xd,%al
 18b:	74 0e                	je     19b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 190:	83 c0 01             	add    $0x1,%eax
 193:	3b 45 0c             	cmp    0xc(%ebp),%eax
 196:	7c b1                	jl     149 <gets+0xf>
 198:	eb 01                	jmp    19b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 19a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 19b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19e:	03 45 08             	add    0x8(%ebp),%eax
 1a1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a7:	c9                   	leave  
 1a8:	c3                   	ret    

000001a9 <stat>:

int
stat(char *n, struct stat *st)
{
 1a9:	55                   	push   %ebp
 1aa:	89 e5                	mov    %esp,%ebp
 1ac:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1b6:	00 
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 ae 02 00 00       	call   470 <open>
 1c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c9:	79 07                	jns    1d2 <stat+0x29>
    return -1;
 1cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1d0:	eb 23                	jmp    1f5 <stat+0x4c>
  r = fstat(fd, st);
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	89 04 24             	mov    %eax,(%esp)
 1df:	e8 a4 02 00 00       	call   488 <fstat>
 1e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ea:	89 04 24             	mov    %eax,(%esp)
 1ed:	e8 66 02 00 00       	call   458 <close>
  return r;
 1f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1f5:	c9                   	leave  
 1f6:	c3                   	ret    

000001f7 <atoi>:

int
atoi(const char *s)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 204:	eb 23                	jmp    229 <atoi+0x32>
    n = n*10 + *s++ - '0';
 206:	8b 55 fc             	mov    -0x4(%ebp),%edx
 209:	89 d0                	mov    %edx,%eax
 20b:	c1 e0 02             	shl    $0x2,%eax
 20e:	01 d0                	add    %edx,%eax
 210:	01 c0                	add    %eax,%eax
 212:	89 c2                	mov    %eax,%edx
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	0f b6 00             	movzbl (%eax),%eax
 21a:	0f be c0             	movsbl %al,%eax
 21d:	01 d0                	add    %edx,%eax
 21f:	83 e8 30             	sub    $0x30,%eax
 222:	89 45 fc             	mov    %eax,-0x4(%ebp)
 225:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	3c 2f                	cmp    $0x2f,%al
 231:	7e 0a                	jle    23d <atoi+0x46>
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	3c 39                	cmp    $0x39,%al
 23b:	7e c9                	jle    206 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 23d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 240:	c9                   	leave  
 241:	c3                   	ret    

00000242 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 242:	55                   	push   %ebp
 243:	89 e5                	mov    %esp,%ebp
 245:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 254:	eb 13                	jmp    269 <memmove+0x27>
    *dst++ = *src++;
 256:	8b 45 f8             	mov    -0x8(%ebp),%eax
 259:	0f b6 10             	movzbl (%eax),%edx
 25c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 25f:	88 10                	mov    %dl,(%eax)
 261:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 265:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 269:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 26d:	0f 9f c0             	setg   %al
 270:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 274:	84 c0                	test   %al,%al
 276:	75 de                	jne    256 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 278:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27b:	c9                   	leave  
 27c:	c3                   	ret    

0000027d <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 27d:	55                   	push   %ebp
 27e:	89 e5                	mov    %esp,%ebp
 280:	83 ec 38             	sub    $0x38,%esp
 283:	8b 45 10             	mov    0x10(%ebp),%eax
 286:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 289:	8b 45 14             	mov    0x14(%ebp),%eax
 28c:	8b 00                	mov    (%eax),%eax
 28e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 291:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 298:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 29c:	74 06                	je     2a4 <strtok+0x27>
 29e:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 2a2:	75 54                	jne    2f8 <strtok+0x7b>
    return match;
 2a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2a7:	eb 6e                	jmp    317 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 2a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ac:	03 45 0c             	add    0xc(%ebp),%eax
 2af:	0f b6 00             	movzbl (%eax),%eax
 2b2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 2b5:	74 06                	je     2bd <strtok+0x40>
      {
	index++;
 2b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2bb:	eb 3c                	jmp    2f9 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 2bd:	8b 45 14             	mov    0x14(%ebp),%eax
 2c0:	8b 00                	mov    (%eax),%eax
 2c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2c5:	29 c2                	sub    %eax,%edx
 2c7:	8b 45 14             	mov    0x14(%ebp),%eax
 2ca:	8b 00                	mov    (%eax),%eax
 2cc:	03 45 0c             	add    0xc(%ebp),%eax
 2cf:	89 54 24 08          	mov    %edx,0x8(%esp)
 2d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
 2da:	89 04 24             	mov    %eax,(%esp)
 2dd:	e8 37 00 00 00       	call   319 <strncpy>
 2e2:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	84 c0                	test   %al,%al
 2ed:	74 19                	je     308 <strtok+0x8b>
	  match = 1;
 2ef:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 2f6:	eb 10                	jmp    308 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 2f8:	90                   	nop
 2f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fc:	03 45 0c             	add    0xc(%ebp),%eax
 2ff:	0f b6 00             	movzbl (%eax),%eax
 302:	84 c0                	test   %al,%al
 304:	75 a3                	jne    2a9 <strtok+0x2c>
 306:	eb 01                	jmp    309 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 308:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 309:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30c:	8d 50 01             	lea    0x1(%eax),%edx
 30f:	8b 45 14             	mov    0x14(%ebp),%eax
 312:	89 10                	mov    %edx,(%eax)
  return match;
 314:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 317:	c9                   	leave  
 318:	c3                   	ret    

00000319 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 319:	55                   	push   %ebp
 31a:	89 e5                	mov    %esp,%ebp
 31c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 325:	90                   	nop
 326:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 32a:	0f 9f c0             	setg   %al
 32d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 331:	84 c0                	test   %al,%al
 333:	74 30                	je     365 <strncpy+0x4c>
 335:	8b 45 0c             	mov    0xc(%ebp),%eax
 338:	0f b6 10             	movzbl (%eax),%edx
 33b:	8b 45 08             	mov    0x8(%ebp),%eax
 33e:	88 10                	mov    %dl,(%eax)
 340:	8b 45 08             	mov    0x8(%ebp),%eax
 343:	0f b6 00             	movzbl (%eax),%eax
 346:	84 c0                	test   %al,%al
 348:	0f 95 c0             	setne  %al
 34b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 34f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 353:	84 c0                	test   %al,%al
 355:	75 cf                	jne    326 <strncpy+0xd>
    ;
  while(n-- > 0)
 357:	eb 0c                	jmp    365 <strncpy+0x4c>
    *s++ = 0;
 359:	8b 45 08             	mov    0x8(%ebp),%eax
 35c:	c6 00 00             	movb   $0x0,(%eax)
 35f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 363:	eb 01                	jmp    366 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 365:	90                   	nop
 366:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 36a:	0f 9f c0             	setg   %al
 36d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 371:	84 c0                	test   %al,%al
 373:	75 e4                	jne    359 <strncpy+0x40>
    *s++ = 0;
  return os;
 375:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 378:	c9                   	leave  
 379:	c3                   	ret    

0000037a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 37a:	55                   	push   %ebp
 37b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 37d:	eb 0c                	jmp    38b <strncmp+0x11>
    n--, p++, q++;
 37f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 383:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 387:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 38b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 38f:	74 1a                	je     3ab <strncmp+0x31>
 391:	8b 45 08             	mov    0x8(%ebp),%eax
 394:	0f b6 00             	movzbl (%eax),%eax
 397:	84 c0                	test   %al,%al
 399:	74 10                	je     3ab <strncmp+0x31>
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	0f b6 10             	movzbl (%eax),%edx
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	0f b6 00             	movzbl (%eax),%eax
 3a7:	38 c2                	cmp    %al,%dl
 3a9:	74 d4                	je     37f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 3ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3af:	75 07                	jne    3b8 <strncmp+0x3e>
    return 0;
 3b1:	b8 00 00 00 00       	mov    $0x0,%eax
 3b6:	eb 18                	jmp    3d0 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
 3bb:	0f b6 00             	movzbl (%eax),%eax
 3be:	0f b6 d0             	movzbl %al,%edx
 3c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c4:	0f b6 00             	movzbl (%eax),%eax
 3c7:	0f b6 c0             	movzbl %al,%eax
 3ca:	89 d1                	mov    %edx,%ecx
 3cc:	29 c1                	sub    %eax,%ecx
 3ce:	89 c8                	mov    %ecx,%eax
}
 3d0:	5d                   	pop    %ebp
 3d1:	c3                   	ret    

000003d2 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 3d2:	55                   	push   %ebp
 3d3:	89 e5                	mov    %esp,%ebp
  while(*p){
 3d5:	eb 13                	jmp    3ea <strcat+0x18>
    *dest++ = *p++;
 3d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3da:	0f b6 10             	movzbl (%eax),%edx
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
 3e0:	88 10                	mov    %dl,(%eax)
 3e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 3ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ed:	0f b6 00             	movzbl (%eax),%eax
 3f0:	84 c0                	test   %al,%al
 3f2:	75 e3                	jne    3d7 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 3f4:	eb 13                	jmp    409 <strcat+0x37>
    *dest++ = *q++;
 3f6:	8b 45 10             	mov    0x10(%ebp),%eax
 3f9:	0f b6 10             	movzbl (%eax),%edx
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
 3ff:	88 10                	mov    %dl,(%eax)
 401:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 405:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 409:	8b 45 10             	mov    0x10(%ebp),%eax
 40c:	0f b6 00             	movzbl (%eax),%eax
 40f:	84 c0                	test   %al,%al
 411:	75 e3                	jne    3f6 <strcat+0x24>
    *dest++ = *q++;
  }  
 413:	5d                   	pop    %ebp
 414:	c3                   	ret    
 415:	90                   	nop
 416:	90                   	nop
 417:	90                   	nop

00000418 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 418:	b8 01 00 00 00       	mov    $0x1,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <exit>:
SYSCALL(exit)
 420:	b8 02 00 00 00       	mov    $0x2,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <wait>:
SYSCALL(wait)
 428:	b8 03 00 00 00       	mov    $0x3,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <wait2>:
SYSCALL(wait2)
 430:	b8 16 00 00 00       	mov    $0x16,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <nice>:
SYSCALL(nice)
 438:	b8 17 00 00 00       	mov    $0x17,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <pipe>:
SYSCALL(pipe)
 440:	b8 04 00 00 00       	mov    $0x4,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <read>:
SYSCALL(read)
 448:	b8 05 00 00 00       	mov    $0x5,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <write>:
SYSCALL(write)
 450:	b8 10 00 00 00       	mov    $0x10,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <close>:
SYSCALL(close)
 458:	b8 15 00 00 00       	mov    $0x15,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <kill>:
SYSCALL(kill)
 460:	b8 06 00 00 00       	mov    $0x6,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <exec>:
SYSCALL(exec)
 468:	b8 07 00 00 00       	mov    $0x7,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <open>:
SYSCALL(open)
 470:	b8 0f 00 00 00       	mov    $0xf,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <mknod>:
SYSCALL(mknod)
 478:	b8 11 00 00 00       	mov    $0x11,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <unlink>:
SYSCALL(unlink)
 480:	b8 12 00 00 00       	mov    $0x12,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <fstat>:
SYSCALL(fstat)
 488:	b8 08 00 00 00       	mov    $0x8,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <link>:
SYSCALL(link)
 490:	b8 13 00 00 00       	mov    $0x13,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <mkdir>:
SYSCALL(mkdir)
 498:	b8 14 00 00 00       	mov    $0x14,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <chdir>:
SYSCALL(chdir)
 4a0:	b8 09 00 00 00       	mov    $0x9,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <dup>:
SYSCALL(dup)
 4a8:	b8 0a 00 00 00       	mov    $0xa,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <getpid>:
SYSCALL(getpid)
 4b0:	b8 0b 00 00 00       	mov    $0xb,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <sbrk>:
SYSCALL(sbrk)
 4b8:	b8 0c 00 00 00       	mov    $0xc,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <sleep>:
SYSCALL(sleep)
 4c0:	b8 0d 00 00 00       	mov    $0xd,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <uptime>:
SYSCALL(uptime)
 4c8:	b8 0e 00 00 00       	mov    $0xe,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	83 ec 28             	sub    $0x28,%esp
 4d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4e3:	00 
 4e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	89 04 24             	mov    %eax,(%esp)
 4f1:	e8 5a ff ff ff       	call   450 <write>
}
 4f6:	c9                   	leave  
 4f7:	c3                   	ret    

000004f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f8:	55                   	push   %ebp
 4f9:	89 e5                	mov    %esp,%ebp
 4fb:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 505:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 509:	74 17                	je     522 <printint+0x2a>
 50b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 50f:	79 11                	jns    522 <printint+0x2a>
    neg = 1;
 511:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 518:	8b 45 0c             	mov    0xc(%ebp),%eax
 51b:	f7 d8                	neg    %eax
 51d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 520:	eb 06                	jmp    528 <printint+0x30>
  } else {
    x = xx;
 522:	8b 45 0c             	mov    0xc(%ebp),%eax
 525:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 528:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 52f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 532:	8b 45 ec             	mov    -0x14(%ebp),%eax
 535:	ba 00 00 00 00       	mov    $0x0,%edx
 53a:	f7 f1                	div    %ecx
 53c:	89 d0                	mov    %edx,%eax
 53e:	0f b6 90 30 0c 00 00 	movzbl 0xc30(%eax),%edx
 545:	8d 45 dc             	lea    -0x24(%ebp),%eax
 548:	03 45 f4             	add    -0xc(%ebp),%eax
 54b:	88 10                	mov    %dl,(%eax)
 54d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 551:	8b 55 10             	mov    0x10(%ebp),%edx
 554:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 557:	8b 45 ec             	mov    -0x14(%ebp),%eax
 55a:	ba 00 00 00 00       	mov    $0x0,%edx
 55f:	f7 75 d4             	divl   -0x2c(%ebp)
 562:	89 45 ec             	mov    %eax,-0x14(%ebp)
 565:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 569:	75 c4                	jne    52f <printint+0x37>
  if(neg)
 56b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 56f:	74 2a                	je     59b <printint+0xa3>
    buf[i++] = '-';
 571:	8d 45 dc             	lea    -0x24(%ebp),%eax
 574:	03 45 f4             	add    -0xc(%ebp),%eax
 577:	c6 00 2d             	movb   $0x2d,(%eax)
 57a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 57e:	eb 1b                	jmp    59b <printint+0xa3>
    putc(fd, buf[i]);
 580:	8d 45 dc             	lea    -0x24(%ebp),%eax
 583:	03 45 f4             	add    -0xc(%ebp),%eax
 586:	0f b6 00             	movzbl (%eax),%eax
 589:	0f be c0             	movsbl %al,%eax
 58c:	89 44 24 04          	mov    %eax,0x4(%esp)
 590:	8b 45 08             	mov    0x8(%ebp),%eax
 593:	89 04 24             	mov    %eax,(%esp)
 596:	e8 35 ff ff ff       	call   4d0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 59b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 59f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a3:	79 db                	jns    580 <printint+0x88>
    putc(fd, buf[i]);
}
 5a5:	c9                   	leave  
 5a6:	c3                   	ret    

000005a7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5a7:	55                   	push   %ebp
 5a8:	89 e5                	mov    %esp,%ebp
 5aa:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5b4:	8d 45 0c             	lea    0xc(%ebp),%eax
 5b7:	83 c0 04             	add    $0x4,%eax
 5ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5c4:	e9 7d 01 00 00       	jmp    746 <printf+0x19f>
    c = fmt[i] & 0xff;
 5c9:	8b 55 0c             	mov    0xc(%ebp),%edx
 5cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5cf:	01 d0                	add    %edx,%eax
 5d1:	0f b6 00             	movzbl (%eax),%eax
 5d4:	0f be c0             	movsbl %al,%eax
 5d7:	25 ff 00 00 00       	and    $0xff,%eax
 5dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e3:	75 2c                	jne    611 <printf+0x6a>
      if(c == '%'){
 5e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5e9:	75 0c                	jne    5f7 <printf+0x50>
        state = '%';
 5eb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5f2:	e9 4b 01 00 00       	jmp    742 <printf+0x19b>
      } else {
        putc(fd, c);
 5f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fa:	0f be c0             	movsbl %al,%eax
 5fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 601:	8b 45 08             	mov    0x8(%ebp),%eax
 604:	89 04 24             	mov    %eax,(%esp)
 607:	e8 c4 fe ff ff       	call   4d0 <putc>
 60c:	e9 31 01 00 00       	jmp    742 <printf+0x19b>
      }
    } else if(state == '%'){
 611:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 615:	0f 85 27 01 00 00    	jne    742 <printf+0x19b>
      if(c == 'd'){
 61b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 61f:	75 2d                	jne    64e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 621:	8b 45 e8             	mov    -0x18(%ebp),%eax
 624:	8b 00                	mov    (%eax),%eax
 626:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 62d:	00 
 62e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 635:	00 
 636:	89 44 24 04          	mov    %eax,0x4(%esp)
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	89 04 24             	mov    %eax,(%esp)
 640:	e8 b3 fe ff ff       	call   4f8 <printint>
        ap++;
 645:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 649:	e9 ed 00 00 00       	jmp    73b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 64e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 652:	74 06                	je     65a <printf+0xb3>
 654:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 658:	75 2d                	jne    687 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 65a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65d:	8b 00                	mov    (%eax),%eax
 65f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 666:	00 
 667:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 66e:	00 
 66f:	89 44 24 04          	mov    %eax,0x4(%esp)
 673:	8b 45 08             	mov    0x8(%ebp),%eax
 676:	89 04 24             	mov    %eax,(%esp)
 679:	e8 7a fe ff ff       	call   4f8 <printint>
        ap++;
 67e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 682:	e9 b4 00 00 00       	jmp    73b <printf+0x194>
      } else if(c == 's'){
 687:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 68b:	75 46                	jne    6d3 <printf+0x12c>
        s = (char*)*ap;
 68d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 690:	8b 00                	mov    (%eax),%eax
 692:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 695:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 699:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 69d:	75 27                	jne    6c6 <printf+0x11f>
          s = "(null)";
 69f:	c7 45 f4 6b 09 00 00 	movl   $0x96b,-0xc(%ebp)
        while(*s != 0){
 6a6:	eb 1e                	jmp    6c6 <printf+0x11f>
          putc(fd, *s);
 6a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ab:	0f b6 00             	movzbl (%eax),%eax
 6ae:	0f be c0             	movsbl %al,%eax
 6b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b5:	8b 45 08             	mov    0x8(%ebp),%eax
 6b8:	89 04 24             	mov    %eax,(%esp)
 6bb:	e8 10 fe ff ff       	call   4d0 <putc>
          s++;
 6c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6c4:	eb 01                	jmp    6c7 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6c6:	90                   	nop
 6c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ca:	0f b6 00             	movzbl (%eax),%eax
 6cd:	84 c0                	test   %al,%al
 6cf:	75 d7                	jne    6a8 <printf+0x101>
 6d1:	eb 68                	jmp    73b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6d7:	75 1d                	jne    6f6 <printf+0x14f>
        putc(fd, *ap);
 6d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	0f be c0             	movsbl %al,%eax
 6e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e5:	8b 45 08             	mov    0x8(%ebp),%eax
 6e8:	89 04 24             	mov    %eax,(%esp)
 6eb:	e8 e0 fd ff ff       	call   4d0 <putc>
        ap++;
 6f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f4:	eb 45                	jmp    73b <printf+0x194>
      } else if(c == '%'){
 6f6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6fa:	75 17                	jne    713 <printf+0x16c>
        putc(fd, c);
 6fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ff:	0f be c0             	movsbl %al,%eax
 702:	89 44 24 04          	mov    %eax,0x4(%esp)
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	89 04 24             	mov    %eax,(%esp)
 70c:	e8 bf fd ff ff       	call   4d0 <putc>
 711:	eb 28                	jmp    73b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 713:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 71a:	00 
 71b:	8b 45 08             	mov    0x8(%ebp),%eax
 71e:	89 04 24             	mov    %eax,(%esp)
 721:	e8 aa fd ff ff       	call   4d0 <putc>
        putc(fd, c);
 726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 729:	0f be c0             	movsbl %al,%eax
 72c:	89 44 24 04          	mov    %eax,0x4(%esp)
 730:	8b 45 08             	mov    0x8(%ebp),%eax
 733:	89 04 24             	mov    %eax,(%esp)
 736:	e8 95 fd ff ff       	call   4d0 <putc>
      }
      state = 0;
 73b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 742:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 746:	8b 55 0c             	mov    0xc(%ebp),%edx
 749:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74c:	01 d0                	add    %edx,%eax
 74e:	0f b6 00             	movzbl (%eax),%eax
 751:	84 c0                	test   %al,%al
 753:	0f 85 70 fe ff ff    	jne    5c9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 759:	c9                   	leave  
 75a:	c3                   	ret    
 75b:	90                   	nop

0000075c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75c:	55                   	push   %ebp
 75d:	89 e5                	mov    %esp,%ebp
 75f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 762:	8b 45 08             	mov    0x8(%ebp),%eax
 765:	83 e8 08             	sub    $0x8,%eax
 768:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76b:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 770:	89 45 fc             	mov    %eax,-0x4(%ebp)
 773:	eb 24                	jmp    799 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	8b 00                	mov    (%eax),%eax
 77a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 77d:	77 12                	ja     791 <free+0x35>
 77f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 782:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 785:	77 24                	ja     7ab <free+0x4f>
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 00                	mov    (%eax),%eax
 78c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 78f:	77 1a                	ja     7ab <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	8b 00                	mov    (%eax),%eax
 796:	89 45 fc             	mov    %eax,-0x4(%ebp)
 799:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79f:	76 d4                	jbe    775 <free+0x19>
 7a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a4:	8b 00                	mov    (%eax),%eax
 7a6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a9:	76 ca                	jbe    775 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ae:	8b 40 04             	mov    0x4(%eax),%eax
 7b1:	c1 e0 03             	shl    $0x3,%eax
 7b4:	89 c2                	mov    %eax,%edx
 7b6:	03 55 f8             	add    -0x8(%ebp),%edx
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	39 c2                	cmp    %eax,%edx
 7c0:	75 24                	jne    7e6 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c5:	8b 50 04             	mov    0x4(%eax),%edx
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	8b 00                	mov    (%eax),%eax
 7cd:	8b 40 04             	mov    0x4(%eax),%eax
 7d0:	01 c2                	add    %eax,%edx
 7d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	8b 10                	mov    (%eax),%edx
 7df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e2:	89 10                	mov    %edx,(%eax)
 7e4:	eb 0a                	jmp    7f0 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 7e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e9:	8b 10                	mov    (%eax),%edx
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	8b 40 04             	mov    0x4(%eax),%eax
 7f6:	c1 e0 03             	shl    $0x3,%eax
 7f9:	03 45 fc             	add    -0x4(%ebp),%eax
 7fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ff:	75 20                	jne    821 <free+0xc5>
    p->s.size += bp->s.size;
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	8b 50 04             	mov    0x4(%eax),%edx
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	01 c2                	add    %eax,%edx
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 815:	8b 45 f8             	mov    -0x8(%ebp),%eax
 818:	8b 10                	mov    (%eax),%edx
 81a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81d:	89 10                	mov    %edx,(%eax)
 81f:	eb 08                	jmp    829 <free+0xcd>
  } else
    p->s.ptr = bp;
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 55 f8             	mov    -0x8(%ebp),%edx
 827:	89 10                	mov    %edx,(%eax)
  freep = p;
 829:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82c:	a3 4c 0c 00 00       	mov    %eax,0xc4c
}
 831:	c9                   	leave  
 832:	c3                   	ret    

00000833 <morecore>:

static Header*
morecore(uint nu)
{
 833:	55                   	push   %ebp
 834:	89 e5                	mov    %esp,%ebp
 836:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 839:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 840:	77 07                	ja     849 <morecore+0x16>
    nu = 4096;
 842:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 849:	8b 45 08             	mov    0x8(%ebp),%eax
 84c:	c1 e0 03             	shl    $0x3,%eax
 84f:	89 04 24             	mov    %eax,(%esp)
 852:	e8 61 fc ff ff       	call   4b8 <sbrk>
 857:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 85a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 85e:	75 07                	jne    867 <morecore+0x34>
    return 0;
 860:	b8 00 00 00 00       	mov    $0x0,%eax
 865:	eb 22                	jmp    889 <morecore+0x56>
  hp = (Header*)p;
 867:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 870:	8b 55 08             	mov    0x8(%ebp),%edx
 873:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 876:	8b 45 f0             	mov    -0x10(%ebp),%eax
 879:	83 c0 08             	add    $0x8,%eax
 87c:	89 04 24             	mov    %eax,(%esp)
 87f:	e8 d8 fe ff ff       	call   75c <free>
  return freep;
 884:	a1 4c 0c 00 00       	mov    0xc4c,%eax
}
 889:	c9                   	leave  
 88a:	c3                   	ret    

0000088b <malloc>:

void*
malloc(uint nbytes)
{
 88b:	55                   	push   %ebp
 88c:	89 e5                	mov    %esp,%ebp
 88e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 891:	8b 45 08             	mov    0x8(%ebp),%eax
 894:	83 c0 07             	add    $0x7,%eax
 897:	c1 e8 03             	shr    $0x3,%eax
 89a:	83 c0 01             	add    $0x1,%eax
 89d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8a0:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 8a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ac:	75 23                	jne    8d1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8ae:	c7 45 f0 44 0c 00 00 	movl   $0xc44,-0x10(%ebp)
 8b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b8:	a3 4c 0c 00 00       	mov    %eax,0xc4c
 8bd:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 8c2:	a3 44 0c 00 00       	mov    %eax,0xc44
    base.s.size = 0;
 8c7:	c7 05 48 0c 00 00 00 	movl   $0x0,0xc48
 8ce:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dc:	8b 40 04             	mov    0x4(%eax),%eax
 8df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8e2:	72 4d                	jb     931 <malloc+0xa6>
      if(p->s.size == nunits)
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	8b 40 04             	mov    0x4(%eax),%eax
 8ea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8ed:	75 0c                	jne    8fb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f2:	8b 10                	mov    (%eax),%edx
 8f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f7:	89 10                	mov    %edx,(%eax)
 8f9:	eb 26                	jmp    921 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	8b 40 04             	mov    0x4(%eax),%eax
 901:	89 c2                	mov    %eax,%edx
 903:	2b 55 ec             	sub    -0x14(%ebp),%edx
 906:	8b 45 f4             	mov    -0xc(%ebp),%eax
 909:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90f:	8b 40 04             	mov    0x4(%eax),%eax
 912:	c1 e0 03             	shl    $0x3,%eax
 915:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 91e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 921:	8b 45 f0             	mov    -0x10(%ebp),%eax
 924:	a3 4c 0c 00 00       	mov    %eax,0xc4c
      return (void*)(p + 1);
 929:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92c:	83 c0 08             	add    $0x8,%eax
 92f:	eb 38                	jmp    969 <malloc+0xde>
    }
    if(p == freep)
 931:	a1 4c 0c 00 00       	mov    0xc4c,%eax
 936:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 939:	75 1b                	jne    956 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 93b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 93e:	89 04 24             	mov    %eax,(%esp)
 941:	e8 ed fe ff ff       	call   833 <morecore>
 946:	89 45 f4             	mov    %eax,-0xc(%ebp)
 949:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 94d:	75 07                	jne    956 <malloc+0xcb>
        return 0;
 94f:	b8 00 00 00 00       	mov    $0x0,%eax
 954:	eb 13                	jmp    969 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 956:	8b 45 f4             	mov    -0xc(%ebp),%eax
 959:	89 45 f0             	mov    %eax,-0x10(%ebp)
 95c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95f:	8b 00                	mov    (%eax),%eax
 961:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 964:	e9 70 ff ff ff       	jmp    8d9 <malloc+0x4e>
}
 969:	c9                   	leave  
 96a:	c3                   	ret    
