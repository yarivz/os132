
_rm:     file format elf32-i386


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
    printf(2, "Usage: rm files...\n");
   f:	c7 44 24 04 cf 09 00 	movl   $0x9cf,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 e8 05 00 00       	call   60b <printf>
    exit();
  23:	e8 5c 04 00 00       	call   484 <exit>
  }

  for(i = 1; i < argc; i++){
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 43                	jmp    75 <main+0x75>
    if(unlink(argv[i]) < 0){
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	c1 e0 02             	shl    $0x2,%eax
  39:	03 45 0c             	add    0xc(%ebp),%eax
  3c:	8b 00                	mov    (%eax),%eax
  3e:	89 04 24             	mov    %eax,(%esp)
  41:	e8 9e 04 00 00       	call   4e4 <unlink>
  46:	85 c0                	test   %eax,%eax
  48:	79 26                	jns    70 <main+0x70>
      printf(2, "rm: %s failed to delete\n", argv[i]);
  4a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  4e:	c1 e0 02             	shl    $0x2,%eax
  51:	03 45 0c             	add    0xc(%ebp),%eax
  54:	8b 00                	mov    (%eax),%eax
  56:	89 44 24 08          	mov    %eax,0x8(%esp)
  5a:	c7 44 24 04 e3 09 00 	movl   $0x9e3,0x4(%esp)
  61:	00 
  62:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  69:	e8 9d 05 00 00       	call   60b <printf>
      break;
  6e:	eb 0e                	jmp    7e <main+0x7e>
  if(argc < 2){
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  70:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  75:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  79:	3b 45 08             	cmp    0x8(%ebp),%eax
  7c:	7c b4                	jl     32 <main+0x32>
      printf(2, "rm: %s failed to delete\n", argv[i]);
      break;
    }
  }

  exit();
  7e:	e8 01 04 00 00       	call   484 <exit>
  83:	90                   	nop

00000084 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  84:	55                   	push   %ebp
  85:	89 e5                	mov    %esp,%ebp
  87:	57                   	push   %edi
  88:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8c:	8b 55 10             	mov    0x10(%ebp),%edx
  8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  92:	89 cb                	mov    %ecx,%ebx
  94:	89 df                	mov    %ebx,%edi
  96:	89 d1                	mov    %edx,%ecx
  98:	fc                   	cld    
  99:	f3 aa                	rep stos %al,%es:(%edi)
  9b:	89 ca                	mov    %ecx,%edx
  9d:	89 fb                	mov    %edi,%ebx
  9f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  a2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  a5:	5b                   	pop    %ebx
  a6:	5f                   	pop    %edi
  a7:	5d                   	pop    %ebp
  a8:	c3                   	ret    

000000a9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  a9:	55                   	push   %ebp
  aa:	89 e5                	mov    %esp,%ebp
  ac:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  af:	8b 45 08             	mov    0x8(%ebp),%eax
  b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  b5:	90                   	nop
  b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  b9:	0f b6 10             	movzbl (%eax),%edx
  bc:	8b 45 08             	mov    0x8(%ebp),%eax
  bf:	88 10                	mov    %dl,(%eax)
  c1:	8b 45 08             	mov    0x8(%ebp),%eax
  c4:	0f b6 00             	movzbl (%eax),%eax
  c7:	84 c0                	test   %al,%al
  c9:	0f 95 c0             	setne  %al
  cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  d4:	84 c0                	test   %al,%al
  d6:	75 de                	jne    b6 <strcpy+0xd>
    ;
  return os;
  d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  db:	c9                   	leave  
  dc:	c3                   	ret    

000000dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dd:	55                   	push   %ebp
  de:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e0:	eb 08                	jmp    ea <strcmp+0xd>
    p++, q++;
  e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  e6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ea:	8b 45 08             	mov    0x8(%ebp),%eax
  ed:	0f b6 00             	movzbl (%eax),%eax
  f0:	84 c0                	test   %al,%al
  f2:	74 10                	je     104 <strcmp+0x27>
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	0f b6 10             	movzbl (%eax),%edx
  fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  fd:	0f b6 00             	movzbl (%eax),%eax
 100:	38 c2                	cmp    %al,%dl
 102:	74 de                	je     e2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 104:	8b 45 08             	mov    0x8(%ebp),%eax
 107:	0f b6 00             	movzbl (%eax),%eax
 10a:	0f b6 d0             	movzbl %al,%edx
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	0f b6 00             	movzbl (%eax),%eax
 113:	0f b6 c0             	movzbl %al,%eax
 116:	89 d1                	mov    %edx,%ecx
 118:	29 c1                	sub    %eax,%ecx
 11a:	89 c8                	mov    %ecx,%eax
}
 11c:	5d                   	pop    %ebp
 11d:	c3                   	ret    

