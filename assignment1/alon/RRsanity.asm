
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
  28:	c7 44 24 04 b0 0a 00 	movl   $0xab0,0x4(%esp)
  2f:	00 
  30:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  37:	e8 af 06 00 00       	call   6eb <printf>
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
  55:	c7 44 24 04 d1 0a 00 	movl   $0xad1,0x4(%esp)
  5c:	00 
  5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  64:	e8 82 06 00 00       	call   6eb <printf>

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
  aa:	eb 38                	jmp    e4 <RRsanity+0x99>
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  b6:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  b9:	01 c2                	add    %eax,%edx
  bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  be:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  c5:	8d 45 cc             	lea    -0x34(%ebp),%eax
  c8:	01 c8                	add    %ecx,%eax
  ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  ce:	89 04 24             	mov    %eax,(%esp)
  d1:	e8 9e 04 00 00       	call   574 <wait2>
  d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  d9:	89 84 95 7c ff ff ff 	mov    %eax,-0x84(%ebp,%edx,4)
      foo();
      exit();      
    }
  }
  
  for(i=0;i<10;i++)
  e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  e4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  e8:	7e c2                	jle    ac <RRsanity+0x61>
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  
  for(i=0;i<10;i++)
  ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  f1:	eb 51                	jmp    144 <RRsanity+0xf9>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",pid[i],wTime[i],rTime[i],wTime[i]+rTime[i]);
  f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f6:	8b 54 85 cc          	mov    -0x34(%ebp,%eax,4),%edx
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
 101:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 104:	8b 45 f4             	mov    -0xc(%ebp),%eax
 107:	8b 4c 85 a4          	mov    -0x5c(%ebp,%eax,4),%ecx
 10b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 10e:	8b 54 85 cc          	mov    -0x34(%ebp,%eax,4),%edx
 112:	8b 45 f4             	mov    -0xc(%ebp),%eax
 115:	8b 84 85 7c ff ff ff 	mov    -0x84(%ebp,%eax,4),%eax
 11c:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 120:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 124:	89 54 24 0c          	mov    %edx,0xc(%esp)
 128:	89 44 24 08          	mov    %eax,0x8(%esp)
 12c:	c7 44 24 04 e0 0a 00 	movl   $0xae0,0x4(%esp)
 133:	00 
 134:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13b:	e8 ab 05 00 00       	call   6eb <printf>
  }
  
  for(i=0;i<10;i++)
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  
  for(i=0;i<10;i++)
 140:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 144:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 148:	7e a9                	jle    f3 <RRsanity+0xa8>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",pid[i],wTime[i],rTime[i],wTime[i]+rTime[i]);

}
 14a:	81 c4 a4 00 00 00    	add    $0xa4,%esp
 150:	5b                   	pop    %ebx
 151:	5d                   	pop    %ebp
 152:	c3                   	ret    

