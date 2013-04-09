
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10:	00 
  11:	c7 04 24 7c 0a 00 00 	movl   $0xa7c,(%esp)
  18:	e8 4f 05 00 00       	call   56c <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 7c 0a 00 00 	movl   $0xa7c,(%esp)
  38:	e8 37 05 00 00       	call   574 <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 7c 0a 00 00 	movl   $0xa7c,(%esp)
  4c:	e8 1b 05 00 00       	call   56c <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 47 05 00 00       	call   5a4 <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 3b 05 00 00       	call   5a4 <dup>
  69:	eb 01                	jmp    6c <main+0x6c>
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  }
  6b:	90                   	nop
  }
  dup(0);  // stdout
  dup(0);  // stderr

  for(;;){
    printf(1, "init: starting sh\n");
  6c:	c7 44 24 04 84 0a 00 	movl   $0xa84,0x4(%esp)
  73:	00 
  74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7b:	e8 29 06 00 00       	call   6a9 <printf>
    pid = fork();
  80:	e8 8f 04 00 00       	call   514 <fork>
  85:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  89:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8e:	79 19                	jns    a9 <main+0xa9>
      printf(1, "init: fork failed\n");
  90:	c7 44 24 04 97 0a 00 	movl   $0xa97,0x4(%esp)
  97:	00 
  98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9f:	e8 05 06 00 00       	call   6a9 <printf>
      exit();
  a4:	e8 73 04 00 00       	call   51c <exit>
    }
    if(pid == 0){
  a9:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  ae:	75 41                	jne    f1 <main+0xf1>
      exec("sh", argv);
  b0:	c7 44 24 04 8c 0d 00 	movl   $0xd8c,0x4(%esp)
  b7:	00 
  b8:	c7 04 24 79 0a 00 00 	movl   $0xa79,(%esp)
  bf:	e8 a0 04 00 00       	call   564 <exec>
      printf(1, "init: exec sh failed\n");
  c4:	c7 44 24 04 aa 0a 00 	movl   $0xaaa,0x4(%esp)
  cb:	00 
  cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d3:	e8 d1 05 00 00       	call   6a9 <printf>
      exit();
  d8:	e8 3f 04 00 00       	call   51c <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  dd:	c7 44 24 04 c0 0a 00 	movl   $0xac0,0x4(%esp)
  e4:	00 
  e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ec:	e8 b8 05 00 00       	call   6a9 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f1:	e8 2e 04 00 00       	call   524 <wait>
  f6:	89 44 24 18          	mov    %eax,0x18(%esp)
  fa:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  ff:	0f 88 66 ff ff ff    	js     6b <main+0x6b>
 105:	8b 44 24 18          	mov    0x18(%esp),%eax
 109:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 10d:	75 ce                	jne    dd <main+0xdd>
      printf(1, "zombie!\n");
  }
 10f:	e9 57 ff ff ff       	jmp    6b <main+0x6b>

00000114 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	57                   	push   %edi
 118:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 119:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11c:	8b 55 10             	mov    0x10(%ebp),%edx
 11f:	8b 45 0c             	mov    0xc(%ebp),%eax
 122:	89 cb                	mov    %ecx,%ebx
 124:	89 df                	mov    %ebx,%edi
 126:	89 d1                	mov    %edx,%ecx
 128:	fc                   	cld    
 129:	f3 aa                	rep stos %al,%es:(%edi)
 12b:	89 ca                	mov    %ecx,%edx
 12d:	89 fb                	mov    %edi,%ebx
 12f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 132:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 135:	5b                   	pop    %ebx
 136:	5f                   	pop    %edi
 137:	5d                   	pop    %ebp
 138:	c3                   	ret    

00000139 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 145:	90                   	nop
 146:	8b 45 0c             	mov    0xc(%ebp),%eax
 149:	0f b6 10             	movzbl (%eax),%edx
 14c:	8b 45 08             	mov    0x8(%ebp),%eax
 14f:	88 10                	mov    %dl,(%eax)
 151:	8b 45 08             	mov    0x8(%ebp),%eax
 154:	0f b6 00             	movzbl (%eax),%eax
 157:	84 c0                	test   %al,%al
 159:	0f 95 c0             	setne  %al
 15c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 160:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 164:	84 c0                	test   %al,%al
 166:	75 de                	jne    146 <strcpy+0xd>
    ;
  return os;
 168:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 16b:	c9                   	leave  
 16c:	c3                   	ret    