0000011e <strlen>:

uint
strlen(char *s)
{
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 124:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 12b:	eb 04                	jmp    131 <strlen+0x13>
 12d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 131:	8b 45 fc             	mov    -0x4(%ebp),%eax
 134:	03 45 08             	add    0x8(%ebp),%eax
 137:	0f b6 00             	movzbl (%eax),%eax
 13a:	84 c0                	test   %al,%al
 13c:	75 ef                	jne    12d <strlen+0xf>
  return n;
 13e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 141:	c9                   	leave  
 142:	c3                   	ret    

00000143 <memset>:

void*
memset(void *dst, int c, uint n)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
 146:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 149:	8b 45 10             	mov    0x10(%ebp),%eax
 14c:	89 44 24 08          	mov    %eax,0x8(%esp)
 150:	8b 45 0c             	mov    0xc(%ebp),%eax
 153:	89 44 24 04          	mov    %eax,0x4(%esp)
 157:	8b 45 08             	mov    0x8(%ebp),%eax
 15a:	89 04 24             	mov    %eax,(%esp)
 15d:	e8 22 ff ff ff       	call   84 <stosb>
  return dst;
 162:	8b 45 08             	mov    0x8(%ebp),%eax
}
 165:	c9                   	leave  
 166:	c3                   	ret    

00000167 <strchr>:

char*
strchr(const char *s, char c)
{
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
 16a:	83 ec 04             	sub    $0x4,%esp
 16d:	8b 45 0c             	mov    0xc(%ebp),%eax
 170:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 173:	eb 14                	jmp    189 <strchr+0x22>
    if(*s == c)
 175:	8b 45 08             	mov    0x8(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 17e:	75 05                	jne    185 <strchr+0x1e>
      return (char*)s;
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	eb 13                	jmp    198 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 185:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	84 c0                	test   %al,%al
 191:	75 e2                	jne    175 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 193:	b8 00 00 00 00       	mov    $0x0,%eax
}
 198:	c9                   	leave  
 199:	c3                   	ret    

0000019a <gets>:

char*
gets(char *buf, int max)
{
 19a:	55                   	push   %ebp
 19b:	89 e5                	mov    %esp,%ebp
 19d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a7:	eb 44                	jmp    1ed <gets+0x53>
    cc = read(0, &c, 1);
 1a9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1b0:	00 
 1b1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1bf:	e8 e8 02 00 00       	call   4ac <read>
 1c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1cb:	7e 2d                	jle    1fa <gets+0x60>
      break;
    buf[i++] = c;
 1cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d0:	03 45 08             	add    0x8(%ebp),%eax
 1d3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1d7:	88 10                	mov    %dl,(%eax)
 1d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1dd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e1:	3c 0a                	cmp    $0xa,%al
 1e3:	74 16                	je     1fb <gets+0x61>
 1e5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e9:	3c 0d                	cmp    $0xd,%al
 1eb:	74 0e                	je     1fb <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f0:	83 c0 01             	add    $0x1,%eax
 1f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f6:	7c b1                	jl     1a9 <gets+0xf>
 1f8:	eb 01                	jmp    1fb <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1fa:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fe:	03 45 08             	add    0x8(%ebp),%eax
 201:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 204:	8b 45 08             	mov    0x8(%ebp),%eax
}
 207:	c9                   	leave  
 208:	c3                   	ret    

00000209 <stat>:

int
stat(char *n, struct stat *st)
{
 209:	55                   	push   %ebp
 20a:	89 e5                	mov    %esp,%ebp
 20c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 216:	00 
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	89 04 24             	mov    %eax,(%esp)
 21d:	e8 b2 02 00 00       	call   4d4 <open>
 222:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 225:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 229:	79 07                	jns    232 <stat+0x29>
    return -1;
 22b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 230:	eb 23                	jmp    255 <stat+0x4c>
  r = fstat(fd, st);
 232:	8b 45 0c             	mov    0xc(%ebp),%eax
 235:	89 44 24 04          	mov    %eax,0x4(%esp)
 239:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23c:	89 04 24             	mov    %eax,(%esp)
 23f:	e8 a8 02 00 00       	call   4ec <fstat>
 244:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 247:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24a:	89 04 24             	mov    %eax,(%esp)
 24d:	e8 6a 02 00 00       	call   4bc <close>
  return r;
 252:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 255:	c9                   	leave  
 256:	c3                   	ret    

00000257 <atoi>:

int
atoi(const char *s)
{
 257:	55                   	push   %ebp
 258:	89 e5                	mov    %esp,%ebp
 25a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 25d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 264:	eb 23                	jmp    289 <atoi+0x32>
    n = n*10 + *s++ - '0';
 266:	8b 55 fc             	mov    -0x4(%ebp),%edx
 269:	89 d0                	mov    %edx,%eax
 26b:	c1 e0 02             	shl    $0x2,%eax
 26e:	01 d0                	add    %edx,%eax
 270:	01 c0                	add    %eax,%eax
 272:	89 c2                	mov    %eax,%edx
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	0f b6 00             	movzbl (%eax),%eax
 27a:	0f be c0             	movsbl %al,%eax
 27d:	01 d0                	add    %edx,%eax
 27f:	83 e8 30             	sub    $0x30,%eax
 282:	89 45 fc             	mov    %eax,-0x4(%ebp)
 285:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 289:	8b 45 08             	mov    0x8(%ebp),%eax
 28c:	0f b6 00             	movzbl (%eax),%eax
 28f:	3c 2f                	cmp    $0x2f,%al
 291:	7e 0a                	jle    29d <atoi+0x46>
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	0f b6 00             	movzbl (%eax),%eax
 299:	3c 39                	cmp    $0x39,%al
 29b:	7e c9                	jle    266 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 29d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a0:	c9                   	leave  
 2a1:	c3                   	ret    

000002a2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a2:	55                   	push   %ebp
 2a3:	89 e5                	mov    %esp,%ebp
 2a5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2a8:	8b 45 08             	mov    0x8(%ebp),%eax
 2ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b4:	eb 13                	jmp    2c9 <memmove+0x27>
    *dst++ = *src++;
 2b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2b9:	0f b6 10             	movzbl (%eax),%edx
 2bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2bf:	88 10                	mov    %dl,(%eax)
 2c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2c5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2cd:	0f 9f c0             	setg   %al
 2d0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2d4:	84 c0                	test   %al,%al
 2d6:	75 de                	jne    2b6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2db:	c9                   	leave  
 2dc:	c3                   	ret    

000002dd <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 2dd:	55                   	push   %ebp
 2de:	89 e5                	mov    %esp,%ebp
 2e0:	83 ec 38             	sub    $0x38,%esp
 2e3:	8b 45 10             	mov    0x10(%ebp),%eax
 2e6:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 2e9:	8b 45 14             	mov    0x14(%ebp),%eax
 2ec:	8b 00                	mov    (%eax),%eax
 2ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 2f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2fc:	74 06                	je     304 <strtok+0x27>
 2fe:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 302:	75 54                	jne    358 <strtok+0x7b>
    return match;
 304:	8b 45 f0             	mov    -0x10(%ebp),%eax
 307:	eb 6e                	jmp    377 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 309:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30c:	03 45 0c             	add    0xc(%ebp),%eax
 30f:	0f b6 00             	movzbl (%eax),%eax
 312:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 315:	74 06                	je     31d <strtok+0x40>
      {
	index++;
 317:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 31b:	eb 3c                	jmp    359 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 31d:	8b 45 14             	mov    0x14(%ebp),%eax
 320:	8b 00                	mov    (%eax),%eax
 322:	8b 55 f4             	mov    -0xc(%ebp),%edx
 325:	29 c2                	sub    %eax,%edx
 327:	8b 45 14             	mov    0x14(%ebp),%eax
 32a:	8b 00                	mov    (%eax),%eax
 32c:	03 45 0c             	add    0xc(%ebp),%eax
 32f:	89 54 24 08          	mov    %edx,0x8(%esp)
 333:	89 44 24 04          	mov    %eax,0x4(%esp)
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	89 04 24             	mov    %eax,(%esp)
 33d:	e8 37 00 00 00       	call   379 <strncpy>
 342:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 345:	8b 45 08             	mov    0x8(%ebp),%eax
 348:	0f b6 00             	movzbl (%eax),%eax
 34b:	84 c0                	test   %al,%al
 34d:	74 19                	je     368 <strtok+0x8b>
	  match = 1;
 34f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 356:	eb 10                	jmp    368 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 358:	90                   	nop
 359:	8b 45 f4             	mov    -0xc(%ebp),%eax
 35c:	03 45 0c             	add    0xc(%ebp),%eax
 35f:	0f b6 00             	movzbl (%eax),%eax
 362:	84 c0                	test   %al,%al
 364:	75 a3                	jne    309 <strtok+0x2c>
 366:	eb 01                	jmp    369 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 368:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 369:	8b 45 f4             	mov    -0xc(%ebp),%eax
 36c:	8d 50 01             	lea    0x1(%eax),%edx
 36f:	8b 45 14             	mov    0x14(%ebp),%eax
 372:	89 10                	mov    %edx,(%eax)
  return match;
 374:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 377:	c9                   	leave  
 378:	c3                   	ret    

00000379 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 379:	55                   	push   %ebp
 37a:	89 e5                	mov    %esp,%ebp
 37c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 385:	90                   	nop
 386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 38a:	0f 9f c0             	setg   %al
 38d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 391:	84 c0                	test   %al,%al
 393:	74 30                	je     3c5 <strncpy+0x4c>
 395:	8b 45 0c             	mov    0xc(%ebp),%eax
 398:	0f b6 10             	movzbl (%eax),%edx
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	88 10                	mov    %dl,(%eax)
 3a0:	8b 45 08             	mov    0x8(%ebp),%eax
 3a3:	0f b6 00             	movzbl (%eax),%eax
 3a6:	84 c0                	test   %al,%al
 3a8:	0f 95 c0             	setne  %al
 3ab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3af:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3b3:	84 c0                	test   %al,%al
 3b5:	75 cf                	jne    386 <strncpy+0xd>
    ;
  while(n-- > 0)
 3b7:	eb 0c                	jmp    3c5 <strncpy+0x4c>
    *s++ = 0;
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
 3bc:	c6 00 00             	movb   $0x0,(%eax)
 3bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c3:	eb 01                	jmp    3c6 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 3c5:	90                   	nop
 3c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3ca:	0f 9f c0             	setg   %al
 3cd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3d1:	84 c0                	test   %al,%al
 3d3:	75 e4                	jne    3b9 <strncpy+0x40>
    *s++ = 0;
  return os;
 3d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d8:	c9                   	leave  
 3d9:	c3                   	ret    

000003da <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 3da:	55                   	push   %ebp
 3db:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 3dd:	eb 0c                	jmp    3eb <strncmp+0x11>
    n--, p++, q++;
 3df:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 3eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3ef:	74 1a                	je     40b <strncmp+0x31>
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	0f b6 00             	movzbl (%eax),%eax
 3f7:	84 c0                	test   %al,%al
 3f9:	74 10                	je     40b <strncmp+0x31>
 3fb:	8b 45 08             	mov    0x8(%ebp),%eax
 3fe:	0f b6 10             	movzbl (%eax),%edx
 401:	8b 45 0c             	mov    0xc(%ebp),%eax
 404:	0f b6 00             	movzbl (%eax),%eax
 407:	38 c2                	cmp    %al,%dl
 409:	74 d4                	je     3df <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 40b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 40f:	75 07                	jne    418 <strncmp+0x3e>
    return 0;
 411:	b8 00 00 00 00       	mov    $0x0,%eax
 416:	eb 18                	jmp    430 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	0f b6 00             	movzbl (%eax),%eax
 41e:	0f b6 d0             	movzbl %al,%edx
 421:	8b 45 0c             	mov    0xc(%ebp),%eax
 424:	0f b6 00             	movzbl (%eax),%eax
 427:	0f b6 c0             	movzbl %al,%eax
 42a:	89 d1                	mov    %edx,%ecx
 42c:	29 c1                	sub    %eax,%ecx
 42e:	89 c8                	mov    %ecx,%eax
}
 430:	5d                   	pop    %ebp
 431:	c3                   	ret    

00000432 <strcat>:

void
strcat(char *dest, char *p, char *q)
{  
 432:	55                   	push   %ebp
 433:	89 e5                	mov    %esp,%ebp
  while(*p){
 435:	eb 13                	jmp    44a <strcat+0x18>
    *dest++ = *p++;
 437:	8b 45 0c             	mov    0xc(%ebp),%eax
 43a:	0f b6 10             	movzbl (%eax),%edx
 43d:	8b 45 08             	mov    0x8(%ebp),%eax
 440:	88 10                	mov    %dl,(%eax)
 442:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 446:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, char *p, char *q)
{  
  while(*p){
 44a:	8b 45 0c             	mov    0xc(%ebp),%eax
 44d:	0f b6 00             	movzbl (%eax),%eax
 450:	84 c0                	test   %al,%al
 452:	75 e3                	jne    437 <strcat+0x5>
    *dest++ = *p++;
  }

  while(*q){
 454:	eb 13                	jmp    469 <strcat+0x37>
    *dest++ = *q++;
 456:	8b 45 10             	mov    0x10(%ebp),%eax
 459:	0f b6 10             	movzbl (%eax),%edx
 45c:	8b 45 08             	mov    0x8(%ebp),%eax
 45f:	88 10                	mov    %dl,(%eax)
 461:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 465:	83 45 10 01          	addl   $0x1,0x10(%ebp)
{  
  while(*p){
    *dest++ = *p++;
  }

  while(*q){
 469:	8b 45 10             	mov    0x10(%ebp),%eax
 46c:	0f b6 00             	movzbl (%eax),%eax
 46f:	84 c0                	test   %al,%al
 471:	75 e3                	jne    456 <strcat+0x24>
    *dest++ = *q++;
  }
  *dest = 0;
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	c6 00 00             	movb   $0x0,(%eax)
 479:	5d                   	pop    %ebp
 47a:	c3                   	ret    
 47b:	90                   	nop

0000047c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 47c:	b8 01 00 00 00       	mov    $0x1,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <exit>:
SYSCALL(exit)
 484:	b8 02 00 00 00       	mov    $0x2,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <wait>:
SYSCALL(wait)
 48c:	b8 03 00 00 00       	mov    $0x3,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <wait2>:
SYSCALL(wait2)
 494:	b8 16 00 00 00       	mov    $0x16,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <nice>:
SYSCALL(nice)
 49c:	b8 17 00 00 00       	mov    $0x17,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <pipe>:
SYSCALL(pipe)
 4a4:	b8 04 00 00 00       	mov    $0x4,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <read>:
SYSCALL(read)
 4ac:	b8 05 00 00 00       	mov    $0x5,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <write>:
SYSCALL(write)
 4b4:	b8 10 00 00 00       	mov    $0x10,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <close>:
SYSCALL(close)
 4bc:	b8 15 00 00 00       	mov    $0x15,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <kill>:
SYSCALL(kill)
 4c4:	b8 06 00 00 00       	mov    $0x6,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <exec>:
SYSCALL(exec)
 4cc:	b8 07 00 00 00       	mov    $0x7,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <open>:
SYSCALL(open)
 4d4:	b8 0f 00 00 00       	mov    $0xf,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <mknod>:
SYSCALL(mknod)
 4dc:	b8 11 00 00 00       	mov    $0x11,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <unlink>:
SYSCALL(unlink)
 4e4:	b8 12 00 00 00       	mov    $0x12,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <fstat>:
SYSCALL(fstat)
 4ec:	b8 08 00 00 00       	mov    $0x8,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <link>:
SYSCALL(link)
 4f4:	b8 13 00 00 00       	mov    $0x13,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <mkdir>:
SYSCALL(mkdir)
 4fc:	b8 14 00 00 00       	mov    $0x14,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <chdir>:
SYSCALL(chdir)
 504:	b8 09 00 00 00       	mov    $0x9,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <dup>:
SYSCALL(dup)
 50c:	b8 0a 00 00 00       	mov    $0xa,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <getpid>:
SYSCALL(getpid)
 514:	b8 0b 00 00 00       	mov    $0xb,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <sbrk>:
SYSCALL(sbrk)
 51c:	b8 0c 00 00 00       	mov    $0xc,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <sleep>:
SYSCALL(sleep)
 524:	b8 0d 00 00 00       	mov    $0xd,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <uptime>:
SYSCALL(uptime)
 52c:	b8 0e 00 00 00       	mov    $0xe,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 534:	55                   	push   %ebp
 535:	89 e5                	mov    %esp,%ebp
 537:	83 ec 28             	sub    $0x28,%esp
 53a:	8b 45 0c             	mov    0xc(%ebp),%eax
 53d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 540:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 547:	00 
 548:	8d 45 f4             	lea    -0xc(%ebp),%eax
 54b:	89 44 24 04          	mov    %eax,0x4(%esp)
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	89 04 24             	mov    %eax,(%esp)
 555:	e8 5a ff ff ff       	call   4b4 <write>
}
 55a:	c9                   	leave  
 55b:	c3                   	ret    

0000055c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 55c:	55                   	push   %ebp
 55d:	89 e5                	mov    %esp,%ebp
 55f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 562:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 569:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 56d:	74 17                	je     586 <printint+0x2a>
 56f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 573:	79 11                	jns    586 <printint+0x2a>
    neg = 1;
 575:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 57c:	8b 45 0c             	mov    0xc(%ebp),%eax
 57f:	f7 d8                	neg    %eax
 581:	89 45 ec             	mov    %eax,-0x14(%ebp)
 584:	eb 06                	jmp    58c <printint+0x30>
  } else {
    x = xx;
 586:	8b 45 0c             	mov    0xc(%ebp),%eax
 589:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 58c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 593:	8b 4d 10             	mov    0x10(%ebp),%ecx
 596:	8b 45 ec             	mov    -0x14(%ebp),%eax
 599:	ba 00 00 00 00       	mov    $0x0,%edx
 59e:	f7 f1                	div    %ecx
 5a0:	89 d0                	mov    %edx,%eax
 5a2:	0f b6 90 c0 0c 00 00 	movzbl 0xcc0(%eax),%edx
 5a9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5ac:	03 45 f4             	add    -0xc(%ebp),%eax
 5af:	88 10                	mov    %dl,(%eax)
 5b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5b5:	8b 55 10             	mov    0x10(%ebp),%edx
 5b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5be:	ba 00 00 00 00       	mov    $0x0,%edx
 5c3:	f7 75 d4             	divl   -0x2c(%ebp)
 5c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5cd:	75 c4                	jne    593 <printint+0x37>
  if(neg)
 5cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5d3:	74 2a                	je     5ff <printint+0xa3>
    buf[i++] = '-';
 5d5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5d8:	03 45 f4             	add    -0xc(%ebp),%eax
 5db:	c6 00 2d             	movb   $0x2d,(%eax)
 5de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5e2:	eb 1b                	jmp    5ff <printint+0xa3>
    putc(fd, buf[i]);
 5e4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5e7:	03 45 f4             	add    -0xc(%ebp),%eax
 5ea:	0f b6 00             	movzbl (%eax),%eax
 5ed:	0f be c0             	movsbl %al,%eax
 5f0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	89 04 24             	mov    %eax,(%esp)
 5fa:	e8 35 ff ff ff       	call   534 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5ff:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 603:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 607:	79 db                	jns    5e4 <printint+0x88>
    putc(fd, buf[i]);
}
 609:	c9                   	leave  
 60a:	c3                   	ret    

0000060b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 60b:	55                   	push   %ebp
 60c:	89 e5                	mov    %esp,%ebp
 60e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 611:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 618:	8d 45 0c             	lea    0xc(%ebp),%eax
 61b:	83 c0 04             	add    $0x4,%eax
 61e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 621:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 628:	e9 7d 01 00 00       	jmp    7aa <printf+0x19f>
    c = fmt[i] & 0xff;
 62d:	8b 55 0c             	mov    0xc(%ebp),%edx
 630:	8b 45 f0             	mov    -0x10(%ebp),%eax
 633:	01 d0                	add    %edx,%eax
 635:	0f b6 00             	movzbl (%eax),%eax
 638:	0f be c0             	movsbl %al,%eax
 63b:	25 ff 00 00 00       	and    $0xff,%eax
 640:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 643:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 647:	75 2c                	jne    675 <printf+0x6a>
      if(c == '%'){
 649:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 64d:	75 0c                	jne    65b <printf+0x50>
        state = '%';
 64f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 656:	e9 4b 01 00 00       	jmp    7a6 <printf+0x19b>
      } else {
        putc(fd, c);
 65b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65e:	0f be c0             	movsbl %al,%eax
 661:	89 44 24 04          	mov    %eax,0x4(%esp)
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	89 04 24             	mov    %eax,(%esp)
 66b:	e8 c4 fe ff ff       	call   534 <putc>
 670:	e9 31 01 00 00       	jmp    7a6 <printf+0x19b>
      }
    } else if(state == '%'){
 675:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 679:	0f 85 27 01 00 00    	jne    7a6 <printf+0x19b>
      if(c == 'd'){
 67f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 683:	75 2d                	jne    6b2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 685:	8b 45 e8             	mov    -0x18(%ebp),%eax
 688:	8b 00                	mov    (%eax),%eax
 68a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 691:	00 
 692:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 699:	00 
 69a:	89 44 24 04          	mov    %eax,0x4(%esp)
 69e:	8b 45 08             	mov    0x8(%ebp),%eax
 6a1:	89 04 24             	mov    %eax,(%esp)
 6a4:	e8 b3 fe ff ff       	call   55c <printint>
        ap++;
 6a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ad:	e9 ed 00 00 00       	jmp    79f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6b2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6b6:	74 06                	je     6be <printf+0xb3>
 6b8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6bc:	75 2d                	jne    6eb <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c1:	8b 00                	mov    (%eax),%eax
 6c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6ca:	00 
 6cb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6d2:	00 
 6d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d7:	8b 45 08             	mov    0x8(%ebp),%eax
 6da:	89 04 24             	mov    %eax,(%esp)
 6dd:	e8 7a fe ff ff       	call   55c <printint>
        ap++;
 6e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e6:	e9 b4 00 00 00       	jmp    79f <printf+0x194>
      } else if(c == 's'){
 6eb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6ef:	75 46                	jne    737 <printf+0x12c>
        s = (char*)*ap;
 6f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 701:	75 27                	jne    72a <printf+0x11f>
          s = "(null)";
 703:	c7 45 f4 fc 09 00 00 	movl   $0x9fc,-0xc(%ebp)
        while(*s != 0){
 70a:	eb 1e                	jmp    72a <printf+0x11f>
          putc(fd, *s);
 70c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70f:	0f b6 00             	movzbl (%eax),%eax
 712:	0f be c0             	movsbl %al,%eax
 715:	89 44 24 04          	mov    %eax,0x4(%esp)
 719:	8b 45 08             	mov    0x8(%ebp),%eax
 71c:	89 04 24             	mov    %eax,(%esp)
 71f:	e8 10 fe ff ff       	call   534 <putc>
          s++;
 724:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 728:	eb 01                	jmp    72b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 72a:	90                   	nop
 72b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72e:	0f b6 00             	movzbl (%eax),%eax
 731:	84 c0                	test   %al,%al
 733:	75 d7                	jne    70c <printf+0x101>
 735:	eb 68                	jmp    79f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 737:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 73b:	75 1d                	jne    75a <printf+0x14f>
        putc(fd, *ap);
 73d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	0f be c0             	movsbl %al,%eax
 745:	89 44 24 04          	mov    %eax,0x4(%esp)
 749:	8b 45 08             	mov    0x8(%ebp),%eax
 74c:	89 04 24             	mov    %eax,(%esp)
 74f:	e8 e0 fd ff ff       	call   534 <putc>
        ap++;
 754:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 758:	eb 45                	jmp    79f <printf+0x194>
      } else if(c == '%'){
 75a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 75e:	75 17                	jne    777 <printf+0x16c>
        putc(fd, c);
 760:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 763:	0f be c0             	movsbl %al,%eax
 766:	89 44 24 04          	mov    %eax,0x4(%esp)
 76a:	8b 45 08             	mov    0x8(%ebp),%eax
 76d:	89 04 24             	mov    %eax,(%esp)
 770:	e8 bf fd ff ff       	call   534 <putc>
 775:	eb 28                	jmp    79f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 777:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 77e:	00 
 77f:	8b 45 08             	mov    0x8(%ebp),%eax
 782:	89 04 24             	mov    %eax,(%esp)
 785:	e8 aa fd ff ff       	call   534 <putc>
        putc(fd, c);
 78a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 78d:	0f be c0             	movsbl %al,%eax
 790:	89 44 24 04          	mov    %eax,0x4(%esp)
 794:	8b 45 08             	mov    0x8(%ebp),%eax
 797:	89 04 24             	mov    %eax,(%esp)
 79a:	e8 95 fd ff ff       	call   534 <putc>
      }
      state = 0;
 79f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7aa:	8b 55 0c             	mov    0xc(%ebp),%edx
 7ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b0:	01 d0                	add    %edx,%eax
 7b2:	0f b6 00             	movzbl (%eax),%eax
 7b5:	84 c0                	test   %al,%al
 7b7:	0f 85 70 fe ff ff    	jne    62d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7bd:	c9                   	leave  
 7be:	c3                   	ret    
 7bf:	90                   	nop

000007c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c0:	55                   	push   %ebp
 7c1:	89 e5                	mov    %esp,%ebp
 7c3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c6:	8b 45 08             	mov    0x8(%ebp),%eax
 7c9:	83 e8 08             	sub    $0x8,%eax
 7cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7cf:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 7d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d7:	eb 24                	jmp    7fd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e1:	77 12                	ja     7f5 <free+0x35>
 7e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e9:	77 24                	ja     80f <free+0x4f>
 7eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ee:	8b 00                	mov    (%eax),%eax
 7f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7f3:	77 1a                	ja     80f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 800:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 803:	76 d4                	jbe    7d9 <free+0x19>
 805:	8b 45 fc             	mov    -0x4(%ebp),%eax
 808:	8b 00                	mov    (%eax),%eax
 80a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 80d:	76 ca                	jbe    7d9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 80f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 812:	8b 40 04             	mov    0x4(%eax),%eax
 815:	c1 e0 03             	shl    $0x3,%eax
 818:	89 c2                	mov    %eax,%edx
 81a:	03 55 f8             	add    -0x8(%ebp),%edx
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	39 c2                	cmp    %eax,%edx
 824:	75 24                	jne    84a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 826:	8b 45 f8             	mov    -0x8(%ebp),%eax
 829:	8b 50 04             	mov    0x4(%eax),%edx
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	8b 00                	mov    (%eax),%eax
 831:	8b 40 04             	mov    0x4(%eax),%eax
 834:	01 c2                	add    %eax,%edx
 836:	8b 45 f8             	mov    -0x8(%ebp),%eax
 839:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 83c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83f:	8b 00                	mov    (%eax),%eax
 841:	8b 10                	mov    (%eax),%edx
 843:	8b 45 f8             	mov    -0x8(%ebp),%eax
 846:	89 10                	mov    %edx,(%eax)
 848:	eb 0a                	jmp    854 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 84a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84d:	8b 10                	mov    (%eax),%edx
 84f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 852:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 854:	8b 45 fc             	mov    -0x4(%ebp),%eax
 857:	8b 40 04             	mov    0x4(%eax),%eax
 85a:	c1 e0 03             	shl    $0x3,%eax
 85d:	03 45 fc             	add    -0x4(%ebp),%eax
 860:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 863:	75 20                	jne    885 <free+0xc5>
    p->s.size += bp->s.size;
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 50 04             	mov    0x4(%eax),%edx
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	8b 40 04             	mov    0x4(%eax),%eax
 871:	01 c2                	add    %eax,%edx
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 879:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87c:	8b 10                	mov    (%eax),%edx
 87e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 881:	89 10                	mov    %edx,(%eax)
 883:	eb 08                	jmp    88d <free+0xcd>
  } else
    p->s.ptr = bp;
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	8b 55 f8             	mov    -0x8(%ebp),%edx
 88b:	89 10                	mov    %edx,(%eax)
  freep = p;
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	a3 dc 0c 00 00       	mov    %eax,0xcdc
}
 895:	c9                   	leave  
 896:	c3                   	ret    

00000897 <morecore>:

static Header*
morecore(uint nu)
{
 897:	55                   	push   %ebp
 898:	89 e5                	mov    %esp,%ebp
 89a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 89d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a4:	77 07                	ja     8ad <morecore+0x16>
    nu = 4096;
 8a6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ad:	8b 45 08             	mov    0x8(%ebp),%eax
 8b0:	c1 e0 03             	shl    $0x3,%eax
 8b3:	89 04 24             	mov    %eax,(%esp)
 8b6:	e8 61 fc ff ff       	call   51c <sbrk>
 8bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8be:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c2:	75 07                	jne    8cb <morecore+0x34>
    return 0;
 8c4:	b8 00 00 00 00       	mov    $0x0,%eax
 8c9:	eb 22                	jmp    8ed <morecore+0x56>
  hp = (Header*)p;
 8cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d4:	8b 55 08             	mov    0x8(%ebp),%edx
 8d7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8dd:	83 c0 08             	add    $0x8,%eax
 8e0:	89 04 24             	mov    %eax,(%esp)
 8e3:	e8 d8 fe ff ff       	call   7c0 <free>
  return freep;
 8e8:	a1 dc 0c 00 00       	mov    0xcdc,%eax
}
 8ed:	c9                   	leave  
 8ee:	c3                   	ret    

000008ef <malloc>:

void*
malloc(uint nbytes)
{
 8ef:	55                   	push   %ebp
 8f0:	89 e5                	mov    %esp,%ebp
 8f2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f5:	8b 45 08             	mov    0x8(%ebp),%eax
 8f8:	83 c0 07             	add    $0x7,%eax
 8fb:	c1 e8 03             	shr    $0x3,%eax
 8fe:	83 c0 01             	add    $0x1,%eax
 901:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 904:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 909:	89 45 f0             	mov    %eax,-0x10(%ebp)
 90c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 910:	75 23                	jne    935 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 912:	c7 45 f0 d4 0c 00 00 	movl   $0xcd4,-0x10(%ebp)
 919:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91c:	a3 dc 0c 00 00       	mov    %eax,0xcdc
 921:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 926:	a3 d4 0c 00 00       	mov    %eax,0xcd4
    base.s.size = 0;
 92b:	c7 05 d8 0c 00 00 00 	movl   $0x0,0xcd8
 932:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 935:	8b 45 f0             	mov    -0x10(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 940:	8b 40 04             	mov    0x4(%eax),%eax
 943:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 946:	72 4d                	jb     995 <malloc+0xa6>
      if(p->s.size == nunits)
 948:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94b:	8b 40 04             	mov    0x4(%eax),%eax
 94e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 951:	75 0c                	jne    95f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	8b 10                	mov    (%eax),%edx
 958:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95b:	89 10                	mov    %edx,(%eax)
 95d:	eb 26                	jmp    985 <malloc+0x96>
      else {
        p->s.size -= nunits;
 95f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 962:	8b 40 04             	mov    0x4(%eax),%eax
 965:	89 c2                	mov    %eax,%edx
 967:	2b 55 ec             	sub    -0x14(%ebp),%edx
 96a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 40 04             	mov    0x4(%eax),%eax
 976:	c1 e0 03             	shl    $0x3,%eax
 979:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 982:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 985:	8b 45 f0             	mov    -0x10(%ebp),%eax
 988:	a3 dc 0c 00 00       	mov    %eax,0xcdc
      return (void*)(p + 1);
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	83 c0 08             	add    $0x8,%eax
 993:	eb 38                	jmp    9cd <malloc+0xde>
    }
    if(p == freep)
 995:	a1 dc 0c 00 00       	mov    0xcdc,%eax
 99a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 99d:	75 1b                	jne    9ba <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 99f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9a2:	89 04 24             	mov    %eax,(%esp)
 9a5:	e8 ed fe ff ff       	call   897 <morecore>
 9aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b1:	75 07                	jne    9ba <malloc+0xcb>
        return 0;
 9b3:	b8 00 00 00 00       	mov    $0x0,%eax
 9b8:	eb 13                	jmp    9cd <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c3:	8b 00                	mov    (%eax),%eax
 9c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9c8:	e9 70 ff ff ff       	jmp    93d <malloc+0x4e>
}
 9cd:	c9                   	leave  
 9ce:	c3                   	ret    
