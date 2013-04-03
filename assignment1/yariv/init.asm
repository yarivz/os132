
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
  11:	c7 04 24 56 0a 00 00 	movl   $0xa56,(%esp)
  18:	e8 3b 05 00 00       	call   558 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 56 0a 00 00 	movl   $0xa56,(%esp)
  38:	e8 23 05 00 00       	call   560 <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 56 0a 00 00 	movl   $0xa56,(%esp)
  4c:	e8 07 05 00 00       	call   558 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 33 05 00 00       	call   590 <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 27 05 00 00       	call   590 <dup>
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
  6c:	c7 44 24 04 5e 0a 00 	movl   $0xa5e,0x4(%esp)
  73:	00 
  74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7b:	e8 0f 06 00 00       	call   68f <printf>
    pid = fork();
  80:	e8 83 04 00 00       	call   508 <fork>
  85:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  89:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8e:	79 19                	jns    a9 <main+0xa9>
      printf(1, "init: fork failed\n");
  90:	c7 44 24 04 71 0a 00 	movl   $0xa71,0x4(%esp)
  97:	00 
  98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9f:	e8 eb 05 00 00       	call   68f <printf>
      exit();
  a4:	e8 67 04 00 00       	call   510 <exit>
    }
    if(pid == 0){
  a9:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  ae:	75 41                	jne    f1 <main+0xf1>
      exec("sh", argv);
  b0:	c7 44 24 04 68 0d 00 	movl   $0xd68,0x4(%esp)
  b7:	00 
  b8:	c7 04 24 53 0a 00 00 	movl   $0xa53,(%esp)
  bf:	e8 8c 04 00 00       	call   550 <exec>
      printf(1, "init: exec sh failed\n");
  c4:	c7 44 24 04 84 0a 00 	movl   $0xa84,0x4(%esp)
  cb:	00 
  cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d3:	e8 b7 05 00 00       	call   68f <printf>
      exit();
  d8:	e8 33 04 00 00       	call   510 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  dd:	c7 44 24 04 9a 0a 00 	movl   $0xa9a,0x4(%esp)
  e4:	00 
  e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ec:	e8 9e 05 00 00       	call   68f <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f1:	e8 22 04 00 00       	call   518 <wait>
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
 1c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1c4:	03 45 08             	add    0x8(%ebp),%eax
 1c7:	0f b6 00             	movzbl (%eax),%eax
 1ca:	84 c0                	test   %al,%al
 1cc:	75 ef                	jne    1bd <strlen+0xf>
  return n;
 1ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d1:	c9                   	leave  
 1d2:	c3                   	ret    

000001d3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d9:	8b 45 10             	mov    0x10(%ebp),%eax
 1dc:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	89 04 24             	mov    %eax,(%esp)
 1ed:	e8 22 ff ff ff       	call   114 <stosb>
  return dst;
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f5:	c9                   	leave  
 1f6:	c3                   	ret    

000001f7 <strchr>:

char*
strchr(const char *s, char c)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 04             	sub    $0x4,%esp
 1fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 200:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 203:	eb 14                	jmp    219 <strchr+0x22>
    if(*s == c)
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	0f b6 00             	movzbl (%eax),%eax
 20b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 20e:	75 05                	jne    215 <strchr+0x1e>
      return (char*)s;
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	eb 13                	jmp    228 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 215:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	0f b6 00             	movzbl (%eax),%eax
 21f:	84 c0                	test   %al,%al
 221:	75 e2                	jne    205 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 223:	b8 00 00 00 00       	mov    $0x0,%eax
}
 228:	c9                   	leave  
 229:	c3                   	ret    

0000022a <gets>:

