
_RRsanity:     file format elf32-i386


Disassembly of section .text:

00000000 <foo>:
}
*/

void
foo()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int i;
  int pid = getpid();
   6:	e8 e9 05 00 00       	call   5f4 <getpid>
   b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (i=0;i<1000;i++)
   e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  15:	eb 29                	jmp    40 <foo+0x40>
     printf(2, "child %d prints for the %d time\n",pid,i+1);
  17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1a:	83 c0 01             	add    $0x1,%eax
  1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  24:	89 44 24 08          	mov    %eax,0x8(%esp)
  28:	c7 44 24 04 c4 0a 00 	movl   $0xac4,0x4(%esp)
  2f:	00 
  30:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  37:	e8 b5 06 00 00       	call   6f1 <printf>
void
foo()
{
  int i;
  int pid = getpid();
  for (i=0;i<1000;i++)
  3c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  40:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
  47:	7e ce                	jle    17 <foo+0x17>
     printf(2, "child %d prints for the %d time\n",pid,i+1);
}
  49:	c9                   	leave  
  4a:	c3                   	ret    

0000004b <RRsanity>:

void
RRsanity(void)
{
  4b:	55                   	push   %ebp
  4c:	89 e5                	mov    %esp,%ebp
  4e:	53                   	push   %ebx
  4f:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  int wTime [10];
  int rTime [10];
  int pid [10];
  printf(1, "RRsanity test\n");
  55:	c7 44 24 04 e5 0a 00 	movl   $0xae5,0x4(%esp)
  5c:	00 
  5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  64:	e8 88 06 00 00       	call   6f1 <printf>

  int i=0;
  69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;i<10;i++)
  70:	eb 2b                	jmp    9d <RRsanity+0x52>
  {  
    pid[i] = fork();
  72:	e8 e5 04 00 00       	call   55c <fork>
  77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  7a:	89 84 95 7c ff ff ff 	mov    %eax,-0x84(%ebp,%edx,4)
    if(pid[i] == 0)
  81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  84:	8b 84 85 7c ff ff ff 	mov    -0x84(%ebp,%eax,4),%eax
  8b:	85 c0                	test   %eax,%eax
  8d:	75 0a                	jne    99 <RRsanity+0x4e>
    {
      foo();
  8f:	e8 6c ff ff ff       	call   0 <foo>
      exit();      
  94:	e8 cb 04 00 00       	call   564 <exit>
  int rTime [10];
  int pid [10];
  printf(1, "RRsanity test\n");

  int i=0;
  for(;i<10;i++)
  99:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  9d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  a1:	7e cf                	jle    72 <RRsanity+0x27>
      foo();
      exit();      
    }
  }
  
  for(i=0;i<10;i++)
  a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  aa:	eb 30                	jmp    dc <RRsanity+0x91>
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  ac:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  b2:	c1 e2 02             	shl    $0x2,%edx
  b5:	01 c2                	add    %eax,%edx
  b7:	8d 45 cc             	lea    -0x34(%ebp),%eax
  ba:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  bd:	c1 e1 02             	shl    $0x2,%ecx
  c0:	01 c8                	add    %ecx,%eax
  c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  c6:	89 04 24             	mov    %eax,(%esp)
  c9:	e8 a6 04 00 00       	call   574 <wait2>
  ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  d1:	89 84 95 7c ff ff ff 	mov    %eax,-0x84(%ebp,%edx,4)
      foo();
      exit();      
    }
  }
  
  for(i=0;i<10;i++)
  d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  dc:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  e0:	7e ca                	jle    ac <RRsanity+0x61>
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  
  for(i=0;i<10;i++)
  e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  e9:	eb 51                	jmp    13c <RRsanity+0xf1>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",pid[i],wTime[i],rTime[i],wTime[i]+rTime[i]);
  eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ee:	8b 54 85 cc          	mov    -0x34(%ebp,%eax,4),%edx
  f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f5:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
  f9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
  fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ff:	8b 4c 85 a4          	mov    -0x5c(%ebp,%eax,4),%ecx
 103:	8b 45 f4             	mov    -0xc(%ebp),%eax
 106:	8b 54 85 cc          	mov    -0x34(%ebp,%eax,4),%edx
 10a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 10d:	8b 84 85 7c ff ff ff 	mov    -0x84(%ebp,%eax,4),%eax
 114:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 118:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 11c:	89 54 24 0c          	mov    %edx,0xc(%esp)
 120:	89 44 24 08          	mov    %eax,0x8(%esp)
 124:	c7 44 24 04 f4 0a 00 	movl   $0xaf4,0x4(%esp)
 12b:	00 
 12c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 133:	e8 b9 05 00 00       	call   6f1 <printf>
  }
  
  for(i=0;i<10;i++)
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  
  for(i=0;i<10;i++)
 138:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 13c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 140:	7e a9                	jle    eb <RRsanity+0xa0>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",pid[i],wTime[i],rTime[i],wTime[i]+rTime[i]);

}
 142:	81 c4 a4 00 00 00    	add    $0xa4,%esp
 148:	5b                   	pop    %ebx
 149:	5d                   	pop    %ebp
 14a:	c3                   	ret    