0000016d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16d:	55                   	push   %ebp
 16e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 170:	eb 08                	jmp    17a <strcmp+0xd>
    p++, q++;
 172:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 176:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	0f b6 00             	movzbl (%eax),%eax
 180:	84 c0                	test   %al,%al
 182:	74 10                	je     194 <strcmp+0x27>
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	0f b6 10             	movzbl (%eax),%edx
 18a:	8b 45 0c             	mov    0xc(%ebp),%eax
 18d:	0f b6 00             	movzbl (%eax),%eax
 190:	38 c2                	cmp    %al,%dl
 192:	74 de                	je     172 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	0f b6 d0             	movzbl %al,%edx
 19d:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	0f b6 c0             	movzbl %al,%eax
 1a6:	89 d1                	mov    %edx,%ecx
 1a8:	29 c1                	sub    %eax,%ecx
 1aa:	89 c8                	mov    %ecx,%eax
}
 1ac:	5d                   	pop    %ebp
 1ad:	c3                   	ret    

000001ae <strlen>:

uint
strlen(char *s)
{
 1ae:	55                   	push   %ebp
 1af:	89 e5                	mov    %esp,%ebp
 1b1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 1b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1bb:	eb 04                	jmp    1c1 <strlen+0x13>
 1bd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
 1c7:	01 d0                	add    %edx,%eax
 1c9:	0f b6 00             	movzbl (%eax),%eax
 1cc:	84 c0                	test   %al,%al
 1ce:	75 ed                	jne    1bd <strlen+0xf>
  return n;
 1d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d3:	c9                   	leave  
 1d4:	c3                   	ret    

000001d5 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d5:	55                   	push   %ebp
 1d6:	89 e5                	mov    %esp,%ebp
 1d8:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1db:	8b 45 10             	mov    0x10(%ebp),%eax
 1de:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ec:	89 04 24             	mov    %eax,(%esp)
 1ef:	e8 20 ff ff ff       	call   114 <stosb>
  return dst;
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f7:	c9                   	leave  
 1f8:	c3                   	ret    

000001f9 <strchr>:

char*
strchr(const char *s, char c)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	83 ec 04             	sub    $0x4,%esp
 1ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 202:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 205:	eb 14                	jmp    21b <strchr+0x22>
    if(*s == c)
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	0f b6 00             	movzbl (%eax),%eax
 20d:	3a 45 fc             	cmp    -0x4(%ebp),%al
 210:	75 05                	jne    217 <strchr+0x1e>
      return (char*)s;
 212:	8b 45 08             	mov    0x8(%ebp),%eax
 215:	eb 13                	jmp    22a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 217:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	0f b6 00             	movzbl (%eax),%eax
 221:	84 c0                	test   %al,%al
 223:	75 e2                	jne    207 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 225:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22a:	c9                   	leave  
 22b:	c3                   	ret    

0000022c <gets>:

char*
gets(char *buf, int max)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
 22f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 232:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 239:	eb 46                	jmp    281 <gets+0x55>
    cc = read(0, &c, 1);
 23b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 242:	00 
 243:	8d 45 ef             	lea    -0x11(%ebp),%eax
 246:	89 44 24 04          	mov    %eax,0x4(%esp)
 24a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 251:	e8 ee 02 00 00       	call   544 <read>
 256:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 259:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 25d:	7e 2f                	jle    28e <gets+0x62>
      break;
    buf[i++] = c;
 25f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	01 c2                	add    %eax,%edx
 267:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26b:	88 02                	mov    %al,(%edx)
 26d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 271:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 275:	3c 0a                	cmp    $0xa,%al
 277:	74 16                	je     28f <gets+0x63>
 279:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27d:	3c 0d                	cmp    $0xd,%al
 27f:	74 0e                	je     28f <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 281:	8b 45 f4             	mov    -0xc(%ebp),%eax
 284:	83 c0 01             	add    $0x1,%eax
 287:	3b 45 0c             	cmp    0xc(%ebp),%eax
 28a:	7c af                	jl     23b <gets+0xf>
 28c:	eb 01                	jmp    28f <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 28e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 28f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	01 d0                	add    %edx,%eax
 297:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29d:	c9                   	leave  
 29e:	c3                   	ret    

0000029f <stat>:

int
stat(char *n, struct stat *st)
{
 29f:	55                   	push   %ebp
 2a0:	89 e5                	mov    %esp,%ebp
 2a2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2ac:	00 
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	89 04 24             	mov    %eax,(%esp)
 2b3:	e8 b4 02 00 00       	call   56c <open>
 2b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2bf:	79 07                	jns    2c8 <stat+0x29>
    return -1;
 2c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2c6:	eb 23                	jmp    2eb <stat+0x4c>
  r = fstat(fd, st);
 2c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 2cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d2:	89 04 24             	mov    %eax,(%esp)
 2d5:	e8 aa 02 00 00       	call   584 <fstat>
 2da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e0:	89 04 24             	mov    %eax,(%esp)
 2e3:	e8 6c 02 00 00       	call   554 <close>
  return r;
 2e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2eb:	c9                   	leave  
 2ec:	c3                   	ret    

000002ed <atoi>:

int
atoi(const char *s)
{
 2ed:	55                   	push   %ebp
 2ee:	89 e5                	mov    %esp,%ebp
 2f0:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2fa:	eb 23                	jmp    31f <atoi+0x32>
    n = n*10 + *s++ - '0';
 2fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2ff:	89 d0                	mov    %edx,%eax
 301:	c1 e0 02             	shl    $0x2,%eax
 304:	01 d0                	add    %edx,%eax
 306:	01 c0                	add    %eax,%eax
 308:	89 c2                	mov    %eax,%edx
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	0f b6 00             	movzbl (%eax),%eax
 310:	0f be c0             	movsbl %al,%eax
 313:	01 d0                	add    %edx,%eax
 315:	83 e8 30             	sub    $0x30,%eax
 318:	89 45 fc             	mov    %eax,-0x4(%ebp)
 31b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	0f b6 00             	movzbl (%eax),%eax
 325:	3c 2f                	cmp    $0x2f,%al
 327:	7e 0a                	jle    333 <atoi+0x46>
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	3c 39                	cmp    $0x39,%al
 331:	7e c9                	jle    2fc <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 333:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 336:	c9                   	leave  
 337:	c3                   	ret    

00000338 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 338:	55                   	push   %ebp
 339:	89 e5                	mov    %esp,%ebp
 33b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 33e:	8b 45 08             	mov    0x8(%ebp),%eax
 341:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 344:	8b 45 0c             	mov    0xc(%ebp),%eax
 347:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 34a:	eb 13                	jmp    35f <memmove+0x27>
    *dst++ = *src++;
 34c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 34f:	0f b6 10             	movzbl (%eax),%edx
 352:	8b 45 fc             	mov    -0x4(%ebp),%eax
 355:	88 10                	mov    %dl,(%eax)
 357:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 35b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 363:	0f 9f c0             	setg   %al
 366:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 36a:	84 c0                	test   %al,%al
 36c:	75 de                	jne    34c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 371:	c9                   	leave  
 372:	c3                   	ret    

00000373 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 373:	55                   	push   %ebp
 374:	89 e5                	mov    %esp,%ebp
 376:	83 ec 38             	sub    $0x38,%esp
 379:	8b 45 10             	mov    0x10(%ebp),%eax
 37c:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 37f:	8b 45 14             	mov    0x14(%ebp),%eax
 382:	8b 00                	mov    (%eax),%eax
 384:	89 45 f4             	mov    %eax,-0xc(%ebp)
 387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 38e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 392:	74 06                	je     39a <strtok+0x27>
 394:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 398:	75 5a                	jne    3f4 <strtok+0x81>
    return match;
 39a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 39d:	eb 76                	jmp    415 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 39f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a5:	01 d0                	add    %edx,%eax
 3a7:	0f b6 00             	movzbl (%eax),%eax
 3aa:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3ad:	74 06                	je     3b5 <strtok+0x42>
      {
	index++;
 3af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3b3:	eb 40                	jmp    3f5 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 3b5:	8b 45 14             	mov    0x14(%ebp),%eax
 3b8:	8b 00                	mov    (%eax),%eax
 3ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3bd:	29 c2                	sub    %eax,%edx
 3bf:	8b 45 14             	mov    0x14(%ebp),%eax
 3c2:	8b 00                	mov    (%eax),%eax
 3c4:	89 c1                	mov    %eax,%ecx
 3c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c9:	01 c8                	add    %ecx,%eax
 3cb:	89 54 24 08          	mov    %edx,0x8(%esp)
 3cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	89 04 24             	mov    %eax,(%esp)
 3d9:	e8 39 00 00 00       	call   417 <strncpy>
 3de:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 3e1:	8b 45 08             	mov    0x8(%ebp),%eax
 3e4:	0f b6 00             	movzbl (%eax),%eax
 3e7:	84 c0                	test   %al,%al
 3e9:	74 1b                	je     406 <strtok+0x93>
	  match = 1;
 3eb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 3f2:	eb 12                	jmp    406 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 3f4:	90                   	nop
 3f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fb:	01 d0                	add    %edx,%eax
 3fd:	0f b6 00             	movzbl (%eax),%eax
 400:	84 c0                	test   %al,%al
 402:	75 9b                	jne    39f <strtok+0x2c>
 404:	eb 01                	jmp    407 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 406:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 407:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40a:	8d 50 01             	lea    0x1(%eax),%edx
 40d:	8b 45 14             	mov    0x14(%ebp),%eax
 410:	89 10                	mov    %edx,(%eax)
  return match;
 412:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 415:	c9                   	leave  
 416:	c3                   	ret    

00000417 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 417:	55                   	push   %ebp
 418:	89 e5                	mov    %esp,%ebp
 41a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
 420:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 423:	90                   	nop
 424:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 428:	0f 9f c0             	setg   %al
 42b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 42f:	84 c0                	test   %al,%al
 431:	74 30                	je     463 <strncpy+0x4c>
 433:	8b 45 0c             	mov    0xc(%ebp),%eax
 436:	0f b6 10             	movzbl (%eax),%edx
 439:	8b 45 08             	mov    0x8(%ebp),%eax
 43c:	88 10                	mov    %dl,(%eax)
 43e:	8b 45 08             	mov    0x8(%ebp),%eax
 441:	0f b6 00             	movzbl (%eax),%eax
 444:	84 c0                	test   %al,%al
 446:	0f 95 c0             	setne  %al
 449:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 44d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 451:	84 c0                	test   %al,%al
 453:	75 cf                	jne    424 <strncpy+0xd>
    ;
  while(n-- > 0)
 455:	eb 0c                	jmp    463 <strncpy+0x4c>
    *s++ = 0;
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	c6 00 00             	movb   $0x0,(%eax)
 45d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 461:	eb 01                	jmp    464 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 463:	90                   	nop
 464:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 468:	0f 9f c0             	setg   %al
 46b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 46f:	84 c0                	test   %al,%al
 471:	75 e4                	jne    457 <strncpy+0x40>
    *s++ = 0;
  return os;
 473:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 476:	c9                   	leave  
 477:	c3                   	ret    

00000478 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 478:	55                   	push   %ebp
 479:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 47b:	eb 0c                	jmp    489 <strncmp+0x11>
    n--, p++, q++;
 47d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 481:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 485:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 489:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 48d:	74 1a                	je     4a9 <strncmp+0x31>
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
 492:	0f b6 00             	movzbl (%eax),%eax
 495:	84 c0                	test   %al,%al
 497:	74 10                	je     4a9 <strncmp+0x31>
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	0f b6 10             	movzbl (%eax),%edx
 49f:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a2:	0f b6 00             	movzbl (%eax),%eax
 4a5:	38 c2                	cmp    %al,%dl
 4a7:	74 d4                	je     47d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 4a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4ad:	75 07                	jne    4b6 <strncmp+0x3e>
    return 0;
 4af:	b8 00 00 00 00       	mov    $0x0,%eax
 4b4:	eb 18                	jmp    4ce <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4b6:	8b 45 08             	mov    0x8(%ebp),%eax
 4b9:	0f b6 00             	movzbl (%eax),%eax
 4bc:	0f b6 d0             	movzbl %al,%edx
 4bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c2:	0f b6 00             	movzbl (%eax),%eax
 4c5:	0f b6 c0             	movzbl %al,%eax
 4c8:	89 d1                	mov    %edx,%ecx
 4ca:	29 c1                	sub    %eax,%ecx
 4cc:	89 c8                	mov    %ecx,%eax
}
 4ce:	5d                   	pop    %ebp
 4cf:	c3                   	ret    

000004d0 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
  while(*p){
 4d3:	eb 13                	jmp    4e8 <strcat+0x18>
    *dest++ = *p++;
 4d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d8:	0f b6 10             	movzbl (%eax),%edx
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	88 10                	mov    %dl,(%eax)
 4e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4e4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 4e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 4eb:	0f b6 00             	movzbl (%eax),%eax
 4ee:	84 c0                	test   %al,%al
 4f0:	75 e3                	jne    4d5 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 4f2:	eb 13                	jmp    507 <strcat+0x37>
    *dest++ = *q++;
 4f4:	8b 45 10             	mov    0x10(%ebp),%eax
 4f7:	0f b6 10             	movzbl (%eax),%edx
 4fa:	8b 45 08             	mov    0x8(%ebp),%eax
 4fd:	88 10                	mov    %dl,(%eax)
 4ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 503:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 507:	8b 45 10             	mov    0x10(%ebp),%eax
 50a:	0f b6 00             	movzbl (%eax),%eax
 50d:	84 c0                	test   %al,%al
 50f:	75 e3                	jne    4f4 <strcat+0x24>
    *dest++ = *q++;
  }  
 511:	5d                   	pop    %ebp
 512:	c3                   	ret    
 513:	90                   	nop

00000514 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 514:	b8 01 00 00 00       	mov    $0x1,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <exit>:
SYSCALL(exit)
 51c:	b8 02 00 00 00       	mov    $0x2,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <wait>:
SYSCALL(wait)
 524:	b8 03 00 00 00       	mov    $0x3,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <wait2>:
SYSCALL(wait2)
 52c:	b8 16 00 00 00       	mov    $0x16,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <nice>:
SYSCALL(nice)
 534:	b8 17 00 00 00       	mov    $0x17,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <pipe>:
SYSCALL(pipe)
 53c:	b8 04 00 00 00       	mov    $0x4,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <read>:
SYSCALL(read)
 544:	b8 05 00 00 00       	mov    $0x5,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <write>:
SYSCALL(write)
 54c:	b8 10 00 00 00       	mov    $0x10,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <close>:
SYSCALL(close)
 554:	b8 15 00 00 00       	mov    $0x15,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <kill>:
SYSCALL(kill)
 55c:	b8 06 00 00 00       	mov    $0x6,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <exec>:
SYSCALL(exec)
 564:	b8 07 00 00 00       	mov    $0x7,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <open>:
SYSCALL(open)
 56c:	b8 0f 00 00 00       	mov    $0xf,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <mknod>:
SYSCALL(mknod)
 574:	b8 11 00 00 00       	mov    $0x11,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <unlink>:
SYSCALL(unlink)
 57c:	b8 12 00 00 00       	mov    $0x12,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <fstat>:
SYSCALL(fstat)
 584:	b8 08 00 00 00       	mov    $0x8,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <link>:
SYSCALL(link)
 58c:	b8 13 00 00 00       	mov    $0x13,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <mkdir>:
SYSCALL(mkdir)
 594:	b8 14 00 00 00       	mov    $0x14,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <chdir>:
SYSCALL(chdir)
 59c:	b8 09 00 00 00       	mov    $0x9,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <dup>:
SYSCALL(dup)
 5a4:	b8 0a 00 00 00       	mov    $0xa,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <getpid>:
SYSCALL(getpid)
 5ac:	b8 0b 00 00 00       	mov    $0xb,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <sbrk>:
SYSCALL(sbrk)
 5b4:	b8 0c 00 00 00       	mov    $0xc,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <sleep>:
SYSCALL(sleep)
 5bc:	b8 0d 00 00 00       	mov    $0xd,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <uptime>:
SYSCALL(uptime)
 5c4:	b8 0e 00 00 00       	mov    $0xe,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5cc:	55                   	push   %ebp
 5cd:	89 e5                	mov    %esp,%ebp
 5cf:	83 ec 28             	sub    $0x28,%esp
 5d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5df:	00 
 5e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ea:	89 04 24             	mov    %eax,(%esp)
 5ed:	e8 5a ff ff ff       	call   54c <write>
}
 5f2:	c9                   	leave  
 5f3:	c3                   	ret    

000005f4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5f4:	55                   	push   %ebp
 5f5:	89 e5                	mov    %esp,%ebp
 5f7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 601:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 605:	74 17                	je     61e <printint+0x2a>
 607:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 60b:	79 11                	jns    61e <printint+0x2a>
    neg = 1;
 60d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 614:	8b 45 0c             	mov    0xc(%ebp),%eax
 617:	f7 d8                	neg    %eax
 619:	89 45 ec             	mov    %eax,-0x14(%ebp)
 61c:	eb 06                	jmp    624 <printint+0x30>
  } else {
    x = xx;
 61e:	8b 45 0c             	mov    0xc(%ebp),%eax
 621:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 624:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 62b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 62e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 631:	ba 00 00 00 00       	mov    $0x0,%edx
 636:	f7 f1                	div    %ecx
 638:	89 d0                	mov    %edx,%eax
 63a:	0f b6 80 94 0d 00 00 	movzbl 0xd94(%eax),%eax
 641:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 644:	8b 55 f4             	mov    -0xc(%ebp),%edx
 647:	01 ca                	add    %ecx,%edx
 649:	88 02                	mov    %al,(%edx)
 64b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 64f:	8b 55 10             	mov    0x10(%ebp),%edx
 652:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 655:	8b 45 ec             	mov    -0x14(%ebp),%eax
 658:	ba 00 00 00 00       	mov    $0x0,%edx
 65d:	f7 75 d4             	divl   -0x2c(%ebp)
 660:	89 45 ec             	mov    %eax,-0x14(%ebp)
 663:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 667:	75 c2                	jne    62b <printint+0x37>
  if(neg)
 669:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 66d:	74 2e                	je     69d <printint+0xa9>
    buf[i++] = '-';
 66f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 672:	8b 45 f4             	mov    -0xc(%ebp),%eax
 675:	01 d0                	add    %edx,%eax
 677:	c6 00 2d             	movb   $0x2d,(%eax)
 67a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 67e:	eb 1d                	jmp    69d <printint+0xa9>
    putc(fd, buf[i]);
 680:	8d 55 dc             	lea    -0x24(%ebp),%edx
 683:	8b 45 f4             	mov    -0xc(%ebp),%eax
 686:	01 d0                	add    %edx,%eax
 688:	0f b6 00             	movzbl (%eax),%eax
 68b:	0f be c0             	movsbl %al,%eax
 68e:	89 44 24 04          	mov    %eax,0x4(%esp)
 692:	8b 45 08             	mov    0x8(%ebp),%eax
 695:	89 04 24             	mov    %eax,(%esp)
 698:	e8 2f ff ff ff       	call   5cc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 69d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a5:	79 d9                	jns    680 <printint+0x8c>
    putc(fd, buf[i]);
}
 6a7:	c9                   	leave  
 6a8:	c3                   	ret    

000006a9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6a9:	55                   	push   %ebp
 6aa:	89 e5                	mov    %esp,%ebp
 6ac:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6b6:	8d 45 0c             	lea    0xc(%ebp),%eax
 6b9:	83 c0 04             	add    $0x4,%eax
 6bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6c6:	e9 7d 01 00 00       	jmp    848 <printf+0x19f>
    c = fmt[i] & 0xff;
 6cb:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d1:	01 d0                	add    %edx,%eax
 6d3:	0f b6 00             	movzbl (%eax),%eax
 6d6:	0f be c0             	movsbl %al,%eax
 6d9:	25 ff 00 00 00       	and    $0xff,%eax
 6de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6e1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e5:	75 2c                	jne    713 <printf+0x6a>
      if(c == '%'){
 6e7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6eb:	75 0c                	jne    6f9 <printf+0x50>
        state = '%';
 6ed:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6f4:	e9 4b 01 00 00       	jmp    844 <printf+0x19b>
      } else {
        putc(fd, c);
 6f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6fc:	0f be c0             	movsbl %al,%eax
 6ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 703:	8b 45 08             	mov    0x8(%ebp),%eax
 706:	89 04 24             	mov    %eax,(%esp)
 709:	e8 be fe ff ff       	call   5cc <putc>
 70e:	e9 31 01 00 00       	jmp    844 <printf+0x19b>
      }
    } else if(state == '%'){
 713:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 717:	0f 85 27 01 00 00    	jne    844 <printf+0x19b>
      if(c == 'd'){
 71d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 721:	75 2d                	jne    750 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 723:	8b 45 e8             	mov    -0x18(%ebp),%eax
 726:	8b 00                	mov    (%eax),%eax
 728:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 72f:	00 
 730:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 737:	00 
 738:	89 44 24 04          	mov    %eax,0x4(%esp)
 73c:	8b 45 08             	mov    0x8(%ebp),%eax
 73f:	89 04 24             	mov    %eax,(%esp)
 742:	e8 ad fe ff ff       	call   5f4 <printint>
        ap++;
 747:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74b:	e9 ed 00 00 00       	jmp    83d <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 750:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 754:	74 06                	je     75c <printf+0xb3>
 756:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 75a:	75 2d                	jne    789 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 75c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75f:	8b 00                	mov    (%eax),%eax
 761:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 768:	00 
 769:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 770:	00 
 771:	89 44 24 04          	mov    %eax,0x4(%esp)
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	89 04 24             	mov    %eax,(%esp)
 77b:	e8 74 fe ff ff       	call   5f4 <printint>
        ap++;
 780:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 784:	e9 b4 00 00 00       	jmp    83d <printf+0x194>
      } else if(c == 's'){
 789:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 78d:	75 46                	jne    7d5 <printf+0x12c>
        s = (char*)*ap;
 78f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 792:	8b 00                	mov    (%eax),%eax
 794:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 797:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 79b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79f:	75 27                	jne    7c8 <printf+0x11f>
          s = "(null)";
 7a1:	c7 45 f4 c9 0a 00 00 	movl   $0xac9,-0xc(%ebp)
        while(*s != 0){
 7a8:	eb 1e                	jmp    7c8 <printf+0x11f>
          putc(fd, *s);
 7aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ad:	0f b6 00             	movzbl (%eax),%eax
 7b0:	0f be c0             	movsbl %al,%eax
 7b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ba:	89 04 24             	mov    %eax,(%esp)
 7bd:	e8 0a fe ff ff       	call   5cc <putc>
          s++;
 7c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7c6:	eb 01                	jmp    7c9 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7c8:	90                   	nop
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	0f b6 00             	movzbl (%eax),%eax
 7cf:	84 c0                	test   %al,%al
 7d1:	75 d7                	jne    7aa <printf+0x101>
 7d3:	eb 68                	jmp    83d <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7d9:	75 1d                	jne    7f8 <printf+0x14f>
        putc(fd, *ap);
 7db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7de:	8b 00                	mov    (%eax),%eax
 7e0:	0f be c0             	movsbl %al,%eax
 7e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ea:	89 04 24             	mov    %eax,(%esp)
 7ed:	e8 da fd ff ff       	call   5cc <putc>
        ap++;
 7f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f6:	eb 45                	jmp    83d <printf+0x194>
      } else if(c == '%'){
 7f8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7fc:	75 17                	jne    815 <printf+0x16c>
        putc(fd, c);
 7fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 801:	0f be c0             	movsbl %al,%eax
 804:	89 44 24 04          	mov    %eax,0x4(%esp)
 808:	8b 45 08             	mov    0x8(%ebp),%eax
 80b:	89 04 24             	mov    %eax,(%esp)
 80e:	e8 b9 fd ff ff       	call   5cc <putc>
 813:	eb 28                	jmp    83d <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 815:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 81c:	00 
 81d:	8b 45 08             	mov    0x8(%ebp),%eax
 820:	89 04 24             	mov    %eax,(%esp)
 823:	e8 a4 fd ff ff       	call   5cc <putc>
        putc(fd, c);
 828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 82b:	0f be c0             	movsbl %al,%eax
 82e:	89 44 24 04          	mov    %eax,0x4(%esp)
 832:	8b 45 08             	mov    0x8(%ebp),%eax
 835:	89 04 24             	mov    %eax,(%esp)
 838:	e8 8f fd ff ff       	call   5cc <putc>
      }
      state = 0;
 83d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 844:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 848:	8b 55 0c             	mov    0xc(%ebp),%edx
 84b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84e:	01 d0                	add    %edx,%eax
 850:	0f b6 00             	movzbl (%eax),%eax
 853:	84 c0                	test   %al,%al
 855:	0f 85 70 fe ff ff    	jne    6cb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 85b:	c9                   	leave  
 85c:	c3                   	ret    
 85d:	66 90                	xchg   %ax,%ax
 85f:	90                   	nop

00000860 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 860:	55                   	push   %ebp
 861:	89 e5                	mov    %esp,%ebp
 863:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 866:	8b 45 08             	mov    0x8(%ebp),%eax
 869:	83 e8 08             	sub    $0x8,%eax
 86c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86f:	a1 b0 0d 00 00       	mov    0xdb0,%eax
 874:	89 45 fc             	mov    %eax,-0x4(%ebp)
 877:	eb 24                	jmp    89d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 00                	mov    (%eax),%eax
 87e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 881:	77 12                	ja     895 <free+0x35>
 883:	8b 45 f8             	mov    -0x8(%ebp),%eax
 886:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 889:	77 24                	ja     8af <free+0x4f>
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 00                	mov    (%eax),%eax
 890:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 893:	77 1a                	ja     8af <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 895:	8b 45 fc             	mov    -0x4(%ebp),%eax
 898:	8b 00                	mov    (%eax),%eax
 89a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 89d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a3:	76 d4                	jbe    879 <free+0x19>
 8a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a8:	8b 00                	mov    (%eax),%eax
 8aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8ad:	76 ca                	jbe    879 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b2:	8b 40 04             	mov    0x4(%eax),%eax
 8b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bf:	01 c2                	add    %eax,%edx
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	39 c2                	cmp    %eax,%edx
 8c8:	75 24                	jne    8ee <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cd:	8b 50 04             	mov    0x4(%eax),%edx
 8d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d3:	8b 00                	mov    (%eax),%eax
 8d5:	8b 40 04             	mov    0x4(%eax),%eax
 8d8:	01 c2                	add    %eax,%edx
 8da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	8b 10                	mov    (%eax),%edx
 8e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ea:	89 10                	mov    %edx,(%eax)
 8ec:	eb 0a                	jmp    8f8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f1:	8b 10                	mov    (%eax),%edx
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fb:	8b 40 04             	mov    0x4(%eax),%eax
 8fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 905:	8b 45 fc             	mov    -0x4(%ebp),%eax
 908:	01 d0                	add    %edx,%eax
 90a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 90d:	75 20                	jne    92f <free+0xcf>
    p->s.size += bp->s.size;
 90f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 912:	8b 50 04             	mov    0x4(%eax),%edx
 915:	8b 45 f8             	mov    -0x8(%ebp),%eax
 918:	8b 40 04             	mov    0x4(%eax),%eax
 91b:	01 c2                	add    %eax,%edx
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	8b 10                	mov    (%eax),%edx
 928:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92b:	89 10                	mov    %edx,(%eax)
 92d:	eb 08                	jmp    937 <free+0xd7>
  } else
    p->s.ptr = bp;
 92f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 932:	8b 55 f8             	mov    -0x8(%ebp),%edx
 935:	89 10                	mov    %edx,(%eax)
  freep = p;
 937:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93a:	a3 b0 0d 00 00       	mov    %eax,0xdb0
}
 93f:	c9                   	leave  
 940:	c3                   	ret    