char*
gets(char *buf, int max)
{
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
 22d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 230:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 237:	eb 44                	jmp    27d <gets+0x53>
    cc = read(0, &c, 1);
 239:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 240:	00 
 241:	8d 45 ef             	lea    -0x11(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 24f:	e8 dc 02 00 00       	call   530 <read>
 254:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 257:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 25b:	7e 2d                	jle    28a <gets+0x60>
      break;
    buf[i++] = c;
 25d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 260:	03 45 08             	add    0x8(%ebp),%eax
 263:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 267:	88 10                	mov    %dl,(%eax)
 269:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 26d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 271:	3c 0a                	cmp    $0xa,%al
 273:	74 16                	je     28b <gets+0x61>
 275:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 279:	3c 0d                	cmp    $0xd,%al
 27b:	74 0e                	je     28b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 280:	83 c0 01             	add    $0x1,%eax
 283:	3b 45 0c             	cmp    0xc(%ebp),%eax
 286:	7c b1                	jl     239 <gets+0xf>
 288:	eb 01                	jmp    28b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 28a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 28b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28e:	03 45 08             	add    0x8(%ebp),%eax
 291:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 294:	8b 45 08             	mov    0x8(%ebp),%eax
}
 297:	c9                   	leave  
 298:	c3                   	ret    

00000299 <stat>:

int
stat(char *n, struct stat *st)
{
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a6:	00 
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	89 04 24             	mov    %eax,(%esp)
 2ad:	e8 a6 02 00 00       	call   558 <open>
 2b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b9:	79 07                	jns    2c2 <stat+0x29>
    return -1;
 2bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2c0:	eb 23                	jmp    2e5 <stat+0x4c>
  r = fstat(fd, st);
 2c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cc:	89 04 24             	mov    %eax,(%esp)
 2cf:	e8 9c 02 00 00       	call   570 <fstat>
 2d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2da:	89 04 24             	mov    %eax,(%esp)
 2dd:	e8 5e 02 00 00       	call   540 <close>
  return r;
 2e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e5:	c9                   	leave  
 2e6:	c3                   	ret    

000002e7 <atoi>:

int
atoi(const char *s)
{
 2e7:	55                   	push   %ebp
 2e8:	89 e5                	mov    %esp,%ebp
 2ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f4:	eb 23                	jmp    319 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f9:	89 d0                	mov    %edx,%eax
 2fb:	c1 e0 02             	shl    $0x2,%eax
 2fe:	01 d0                	add    %edx,%eax
 300:	01 c0                	add    %eax,%eax
 302:	89 c2                	mov    %eax,%edx
 304:	8b 45 08             	mov    0x8(%ebp),%eax
 307:	0f b6 00             	movzbl (%eax),%eax
 30a:	0f be c0             	movsbl %al,%eax
 30d:	01 d0                	add    %edx,%eax
 30f:	83 e8 30             	sub    $0x30,%eax
 312:	89 45 fc             	mov    %eax,-0x4(%ebp)
 315:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	3c 2f                	cmp    $0x2f,%al
 321:	7e 0a                	jle    32d <atoi+0x46>
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	3c 39                	cmp    $0x39,%al
 32b:	7e c9                	jle    2f6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33e:	8b 45 0c             	mov    0xc(%ebp),%eax
 341:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 344:	eb 13                	jmp    359 <memmove+0x27>
    *dst++ = *src++;
 346:	8b 45 f8             	mov    -0x8(%ebp),%eax
 349:	0f b6 10             	movzbl (%eax),%edx
 34c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 34f:	88 10                	mov    %dl,(%eax)
 351:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 355:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 359:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 35d:	0f 9f c0             	setg   %al
 360:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 364:	84 c0                	test   %al,%al
 366:	75 de                	jne    346 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 368:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36b:	c9                   	leave  
 36c:	c3                   	ret    

0000036d <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 36d:	55                   	push   %ebp
 36e:	89 e5                	mov    %esp,%ebp
 370:	83 ec 38             	sub    $0x38,%esp
 373:	8b 45 10             	mov    0x10(%ebp),%eax
 376:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 379:	8b 45 14             	mov    0x14(%ebp),%eax
 37c:	8b 00                	mov    (%eax),%eax
 37e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 381:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 388:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 38c:	74 06                	je     394 <strtok+0x27>
 38e:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 392:	75 54                	jne    3e8 <strtok+0x7b>
    return match;
 394:	8b 45 f0             	mov    -0x10(%ebp),%eax
 397:	eb 6e                	jmp    407 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 399:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39c:	03 45 0c             	add    0xc(%ebp),%eax
 39f:	0f b6 00             	movzbl (%eax),%eax
 3a2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3a5:	74 06                	je     3ad <strtok+0x40>
      {
	index++;
 3a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3ab:	eb 3c                	jmp    3e9 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 3ad:	8b 45 14             	mov    0x14(%ebp),%eax
 3b0:	8b 00                	mov    (%eax),%eax
 3b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3b5:	29 c2                	sub    %eax,%edx
 3b7:	8b 45 14             	mov    0x14(%ebp),%eax
 3ba:	8b 00                	mov    (%eax),%eax
 3bc:	03 45 0c             	add    0xc(%ebp),%eax
 3bf:	89 54 24 08          	mov    %edx,0x8(%esp)
 3c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ca:	89 04 24             	mov    %eax,(%esp)
 3cd:	e8 37 00 00 00       	call   409 <strncpy>
 3d2:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	0f b6 00             	movzbl (%eax),%eax
 3db:	84 c0                	test   %al,%al
 3dd:	74 19                	je     3f8 <strtok+0x8b>
	  match = 1;
 3df:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 3e6:	eb 10                	jmp    3f8 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 3e8:	90                   	nop
 3e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ec:	03 45 0c             	add    0xc(%ebp),%eax
 3ef:	0f b6 00             	movzbl (%eax),%eax
 3f2:	84 c0                	test   %al,%al
 3f4:	75 a3                	jne    399 <strtok+0x2c>
 3f6:	eb 01                	jmp    3f9 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 3f8:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 3f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fc:	8d 50 01             	lea    0x1(%eax),%edx
 3ff:	8b 45 14             	mov    0x14(%ebp),%eax
 402:	89 10                	mov    %edx,(%eax)
  return match;
 404:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 407:	c9                   	leave  
 408:	c3                   	ret    

00000409 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 409:	55                   	push   %ebp
 40a:	89 e5                	mov    %esp,%ebp
 40c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 40f:	8b 45 08             	mov    0x8(%ebp),%eax
 412:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 415:	90                   	nop
 416:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 41a:	0f 9f c0             	setg   %al
 41d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 421:	84 c0                	test   %al,%al
 423:	74 30                	je     455 <strncpy+0x4c>
 425:	8b 45 0c             	mov    0xc(%ebp),%eax
 428:	0f b6 10             	movzbl (%eax),%edx
 42b:	8b 45 08             	mov    0x8(%ebp),%eax
 42e:	88 10                	mov    %dl,(%eax)
 430:	8b 45 08             	mov    0x8(%ebp),%eax
 433:	0f b6 00             	movzbl (%eax),%eax
 436:	84 c0                	test   %al,%al
 438:	0f 95 c0             	setne  %al
 43b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 443:	84 c0                	test   %al,%al
 445:	75 cf                	jne    416 <strncpy+0xd>
    ;
  while(n-- > 0)
 447:	eb 0c                	jmp    455 <strncpy+0x4c>
    *s++ = 0;
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	c6 00 00             	movb   $0x0,(%eax)
 44f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 453:	eb 01                	jmp    456 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 455:	90                   	nop
 456:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 45a:	0f 9f c0             	setg   %al
 45d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 461:	84 c0                	test   %al,%al
 463:	75 e4                	jne    449 <strncpy+0x40>
    *s++ = 0;
  return os;
 465:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 468:	c9                   	leave  
 469:	c3                   	ret    

0000046a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 46a:	55                   	push   %ebp
 46b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 46d:	eb 0c                	jmp    47b <strncmp+0x11>
    n--, p++, q++;
 46f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 473:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 477:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 47b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 47f:	74 1a                	je     49b <strncmp+0x31>
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	0f b6 00             	movzbl (%eax),%eax
 487:	84 c0                	test   %al,%al
 489:	74 10                	je     49b <strncmp+0x31>
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	0f b6 10             	movzbl (%eax),%edx
 491:	8b 45 0c             	mov    0xc(%ebp),%eax
 494:	0f b6 00             	movzbl (%eax),%eax
 497:	38 c2                	cmp    %al,%dl
 499:	74 d4                	je     46f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 49b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 49f:	75 07                	jne    4a8 <strncmp+0x3e>
    return 0;
 4a1:	b8 00 00 00 00       	mov    $0x0,%eax
 4a6:	eb 18                	jmp    4c0 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4a8:	8b 45 08             	mov    0x8(%ebp),%eax
 4ab:	0f b6 00             	movzbl (%eax),%eax
 4ae:	0f b6 d0             	movzbl %al,%edx
 4b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b4:	0f b6 00             	movzbl (%eax),%eax
 4b7:	0f b6 c0             	movzbl %al,%eax
 4ba:	89 d1                	mov    %edx,%ecx
 4bc:	29 c1                	sub    %eax,%ecx
 4be:	89 c8                	mov    %ecx,%eax
}
 4c0:	5d                   	pop    %ebp
 4c1:	c3                   	ret    

000004c2 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 4c2:	55                   	push   %ebp
 4c3:	89 e5                	mov    %esp,%ebp
  while(*p){
 4c5:	eb 13                	jmp    4da <strcat+0x18>
    *dest++ = *p++;
 4c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ca:	0f b6 10             	movzbl (%eax),%edx
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	88 10                	mov    %dl,(%eax)
 4d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4d6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 4da:	8b 45 0c             	mov    0xc(%ebp),%eax
 4dd:	0f b6 00             	movzbl (%eax),%eax
 4e0:	84 c0                	test   %al,%al
 4e2:	75 e3                	jne    4c7 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 4e4:	eb 13                	jmp    4f9 <strcat+0x37>
    *dest++ = *q++;
 4e6:	8b 45 10             	mov    0x10(%ebp),%eax
 4e9:	0f b6 10             	movzbl (%eax),%edx
 4ec:	8b 45 08             	mov    0x8(%ebp),%eax
 4ef:	88 10                	mov    %dl,(%eax)
 4f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4f5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 4f9:	8b 45 10             	mov    0x10(%ebp),%eax
 4fc:	0f b6 00             	movzbl (%eax),%eax
 4ff:	84 c0                	test   %al,%al
 501:	75 e3                	jne    4e6 <strcat+0x24>
    *dest++ = *q++;
  }  
 503:	5d                   	pop    %ebp
 504:	c3                   	ret    
 505:	90                   	nop
 506:	90                   	nop
 507:	90                   	nop

00000508 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 508:	b8 01 00 00 00       	mov    $0x1,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <exit>:
SYSCALL(exit)
 510:	b8 02 00 00 00       	mov    $0x2,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <wait>:
SYSCALL(wait)
 518:	b8 03 00 00 00       	mov    $0x3,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <wait2>:
SYSCALL(wait2)
 520:	b8 16 00 00 00       	mov    $0x16,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <pipe>:
SYSCALL(pipe)
 528:	b8 04 00 00 00       	mov    $0x4,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <read>:
SYSCALL(read)
 530:	b8 05 00 00 00       	mov    $0x5,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <write>:
SYSCALL(write)
 538:	b8 10 00 00 00       	mov    $0x10,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <close>:
SYSCALL(close)
 540:	b8 15 00 00 00       	mov    $0x15,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <kill>:
SYSCALL(kill)
 548:	b8 06 00 00 00       	mov    $0x6,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <exec>:
SYSCALL(exec)
 550:	b8 07 00 00 00       	mov    $0x7,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <open>:
SYSCALL(open)
 558:	b8 0f 00 00 00       	mov    $0xf,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <mknod>:
SYSCALL(mknod)
 560:	b8 11 00 00 00       	mov    $0x11,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <unlink>:
SYSCALL(unlink)
 568:	b8 12 00 00 00       	mov    $0x12,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <fstat>:
SYSCALL(fstat)
 570:	b8 08 00 00 00       	mov    $0x8,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <link>:
SYSCALL(link)
 578:	b8 13 00 00 00       	mov    $0x13,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <mkdir>:
SYSCALL(mkdir)
 580:	b8 14 00 00 00       	mov    $0x14,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <chdir>:
SYSCALL(chdir)
 588:	b8 09 00 00 00       	mov    $0x9,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <dup>:
SYSCALL(dup)
 590:	b8 0a 00 00 00       	mov    $0xa,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <getpid>:
SYSCALL(getpid)
 598:	b8 0b 00 00 00       	mov    $0xb,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <sbrk>:
SYSCALL(sbrk)
 5a0:	b8 0c 00 00 00       	mov    $0xc,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <sleep>:
SYSCALL(sleep)
 5a8:	b8 0d 00 00 00       	mov    $0xd,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <uptime>:
SYSCALL(uptime)
 5b0:	b8 0e 00 00 00       	mov    $0xe,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5b8:	55                   	push   %ebp
 5b9:	89 e5                	mov    %esp,%ebp
 5bb:	83 ec 28             	sub    $0x28,%esp
 5be:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5cb:	00 
 5cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
 5d6:	89 04 24             	mov    %eax,(%esp)
 5d9:	e8 5a ff ff ff       	call   538 <write>
}
 5de:	c9                   	leave  
 5df:	c3                   	ret    

000005e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5ed:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5f1:	74 17                	je     60a <printint+0x2a>
 5f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5f7:	79 11                	jns    60a <printint+0x2a>
    neg = 1;
 5f9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 600:	8b 45 0c             	mov    0xc(%ebp),%eax
 603:	f7 d8                	neg    %eax
 605:	89 45 ec             	mov    %eax,-0x14(%ebp)
 608:	eb 06                	jmp    610 <printint+0x30>
  } else {
    x = xx;
 60a:	8b 45 0c             	mov    0xc(%ebp),%eax
 60d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 610:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 617:	8b 4d 10             	mov    0x10(%ebp),%ecx
 61a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 61d:	ba 00 00 00 00       	mov    $0x0,%edx
 622:	f7 f1                	div    %ecx
 624:	89 d0                	mov    %edx,%eax
 626:	0f b6 90 70 0d 00 00 	movzbl 0xd70(%eax),%edx
 62d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 630:	03 45 f4             	add    -0xc(%ebp),%eax
 633:	88 10                	mov    %dl,(%eax)
 635:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 639:	8b 55 10             	mov    0x10(%ebp),%edx
 63c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 63f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 642:	ba 00 00 00 00       	mov    $0x0,%edx
 647:	f7 75 d4             	divl   -0x2c(%ebp)
 64a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 64d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 651:	75 c4                	jne    617 <printint+0x37>
  if(neg)
 653:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 657:	74 2a                	je     683 <printint+0xa3>
    buf[i++] = '-';
 659:	8d 45 dc             	lea    -0x24(%ebp),%eax
 65c:	03 45 f4             	add    -0xc(%ebp),%eax
 65f:	c6 00 2d             	movb   $0x2d,(%eax)
 662:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 666:	eb 1b                	jmp    683 <printint+0xa3>
    putc(fd, buf[i]);
 668:	8d 45 dc             	lea    -0x24(%ebp),%eax
 66b:	03 45 f4             	add    -0xc(%ebp),%eax
 66e:	0f b6 00             	movzbl (%eax),%eax
 671:	0f be c0             	movsbl %al,%eax
 674:	89 44 24 04          	mov    %eax,0x4(%esp)
 678:	8b 45 08             	mov    0x8(%ebp),%eax
 67b:	89 04 24             	mov    %eax,(%esp)
 67e:	e8 35 ff ff ff       	call   5b8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 683:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 687:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 68b:	79 db                	jns    668 <printint+0x88>
    putc(fd, buf[i]);
}
 68d:	c9                   	leave  
 68e:	c3                   	ret    

0000068f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 68f:	55                   	push   %ebp
 690:	89 e5                	mov    %esp,%ebp
 692:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 695:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 69c:	8d 45 0c             	lea    0xc(%ebp),%eax
 69f:	83 c0 04             	add    $0x4,%eax
 6a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ac:	e9 7d 01 00 00       	jmp    82e <printf+0x19f>
    c = fmt[i] & 0xff;
 6b1:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b7:	01 d0                	add    %edx,%eax
 6b9:	0f b6 00             	movzbl (%eax),%eax
 6bc:	0f be c0             	movsbl %al,%eax
 6bf:	25 ff 00 00 00       	and    $0xff,%eax
 6c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6cb:	75 2c                	jne    6f9 <printf+0x6a>
      if(c == '%'){
 6cd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d1:	75 0c                	jne    6df <printf+0x50>
        state = '%';
 6d3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6da:	e9 4b 01 00 00       	jmp    82a <printf+0x19b>
      } else {
        putc(fd, c);
 6df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e2:	0f be c0             	movsbl %al,%eax
 6e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e9:	8b 45 08             	mov    0x8(%ebp),%eax
 6ec:	89 04 24             	mov    %eax,(%esp)
 6ef:	e8 c4 fe ff ff       	call   5b8 <putc>
 6f4:	e9 31 01 00 00       	jmp    82a <printf+0x19b>
      }
    } else if(state == '%'){
 6f9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6fd:	0f 85 27 01 00 00    	jne    82a <printf+0x19b>
      if(c == 'd'){
 703:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 707:	75 2d                	jne    736 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 709:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70c:	8b 00                	mov    (%eax),%eax
 70e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 715:	00 
 716:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 71d:	00 
 71e:	89 44 24 04          	mov    %eax,0x4(%esp)
 722:	8b 45 08             	mov    0x8(%ebp),%eax
 725:	89 04 24             	mov    %eax,(%esp)
 728:	e8 b3 fe ff ff       	call   5e0 <printint>
        ap++;
 72d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 731:	e9 ed 00 00 00       	jmp    823 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 736:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 73a:	74 06                	je     742 <printf+0xb3>
 73c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 740:	75 2d                	jne    76f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 742:	8b 45 e8             	mov    -0x18(%ebp),%eax
 745:	8b 00                	mov    (%eax),%eax
 747:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 74e:	00 
 74f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 756:	00 
 757:	89 44 24 04          	mov    %eax,0x4(%esp)
 75b:	8b 45 08             	mov    0x8(%ebp),%eax
 75e:	89 04 24             	mov    %eax,(%esp)
 761:	e8 7a fe ff ff       	call   5e0 <printint>
        ap++;
 766:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76a:	e9 b4 00 00 00       	jmp    823 <printf+0x194>
      } else if(c == 's'){
 76f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 773:	75 46                	jne    7bb <printf+0x12c>
        s = (char*)*ap;
 775:	8b 45 e8             	mov    -0x18(%ebp),%eax
 778:	8b 00                	mov    (%eax),%eax
 77a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 77d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 781:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 785:	75 27                	jne    7ae <printf+0x11f>
          s = "(null)";
 787:	c7 45 f4 a3 0a 00 00 	movl   $0xaa3,-0xc(%ebp)
        while(*s != 0){
 78e:	eb 1e                	jmp    7ae <printf+0x11f>
          putc(fd, *s);
 790:	8b 45 f4             	mov    -0xc(%ebp),%eax
 793:	0f b6 00             	movzbl (%eax),%eax
 796:	0f be c0             	movsbl %al,%eax
 799:	89 44 24 04          	mov    %eax,0x4(%esp)
 79d:	8b 45 08             	mov    0x8(%ebp),%eax
 7a0:	89 04 24             	mov    %eax,(%esp)
 7a3:	e8 10 fe ff ff       	call   5b8 <putc>
          s++;
 7a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7ac:	eb 01                	jmp    7af <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7ae:	90                   	nop
 7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b2:	0f b6 00             	movzbl (%eax),%eax
 7b5:	84 c0                	test   %al,%al
 7b7:	75 d7                	jne    790 <printf+0x101>
 7b9:	eb 68                	jmp    823 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7bb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7bf:	75 1d                	jne    7de <printf+0x14f>
        putc(fd, *ap);
 7c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c4:	8b 00                	mov    (%eax),%eax
 7c6:	0f be c0             	movsbl %al,%eax
 7c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7cd:	8b 45 08             	mov    0x8(%ebp),%eax
 7d0:	89 04 24             	mov    %eax,(%esp)
 7d3:	e8 e0 fd ff ff       	call   5b8 <putc>
        ap++;
 7d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7dc:	eb 45                	jmp    823 <printf+0x194>
      } else if(c == '%'){
 7de:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e2:	75 17                	jne    7fb <printf+0x16c>
        putc(fd, c);
 7e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7e7:	0f be c0             	movsbl %al,%eax
 7ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ee:	8b 45 08             	mov    0x8(%ebp),%eax
 7f1:	89 04 24             	mov    %eax,(%esp)
 7f4:	e8 bf fd ff ff       	call   5b8 <putc>
 7f9:	eb 28                	jmp    823 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7fb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 802:	00 
 803:	8b 45 08             	mov    0x8(%ebp),%eax
 806:	89 04 24             	mov    %eax,(%esp)
 809:	e8 aa fd ff ff       	call   5b8 <putc>
        putc(fd, c);
 80e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 811:	0f be c0             	movsbl %al,%eax
 814:	89 44 24 04          	mov    %eax,0x4(%esp)
 818:	8b 45 08             	mov    0x8(%ebp),%eax
 81b:	89 04 24             	mov    %eax,(%esp)
 81e:	e8 95 fd ff ff       	call   5b8 <putc>
      }
      state = 0;
 823:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 82a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 82e:	8b 55 0c             	mov    0xc(%ebp),%edx
 831:	8b 45 f0             	mov    -0x10(%ebp),%eax
 834:	01 d0                	add    %edx,%eax
 836:	0f b6 00             	movzbl (%eax),%eax
 839:	84 c0                	test   %al,%al
 83b:	0f 85 70 fe ff ff    	jne    6b1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 841:	c9                   	leave  
 842:	c3                   	ret    
 843:	90                   	nop

00000844 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 844:	55                   	push   %ebp
 845:	89 e5                	mov    %esp,%ebp
 847:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84a:	8b 45 08             	mov    0x8(%ebp),%eax
 84d:	83 e8 08             	sub    $0x8,%eax
 850:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 853:	a1 8c 0d 00 00       	mov    0xd8c,%eax
 858:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85b:	eb 24                	jmp    881 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 860:	8b 00                	mov    (%eax),%eax
 862:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 865:	77 12                	ja     879 <free+0x35>
 867:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86d:	77 24                	ja     893 <free+0x4f>
 86f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 872:	8b 00                	mov    (%eax),%eax
 874:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 877:	77 1a                	ja     893 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 00                	mov    (%eax),%eax
 87e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 881:	8b 45 f8             	mov    -0x8(%ebp),%eax
 884:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 887:	76 d4                	jbe    85d <free+0x19>
 889:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88c:	8b 00                	mov    (%eax),%eax
 88e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 891:	76 ca                	jbe    85d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 893:	8b 45 f8             	mov    -0x8(%ebp),%eax
 896:	8b 40 04             	mov    0x4(%eax),%eax
 899:	c1 e0 03             	shl    $0x3,%eax
 89c:	89 c2                	mov    %eax,%edx
 89e:	03 55 f8             	add    -0x8(%ebp),%edx
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	8b 00                	mov    (%eax),%eax
 8a6:	39 c2                	cmp    %eax,%edx
 8a8:	75 24                	jne    8ce <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ad:	8b 50 04             	mov    0x4(%eax),%edx
 8b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b3:	8b 00                	mov    (%eax),%eax
 8b5:	8b 40 04             	mov    0x4(%eax),%eax
 8b8:	01 c2                	add    %eax,%edx
 8ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c3:	8b 00                	mov    (%eax),%eax
 8c5:	8b 10                	mov    (%eax),%edx
 8c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ca:	89 10                	mov    %edx,(%eax)
 8cc:	eb 0a                	jmp    8d8 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d1:	8b 10                	mov    (%eax),%edx
 8d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8db:	8b 40 04             	mov    0x4(%eax),%eax
 8de:	c1 e0 03             	shl    $0x3,%eax
 8e1:	03 45 fc             	add    -0x4(%ebp),%eax
 8e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e7:	75 20                	jne    909 <free+0xc5>
    p->s.size += bp->s.size;
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	8b 50 04             	mov    0x4(%eax),%edx
 8ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f2:	8b 40 04             	mov    0x4(%eax),%eax
 8f5:	01 c2                	add    %eax,%edx
 8f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fa:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 900:	8b 10                	mov    (%eax),%edx
 902:	8b 45 fc             	mov    -0x4(%ebp),%eax
 905:	89 10                	mov    %edx,(%eax)
 907:	eb 08                	jmp    911 <free+0xcd>
  } else
    p->s.ptr = bp;
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 90f:	89 10                	mov    %edx,(%eax)
  freep = p;
 911:	8b 45 fc             	mov    -0x4(%ebp),%eax
 914:	a3 8c 0d 00 00       	mov    %eax,0xd8c
}
 919:	c9                   	leave  
 91a:	c3                   	ret    

