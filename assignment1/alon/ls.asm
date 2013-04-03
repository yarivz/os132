
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 04 24             	mov    %eax,(%esp)
   d:	e8 dc 03 00 00       	call   3ee <strlen>
  12:	03 45 08             	add    0x8(%ebp),%eax
  15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  18:	eb 04                	jmp    1e <fmtname+0x1e>
  1a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  21:	3b 45 08             	cmp    0x8(%ebp),%eax
  24:	72 0a                	jb     30 <fmtname+0x30>
  26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  29:	0f b6 00             	movzbl (%eax),%eax
  2c:	3c 2f                	cmp    $0x2f,%al
  2e:	75 ea                	jne    1a <fmtname+0x1a>
    ;
  p++;
  30:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  37:	89 04 24             	mov    %eax,(%esp)
  3a:	e8 af 03 00 00       	call   3ee <strlen>
  3f:	83 f8 0d             	cmp    $0xd,%eax
  42:	76 05                	jbe    49 <fmtname+0x49>
    return p;
  44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  47:	eb 5f                	jmp    a8 <fmtname+0xa8>
  memmove(buf, p, strlen(p));
  49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 9a 03 00 00       	call   3ee <strlen>
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  5f:	c7 04 24 08 10 00 00 	movl   $0x1008,(%esp)
  66:	e8 07 05 00 00       	call   572 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6e:	89 04 24             	mov    %eax,(%esp)
  71:	e8 78 03 00 00       	call   3ee <strlen>
  76:	ba 0e 00 00 00       	mov    $0xe,%edx
  7b:	89 d3                	mov    %edx,%ebx
  7d:	29 c3                	sub    %eax,%ebx
  7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  82:	89 04 24             	mov    %eax,(%esp)
  85:	e8 64 03 00 00       	call   3ee <strlen>
  8a:	05 08 10 00 00       	add    $0x1008,%eax
  8f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  93:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  9a:	00 
  9b:	89 04 24             	mov    %eax,(%esp)
  9e:	e8 70 03 00 00       	call   413 <memset>
  return buf;
  a3:	b8 08 10 00 00       	mov    $0x1008,%eax
}
  a8:	83 c4 24             	add    $0x24,%esp
  ab:	5b                   	pop    %ebx
  ac:	5d                   	pop    %ebp
  ad:	c3                   	ret    

000000ae <ls>:

void
ls(char *path)
{
  ae:	55                   	push   %ebp
  af:	89 e5                	mov    %esp,%ebp
  b1:	57                   	push   %edi
  b2:	56                   	push   %esi
  b3:	53                   	push   %ebx
  b4:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c1:	00 
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	89 04 24             	mov    %eax,(%esp)
  c8:	e8 cb 06 00 00       	call   798 <open>
  cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d4:	79 20                	jns    f6 <ls+0x48>
    printf(2, "ls: cannot open %s\n", path);
  d6:	8b 45 08             	mov    0x8(%ebp),%eax
  d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  dd:	c7 44 24 04 93 0c 00 	movl   $0xc93,0x4(%esp)
  e4:	00 
  e5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ec:	e8 de 07 00 00       	call   8cf <printf>
    return;
  f1:	e9 01 02 00 00       	jmp    2f7 <ls+0x249>
  }
  
  if(fstat(fd, &st) < 0){
  f6:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 103:	89 04 24             	mov    %eax,(%esp)
 106:	e8 a5 06 00 00       	call   7b0 <fstat>
 10b:	85 c0                	test   %eax,%eax
 10d:	79 2b                	jns    13a <ls+0x8c>
    printf(2, "ls: cannot stat %s\n", path);
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	89 44 24 08          	mov    %eax,0x8(%esp)
 116:	c7 44 24 04 a7 0c 00 	movl   $0xca7,0x4(%esp)
 11d:	00 
 11e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 125:	e8 a5 07 00 00       	call   8cf <printf>
    close(fd);
 12a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12d:	89 04 24             	mov    %eax,(%esp)
 130:	e8 4b 06 00 00       	call   780 <close>
    return;
 135:	e9 bd 01 00 00       	jmp    2f7 <ls+0x249>
  }
  
  switch(st.type){
 13a:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 141:	98                   	cwtl   
 142:	83 f8 01             	cmp    $0x1,%eax
 145:	74 53                	je     19a <ls+0xec>
 147:	83 f8 02             	cmp    $0x2,%eax
 14a:	0f 85 9c 01 00 00    	jne    2ec <ls+0x23e>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 150:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 156:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 15c:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 163:	0f bf d8             	movswl %ax,%ebx
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	89 04 24             	mov    %eax,(%esp)
 16c:	e8 8f fe ff ff       	call   0 <fmtname>
 171:	89 7c 24 14          	mov    %edi,0x14(%esp)
 175:	89 74 24 10          	mov    %esi,0x10(%esp)
 179:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 17d:	89 44 24 08          	mov    %eax,0x8(%esp)
 181:	c7 44 24 04 bb 0c 00 	movl   $0xcbb,0x4(%esp)
 188:	00 
 189:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 190:	e8 3a 07 00 00       	call   8cf <printf>
    break;
 195:	e9 52 01 00 00       	jmp    2ec <ls+0x23e>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
 19d:	89 04 24             	mov    %eax,(%esp)
 1a0:	e8 49 02 00 00       	call   3ee <strlen>
 1a5:	83 c0 10             	add    $0x10,%eax
 1a8:	3d 00 02 00 00       	cmp    $0x200,%eax
 1ad:	76 19                	jbe    1c8 <ls+0x11a>
      printf(1, "ls: path too long\n");
 1af:	c7 44 24 04 c8 0c 00 	movl   $0xcc8,0x4(%esp)
 1b6:	00 
 1b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1be:	e8 0c 07 00 00       	call   8cf <printf>
      break;
 1c3:	e9 24 01 00 00       	jmp    2ec <ls+0x23e>
    }
    strcpy(buf, path);
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cf:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d5:	89 04 24             	mov    %eax,(%esp)
 1d8:	e8 9c 01 00 00       	call   379 <strcpy>
    p = buf+strlen(buf);
 1dd:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e3:	89 04 24             	mov    %eax,(%esp)
 1e6:	e8 03 02 00 00       	call   3ee <strlen>
 1eb:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1f1:	01 d0                	add    %edx,%eax
 1f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f9:	c6 00 2f             	movb   $0x2f,(%eax)
 1fc:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 200:	e9 c0 00 00 00       	jmp    2c5 <ls+0x217>
      if(de.inum == 0)
 205:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 20c:	66 85 c0             	test   %ax,%ax
 20f:	0f 84 af 00 00 00    	je     2c4 <ls+0x216>
        continue;
      memmove(p, de.name, DIRSIZ);
 215:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 21c:	00 
 21d:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 223:	83 c0 02             	add    $0x2,%eax
 226:	89 44 24 04          	mov    %eax,0x4(%esp)
 22a:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22d:	89 04 24             	mov    %eax,(%esp)
 230:	e8 3d 03 00 00       	call   572 <memmove>
      p[DIRSIZ] = 0;
 235:	8b 45 e0             	mov    -0x20(%ebp),%eax
 238:	83 c0 0e             	add    $0xe,%eax
 23b:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 23e:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 24e:	89 04 24             	mov    %eax,(%esp)
 251:	e8 83 02 00 00       	call   4d9 <stat>
 256:	85 c0                	test   %eax,%eax
 258:	79 20                	jns    27a <ls+0x1cc>
        printf(1, "ls: cannot stat %s\n", buf);
 25a:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 260:	89 44 24 08          	mov    %eax,0x8(%esp)
 264:	c7 44 24 04 a7 0c 00 	movl   $0xca7,0x4(%esp)
 26b:	00 
 26c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 273:	e8 57 06 00 00       	call   8cf <printf>
        continue;
 278:	eb 4b                	jmp    2c5 <ls+0x217>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 27a:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 280:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 286:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 28d:	0f bf d8             	movswl %ax,%ebx
 290:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 296:	89 04 24             	mov    %eax,(%esp)
 299:	e8 62 fd ff ff       	call   0 <fmtname>
 29e:	89 7c 24 14          	mov    %edi,0x14(%esp)
 2a2:	89 74 24 10          	mov    %esi,0x10(%esp)
 2a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2aa:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ae:	c7 44 24 04 bb 0c 00 	movl   $0xcbb,0x4(%esp)
 2b5:	00 
 2b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bd:	e8 0d 06 00 00       	call   8cf <printf>
 2c2:	eb 01                	jmp    2c5 <ls+0x217>
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
 2c4:	90                   	nop
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2c5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 2cc:	00 
 2cd:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2da:	89 04 24             	mov    %eax,(%esp)
 2dd:	e8 8e 04 00 00       	call   770 <read>
 2e2:	83 f8 10             	cmp    $0x10,%eax
 2e5:	0f 84 1a ff ff ff    	je     205 <ls+0x157>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2eb:	90                   	nop
  }
  close(fd);
 2ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ef:	89 04 24             	mov    %eax,(%esp)
 2f2:	e8 89 04 00 00       	call   780 <close>
}
 2f7:	81 c4 5c 02 00 00    	add    $0x25c,%esp
 2fd:	5b                   	pop    %ebx
 2fe:	5e                   	pop    %esi
 2ff:	5f                   	pop    %edi
 300:	5d                   	pop    %ebp
 301:	c3                   	ret    