00000941 <morecore>:

static Header*
morecore(uint nu)
{
 941:	55                   	push   %ebp
 942:	89 e5                	mov    %esp,%ebp
 944:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 947:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 94e:	77 07                	ja     957 <morecore+0x16>
    nu = 4096;
 950:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 957:	8b 45 08             	mov    0x8(%ebp),%eax
 95a:	c1 e0 03             	shl    $0x3,%eax
 95d:	89 04 24             	mov    %eax,(%esp)
 960:	e8 4f fc ff ff       	call   5b4 <sbrk>
 965:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 968:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 96c:	75 07                	jne    975 <morecore+0x34>
    return 0;
 96e:	b8 00 00 00 00       	mov    $0x0,%eax
 973:	eb 22                	jmp    997 <morecore+0x56>
  hp = (Header*)p;
 975:	8b 45 f4             	mov    -0xc(%ebp),%eax
 978:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 97b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97e:	8b 55 08             	mov    0x8(%ebp),%edx
 981:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 984:	8b 45 f0             	mov    -0x10(%ebp),%eax
 987:	83 c0 08             	add    $0x8,%eax
 98a:	89 04 24             	mov    %eax,(%esp)
 98d:	e8 ce fe ff ff       	call   860 <free>
  return freep;
 992:	a1 b0 0d 00 00       	mov    0xdb0,%eax
}
 997:	c9                   	leave  
 998:	c3                   	ret    