0000091b <morecore>:

static Header*
morecore(uint nu)
{
 91b:	55                   	push   %ebp
 91c:	89 e5                	mov    %esp,%ebp
 91e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 921:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 928:	77 07                	ja     931 <morecore+0x16>
    nu = 4096;
 92a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 931:	8b 45 08             	mov    0x8(%ebp),%eax
 934:	c1 e0 03             	shl    $0x3,%eax
 937:	89 04 24             	mov    %eax,(%esp)
 93a:	e8 61 fc ff ff       	call   5a0 <sbrk>
 93f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 942:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 946:	75 07                	jne    94f <morecore+0x34>
    return 0;
 948:	b8 00 00 00 00       	mov    $0x0,%eax
 94d:	eb 22                	jmp    971 <morecore+0x56>
  hp = (Header*)p;
 94f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 955:	8b 45 f0             	mov    -0x10(%ebp),%eax
 958:	8b 55 08             	mov    0x8(%ebp),%edx
 95b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 95e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 961:	83 c0 08             	add    $0x8,%eax
 964:	89 04 24             	mov    %eax,(%esp)
 967:	e8 d8 fe ff ff       	call   844 <free>
  return freep;
 96c:	a1 8c 0d 00 00       	mov    0xd8c,%eax
}
 971:	c9                   	leave  
 972:	c3                   	ret    