00000153 <main>:
int
main(void)
{
 153:	55                   	push   %ebp
 154:	89 e5                	mov    %esp,%ebp
 156:	83 e4 f0             	and    $0xfffffff0,%esp
  RRsanity();
 159:	e8 ed fe ff ff       	call   4b <RRsanity>
  exit();
 15e:	e8 01 04 00 00       	call   564 <exit>
 163:	90                   	nop

00000164 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
 167:	57                   	push   %edi
 168:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 169:	8b 4d 08             	mov    0x8(%ebp),%ecx
 16c:	8b 55 10             	mov    0x10(%ebp),%edx
 16f:	8b 45 0c             	mov    0xc(%ebp),%eax
 172:	89 cb                	mov    %ecx,%ebx
 174:	89 df                	mov    %ebx,%edi
 176:	89 d1                	mov    %edx,%ecx
 178:	fc                   	cld    
 179:	f3 aa                	rep stos %al,%es:(%edi)
 17b:	89 ca                	mov    %ecx,%edx
 17d:	89 fb                	mov    %edi,%ebx
 17f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 182:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 185:	5b                   	pop    %ebx
 186:	5f                   	pop    %edi
 187:	5d                   	pop    %ebp
 188:	c3                   	ret    

00000189 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 18f:	8b 45 08             	mov    0x8(%ebp),%eax
 192:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 195:	90                   	nop
 196:	8b 45 0c             	mov    0xc(%ebp),%eax
 199:	0f b6 10             	movzbl (%eax),%edx
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	88 10                	mov    %dl,(%eax)
 1a1:	8b 45 08             	mov    0x8(%ebp),%eax
 1a4:	0f b6 00             	movzbl (%eax),%eax
 1a7:	84 c0                	test   %al,%al
 1a9:	0f 95 c0             	setne  %al
 1ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 1b4:	84 c0                	test   %al,%al
 1b6:	75 de                	jne    196 <strcpy+0xd>
    ;
  return os;
 1b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1bb:	c9                   	leave  
 1bc:	c3                   	ret    

000001bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1bd:	55                   	push   %ebp
 1be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1c0:	eb 08                	jmp    1ca <strcmp+0xd>
    p++, q++;
 1c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	0f b6 00             	movzbl (%eax),%eax
 1d0:	84 c0                	test   %al,%al
 1d2:	74 10                	je     1e4 <strcmp+0x27>
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	0f b6 10             	movzbl (%eax),%edx
 1da:	8b 45 0c             	mov    0xc(%ebp),%eax
 1dd:	0f b6 00             	movzbl (%eax),%eax
 1e0:	38 c2                	cmp    %al,%dl
 1e2:	74 de                	je     1c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	0f b6 00             	movzbl (%eax),%eax
 1ea:	0f b6 d0             	movzbl %al,%edx
 1ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f0:	0f b6 00             	movzbl (%eax),%eax
 1f3:	0f b6 c0             	movzbl %al,%eax
 1f6:	89 d1                	mov    %edx,%ecx
 1f8:	29 c1                	sub    %eax,%ecx
 1fa:	89 c8                	mov    %ecx,%eax
}
 1fc:	5d                   	pop    %ebp
 1fd:	c3                   	ret    

000001fe <strlen>:

uint
strlen(char *s)
{
 1fe:	55                   	push   %ebp
 1ff:	89 e5                	mov    %esp,%ebp
 201:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 204:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 20b:	eb 04                	jmp    211 <strlen+0x13>
 20d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 211:	8b 45 fc             	mov    -0x4(%ebp),%eax
 214:	03 45 08             	add    0x8(%ebp),%eax
 217:	0f b6 00             	movzbl (%eax),%eax
 21a:	84 c0                	test   %al,%al
 21c:	75 ef                	jne    20d <strlen+0xf>
  return n;
 21e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 221:	c9                   	leave  
 222:	c3                   	ret    

00000223 <memset>:

void*
memset(void *dst, int c, uint n)
{
 223:	55                   	push   %ebp
 224:	89 e5                	mov    %esp,%ebp
 226:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 229:	8b 45 10             	mov    0x10(%ebp),%eax
 22c:	89 44 24 08          	mov    %eax,0x8(%esp)
 230:	8b 45 0c             	mov    0xc(%ebp),%eax
 233:	89 44 24 04          	mov    %eax,0x4(%esp)
 237:	8b 45 08             	mov    0x8(%ebp),%eax
 23a:	89 04 24             	mov    %eax,(%esp)
 23d:	e8 22 ff ff ff       	call   164 <stosb>
  return dst;
 242:	8b 45 08             	mov    0x8(%ebp),%eax
}
 245:	c9                   	leave  
 246:	c3                   	ret    

00000247 <strchr>:

char*
strchr(const char *s, char c)
{
 247:	55                   	push   %ebp
 248:	89 e5                	mov    %esp,%ebp
 24a:	83 ec 04             	sub    $0x4,%esp
 24d:	8b 45 0c             	mov    0xc(%ebp),%eax
 250:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 253:	eb 14                	jmp    269 <strchr+0x22>
    if(*s == c)
 255:	8b 45 08             	mov    0x8(%ebp),%eax
 258:	0f b6 00             	movzbl (%eax),%eax
 25b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 25e:	75 05                	jne    265 <strchr+0x1e>
      return (char*)s;
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	eb 13                	jmp    278 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 265:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	0f b6 00             	movzbl (%eax),%eax
 26f:	84 c0                	test   %al,%al
 271:	75 e2                	jne    255 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 273:	b8 00 00 00 00       	mov    $0x0,%eax
}
 278:	c9                   	leave  
 279:	c3                   	ret    

0000027a <gets>:

char*
gets(char *buf, int max)
{
 27a:	55                   	push   %ebp
 27b:	89 e5                	mov    %esp,%ebp
 27d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 280:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 287:	eb 44                	jmp    2cd <gets+0x53>
    cc = read(0, &c, 1);
 289:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 290:	00 
 291:	8d 45 ef             	lea    -0x11(%ebp),%eax
 294:	89 44 24 04          	mov    %eax,0x4(%esp)
 298:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 29f:	e8 e8 02 00 00       	call   58c <read>
 2a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2ab:	7e 2d                	jle    2da <gets+0x60>
      break;
    buf[i++] = c;
 2ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b0:	03 45 08             	add    0x8(%ebp),%eax
 2b3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 2b7:	88 10                	mov    %dl,(%eax)
 2b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 2bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c1:	3c 0a                	cmp    $0xa,%al
 2c3:	74 16                	je     2db <gets+0x61>
 2c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c9:	3c 0d                	cmp    $0xd,%al
 2cb:	74 0e                	je     2db <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d0:	83 c0 01             	add    $0x1,%eax
 2d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2d6:	7c b1                	jl     289 <gets+0xf>
 2d8:	eb 01                	jmp    2db <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2da:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2de:	03 45 08             	add    0x8(%ebp),%eax
 2e1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e7:	c9                   	leave  
 2e8:	c3                   	ret    

000002e9 <stat>:

int
stat(char *n, struct stat *st)
{
 2e9:	55                   	push   %ebp
 2ea:	89 e5                	mov    %esp,%ebp
 2ec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2f6:	00 
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	89 04 24             	mov    %eax,(%esp)
 2fd:	e8 b2 02 00 00       	call   5b4 <open>
 302:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 305:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 309:	79 07                	jns    312 <stat+0x29>
    return -1;
 30b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 310:	eb 23                	jmp    335 <stat+0x4c>
  r = fstat(fd, st);
 312:	8b 45 0c             	mov    0xc(%ebp),%eax
 315:	89 44 24 04          	mov    %eax,0x4(%esp)
 319:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31c:	89 04 24             	mov    %eax,(%esp)
 31f:	e8 a8 02 00 00       	call   5cc <fstat>
 324:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 327:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32a:	89 04 24             	mov    %eax,(%esp)
 32d:	e8 6a 02 00 00       	call   59c <close>
  return r;
 332:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 335:	c9                   	leave  
 336:	c3                   	ret    

00000337 <atoi>:

int
atoi(const char *s)
{
 337:	55                   	push   %ebp
 338:	89 e5                	mov    %esp,%ebp
 33a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 33d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 344:	eb 23                	jmp    369 <atoi+0x32>
    n = n*10 + *s++ - '0';
 346:	8b 55 fc             	mov    -0x4(%ebp),%edx
 349:	89 d0                	mov    %edx,%eax
 34b:	c1 e0 02             	shl    $0x2,%eax
 34e:	01 d0                	add    %edx,%eax
 350:	01 c0                	add    %eax,%eax
 352:	89 c2                	mov    %eax,%edx
 354:	8b 45 08             	mov    0x8(%ebp),%eax
 357:	0f b6 00             	movzbl (%eax),%eax
 35a:	0f be c0             	movsbl %al,%eax
 35d:	01 d0                	add    %edx,%eax
 35f:	83 e8 30             	sub    $0x30,%eax
 362:	89 45 fc             	mov    %eax,-0x4(%ebp)
 365:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	0f b6 00             	movzbl (%eax),%eax
 36f:	3c 2f                	cmp    $0x2f,%al
 371:	7e 0a                	jle    37d <atoi+0x46>
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	0f b6 00             	movzbl (%eax),%eax
 379:	3c 39                	cmp    $0x39,%al
 37b:	7e c9                	jle    346 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 37d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 380:	c9                   	leave  
 381:	c3                   	ret    

00000382 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 382:	55                   	push   %ebp
 383:	89 e5                	mov    %esp,%ebp
 385:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 394:	eb 13                	jmp    3a9 <memmove+0x27>
    *dst++ = *src++;
 396:	8b 45 f8             	mov    -0x8(%ebp),%eax
 399:	0f b6 10             	movzbl (%eax),%edx
 39c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 39f:	88 10                	mov    %dl,(%eax)
 3a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3a5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3ad:	0f 9f c0             	setg   %al
 3b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3b4:	84 c0                	test   %al,%al
 3b6:	75 de                	jne    396 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3bb:	c9                   	leave  
 3bc:	c3                   	ret    

000003bd <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 3bd:	55                   	push   %ebp
 3be:	89 e5                	mov    %esp,%ebp
 3c0:	83 ec 38             	sub    $0x38,%esp
 3c3:	8b 45 10             	mov    0x10(%ebp),%eax
 3c6:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 3c9:	8b 45 14             	mov    0x14(%ebp),%eax
 3cc:	8b 00                	mov    (%eax),%eax
 3ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 3d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3dc:	74 06                	je     3e4 <strtok+0x27>
 3de:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 3e2:	75 54                	jne    438 <strtok+0x7b>
    return match;
 3e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 3e7:	eb 6e                	jmp    457 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 3e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ec:	03 45 0c             	add    0xc(%ebp),%eax
 3ef:	0f b6 00             	movzbl (%eax),%eax
 3f2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3f5:	74 06                	je     3fd <strtok+0x40>
      {
	index++;
 3f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3fb:	eb 3c                	jmp    439 <strtok+0x7c>
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
 40c:	03 45 0c             	add    0xc(%ebp),%eax
 40f:	89 54 24 08          	mov    %edx,0x8(%esp)
 413:	89 44 24 04          	mov    %eax,0x4(%esp)
 417:	8b 45 08             	mov    0x8(%ebp),%eax
 41a:	89 04 24             	mov    %eax,(%esp)
 41d:	e8 37 00 00 00       	call   459 <strncpy>
 422:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 425:	8b 45 08             	mov    0x8(%ebp),%eax
 428:	0f b6 00             	movzbl (%eax),%eax
 42b:	84 c0                	test   %al,%al
 42d:	74 19                	je     448 <strtok+0x8b>
	  match = 1;
 42f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 436:	eb 10                	jmp    448 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 438:	90                   	nop
 439:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43c:	03 45 0c             	add    0xc(%ebp),%eax
 43f:	0f b6 00             	movzbl (%eax),%eax
 442:	84 c0                	test   %al,%al
 444:	75 a3                	jne    3e9 <strtok+0x2c>
 446:	eb 01                	jmp    449 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 448:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 449:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44c:	8d 50 01             	lea    0x1(%eax),%edx
 44f:	8b 45 14             	mov    0x14(%ebp),%eax
 452:	89 10                	mov    %edx,(%eax)
  return match;
 454:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 457:	c9                   	leave  
 458:	c3                   	ret    

00000459 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 459:	55                   	push   %ebp
 45a:	89 e5                	mov    %esp,%ebp
 45c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 45f:	8b 45 08             	mov    0x8(%ebp),%eax
 462:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 465:	90                   	nop
 466:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 46a:	0f 9f c0             	setg   %al
 46d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 471:	84 c0                	test   %al,%al
 473:	74 30                	je     4a5 <strncpy+0x4c>
 475:	8b 45 0c             	mov    0xc(%ebp),%eax
 478:	0f b6 10             	movzbl (%eax),%edx
 47b:	8b 45 08             	mov    0x8(%ebp),%eax
 47e:	88 10                	mov    %dl,(%eax)
 480:	8b 45 08             	mov    0x8(%ebp),%eax
 483:	0f b6 00             	movzbl (%eax),%eax
 486:	84 c0                	test   %al,%al
 488:	0f 95 c0             	setne  %al
 48b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 48f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 493:	84 c0                	test   %al,%al
 495:	75 cf                	jne    466 <strncpy+0xd>
    ;
  while(n-- > 0)
 497:	eb 0c                	jmp    4a5 <strncpy+0x4c>
    *s++ = 0;
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	c6 00 00             	movb   $0x0,(%eax)
 49f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4a3:	eb 01                	jmp    4a6 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 4a5:	90                   	nop
 4a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4aa:	0f 9f c0             	setg   %al
 4ad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4b1:	84 c0                	test   %al,%al
 4b3:	75 e4                	jne    499 <strncpy+0x40>
    *s++ = 0;
  return os;
 4b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b8:	c9                   	leave  
 4b9:	c3                   	ret    

000004ba <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 4ba:	55                   	push   %ebp
 4bb:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 4bd:	eb 0c                	jmp    4cb <strncmp+0x11>
    n--, p++, q++;
 4bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4c7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 4cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4cf:	74 1a                	je     4eb <strncmp+0x31>
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	0f b6 00             	movzbl (%eax),%eax
 4d7:	84 c0                	test   %al,%al
 4d9:	74 10                	je     4eb <strncmp+0x31>
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	0f b6 10             	movzbl (%eax),%edx
 4e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e4:	0f b6 00             	movzbl (%eax),%eax
 4e7:	38 c2                	cmp    %al,%dl
 4e9:	74 d4                	je     4bf <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 4eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4ef:	75 07                	jne    4f8 <strncmp+0x3e>
    return 0;
 4f1:	b8 00 00 00 00       	mov    $0x0,%eax
 4f6:	eb 18                	jmp    510 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4f8:	8b 45 08             	mov    0x8(%ebp),%eax
 4fb:	0f b6 00             	movzbl (%eax),%eax
 4fe:	0f b6 d0             	movzbl %al,%edx
 501:	8b 45 0c             	mov    0xc(%ebp),%eax
 504:	0f b6 00             	movzbl (%eax),%eax
 507:	0f b6 c0             	movzbl %al,%eax
 50a:	89 d1                	mov    %edx,%ecx
 50c:	29 c1                	sub    %eax,%ecx
 50e:	89 c8                	mov    %ecx,%eax
}
 510:	5d                   	pop    %ebp
 511:	c3                   	ret    

00000512 <strcat>:

void
strcat(char *dest, char *p, char *q)
{  
 512:	55                   	push   %ebp
 513:	89 e5                	mov    %esp,%ebp
  while(*p){
 515:	eb 13                	jmp    52a <strcat+0x18>
    *dest++ = *p++;
 517:	8b 45 0c             	mov    0xc(%ebp),%eax
 51a:	0f b6 10             	movzbl (%eax),%edx
 51d:	8b 45 08             	mov    0x8(%ebp),%eax
 520:	88 10                	mov    %dl,(%eax)
 522:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 526:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, char *p, char *q)
{  
  while(*p){
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	84 c0                	test   %al,%al
 532:	75 e3                	jne    517 <strcat+0x5>
    *dest++ = *p++;
  }

  while(*q){
 534:	eb 13                	jmp    549 <strcat+0x37>
    *dest++ = *q++;
 536:	8b 45 10             	mov    0x10(%ebp),%eax
 539:	0f b6 10             	movzbl (%eax),%edx
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
 53f:	88 10                	mov    %dl,(%eax)
 541:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 545:	83 45 10 01          	addl   $0x1,0x10(%ebp)
{  
  while(*p){
    *dest++ = *p++;
  }

  while(*q){
 549:	8b 45 10             	mov    0x10(%ebp),%eax
 54c:	0f b6 00             	movzbl (%eax),%eax
 54f:	84 c0                	test   %al,%al
 551:	75 e3                	jne    536 <strcat+0x24>
    *dest++ = *q++;
  }
  *dest = 0;
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	c6 00 00             	movb   $0x0,(%eax)
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
 682:	0f b6 90 28 0e 00 00 	movzbl 0xe28(%eax),%edx
 689:	8d 45 dc             	lea    -0x24(%ebp),%eax
 68c:	03 45 f4             	add    -0xc(%ebp),%eax
 68f:	88 10                	mov    %dl,(%eax)
 691:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 695:	8b 55 10             	mov    0x10(%ebp),%edx
 698:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 69b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 69e:	ba 00 00 00 00       	mov    $0x0,%edx
 6a3:	f7 75 d4             	divl   -0x2c(%ebp)
 6a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ad:	75 c4                	jne    673 <printint+0x37>
  if(neg)
 6af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6b3:	74 2a                	je     6df <printint+0xa3>
    buf[i++] = '-';
 6b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6b8:	03 45 f4             	add    -0xc(%ebp),%eax
 6bb:	c6 00 2d             	movb   $0x2d,(%eax)
 6be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6c2:	eb 1b                	jmp    6df <printint+0xa3>
    putc(fd, buf[i]);
 6c4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6c7:	03 45 f4             	add    -0xc(%ebp),%eax
 6ca:	0f b6 00             	movzbl (%eax),%eax
 6cd:	0f be c0             	movsbl %al,%eax
 6d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d4:	8b 45 08             	mov    0x8(%ebp),%eax
 6d7:	89 04 24             	mov    %eax,(%esp)
 6da:	e8 35 ff ff ff       	call   614 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6df:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e7:	79 db                	jns    6c4 <printint+0x88>
    putc(fd, buf[i]);
}
 6e9:	c9                   	leave  
 6ea:	c3                   	ret    

000006eb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6eb:	55                   	push   %ebp
 6ec:	89 e5                	mov    %esp,%ebp
 6ee:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6f8:	8d 45 0c             	lea    0xc(%ebp),%eax
 6fb:	83 c0 04             	add    $0x4,%eax
 6fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 701:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 708:	e9 7d 01 00 00       	jmp    88a <printf+0x19f>
    c = fmt[i] & 0xff;
 70d:	8b 55 0c             	mov    0xc(%ebp),%edx
 710:	8b 45 f0             	mov    -0x10(%ebp),%eax
 713:	01 d0                	add    %edx,%eax
 715:	0f b6 00             	movzbl (%eax),%eax
 718:	0f be c0             	movsbl %al,%eax
 71b:	25 ff 00 00 00       	and    $0xff,%eax
 720:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 723:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 727:	75 2c                	jne    755 <printf+0x6a>
      if(c == '%'){
 729:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 72d:	75 0c                	jne    73b <printf+0x50>
        state = '%';
 72f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 736:	e9 4b 01 00 00       	jmp    886 <printf+0x19b>
      } else {
        putc(fd, c);
 73b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73e:	0f be c0             	movsbl %al,%eax
 741:	89 44 24 04          	mov    %eax,0x4(%esp)
 745:	8b 45 08             	mov    0x8(%ebp),%eax
 748:	89 04 24             	mov    %eax,(%esp)
 74b:	e8 c4 fe ff ff       	call   614 <putc>
 750:	e9 31 01 00 00       	jmp    886 <printf+0x19b>
      }
    } else if(state == '%'){
 755:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 759:	0f 85 27 01 00 00    	jne    886 <printf+0x19b>
      if(c == 'd'){
 75f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 763:	75 2d                	jne    792 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 765:	8b 45 e8             	mov    -0x18(%ebp),%eax
 768:	8b 00                	mov    (%eax),%eax
 76a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 771:	00 
 772:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 779:	00 
 77a:	89 44 24 04          	mov    %eax,0x4(%esp)
 77e:	8b 45 08             	mov    0x8(%ebp),%eax
 781:	89 04 24             	mov    %eax,(%esp)
 784:	e8 b3 fe ff ff       	call   63c <printint>
        ap++;
 789:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 78d:	e9 ed 00 00 00       	jmp    87f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 792:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 796:	74 06                	je     79e <printf+0xb3>
 798:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 79c:	75 2d                	jne    7cb <printf+0xe0>
        printint(fd, *ap, 16, 0);
 79e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a1:	8b 00                	mov    (%eax),%eax
 7a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7aa:	00 
 7ab:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7b2:	00 
 7b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ba:	89 04 24             	mov    %eax,(%esp)
 7bd:	e8 7a fe ff ff       	call   63c <printint>
        ap++;
 7c2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c6:	e9 b4 00 00 00       	jmp    87f <printf+0x194>
      } else if(c == 's'){
 7cb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7cf:	75 46                	jne    817 <printf+0x12c>
        s = (char*)*ap;
 7d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e1:	75 27                	jne    80a <printf+0x11f>
          s = "(null)";
 7e3:	c7 45 f4 21 0b 00 00 	movl   $0xb21,-0xc(%ebp)
        while(*s != 0){
 7ea:	eb 1e                	jmp    80a <printf+0x11f>
          putc(fd, *s);
 7ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ef:	0f b6 00             	movzbl (%eax),%eax
 7f2:	0f be c0             	movsbl %al,%eax
 7f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f9:	8b 45 08             	mov    0x8(%ebp),%eax
 7fc:	89 04 24             	mov    %eax,(%esp)
 7ff:	e8 10 fe ff ff       	call   614 <putc>
          s++;
 804:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 808:	eb 01                	jmp    80b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 80a:	90                   	nop
 80b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80e:	0f b6 00             	movzbl (%eax),%eax
 811:	84 c0                	test   %al,%al
 813:	75 d7                	jne    7ec <printf+0x101>
 815:	eb 68                	jmp    87f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 817:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 81b:	75 1d                	jne    83a <printf+0x14f>
        putc(fd, *ap);
 81d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	0f be c0             	movsbl %al,%eax
 825:	89 44 24 04          	mov    %eax,0x4(%esp)
 829:	8b 45 08             	mov    0x8(%ebp),%eax
 82c:	89 04 24             	mov    %eax,(%esp)
 82f:	e8 e0 fd ff ff       	call   614 <putc>
        ap++;
 834:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 838:	eb 45                	jmp    87f <printf+0x194>
      } else if(c == '%'){
 83a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 83e:	75 17                	jne    857 <printf+0x16c>
        putc(fd, c);
 840:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 843:	0f be c0             	movsbl %al,%eax
 846:	89 44 24 04          	mov    %eax,0x4(%esp)
 84a:	8b 45 08             	mov    0x8(%ebp),%eax
 84d:	89 04 24             	mov    %eax,(%esp)
 850:	e8 bf fd ff ff       	call   614 <putc>
 855:	eb 28                	jmp    87f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 857:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 85e:	00 
 85f:	8b 45 08             	mov    0x8(%ebp),%eax
 862:	89 04 24             	mov    %eax,(%esp)
 865:	e8 aa fd ff ff       	call   614 <putc>
        putc(fd, c);
 86a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 86d:	0f be c0             	movsbl %al,%eax
 870:	89 44 24 04          	mov    %eax,0x4(%esp)
 874:	8b 45 08             	mov    0x8(%ebp),%eax
 877:	89 04 24             	mov    %eax,(%esp)
 87a:	e8 95 fd ff ff       	call   614 <putc>
      }
      state = 0;
 87f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 886:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 88a:	8b 55 0c             	mov    0xc(%ebp),%edx
 88d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 890:	01 d0                	add    %edx,%eax
 892:	0f b6 00             	movzbl (%eax),%eax
 895:	84 c0                	test   %al,%al
 897:	0f 85 70 fe ff ff    	jne    70d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 89d:	c9                   	leave  
 89e:	c3                   	ret    
 89f:	90                   	nop

000008a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a0:	55                   	push   %ebp
 8a1:	89 e5                	mov    %esp,%ebp
 8a3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a6:	8b 45 08             	mov    0x8(%ebp),%eax
 8a9:	83 e8 08             	sub    $0x8,%eax
 8ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8af:	a1 44 0e 00 00       	mov    0xe44,%eax
 8b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b7:	eb 24                	jmp    8dd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	8b 00                	mov    (%eax),%eax
 8be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c1:	77 12                	ja     8d5 <free+0x35>
 8c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c9:	77 24                	ja     8ef <free+0x4f>
 8cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ce:	8b 00                	mov    (%eax),%eax
 8d0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8d3:	77 1a                	ja     8ef <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d8:	8b 00                	mov    (%eax),%eax
 8da:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e3:	76 d4                	jbe    8b9 <free+0x19>
 8e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e8:	8b 00                	mov    (%eax),%eax
 8ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8ed:	76 ca                	jbe    8b9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f2:	8b 40 04             	mov    0x4(%eax),%eax
 8f5:	c1 e0 03             	shl    $0x3,%eax
 8f8:	89 c2                	mov    %eax,%edx
 8fa:	03 55 f8             	add    -0x8(%ebp),%edx
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	39 c2                	cmp    %eax,%edx
 904:	75 24                	jne    92a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 906:	8b 45 f8             	mov    -0x8(%ebp),%eax
 909:	8b 50 04             	mov    0x4(%eax),%edx
 90c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90f:	8b 00                	mov    (%eax),%eax
 911:	8b 40 04             	mov    0x4(%eax),%eax
 914:	01 c2                	add    %eax,%edx
 916:	8b 45 f8             	mov    -0x8(%ebp),%eax
 919:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 91c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91f:	8b 00                	mov    (%eax),%eax
 921:	8b 10                	mov    (%eax),%edx
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	89 10                	mov    %edx,(%eax)
 928:	eb 0a                	jmp    934 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 92a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92d:	8b 10                	mov    (%eax),%edx
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 40 04             	mov    0x4(%eax),%eax
 93a:	c1 e0 03             	shl    $0x3,%eax
 93d:	03 45 fc             	add    -0x4(%ebp),%eax
 940:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 943:	75 20                	jne    965 <free+0xc5>
    p->s.size += bp->s.size;
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 50 04             	mov    0x4(%eax),%edx
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	8b 40 04             	mov    0x4(%eax),%eax
 951:	01 c2                	add    %eax,%edx
 953:	8b 45 fc             	mov    -0x4(%ebp),%eax
 956:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 959:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95c:	8b 10                	mov    (%eax),%edx
 95e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 961:	89 10                	mov    %edx,(%eax)
 963:	eb 08                	jmp    96d <free+0xcd>
  } else
    p->s.ptr = bp;
 965:	8b 45 fc             	mov    -0x4(%ebp),%eax
 968:	8b 55 f8             	mov    -0x8(%ebp),%edx
 96b:	89 10                	mov    %edx,(%eax)
  freep = p;
 96d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 970:	a3 44 0e 00 00       	mov    %eax,0xe44
}
 975:	c9                   	leave  
 976:	c3                   	ret    

00000977 <morecore>:

static Header*
morecore(uint nu)
{
 977:	55                   	push   %ebp
 978:	89 e5                	mov    %esp,%ebp
 97a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 97d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 984:	77 07                	ja     98d <morecore+0x16>
    nu = 4096;
 986:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 98d:	8b 45 08             	mov    0x8(%ebp),%eax
 990:	c1 e0 03             	shl    $0x3,%eax
 993:	89 04 24             	mov    %eax,(%esp)
 996:	e8 61 fc ff ff       	call   5fc <sbrk>
 99b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 99e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9a2:	75 07                	jne    9ab <morecore+0x34>
    return 0;
 9a4:	b8 00 00 00 00       	mov    $0x0,%eax
 9a9:	eb 22                	jmp    9cd <morecore+0x56>
  hp = (Header*)p;
 9ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b4:	8b 55 08             	mov    0x8(%ebp),%edx
 9b7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bd:	83 c0 08             	add    $0x8,%eax
 9c0:	89 04 24             	mov    %eax,(%esp)
 9c3:	e8 d8 fe ff ff       	call   8a0 <free>
  return freep;
 9c8:	a1 44 0e 00 00       	mov    0xe44,%eax
}
 9cd:	c9                   	leave  
 9ce:	c3                   	ret    

000009cf <malloc>:

void*
malloc(uint nbytes)
{
 9cf:	55                   	push   %ebp
 9d0:	89 e5                	mov    %esp,%ebp
 9d2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9d5:	8b 45 08             	mov    0x8(%ebp),%eax
 9d8:	83 c0 07             	add    $0x7,%eax
 9db:	c1 e8 03             	shr    $0x3,%eax
 9de:	83 c0 01             	add    $0x1,%eax
 9e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9e4:	a1 44 0e 00 00       	mov    0xe44,%eax
 9e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9f0:	75 23                	jne    a15 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9f2:	c7 45 f0 3c 0e 00 00 	movl   $0xe3c,-0x10(%ebp)
 9f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fc:	a3 44 0e 00 00       	mov    %eax,0xe44
 a01:	a1 44 0e 00 00       	mov    0xe44,%eax
 a06:	a3 3c 0e 00 00       	mov    %eax,0xe3c
    base.s.size = 0;
 a0b:	c7 05 40 0e 00 00 00 	movl   $0x0,0xe40
 a12:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a18:	8b 00                	mov    (%eax),%eax
 a1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a20:	8b 40 04             	mov    0x4(%eax),%eax
 a23:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a26:	72 4d                	jb     a75 <malloc+0xa6>
      if(p->s.size == nunits)
 a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2b:	8b 40 04             	mov    0x4(%eax),%eax
 a2e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a31:	75 0c                	jne    a3f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a36:	8b 10                	mov    (%eax),%edx
 a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3b:	89 10                	mov    %edx,(%eax)
 a3d:	eb 26                	jmp    a65 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a42:	8b 40 04             	mov    0x4(%eax),%eax
 a45:	89 c2                	mov    %eax,%edx
 a47:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a53:	8b 40 04             	mov    0x4(%eax),%eax
 a56:	c1 e0 03             	shl    $0x3,%eax
 a59:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a62:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a68:	a3 44 0e 00 00       	mov    %eax,0xe44
      return (void*)(p + 1);
 a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a70:	83 c0 08             	add    $0x8,%eax
 a73:	eb 38                	jmp    aad <malloc+0xde>
    }
    if(p == freep)
 a75:	a1 44 0e 00 00       	mov    0xe44,%eax
 a7a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a7d:	75 1b                	jne    a9a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a82:	89 04 24             	mov    %eax,(%esp)
 a85:	e8 ed fe ff ff       	call   977 <morecore>
 a8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a91:	75 07                	jne    a9a <malloc+0xcb>
        return 0;
 a93:	b8 00 00 00 00       	mov    $0x0,%eax
 a98:	eb 13                	jmp    aad <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa3:	8b 00                	mov    (%eax),%eax
 aa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 aa8:	e9 70 ff ff ff       	jmp    a1d <malloc+0x4e>
}
 aad:	c9                   	leave  
 aae:	c3                   	ret    
