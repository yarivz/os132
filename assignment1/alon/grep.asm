
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
   d:	e9 bf 00 00 00       	jmp    d1 <grep+0xd1>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    p = buf;
  18:	c7 45 f0 80 10 00 00 	movl   $0x1080,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  1f:	eb 53                	jmp    74 <grep+0x74>
      *q = 0;
  21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  24:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  2e:	8b 45 08             	mov    0x8(%ebp),%eax
  31:	89 04 24             	mov    %eax,(%esp)
  34:	e8 c2 01 00 00       	call   1fb <match>
  39:	85 c0                	test   %eax,%eax
  3b:	74 2e                	je     6b <grep+0x6b>
        *q = '\n';
  3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  40:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  46:	83 c0 01             	add    $0x1,%eax
  49:	89 c2                	mov    %eax,%edx
  4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  4e:	89 d1                	mov    %edx,%ecx
  50:	29 c1                	sub    %eax,%ecx
  52:	89 c8                	mov    %ecx,%eax
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  66:	e8 31 07 00 00       	call   79c <write>
      }
      p = q+1;
  6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6e:	83 c0 01             	add    $0x1,%eax
  71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
    m += n;
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  74:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  7b:	00 
  7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  7f:	89 04 24             	mov    %eax,(%esp)
  82:	e8 c2 03 00 00       	call   449 <strchr>
  87:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8e:	75 91                	jne    21 <grep+0x21>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  90:	81 7d f0 80 10 00 00 	cmpl   $0x1080,-0x10(%ebp)
  97:	75 07                	jne    a0 <grep+0xa0>
      m = 0;
  99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a4:	7e 2b                	jle    d1 <grep+0xd1>
      m -= p - buf;
  a6:	ba 80 10 00 00       	mov    $0x1080,%edx
  ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ae:	89 d1                	mov    %edx,%ecx
  b0:	29 c1                	sub    %eax,%ecx
  b2:	89 c8                	mov    %ecx,%eax
  b4:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  c5:	c7 04 24 80 10 00 00 	movl   $0x1080,(%esp)
  cc:	e8 b7 04 00 00       	call   588 <memmove>
{
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
  d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d4:	ba 00 04 00 00       	mov    $0x400,%edx
  d9:	89 d1                	mov    %edx,%ecx
  db:	29 c1                	sub    %eax,%ecx
  dd:	89 c8                	mov    %ecx,%eax
  df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  e2:	81 c2 80 10 00 00    	add    $0x1080,%edx
  e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 04 24             	mov    %eax,(%esp)
  f6:	e8 99 06 00 00       	call   794 <read>
  fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 102:	0f 8f 0a ff ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}
 108:	c9                   	leave  
 109:	c3                   	ret    

0000010a <main>:

int
main(int argc, char *argv[])
{
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
 10d:	83 e4 f0             	and    $0xfffffff0,%esp
 110:	83 ec 20             	sub    $0x20,%esp
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 113:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 117:	7f 19                	jg     132 <main+0x28>
    printf(2, "usage: grep pattern [file ...]\n");
 119:	c7 44 24 04 cc 0c 00 	movl   $0xccc,0x4(%esp)
 120:	00 
 121:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 128:	e8 cc 07 00 00       	call   8f9 <printf>
    exit();
 12d:	e8 3a 06 00 00       	call   76c <exit>
  }
  pattern = argv[1];
 132:	8b 45 0c             	mov    0xc(%ebp),%eax
 135:	8b 40 04             	mov    0x4(%eax),%eax
 138:	89 44 24 18          	mov    %eax,0x18(%esp)
  
  if(argc <= 2){
 13c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 140:	7f 19                	jg     15b <main+0x51>
    grep(pattern, 0);
 142:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 149:	00 
 14a:	8b 44 24 18          	mov    0x18(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 aa fe ff ff       	call   0 <grep>
    exit();
 156:	e8 11 06 00 00       	call   76c <exit>
  }

  for(i = 2; i < argc; i++){
 15b:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 162:	00 
 163:	e9 81 00 00 00       	jmp    1e9 <main+0xdf>
    if((fd = open(argv[i], 0)) < 0){
 168:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 16c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 173:	8b 45 0c             	mov    0xc(%ebp),%eax
 176:	01 d0                	add    %edx,%eax
 178:	8b 00                	mov    (%eax),%eax
 17a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 181:	00 
 182:	89 04 24             	mov    %eax,(%esp)
 185:	e8 32 06 00 00       	call   7bc <open>
 18a:	89 44 24 14          	mov    %eax,0x14(%esp)
 18e:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 193:	79 2f                	jns    1c4 <main+0xba>
      printf(1, "grep: cannot open %s\n", argv[i]);
 195:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 199:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a3:	01 d0                	add    %edx,%eax
 1a5:	8b 00                	mov    (%eax),%eax
 1a7:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ab:	c7 44 24 04 ec 0c 00 	movl   $0xcec,0x4(%esp)
 1b2:	00 
 1b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ba:	e8 3a 07 00 00       	call   8f9 <printf>
      exit();
 1bf:	e8 a8 05 00 00       	call   76c <exit>
    }
    grep(pattern, fd);
 1c4:	8b 44 24 14          	mov    0x14(%esp),%eax
 1c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cc:	8b 44 24 18          	mov    0x18(%esp),%eax
 1d0:	89 04 24             	mov    %eax,(%esp)
 1d3:	e8 28 fe ff ff       	call   0 <grep>
    close(fd);
 1d8:	8b 44 24 14          	mov    0x14(%esp),%eax
 1dc:	89 04 24             	mov    %eax,(%esp)
 1df:	e8 c0 05 00 00       	call   7a4 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 1e4:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1e9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1ed:	3b 45 08             	cmp    0x8(%ebp),%eax
 1f0:	0f 8c 72 ff ff ff    	jl     168 <main+0x5e>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 1f6:	e8 71 05 00 00       	call   76c <exit>

000001fb <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1fb:	55                   	push   %ebp
 1fc:	89 e5                	mov    %esp,%ebp
 1fe:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	0f b6 00             	movzbl (%eax),%eax
 207:	3c 5e                	cmp    $0x5e,%al
 209:	75 17                	jne    222 <match+0x27>
    return matchhere(re+1, text);
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	8d 50 01             	lea    0x1(%eax),%edx
 211:	8b 45 0c             	mov    0xc(%ebp),%eax
 214:	89 44 24 04          	mov    %eax,0x4(%esp)
 218:	89 14 24             	mov    %edx,(%esp)
 21b:	e8 39 00 00 00       	call   259 <matchhere>
 220:	eb 35                	jmp    257 <match+0x5c>
  do{  // must look at empty string
    if(matchhere(re, text))
 222:	8b 45 0c             	mov    0xc(%ebp),%eax
 225:	89 44 24 04          	mov    %eax,0x4(%esp)
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	89 04 24             	mov    %eax,(%esp)
 22f:	e8 25 00 00 00       	call   259 <matchhere>
 234:	85 c0                	test   %eax,%eax
 236:	74 07                	je     23f <match+0x44>
      return 1;
 238:	b8 01 00 00 00       	mov    $0x1,%eax
 23d:	eb 18                	jmp    257 <match+0x5c>
  }while(*text++ != '\0');
 23f:	8b 45 0c             	mov    0xc(%ebp),%eax
 242:	0f b6 00             	movzbl (%eax),%eax
 245:	84 c0                	test   %al,%al
 247:	0f 95 c0             	setne  %al
 24a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 24e:	84 c0                	test   %al,%al
 250:	75 d0                	jne    222 <match+0x27>
  return 0;
 252:	b8 00 00 00 00       	mov    $0x0,%eax
}
 257:	c9                   	leave  
 258:	c3                   	ret    

00000259 <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 259:	55                   	push   %ebp
 25a:	89 e5                	mov    %esp,%ebp
 25c:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 25f:	8b 45 08             	mov    0x8(%ebp),%eax
 262:	0f b6 00             	movzbl (%eax),%eax
 265:	84 c0                	test   %al,%al
 267:	75 0a                	jne    273 <matchhere+0x1a>
    return 1;
 269:	b8 01 00 00 00       	mov    $0x1,%eax
 26e:	e9 9b 00 00 00       	jmp    30e <matchhere+0xb5>
  if(re[1] == '*')
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	83 c0 01             	add    $0x1,%eax
 279:	0f b6 00             	movzbl (%eax),%eax
 27c:	3c 2a                	cmp    $0x2a,%al
 27e:	75 24                	jne    2a4 <matchhere+0x4b>
    return matchstar(re[0], re+2, text);
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	8d 48 02             	lea    0x2(%eax),%ecx
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	0f b6 00             	movzbl (%eax),%eax
 28c:	0f be c0             	movsbl %al,%eax
 28f:	8b 55 0c             	mov    0xc(%ebp),%edx
 292:	89 54 24 08          	mov    %edx,0x8(%esp)
 296:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 6e 00 00 00       	call   310 <matchstar>
 2a2:	eb 6a                	jmp    30e <matchhere+0xb5>
  if(re[0] == '$' && re[1] == '\0')
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
 2a7:	0f b6 00             	movzbl (%eax),%eax
 2aa:	3c 24                	cmp    $0x24,%al
 2ac:	75 1d                	jne    2cb <matchhere+0x72>
 2ae:	8b 45 08             	mov    0x8(%ebp),%eax
 2b1:	83 c0 01             	add    $0x1,%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	84 c0                	test   %al,%al
 2b9:	75 10                	jne    2cb <matchhere+0x72>
    return *text == '\0';
 2bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2be:	0f b6 00             	movzbl (%eax),%eax
 2c1:	84 c0                	test   %al,%al
 2c3:	0f 94 c0             	sete   %al
 2c6:	0f b6 c0             	movzbl %al,%eax
 2c9:	eb 43                	jmp    30e <matchhere+0xb5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ce:	0f b6 00             	movzbl (%eax),%eax
 2d1:	84 c0                	test   %al,%al
 2d3:	74 34                	je     309 <matchhere+0xb0>
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	0f b6 00             	movzbl (%eax),%eax
 2db:	3c 2e                	cmp    $0x2e,%al
 2dd:	74 10                	je     2ef <matchhere+0x96>
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	0f b6 10             	movzbl (%eax),%edx
 2e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	38 c2                	cmp    %al,%dl
 2ed:	75 1a                	jne    309 <matchhere+0xb0>
    return matchhere(re+1, text+1);
 2ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f2:	8d 50 01             	lea    0x1(%eax),%edx
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	83 c0 01             	add    $0x1,%eax
 2fb:	89 54 24 04          	mov    %edx,0x4(%esp)
 2ff:	89 04 24             	mov    %eax,(%esp)
 302:	e8 52 ff ff ff       	call   259 <matchhere>
 307:	eb 05                	jmp    30e <matchhere+0xb5>
  return 0;
 309:	b8 00 00 00 00       	mov    $0x0,%eax
}
 30e:	c9                   	leave  
 30f:	c3                   	ret    

00000310 <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 310:	55                   	push   %ebp
 311:	89 e5                	mov    %esp,%ebp
 313:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 316:	8b 45 10             	mov    0x10(%ebp),%eax
 319:	89 44 24 04          	mov    %eax,0x4(%esp)
 31d:	8b 45 0c             	mov    0xc(%ebp),%eax
 320:	89 04 24             	mov    %eax,(%esp)
 323:	e8 31 ff ff ff       	call   259 <matchhere>
 328:	85 c0                	test   %eax,%eax
 32a:	74 07                	je     333 <matchstar+0x23>
      return 1;
 32c:	b8 01 00 00 00       	mov    $0x1,%eax
 331:	eb 2c                	jmp    35f <matchstar+0x4f>
  }while(*text!='\0' && (*text++==c || c=='.'));
 333:	8b 45 10             	mov    0x10(%ebp),%eax
 336:	0f b6 00             	movzbl (%eax),%eax
 339:	84 c0                	test   %al,%al
 33b:	74 1d                	je     35a <matchstar+0x4a>
 33d:	8b 45 10             	mov    0x10(%ebp),%eax
 340:	0f b6 00             	movzbl (%eax),%eax
 343:	0f be c0             	movsbl %al,%eax
 346:	3b 45 08             	cmp    0x8(%ebp),%eax
 349:	0f 94 c0             	sete   %al
 34c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
 350:	84 c0                	test   %al,%al
 352:	75 c2                	jne    316 <matchstar+0x6>
 354:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 358:	74 bc                	je     316 <matchstar+0x6>
  return 0;
 35a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 35f:	c9                   	leave  
 360:	c3                   	ret    
 361:	66 90                	xchg   %ax,%ax
 363:	90                   	nop