00000973 <malloc>:

void*
malloc(uint nbytes)
{
 973:	55                   	push   %ebp
 974:	89 e5                	mov    %esp,%ebp
 976:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 979:	8b 45 08             	mov    0x8(%ebp),%eax
 97c:	83 c0 07             	add    $0x7,%eax
 97f:	c1 e8 03             	shr    $0x3,%eax
 982:	83 c0 01             	add    $0x1,%eax
 985:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 988:	a1 8c 0d 00 00       	mov    0xd8c,%eax
 98d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 990:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 994:	75 23                	jne    9b9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 996:	c7 45 f0 84 0d 00 00 	movl   $0xd84,-0x10(%ebp)
 99d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a0:	a3 8c 0d 00 00       	mov    %eax,0xd8c
 9a5:	a1 8c 0d 00 00       	mov    0xd8c,%eax
 9aa:	a3 84 0d 00 00       	mov    %eax,0xd84
    base.s.size = 0;
 9af:	c7 05 88 0d 00 00 00 	movl   $0x0,0xd88
 9b6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bc:	8b 00                	mov    (%eax),%eax
 9be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c4:	8b 40 04             	mov    0x4(%eax),%eax
 9c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ca:	72 4d                	jb     a19 <malloc+0xa6>
      if(p->s.size == nunits)
 9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cf:	8b 40 04             	mov    0x4(%eax),%eax
 9d2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9d5:	75 0c                	jne    9e3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9da:	8b 10                	mov    (%eax),%edx
 9dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9df:	89 10                	mov    %edx,(%eax)
 9e1:	eb 26                	jmp    a09 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e6:	8b 40 04             	mov    0x4(%eax),%eax
 9e9:	89 c2                	mov    %eax,%edx
 9eb:	2b 55 ec             	sub    -0x14(%ebp),%edx
 9ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f7:	8b 40 04             	mov    0x4(%eax),%eax
 9fa:	c1 e0 03             	shl    $0x3,%eax
 9fd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a03:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a06:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0c:	a3 8c 0d 00 00       	mov    %eax,0xd8c
      return (void*)(p + 1);
 a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a14:	83 c0 08             	add    $0x8,%eax
 a17:	eb 38                	jmp    a51 <malloc+0xde>
    }
    if(p == freep)
 a19:	a1 8c 0d 00 00       	mov    0xd8c,%eax
 a1e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a21:	75 1b                	jne    a3e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a23:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a26:	89 04 24             	mov    %eax,(%esp)
 a29:	e8 ed fe ff ff       	call   91b <morecore>
 a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a35:	75 07                	jne    a3e <malloc+0xcb>
        return 0;
 a37:	b8 00 00 00 00       	mov    $0x0,%eax
 a3c:	eb 13                	jmp    a51 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a47:	8b 00                	mov    (%eax),%eax
 a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a4c:	e9 70 ff ff ff       	jmp    9c1 <malloc+0x4e>
}
 a51:	c9                   	leave  
 a52:	c3                   	ret    