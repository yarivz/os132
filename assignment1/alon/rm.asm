
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
   f:	c7 44 24 04 cb 09 00 	movl   $0x9cb,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 e4 05 00 00       	call   607 <printf>
    exit();
  23:	e8 58 04 00 00       	call   480 <exit>
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
  41:	e8 9a 04 00 00       	call   4e0 <unlink>
  46:	85 c0                	test   %eax,%eax
  48:	79 26                	jns    70 <main+0x70>
      printf(2, "rm: %s failed to delete\n", argv[i]);
  4a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  4e:	c1 e0 02             	shl    $0x2,%eax
  51:	03 45 0c             	add    0xc(%ebp),%eax
  54:	8b 00                	mov    (%eax),%eax
  56:	89 44 24 08          	mov    %eax,0x8(%esp)
  5a:	c7 44 24 04 df 09 00 	movl   $0x9df,0x4(%esp)
  61:	00 
  62:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  69:	e8 99 05 00 00       	call   607 <printf>
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
  7e:	e8 fd 03 00 00       	call   480 <exit>
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
 1bf:	e8 e4 02 00 00       	call   4a8 <read>
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
 21d:	e8 ae 02 00 00       	call   4d0 <open>
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
 23f:	e8 a4 02 00 00       	call   4e8 <fstat>
 244:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 247:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24a:	89 04 24             	mov    %eax,(%esp)
 24d:	e8 66 02 00 00       	call   4b8 <close>
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
strcat(char *dest, const char *p, const char *q)
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
strcat(char *dest, const char *p, const char *q)
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
strcat(char *dest, const char *p, const char *q)
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
 473:	5d                   	pop    %ebp
 474:	c3                   	ret    
 475:	90                   	nop
 476:	90                   	nop
 477:	90                   	nop

00000478 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 478:	b8 01 00 00 00       	mov    $0x1,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <exit>:
SYSCALL(exit)
 480:	b8 02 00 00 00       	mov    $0x2,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <wait>:
SYSCALL(wait)
 488:	b8 03 00 00 00       	mov    $0x3,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <wait2>:
SYSCALL(wait2)
 490:	b8 16 00 00 00       	mov    $0x16,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <nice>:
SYSCALL(nice)
 498:	b8 17 00 00 00       	mov    $0x17,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <pipe>:
SYSCALL(pipe)
 4a0:	b8 04 00 00 00       	mov    $0x4,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <read>:
SYSCALL(read)
 4a8:	b8 05 00 00 00       	mov    $0x5,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <write>:
SYSCALL(write)
 4b0:	b8 10 00 00 00       	mov    $0x10,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <close>:
SYSCALL(close)
 4b8:	b8 15 00 00 00       	mov    $0x15,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <kill>:
SYSCALL(kill)
 4c0:	b8 06 00 00 00       	mov    $0x6,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <exec>:
SYSCALL(exec)
 4c8:	b8 07 00 00 00       	mov    $0x7,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <open>:
SYSCALL(open)
 4d0:	b8 0f 00 00 00       	mov    $0xf,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <mknod>:
SYSCALL(mknod)
 4d8:	b8 11 00 00 00       	mov    $0x11,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <unlink>:
SYSCALL(unlink)
 4e0:	b8 12 00 00 00       	mov    $0x12,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <fstat>:
SYSCALL(fstat)
 4e8:	b8 08 00 00 00       	mov    $0x8,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <link>:
SYSCALL(link)
 4f0:	b8 13 00 00 00       	mov    $0x13,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <mkdir>:
SYSCALL(mkdir)
 4f8:	b8 14 00 00 00       	mov    $0x14,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <chdir>:
SYSCALL(chdir)
 500:	b8 09 00 00 00       	mov    $0x9,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <dup>:
SYSCALL(dup)
 508:	b8 0a 00 00 00       	mov    $0xa,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <getpid>:
SYSCALL(getpid)
 510:	b8 0b 00 00 00       	mov    $0xb,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <sbrk>:
SYSCALL(sbrk)
 518:	b8 0c 00 00 00       	mov    $0xc,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <sleep>:
SYSCALL(sleep)
 520:	b8 0d 00 00 00       	mov    $0xd,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <uptime>:
SYSCALL(uptime)
 528:	b8 0e 00 00 00       	mov    $0xe,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 530:	55                   	push   %ebp
 531:	89 e5                	mov    %esp,%ebp
 533:	83 ec 28             	sub    $0x28,%esp
 536:	8b 45 0c             	mov    0xc(%ebp),%eax
 539:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 53c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 543:	00 
 544:	8d 45 f4             	lea    -0xc(%ebp),%eax
 547:	89 44 24 04          	mov    %eax,0x4(%esp)
 54b:	8b 45 08             	mov    0x8(%ebp),%eax
 54e:	89 04 24             	mov    %eax,(%esp)
 551:	e8 5a ff ff ff       	call   4b0 <write>
}
 556:	c9                   	leave  
 557:	c3                   	ret    

00000558 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 558:	55                   	push   %ebp
 559:	89 e5                	mov    %esp,%ebp
 55b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 55e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 565:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 569:	74 17                	je     582 <printint+0x2a>
 56b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 56f:	79 11                	jns    582 <printint+0x2a>
    neg = 1;
 571:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 578:	8b 45 0c             	mov    0xc(%ebp),%eax
 57b:	f7 d8                	neg    %eax
 57d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 580:	eb 06                	jmp    588 <printint+0x30>
  } else {
    x = xx;
 582:	8b 45 0c             	mov    0xc(%ebp),%eax
 585:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 588:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 58f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 592:	8b 45 ec             	mov    -0x14(%ebp),%eax
 595:	ba 00 00 00 00       	mov    $0x0,%edx
 59a:	f7 f1                	div    %ecx
 59c:	89 d0                	mov    %edx,%eax
 59e:	0f b6 90 bc 0c 00 00 	movzbl 0xcbc(%eax),%edx
 5a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5a8:	03 45 f4             	add    -0xc(%ebp),%eax
 5ab:	88 10                	mov    %dl,(%eax)
 5ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5b1:	8b 55 10             	mov    0x10(%ebp),%edx
 5b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ba:	ba 00 00 00 00       	mov    $0x0,%edx
 5bf:	f7 75 d4             	divl   -0x2c(%ebp)
 5c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c9:	75 c4                	jne    58f <printint+0x37>
  if(neg)
 5cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5cf:	74 2a                	je     5fb <printint+0xa3>
    buf[i++] = '-';
 5d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5d4:	03 45 f4             	add    -0xc(%ebp),%eax
 5d7:	c6 00 2d             	movb   $0x2d,(%eax)
 5da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5de:	eb 1b                	jmp    5fb <printint+0xa3>
    putc(fd, buf[i]);
 5e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5e3:	03 45 f4             	add    -0xc(%ebp),%eax
 5e6:	0f b6 00             	movzbl (%eax),%eax
 5e9:	0f be c0             	movsbl %al,%eax
 5ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f0:	8b 45 08             	mov    0x8(%ebp),%eax
 5f3:	89 04 24             	mov    %eax,(%esp)
 5f6:	e8 35 ff ff ff       	call   530 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 603:	79 db                	jns    5e0 <printint+0x88>
    putc(fd, buf[i]);
}
 605:	c9                   	leave  
 606:	c3                   	ret    

