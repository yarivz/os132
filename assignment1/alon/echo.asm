
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  for(i = 1; i < argc; i++)
   9:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  10:	00 
  11:	eb 4b                	jmp    5e <main+0x5e>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  13:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  17:	83 c0 01             	add    $0x1,%eax
  1a:	3b 45 08             	cmp    0x8(%ebp),%eax
  1d:	7d 07                	jge    26 <main+0x26>
  1f:	b8 d1 09 00 00       	mov    $0x9d1,%eax
  24:	eb 05                	jmp    2b <main+0x2b>
  26:	b8 d3 09 00 00       	mov    $0x9d3,%eax
  2b:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  2f:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  36:	8b 55 0c             	mov    0xc(%ebp),%edx
  39:	01 ca                	add    %ecx,%edx
  3b:	8b 12                	mov    (%edx),%edx
  3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  41:	89 54 24 08          	mov    %edx,0x8(%esp)
  45:	c7 44 24 04 d5 09 00 	movl   $0x9d5,0x4(%esp)
  4c:	00 
  4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  54:	e8 a8 05 00 00       	call   601 <printf>
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
  59:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  5e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  62:	3b 45 08             	cmp    0x8(%ebp),%eax
  65:	7c ac                	jl     13 <main+0x13>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  exit();
  67:	e8 08 04 00 00       	call   474 <exit>

0000006c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  6c:	55                   	push   %ebp
  6d:	89 e5                	mov    %esp,%ebp
  6f:	57                   	push   %edi
  70:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  74:	8b 55 10             	mov    0x10(%ebp),%edx
  77:	8b 45 0c             	mov    0xc(%ebp),%eax
  7a:	89 cb                	mov    %ecx,%ebx
  7c:	89 df                	mov    %ebx,%edi
  7e:	89 d1                	mov    %edx,%ecx
  80:	fc                   	cld    
  81:	f3 aa                	rep stos %al,%es:(%edi)
  83:	89 ca                	mov    %ecx,%edx
  85:	89 fb                	mov    %edi,%ebx
  87:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  8d:	5b                   	pop    %ebx
  8e:	5f                   	pop    %edi
  8f:	5d                   	pop    %ebp
  90:	c3                   	ret    

00000091 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  91:	55                   	push   %ebp
  92:	89 e5                	mov    %esp,%ebp
  94:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  97:	8b 45 08             	mov    0x8(%ebp),%eax
  9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  9d:	90                   	nop
  9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  a1:	0f b6 10             	movzbl (%eax),%edx
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	88 10                	mov    %dl,(%eax)
  a9:	8b 45 08             	mov    0x8(%ebp),%eax
  ac:	0f b6 00             	movzbl (%eax),%eax
  af:	84 c0                	test   %al,%al
  b1:	0f 95 c0             	setne  %al
  b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  b8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  bc:	84 c0                	test   %al,%al
  be:	75 de                	jne    9e <strcpy+0xd>
    ;
  return os;
  c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c3:	c9                   	leave  
  c4:	c3                   	ret    

000000c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c5:	55                   	push   %ebp
  c6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  c8:	eb 08                	jmp    d2 <strcmp+0xd>
    p++, q++;
  ca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ce:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d2:	8b 45 08             	mov    0x8(%ebp),%eax
  d5:	0f b6 00             	movzbl (%eax),%eax
  d8:	84 c0                	test   %al,%al
  da:	74 10                	je     ec <strcmp+0x27>
  dc:	8b 45 08             	mov    0x8(%ebp),%eax
  df:	0f b6 10             	movzbl (%eax),%edx
  e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  e5:	0f b6 00             	movzbl (%eax),%eax
  e8:	38 c2                	cmp    %al,%dl
  ea:	74 de                	je     ca <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  ec:	8b 45 08             	mov    0x8(%ebp),%eax
  ef:	0f b6 00             	movzbl (%eax),%eax
  f2:	0f b6 d0             	movzbl %al,%edx
  f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  f8:	0f b6 00             	movzbl (%eax),%eax
  fb:	0f b6 c0             	movzbl %al,%eax
  fe:	89 d1                	mov    %edx,%ecx
 100:	29 c1                	sub    %eax,%ecx
 102:	89 c8                	mov    %ecx,%eax
}
 104:	5d                   	pop    %ebp
 105:	c3                   	ret    

00000106 <strlen>:

uint
strlen(char *s)
{
 106:	55                   	push   %ebp
 107:	89 e5                	mov    %esp,%ebp
 109:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 10c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 113:	eb 04                	jmp    119 <strlen+0x13>
 115:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 119:	8b 55 fc             	mov    -0x4(%ebp),%edx
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	01 d0                	add    %edx,%eax
 121:	0f b6 00             	movzbl (%eax),%eax
 124:	84 c0                	test   %al,%al
 126:	75 ed                	jne    115 <strlen+0xf>
  return n;
 128:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12b:	c9                   	leave  
 12c:	c3                   	ret    

0000012d <memset>:

void*
memset(void *dst, int c, uint n)
{
 12d:	55                   	push   %ebp
 12e:	89 e5                	mov    %esp,%ebp
 130:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 133:	8b 45 10             	mov    0x10(%ebp),%eax
 136:	89 44 24 08          	mov    %eax,0x8(%esp)
 13a:	8b 45 0c             	mov    0xc(%ebp),%eax
 13d:	89 44 24 04          	mov    %eax,0x4(%esp)
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	89 04 24             	mov    %eax,(%esp)
 147:	e8 20 ff ff ff       	call   6c <stosb>
  return dst;
 14c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14f:	c9                   	leave  
 150:	c3                   	ret    

00000151 <strchr>:

char*
strchr(const char *s, char c)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 ec 04             	sub    $0x4,%esp
 157:	8b 45 0c             	mov    0xc(%ebp),%eax
 15a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 15d:	eb 14                	jmp    173 <strchr+0x22>
    if(*s == c)
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
 162:	0f b6 00             	movzbl (%eax),%eax
 165:	3a 45 fc             	cmp    -0x4(%ebp),%al
 168:	75 05                	jne    16f <strchr+0x1e>
      return (char*)s;
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	eb 13                	jmp    182 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 16f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 173:	8b 45 08             	mov    0x8(%ebp),%eax
 176:	0f b6 00             	movzbl (%eax),%eax
 179:	84 c0                	test   %al,%al
 17b:	75 e2                	jne    15f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 17d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 182:	c9                   	leave  
 183:	c3                   	ret    

00000184 <gets>:

char*
gets(char *buf, int max)
{
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 191:	eb 46                	jmp    1d9 <gets+0x55>
    cc = read(0, &c, 1);
 193:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 19a:	00 
 19b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 19e:	89 44 24 04          	mov    %eax,0x4(%esp)
 1a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1a9:	e8 ee 02 00 00       	call   49c <read>
 1ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b5:	7e 2f                	jle    1e6 <gets+0x62>
      break;
    buf[i++] = c;
 1b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	01 c2                	add    %eax,%edx
 1bf:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c3:	88 02                	mov    %al,(%edx)
 1c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cd:	3c 0a                	cmp    $0xa,%al
 1cf:	74 16                	je     1e7 <gets+0x63>
 1d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d5:	3c 0d                	cmp    $0xd,%al
 1d7:	74 0e                	je     1e7 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	83 c0 01             	add    $0x1,%eax
 1df:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1e2:	7c af                	jl     193 <gets+0xf>
 1e4:	eb 01                	jmp    1e7 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1e6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ea:	8b 45 08             	mov    0x8(%ebp),%eax
 1ed:	01 d0                	add    %edx,%eax
 1ef:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f5:	c9                   	leave  
 1f6:	c3                   	ret    

000001f7 <stat>:

int
stat(char *n, struct stat *st)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 204:	00 
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	89 04 24             	mov    %eax,(%esp)
 20b:	e8 b4 02 00 00       	call   4c4 <open>
 210:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 213:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 217:	79 07                	jns    220 <stat+0x29>
    return -1;
 219:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 21e:	eb 23                	jmp    243 <stat+0x4c>
  r = fstat(fd, st);
 220:	8b 45 0c             	mov    0xc(%ebp),%eax
 223:	89 44 24 04          	mov    %eax,0x4(%esp)
 227:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22a:	89 04 24             	mov    %eax,(%esp)
 22d:	e8 aa 02 00 00       	call   4dc <fstat>
 232:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 235:	8b 45 f4             	mov    -0xc(%ebp),%eax
 238:	89 04 24             	mov    %eax,(%esp)
 23b:	e8 6c 02 00 00       	call   4ac <close>
  return r;
 240:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 243:	c9                   	leave  
 244:	c3                   	ret    

00000245 <atoi>:

int
atoi(const char *s)
{
 245:	55                   	push   %ebp
 246:	89 e5                	mov    %esp,%ebp
 248:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 24b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 252:	eb 23                	jmp    277 <atoi+0x32>
    n = n*10 + *s++ - '0';
 254:	8b 55 fc             	mov    -0x4(%ebp),%edx
 257:	89 d0                	mov    %edx,%eax
 259:	c1 e0 02             	shl    $0x2,%eax
 25c:	01 d0                	add    %edx,%eax
 25e:	01 c0                	add    %eax,%eax
 260:	89 c2                	mov    %eax,%edx
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	0f b6 00             	movzbl (%eax),%eax
 268:	0f be c0             	movsbl %al,%eax
 26b:	01 d0                	add    %edx,%eax
 26d:	83 e8 30             	sub    $0x30,%eax
 270:	89 45 fc             	mov    %eax,-0x4(%ebp)
 273:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	0f b6 00             	movzbl (%eax),%eax
 27d:	3c 2f                	cmp    $0x2f,%al
 27f:	7e 0a                	jle    28b <atoi+0x46>
 281:	8b 45 08             	mov    0x8(%ebp),%eax
 284:	0f b6 00             	movzbl (%eax),%eax
 287:	3c 39                	cmp    $0x39,%al
 289:	7e c9                	jle    254 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 28b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28e:	c9                   	leave  
 28f:	c3                   	ret    

00000290 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 290:	55                   	push   %ebp
 291:	89 e5                	mov    %esp,%ebp
 293:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 296:	8b 45 08             	mov    0x8(%ebp),%eax
 299:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 29c:	8b 45 0c             	mov    0xc(%ebp),%eax
 29f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2a2:	eb 13                	jmp    2b7 <memmove+0x27>
    *dst++ = *src++;
 2a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2a7:	0f b6 10             	movzbl (%eax),%edx
 2aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ad:	88 10                	mov    %dl,(%eax)
 2af:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2b3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2bb:	0f 9f c0             	setg   %al
 2be:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2c2:	84 c0                	test   %al,%al
 2c4:	75 de                	jne    2a4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c9:	c9                   	leave  
 2ca:	c3                   	ret    

000002cb <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 2cb:	55                   	push   %ebp
 2cc:	89 e5                	mov    %esp,%ebp
 2ce:	83 ec 38             	sub    $0x38,%esp
 2d1:	8b 45 10             	mov    0x10(%ebp),%eax
 2d4:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 2d7:	8b 45 14             	mov    0x14(%ebp),%eax
 2da:	8b 00                	mov    (%eax),%eax
 2dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 2e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2ea:	74 06                	je     2f2 <strtok+0x27>
 2ec:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 2f0:	75 5a                	jne    34c <strtok+0x81>
    return match;
 2f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2f5:	eb 76                	jmp    36d <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 2f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 2fd:	01 d0                	add    %edx,%eax
 2ff:	0f b6 00             	movzbl (%eax),%eax
 302:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 305:	74 06                	je     30d <strtok+0x42>
      {
	index++;
 307:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 30b:	eb 40                	jmp    34d <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 30d:	8b 45 14             	mov    0x14(%ebp),%eax
 310:	8b 00                	mov    (%eax),%eax
 312:	8b 55 f4             	mov    -0xc(%ebp),%edx
 315:	29 c2                	sub    %eax,%edx
 317:	8b 45 14             	mov    0x14(%ebp),%eax
 31a:	8b 00                	mov    (%eax),%eax
 31c:	89 c1                	mov    %eax,%ecx
 31e:	8b 45 0c             	mov    0xc(%ebp),%eax
 321:	01 c8                	add    %ecx,%eax
 323:	89 54 24 08          	mov    %edx,0x8(%esp)
 327:	89 44 24 04          	mov    %eax,0x4(%esp)
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
 32e:	89 04 24             	mov    %eax,(%esp)
 331:	e8 39 00 00 00       	call   36f <strncpy>
 336:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 339:	8b 45 08             	mov    0x8(%ebp),%eax
 33c:	0f b6 00             	movzbl (%eax),%eax
 33f:	84 c0                	test   %al,%al
 341:	74 1b                	je     35e <strtok+0x93>
	  match = 1;
 343:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 34a:	eb 12                	jmp    35e <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 34c:	90                   	nop
 34d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 350:	8b 45 0c             	mov    0xc(%ebp),%eax
 353:	01 d0                	add    %edx,%eax
 355:	0f b6 00             	movzbl (%eax),%eax
 358:	84 c0                	test   %al,%al
 35a:	75 9b                	jne    2f7 <strtok+0x2c>
 35c:	eb 01                	jmp    35f <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 35e:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 35f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 362:	8d 50 01             	lea    0x1(%eax),%edx
 365:	8b 45 14             	mov    0x14(%ebp),%eax
 368:	89 10                	mov    %edx,(%eax)
  return match;
 36a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 36f:	55                   	push   %ebp
 370:	89 e5                	mov    %esp,%ebp
 372:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 37b:	90                   	nop
 37c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 380:	0f 9f c0             	setg   %al
 383:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 387:	84 c0                	test   %al,%al
 389:	74 30                	je     3bb <strncpy+0x4c>
 38b:	8b 45 0c             	mov    0xc(%ebp),%eax
 38e:	0f b6 10             	movzbl (%eax),%edx
 391:	8b 45 08             	mov    0x8(%ebp),%eax
 394:	88 10                	mov    %dl,(%eax)
 396:	8b 45 08             	mov    0x8(%ebp),%eax
 399:	0f b6 00             	movzbl (%eax),%eax
 39c:	84 c0                	test   %al,%al
 39e:	0f 95 c0             	setne  %al
 3a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3a9:	84 c0                	test   %al,%al
 3ab:	75 cf                	jne    37c <strncpy+0xd>
    ;
  while(n-- > 0)
 3ad:	eb 0c                	jmp    3bb <strncpy+0x4c>
    *s++ = 0;
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	c6 00 00             	movb   $0x0,(%eax)
 3b5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b9:	eb 01                	jmp    3bc <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3bb:	90                   	nop
 3bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3c0:	0f 9f c0             	setg   %al
 3c3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3c7:	84 c0                	test   %al,%al
 3c9:	75 e4                	jne    3af <strncpy+0x40>
    *s++ = 0;
  return os;
 3cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ce:	c9                   	leave  
 3cf:	c3                   	ret    

000003d0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 3d3:	eb 0c                	jmp    3e1 <strncmp+0x11>
    n--, p++, q++;
 3d5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3dd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 3e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3e5:	74 1a                	je     401 <strncmp+0x31>
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	0f b6 00             	movzbl (%eax),%eax
 3ed:	84 c0                	test   %al,%al
 3ef:	74 10                	je     401 <strncmp+0x31>
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	0f b6 10             	movzbl (%eax),%edx
 3f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fa:	0f b6 00             	movzbl (%eax),%eax
 3fd:	38 c2                	cmp    %al,%dl
 3ff:	74 d4                	je     3d5 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 401:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 405:	75 07                	jne    40e <strncmp+0x3e>
    return 0;
 407:	b8 00 00 00 00       	mov    $0x0,%eax
 40c:	eb 18                	jmp    426 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 40e:	8b 45 08             	mov    0x8(%ebp),%eax
 411:	0f b6 00             	movzbl (%eax),%eax
 414:	0f b6 d0             	movzbl %al,%edx
 417:	8b 45 0c             	mov    0xc(%ebp),%eax
 41a:	0f b6 00             	movzbl (%eax),%eax
 41d:	0f b6 c0             	movzbl %al,%eax
 420:	89 d1                	mov    %edx,%ecx
 422:	29 c1                	sub    %eax,%ecx
 424:	89 c8                	mov    %ecx,%eax
}
 426:	5d                   	pop    %ebp
 427:	c3                   	ret    

00000428 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 428:	55                   	push   %ebp
 429:	89 e5                	mov    %esp,%ebp
  while(*p){
 42b:	eb 13                	jmp    440 <strcat+0x18>
    *dest++ = *p++;
 42d:	8b 45 0c             	mov    0xc(%ebp),%eax
 430:	0f b6 10             	movzbl (%eax),%edx
 433:	8b 45 08             	mov    0x8(%ebp),%eax
 436:	88 10                	mov    %dl,(%eax)
 438:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 440:	8b 45 0c             	mov    0xc(%ebp),%eax
 443:	0f b6 00             	movzbl (%eax),%eax
 446:	84 c0                	test   %al,%al
 448:	75 e3                	jne    42d <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 44a:	eb 13                	jmp    45f <strcat+0x37>
    *dest++ = *q++;
 44c:	8b 45 10             	mov    0x10(%ebp),%eax
 44f:	0f b6 10             	movzbl (%eax),%edx
 452:	8b 45 08             	mov    0x8(%ebp),%eax
 455:	88 10                	mov    %dl,(%eax)
 457:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 45f:	8b 45 10             	mov    0x10(%ebp),%eax
 462:	0f b6 00             	movzbl (%eax),%eax
 465:	84 c0                	test   %al,%al
 467:	75 e3                	jne    44c <strcat+0x24>
    *dest++ = *q++;
  }  
 469:	5d                   	pop    %ebp
 46a:	c3                   	ret    
 46b:	90                   	nop

0000046c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 46c:	b8 01 00 00 00       	mov    $0x1,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <exit>:
SYSCALL(exit)
 474:	b8 02 00 00 00       	mov    $0x2,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <wait>:
SYSCALL(wait)
 47c:	b8 03 00 00 00       	mov    $0x3,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <wait2>:
SYSCALL(wait2)
 484:	b8 16 00 00 00       	mov    $0x16,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <nice>:
SYSCALL(nice)
 48c:	b8 17 00 00 00       	mov    $0x17,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <pipe>:
SYSCALL(pipe)
 494:	b8 04 00 00 00       	mov    $0x4,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <read>:
SYSCALL(read)
 49c:	b8 05 00 00 00       	mov    $0x5,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <write>:
SYSCALL(write)
 4a4:	b8 10 00 00 00       	mov    $0x10,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <close>:
SYSCALL(close)
 4ac:	b8 15 00 00 00       	mov    $0x15,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <kill>:
SYSCALL(kill)
 4b4:	b8 06 00 00 00       	mov    $0x6,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <exec>:
SYSCALL(exec)
 4bc:	b8 07 00 00 00       	mov    $0x7,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <open>:
SYSCALL(open)
 4c4:	b8 0f 00 00 00       	mov    $0xf,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <mknod>:
SYSCALL(mknod)
 4cc:	b8 11 00 00 00       	mov    $0x11,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <unlink>:
SYSCALL(unlink)
 4d4:	b8 12 00 00 00       	mov    $0x12,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <fstat>:
SYSCALL(fstat)
 4dc:	b8 08 00 00 00       	mov    $0x8,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <link>:
SYSCALL(link)
 4e4:	b8 13 00 00 00       	mov    $0x13,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <mkdir>:
SYSCALL(mkdir)
 4ec:	b8 14 00 00 00       	mov    $0x14,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <chdir>:
SYSCALL(chdir)
 4f4:	b8 09 00 00 00       	mov    $0x9,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <dup>:
SYSCALL(dup)
 4fc:	b8 0a 00 00 00       	mov    $0xa,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <getpid>:
SYSCALL(getpid)
 504:	b8 0b 00 00 00       	mov    $0xb,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <sbrk>:
SYSCALL(sbrk)
 50c:	b8 0c 00 00 00       	mov    $0xc,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <sleep>:
SYSCALL(sleep)
 514:	b8 0d 00 00 00       	mov    $0xd,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <uptime>:
SYSCALL(uptime)
 51c:	b8 0e 00 00 00       	mov    $0xe,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 524:	55                   	push   %ebp
 525:	89 e5                	mov    %esp,%ebp
 527:	83 ec 28             	sub    $0x28,%esp
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 530:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 537:	00 
 538:	8d 45 f4             	lea    -0xc(%ebp),%eax
 53b:	89 44 24 04          	mov    %eax,0x4(%esp)
 53f:	8b 45 08             	mov    0x8(%ebp),%eax
 542:	89 04 24             	mov    %eax,(%esp)
 545:	e8 5a ff ff ff       	call   4a4 <write>
}
 54a:	c9                   	leave  
 54b:	c3                   	ret    

0000054c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 54c:	55                   	push   %ebp
 54d:	89 e5                	mov    %esp,%ebp
 54f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 552:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 559:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 55d:	74 17                	je     576 <printint+0x2a>
 55f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 563:	79 11                	jns    576 <printint+0x2a>
    neg = 1;
 565:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 56c:	8b 45 0c             	mov    0xc(%ebp),%eax
 56f:	f7 d8                	neg    %eax
 571:	89 45 ec             	mov    %eax,-0x14(%ebp)
 574:	eb 06                	jmp    57c <printint+0x30>
  } else {
    x = xx;
 576:	8b 45 0c             	mov    0xc(%ebp),%eax
 579:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 57c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 583:	8b 4d 10             	mov    0x10(%ebp),%ecx
 586:	8b 45 ec             	mov    -0x14(%ebp),%eax
 589:	ba 00 00 00 00       	mov    $0x0,%edx
 58e:	f7 f1                	div    %ecx
 590:	89 d0                	mov    %edx,%eax
 592:	0f b6 80 a0 0c 00 00 	movzbl 0xca0(%eax),%eax
 599:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 59c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 59f:	01 ca                	add    %ecx,%edx
 5a1:	88 02                	mov    %al,(%edx)
 5a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5a7:	8b 55 10             	mov    0x10(%ebp),%edx
 5aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b0:	ba 00 00 00 00       	mov    $0x0,%edx
 5b5:	f7 75 d4             	divl   -0x2c(%ebp)
 5b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5bf:	75 c2                	jne    583 <printint+0x37>
  if(neg)
 5c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c5:	74 2e                	je     5f5 <printint+0xa9>
    buf[i++] = '-';
 5c7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cd:	01 d0                	add    %edx,%eax
 5cf:	c6 00 2d             	movb   $0x2d,(%eax)
 5d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5d6:	eb 1d                	jmp    5f5 <printint+0xa9>
    putc(fd, buf[i]);
 5d8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5de:	01 d0                	add    %edx,%eax
 5e0:	0f b6 00             	movzbl (%eax),%eax
 5e3:	0f be c0             	movsbl %al,%eax
 5e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ea:	8b 45 08             	mov    0x8(%ebp),%eax
 5ed:	89 04 24             	mov    %eax,(%esp)
 5f0:	e8 2f ff ff ff       	call   524 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5f5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fd:	79 d9                	jns    5d8 <printint+0x8c>
    putc(fd, buf[i]);
}
 5ff:	c9                   	leave  
 600:	c3                   	ret    

00000601 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 601:	55                   	push   %ebp
 602:	89 e5                	mov    %esp,%ebp
 604:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 607:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 60e:	8d 45 0c             	lea    0xc(%ebp),%eax
 611:	83 c0 04             	add    $0x4,%eax
 614:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 617:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 61e:	e9 7d 01 00 00       	jmp    7a0 <printf+0x19f>
    c = fmt[i] & 0xff;
 623:	8b 55 0c             	mov    0xc(%ebp),%edx
 626:	8b 45 f0             	mov    -0x10(%ebp),%eax
 629:	01 d0                	add    %edx,%eax
 62b:	0f b6 00             	movzbl (%eax),%eax
 62e:	0f be c0             	movsbl %al,%eax
 631:	25 ff 00 00 00       	and    $0xff,%eax
 636:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 639:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63d:	75 2c                	jne    66b <printf+0x6a>
      if(c == '%'){
 63f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 643:	75 0c                	jne    651 <printf+0x50>
        state = '%';
 645:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 64c:	e9 4b 01 00 00       	jmp    79c <printf+0x19b>
      } else {
        putc(fd, c);
 651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 654:	0f be c0             	movsbl %al,%eax
 657:	89 44 24 04          	mov    %eax,0x4(%esp)
 65b:	8b 45 08             	mov    0x8(%ebp),%eax
 65e:	89 04 24             	mov    %eax,(%esp)
 661:	e8 be fe ff ff       	call   524 <putc>
 666:	e9 31 01 00 00       	jmp    79c <printf+0x19b>
      }
    } else if(state == '%'){
 66b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 66f:	0f 85 27 01 00 00    	jne    79c <printf+0x19b>
      if(c == 'd'){
 675:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 679:	75 2d                	jne    6a8 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 67b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67e:	8b 00                	mov    (%eax),%eax
 680:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 687:	00 
 688:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 68f:	00 
 690:	89 44 24 04          	mov    %eax,0x4(%esp)
 694:	8b 45 08             	mov    0x8(%ebp),%eax
 697:	89 04 24             	mov    %eax,(%esp)
 69a:	e8 ad fe ff ff       	call   54c <printint>
        ap++;
 69f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a3:	e9 ed 00 00 00       	jmp    795 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6a8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ac:	74 06                	je     6b4 <printf+0xb3>
 6ae:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b2:	75 2d                	jne    6e1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b7:	8b 00                	mov    (%eax),%eax
 6b9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6c0:	00 
 6c1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6c8:	00 
 6c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cd:	8b 45 08             	mov    0x8(%ebp),%eax
 6d0:	89 04 24             	mov    %eax,(%esp)
 6d3:	e8 74 fe ff ff       	call   54c <printint>
        ap++;
 6d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6dc:	e9 b4 00 00 00       	jmp    795 <printf+0x194>
      } else if(c == 's'){
 6e1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e5:	75 46                	jne    72d <printf+0x12c>
        s = (char*)*ap;
 6e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ea:	8b 00                	mov    (%eax),%eax
 6ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f7:	75 27                	jne    720 <printf+0x11f>
          s = "(null)";
 6f9:	c7 45 f4 da 09 00 00 	movl   $0x9da,-0xc(%ebp)
        while(*s != 0){
 700:	eb 1e                	jmp    720 <printf+0x11f>
          putc(fd, *s);
 702:	8b 45 f4             	mov    -0xc(%ebp),%eax
 705:	0f b6 00             	movzbl (%eax),%eax
 708:	0f be c0             	movsbl %al,%eax
 70b:	89 44 24 04          	mov    %eax,0x4(%esp)
 70f:	8b 45 08             	mov    0x8(%ebp),%eax
 712:	89 04 24             	mov    %eax,(%esp)
 715:	e8 0a fe ff ff       	call   524 <putc>
          s++;
 71a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 71e:	eb 01                	jmp    721 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 720:	90                   	nop
 721:	8b 45 f4             	mov    -0xc(%ebp),%eax
 724:	0f b6 00             	movzbl (%eax),%eax
 727:	84 c0                	test   %al,%al
 729:	75 d7                	jne    702 <printf+0x101>
 72b:	eb 68                	jmp    795 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 72d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 731:	75 1d                	jne    750 <printf+0x14f>
        putc(fd, *ap);
 733:	8b 45 e8             	mov    -0x18(%ebp),%eax
 736:	8b 00                	mov    (%eax),%eax
 738:	0f be c0             	movsbl %al,%eax
 73b:	89 44 24 04          	mov    %eax,0x4(%esp)
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	89 04 24             	mov    %eax,(%esp)
 745:	e8 da fd ff ff       	call   524 <putc>
        ap++;
 74a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74e:	eb 45                	jmp    795 <printf+0x194>
      } else if(c == '%'){
 750:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 754:	75 17                	jne    76d <printf+0x16c>
        putc(fd, c);
 756:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 759:	0f be c0             	movsbl %al,%eax
 75c:	89 44 24 04          	mov    %eax,0x4(%esp)
 760:	8b 45 08             	mov    0x8(%ebp),%eax
 763:	89 04 24             	mov    %eax,(%esp)
 766:	e8 b9 fd ff ff       	call   524 <putc>
 76b:	eb 28                	jmp    795 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76d:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 774:	00 
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	89 04 24             	mov    %eax,(%esp)
 77b:	e8 a4 fd ff ff       	call   524 <putc>
        putc(fd, c);
 780:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 783:	0f be c0             	movsbl %al,%eax
 786:	89 44 24 04          	mov    %eax,0x4(%esp)
 78a:	8b 45 08             	mov    0x8(%ebp),%eax
 78d:	89 04 24             	mov    %eax,(%esp)
 790:	e8 8f fd ff ff       	call   524 <putc>
      }
      state = 0;
 795:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 79c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7a0:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a6:	01 d0                	add    %edx,%eax
 7a8:	0f b6 00             	movzbl (%eax),%eax
 7ab:	84 c0                	test   %al,%al
 7ad:	0f 85 70 fe ff ff    	jne    623 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b3:	c9                   	leave  
 7b4:	c3                   	ret    
 7b5:	66 90                	xchg   %ax,%ax
 7b7:	90                   	nop

000007b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b8:	55                   	push   %ebp
 7b9:	89 e5                	mov    %esp,%ebp
 7bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7be:	8b 45 08             	mov    0x8(%ebp),%eax
 7c1:	83 e8 08             	sub    $0x8,%eax
 7c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c7:	a1 bc 0c 00 00       	mov    0xcbc,%eax
 7cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cf:	eb 24                	jmp    7f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d9:	77 12                	ja     7ed <free+0x35>
 7db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e1:	77 24                	ja     807 <free+0x4f>
 7e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e6:	8b 00                	mov    (%eax),%eax
 7e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7eb:	77 1a                	ja     807 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f0:	8b 00                	mov    (%eax),%eax
 7f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7fb:	76 d4                	jbe    7d1 <free+0x19>
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 805:	76 ca                	jbe    7d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 814:	8b 45 f8             	mov    -0x8(%ebp),%eax
 817:	01 c2                	add    %eax,%edx
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	39 c2                	cmp    %eax,%edx
 820:	75 24                	jne    846 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 822:	8b 45 f8             	mov    -0x8(%ebp),%eax
 825:	8b 50 04             	mov    0x4(%eax),%edx
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	8b 00                	mov    (%eax),%eax
 82d:	8b 40 04             	mov    0x4(%eax),%eax
 830:	01 c2                	add    %eax,%edx
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	8b 10                	mov    (%eax),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	89 10                	mov    %edx,(%eax)
 844:	eb 0a                	jmp    850 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 10                	mov    (%eax),%edx
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 40 04             	mov    0x4(%eax),%eax
 856:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 85d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 860:	01 d0                	add    %edx,%eax
 862:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 865:	75 20                	jne    887 <free+0xcf>
    p->s.size += bp->s.size;
 867:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86a:	8b 50 04             	mov    0x4(%eax),%edx
 86d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 870:	8b 40 04             	mov    0x4(%eax),%eax
 873:	01 c2                	add    %eax,%edx
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	8b 10                	mov    (%eax),%edx
 880:	8b 45 fc             	mov    -0x4(%ebp),%eax
 883:	89 10                	mov    %edx,(%eax)
 885:	eb 08                	jmp    88f <free+0xd7>
  } else
    p->s.ptr = bp;
 887:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 88d:	89 10                	mov    %edx,(%eax)
  freep = p;
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	a3 bc 0c 00 00       	mov    %eax,0xcbc
}
 897:	c9                   	leave  
 898:	c3                   	ret    

00000899 <morecore>:

static Header*
morecore(uint nu)
{
 899:	55                   	push   %ebp
 89a:	89 e5                	mov    %esp,%ebp
 89c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 89f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a6:	77 07                	ja     8af <morecore+0x16>
    nu = 4096;
 8a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8af:	8b 45 08             	mov    0x8(%ebp),%eax
 8b2:	c1 e0 03             	shl    $0x3,%eax
 8b5:	89 04 24             	mov    %eax,(%esp)
 8b8:	e8 4f fc ff ff       	call   50c <sbrk>
 8bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8c0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c4:	75 07                	jne    8cd <morecore+0x34>
    return 0;
 8c6:	b8 00 00 00 00       	mov    $0x0,%eax
 8cb:	eb 22                	jmp    8ef <morecore+0x56>
  hp = (Header*)p;
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d6:	8b 55 08             	mov    0x8(%ebp),%edx
 8d9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8df:	83 c0 08             	add    $0x8,%eax
 8e2:	89 04 24             	mov    %eax,(%esp)
 8e5:	e8 ce fe ff ff       	call   7b8 <free>
  return freep;
 8ea:	a1 bc 0c 00 00       	mov    0xcbc,%eax
}
 8ef:	c9                   	leave  
 8f0:	c3                   	ret    

000008f1 <malloc>:

void*
malloc(uint nbytes)
{
 8f1:	55                   	push   %ebp
 8f2:	89 e5                	mov    %esp,%ebp
 8f4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f7:	8b 45 08             	mov    0x8(%ebp),%eax
 8fa:	83 c0 07             	add    $0x7,%eax
 8fd:	c1 e8 03             	shr    $0x3,%eax
 900:	83 c0 01             	add    $0x1,%eax
 903:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 906:	a1 bc 0c 00 00       	mov    0xcbc,%eax
 90b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 912:	75 23                	jne    937 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 914:	c7 45 f0 b4 0c 00 00 	movl   $0xcb4,-0x10(%ebp)
 91b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91e:	a3 bc 0c 00 00       	mov    %eax,0xcbc
 923:	a1 bc 0c 00 00       	mov    0xcbc,%eax
 928:	a3 b4 0c 00 00       	mov    %eax,0xcb4
    base.s.size = 0;
 92d:	c7 05 b8 0c 00 00 00 	movl   $0x0,0xcb8
 934:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 937:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93a:	8b 00                	mov    (%eax),%eax
 93c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 942:	8b 40 04             	mov    0x4(%eax),%eax
 945:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 948:	72 4d                	jb     997 <malloc+0xa6>
      if(p->s.size == nunits)
 94a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94d:	8b 40 04             	mov    0x4(%eax),%eax
 950:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 953:	75 0c                	jne    961 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 955:	8b 45 f4             	mov    -0xc(%ebp),%eax
 958:	8b 10                	mov    (%eax),%edx
 95a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95d:	89 10                	mov    %edx,(%eax)
 95f:	eb 26                	jmp    987 <malloc+0x96>
      else {
        p->s.size -= nunits;
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	8b 40 04             	mov    0x4(%eax),%eax
 967:	89 c2                	mov    %eax,%edx
 969:	2b 55 ec             	sub    -0x14(%ebp),%edx
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 972:	8b 45 f4             	mov    -0xc(%ebp),%eax
 975:	8b 40 04             	mov    0x4(%eax),%eax
 978:	c1 e0 03             	shl    $0x3,%eax
 97b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 981:	8b 55 ec             	mov    -0x14(%ebp),%edx
 984:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 987:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98a:	a3 bc 0c 00 00       	mov    %eax,0xcbc
      return (void*)(p + 1);
 98f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 992:	83 c0 08             	add    $0x8,%eax
 995:	eb 38                	jmp    9cf <malloc+0xde>
    }
    if(p == freep)
 997:	a1 bc 0c 00 00       	mov    0xcbc,%eax
 99c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99f:	75 1b                	jne    9bc <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9a4:	89 04 24             	mov    %eax,(%esp)
 9a7:	e8 ed fe ff ff       	call   899 <morecore>
 9ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b3:	75 07                	jne    9bc <malloc+0xcb>
        return 0;
 9b5:	b8 00 00 00 00       	mov    $0x0,%eax
 9ba:	eb 13                	jmp    9cf <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c5:	8b 00                	mov    (%eax),%eax
 9c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9ca:	e9 70 ff ff ff       	jmp    93f <malloc+0x4e>
}
 9cf:	c9                   	leave  
 9d0:	c3                   	ret    