00000302 <main>:

int
main(int argc, char *argv[])
{
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp
 305:	83 e4 f0             	and    $0xfffffff0,%esp
 308:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
 30b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 30f:	7f 11                	jg     322 <main+0x20>
    ls(".");
 311:	c7 04 24 db 0c 00 00 	movl   $0xcdb,(%esp)
 318:	e8 91 fd ff ff       	call   ae <ls>
    exit();
 31d:	e8 2e 04 00 00       	call   750 <exit>
  }
  for(i=1; i<argc; i++)
 322:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 329:	00 
 32a:	eb 19                	jmp    345 <main+0x43>
    ls(argv[i]);
 32c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 330:	c1 e0 02             	shl    $0x2,%eax
 333:	03 45 0c             	add    0xc(%ebp),%eax
 336:	8b 00                	mov    (%eax),%eax
 338:	89 04 24             	mov    %eax,(%esp)
 33b:	e8 6e fd ff ff       	call   ae <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 340:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 345:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 349:	3b 45 08             	cmp    0x8(%ebp),%eax
 34c:	7c de                	jl     32c <main+0x2a>
    ls(argv[i]);
  exit();
 34e:	e8 fd 03 00 00       	call   750 <exit>
 353:	90                   	nop

00000354 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	57                   	push   %edi
 358:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 359:	8b 4d 08             	mov    0x8(%ebp),%ecx
 35c:	8b 55 10             	mov    0x10(%ebp),%edx
 35f:	8b 45 0c             	mov    0xc(%ebp),%eax
 362:	89 cb                	mov    %ecx,%ebx
 364:	89 df                	mov    %ebx,%edi
 366:	89 d1                	mov    %edx,%ecx
 368:	fc                   	cld    
 369:	f3 aa                	rep stos %al,%es:(%edi)
 36b:	89 ca                	mov    %ecx,%edx
 36d:	89 fb                	mov    %edi,%ebx
 36f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 372:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 375:	5b                   	pop    %ebx
 376:	5f                   	pop    %edi
 377:	5d                   	pop    %ebp
 378:	c3                   	ret    

00000379 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 379:	55                   	push   %ebp
 37a:	89 e5                	mov    %esp,%ebp
 37c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 385:	90                   	nop
 386:	8b 45 0c             	mov    0xc(%ebp),%eax
 389:	0f b6 10             	movzbl (%eax),%edx
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
 38f:	88 10                	mov    %dl,(%eax)
 391:	8b 45 08             	mov    0x8(%ebp),%eax
 394:	0f b6 00             	movzbl (%eax),%eax
 397:	84 c0                	test   %al,%al
 399:	0f 95 c0             	setne  %al
 39c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3a4:	84 c0                	test   %al,%al
 3a6:	75 de                	jne    386 <strcpy+0xd>
    ;
  return os;
 3a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ab:	c9                   	leave  
 3ac:	c3                   	ret    

