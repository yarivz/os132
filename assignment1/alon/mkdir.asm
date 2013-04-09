
_mkdir:     file format elf32-i386


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

  if(argc < 2){
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "Usage: mkdir files...\n");
   f:	c7 44 24 04 f5 09 00 	movl   $0x9f5,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 02 06 00 00       	call   625 <printf>
    exit();
  23:	e8 70 04 00 00       	call   498 <exit>
  }

  for(i = 1; i < argc; i++){
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 4f                	jmp    81 <main+0x81>
    if(mkdir(argv[i]) < 0){
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 c4 04 00 00       	call   510 <mkdir>
  4c:	85 c0                	test   %eax,%eax
  4e:	79 2c                	jns    7c <main+0x7c>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
  50:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  5e:	01 d0                	add    %edx,%eax
  60:	8b 00                	mov    (%eax),%eax
  62:	89 44 24 08          	mov    %eax,0x8(%esp)
  66:	c7 44 24 04 0c 0a 00 	movl   $0xa0c,0x4(%esp)
  6d:	00 
  6e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  75:	e8 ab 05 00 00       	call   625 <printf>
      break;
  7a:	eb 0e                	jmp    8a <main+0x8a>
  if(argc < 2){
    printf(2, "Usage: mkdir files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  7c:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  81:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  85:	3b 45 08             	cmp    0x8(%ebp),%eax
  88:	7c a8                	jl     32 <main+0x32>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
      break;
    }
  }

  exit();
  8a:	e8 09 04 00 00       	call   498 <exit>
  8f:	90                   	nop

00000090 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	57                   	push   %edi
  94:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  98:	8b 55 10             	mov    0x10(%ebp),%edx
  9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  9e:	89 cb                	mov    %ecx,%ebx
  a0:	89 df                	mov    %ebx,%edi
  a2:	89 d1                	mov    %edx,%ecx
  a4:	fc                   	cld    
  a5:	f3 aa                	rep stos %al,%es:(%edi)
  a7:	89 ca                	mov    %ecx,%edx
  a9:	89 fb                	mov    %edi,%ebx
  ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ae:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b1:	5b                   	pop    %ebx
  b2:	5f                   	pop    %edi
  b3:	5d                   	pop    %ebp
  b4:	c3                   	ret    

000000b5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  b8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c1:	90                   	nop
  c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  c5:	0f b6 10             	movzbl (%eax),%edx
  c8:	8b 45 08             	mov    0x8(%ebp),%eax
  cb:	88 10                	mov    %dl,(%eax)
  cd:	8b 45 08             	mov    0x8(%ebp),%eax
  d0:	0f b6 00             	movzbl (%eax),%eax
  d3:	84 c0                	test   %al,%al
  d5:	0f 95 c0             	setne  %al
  d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  dc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  e0:	84 c0                	test   %al,%al
  e2:	75 de                	jne    c2 <strcpy+0xd>
    ;
  return os;
  e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e7:	c9                   	leave  
  e8:	c3                   	ret    

000000e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e9:	55                   	push   %ebp
  ea:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  ec:	eb 08                	jmp    f6 <strcmp+0xd>
    p++, q++;
  ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  f2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  f6:	8b 45 08             	mov    0x8(%ebp),%eax
  f9:	0f b6 00             	movzbl (%eax),%eax
  fc:	84 c0                	test   %al,%al
  fe:	74 10                	je     110 <strcmp+0x27>
 100:	8b 45 08             	mov    0x8(%ebp),%eax
 103:	0f b6 10             	movzbl (%eax),%edx
 106:	8b 45 0c             	mov    0xc(%ebp),%eax
 109:	0f b6 00             	movzbl (%eax),%eax
 10c:	38 c2                	cmp    %al,%dl
 10e:	74 de                	je     ee <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 110:	8b 45 08             	mov    0x8(%ebp),%eax
 113:	0f b6 00             	movzbl (%eax),%eax
 116:	0f b6 d0             	movzbl %al,%edx
 119:	8b 45 0c             	mov    0xc(%ebp),%eax
 11c:	0f b6 00             	movzbl (%eax),%eax
 11f:	0f b6 c0             	movzbl %al,%eax
 122:	89 d1                	mov    %edx,%ecx
 124:	29 c1                	sub    %eax,%ecx
 126:	89 c8                	mov    %ecx,%eax
}
 128:	5d                   	pop    %ebp
 129:	c3                   	ret    

0000012a <strlen>:

uint
strlen(char *s)
{
 12a:	55                   	push   %ebp
 12b:	89 e5                	mov    %esp,%ebp
 12d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 130:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 137:	eb 04                	jmp    13d <strlen+0x13>
 139:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 13d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 140:	8b 45 08             	mov    0x8(%ebp),%eax
 143:	01 d0                	add    %edx,%eax
 145:	0f b6 00             	movzbl (%eax),%eax
 148:	84 c0                	test   %al,%al
 14a:	75 ed                	jne    139 <strlen+0xf>
  return n;
 14c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 14f:	c9                   	leave  
 150:	c3                   	ret    

00000151 <memset>:

void*
memset(void *dst, int c, uint n)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 157:	8b 45 10             	mov    0x10(%ebp),%eax
 15a:	89 44 24 08          	mov    %eax,0x8(%esp)
 15e:	8b 45 0c             	mov    0xc(%ebp),%eax
 161:	89 44 24 04          	mov    %eax,0x4(%esp)
 165:	8b 45 08             	mov    0x8(%ebp),%eax
 168:	89 04 24             	mov    %eax,(%esp)
 16b:	e8 20 ff ff ff       	call   90 <stosb>
  return dst;
 170:	8b 45 08             	mov    0x8(%ebp),%eax
}
 173:	c9                   	leave  
 174:	c3                   	ret    

00000175 <strchr>:

char*
strchr(const char *s, char c)
{
 175:	55                   	push   %ebp
 176:	89 e5                	mov    %esp,%ebp
 178:	83 ec 04             	sub    $0x4,%esp
 17b:	8b 45 0c             	mov    0xc(%ebp),%eax
 17e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 181:	eb 14                	jmp    197 <strchr+0x22>
    if(*s == c)
 183:	8b 45 08             	mov    0x8(%ebp),%eax
 186:	0f b6 00             	movzbl (%eax),%eax
 189:	3a 45 fc             	cmp    -0x4(%ebp),%al
 18c:	75 05                	jne    193 <strchr+0x1e>
      return (char*)s;
 18e:	8b 45 08             	mov    0x8(%ebp),%eax
 191:	eb 13                	jmp    1a6 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 193:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 197:	8b 45 08             	mov    0x8(%ebp),%eax
 19a:	0f b6 00             	movzbl (%eax),%eax
 19d:	84 c0                	test   %al,%al
 19f:	75 e2                	jne    183 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a6:	c9                   	leave  
 1a7:	c3                   	ret    

000001a8 <gets>:

char*
gets(char *buf, int max)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
 1ab:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1b5:	eb 46                	jmp    1fd <gets+0x55>
    cc = read(0, &c, 1);
 1b7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1be:	00 
 1bf:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1cd:	e8 ee 02 00 00       	call   4c0 <read>
 1d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1d9:	7e 2f                	jle    20a <gets+0x62>
      break;
    buf[i++] = c;
 1db:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	01 c2                	add    %eax,%edx
 1e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e7:	88 02                	mov    %al,(%edx)
 1e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1ed:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f1:	3c 0a                	cmp    $0xa,%al
 1f3:	74 16                	je     20b <gets+0x63>
 1f5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f9:	3c 0d                	cmp    $0xd,%al
 1fb:	74 0e                	je     20b <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 200:	83 c0 01             	add    $0x1,%eax
 203:	3b 45 0c             	cmp    0xc(%ebp),%eax
 206:	7c af                	jl     1b7 <gets+0xf>
 208:	eb 01                	jmp    20b <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 20a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 20b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 20e:	8b 45 08             	mov    0x8(%ebp),%eax
 211:	01 d0                	add    %edx,%eax
 213:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 216:	8b 45 08             	mov    0x8(%ebp),%eax
}
 219:	c9                   	leave  
 21a:	c3                   	ret    

0000021b <stat>:

int
stat(char *n, struct stat *st)
{
 21b:	55                   	push   %ebp
 21c:	89 e5                	mov    %esp,%ebp
 21e:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 221:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 228:	00 
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	89 04 24             	mov    %eax,(%esp)
 22f:	e8 b4 02 00 00       	call   4e8 <open>
 234:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 237:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 23b:	79 07                	jns    244 <stat+0x29>
    return -1;
 23d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 242:	eb 23                	jmp    267 <stat+0x4c>
  r = fstat(fd, st);
 244:	8b 45 0c             	mov    0xc(%ebp),%eax
 247:	89 44 24 04          	mov    %eax,0x4(%esp)
 24b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24e:	89 04 24             	mov    %eax,(%esp)
 251:	e8 aa 02 00 00       	call   500 <fstat>
 256:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 259:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25c:	89 04 24             	mov    %eax,(%esp)
 25f:	e8 6c 02 00 00       	call   4d0 <close>
  return r;
 264:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 267:	c9                   	leave  
 268:	c3                   	ret    

00000269 <atoi>:

int
atoi(const char *s)
{
 269:	55                   	push   %ebp
 26a:	89 e5                	mov    %esp,%ebp
 26c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 26f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 276:	eb 23                	jmp    29b <atoi+0x32>
    n = n*10 + *s++ - '0';
 278:	8b 55 fc             	mov    -0x4(%ebp),%edx
 27b:	89 d0                	mov    %edx,%eax
 27d:	c1 e0 02             	shl    $0x2,%eax
 280:	01 d0                	add    %edx,%eax
 282:	01 c0                	add    %eax,%eax
 284:	89 c2                	mov    %eax,%edx
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	0f b6 00             	movzbl (%eax),%eax
 28c:	0f be c0             	movsbl %al,%eax
 28f:	01 d0                	add    %edx,%eax
 291:	83 e8 30             	sub    $0x30,%eax
 294:	89 45 fc             	mov    %eax,-0x4(%ebp)
 297:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	3c 2f                	cmp    $0x2f,%al
 2a3:	7e 0a                	jle    2af <atoi+0x46>
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	0f b6 00             	movzbl (%eax),%eax
 2ab:	3c 39                	cmp    $0x39,%al
 2ad:	7e c9                	jle    278 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b2:	c9                   	leave  
 2b3:	c3                   	ret    

000002b4 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2b4:	55                   	push   %ebp
 2b5:	89 e5                	mov    %esp,%ebp
 2b7:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2ba:	8b 45 08             	mov    0x8(%ebp),%eax
 2bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c6:	eb 13                	jmp    2db <memmove+0x27>
    *dst++ = *src++;
 2c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2cb:	0f b6 10             	movzbl (%eax),%edx
 2ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2d1:	88 10                	mov    %dl,(%eax)
 2d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2d7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2df:	0f 9f c0             	setg   %al
 2e2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2e6:	84 c0                	test   %al,%al
 2e8:	75 de                	jne    2c8 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ed:	c9                   	leave  
 2ee:	c3                   	ret    

000002ef <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 2ef:	55                   	push   %ebp
 2f0:	89 e5                	mov    %esp,%ebp
 2f2:	83 ec 38             	sub    $0x38,%esp
 2f5:	8b 45 10             	mov    0x10(%ebp),%eax
 2f8:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 2fb:	8b 45 14             	mov    0x14(%ebp),%eax
 2fe:	8b 00                	mov    (%eax),%eax
 300:	89 45 f4             	mov    %eax,-0xc(%ebp)
 303:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 30a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 30e:	74 06                	je     316 <strtok+0x27>
 310:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 314:	75 5a                	jne    370 <strtok+0x81>
    return match;
 316:	8b 45 f0             	mov    -0x10(%ebp),%eax
 319:	eb 76                	jmp    391 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 31b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 31e:	8b 45 0c             	mov    0xc(%ebp),%eax
 321:	01 d0                	add    %edx,%eax
 323:	0f b6 00             	movzbl (%eax),%eax
 326:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 329:	74 06                	je     331 <strtok+0x42>
      {
	index++;
 32b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 32f:	eb 40                	jmp    371 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 331:	8b 45 14             	mov    0x14(%ebp),%eax
 334:	8b 00                	mov    (%eax),%eax
 336:	8b 55 f4             	mov    -0xc(%ebp),%edx
 339:	29 c2                	sub    %eax,%edx
 33b:	8b 45 14             	mov    0x14(%ebp),%eax
 33e:	8b 00                	mov    (%eax),%eax
 340:	89 c1                	mov    %eax,%ecx
 342:	8b 45 0c             	mov    0xc(%ebp),%eax
 345:	01 c8                	add    %ecx,%eax
 347:	89 54 24 08          	mov    %edx,0x8(%esp)
 34b:	89 44 24 04          	mov    %eax,0x4(%esp)
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	89 04 24             	mov    %eax,(%esp)
 355:	e8 39 00 00 00       	call   393 <strncpy>
 35a:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	0f b6 00             	movzbl (%eax),%eax
 363:	84 c0                	test   %al,%al
 365:	74 1b                	je     382 <strtok+0x93>
	  match = 1;
 367:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 36e:	eb 12                	jmp    382 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 370:	90                   	nop
 371:	8b 55 f4             	mov    -0xc(%ebp),%edx
 374:	8b 45 0c             	mov    0xc(%ebp),%eax
 377:	01 d0                	add    %edx,%eax
 379:	0f b6 00             	movzbl (%eax),%eax
 37c:	84 c0                	test   %al,%al
 37e:	75 9b                	jne    31b <strtok+0x2c>
 380:	eb 01                	jmp    383 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 382:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 383:	8b 45 f4             	mov    -0xc(%ebp),%eax
 386:	8d 50 01             	lea    0x1(%eax),%edx
 389:	8b 45 14             	mov    0x14(%ebp),%eax
 38c:	89 10                	mov    %edx,(%eax)
  return match;
 38e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 391:	c9                   	leave  
 392:	c3                   	ret    

00000393 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 393:	55                   	push   %ebp
 394:	89 e5                	mov    %esp,%ebp
 396:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 399:	8b 45 08             	mov    0x8(%ebp),%eax
 39c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 39f:	90                   	nop
 3a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3a4:	0f 9f c0             	setg   %al
 3a7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3ab:	84 c0                	test   %al,%al
 3ad:	74 30                	je     3df <strncpy+0x4c>
 3af:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b2:	0f b6 10             	movzbl (%eax),%edx
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	88 10                	mov    %dl,(%eax)
 3ba:	8b 45 08             	mov    0x8(%ebp),%eax
 3bd:	0f b6 00             	movzbl (%eax),%eax
 3c0:	84 c0                	test   %al,%al
 3c2:	0f 95 c0             	setne  %al
 3c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3cd:	84 c0                	test   %al,%al
 3cf:	75 cf                	jne    3a0 <strncpy+0xd>
    ;
  while(n-- > 0)
 3d1:	eb 0c                	jmp    3df <strncpy+0x4c>
    *s++ = 0;
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	c6 00 00             	movb   $0x0,(%eax)
 3d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3dd:	eb 01                	jmp    3e0 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3df:	90                   	nop
 3e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3e4:	0f 9f c0             	setg   %al
 3e7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3eb:	84 c0                	test   %al,%al
 3ed:	75 e4                	jne    3d3 <strncpy+0x40>
    *s++ = 0;
  return os;
 3ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f2:	c9                   	leave  
 3f3:	c3                   	ret    

000003f4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 3f7:	eb 0c                	jmp    405 <strncmp+0x11>
    n--, p++, q++;
 3f9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 401:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 405:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 409:	74 1a                	je     425 <strncmp+0x31>
 40b:	8b 45 08             	mov    0x8(%ebp),%eax
 40e:	0f b6 00             	movzbl (%eax),%eax
 411:	84 c0                	test   %al,%al
 413:	74 10                	je     425 <strncmp+0x31>
 415:	8b 45 08             	mov    0x8(%ebp),%eax
 418:	0f b6 10             	movzbl (%eax),%edx
 41b:	8b 45 0c             	mov    0xc(%ebp),%eax
 41e:	0f b6 00             	movzbl (%eax),%eax
 421:	38 c2                	cmp    %al,%dl
 423:	74 d4                	je     3f9 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 425:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 429:	75 07                	jne    432 <strncmp+0x3e>
    return 0;
 42b:	b8 00 00 00 00       	mov    $0x0,%eax
 430:	eb 18                	jmp    44a <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 432:	8b 45 08             	mov    0x8(%ebp),%eax
 435:	0f b6 00             	movzbl (%eax),%eax
 438:	0f b6 d0             	movzbl %al,%edx
 43b:	8b 45 0c             	mov    0xc(%ebp),%eax
 43e:	0f b6 00             	movzbl (%eax),%eax
 441:	0f b6 c0             	movzbl %al,%eax
 444:	89 d1                	mov    %edx,%ecx
 446:	29 c1                	sub    %eax,%ecx
 448:	89 c8                	mov    %ecx,%eax
}
 44a:	5d                   	pop    %ebp
 44b:	c3                   	ret    

0000044c <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 44c:	55                   	push   %ebp
 44d:	89 e5                	mov    %esp,%ebp
  while(*p){
 44f:	eb 13                	jmp    464 <strcat+0x18>
    *dest++ = *p++;
 451:	8b 45 0c             	mov    0xc(%ebp),%eax
 454:	0f b6 10             	movzbl (%eax),%edx
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	88 10                	mov    %dl,(%eax)
 45c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 460:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 464:	8b 45 0c             	mov    0xc(%ebp),%eax
 467:	0f b6 00             	movzbl (%eax),%eax
 46a:	84 c0                	test   %al,%al
 46c:	75 e3                	jne    451 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 46e:	eb 13                	jmp    483 <strcat+0x37>
    *dest++ = *q++;
 470:	8b 45 10             	mov    0x10(%ebp),%eax
 473:	0f b6 10             	movzbl (%eax),%edx
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	88 10                	mov    %dl,(%eax)
 47b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 47f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 483:	8b 45 10             	mov    0x10(%ebp),%eax
 486:	0f b6 00             	movzbl (%eax),%eax
 489:	84 c0                	test   %al,%al
 48b:	75 e3                	jne    470 <strcat+0x24>
    *dest++ = *q++;
  }  
 48d:	5d                   	pop    %ebp
 48e:	c3                   	ret    
 48f:	90                   	nop

00000490 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 490:	b8 01 00 00 00       	mov    $0x1,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <exit>:
SYSCALL(exit)
 498:	b8 02 00 00 00       	mov    $0x2,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <wait>:
SYSCALL(wait)
 4a0:	b8 03 00 00 00       	mov    $0x3,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <wait2>:
SYSCALL(wait2)
 4a8:	b8 16 00 00 00       	mov    $0x16,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <nice>:
SYSCALL(nice)
 4b0:	b8 17 00 00 00       	mov    $0x17,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <pipe>:
SYSCALL(pipe)
 4b8:	b8 04 00 00 00       	mov    $0x4,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <read>:
SYSCALL(read)
 4c0:	b8 05 00 00 00       	mov    $0x5,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <write>:
SYSCALL(write)
 4c8:	b8 10 00 00 00       	mov    $0x10,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <close>:
SYSCALL(close)
 4d0:	b8 15 00 00 00       	mov    $0x15,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <kill>:
SYSCALL(kill)
 4d8:	b8 06 00 00 00       	mov    $0x6,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <exec>:
SYSCALL(exec)
 4e0:	b8 07 00 00 00       	mov    $0x7,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <open>:
SYSCALL(open)
 4e8:	b8 0f 00 00 00       	mov    $0xf,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <mknod>:
SYSCALL(mknod)
 4f0:	b8 11 00 00 00       	mov    $0x11,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <unlink>:
SYSCALL(unlink)
 4f8:	b8 12 00 00 00       	mov    $0x12,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <fstat>:
SYSCALL(fstat)
 500:	b8 08 00 00 00       	mov    $0x8,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <link>:
SYSCALL(link)
 508:	b8 13 00 00 00       	mov    $0x13,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <mkdir>:
SYSCALL(mkdir)
 510:	b8 14 00 00 00       	mov    $0x14,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <chdir>:
SYSCALL(chdir)
 518:	b8 09 00 00 00       	mov    $0x9,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <dup>:
SYSCALL(dup)
 520:	b8 0a 00 00 00       	mov    $0xa,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <getpid>:
SYSCALL(getpid)
 528:	b8 0b 00 00 00       	mov    $0xb,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <sbrk>:
SYSCALL(sbrk)
 530:	b8 0c 00 00 00       	mov    $0xc,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <sleep>:
SYSCALL(sleep)
 538:	b8 0d 00 00 00       	mov    $0xd,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <uptime>:
SYSCALL(uptime)
 540:	b8 0e 00 00 00       	mov    $0xe,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 548:	55                   	push   %ebp
 549:	89 e5                	mov    %esp,%ebp
 54b:	83 ec 28             	sub    $0x28,%esp
 54e:	8b 45 0c             	mov    0xc(%ebp),%eax
 551:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 554:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 55b:	00 
 55c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 55f:	89 44 24 04          	mov    %eax,0x4(%esp)
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	89 04 24             	mov    %eax,(%esp)
 569:	e8 5a ff ff ff       	call   4c8 <write>
}
 56e:	c9                   	leave  
 56f:	c3                   	ret    

00000570 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 570:	55                   	push   %ebp
 571:	89 e5                	mov    %esp,%ebp
 573:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 576:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 57d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 581:	74 17                	je     59a <printint+0x2a>
 583:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 587:	79 11                	jns    59a <printint+0x2a>
    neg = 1;
 589:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 590:	8b 45 0c             	mov    0xc(%ebp),%eax
 593:	f7 d8                	neg    %eax
 595:	89 45 ec             	mov    %eax,-0x14(%ebp)
 598:	eb 06                	jmp    5a0 <printint+0x30>
  } else {
    x = xx;
 59a:	8b 45 0c             	mov    0xc(%ebp),%eax
 59d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ad:	ba 00 00 00 00       	mov    $0x0,%edx
 5b2:	f7 f1                	div    %ecx
 5b4:	89 d0                	mov    %edx,%eax
 5b6:	0f b6 80 ec 0c 00 00 	movzbl 0xcec(%eax),%eax
 5bd:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 5c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5c3:	01 ca                	add    %ecx,%edx
 5c5:	88 02                	mov    %al,(%edx)
 5c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5cb:	8b 55 10             	mov    0x10(%ebp),%edx
 5ce:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5d4:	ba 00 00 00 00       	mov    $0x0,%edx
 5d9:	f7 75 d4             	divl   -0x2c(%ebp)
 5dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e3:	75 c2                	jne    5a7 <printint+0x37>
  if(neg)
 5e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5e9:	74 2e                	je     619 <printint+0xa9>
    buf[i++] = '-';
 5eb:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f1:	01 d0                	add    %edx,%eax
 5f3:	c6 00 2d             	movb   $0x2d,(%eax)
 5f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5fa:	eb 1d                	jmp    619 <printint+0xa9>
    putc(fd, buf[i]);
 5fc:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 602:	01 d0                	add    %edx,%eax
 604:	0f b6 00             	movzbl (%eax),%eax
 607:	0f be c0             	movsbl %al,%eax
 60a:	89 44 24 04          	mov    %eax,0x4(%esp)
 60e:	8b 45 08             	mov    0x8(%ebp),%eax
 611:	89 04 24             	mov    %eax,(%esp)
 614:	e8 2f ff ff ff       	call   548 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 619:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 61d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 621:	79 d9                	jns    5fc <printint+0x8c>
    putc(fd, buf[i]);
}
 623:	c9                   	leave  
 624:	c3                   	ret    

00000625 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 625:	55                   	push   %ebp
 626:	89 e5                	mov    %esp,%ebp
 628:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 62b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 632:	8d 45 0c             	lea    0xc(%ebp),%eax
 635:	83 c0 04             	add    $0x4,%eax
 638:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 63b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 642:	e9 7d 01 00 00       	jmp    7c4 <printf+0x19f>
    c = fmt[i] & 0xff;
 647:	8b 55 0c             	mov    0xc(%ebp),%edx
 64a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64d:	01 d0                	add    %edx,%eax
 64f:	0f b6 00             	movzbl (%eax),%eax
 652:	0f be c0             	movsbl %al,%eax
 655:	25 ff 00 00 00       	and    $0xff,%eax
 65a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 65d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 661:	75 2c                	jne    68f <printf+0x6a>
      if(c == '%'){
 663:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 667:	75 0c                	jne    675 <printf+0x50>
        state = '%';
 669:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 670:	e9 4b 01 00 00       	jmp    7c0 <printf+0x19b>
      } else {
        putc(fd, c);
 675:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 678:	0f be c0             	movsbl %al,%eax
 67b:	89 44 24 04          	mov    %eax,0x4(%esp)
 67f:	8b 45 08             	mov    0x8(%ebp),%eax
 682:	89 04 24             	mov    %eax,(%esp)
 685:	e8 be fe ff ff       	call   548 <putc>
 68a:	e9 31 01 00 00       	jmp    7c0 <printf+0x19b>
      }
    } else if(state == '%'){
 68f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 693:	0f 85 27 01 00 00    	jne    7c0 <printf+0x19b>
      if(c == 'd'){
 699:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 69d:	75 2d                	jne    6cc <printf+0xa7>
        printint(fd, *ap, 10, 1);
 69f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a2:	8b 00                	mov    (%eax),%eax
 6a4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6ab:	00 
 6ac:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6b3:	00 
 6b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b8:	8b 45 08             	mov    0x8(%ebp),%eax
 6bb:	89 04 24             	mov    %eax,(%esp)
 6be:	e8 ad fe ff ff       	call   570 <printint>
        ap++;
 6c3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6c7:	e9 ed 00 00 00       	jmp    7b9 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6cc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6d0:	74 06                	je     6d8 <printf+0xb3>
 6d2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6d6:	75 2d                	jne    705 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6db:	8b 00                	mov    (%eax),%eax
 6dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6e4:	00 
 6e5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6ec:	00 
 6ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f1:	8b 45 08             	mov    0x8(%ebp),%eax
 6f4:	89 04 24             	mov    %eax,(%esp)
 6f7:	e8 74 fe ff ff       	call   570 <printint>
        ap++;
 6fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 700:	e9 b4 00 00 00       	jmp    7b9 <printf+0x194>
      } else if(c == 's'){
 705:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 709:	75 46                	jne    751 <printf+0x12c>
        s = (char*)*ap;
 70b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70e:	8b 00                	mov    (%eax),%eax
 710:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 713:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 71b:	75 27                	jne    744 <printf+0x11f>
          s = "(null)";
 71d:	c7 45 f4 28 0a 00 00 	movl   $0xa28,-0xc(%ebp)
        while(*s != 0){
 724:	eb 1e                	jmp    744 <printf+0x11f>
          putc(fd, *s);
 726:	8b 45 f4             	mov    -0xc(%ebp),%eax
 729:	0f b6 00             	movzbl (%eax),%eax
 72c:	0f be c0             	movsbl %al,%eax
 72f:	89 44 24 04          	mov    %eax,0x4(%esp)
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	89 04 24             	mov    %eax,(%esp)
 739:	e8 0a fe ff ff       	call   548 <putc>
          s++;
 73e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 742:	eb 01                	jmp    745 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 744:	90                   	nop
 745:	8b 45 f4             	mov    -0xc(%ebp),%eax
 748:	0f b6 00             	movzbl (%eax),%eax
 74b:	84 c0                	test   %al,%al
 74d:	75 d7                	jne    726 <printf+0x101>
 74f:	eb 68                	jmp    7b9 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 751:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 755:	75 1d                	jne    774 <printf+0x14f>
        putc(fd, *ap);
 757:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75a:	8b 00                	mov    (%eax),%eax
 75c:	0f be c0             	movsbl %al,%eax
 75f:	89 44 24 04          	mov    %eax,0x4(%esp)
 763:	8b 45 08             	mov    0x8(%ebp),%eax
 766:	89 04 24             	mov    %eax,(%esp)
 769:	e8 da fd ff ff       	call   548 <putc>
        ap++;
 76e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 772:	eb 45                	jmp    7b9 <printf+0x194>
      } else if(c == '%'){
 774:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 778:	75 17                	jne    791 <printf+0x16c>
        putc(fd, c);
 77a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77d:	0f be c0             	movsbl %al,%eax
 780:	89 44 24 04          	mov    %eax,0x4(%esp)
 784:	8b 45 08             	mov    0x8(%ebp),%eax
 787:	89 04 24             	mov    %eax,(%esp)
 78a:	e8 b9 fd ff ff       	call   548 <putc>
 78f:	eb 28                	jmp    7b9 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 791:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 798:	00 
 799:	8b 45 08             	mov    0x8(%ebp),%eax
 79c:	89 04 24             	mov    %eax,(%esp)
 79f:	e8 a4 fd ff ff       	call   548 <putc>
        putc(fd, c);
 7a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a7:	0f be c0             	movsbl %al,%eax
 7aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ae:	8b 45 08             	mov    0x8(%ebp),%eax
 7b1:	89 04 24             	mov    %eax,(%esp)
 7b4:	e8 8f fd ff ff       	call   548 <putc>
      }
      state = 0;
 7b9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7c0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7c4:	8b 55 0c             	mov    0xc(%ebp),%edx
 7c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ca:	01 d0                	add    %edx,%eax
 7cc:	0f b6 00             	movzbl (%eax),%eax
 7cf:	84 c0                	test   %al,%al
 7d1:	0f 85 70 fe ff ff    	jne    647 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7d7:	c9                   	leave  
 7d8:	c3                   	ret    
 7d9:	66 90                	xchg   %ax,%ax
 7db:	90                   	nop

000007dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7dc:	55                   	push   %ebp
 7dd:	89 e5                	mov    %esp,%ebp
 7df:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e2:	8b 45 08             	mov    0x8(%ebp),%eax
 7e5:	83 e8 08             	sub    $0x8,%eax
 7e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7eb:	a1 08 0d 00 00       	mov    0xd08,%eax
 7f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f3:	eb 24                	jmp    819 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7fd:	77 12                	ja     811 <free+0x35>
 7ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 802:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 805:	77 24                	ja     82b <free+0x4f>
 807:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80a:	8b 00                	mov    (%eax),%eax
 80c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 80f:	77 1a                	ja     82b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	89 45 fc             	mov    %eax,-0x4(%ebp)
 819:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 81f:	76 d4                	jbe    7f5 <free+0x19>
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 829:	76 ca                	jbe    7f5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 82b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82e:	8b 40 04             	mov    0x4(%eax),%eax
 831:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 838:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83b:	01 c2                	add    %eax,%edx
 83d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 840:	8b 00                	mov    (%eax),%eax
 842:	39 c2                	cmp    %eax,%edx
 844:	75 24                	jne    86a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 846:	8b 45 f8             	mov    -0x8(%ebp),%eax
 849:	8b 50 04             	mov    0x4(%eax),%edx
 84c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84f:	8b 00                	mov    (%eax),%eax
 851:	8b 40 04             	mov    0x4(%eax),%eax
 854:	01 c2                	add    %eax,%edx
 856:	8b 45 f8             	mov    -0x8(%ebp),%eax
 859:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 85c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85f:	8b 00                	mov    (%eax),%eax
 861:	8b 10                	mov    (%eax),%edx
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	89 10                	mov    %edx,(%eax)
 868:	eb 0a                	jmp    874 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 86a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86d:	8b 10                	mov    (%eax),%edx
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 874:	8b 45 fc             	mov    -0x4(%ebp),%eax
 877:	8b 40 04             	mov    0x4(%eax),%eax
 87a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	01 d0                	add    %edx,%eax
 886:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 889:	75 20                	jne    8ab <free+0xcf>
    p->s.size += bp->s.size;
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 50 04             	mov    0x4(%eax),%edx
 891:	8b 45 f8             	mov    -0x8(%ebp),%eax
 894:	8b 40 04             	mov    0x4(%eax),%eax
 897:	01 c2                	add    %eax,%edx
 899:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 89f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a2:	8b 10                	mov    (%eax),%edx
 8a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a7:	89 10                	mov    %edx,(%eax)
 8a9:	eb 08                	jmp    8b3 <free+0xd7>
  } else
    p->s.ptr = bp;
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8b1:	89 10                	mov    %edx,(%eax)
  freep = p;
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	a3 08 0d 00 00       	mov    %eax,0xd08
}
 8bb:	c9                   	leave  
 8bc:	c3                   	ret    