00000364 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
 367:	57                   	push   %edi
 368:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 369:	8b 4d 08             	mov    0x8(%ebp),%ecx
 36c:	8b 55 10             	mov    0x10(%ebp),%edx
 36f:	8b 45 0c             	mov    0xc(%ebp),%eax
 372:	89 cb                	mov    %ecx,%ebx
 374:	89 df                	mov    %ebx,%edi
 376:	89 d1                	mov    %edx,%ecx
 378:	fc                   	cld    
 379:	f3 aa                	rep stos %al,%es:(%edi)
 37b:	89 ca                	mov    %ecx,%edx
 37d:	89 fb                	mov    %edi,%ebx
 37f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 382:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 385:	5b                   	pop    %ebx
 386:	5f                   	pop    %edi
 387:	5d                   	pop    %ebp
 388:	c3                   	ret    

00000389 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 389:	55                   	push   %ebp
 38a:	89 e5                	mov    %esp,%ebp
 38c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 38f:	8b 45 08             	mov    0x8(%ebp),%eax
 392:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 395:	90                   	nop
 396:	8b 45 0c             	mov    0xc(%ebp),%eax
 399:	0f b6 10             	movzbl (%eax),%edx
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
 39f:	88 10                	mov    %dl,(%eax)
 3a1:	8b 45 08             	mov    0x8(%ebp),%eax
 3a4:	0f b6 00             	movzbl (%eax),%eax
 3a7:	84 c0                	test   %al,%al
 3a9:	0f 95 c0             	setne  %al
 3ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3b4:	84 c0                	test   %al,%al
 3b6:	75 de                	jne    396 <strcpy+0xd>
    ;
  return os;
 3b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3bb:	c9                   	leave  
 3bc:	c3                   	ret    

000003bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3bd:	55                   	push   %ebp
 3be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3c0:	eb 08                	jmp    3ca <strcmp+0xd>
    p++, q++;
 3c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3ca:	8b 45 08             	mov    0x8(%ebp),%eax
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	84 c0                	test   %al,%al
 3d2:	74 10                	je     3e4 <strcmp+0x27>
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	0f b6 10             	movzbl (%eax),%edx
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	0f b6 00             	movzbl (%eax),%eax
 3e0:	38 c2                	cmp    %al,%dl
 3e2:	74 de                	je     3c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3e4:	8b 45 08             	mov    0x8(%ebp),%eax
 3e7:	0f b6 00             	movzbl (%eax),%eax
 3ea:	0f b6 d0             	movzbl %al,%edx
 3ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f0:	0f b6 00             	movzbl (%eax),%eax
 3f3:	0f b6 c0             	movzbl %al,%eax
 3f6:	89 d1                	mov    %edx,%ecx
 3f8:	29 c1                	sub    %eax,%ecx
 3fa:	89 c8                	mov    %ecx,%eax
}
 3fc:	5d                   	pop    %ebp
 3fd:	c3                   	ret    

000003fe <strlen>:

uint
strlen(char *s)
{
 3fe:	55                   	push   %ebp
 3ff:	89 e5                	mov    %esp,%ebp
 401:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 404:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 40b:	eb 04                	jmp    411 <strlen+0x13>
 40d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 411:	8b 55 fc             	mov    -0x4(%ebp),%edx
 414:	8b 45 08             	mov    0x8(%ebp),%eax
 417:	01 d0                	add    %edx,%eax
 419:	0f b6 00             	movzbl (%eax),%eax
 41c:	84 c0                	test   %al,%al
 41e:	75 ed                	jne    40d <strlen+0xf>
  return n;
 420:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 423:	c9                   	leave  
 424:	c3                   	ret    

00000425 <memset>:

void*
memset(void *dst, int c, uint n)
{
 425:	55                   	push   %ebp
 426:	89 e5                	mov    %esp,%ebp
 428:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 42b:	8b 45 10             	mov    0x10(%ebp),%eax
 42e:	89 44 24 08          	mov    %eax,0x8(%esp)
 432:	8b 45 0c             	mov    0xc(%ebp),%eax
 435:	89 44 24 04          	mov    %eax,0x4(%esp)
 439:	8b 45 08             	mov    0x8(%ebp),%eax
 43c:	89 04 24             	mov    %eax,(%esp)
 43f:	e8 20 ff ff ff       	call   364 <stosb>
  return dst;
 444:	8b 45 08             	mov    0x8(%ebp),%eax
}
 447:	c9                   	leave  
 448:	c3                   	ret    

00000449 <strchr>:

char*
strchr(const char *s, char c)
{
 449:	55                   	push   %ebp
 44a:	89 e5                	mov    %esp,%ebp
 44c:	83 ec 04             	sub    $0x4,%esp
 44f:	8b 45 0c             	mov    0xc(%ebp),%eax
 452:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 455:	eb 14                	jmp    46b <strchr+0x22>
    if(*s == c)
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	0f b6 00             	movzbl (%eax),%eax
 45d:	3a 45 fc             	cmp    -0x4(%ebp),%al
 460:	75 05                	jne    467 <strchr+0x1e>
      return (char*)s;
 462:	8b 45 08             	mov    0x8(%ebp),%eax
 465:	eb 13                	jmp    47a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 467:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	0f b6 00             	movzbl (%eax),%eax
 471:	84 c0                	test   %al,%al
 473:	75 e2                	jne    457 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 475:	b8 00 00 00 00       	mov    $0x0,%eax
}
 47a:	c9                   	leave  
 47b:	c3                   	ret    

0000047c <gets>:

char*
gets(char *buf, int max)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 482:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 489:	eb 46                	jmp    4d1 <gets+0x55>
    cc = read(0, &c, 1);
 48b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 492:	00 
 493:	8d 45 ef             	lea    -0x11(%ebp),%eax
 496:	89 44 24 04          	mov    %eax,0x4(%esp)
 49a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4a1:	e8 ee 02 00 00       	call   794 <read>
 4a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ad:	7e 2f                	jle    4de <gets+0x62>
      break;
    buf[i++] = c;
 4af:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4b2:	8b 45 08             	mov    0x8(%ebp),%eax
 4b5:	01 c2                	add    %eax,%edx
 4b7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4bb:	88 02                	mov    %al,(%edx)
 4bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c5:	3c 0a                	cmp    $0xa,%al
 4c7:	74 16                	je     4df <gets+0x63>
 4c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4cd:	3c 0d                	cmp    $0xd,%al
 4cf:	74 0e                	je     4df <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d4:	83 c0 01             	add    $0x1,%eax
 4d7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4da:	7c af                	jl     48b <gets+0xf>
 4dc:	eb 01                	jmp    4df <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4de:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4df:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4e2:	8b 45 08             	mov    0x8(%ebp),%eax
 4e5:	01 d0                	add    %edx,%eax
 4e7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4ed:	c9                   	leave  
 4ee:	c3                   	ret    

000004ef <stat>:

int
stat(char *n, struct stat *st)
{
 4ef:	55                   	push   %ebp
 4f0:	89 e5                	mov    %esp,%ebp
 4f2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4fc:	00 
 4fd:	8b 45 08             	mov    0x8(%ebp),%eax
 500:	89 04 24             	mov    %eax,(%esp)
 503:	e8 b4 02 00 00       	call   7bc <open>
 508:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 50b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 50f:	79 07                	jns    518 <stat+0x29>
    return -1;
 511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 516:	eb 23                	jmp    53b <stat+0x4c>
  r = fstat(fd, st);
 518:	8b 45 0c             	mov    0xc(%ebp),%eax
 51b:	89 44 24 04          	mov    %eax,0x4(%esp)
 51f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 522:	89 04 24             	mov    %eax,(%esp)
 525:	e8 aa 02 00 00       	call   7d4 <fstat>
 52a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 52d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 530:	89 04 24             	mov    %eax,(%esp)
 533:	e8 6c 02 00 00       	call   7a4 <close>
  return r;
 538:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 53b:	c9                   	leave  
 53c:	c3                   	ret    

0000053d <atoi>:

int
atoi(const char *s)
{
 53d:	55                   	push   %ebp
 53e:	89 e5                	mov    %esp,%ebp
 540:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 543:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 54a:	eb 23                	jmp    56f <atoi+0x32>
    n = n*10 + *s++ - '0';
 54c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 54f:	89 d0                	mov    %edx,%eax
 551:	c1 e0 02             	shl    $0x2,%eax
 554:	01 d0                	add    %edx,%eax
 556:	01 c0                	add    %eax,%eax
 558:	89 c2                	mov    %eax,%edx
 55a:	8b 45 08             	mov    0x8(%ebp),%eax
 55d:	0f b6 00             	movzbl (%eax),%eax
 560:	0f be c0             	movsbl %al,%eax
 563:	01 d0                	add    %edx,%eax
 565:	83 e8 30             	sub    $0x30,%eax
 568:	89 45 fc             	mov    %eax,-0x4(%ebp)
 56b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 56f:	8b 45 08             	mov    0x8(%ebp),%eax
 572:	0f b6 00             	movzbl (%eax),%eax
 575:	3c 2f                	cmp    $0x2f,%al
 577:	7e 0a                	jle    583 <atoi+0x46>
 579:	8b 45 08             	mov    0x8(%ebp),%eax
 57c:	0f b6 00             	movzbl (%eax),%eax
 57f:	3c 39                	cmp    $0x39,%al
 581:	7e c9                	jle    54c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 583:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 586:	c9                   	leave  
 587:	c3                   	ret    

00000588 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 588:	55                   	push   %ebp
 589:	89 e5                	mov    %esp,%ebp
 58b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 58e:	8b 45 08             	mov    0x8(%ebp),%eax
 591:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 594:	8b 45 0c             	mov    0xc(%ebp),%eax
 597:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 59a:	eb 13                	jmp    5af <memmove+0x27>
    *dst++ = *src++;
 59c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 59f:	0f b6 10             	movzbl (%eax),%edx
 5a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5a5:	88 10                	mov    %dl,(%eax)
 5a7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5ab:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 5b3:	0f 9f c0             	setg   %al
 5b6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5ba:	84 c0                	test   %al,%al
 5bc:	75 de                	jne    59c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5c1:	c9                   	leave  
 5c2:	c3                   	ret    

000005c3 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 5c3:	55                   	push   %ebp
 5c4:	89 e5                	mov    %esp,%ebp
 5c6:	83 ec 38             	sub    $0x38,%esp
 5c9:	8b 45 10             	mov    0x10(%ebp),%eax
 5cc:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 5cf:	8b 45 14             	mov    0x14(%ebp),%eax
 5d2:	8b 00                	mov    (%eax),%eax
 5d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 5de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5e2:	74 06                	je     5ea <strtok+0x27>
 5e4:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 5e8:	75 5a                	jne    644 <strtok+0x81>
    return match;
 5ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ed:	eb 76                	jmp    665 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 5ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f5:	01 d0                	add    %edx,%eax
 5f7:	0f b6 00             	movzbl (%eax),%eax
 5fa:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 5fd:	74 06                	je     605 <strtok+0x42>
      {
	index++;
 5ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 603:	eb 40                	jmp    645 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 605:	8b 45 14             	mov    0x14(%ebp),%eax
 608:	8b 00                	mov    (%eax),%eax
 60a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 60d:	29 c2                	sub    %eax,%edx
 60f:	8b 45 14             	mov    0x14(%ebp),%eax
 612:	8b 00                	mov    (%eax),%eax
 614:	89 c1                	mov    %eax,%ecx
 616:	8b 45 0c             	mov    0xc(%ebp),%eax
 619:	01 c8                	add    %ecx,%eax
 61b:	89 54 24 08          	mov    %edx,0x8(%esp)
 61f:	89 44 24 04          	mov    %eax,0x4(%esp)
 623:	8b 45 08             	mov    0x8(%ebp),%eax
 626:	89 04 24             	mov    %eax,(%esp)
 629:	e8 39 00 00 00       	call   667 <strncpy>
 62e:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 631:	8b 45 08             	mov    0x8(%ebp),%eax
 634:	0f b6 00             	movzbl (%eax),%eax
 637:	84 c0                	test   %al,%al
 639:	74 1b                	je     656 <strtok+0x93>
	  match = 1;
 63b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 642:	eb 12                	jmp    656 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 644:	90                   	nop
 645:	8b 55 f4             	mov    -0xc(%ebp),%edx
 648:	8b 45 0c             	mov    0xc(%ebp),%eax
 64b:	01 d0                	add    %edx,%eax
 64d:	0f b6 00             	movzbl (%eax),%eax
 650:	84 c0                	test   %al,%al
 652:	75 9b                	jne    5ef <strtok+0x2c>
 654:	eb 01                	jmp    657 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 656:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 657:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65a:	8d 50 01             	lea    0x1(%eax),%edx
 65d:	8b 45 14             	mov    0x14(%ebp),%eax
 660:	89 10                	mov    %edx,(%eax)
  return match;
 662:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 665:	c9                   	leave  
 666:	c3                   	ret    

00000667 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 667:	55                   	push   %ebp
 668:	89 e5                	mov    %esp,%ebp
 66a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 66d:	8b 45 08             	mov    0x8(%ebp),%eax
 670:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 673:	90                   	nop
 674:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 678:	0f 9f c0             	setg   %al
 67b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 67f:	84 c0                	test   %al,%al
 681:	74 30                	je     6b3 <strncpy+0x4c>
 683:	8b 45 0c             	mov    0xc(%ebp),%eax
 686:	0f b6 10             	movzbl (%eax),%edx
 689:	8b 45 08             	mov    0x8(%ebp),%eax
 68c:	88 10                	mov    %dl,(%eax)
 68e:	8b 45 08             	mov    0x8(%ebp),%eax
 691:	0f b6 00             	movzbl (%eax),%eax
 694:	84 c0                	test   %al,%al
 696:	0f 95 c0             	setne  %al
 699:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 69d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 6a1:	84 c0                	test   %al,%al
 6a3:	75 cf                	jne    674 <strncpy+0xd>
    ;
  while(n-- > 0)
 6a5:	eb 0c                	jmp    6b3 <strncpy+0x4c>
    *s++ = 0;
 6a7:	8b 45 08             	mov    0x8(%ebp),%eax
 6aa:	c6 00 00             	movb   $0x0,(%eax)
 6ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6b1:	eb 01                	jmp    6b4 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 6b3:	90                   	nop
 6b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6b8:	0f 9f c0             	setg   %al
 6bb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6bf:	84 c0                	test   %al,%al
 6c1:	75 e4                	jne    6a7 <strncpy+0x40>
    *s++ = 0;
  return os;
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6c6:	c9                   	leave  
 6c7:	c3                   	ret    

000006c8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 6c8:	55                   	push   %ebp
 6c9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 6cb:	eb 0c                	jmp    6d9 <strncmp+0x11>
    n--, p++, q++;
 6cd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6d1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6d5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 6d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6dd:	74 1a                	je     6f9 <strncmp+0x31>
 6df:	8b 45 08             	mov    0x8(%ebp),%eax
 6e2:	0f b6 00             	movzbl (%eax),%eax
 6e5:	84 c0                	test   %al,%al
 6e7:	74 10                	je     6f9 <strncmp+0x31>
 6e9:	8b 45 08             	mov    0x8(%ebp),%eax
 6ec:	0f b6 10             	movzbl (%eax),%edx
 6ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 6f2:	0f b6 00             	movzbl (%eax),%eax
 6f5:	38 c2                	cmp    %al,%dl
 6f7:	74 d4                	je     6cd <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 6f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6fd:	75 07                	jne    706 <strncmp+0x3e>
    return 0;
 6ff:	b8 00 00 00 00       	mov    $0x0,%eax
 704:	eb 18                	jmp    71e <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	0f b6 00             	movzbl (%eax),%eax
 70c:	0f b6 d0             	movzbl %al,%edx
 70f:	8b 45 0c             	mov    0xc(%ebp),%eax
 712:	0f b6 00             	movzbl (%eax),%eax
 715:	0f b6 c0             	movzbl %al,%eax
 718:	89 d1                	mov    %edx,%ecx
 71a:	29 c1                	sub    %eax,%ecx
 71c:	89 c8                	mov    %ecx,%eax
}
 71e:	5d                   	pop    %ebp
 71f:	c3                   	ret    

00000720 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 720:	55                   	push   %ebp
 721:	89 e5                	mov    %esp,%ebp
  while(*p){
 723:	eb 13                	jmp    738 <strcat+0x18>
    *dest++ = *p++;
 725:	8b 45 0c             	mov    0xc(%ebp),%eax
 728:	0f b6 10             	movzbl (%eax),%edx
 72b:	8b 45 08             	mov    0x8(%ebp),%eax
 72e:	88 10                	mov    %dl,(%eax)
 730:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 734:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 738:	8b 45 0c             	mov    0xc(%ebp),%eax
 73b:	0f b6 00             	movzbl (%eax),%eax
 73e:	84 c0                	test   %al,%al
 740:	75 e3                	jne    725 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 742:	eb 13                	jmp    757 <strcat+0x37>
    *dest++ = *q++;
 744:	8b 45 10             	mov    0x10(%ebp),%eax
 747:	0f b6 10             	movzbl (%eax),%edx
 74a:	8b 45 08             	mov    0x8(%ebp),%eax
 74d:	88 10                	mov    %dl,(%eax)
 74f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 753:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 757:	8b 45 10             	mov    0x10(%ebp),%eax
 75a:	0f b6 00             	movzbl (%eax),%eax
 75d:	84 c0                	test   %al,%al
 75f:	75 e3                	jne    744 <strcat+0x24>
    *dest++ = *q++;
  }  
 761:	5d                   	pop    %ebp
 762:	c3                   	ret    
 763:	90                   	nop

00000764 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 764:	b8 01 00 00 00       	mov    $0x1,%eax
 769:	cd 40                	int    $0x40
 76b:	c3                   	ret    

0000076c <exit>:
SYSCALL(exit)
 76c:	b8 02 00 00 00       	mov    $0x2,%eax
 771:	cd 40                	int    $0x40
 773:	c3                   	ret    

00000774 <wait>:
SYSCALL(wait)
 774:	b8 03 00 00 00       	mov    $0x3,%eax
 779:	cd 40                	int    $0x40
 77b:	c3                   	ret    

0000077c <wait2>:
SYSCALL(wait2)
 77c:	b8 16 00 00 00       	mov    $0x16,%eax
 781:	cd 40                	int    $0x40
 783:	c3                   	ret    

00000784 <nice>:
SYSCALL(nice)
 784:	b8 17 00 00 00       	mov    $0x17,%eax
 789:	cd 40                	int    $0x40
 78b:	c3                   	ret    

0000078c <pipe>:
SYSCALL(pipe)
 78c:	b8 04 00 00 00       	mov    $0x4,%eax
 791:	cd 40                	int    $0x40
 793:	c3                   	ret    

00000794 <read>:
SYSCALL(read)
 794:	b8 05 00 00 00       	mov    $0x5,%eax
 799:	cd 40                	int    $0x40
 79b:	c3                   	ret    

0000079c <write>:
SYSCALL(write)
 79c:	b8 10 00 00 00       	mov    $0x10,%eax
 7a1:	cd 40                	int    $0x40
 7a3:	c3                   	ret    

000007a4 <close>:
SYSCALL(close)
 7a4:	b8 15 00 00 00       	mov    $0x15,%eax
 7a9:	cd 40                	int    $0x40
 7ab:	c3                   	ret    

000007ac <kill>:
SYSCALL(kill)
 7ac:	b8 06 00 00 00       	mov    $0x6,%eax
 7b1:	cd 40                	int    $0x40
 7b3:	c3                   	ret    

000007b4 <exec>:
SYSCALL(exec)
 7b4:	b8 07 00 00 00       	mov    $0x7,%eax
 7b9:	cd 40                	int    $0x40
 7bb:	c3                   	ret    

000007bc <open>:
SYSCALL(open)
 7bc:	b8 0f 00 00 00       	mov    $0xf,%eax
 7c1:	cd 40                	int    $0x40
 7c3:	c3                   	ret    

000007c4 <mknod>:
SYSCALL(mknod)
 7c4:	b8 11 00 00 00       	mov    $0x11,%eax
 7c9:	cd 40                	int    $0x40
 7cb:	c3                   	ret    

000007cc <unlink>:
SYSCALL(unlink)
 7cc:	b8 12 00 00 00       	mov    $0x12,%eax
 7d1:	cd 40                	int    $0x40
 7d3:	c3                   	ret    

000007d4 <fstat>:
SYSCALL(fstat)
 7d4:	b8 08 00 00 00       	mov    $0x8,%eax
 7d9:	cd 40                	int    $0x40
 7db:	c3                   	ret    

000007dc <link>:
SYSCALL(link)
 7dc:	b8 13 00 00 00       	mov    $0x13,%eax
 7e1:	cd 40                	int    $0x40
 7e3:	c3                   	ret    

000007e4 <mkdir>:
SYSCALL(mkdir)
 7e4:	b8 14 00 00 00       	mov    $0x14,%eax
 7e9:	cd 40                	int    $0x40
 7eb:	c3                   	ret    

000007ec <chdir>:
SYSCALL(chdir)
 7ec:	b8 09 00 00 00       	mov    $0x9,%eax
 7f1:	cd 40                	int    $0x40
 7f3:	c3                   	ret    

000007f4 <dup>:
SYSCALL(dup)
 7f4:	b8 0a 00 00 00       	mov    $0xa,%eax
 7f9:	cd 40                	int    $0x40
 7fb:	c3                   	ret    

000007fc <getpid>:
SYSCALL(getpid)
 7fc:	b8 0b 00 00 00       	mov    $0xb,%eax
 801:	cd 40                	int    $0x40
 803:	c3                   	ret    

00000804 <sbrk>:
SYSCALL(sbrk)
 804:	b8 0c 00 00 00       	mov    $0xc,%eax
 809:	cd 40                	int    $0x40
 80b:	c3                   	ret    

0000080c <sleep>:
SYSCALL(sleep)
 80c:	b8 0d 00 00 00       	mov    $0xd,%eax
 811:	cd 40                	int    $0x40
 813:	c3                   	ret    

00000814 <uptime>:
SYSCALL(uptime)
 814:	b8 0e 00 00 00       	mov    $0xe,%eax
 819:	cd 40                	int    $0x40
 81b:	c3                   	ret    

0000081c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 81c:	55                   	push   %ebp
 81d:	89 e5                	mov    %esp,%ebp
 81f:	83 ec 28             	sub    $0x28,%esp
 822:	8b 45 0c             	mov    0xc(%ebp),%eax
 825:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 828:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 82f:	00 
 830:	8d 45 f4             	lea    -0xc(%ebp),%eax
 833:	89 44 24 04          	mov    %eax,0x4(%esp)
 837:	8b 45 08             	mov    0x8(%ebp),%eax
 83a:	89 04 24             	mov    %eax,(%esp)
 83d:	e8 5a ff ff ff       	call   79c <write>
}
 842:	c9                   	leave  
 843:	c3                   	ret    

00000844 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 844:	55                   	push   %ebp
 845:	89 e5                	mov    %esp,%ebp
 847:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 84a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 851:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 855:	74 17                	je     86e <printint+0x2a>
 857:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 85b:	79 11                	jns    86e <printint+0x2a>
    neg = 1;
 85d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 864:	8b 45 0c             	mov    0xc(%ebp),%eax
 867:	f7 d8                	neg    %eax
 869:	89 45 ec             	mov    %eax,-0x14(%ebp)
 86c:	eb 06                	jmp    874 <printint+0x30>
  } else {
    x = xx;
 86e:	8b 45 0c             	mov    0xc(%ebp),%eax
 871:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 874:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 87b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 87e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 881:	ba 00 00 00 00       	mov    $0x0,%edx
 886:	f7 f1                	div    %ecx
 888:	89 d0                	mov    %edx,%eax
 88a:	0f b6 80 48 10 00 00 	movzbl 0x1048(%eax),%eax
 891:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 894:	8b 55 f4             	mov    -0xc(%ebp),%edx
 897:	01 ca                	add    %ecx,%edx
 899:	88 02                	mov    %al,(%edx)
 89b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 89f:	8b 55 10             	mov    0x10(%ebp),%edx
 8a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 8a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a8:	ba 00 00 00 00       	mov    $0x0,%edx
 8ad:	f7 75 d4             	divl   -0x2c(%ebp)
 8b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8b7:	75 c2                	jne    87b <printint+0x37>
  if(neg)
 8b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8bd:	74 2e                	je     8ed <printint+0xa9>
    buf[i++] = '-';
 8bf:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	01 d0                	add    %edx,%eax
 8c7:	c6 00 2d             	movb   $0x2d,(%eax)
 8ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 8ce:	eb 1d                	jmp    8ed <printint+0xa9>
    putc(fd, buf[i]);
 8d0:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d6:	01 d0                	add    %edx,%eax
 8d8:	0f b6 00             	movzbl (%eax),%eax
 8db:	0f be c0             	movsbl %al,%eax
 8de:	89 44 24 04          	mov    %eax,0x4(%esp)
 8e2:	8b 45 08             	mov    0x8(%ebp),%eax
 8e5:	89 04 24             	mov    %eax,(%esp)
 8e8:	e8 2f ff ff ff       	call   81c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 8ed:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8f5:	79 d9                	jns    8d0 <printint+0x8c>
    putc(fd, buf[i]);
}
 8f7:	c9                   	leave  
 8f8:	c3                   	ret    

000008f9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 8f9:	55                   	push   %ebp
 8fa:	89 e5                	mov    %esp,%ebp
 8fc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 906:	8d 45 0c             	lea    0xc(%ebp),%eax
 909:	83 c0 04             	add    $0x4,%eax
 90c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 90f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 916:	e9 7d 01 00 00       	jmp    a98 <printf+0x19f>
    c = fmt[i] & 0xff;
 91b:	8b 55 0c             	mov    0xc(%ebp),%edx
 91e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 921:	01 d0                	add    %edx,%eax
 923:	0f b6 00             	movzbl (%eax),%eax
 926:	0f be c0             	movsbl %al,%eax
 929:	25 ff 00 00 00       	and    $0xff,%eax
 92e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 931:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 935:	75 2c                	jne    963 <printf+0x6a>
      if(c == '%'){
 937:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 93b:	75 0c                	jne    949 <printf+0x50>
        state = '%';
 93d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 944:	e9 4b 01 00 00       	jmp    a94 <printf+0x19b>
      } else {
        putc(fd, c);
 949:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 94c:	0f be c0             	movsbl %al,%eax
 94f:	89 44 24 04          	mov    %eax,0x4(%esp)
 953:	8b 45 08             	mov    0x8(%ebp),%eax
 956:	89 04 24             	mov    %eax,(%esp)
 959:	e8 be fe ff ff       	call   81c <putc>
 95e:	e9 31 01 00 00       	jmp    a94 <printf+0x19b>
      }
    } else if(state == '%'){
 963:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 967:	0f 85 27 01 00 00    	jne    a94 <printf+0x19b>
      if(c == 'd'){
 96d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 971:	75 2d                	jne    9a0 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 973:	8b 45 e8             	mov    -0x18(%ebp),%eax
 976:	8b 00                	mov    (%eax),%eax
 978:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 97f:	00 
 980:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 987:	00 
 988:	89 44 24 04          	mov    %eax,0x4(%esp)
 98c:	8b 45 08             	mov    0x8(%ebp),%eax
 98f:	89 04 24             	mov    %eax,(%esp)
 992:	e8 ad fe ff ff       	call   844 <printint>
        ap++;
 997:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 99b:	e9 ed 00 00 00       	jmp    a8d <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 9a0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9a4:	74 06                	je     9ac <printf+0xb3>
 9a6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9aa:	75 2d                	jne    9d9 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 9ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9af:	8b 00                	mov    (%eax),%eax
 9b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 9b8:	00 
 9b9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 9c0:	00 
 9c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 9c5:	8b 45 08             	mov    0x8(%ebp),%eax
 9c8:	89 04 24             	mov    %eax,(%esp)
 9cb:	e8 74 fe ff ff       	call   844 <printint>
        ap++;
 9d0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9d4:	e9 b4 00 00 00       	jmp    a8d <printf+0x194>
      } else if(c == 's'){
 9d9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9dd:	75 46                	jne    a25 <printf+0x12c>
        s = (char*)*ap;
 9df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9e2:	8b 00                	mov    (%eax),%eax
 9e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9e7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9ef:	75 27                	jne    a18 <printf+0x11f>
          s = "(null)";
 9f1:	c7 45 f4 02 0d 00 00 	movl   $0xd02,-0xc(%ebp)
        while(*s != 0){
 9f8:	eb 1e                	jmp    a18 <printf+0x11f>
          putc(fd, *s);
 9fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fd:	0f b6 00             	movzbl (%eax),%eax
 a00:	0f be c0             	movsbl %al,%eax
 a03:	89 44 24 04          	mov    %eax,0x4(%esp)
 a07:	8b 45 08             	mov    0x8(%ebp),%eax
 a0a:	89 04 24             	mov    %eax,(%esp)
 a0d:	e8 0a fe ff ff       	call   81c <putc>
          s++;
 a12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 a16:	eb 01                	jmp    a19 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a18:	90                   	nop
 a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1c:	0f b6 00             	movzbl (%eax),%eax
 a1f:	84 c0                	test   %al,%al
 a21:	75 d7                	jne    9fa <printf+0x101>
 a23:	eb 68                	jmp    a8d <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a25:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a29:	75 1d                	jne    a48 <printf+0x14f>
        putc(fd, *ap);
 a2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a2e:	8b 00                	mov    (%eax),%eax
 a30:	0f be c0             	movsbl %al,%eax
 a33:	89 44 24 04          	mov    %eax,0x4(%esp)
 a37:	8b 45 08             	mov    0x8(%ebp),%eax
 a3a:	89 04 24             	mov    %eax,(%esp)
 a3d:	e8 da fd ff ff       	call   81c <putc>
        ap++;
 a42:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a46:	eb 45                	jmp    a8d <printf+0x194>
      } else if(c == '%'){
 a48:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a4c:	75 17                	jne    a65 <printf+0x16c>
        putc(fd, c);
 a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a51:	0f be c0             	movsbl %al,%eax
 a54:	89 44 24 04          	mov    %eax,0x4(%esp)
 a58:	8b 45 08             	mov    0x8(%ebp),%eax
 a5b:	89 04 24             	mov    %eax,(%esp)
 a5e:	e8 b9 fd ff ff       	call   81c <putc>
 a63:	eb 28                	jmp    a8d <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a65:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a6c:	00 
 a6d:	8b 45 08             	mov    0x8(%ebp),%eax
 a70:	89 04 24             	mov    %eax,(%esp)
 a73:	e8 a4 fd ff ff       	call   81c <putc>
        putc(fd, c);
 a78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a7b:	0f be c0             	movsbl %al,%eax
 a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
 a82:	8b 45 08             	mov    0x8(%ebp),%eax
 a85:	89 04 24             	mov    %eax,(%esp)
 a88:	e8 8f fd ff ff       	call   81c <putc>
      }
      state = 0;
 a8d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 a94:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a98:	8b 55 0c             	mov    0xc(%ebp),%edx
 a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a9e:	01 d0                	add    %edx,%eax
 aa0:	0f b6 00             	movzbl (%eax),%eax
 aa3:	84 c0                	test   %al,%al
 aa5:	0f 85 70 fe ff ff    	jne    91b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 aab:	c9                   	leave  
 aac:	c3                   	ret    
 aad:	66 90                	xchg   %ax,%ax
 aaf:	90                   	nop

00000ab0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ab0:	55                   	push   %ebp
 ab1:	89 e5                	mov    %esp,%ebp
 ab3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ab6:	8b 45 08             	mov    0x8(%ebp),%eax
 ab9:	83 e8 08             	sub    $0x8,%eax
 abc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 abf:	a1 68 10 00 00       	mov    0x1068,%eax
 ac4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ac7:	eb 24                	jmp    aed <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ac9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 acc:	8b 00                	mov    (%eax),%eax
 ace:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ad1:	77 12                	ja     ae5 <free+0x35>
 ad3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ad9:	77 24                	ja     aff <free+0x4f>
 adb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ade:	8b 00                	mov    (%eax),%eax
 ae0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ae3:	77 1a                	ja     aff <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ae5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae8:	8b 00                	mov    (%eax),%eax
 aea:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 af0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 af3:	76 d4                	jbe    ac9 <free+0x19>
 af5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af8:	8b 00                	mov    (%eax),%eax
 afa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 afd:	76 ca                	jbe    ac9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 aff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b02:	8b 40 04             	mov    0x4(%eax),%eax
 b05:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b0f:	01 c2                	add    %eax,%edx
 b11:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b14:	8b 00                	mov    (%eax),%eax
 b16:	39 c2                	cmp    %eax,%edx
 b18:	75 24                	jne    b3e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b1d:	8b 50 04             	mov    0x4(%eax),%edx
 b20:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b23:	8b 00                	mov    (%eax),%eax
 b25:	8b 40 04             	mov    0x4(%eax),%eax
 b28:	01 c2                	add    %eax,%edx
 b2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b2d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b30:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b33:	8b 00                	mov    (%eax),%eax
 b35:	8b 10                	mov    (%eax),%edx
 b37:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3a:	89 10                	mov    %edx,(%eax)
 b3c:	eb 0a                	jmp    b48 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b41:	8b 10                	mov    (%eax),%edx
 b43:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b46:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b48:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4b:	8b 40 04             	mov    0x4(%eax),%eax
 b4e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b58:	01 d0                	add    %edx,%eax
 b5a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b5d:	75 20                	jne    b7f <free+0xcf>
    p->s.size += bp->s.size;
 b5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b62:	8b 50 04             	mov    0x4(%eax),%edx
 b65:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b68:	8b 40 04             	mov    0x4(%eax),%eax
 b6b:	01 c2                	add    %eax,%edx
 b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b70:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b73:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b76:	8b 10                	mov    (%eax),%edx
 b78:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7b:	89 10                	mov    %edx,(%eax)
 b7d:	eb 08                	jmp    b87 <free+0xd7>
  } else
    p->s.ptr = bp;
 b7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b82:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b85:	89 10                	mov    %edx,(%eax)
  freep = p;
 b87:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8a:	a3 68 10 00 00       	mov    %eax,0x1068
}
 b8f:	c9                   	leave  
 b90:	c3                   	ret    