00000607 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 607:	55                   	push   %ebp
 608:	89 e5                	mov    %esp,%ebp
 60a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 60d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 614:	8d 45 0c             	lea    0xc(%ebp),%eax
 617:	83 c0 04             	add    $0x4,%eax
 61a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 61d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 624:	e9 7d 01 00 00       	jmp    7a6 <printf+0x19f>
    c = fmt[i] & 0xff;
 629:	8b 55 0c             	mov    0xc(%ebp),%edx
 62c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 62f:	01 d0                	add    %edx,%eax
 631:	0f b6 00             	movzbl (%eax),%eax
 634:	0f be c0             	movsbl %al,%eax
 637:	25 ff 00 00 00       	and    $0xff,%eax
 63c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 63f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 643:	75 2c                	jne    671 <printf+0x6a>
      if(c == '%'){
 645:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 649:	75 0c                	jne    657 <printf+0x50>
        state = '%';
 64b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 652:	e9 4b 01 00 00       	jmp    7a2 <printf+0x19b>
      } else {
        putc(fd, c);
 657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65a:	0f be c0             	movsbl %al,%eax
 65d:	89 44 24 04          	mov    %eax,0x4(%esp)
 661:	8b 45 08             	mov    0x8(%ebp),%eax
 664:	89 04 24             	mov    %eax,(%esp)
 667:	e8 c4 fe ff ff       	call   530 <putc>
 66c:	e9 31 01 00 00       	jmp    7a2 <printf+0x19b>
      }
    } else if(state == '%'){
 671:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 675:	0f 85 27 01 00 00    	jne    7a2 <printf+0x19b>
      if(c == 'd'){
 67b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 67f:	75 2d                	jne    6ae <printf+0xa7>
        printint(fd, *ap, 10, 1);
 681:	8b 45 e8             	mov    -0x18(%ebp),%eax
 684:	8b 00                	mov    (%eax),%eax
 686:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 68d:	00 
 68e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 695:	00 
 696:	89 44 24 04          	mov    %eax,0x4(%esp)
 69a:	8b 45 08             	mov    0x8(%ebp),%eax
 69d:	89 04 24             	mov    %eax,(%esp)
 6a0:	e8 b3 fe ff ff       	call   558 <printint>
        ap++;
 6a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a9:	e9 ed 00 00 00       	jmp    79b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6b2:	74 06                	je     6ba <printf+0xb3>
 6b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b8:	75 2d                	jne    6e7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6bd:	8b 00                	mov    (%eax),%eax
 6bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6c6:	00 
 6c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6ce:	00 
 6cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d3:	8b 45 08             	mov    0x8(%ebp),%eax
 6d6:	89 04 24             	mov    %eax,(%esp)
 6d9:	e8 7a fe ff ff       	call   558 <printint>
        ap++;
 6de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e2:	e9 b4 00 00 00       	jmp    79b <printf+0x194>
      } else if(c == 's'){
 6e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6eb:	75 46                	jne    733 <printf+0x12c>
        s = (char*)*ap;
 6ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fd:	75 27                	jne    726 <printf+0x11f>
          s = "(null)";
 6ff:	c7 45 f4 f8 09 00 00 	movl   $0x9f8,-0xc(%ebp)
        while(*s != 0){
 706:	eb 1e                	jmp    726 <printf+0x11f>
          putc(fd, *s);
 708:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70b:	0f b6 00             	movzbl (%eax),%eax
 70e:	0f be c0             	movsbl %al,%eax
 711:	89 44 24 04          	mov    %eax,0x4(%esp)
 715:	8b 45 08             	mov    0x8(%ebp),%eax
 718:	89 04 24             	mov    %eax,(%esp)
 71b:	e8 10 fe ff ff       	call   530 <putc>
          s++;
 720:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 724:	eb 01                	jmp    727 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 726:	90                   	nop
 727:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72a:	0f b6 00             	movzbl (%eax),%eax
 72d:	84 c0                	test   %al,%al
 72f:	75 d7                	jne    708 <printf+0x101>
 731:	eb 68                	jmp    79b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 733:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 737:	75 1d                	jne    756 <printf+0x14f>
        putc(fd, *ap);
 739:	8b 45 e8             	mov    -0x18(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	0f be c0             	movsbl %al,%eax
 741:	89 44 24 04          	mov    %eax,0x4(%esp)
 745:	8b 45 08             	mov    0x8(%ebp),%eax
 748:	89 04 24             	mov    %eax,(%esp)
 74b:	e8 e0 fd ff ff       	call   530 <putc>
        ap++;
 750:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 754:	eb 45                	jmp    79b <printf+0x194>
      } else if(c == '%'){
 756:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 75a:	75 17                	jne    773 <printf+0x16c>
        putc(fd, c);
 75c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75f:	0f be c0             	movsbl %al,%eax
 762:	89 44 24 04          	mov    %eax,0x4(%esp)
 766:	8b 45 08             	mov    0x8(%ebp),%eax
 769:	89 04 24             	mov    %eax,(%esp)
 76c:	e8 bf fd ff ff       	call   530 <putc>
 771:	eb 28                	jmp    79b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 773:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 77a:	00 
 77b:	8b 45 08             	mov    0x8(%ebp),%eax
 77e:	89 04 24             	mov    %eax,(%esp)
 781:	e8 aa fd ff ff       	call   530 <putc>
        putc(fd, c);
 786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 789:	0f be c0             	movsbl %al,%eax
 78c:	89 44 24 04          	mov    %eax,0x4(%esp)
 790:	8b 45 08             	mov    0x8(%ebp),%eax
 793:	89 04 24             	mov    %eax,(%esp)
 796:	e8 95 fd ff ff       	call   530 <putc>
      }
      state = 0;
 79b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7a2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ac:	01 d0                	add    %edx,%eax
 7ae:	0f b6 00             	movzbl (%eax),%eax
 7b1:	84 c0                	test   %al,%al
 7b3:	0f 85 70 fe ff ff    	jne    629 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b9:	c9                   	leave  
 7ba:	c3                   	ret    
 7bb:	90                   	nop

000007bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7bc:	55                   	push   %ebp
 7bd:	89 e5                	mov    %esp,%ebp
 7bf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c2:	8b 45 08             	mov    0x8(%ebp),%eax
 7c5:	83 e8 08             	sub    $0x8,%eax
 7c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7cb:	a1 d8 0c 00 00       	mov    0xcd8,%eax
 7d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d3:	eb 24                	jmp    7f9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d8:	8b 00                	mov    (%eax),%eax
 7da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7dd:	77 12                	ja     7f1 <free+0x35>
 7df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e5:	77 24                	ja     80b <free+0x4f>
 7e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ea:	8b 00                	mov    (%eax),%eax
 7ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ef:	77 1a                	ja     80b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ff:	76 d4                	jbe    7d5 <free+0x19>
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	8b 00                	mov    (%eax),%eax
 806:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 809:	76 ca                	jbe    7d5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 80b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80e:	8b 40 04             	mov    0x4(%eax),%eax
 811:	c1 e0 03             	shl    $0x3,%eax
 814:	89 c2                	mov    %eax,%edx
 816:	03 55 f8             	add    -0x8(%ebp),%edx
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	39 c2                	cmp    %eax,%edx
 820:	75 24                	jne    846 <free+0x8a>
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
 844:	eb 0a                	jmp    850 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 10                	mov    (%eax),%edx
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 40 04             	mov    0x4(%eax),%eax
 856:	c1 e0 03             	shl    $0x3,%eax
 859:	03 45 fc             	add    -0x4(%ebp),%eax
 85c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 85f:	75 20                	jne    881 <free+0xc5>
    p->s.size += bp->s.size;
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 50 04             	mov    0x4(%eax),%edx
 867:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86a:	8b 40 04             	mov    0x4(%eax),%eax
 86d:	01 c2                	add    %eax,%edx
 86f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 872:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 875:	8b 45 f8             	mov    -0x8(%ebp),%eax
 878:	8b 10                	mov    (%eax),%edx
 87a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87d:	89 10                	mov    %edx,(%eax)
 87f:	eb 08                	jmp    889 <free+0xcd>
  } else
    p->s.ptr = bp;
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 55 f8             	mov    -0x8(%ebp),%edx
 887:	89 10                	mov    %edx,(%eax)
  freep = p;
 889:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88c:	a3 d8 0c 00 00       	mov    %eax,0xcd8
}
 891:	c9                   	leave  
 892:	c3                   	ret    

00000893 <morecore>:

static Header*
morecore(uint nu)
{
 893:	55                   	push   %ebp
 894:	89 e5                	mov    %esp,%ebp
 896:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 899:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a0:	77 07                	ja     8a9 <morecore+0x16>
    nu = 4096;
 8a2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ac:	c1 e0 03             	shl    $0x3,%eax
 8af:	89 04 24             	mov    %eax,(%esp)
 8b2:	e8 61 fc ff ff       	call   518 <sbrk>
 8b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ba:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8be:	75 07                	jne    8c7 <morecore+0x34>
    return 0;
 8c0:	b8 00 00 00 00       	mov    $0x0,%eax
 8c5:	eb 22                	jmp    8e9 <morecore+0x56>
  hp = (Header*)p;
 8c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d0:	8b 55 08             	mov    0x8(%ebp),%edx
 8d3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d9:	83 c0 08             	add    $0x8,%eax
 8dc:	89 04 24             	mov    %eax,(%esp)
 8df:	e8 d8 fe ff ff       	call   7bc <free>
  return freep;
 8e4:	a1 d8 0c 00 00       	mov    0xcd8,%eax
}
 8e9:	c9                   	leave  
 8ea:	c3                   	ret    

000008eb <malloc>:

void*
malloc(uint nbytes)
{
 8eb:	55                   	push   %ebp
 8ec:	89 e5                	mov    %esp,%ebp
 8ee:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f1:	8b 45 08             	mov    0x8(%ebp),%eax
 8f4:	83 c0 07             	add    $0x7,%eax
 8f7:	c1 e8 03             	shr    $0x3,%eax
 8fa:	83 c0 01             	add    $0x1,%eax
 8fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 900:	a1 d8 0c 00 00       	mov    0xcd8,%eax
 905:	89 45 f0             	mov    %eax,-0x10(%ebp)
 908:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 90c:	75 23                	jne    931 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 90e:	c7 45 f0 d0 0c 00 00 	movl   $0xcd0,-0x10(%ebp)
 915:	8b 45 f0             	mov    -0x10(%ebp),%eax
 918:	a3 d8 0c 00 00       	mov    %eax,0xcd8
 91d:	a1 d8 0c 00 00       	mov    0xcd8,%eax
 922:	a3 d0 0c 00 00       	mov    %eax,0xcd0
    base.s.size = 0;
 927:	c7 05 d4 0c 00 00 00 	movl   $0x0,0xcd4
 92e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 931:	8b 45 f0             	mov    -0x10(%ebp),%eax
 934:	8b 00                	mov    (%eax),%eax
 936:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 939:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93c:	8b 40 04             	mov    0x4(%eax),%eax
 93f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 942:	72 4d                	jb     991 <malloc+0xa6>
      if(p->s.size == nunits)
 944:	8b 45 f4             	mov    -0xc(%ebp),%eax
 947:	8b 40 04             	mov    0x4(%eax),%eax
 94a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 94d:	75 0c                	jne    95b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 94f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 952:	8b 10                	mov    (%eax),%edx
 954:	8b 45 f0             	mov    -0x10(%ebp),%eax
 957:	89 10                	mov    %edx,(%eax)
 959:	eb 26                	jmp    981 <malloc+0x96>
      else {
        p->s.size -= nunits;
 95b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95e:	8b 40 04             	mov    0x4(%eax),%eax
 961:	89 c2                	mov    %eax,%edx
 963:	2b 55 ec             	sub    -0x14(%ebp),%edx
 966:	8b 45 f4             	mov    -0xc(%ebp),%eax
 969:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	8b 40 04             	mov    0x4(%eax),%eax
 972:	c1 e0 03             	shl    $0x3,%eax
 975:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 978:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 97e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 981:	8b 45 f0             	mov    -0x10(%ebp),%eax
 984:	a3 d8 0c 00 00       	mov    %eax,0xcd8
      return (void*)(p + 1);
 989:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98c:	83 c0 08             	add    $0x8,%eax
 98f:	eb 38                	jmp    9c9 <malloc+0xde>
    }
    if(p == freep)
 991:	a1 d8 0c 00 00       	mov    0xcd8,%eax
 996:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 999:	75 1b                	jne    9b6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 99b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 99e:	89 04 24             	mov    %eax,(%esp)
 9a1:	e8 ed fe ff ff       	call   893 <morecore>
 9a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9ad:	75 07                	jne    9b6 <malloc+0xcb>
        return 0;
 9af:	b8 00 00 00 00       	mov    $0x0,%eax
 9b4:	eb 13                	jmp    9c9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bf:	8b 00                	mov    (%eax),%eax
 9c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9c4:	e9 70 ff ff ff       	jmp    939 <malloc+0x4e>
}
 9c9:	c9                   	leave  
 9ca:	c3                   	ret    