000008bd <morecore>:

static Header*
morecore(uint nu)
{
 8bd:	55                   	push   %ebp
 8be:	89 e5                	mov    %esp,%ebp
 8c0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8c3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8ca:	77 07                	ja     8d3 <morecore+0x16>
    nu = 4096;
 8cc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8d3:	8b 45 08             	mov    0x8(%ebp),%eax
 8d6:	c1 e0 03             	shl    $0x3,%eax
 8d9:	89 04 24             	mov    %eax,(%esp)
 8dc:	e8 4f fc ff ff       	call   530 <sbrk>
 8e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8e4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8e8:	75 07                	jne    8f1 <morecore+0x34>
    return 0;
 8ea:	b8 00 00 00 00       	mov    $0x0,%eax
 8ef:	eb 22                	jmp    913 <morecore+0x56>
  hp = (Header*)p;
 8f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8fa:	8b 55 08             	mov    0x8(%ebp),%edx
 8fd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 900:	8b 45 f0             	mov    -0x10(%ebp),%eax
 903:	83 c0 08             	add    $0x8,%eax
 906:	89 04 24             	mov    %eax,(%esp)
 909:	e8 ce fe ff ff       	call   7dc <free>
  return freep;
 90e:	a1 08 0d 00 00       	mov    0xd08,%eax
}
 913:	c9                   	leave  
 914:	c3                   	ret    