00000b91 <morecore>:

static Header*
morecore(uint nu)
{
 b91:	55                   	push   %ebp
 b92:	89 e5                	mov    %esp,%ebp
 b94:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b97:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b9e:	77 07                	ja     ba7 <morecore+0x16>
    nu = 4096;
 ba0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 ba7:	8b 45 08             	mov    0x8(%ebp),%eax
 baa:	c1 e0 03             	shl    $0x3,%eax
 bad:	89 04 24             	mov    %eax,(%esp)
 bb0:	e8 4f fc ff ff       	call   804 <sbrk>
 bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bb8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bbc:	75 07                	jne    bc5 <morecore+0x34>
    return 0;
 bbe:	b8 00 00 00 00       	mov    $0x0,%eax
 bc3:	eb 22                	jmp    be7 <morecore+0x56>
  hp = (Header*)p;
 bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bce:	8b 55 08             	mov    0x8(%ebp),%edx
 bd1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bd7:	83 c0 08             	add    $0x8,%eax
 bda:	89 04 24             	mov    %eax,(%esp)
 bdd:	e8 ce fe ff ff       	call   ab0 <free>
  return freep;
 be2:	a1 68 10 00 00       	mov    0x1068,%eax
}
 be7:	c9                   	leave  
 be8:	c3                   	ret    