00000999 <malloc>:

void*
malloc(uint nbytes)
{
 999:	55                   	push   %ebp
 99a:	89 e5                	mov    %esp,%ebp
 99c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99f:	8b 45 08             	mov    0x8(%ebp),%eax
 9a2:	83 c0 07             	add    $0x7,%eax
 9a5:	c1 e8 03             	shr    $0x3,%eax
 9a8:	83 c0 01             	add    $0x1,%eax
 9ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9ae:	a1 b0 0d 00 00       	mov    0xdb0,%eax
 9b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9ba:	75 23                	jne    9df <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9bc:	c7 45 f0 a8 0d 00 00 	movl   $0xda8,-0x10(%ebp)
 9c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c6:	a3 b0 0d 00 00       	mov    %eax,0xdb0
 9cb:	a1 b0 0d 00 00       	mov    0xdb0,%eax
 9d0:	a3 a8 0d 00 00       	mov    %eax,0xda8
    base.s.size = 0;
 9d5:	c7 05 ac 0d 00 00 00 	movl   $0x0,0xdac
 9dc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e2:	8b 00                	mov    (%eax),%eax
 9e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ea:	8b 40 04             	mov    0x4(%eax),%eax
 9ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9f0:	72 4d                	jb     a3f <malloc+0xa6>
      if(p->s.size == nunits)
 9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f5:	8b 40 04             	mov    0x4(%eax),%eax
 9f8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9fb:	75 0c                	jne    a09 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a00:	8b 10                	mov    (%eax),%edx
 a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a05:	89 10                	mov    %edx,(%eax)
 a07:	eb 26                	jmp    a2f <malloc+0x96>
      else {
        p->s.size -= nunits;
 a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0c:	8b 40 04             	mov    0x4(%eax),%eax
 a0f:	89 c2                	mov    %eax,%edx
 a11:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a17:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1d:	8b 40 04             	mov    0x4(%eax),%eax
 a20:	c1 e0 03             	shl    $0x3,%eax
 a23:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a29:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a2c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a32:	a3 b0 0d 00 00       	mov    %eax,0xdb0
      return (void*)(p + 1);
 a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3a:	83 c0 08             	add    $0x8,%eax
 a3d:	eb 38                	jmp    a77 <malloc+0xde>
    }
    if(p == freep)
 a3f:	a1 b0 0d 00 00       	mov    0xdb0,%eax
 a44:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a47:	75 1b                	jne    a64 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a4c:	89 04 24             	mov    %eax,(%esp)
 a4f:	e8 ed fe ff ff       	call   941 <morecore>
 a54:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a5b:	75 07                	jne    a64 <malloc+0xcb>
        return 0;
 a5d:	b8 00 00 00 00       	mov    $0x0,%eax
 a62:	eb 13                	jmp    a77 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a67:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6d:	8b 00                	mov    (%eax),%eax
 a6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a72:	e9 70 ff ff ff       	jmp    9e7 <malloc+0x4e>
}
 a77:	c9                   	leave  
 a78:	c3                   	ret    