00000915 <malloc>:

void*
malloc(uint nbytes)
{
 915:	55                   	push   %ebp
 916:	89 e5                	mov    %esp,%ebp
 918:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91b:	8b 45 08             	mov    0x8(%ebp),%eax
 91e:	83 c0 07             	add    $0x7,%eax
 921:	c1 e8 03             	shr    $0x3,%eax
 924:	83 c0 01             	add    $0x1,%eax
 927:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 92a:	a1 08 0d 00 00       	mov    0xd08,%eax
 92f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 932:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 936:	75 23                	jne    95b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 938:	c7 45 f0 00 0d 00 00 	movl   $0xd00,-0x10(%ebp)
 93f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 942:	a3 08 0d 00 00       	mov    %eax,0xd08
 947:	a1 08 0d 00 00       	mov    0xd08,%eax
 94c:	a3 00 0d 00 00       	mov    %eax,0xd00
    base.s.size = 0;
 951:	c7 05 04 0d 00 00 00 	movl   $0x0,0xd04
 958:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95e:	8b 00                	mov    (%eax),%eax
 960:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 963:	8b 45 f4             	mov    -0xc(%ebp),%eax
 966:	8b 40 04             	mov    0x4(%eax),%eax
 969:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 96c:	72 4d                	jb     9bb <malloc+0xa6>
      if(p->s.size == nunits)
 96e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 971:	8b 40 04             	mov    0x4(%eax),%eax
 974:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 977:	75 0c                	jne    985 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 979:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97c:	8b 10                	mov    (%eax),%edx
 97e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 981:	89 10                	mov    %edx,(%eax)
 983:	eb 26                	jmp    9ab <malloc+0x96>
      else {
        p->s.size -= nunits;
 985:	8b 45 f4             	mov    -0xc(%ebp),%eax
 988:	8b 40 04             	mov    0x4(%eax),%eax
 98b:	89 c2                	mov    %eax,%edx
 98d:	2b 55 ec             	sub    -0x14(%ebp),%edx
 990:	8b 45 f4             	mov    -0xc(%ebp),%eax
 993:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 996:	8b 45 f4             	mov    -0xc(%ebp),%eax
 999:	8b 40 04             	mov    0x4(%eax),%eax
 99c:	c1 e0 03             	shl    $0x3,%eax
 99f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9a8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ae:	a3 08 0d 00 00       	mov    %eax,0xd08
      return (void*)(p + 1);
 9b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b6:	83 c0 08             	add    $0x8,%eax
 9b9:	eb 38                	jmp    9f3 <malloc+0xde>
    }
    if(p == freep)
 9bb:	a1 08 0d 00 00       	mov    0xd08,%eax
 9c0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9c3:	75 1b                	jne    9e0 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9c8:	89 04 24             	mov    %eax,(%esp)
 9cb:	e8 ed fe ff ff       	call   8bd <morecore>
 9d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d7:	75 07                	jne    9e0 <malloc+0xcb>
        return 0;
 9d9:	b8 00 00 00 00       	mov    $0x0,%eax
 9de:	eb 13                	jmp    9f3 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e9:	8b 00                	mov    (%eax),%eax
 9eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9ee:	e9 70 ff ff ff       	jmp    963 <malloc+0x4e>
}
 9f3:	c9                   	leave  
 9f4:	c3                   	ret    