00000be9 <malloc>:

void*
malloc(uint nbytes)
{
 be9:	55                   	push   %ebp
 bea:	89 e5                	mov    %esp,%ebp
 bec:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bef:	8b 45 08             	mov    0x8(%ebp),%eax
 bf2:	83 c0 07             	add    $0x7,%eax
 bf5:	c1 e8 03             	shr    $0x3,%eax
 bf8:	83 c0 01             	add    $0x1,%eax
 bfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bfe:	a1 68 10 00 00       	mov    0x1068,%eax
 c03:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c06:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c0a:	75 23                	jne    c2f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c0c:	c7 45 f0 60 10 00 00 	movl   $0x1060,-0x10(%ebp)
 c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c16:	a3 68 10 00 00       	mov    %eax,0x1068
 c1b:	a1 68 10 00 00       	mov    0x1068,%eax
 c20:	a3 60 10 00 00       	mov    %eax,0x1060
    base.s.size = 0;
 c25:	c7 05 64 10 00 00 00 	movl   $0x0,0x1064
 c2c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c32:	8b 00                	mov    (%eax),%eax
 c34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c3a:	8b 40 04             	mov    0x4(%eax),%eax
 c3d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c40:	72 4d                	jb     c8f <malloc+0xa6>
      if(p->s.size == nunits)
 c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c45:	8b 40 04             	mov    0x4(%eax),%eax
 c48:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c4b:	75 0c                	jne    c59 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c50:	8b 10                	mov    (%eax),%edx
 c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c55:	89 10                	mov    %edx,(%eax)
 c57:	eb 26                	jmp    c7f <malloc+0x96>
      else {
        p->s.size -= nunits;
 c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5c:	8b 40 04             	mov    0x4(%eax),%eax
 c5f:	89 c2                	mov    %eax,%edx
 c61:	2b 55 ec             	sub    -0x14(%ebp),%edx
 c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c67:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6d:	8b 40 04             	mov    0x4(%eax),%eax
 c70:	c1 e0 03             	shl    $0x3,%eax
 c73:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c79:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c7c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c82:	a3 68 10 00 00       	mov    %eax,0x1068
      return (void*)(p + 1);
 c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8a:	83 c0 08             	add    $0x8,%eax
 c8d:	eb 38                	jmp    cc7 <malloc+0xde>
    }
    if(p == freep)
 c8f:	a1 68 10 00 00       	mov    0x1068,%eax
 c94:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c97:	75 1b                	jne    cb4 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
 c9c:	89 04 24             	mov    %eax,(%esp)
 c9f:	e8 ed fe ff ff       	call   b91 <morecore>
 ca4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ca7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cab:	75 07                	jne    cb4 <malloc+0xcb>
        return 0;
 cad:	b8 00 00 00 00       	mov    $0x0,%eax
 cb2:	eb 13                	jmp    cc7 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cbd:	8b 00                	mov    (%eax),%eax
 cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 cc2:	e9 70 ff ff ff       	jmp    c37 <malloc+0x4e>
}
 cc7:	c9                   	leave  
 cc8:	c3                   	ret    