0000014b <main>:
int
main(void)
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	83 e4 f0             	and    $0xfffffff0,%esp
  RRsanity();
 151:	e8 f5 fe ff ff       	call   4b <RRsanity>
  exit();
 156:	e8 09 04 00 00       	call   564 <exit>
 15b:	90                   	nop

0000015c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 15c:	55                   	push   %ebp
 15d:	89 e5                	mov    %esp,%ebp
 15f:	57                   	push   %edi
 160:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 161:	8b 4d 08             	mov    0x8(%ebp),%ecx
 164:	8b 55 10             	mov    0x10(%ebp),%edx
 167:	8b 45 0c             	mov    0xc(%ebp),%eax
 16a:	89 cb                	mov    %ecx,%ebx
 16c:	89 df                	mov    %ebx,%edi
 16e:	89 d1                	mov    %edx,%ecx
 170:	fc                   	cld    
 171:	f3 aa                	rep stos %al,%es:(%edi)
 173:	89 ca                	mov    %ecx,%edx
 175:	89 fb                	mov    %edi,%ebx
 177:	89 5d 08             	mov    %ebx,0x8(%ebp)
 17a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 17d:	5b                   	pop    %ebx
 17e:	5f                   	pop    %edi
 17f:	5d                   	pop    %ebp
 180:	c3                   	ret    

00000181 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 181:	55                   	push   %ebp
 182:	89 e5                	mov    %esp,%ebp
 184:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 187:	8b 45 08             	mov    0x8(%ebp),%eax
 18a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 18d:	90                   	nop
 18e:	8b 45 0c             	mov    0xc(%ebp),%eax
 191:	0f b6 10             	movzbl (%eax),%edx
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	88 10                	mov    %dl,(%eax)
 199:	8b 45 08             	mov    0x8(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	84 c0                	test   %al,%al
 1a1:	0f 95 c0             	setne  %al
 1a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 1ac:	84 c0                	test   %al,%al
 1ae:	75 de                	jne    18e <strcpy+0xd>
    ;
  return os;
 1b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1b3:	c9                   	leave  
 1b4:	c3                   	ret    

000001b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b5:	55                   	push   %ebp
 1b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1b8:	eb 08                	jmp    1c2 <strcmp+0xd>
    p++, q++;
 1ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1c2:	8b 45 08             	mov    0x8(%ebp),%eax
 1c5:	0f b6 00             	movzbl (%eax),%eax
 1c8:	84 c0                	test   %al,%al
 1ca:	74 10                	je     1dc <strcmp+0x27>
 1cc:	8b 45 08             	mov    0x8(%ebp),%eax
 1cf:	0f b6 10             	movzbl (%eax),%edx
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	0f b6 00             	movzbl (%eax),%eax
 1d8:	38 c2                	cmp    %al,%dl
 1da:	74 de                	je     1ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	0f b6 00             	movzbl (%eax),%eax
 1e2:	0f b6 d0             	movzbl %al,%edx
 1e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e8:	0f b6 00             	movzbl (%eax),%eax
 1eb:	0f b6 c0             	movzbl %al,%eax
 1ee:	89 d1                	mov    %edx,%ecx
 1f0:	29 c1                	sub    %eax,%ecx
 1f2:	89 c8                	mov    %ecx,%eax
}
 1f4:	5d                   	pop    %ebp
 1f5:	c3                   	ret    

000001f6 <strlen>:

uint
strlen(char *s)
{
 1f6:	55                   	push   %ebp
 1f7:	89 e5                	mov    %esp,%ebp
 1f9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 1fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 203:	eb 04                	jmp    209 <strlen+0x13>
 205:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 209:	8b 55 fc             	mov    -0x4(%ebp),%edx
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
 20f:	01 d0                	add    %edx,%eax
 211:	0f b6 00             	movzbl (%eax),%eax
 214:	84 c0                	test   %al,%al
 216:	75 ed                	jne    205 <strlen+0xf>
  return n;
 218:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <memset>:

void*
memset(void *dst, int c, uint n)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 223:	8b 45 10             	mov    0x10(%ebp),%eax
 226:	89 44 24 08          	mov    %eax,0x8(%esp)
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	89 44 24 04          	mov    %eax,0x4(%esp)
 231:	8b 45 08             	mov    0x8(%ebp),%eax
 234:	89 04 24             	mov    %eax,(%esp)
 237:	e8 20 ff ff ff       	call   15c <stosb>
  return dst;
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 23f:	c9                   	leave  
 240:	c3                   	ret    

00000241 <strchr>:

char*
strchr(const char *s, char c)
{
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
 244:	83 ec 04             	sub    $0x4,%esp
 247:	8b 45 0c             	mov    0xc(%ebp),%eax
 24a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 24d:	eb 14                	jmp    263 <strchr+0x22>
    if(*s == c)
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
 252:	0f b6 00             	movzbl (%eax),%eax
 255:	3a 45 fc             	cmp    -0x4(%ebp),%al
 258:	75 05                	jne    25f <strchr+0x1e>
      return (char*)s;
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	eb 13                	jmp    272 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 25f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 263:	8b 45 08             	mov    0x8(%ebp),%eax
 266:	0f b6 00             	movzbl (%eax),%eax
 269:	84 c0                	test   %al,%al
 26b:	75 e2                	jne    24f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 26d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 272:	c9                   	leave  
 273:	c3                   	ret    

00000274 <gets>:

char*
gets(char *buf, int max)
{
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
 277:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 281:	eb 46                	jmp    2c9 <gets+0x55>
    cc = read(0, &c, 1);
 283:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 28a:	00 
 28b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 28e:	89 44 24 04          	mov    %eax,0x4(%esp)
 292:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 299:	e8 ee 02 00 00       	call   58c <read>
 29e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2a5:	7e 2f                	jle    2d6 <gets+0x62>
      break;
    buf[i++] = c;
 2a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2aa:	8b 45 08             	mov    0x8(%ebp),%eax
 2ad:	01 c2                	add    %eax,%edx
 2af:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b3:	88 02                	mov    %al,(%edx)
 2b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 2b9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2bd:	3c 0a                	cmp    $0xa,%al
 2bf:	74 16                	je     2d7 <gets+0x63>
 2c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c5:	3c 0d                	cmp    $0xd,%al
 2c7:	74 0e                	je     2d7 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cc:	83 c0 01             	add    $0x1,%eax
 2cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2d2:	7c af                	jl     283 <gets+0xf>
 2d4:	eb 01                	jmp    2d7 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2d6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
 2dd:	01 d0                	add    %edx,%eax
 2df:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e5:	c9                   	leave  
 2e6:	c3                   	ret    

000002e7 <stat>:

int
stat(char *n, struct stat *st)
{
 2e7:	55                   	push   %ebp
 2e8:	89 e5                	mov    %esp,%ebp
 2ea:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2f4:	00 
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	89 04 24             	mov    %eax,(%esp)
 2fb:	e8 b4 02 00 00       	call   5b4 <open>
 300:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 303:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 307:	79 07                	jns    310 <stat+0x29>
    return -1;
 309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 30e:	eb 23                	jmp    333 <stat+0x4c>
  r = fstat(fd, st);
 310:	8b 45 0c             	mov    0xc(%ebp),%eax
 313:	89 44 24 04          	mov    %eax,0x4(%esp)
 317:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31a:	89 04 24             	mov    %eax,(%esp)
 31d:	e8 aa 02 00 00       	call   5cc <fstat>
 322:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 325:	8b 45 f4             	mov    -0xc(%ebp),%eax
 328:	89 04 24             	mov    %eax,(%esp)
 32b:	e8 6c 02 00 00       	call   59c <close>
  return r;
 330:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 333:	c9                   	leave  
 334:	c3                   	ret    

00000335 <atoi>:

int
atoi(const char *s)
{
 335:	55                   	push   %ebp
 336:	89 e5                	mov    %esp,%ebp
 338:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 33b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 342:	eb 23                	jmp    367 <atoi+0x32>
    n = n*10 + *s++ - '0';
 344:	8b 55 fc             	mov    -0x4(%ebp),%edx
 347:	89 d0                	mov    %edx,%eax
 349:	c1 e0 02             	shl    $0x2,%eax
 34c:	01 d0                	add    %edx,%eax
 34e:	01 c0                	add    %eax,%eax
 350:	89 c2                	mov    %eax,%edx
 352:	8b 45 08             	mov    0x8(%ebp),%eax
 355:	0f b6 00             	movzbl (%eax),%eax
 358:	0f be c0             	movsbl %al,%eax
 35b:	01 d0                	add    %edx,%eax
 35d:	83 e8 30             	sub    $0x30,%eax
 360:	89 45 fc             	mov    %eax,-0x4(%ebp)
 363:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 367:	8b 45 08             	mov    0x8(%ebp),%eax
 36a:	0f b6 00             	movzbl (%eax),%eax
 36d:	3c 2f                	cmp    $0x2f,%al
 36f:	7e 0a                	jle    37b <atoi+0x46>
 371:	8b 45 08             	mov    0x8(%ebp),%eax
 374:	0f b6 00             	movzbl (%eax),%eax
 377:	3c 39                	cmp    $0x39,%al
 379:	7e c9                	jle    344 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 37b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 37e:	c9                   	leave  
 37f:	c3                   	ret    

00000380 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 386:	8b 45 08             	mov    0x8(%ebp),%eax
 389:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 38c:	8b 45 0c             	mov    0xc(%ebp),%eax
 38f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 392:	eb 13                	jmp    3a7 <memmove+0x27>
    *dst++ = *src++;
 394:	8b 45 f8             	mov    -0x8(%ebp),%eax
 397:	0f b6 10             	movzbl (%eax),%edx
 39a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 39d:	88 10                	mov    %dl,(%eax)
 39f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3a3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3ab:	0f 9f c0             	setg   %al
 3ae:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3b2:	84 c0                	test   %al,%al
 3b4:	75 de                	jne    394 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3b9:	c9                   	leave  
 3ba:	c3                   	ret    

000003bb <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 3bb:	55                   	push   %ebp
 3bc:	89 e5                	mov    %esp,%ebp
 3be:	83 ec 38             	sub    $0x38,%esp
 3c1:	8b 45 10             	mov    0x10(%ebp),%eax
 3c4:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 3c7:	8b 45 14             	mov    0x14(%ebp),%eax
 3ca:	8b 00                	mov    (%eax),%eax
 3cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 3d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3da:	74 06                	je     3e2 <strtok+0x27>
 3dc:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 3e0:	75 5a                	jne    43c <strtok+0x81>
    return match;
 3e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 3e5:	eb 76                	jmp    45d <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 3e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ed:	01 d0                	add    %edx,%eax
 3ef:	0f b6 00             	movzbl (%eax),%eax
 3f2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3f5:	74 06                	je     3fd <strtok+0x42>
      {
	index++;
 3f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3fb:	eb 40                	jmp    43d <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 3fd:	8b 45 14             	mov    0x14(%ebp),%eax
 400:	8b 00                	mov    (%eax),%eax
 402:	8b 55 f4             	mov    -0xc(%ebp),%edx
 405:	29 c2                	sub    %eax,%edx
 407:	8b 45 14             	mov    0x14(%ebp),%eax
 40a:	8b 00                	mov    (%eax),%eax
 40c:	89 c1                	mov    %eax,%ecx
 40e:	8b 45 0c             	mov    0xc(%ebp),%eax
 411:	01 c8                	add    %ecx,%eax
 413:	89 54 24 08          	mov    %edx,0x8(%esp)
 417:	89 44 24 04          	mov    %eax,0x4(%esp)
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
 41e:	89 04 24             	mov    %eax,(%esp)
 421:	e8 39 00 00 00       	call   45f <strncpy>
 426:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 429:	8b 45 08             	mov    0x8(%ebp),%eax
 42c:	0f b6 00             	movzbl (%eax),%eax
 42f:	84 c0                	test   %al,%al
 431:	74 1b                	je     44e <strtok+0x93>
	  match = 1;
 433:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 43a:	eb 12                	jmp    44e <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 43c:	90                   	nop
 43d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 440:	8b 45 0c             	mov    0xc(%ebp),%eax
 443:	01 d0                	add    %edx,%eax
 445:	0f b6 00             	movzbl (%eax),%eax
 448:	84 c0                	test   %al,%al
 44a:	75 9b                	jne    3e7 <strtok+0x2c>
 44c:	eb 01                	jmp    44f <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 44e:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 44f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 452:	8d 50 01             	lea    0x1(%eax),%edx
 455:	8b 45 14             	mov    0x14(%ebp),%eax
 458:	89 10                	mov    %edx,(%eax)
  return match;
 45a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 45d:	c9                   	leave  
 45e:	c3                   	ret    

0000045f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 45f:	55                   	push   %ebp
 460:	89 e5                	mov    %esp,%ebp
 462:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 465:	8b 45 08             	mov    0x8(%ebp),%eax
 468:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 46b:	90                   	nop
 46c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 470:	0f 9f c0             	setg   %al
 473:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 477:	84 c0                	test   %al,%al
 479:	74 30                	je     4ab <strncpy+0x4c>
 47b:	8b 45 0c             	mov    0xc(%ebp),%eax
 47e:	0f b6 10             	movzbl (%eax),%edx
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	88 10                	mov    %dl,(%eax)
 486:	8b 45 08             	mov    0x8(%ebp),%eax
 489:	0f b6 00             	movzbl (%eax),%eax
 48c:	84 c0                	test   %al,%al
 48e:	0f 95 c0             	setne  %al
 491:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 495:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 499:	84 c0                	test   %al,%al
 49b:	75 cf                	jne    46c <strncpy+0xd>
    ;
  while(n-- > 0)
 49d:	eb 0c                	jmp    4ab <strncpy+0x4c>
    *s++ = 0;
 49f:	8b 45 08             	mov    0x8(%ebp),%eax
 4a2:	c6 00 00             	movb   $0x0,(%eax)
 4a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4a9:	eb 01                	jmp    4ac <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 4ab:	90                   	nop
 4ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4b0:	0f 9f c0             	setg   %al
 4b3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4b7:	84 c0                	test   %al,%al
 4b9:	75 e4                	jne    49f <strncpy+0x40>
    *s++ = 0;
  return os;
 4bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4be:	c9                   	leave  
 4bf:	c3                   	ret    

000004c0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 4c3:	eb 0c                	jmp    4d1 <strncmp+0x11>
    n--, p++, q++;
 4c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4c9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4cd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 4d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4d5:	74 1a                	je     4f1 <strncmp+0x31>
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
 4da:	0f b6 00             	movzbl (%eax),%eax
 4dd:	84 c0                	test   %al,%al
 4df:	74 10                	je     4f1 <strncmp+0x31>
 4e1:	8b 45 08             	mov    0x8(%ebp),%eax
 4e4:	0f b6 10             	movzbl (%eax),%edx
 4e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ea:	0f b6 00             	movzbl (%eax),%eax
 4ed:	38 c2                	cmp    %al,%dl
 4ef:	74 d4                	je     4c5 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 4f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4f5:	75 07                	jne    4fe <strncmp+0x3e>
    return 0;
 4f7:	b8 00 00 00 00       	mov    $0x0,%eax
 4fc:	eb 18                	jmp    516 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4fe:	8b 45 08             	mov    0x8(%ebp),%eax
 501:	0f b6 00             	movzbl (%eax),%eax
 504:	0f b6 d0             	movzbl %al,%edx
 507:	8b 45 0c             	mov    0xc(%ebp),%eax
 50a:	0f b6 00             	movzbl (%eax),%eax
 50d:	0f b6 c0             	movzbl %al,%eax
 510:	89 d1                	mov    %edx,%ecx
 512:	29 c1                	sub    %eax,%ecx
 514:	89 c8                	mov    %ecx,%eax
}
 516:	5d                   	pop    %ebp
 517:	c3                   	ret    

00000518 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 518:	55                   	push   %ebp
 519:	89 e5                	mov    %esp,%ebp
  while(*p){
 51b:	eb 13                	jmp    530 <strcat+0x18>
    *dest++ = *p++;
 51d:	8b 45 0c             	mov    0xc(%ebp),%eax
 520:	0f b6 10             	movzbl (%eax),%edx
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	88 10                	mov    %dl,(%eax)
 528:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 52c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 530:	8b 45 0c             	mov    0xc(%ebp),%eax
 533:	0f b6 00             	movzbl (%eax),%eax
 536:	84 c0                	test   %al,%al
 538:	75 e3                	jne    51d <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 53a:	eb 13                	jmp    54f <strcat+0x37>
    *dest++ = *q++;
 53c:	8b 45 10             	mov    0x10(%ebp),%eax
 53f:	0f b6 10             	movzbl (%eax),%edx
 542:	8b 45 08             	mov    0x8(%ebp),%eax
 545:	88 10                	mov    %dl,(%eax)
 547:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 54b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 54f:	8b 45 10             	mov    0x10(%ebp),%eax
 552:	0f b6 00             	movzbl (%eax),%eax
 555:	84 c0                	test   %al,%al
 557:	75 e3                	jne    53c <strcat+0x24>
    *dest++ = *q++;
  }  
 559:	5d                   	pop    %ebp
 55a:	c3                   	ret    
 55b:	90                   	nop

0000055c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 55c:	b8 01 00 00 00       	mov    $0x1,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <exit>:
SYSCALL(exit)
 564:	b8 02 00 00 00       	mov    $0x2,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <wait>:
SYSCALL(wait)
 56c:	b8 03 00 00 00       	mov    $0x3,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <wait2>:
SYSCALL(wait2)
 574:	b8 16 00 00 00       	mov    $0x16,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <nice>:
SYSCALL(nice)
 57c:	b8 17 00 00 00       	mov    $0x17,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <pipe>:
SYSCALL(pipe)
 584:	b8 04 00 00 00       	mov    $0x4,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <read>:
SYSCALL(read)
 58c:	b8 05 00 00 00       	mov    $0x5,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <write>:
SYSCALL(write)
 594:	b8 10 00 00 00       	mov    $0x10,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <close>:
SYSCALL(close)
 59c:	b8 15 00 00 00       	mov    $0x15,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <kill>:
SYSCALL(kill)
 5a4:	b8 06 00 00 00       	mov    $0x6,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <exec>:
SYSCALL(exec)
 5ac:	b8 07 00 00 00       	mov    $0x7,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <open>:
SYSCALL(open)
 5b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <mknod>:
SYSCALL(mknod)
 5bc:	b8 11 00 00 00       	mov    $0x11,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <unlink>:
SYSCALL(unlink)
 5c4:	b8 12 00 00 00       	mov    $0x12,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <fstat>:
SYSCALL(fstat)
 5cc:	b8 08 00 00 00       	mov    $0x8,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <link>:
SYSCALL(link)
 5d4:	b8 13 00 00 00       	mov    $0x13,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <mkdir>:
SYSCALL(mkdir)
 5dc:	b8 14 00 00 00       	mov    $0x14,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <chdir>:
SYSCALL(chdir)
 5e4:	b8 09 00 00 00       	mov    $0x9,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <dup>:
SYSCALL(dup)
 5ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <getpid>:
SYSCALL(getpid)
 5f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <sbrk>:
SYSCALL(sbrk)
 5fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <sleep>:
SYSCALL(sleep)
 604:	b8 0d 00 00 00       	mov    $0xd,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <uptime>:
SYSCALL(uptime)
 60c:	b8 0e 00 00 00       	mov    $0xe,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 614:	55                   	push   %ebp
 615:	89 e5                	mov    %esp,%ebp
 617:	83 ec 28             	sub    $0x28,%esp
 61a:	8b 45 0c             	mov    0xc(%ebp),%eax
 61d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 620:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 627:	00 
 628:	8d 45 f4             	lea    -0xc(%ebp),%eax
 62b:	89 44 24 04          	mov    %eax,0x4(%esp)
 62f:	8b 45 08             	mov    0x8(%ebp),%eax
 632:	89 04 24             	mov    %eax,(%esp)
 635:	e8 5a ff ff ff       	call   594 <write>
}
 63a:	c9                   	leave  
 63b:	c3                   	ret    

0000063c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 63c:	55                   	push   %ebp
 63d:	89 e5                	mov    %esp,%ebp
 63f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 642:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 649:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 64d:	74 17                	je     666 <printint+0x2a>
 64f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 653:	79 11                	jns    666 <printint+0x2a>
    neg = 1;
 655:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 65c:	8b 45 0c             	mov    0xc(%ebp),%eax
 65f:	f7 d8                	neg    %eax
 661:	89 45 ec             	mov    %eax,-0x14(%ebp)
 664:	eb 06                	jmp    66c <printint+0x30>
  } else {
    x = xx;
 666:	8b 45 0c             	mov    0xc(%ebp),%eax
 669:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 66c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 673:	8b 4d 10             	mov    0x10(%ebp),%ecx
 676:	8b 45 ec             	mov    -0x14(%ebp),%eax
 679:	ba 00 00 00 00       	mov    $0x0,%edx
 67e:	f7 f1                	div    %ecx
 680:	89 d0                	mov    %edx,%eax
 682:	0f b6 80 3c 0e 00 00 	movzbl 0xe3c(%eax),%eax
 689:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 68c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 68f:	01 ca                	add    %ecx,%edx
 691:	88 02                	mov    %al,(%edx)
 693:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 697:	8b 55 10             	mov    0x10(%ebp),%edx
 69a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 69d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6a0:	ba 00 00 00 00       	mov    $0x0,%edx
 6a5:	f7 75 d4             	divl   -0x2c(%ebp)
 6a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6af:	75 c2                	jne    673 <printint+0x37>
  if(neg)
 6b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6b5:	74 2e                	je     6e5 <printint+0xa9>
    buf[i++] = '-';
 6b7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bd:	01 d0                	add    %edx,%eax
 6bf:	c6 00 2d             	movb   $0x2d,(%eax)
 6c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6c6:	eb 1d                	jmp    6e5 <printint+0xa9>
    putc(fd, buf[i]);
 6c8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ce:	01 d0                	add    %edx,%eax
 6d0:	0f b6 00             	movzbl (%eax),%eax
 6d3:	0f be c0             	movsbl %al,%eax
 6d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 6da:	8b 45 08             	mov    0x8(%ebp),%eax
 6dd:	89 04 24             	mov    %eax,(%esp)
 6e0:	e8 2f ff ff ff       	call   614 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6e5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ed:	79 d9                	jns    6c8 <printint+0x8c>
    putc(fd, buf[i]);
}
 6ef:	c9                   	leave  
 6f0:	c3                   	ret    

000006f1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6f1:	55                   	push   %ebp
 6f2:	89 e5                	mov    %esp,%ebp
 6f4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6fe:	8d 45 0c             	lea    0xc(%ebp),%eax
 701:	83 c0 04             	add    $0x4,%eax
 704:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 707:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 70e:	e9 7d 01 00 00       	jmp    890 <printf+0x19f>
    c = fmt[i] & 0xff;
 713:	8b 55 0c             	mov    0xc(%ebp),%edx
 716:	8b 45 f0             	mov    -0x10(%ebp),%eax
 719:	01 d0                	add    %edx,%eax
 71b:	0f b6 00             	movzbl (%eax),%eax
 71e:	0f be c0             	movsbl %al,%eax
 721:	25 ff 00 00 00       	and    $0xff,%eax
 726:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 729:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 72d:	75 2c                	jne    75b <printf+0x6a>
      if(c == '%'){
 72f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 733:	75 0c                	jne    741 <printf+0x50>
        state = '%';
 735:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 73c:	e9 4b 01 00 00       	jmp    88c <printf+0x19b>
      } else {
        putc(fd, c);
 741:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 744:	0f be c0             	movsbl %al,%eax
 747:	89 44 24 04          	mov    %eax,0x4(%esp)
 74b:	8b 45 08             	mov    0x8(%ebp),%eax
 74e:	89 04 24             	mov    %eax,(%esp)
 751:	e8 be fe ff ff       	call   614 <putc>
 756:	e9 31 01 00 00       	jmp    88c <printf+0x19b>
      }
    } else if(state == '%'){
 75b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 75f:	0f 85 27 01 00 00    	jne    88c <printf+0x19b>
      if(c == 'd'){
 765:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 769:	75 2d                	jne    798 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 76b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76e:	8b 00                	mov    (%eax),%eax
 770:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 777:	00 
 778:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 77f:	00 
 780:	89 44 24 04          	mov    %eax,0x4(%esp)
 784:	8b 45 08             	mov    0x8(%ebp),%eax
 787:	89 04 24             	mov    %eax,(%esp)
 78a:	e8 ad fe ff ff       	call   63c <printint>
        ap++;
 78f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 793:	e9 ed 00 00 00       	jmp    885 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 798:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 79c:	74 06                	je     7a4 <printf+0xb3>
 79e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7a2:	75 2d                	jne    7d1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a7:	8b 00                	mov    (%eax),%eax
 7a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7b0:	00 
 7b1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7b8:	00 
 7b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7bd:	8b 45 08             	mov    0x8(%ebp),%eax
 7c0:	89 04 24             	mov    %eax,(%esp)
 7c3:	e8 74 fe ff ff       	call   63c <printint>
        ap++;
 7c8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7cc:	e9 b4 00 00 00       	jmp    885 <printf+0x194>
      } else if(c == 's'){
 7d1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7d5:	75 46                	jne    81d <printf+0x12c>
        s = (char*)*ap;
 7d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7da:	8b 00                	mov    (%eax),%eax
 7dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e7:	75 27                	jne    810 <printf+0x11f>
          s = "(null)";
 7e9:	c7 45 f4 35 0b 00 00 	movl   $0xb35,-0xc(%ebp)
        while(*s != 0){
 7f0:	eb 1e                	jmp    810 <printf+0x11f>
          putc(fd, *s);
 7f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f5:	0f b6 00             	movzbl (%eax),%eax
 7f8:	0f be c0             	movsbl %al,%eax
 7fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ff:	8b 45 08             	mov    0x8(%ebp),%eax
 802:	89 04 24             	mov    %eax,(%esp)
 805:	e8 0a fe ff ff       	call   614 <putc>
          s++;
 80a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 80e:	eb 01                	jmp    811 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 810:	90                   	nop
 811:	8b 45 f4             	mov    -0xc(%ebp),%eax
 814:	0f b6 00             	movzbl (%eax),%eax
 817:	84 c0                	test   %al,%al
 819:	75 d7                	jne    7f2 <printf+0x101>
 81b:	eb 68                	jmp    885 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 81d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 821:	75 1d                	jne    840 <printf+0x14f>
        putc(fd, *ap);
 823:	8b 45 e8             	mov    -0x18(%ebp),%eax
 826:	8b 00                	mov    (%eax),%eax
 828:	0f be c0             	movsbl %al,%eax
 82b:	89 44 24 04          	mov    %eax,0x4(%esp)
 82f:	8b 45 08             	mov    0x8(%ebp),%eax
 832:	89 04 24             	mov    %eax,(%esp)
 835:	e8 da fd ff ff       	call   614 <putc>
        ap++;
 83a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 83e:	eb 45                	jmp    885 <printf+0x194>
      } else if(c == '%'){
 840:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 844:	75 17                	jne    85d <printf+0x16c>
        putc(fd, c);
 846:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 849:	0f be c0             	movsbl %al,%eax
 84c:	89 44 24 04          	mov    %eax,0x4(%esp)
 850:	8b 45 08             	mov    0x8(%ebp),%eax
 853:	89 04 24             	mov    %eax,(%esp)
 856:	e8 b9 fd ff ff       	call   614 <putc>
 85b:	eb 28                	jmp    885 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 85d:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 864:	00 
 865:	8b 45 08             	mov    0x8(%ebp),%eax
 868:	89 04 24             	mov    %eax,(%esp)
 86b:	e8 a4 fd ff ff       	call   614 <putc>
        putc(fd, c);
 870:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 873:	0f be c0             	movsbl %al,%eax
 876:	89 44 24 04          	mov    %eax,0x4(%esp)
 87a:	8b 45 08             	mov    0x8(%ebp),%eax
 87d:	89 04 24             	mov    %eax,(%esp)
 880:	e8 8f fd ff ff       	call   614 <putc>
      }
      state = 0;
 885:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 88c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 890:	8b 55 0c             	mov    0xc(%ebp),%edx
 893:	8b 45 f0             	mov    -0x10(%ebp),%eax
 896:	01 d0                	add    %edx,%eax
 898:	0f b6 00             	movzbl (%eax),%eax
 89b:	84 c0                	test   %al,%al
 89d:	0f 85 70 fe ff ff    	jne    713 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8a3:	c9                   	leave  
 8a4:	c3                   	ret    
 8a5:	66 90                	xchg   %ax,%ax
 8a7:	90                   	nop

000008a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a8:	55                   	push   %ebp
 8a9:	89 e5                	mov    %esp,%ebp
 8ab:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ae:	8b 45 08             	mov    0x8(%ebp),%eax
 8b1:	83 e8 08             	sub    $0x8,%eax
 8b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b7:	a1 58 0e 00 00       	mov    0xe58,%eax
 8bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8bf:	eb 24                	jmp    8e5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c9:	77 12                	ja     8dd <free+0x35>
 8cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d1:	77 24                	ja     8f7 <free+0x4f>
 8d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d6:	8b 00                	mov    (%eax),%eax
 8d8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8db:	77 1a                	ja     8f7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e0:	8b 00                	mov    (%eax),%eax
 8e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8eb:	76 d4                	jbe    8c1 <free+0x19>
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	8b 00                	mov    (%eax),%eax
 8f2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8f5:	76 ca                	jbe    8c1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fa:	8b 40 04             	mov    0x4(%eax),%eax
 8fd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 904:	8b 45 f8             	mov    -0x8(%ebp),%eax
 907:	01 c2                	add    %eax,%edx
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	39 c2                	cmp    %eax,%edx
 910:	75 24                	jne    936 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 912:	8b 45 f8             	mov    -0x8(%ebp),%eax
 915:	8b 50 04             	mov    0x4(%eax),%edx
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	8b 00                	mov    (%eax),%eax
 91d:	8b 40 04             	mov    0x4(%eax),%eax
 920:	01 c2                	add    %eax,%edx
 922:	8b 45 f8             	mov    -0x8(%ebp),%eax
 925:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 928:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92b:	8b 00                	mov    (%eax),%eax
 92d:	8b 10                	mov    (%eax),%edx
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	89 10                	mov    %edx,(%eax)
 934:	eb 0a                	jmp    940 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 936:	8b 45 fc             	mov    -0x4(%ebp),%eax
 939:	8b 10                	mov    (%eax),%edx
 93b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 940:	8b 45 fc             	mov    -0x4(%ebp),%eax
 943:	8b 40 04             	mov    0x4(%eax),%eax
 946:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 94d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 950:	01 d0                	add    %edx,%eax
 952:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 955:	75 20                	jne    977 <free+0xcf>
    p->s.size += bp->s.size;
 957:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95a:	8b 50 04             	mov    0x4(%eax),%edx
 95d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 960:	8b 40 04             	mov    0x4(%eax),%eax
 963:	01 c2                	add    %eax,%edx
 965:	8b 45 fc             	mov    -0x4(%ebp),%eax
 968:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 96b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96e:	8b 10                	mov    (%eax),%edx
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	89 10                	mov    %edx,(%eax)
 975:	eb 08                	jmp    97f <free+0xd7>
  } else
    p->s.ptr = bp;
 977:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 97d:	89 10                	mov    %edx,(%eax)
  freep = p;
 97f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 982:	a3 58 0e 00 00       	mov    %eax,0xe58
}
 987:	c9                   	leave  
 988:	c3                   	ret    

00000989 <morecore>:

static Header*
morecore(uint nu)
{
 989:	55                   	push   %ebp
 98a:	89 e5                	mov    %esp,%ebp
 98c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 98f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 996:	77 07                	ja     99f <morecore+0x16>
    nu = 4096;
 998:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 99f:	8b 45 08             	mov    0x8(%ebp),%eax
 9a2:	c1 e0 03             	shl    $0x3,%eax
 9a5:	89 04 24             	mov    %eax,(%esp)
 9a8:	e8 4f fc ff ff       	call   5fc <sbrk>
 9ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9b0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9b4:	75 07                	jne    9bd <morecore+0x34>
    return 0;
 9b6:	b8 00 00 00 00       	mov    $0x0,%eax
 9bb:	eb 22                	jmp    9df <morecore+0x56>
  hp = (Header*)p;
 9bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c6:	8b 55 08             	mov    0x8(%ebp),%edx
 9c9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cf:	83 c0 08             	add    $0x8,%eax
 9d2:	89 04 24             	mov    %eax,(%esp)
 9d5:	e8 ce fe ff ff       	call   8a8 <free>
  return freep;
 9da:	a1 58 0e 00 00       	mov    0xe58,%eax
}
 9df:	c9                   	leave  
 9e0:	c3                   	ret    

000009e1 <malloc>:

void*
malloc(uint nbytes)
{
 9e1:	55                   	push   %ebp
 9e2:	89 e5                	mov    %esp,%ebp
 9e4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ea:	83 c0 07             	add    $0x7,%eax
 9ed:	c1 e8 03             	shr    $0x3,%eax
 9f0:	83 c0 01             	add    $0x1,%eax
 9f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9f6:	a1 58 0e 00 00       	mov    0xe58,%eax
 9fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a02:	75 23                	jne    a27 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a04:	c7 45 f0 50 0e 00 00 	movl   $0xe50,-0x10(%ebp)
 a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0e:	a3 58 0e 00 00       	mov    %eax,0xe58
 a13:	a1 58 0e 00 00       	mov    0xe58,%eax
 a18:	a3 50 0e 00 00       	mov    %eax,0xe50
    base.s.size = 0;
 a1d:	c7 05 54 0e 00 00 00 	movl   $0x0,0xe54
 a24:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2a:	8b 00                	mov    (%eax),%eax
 a2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a32:	8b 40 04             	mov    0x4(%eax),%eax
 a35:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a38:	72 4d                	jb     a87 <malloc+0xa6>
      if(p->s.size == nunits)
 a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3d:	8b 40 04             	mov    0x4(%eax),%eax
 a40:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a43:	75 0c                	jne    a51 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a48:	8b 10                	mov    (%eax),%edx
 a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4d:	89 10                	mov    %edx,(%eax)
 a4f:	eb 26                	jmp    a77 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a54:	8b 40 04             	mov    0x4(%eax),%eax
 a57:	89 c2                	mov    %eax,%edx
 a59:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a65:	8b 40 04             	mov    0x4(%eax),%eax
 a68:	c1 e0 03             	shl    $0x3,%eax
 a6b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a71:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a74:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7a:	a3 58 0e 00 00       	mov    %eax,0xe58
      return (void*)(p + 1);
 a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a82:	83 c0 08             	add    $0x8,%eax
 a85:	eb 38                	jmp    abf <malloc+0xde>
    }
    if(p == freep)
 a87:	a1 58 0e 00 00       	mov    0xe58,%eax
 a8c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a8f:	75 1b                	jne    aac <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a91:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a94:	89 04 24             	mov    %eax,(%esp)
 a97:	e8 ed fe ff ff       	call   989 <morecore>
 a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aa3:	75 07                	jne    aac <malloc+0xcb>
        return 0;
 aa5:	b8 00 00 00 00       	mov    $0x0,%eax
 aaa:	eb 13                	jmp    abf <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab5:	8b 00                	mov    (%eax),%eax
 ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 aba:	e9 70 ff ff ff       	jmp    a2f <malloc+0x4e>
}
 abf:	c9                   	leave  
 ac0:	c3                   	ret    