000003ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3ad:	55                   	push   %ebp
 3ae:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3b0:	eb 08                	jmp    3ba <strcmp+0xd>
    p++, q++;
 3b2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3ba:	8b 45 08             	mov    0x8(%ebp),%eax
 3bd:	0f b6 00             	movzbl (%eax),%eax
 3c0:	84 c0                	test   %al,%al
 3c2:	74 10                	je     3d4 <strcmp+0x27>
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	0f b6 10             	movzbl (%eax),%edx
 3ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	38 c2                	cmp    %al,%dl
 3d2:	74 de                	je     3b2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	0f b6 00             	movzbl (%eax),%eax
 3da:	0f b6 d0             	movzbl %al,%edx
 3dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e0:	0f b6 00             	movzbl (%eax),%eax
 3e3:	0f b6 c0             	movzbl %al,%eax
 3e6:	89 d1                	mov    %edx,%ecx
 3e8:	29 c1                	sub    %eax,%ecx
 3ea:	89 c8                	mov    %ecx,%eax
}
 3ec:	5d                   	pop    %ebp
 3ed:	c3                   	ret    

000003ee <strlen>:

uint
strlen(char *s)
{
 3ee:	55                   	push   %ebp
 3ef:	89 e5                	mov    %esp,%ebp
 3f1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 3f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3fb:	eb 04                	jmp    401 <strlen+0x13>
 3fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 401:	8b 45 fc             	mov    -0x4(%ebp),%eax
 404:	03 45 08             	add    0x8(%ebp),%eax
 407:	0f b6 00             	movzbl (%eax),%eax
 40a:	84 c0                	test   %al,%al
 40c:	75 ef                	jne    3fd <strlen+0xf>
  return n;
 40e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 411:	c9                   	leave  
 412:	c3                   	ret    

00000413 <memset>:

void*
memset(void *dst, int c, uint n)
{
 413:	55                   	push   %ebp
 414:	89 e5                	mov    %esp,%ebp
 416:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 419:	8b 45 10             	mov    0x10(%ebp),%eax
 41c:	89 44 24 08          	mov    %eax,0x8(%esp)
 420:	8b 45 0c             	mov    0xc(%ebp),%eax
 423:	89 44 24 04          	mov    %eax,0x4(%esp)
 427:	8b 45 08             	mov    0x8(%ebp),%eax
 42a:	89 04 24             	mov    %eax,(%esp)
 42d:	e8 22 ff ff ff       	call   354 <stosb>
  return dst;
 432:	8b 45 08             	mov    0x8(%ebp),%eax
}
 435:	c9                   	leave  
 436:	c3                   	ret    

00000437 <strchr>:

char*
strchr(const char *s, char c)
{
 437:	55                   	push   %ebp
 438:	89 e5                	mov    %esp,%ebp
 43a:	83 ec 04             	sub    $0x4,%esp
 43d:	8b 45 0c             	mov    0xc(%ebp),%eax
 440:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 443:	eb 14                	jmp    459 <strchr+0x22>
    if(*s == c)
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	0f b6 00             	movzbl (%eax),%eax
 44b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 44e:	75 05                	jne    455 <strchr+0x1e>
      return (char*)s;
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	eb 13                	jmp    468 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 455:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 459:	8b 45 08             	mov    0x8(%ebp),%eax
 45c:	0f b6 00             	movzbl (%eax),%eax
 45f:	84 c0                	test   %al,%al
 461:	75 e2                	jne    445 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 463:	b8 00 00 00 00       	mov    $0x0,%eax
}
 468:	c9                   	leave  
 469:	c3                   	ret    

0000046a <gets>:

char*
gets(char *buf, int max)
{
 46a:	55                   	push   %ebp
 46b:	89 e5                	mov    %esp,%ebp
 46d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 470:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 477:	eb 44                	jmp    4bd <gets+0x53>
    cc = read(0, &c, 1);
 479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 480:	00 
 481:	8d 45 ef             	lea    -0x11(%ebp),%eax
 484:	89 44 24 04          	mov    %eax,0x4(%esp)
 488:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 48f:	e8 dc 02 00 00       	call   770 <read>
 494:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 497:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 49b:	7e 2d                	jle    4ca <gets+0x60>
      break;
    buf[i++] = c;
 49d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a0:	03 45 08             	add    0x8(%ebp),%eax
 4a3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 4a7:	88 10                	mov    %dl,(%eax)
 4a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4ad:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b1:	3c 0a                	cmp    $0xa,%al
 4b3:	74 16                	je     4cb <gets+0x61>
 4b5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b9:	3c 0d                	cmp    $0xd,%al
 4bb:	74 0e                	je     4cb <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c0:	83 c0 01             	add    $0x1,%eax
 4c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4c6:	7c b1                	jl     479 <gets+0xf>
 4c8:	eb 01                	jmp    4cb <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4ca:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ce:	03 45 08             	add    0x8(%ebp),%eax
 4d1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d7:	c9                   	leave  
 4d8:	c3                   	ret    

000004d9 <stat>:

int
stat(char *n, struct stat *st)
{
 4d9:	55                   	push   %ebp
 4da:	89 e5                	mov    %esp,%ebp
 4dc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4e6:	00 
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	89 04 24             	mov    %eax,(%esp)
 4ed:	e8 a6 02 00 00       	call   798 <open>
 4f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f9:	79 07                	jns    502 <stat+0x29>
    return -1;
 4fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 500:	eb 23                	jmp    525 <stat+0x4c>
  r = fstat(fd, st);
 502:	8b 45 0c             	mov    0xc(%ebp),%eax
 505:	89 44 24 04          	mov    %eax,0x4(%esp)
 509:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50c:	89 04 24             	mov    %eax,(%esp)
 50f:	e8 9c 02 00 00       	call   7b0 <fstat>
 514:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 517:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51a:	89 04 24             	mov    %eax,(%esp)
 51d:	e8 5e 02 00 00       	call   780 <close>
  return r;
 522:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 525:	c9                   	leave  
 526:	c3                   	ret    

00000527 <atoi>:

int
atoi(const char *s)
{
 527:	55                   	push   %ebp
 528:	89 e5                	mov    %esp,%ebp
 52a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 52d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 534:	eb 23                	jmp    559 <atoi+0x32>
    n = n*10 + *s++ - '0';
 536:	8b 55 fc             	mov    -0x4(%ebp),%edx
 539:	89 d0                	mov    %edx,%eax
 53b:	c1 e0 02             	shl    $0x2,%eax
 53e:	01 d0                	add    %edx,%eax
 540:	01 c0                	add    %eax,%eax
 542:	89 c2                	mov    %eax,%edx
 544:	8b 45 08             	mov    0x8(%ebp),%eax
 547:	0f b6 00             	movzbl (%eax),%eax
 54a:	0f be c0             	movsbl %al,%eax
 54d:	01 d0                	add    %edx,%eax
 54f:	83 e8 30             	sub    $0x30,%eax
 552:	89 45 fc             	mov    %eax,-0x4(%ebp)
 555:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 559:	8b 45 08             	mov    0x8(%ebp),%eax
 55c:	0f b6 00             	movzbl (%eax),%eax
 55f:	3c 2f                	cmp    $0x2f,%al
 561:	7e 0a                	jle    56d <atoi+0x46>
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	0f b6 00             	movzbl (%eax),%eax
 569:	3c 39                	cmp    $0x39,%al
 56b:	7e c9                	jle    536 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 56d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 570:	c9                   	leave  
 571:	c3                   	ret    

00000572 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 572:	55                   	push   %ebp
 573:	89 e5                	mov    %esp,%ebp
 575:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 57e:	8b 45 0c             	mov    0xc(%ebp),%eax
 581:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 584:	eb 13                	jmp    599 <memmove+0x27>
    *dst++ = *src++;
 586:	8b 45 f8             	mov    -0x8(%ebp),%eax
 589:	0f b6 10             	movzbl (%eax),%edx
 58c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 58f:	88 10                	mov    %dl,(%eax)
 591:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 595:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 599:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 59d:	0f 9f c0             	setg   %al
 5a0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5a4:	84 c0                	test   %al,%al
 5a6:	75 de                	jne    586 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ab:	c9                   	leave  
 5ac:	c3                   	ret    

000005ad <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 5ad:	55                   	push   %ebp
 5ae:	89 e5                	mov    %esp,%ebp
 5b0:	83 ec 38             	sub    $0x38,%esp
 5b3:	8b 45 10             	mov    0x10(%ebp),%eax
 5b6:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 5b9:	8b 45 14             	mov    0x14(%ebp),%eax
 5bc:	8b 00                	mov    (%eax),%eax
 5be:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 5c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5cc:	74 06                	je     5d4 <strtok+0x27>
 5ce:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 5d2:	75 54                	jne    628 <strtok+0x7b>
    return match;
 5d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d7:	eb 6e                	jmp    647 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 5d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5dc:	03 45 0c             	add    0xc(%ebp),%eax
 5df:	0f b6 00             	movzbl (%eax),%eax
 5e2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 5e5:	74 06                	je     5ed <strtok+0x40>
      {
	index++;
 5e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5eb:	eb 3c                	jmp    629 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 5ed:	8b 45 14             	mov    0x14(%ebp),%eax
 5f0:	8b 00                	mov    (%eax),%eax
 5f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5f5:	29 c2                	sub    %eax,%edx
 5f7:	8b 45 14             	mov    0x14(%ebp),%eax
 5fa:	8b 00                	mov    (%eax),%eax
 5fc:	03 45 0c             	add    0xc(%ebp),%eax
 5ff:	89 54 24 08          	mov    %edx,0x8(%esp)
 603:	89 44 24 04          	mov    %eax,0x4(%esp)
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	89 04 24             	mov    %eax,(%esp)
 60d:	e8 37 00 00 00       	call   649 <strncpy>
 612:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 615:	8b 45 08             	mov    0x8(%ebp),%eax
 618:	0f b6 00             	movzbl (%eax),%eax
 61b:	84 c0                	test   %al,%al
 61d:	74 19                	je     638 <strtok+0x8b>
	  match = 1;
 61f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 626:	eb 10                	jmp    638 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 628:	90                   	nop
 629:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62c:	03 45 0c             	add    0xc(%ebp),%eax
 62f:	0f b6 00             	movzbl (%eax),%eax
 632:	84 c0                	test   %al,%al
 634:	75 a3                	jne    5d9 <strtok+0x2c>
 636:	eb 01                	jmp    639 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 638:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 639:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63c:	8d 50 01             	lea    0x1(%eax),%edx
 63f:	8b 45 14             	mov    0x14(%ebp),%eax
 642:	89 10                	mov    %edx,(%eax)
  return match;
 644:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 647:	c9                   	leave  
 648:	c3                   	ret    

00000649 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 649:	55                   	push   %ebp
 64a:	89 e5                	mov    %esp,%ebp
 64c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 64f:	8b 45 08             	mov    0x8(%ebp),%eax
 652:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 655:	90                   	nop
 656:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 65a:	0f 9f c0             	setg   %al
 65d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 661:	84 c0                	test   %al,%al
 663:	74 30                	je     695 <strncpy+0x4c>
 665:	8b 45 0c             	mov    0xc(%ebp),%eax
 668:	0f b6 10             	movzbl (%eax),%edx
 66b:	8b 45 08             	mov    0x8(%ebp),%eax
 66e:	88 10                	mov    %dl,(%eax)
 670:	8b 45 08             	mov    0x8(%ebp),%eax
 673:	0f b6 00             	movzbl (%eax),%eax
 676:	84 c0                	test   %al,%al
 678:	0f 95 c0             	setne  %al
 67b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 67f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 683:	84 c0                	test   %al,%al
 685:	75 cf                	jne    656 <strncpy+0xd>
    ;
  while(n-- > 0)
 687:	eb 0c                	jmp    695 <strncpy+0x4c>
    *s++ = 0;
 689:	8b 45 08             	mov    0x8(%ebp),%eax
 68c:	c6 00 00             	movb   $0x0,(%eax)
 68f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 693:	eb 01                	jmp    696 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 695:	90                   	nop
 696:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 69a:	0f 9f c0             	setg   %al
 69d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6a1:	84 c0                	test   %al,%al
 6a3:	75 e4                	jne    689 <strncpy+0x40>
    *s++ = 0;
  return os;
 6a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6a8:	c9                   	leave  
 6a9:	c3                   	ret    

000006aa <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 6aa:	55                   	push   %ebp
 6ab:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 6ad:	eb 0c                	jmp    6bb <strncmp+0x11>
    n--, p++, q++;
 6af:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6b7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 6bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6bf:	74 1a                	je     6db <strncmp+0x31>
 6c1:	8b 45 08             	mov    0x8(%ebp),%eax
 6c4:	0f b6 00             	movzbl (%eax),%eax
 6c7:	84 c0                	test   %al,%al
 6c9:	74 10                	je     6db <strncmp+0x31>
 6cb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ce:	0f b6 10             	movzbl (%eax),%edx
 6d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d4:	0f b6 00             	movzbl (%eax),%eax
 6d7:	38 c2                	cmp    %al,%dl
 6d9:	74 d4                	je     6af <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 6db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6df:	75 07                	jne    6e8 <strncmp+0x3e>
    return 0;
 6e1:	b8 00 00 00 00       	mov    $0x0,%eax
 6e6:	eb 18                	jmp    700 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 6e8:	8b 45 08             	mov    0x8(%ebp),%eax
 6eb:	0f b6 00             	movzbl (%eax),%eax
 6ee:	0f b6 d0             	movzbl %al,%edx
 6f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6f4:	0f b6 00             	movzbl (%eax),%eax
 6f7:	0f b6 c0             	movzbl %al,%eax
 6fa:	89 d1                	mov    %edx,%ecx
 6fc:	29 c1                	sub    %eax,%ecx
 6fe:	89 c8                	mov    %ecx,%eax
}
 700:	5d                   	pop    %ebp
 701:	c3                   	ret    

00000702 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 702:	55                   	push   %ebp
 703:	89 e5                	mov    %esp,%ebp
  while(*p){
 705:	eb 13                	jmp    71a <strcat+0x18>
    *dest++ = *p++;
 707:	8b 45 0c             	mov    0xc(%ebp),%eax
 70a:	0f b6 10             	movzbl (%eax),%edx
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	88 10                	mov    %dl,(%eax)
 712:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 716:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 71a:	8b 45 0c             	mov    0xc(%ebp),%eax
 71d:	0f b6 00             	movzbl (%eax),%eax
 720:	84 c0                	test   %al,%al
 722:	75 e3                	jne    707 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 724:	eb 13                	jmp    739 <strcat+0x37>
    *dest++ = *q++;
 726:	8b 45 10             	mov    0x10(%ebp),%eax
 729:	0f b6 10             	movzbl (%eax),%edx
 72c:	8b 45 08             	mov    0x8(%ebp),%eax
 72f:	88 10                	mov    %dl,(%eax)
 731:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 735:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 739:	8b 45 10             	mov    0x10(%ebp),%eax
 73c:	0f b6 00             	movzbl (%eax),%eax
 73f:	84 c0                	test   %al,%al
 741:	75 e3                	jne    726 <strcat+0x24>
    *dest++ = *q++;
  }  
 743:	5d                   	pop    %ebp
 744:	c3                   	ret    
 745:	90                   	nop
 746:	90                   	nop
 747:	90                   	nop

00000748 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 748:	b8 01 00 00 00       	mov    $0x1,%eax
 74d:	cd 40                	int    $0x40
 74f:	c3                   	ret    

00000750 <exit>:
SYSCALL(exit)
 750:	b8 02 00 00 00       	mov    $0x2,%eax
 755:	cd 40                	int    $0x40
 757:	c3                   	ret    

00000758 <wait>:
SYSCALL(wait)
 758:	b8 03 00 00 00       	mov    $0x3,%eax
 75d:	cd 40                	int    $0x40
 75f:	c3                   	ret    

00000760 <wait2>:
SYSCALL(wait2)
 760:	b8 16 00 00 00       	mov    $0x16,%eax
 765:	cd 40                	int    $0x40
 767:	c3                   	ret    

00000768 <pipe>:
SYSCALL(pipe)
 768:	b8 04 00 00 00       	mov    $0x4,%eax
 76d:	cd 40                	int    $0x40
 76f:	c3                   	ret    

00000770 <read>:
SYSCALL(read)
 770:	b8 05 00 00 00       	mov    $0x5,%eax
 775:	cd 40                	int    $0x40
 777:	c3                   	ret    

00000778 <write>:
SYSCALL(write)
 778:	b8 10 00 00 00       	mov    $0x10,%eax
 77d:	cd 40                	int    $0x40
 77f:	c3                   	ret    

00000780 <close>:
SYSCALL(close)
 780:	b8 15 00 00 00       	mov    $0x15,%eax
 785:	cd 40                	int    $0x40
 787:	c3                   	ret    

00000788 <kill>:
SYSCALL(kill)
 788:	b8 06 00 00 00       	mov    $0x6,%eax
 78d:	cd 40                	int    $0x40
 78f:	c3                   	ret    

00000790 <exec>:
SYSCALL(exec)
 790:	b8 07 00 00 00       	mov    $0x7,%eax
 795:	cd 40                	int    $0x40
 797:	c3                   	ret    

00000798 <open>:
SYSCALL(open)
 798:	b8 0f 00 00 00       	mov    $0xf,%eax
 79d:	cd 40                	int    $0x40
 79f:	c3                   	ret    

000007a0 <mknod>:
SYSCALL(mknod)
 7a0:	b8 11 00 00 00       	mov    $0x11,%eax
 7a5:	cd 40                	int    $0x40
 7a7:	c3                   	ret    

000007a8 <unlink>:
SYSCALL(unlink)
 7a8:	b8 12 00 00 00       	mov    $0x12,%eax
 7ad:	cd 40                	int    $0x40
 7af:	c3                   	ret    

000007b0 <fstat>:
SYSCALL(fstat)
 7b0:	b8 08 00 00 00       	mov    $0x8,%eax
 7b5:	cd 40                	int    $0x40
 7b7:	c3                   	ret    

000007b8 <link>:
SYSCALL(link)
 7b8:	b8 13 00 00 00       	mov    $0x13,%eax
 7bd:	cd 40                	int    $0x40
 7bf:	c3                   	ret    

000007c0 <mkdir>:
SYSCALL(mkdir)
 7c0:	b8 14 00 00 00       	mov    $0x14,%eax
 7c5:	cd 40                	int    $0x40
 7c7:	c3                   	ret    

000007c8 <chdir>:
SYSCALL(chdir)
 7c8:	b8 09 00 00 00       	mov    $0x9,%eax
 7cd:	cd 40                	int    $0x40
 7cf:	c3                   	ret    

000007d0 <dup>:
SYSCALL(dup)
 7d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 7d5:	cd 40                	int    $0x40
 7d7:	c3                   	ret    

000007d8 <getpid>:
SYSCALL(getpid)
 7d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 7dd:	cd 40                	int    $0x40
 7df:	c3                   	ret    

000007e0 <sbrk>:
SYSCALL(sbrk)
 7e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 7e5:	cd 40                	int    $0x40
 7e7:	c3                   	ret    

000007e8 <sleep>:
SYSCALL(sleep)
 7e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 7ed:	cd 40                	int    $0x40
 7ef:	c3                   	ret    

000007f0 <uptime>:
SYSCALL(uptime)
 7f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 7f5:	cd 40                	int    $0x40
 7f7:	c3                   	ret    

000007f8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7f8:	55                   	push   %ebp
 7f9:	89 e5                	mov    %esp,%ebp
 7fb:	83 ec 28             	sub    $0x28,%esp
 7fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 801:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 804:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 80b:	00 
 80c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 80f:	89 44 24 04          	mov    %eax,0x4(%esp)
 813:	8b 45 08             	mov    0x8(%ebp),%eax
 816:	89 04 24             	mov    %eax,(%esp)
 819:	e8 5a ff ff ff       	call   778 <write>
}
 81e:	c9                   	leave  
 81f:	c3                   	ret    

00000820 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 820:	55                   	push   %ebp
 821:	89 e5                	mov    %esp,%ebp
 823:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 826:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 82d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 831:	74 17                	je     84a <printint+0x2a>
 833:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 837:	79 11                	jns    84a <printint+0x2a>
    neg = 1;
 839:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 840:	8b 45 0c             	mov    0xc(%ebp),%eax
 843:	f7 d8                	neg    %eax
 845:	89 45 ec             	mov    %eax,-0x14(%ebp)
 848:	eb 06                	jmp    850 <printint+0x30>
  } else {
    x = xx;
 84a:	8b 45 0c             	mov    0xc(%ebp),%eax
 84d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 850:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 857:	8b 4d 10             	mov    0x10(%ebp),%ecx
 85a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 85d:	ba 00 00 00 00       	mov    $0x0,%edx
 862:	f7 f1                	div    %ecx
 864:	89 d0                	mov    %edx,%eax
 866:	0f b6 90 f4 0f 00 00 	movzbl 0xff4(%eax),%edx
 86d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 870:	03 45 f4             	add    -0xc(%ebp),%eax
 873:	88 10                	mov    %dl,(%eax)
 875:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 879:	8b 55 10             	mov    0x10(%ebp),%edx
 87c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 87f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 882:	ba 00 00 00 00       	mov    $0x0,%edx
 887:	f7 75 d4             	divl   -0x2c(%ebp)
 88a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 88d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 891:	75 c4                	jne    857 <printint+0x37>
  if(neg)
 893:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 897:	74 2a                	je     8c3 <printint+0xa3>
    buf[i++] = '-';
 899:	8d 45 dc             	lea    -0x24(%ebp),%eax
 89c:	03 45 f4             	add    -0xc(%ebp),%eax
 89f:	c6 00 2d             	movb   $0x2d,(%eax)
 8a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 8a6:	eb 1b                	jmp    8c3 <printint+0xa3>
    putc(fd, buf[i]);
 8a8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 8ab:	03 45 f4             	add    -0xc(%ebp),%eax
 8ae:	0f b6 00             	movzbl (%eax),%eax
 8b1:	0f be c0             	movsbl %al,%eax
 8b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8b8:	8b 45 08             	mov    0x8(%ebp),%eax
 8bb:	89 04 24             	mov    %eax,(%esp)
 8be:	e8 35 ff ff ff       	call   7f8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 8c3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8cb:	79 db                	jns    8a8 <printint+0x88>
    putc(fd, buf[i]);
}
 8cd:	c9                   	leave  
 8ce:	c3                   	ret    

000008cf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 8cf:	55                   	push   %ebp
 8d0:	89 e5                	mov    %esp,%ebp
 8d2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 8dc:	8d 45 0c             	lea    0xc(%ebp),%eax
 8df:	83 c0 04             	add    $0x4,%eax
 8e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8ec:	e9 7d 01 00 00       	jmp    a6e <printf+0x19f>
    c = fmt[i] & 0xff;
 8f1:	8b 55 0c             	mov    0xc(%ebp),%edx
 8f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f7:	01 d0                	add    %edx,%eax
 8f9:	0f b6 00             	movzbl (%eax),%eax
 8fc:	0f be c0             	movsbl %al,%eax
 8ff:	25 ff 00 00 00       	and    $0xff,%eax
 904:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 907:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 90b:	75 2c                	jne    939 <printf+0x6a>
      if(c == '%'){
 90d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 911:	75 0c                	jne    91f <printf+0x50>
        state = '%';
 913:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 91a:	e9 4b 01 00 00       	jmp    a6a <printf+0x19b>
      } else {
        putc(fd, c);
 91f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 922:	0f be c0             	movsbl %al,%eax
 925:	89 44 24 04          	mov    %eax,0x4(%esp)
 929:	8b 45 08             	mov    0x8(%ebp),%eax
 92c:	89 04 24             	mov    %eax,(%esp)
 92f:	e8 c4 fe ff ff       	call   7f8 <putc>
 934:	e9 31 01 00 00       	jmp    a6a <printf+0x19b>
      }
    } else if(state == '%'){
 939:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 93d:	0f 85 27 01 00 00    	jne    a6a <printf+0x19b>
      if(c == 'd'){
 943:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 947:	75 2d                	jne    976 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 949:	8b 45 e8             	mov    -0x18(%ebp),%eax
 94c:	8b 00                	mov    (%eax),%eax
 94e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 955:	00 
 956:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 95d:	00 
 95e:	89 44 24 04          	mov    %eax,0x4(%esp)
 962:	8b 45 08             	mov    0x8(%ebp),%eax
 965:	89 04 24             	mov    %eax,(%esp)
 968:	e8 b3 fe ff ff       	call   820 <printint>
        ap++;
 96d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 971:	e9 ed 00 00 00       	jmp    a63 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 976:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 97a:	74 06                	je     982 <printf+0xb3>
 97c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 980:	75 2d                	jne    9af <printf+0xe0>
        printint(fd, *ap, 16, 0);
 982:	8b 45 e8             	mov    -0x18(%ebp),%eax
 985:	8b 00                	mov    (%eax),%eax
 987:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 98e:	00 
 98f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 996:	00 
 997:	89 44 24 04          	mov    %eax,0x4(%esp)
 99b:	8b 45 08             	mov    0x8(%ebp),%eax
 99e:	89 04 24             	mov    %eax,(%esp)
 9a1:	e8 7a fe ff ff       	call   820 <printint>
        ap++;
 9a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9aa:	e9 b4 00 00 00       	jmp    a63 <printf+0x194>
      } else if(c == 's'){
 9af:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9b3:	75 46                	jne    9fb <printf+0x12c>
        s = (char*)*ap;
 9b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9b8:	8b 00                	mov    (%eax),%eax
 9ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9bd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9c5:	75 27                	jne    9ee <printf+0x11f>
          s = "(null)";
 9c7:	c7 45 f4 dd 0c 00 00 	movl   $0xcdd,-0xc(%ebp)
        while(*s != 0){
 9ce:	eb 1e                	jmp    9ee <printf+0x11f>
          putc(fd, *s);
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	0f b6 00             	movzbl (%eax),%eax
 9d6:	0f be c0             	movsbl %al,%eax
 9d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 9dd:	8b 45 08             	mov    0x8(%ebp),%eax
 9e0:	89 04 24             	mov    %eax,(%esp)
 9e3:	e8 10 fe ff ff       	call   7f8 <putc>
          s++;
 9e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 9ec:	eb 01                	jmp    9ef <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 9ee:	90                   	nop
 9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f2:	0f b6 00             	movzbl (%eax),%eax
 9f5:	84 c0                	test   %al,%al
 9f7:	75 d7                	jne    9d0 <printf+0x101>
 9f9:	eb 68                	jmp    a63 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 9fb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 9ff:	75 1d                	jne    a1e <printf+0x14f>
        putc(fd, *ap);
 a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a04:	8b 00                	mov    (%eax),%eax
 a06:	0f be c0             	movsbl %al,%eax
 a09:	89 44 24 04          	mov    %eax,0x4(%esp)
 a0d:	8b 45 08             	mov    0x8(%ebp),%eax
 a10:	89 04 24             	mov    %eax,(%esp)
 a13:	e8 e0 fd ff ff       	call   7f8 <putc>
        ap++;
 a18:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a1c:	eb 45                	jmp    a63 <printf+0x194>
      } else if(c == '%'){
 a1e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a22:	75 17                	jne    a3b <printf+0x16c>
        putc(fd, c);
 a24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a27:	0f be c0             	movsbl %al,%eax
 a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
 a2e:	8b 45 08             	mov    0x8(%ebp),%eax
 a31:	89 04 24             	mov    %eax,(%esp)
 a34:	e8 bf fd ff ff       	call   7f8 <putc>
 a39:	eb 28                	jmp    a63 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a3b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a42:	00 
 a43:	8b 45 08             	mov    0x8(%ebp),%eax
 a46:	89 04 24             	mov    %eax,(%esp)
 a49:	e8 aa fd ff ff       	call   7f8 <putc>
        putc(fd, c);
 a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a51:	0f be c0             	movsbl %al,%eax
 a54:	89 44 24 04          	mov    %eax,0x4(%esp)
 a58:	8b 45 08             	mov    0x8(%ebp),%eax
 a5b:	89 04 24             	mov    %eax,(%esp)
 a5e:	e8 95 fd ff ff       	call   7f8 <putc>
      }
      state = 0;
 a63:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 a6a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
 a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a74:	01 d0                	add    %edx,%eax
 a76:	0f b6 00             	movzbl (%eax),%eax
 a79:	84 c0                	test   %al,%al
 a7b:	0f 85 70 fe ff ff    	jne    8f1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 a81:	c9                   	leave  
 a82:	c3                   	ret    
 a83:	90                   	nop

00000a84 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a84:	55                   	push   %ebp
 a85:	89 e5                	mov    %esp,%ebp
 a87:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a8a:	8b 45 08             	mov    0x8(%ebp),%eax
 a8d:	83 e8 08             	sub    $0x8,%eax
 a90:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a93:	a1 20 10 00 00       	mov    0x1020,%eax
 a98:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a9b:	eb 24                	jmp    ac1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa0:	8b 00                	mov    (%eax),%eax
 aa2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 aa5:	77 12                	ja     ab9 <free+0x35>
 aa7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aaa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 aad:	77 24                	ja     ad3 <free+0x4f>
 aaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab2:	8b 00                	mov    (%eax),%eax
 ab4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ab7:	77 1a                	ja     ad3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 abc:	8b 00                	mov    (%eax),%eax
 abe:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ac1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ac4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ac7:	76 d4                	jbe    a9d <free+0x19>
 ac9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 acc:	8b 00                	mov    (%eax),%eax
 ace:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ad1:	76 ca                	jbe    a9d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 ad3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad6:	8b 40 04             	mov    0x4(%eax),%eax
 ad9:	c1 e0 03             	shl    $0x3,%eax
 adc:	89 c2                	mov    %eax,%edx
 ade:	03 55 f8             	add    -0x8(%ebp),%edx
 ae1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae4:	8b 00                	mov    (%eax),%eax
 ae6:	39 c2                	cmp    %eax,%edx
 ae8:	75 24                	jne    b0e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 aea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aed:	8b 50 04             	mov    0x4(%eax),%edx
 af0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af3:	8b 00                	mov    (%eax),%eax
 af5:	8b 40 04             	mov    0x4(%eax),%eax
 af8:	01 c2                	add    %eax,%edx
 afa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b03:	8b 00                	mov    (%eax),%eax
 b05:	8b 10                	mov    (%eax),%edx
 b07:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b0a:	89 10                	mov    %edx,(%eax)
 b0c:	eb 0a                	jmp    b18 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 b0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b11:	8b 10                	mov    (%eax),%edx
 b13:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b16:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b18:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1b:	8b 40 04             	mov    0x4(%eax),%eax
 b1e:	c1 e0 03             	shl    $0x3,%eax
 b21:	03 45 fc             	add    -0x4(%ebp),%eax
 b24:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b27:	75 20                	jne    b49 <free+0xc5>
    p->s.size += bp->s.size;
 b29:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2c:	8b 50 04             	mov    0x4(%eax),%edx
 b2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b32:	8b 40 04             	mov    0x4(%eax),%eax
 b35:	01 c2                	add    %eax,%edx
 b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b40:	8b 10                	mov    (%eax),%edx
 b42:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b45:	89 10                	mov    %edx,(%eax)
 b47:	eb 08                	jmp    b51 <free+0xcd>
  } else
    p->s.ptr = bp;
 b49:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b4f:	89 10                	mov    %edx,(%eax)
  freep = p;
 b51:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b54:	a3 20 10 00 00       	mov    %eax,0x1020
}
 b59:	c9                   	leave  
 b5a:	c3                   	ret    

00000b5b <morecore>:

static Header*
morecore(uint nu)
{
 b5b:	55                   	push   %ebp
 b5c:	89 e5                	mov    %esp,%ebp
 b5e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b61:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b68:	77 07                	ja     b71 <morecore+0x16>
    nu = 4096;
 b6a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b71:	8b 45 08             	mov    0x8(%ebp),%eax
 b74:	c1 e0 03             	shl    $0x3,%eax
 b77:	89 04 24             	mov    %eax,(%esp)
 b7a:	e8 61 fc ff ff       	call   7e0 <sbrk>
 b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b82:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b86:	75 07                	jne    b8f <morecore+0x34>
    return 0;
 b88:	b8 00 00 00 00       	mov    $0x0,%eax
 b8d:	eb 22                	jmp    bb1 <morecore+0x56>
  hp = (Header*)p;
 b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b98:	8b 55 08             	mov    0x8(%ebp),%edx
 b9b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba1:	83 c0 08             	add    $0x8,%eax
 ba4:	89 04 24             	mov    %eax,(%esp)
 ba7:	e8 d8 fe ff ff       	call   a84 <free>
  return freep;
 bac:	a1 20 10 00 00       	mov    0x1020,%eax
}
 bb1:	c9                   	leave  
 bb2:	c3                   	ret    

00000bb3 <malloc>:

void*
malloc(uint nbytes)
{
 bb3:	55                   	push   %ebp
 bb4:	89 e5                	mov    %esp,%ebp
 bb6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bb9:	8b 45 08             	mov    0x8(%ebp),%eax
 bbc:	83 c0 07             	add    $0x7,%eax
 bbf:	c1 e8 03             	shr    $0x3,%eax
 bc2:	83 c0 01             	add    $0x1,%eax
 bc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bc8:	a1 20 10 00 00       	mov    0x1020,%eax
 bcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 bd4:	75 23                	jne    bf9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 bd6:	c7 45 f0 18 10 00 00 	movl   $0x1018,-0x10(%ebp)
 bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 be0:	a3 20 10 00 00       	mov    %eax,0x1020
 be5:	a1 20 10 00 00       	mov    0x1020,%eax
 bea:	a3 18 10 00 00       	mov    %eax,0x1018
    base.s.size = 0;
 bef:	c7 05 1c 10 00 00 00 	movl   $0x0,0x101c
 bf6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bfc:	8b 00                	mov    (%eax),%eax
 bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c04:	8b 40 04             	mov    0x4(%eax),%eax
 c07:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c0a:	72 4d                	jb     c59 <malloc+0xa6>
      if(p->s.size == nunits)
 c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c0f:	8b 40 04             	mov    0x4(%eax),%eax
 c12:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c15:	75 0c                	jne    c23 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c1a:	8b 10                	mov    (%eax),%edx
 c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c1f:	89 10                	mov    %edx,(%eax)
 c21:	eb 26                	jmp    c49 <malloc+0x96>
      else {
        p->s.size -= nunits;
 c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c26:	8b 40 04             	mov    0x4(%eax),%eax
 c29:	89 c2                	mov    %eax,%edx
 c2b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c31:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c37:	8b 40 04             	mov    0x4(%eax),%eax
 c3a:	c1 e0 03             	shl    $0x3,%eax
 c3d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c43:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c46:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c4c:	a3 20 10 00 00       	mov    %eax,0x1020
      return (void*)(p + 1);
 c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c54:	83 c0 08             	add    $0x8,%eax
 c57:	eb 38                	jmp    c91 <malloc+0xde>
    }
    if(p == freep)
 c59:	a1 20 10 00 00       	mov    0x1020,%eax
 c5e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c61:	75 1b                	jne    c7e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 c63:	8b 45 ec             	mov    -0x14(%ebp),%eax
 c66:	89 04 24             	mov    %eax,(%esp)
 c69:	e8 ed fe ff ff       	call   b5b <morecore>
 c6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c75:	75 07                	jne    c7e <malloc+0xcb>
        return 0;
 c77:	b8 00 00 00 00       	mov    $0x0,%eax
 c7c:	eb 13                	jmp    c91 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c81:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c87:	8b 00                	mov    (%eax),%eax
 c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 c8c:	e9 70 ff ff ff       	jmp    c01 <malloc+0x4e>
}
 c91:	c9                   	leave  
 c92:	c3                   	ret    
