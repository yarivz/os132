
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <getcmd>:
int pathInit;


int
getcmd(char *buf, int nbuf)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
       6:	c7 44 24 04 60 18 00 	movl   $0x1860,0x4(%esp)
       d:	00 
       e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      15:	e8 81 14 00 00       	call   149b <printf>
  memset(buf, 0, nbuf);
      1a:	8b 45 0c             	mov    0xc(%ebp),%eax
      1d:	89 44 24 08          	mov    %eax,0x8(%esp)
      21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      28:	00 
      29:	8b 45 08             	mov    0x8(%ebp),%eax
      2c:	89 04 24             	mov    %eax,(%esp)
      2f:	e8 a3 0f 00 00       	call   fd7 <memset>
  gets(buf, nbuf);
      34:	8b 45 0c             	mov    0xc(%ebp),%eax
      37:	89 44 24 04          	mov    %eax,0x4(%esp)
      3b:	8b 45 08             	mov    0x8(%ebp),%eax
      3e:	89 04 24             	mov    %eax,(%esp)
      41:	e8 e8 0f 00 00       	call   102e <gets>
  if(buf[0] == 0) // EOF
      46:	8b 45 08             	mov    0x8(%ebp),%eax
      49:	0f b6 00             	movzbl (%eax),%eax
      4c:	84 c0                	test   %al,%al
      4e:	75 07                	jne    57 <getcmd+0x57>
    return -1;
      50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      55:	eb 05                	jmp    5c <getcmd+0x5c>
  return 0;
      57:	b8 00 00 00 00       	mov    $0x0,%eax
}
      5c:	c9                   	leave  
      5d:	c3                   	ret    

0000005e <panic>:


void
panic(char *s)
{
      5e:	55                   	push   %ebp
      5f:	89 e5                	mov    %esp,%ebp
      61:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
      64:	8b 45 08             	mov    0x8(%ebp),%eax
      67:	89 44 24 08          	mov    %eax,0x8(%esp)
      6b:	c7 44 24 04 63 18 00 	movl   $0x1863,0x4(%esp)
      72:	00 
      73:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      7a:	e8 1c 14 00 00       	call   149b <printf>
  exit();
      7f:	e8 90 12 00 00       	call   1314 <exit>

00000084 <fork1>:
}

int
fork1(void)
{
      84:	55                   	push   %ebp
      85:	89 e5                	mov    %esp,%ebp
      87:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
      8a:	e8 7d 12 00 00       	call   130c <fork>
      8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
      92:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
      96:	75 0c                	jne    a4 <fork1+0x20>
    panic("fork");
      98:	c7 04 24 67 18 00 00 	movl   $0x1867,(%esp)
      9f:	e8 ba ff ff ff       	call   5e <panic>
  return pid;
      a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
      a7:	c9                   	leave  
      a8:	c3                   	ret    

000000a9 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
      a9:	55                   	push   %ebp
      aa:	89 e5                	mov    %esp,%ebp
      ac:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
      af:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
      b6:	e8 c4 16 00 00       	call   177f <malloc>
      bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
      be:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
      c5:	00 
      c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      cd:	00 
      ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
      d1:	89 04 24             	mov    %eax,(%esp)
      d4:	e8 fe 0e 00 00       	call   fd7 <memset>
  cmd->type = EXEC;
      d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
      dc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
      e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
      e5:	c9                   	leave  
      e6:	c3                   	ret    

000000e7 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
      e7:	55                   	push   %ebp
      e8:	89 e5                	mov    %esp,%ebp
      ea:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
      ed:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
      f4:	e8 86 16 00 00       	call   177f <malloc>
      f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
      fc:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     103:	00 
     104:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     10b:	00 
     10c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     10f:	89 04 24             	mov    %eax,(%esp)
     112:	e8 c0 0e 00 00       	call   fd7 <memset>
  cmd->type = REDIR;
     117:	8b 45 f4             	mov    -0xc(%ebp),%eax
     11a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     120:	8b 45 f4             	mov    -0xc(%ebp),%eax
     123:	8b 55 08             	mov    0x8(%ebp),%edx
     126:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     129:	8b 45 f4             	mov    -0xc(%ebp),%eax
     12c:	8b 55 0c             	mov    0xc(%ebp),%edx
     12f:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     132:	8b 45 f4             	mov    -0xc(%ebp),%eax
     135:	8b 55 10             	mov    0x10(%ebp),%edx
     138:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     13b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     13e:	8b 55 14             	mov    0x14(%ebp),%edx
     141:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     144:	8b 45 f4             	mov    -0xc(%ebp),%eax
     147:	8b 55 18             	mov    0x18(%ebp),%edx
     14a:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     14d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     150:	c9                   	leave  
     151:	c3                   	ret    

00000152 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     152:	55                   	push   %ebp
     153:	89 e5                	mov    %esp,%ebp
     155:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     158:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     15f:	e8 1b 16 00 00       	call   177f <malloc>
     164:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     167:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     16e:	00 
     16f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     176:	00 
     177:	8b 45 f4             	mov    -0xc(%ebp),%eax
     17a:	89 04 24             	mov    %eax,(%esp)
     17d:	e8 55 0e 00 00       	call   fd7 <memset>
  cmd->type = PIPE;
     182:	8b 45 f4             	mov    -0xc(%ebp),%eax
     185:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     18b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     18e:	8b 55 08             	mov    0x8(%ebp),%edx
     191:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     194:	8b 45 f4             	mov    -0xc(%ebp),%eax
     197:	8b 55 0c             	mov    0xc(%ebp),%edx
     19a:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     19d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     1a0:	c9                   	leave  
     1a1:	c3                   	ret    

000001a2 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     1a2:	55                   	push   %ebp
     1a3:	89 e5                	mov    %esp,%ebp
     1a5:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     1a8:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     1af:	e8 cb 15 00 00       	call   177f <malloc>
     1b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     1b7:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     1be:	00 
     1bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     1c6:	00 
     1c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1ca:	89 04 24             	mov    %eax,(%esp)
     1cd:	e8 05 0e 00 00       	call   fd7 <memset>
  cmd->type = LIST;
     1d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1d5:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     1db:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1de:	8b 55 08             	mov    0x8(%ebp),%edx
     1e1:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     1e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1e7:	8b 55 0c             	mov    0xc(%ebp),%edx
     1ea:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     1ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     1f0:	c9                   	leave  
     1f1:	c3                   	ret    

000001f2 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     1f2:	55                   	push   %ebp
     1f3:	89 e5                	mov    %esp,%ebp
     1f5:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     1f8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     1ff:	e8 7b 15 00 00       	call   177f <malloc>
     204:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     207:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     20e:	00 
     20f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     216:	00 
     217:	8b 45 f4             	mov    -0xc(%ebp),%eax
     21a:	89 04 24             	mov    %eax,(%esp)
     21d:	e8 b5 0d 00 00       	call   fd7 <memset>
  cmd->type = BACK;
     222:	8b 45 f4             	mov    -0xc(%ebp),%eax
     225:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     22b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     22e:	8b 55 08             	mov    0x8(%ebp),%edx
     231:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     234:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     237:	c9                   	leave  
     238:	c3                   	ret    

00000239 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     239:	55                   	push   %ebp
     23a:	89 e5                	mov    %esp,%ebp
     23c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     23f:	8b 45 08             	mov    0x8(%ebp),%eax
     242:	8b 00                	mov    (%eax),%eax
     244:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     247:	eb 04                	jmp    24d <gettoken+0x14>
    s++;
     249:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     24d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     250:	3b 45 0c             	cmp    0xc(%ebp),%eax
     253:	73 1d                	jae    272 <gettoken+0x39>
     255:	8b 45 f4             	mov    -0xc(%ebp),%eax
     258:	0f b6 00             	movzbl (%eax),%eax
     25b:	0f be c0             	movsbl %al,%eax
     25e:	89 44 24 04          	mov    %eax,0x4(%esp)
     262:	c7 04 24 60 1e 00 00 	movl   $0x1e60,(%esp)
     269:	e8 8d 0d 00 00       	call   ffb <strchr>
     26e:	85 c0                	test   %eax,%eax
     270:	75 d7                	jne    249 <gettoken+0x10>
    s++;
  if(q)
     272:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     276:	74 08                	je     280 <gettoken+0x47>
    *q = s;
     278:	8b 45 10             	mov    0x10(%ebp),%eax
     27b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     27e:	89 10                	mov    %edx,(%eax)
  ret = *s;
     280:	8b 45 f4             	mov    -0xc(%ebp),%eax
     283:	0f b6 00             	movzbl (%eax),%eax
     286:	0f be c0             	movsbl %al,%eax
     289:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     28c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     28f:	0f b6 00             	movzbl (%eax),%eax
     292:	0f be c0             	movsbl %al,%eax
     295:	83 f8 3c             	cmp    $0x3c,%eax
     298:	7f 1e                	jg     2b8 <gettoken+0x7f>
     29a:	83 f8 3b             	cmp    $0x3b,%eax
     29d:	7d 23                	jge    2c2 <gettoken+0x89>
     29f:	83 f8 29             	cmp    $0x29,%eax
     2a2:	7f 3f                	jg     2e3 <gettoken+0xaa>
     2a4:	83 f8 28             	cmp    $0x28,%eax
     2a7:	7d 19                	jge    2c2 <gettoken+0x89>
     2a9:	85 c0                	test   %eax,%eax
     2ab:	0f 84 83 00 00 00    	je     334 <gettoken+0xfb>
     2b1:	83 f8 26             	cmp    $0x26,%eax
     2b4:	74 0c                	je     2c2 <gettoken+0x89>
     2b6:	eb 2b                	jmp    2e3 <gettoken+0xaa>
     2b8:	83 f8 3e             	cmp    $0x3e,%eax
     2bb:	74 0b                	je     2c8 <gettoken+0x8f>
     2bd:	83 f8 7c             	cmp    $0x7c,%eax
     2c0:	75 21                	jne    2e3 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     2c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     2c6:	eb 73                	jmp    33b <gettoken+0x102>
  case '>':
    s++;
     2c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     2cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2cf:	0f b6 00             	movzbl (%eax),%eax
     2d2:	3c 3e                	cmp    $0x3e,%al
     2d4:	75 61                	jne    337 <gettoken+0xfe>
      ret = '+';
     2d6:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     2dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     2e1:	eb 54                	jmp    337 <gettoken+0xfe>
  default:
    ret = 'a';
     2e3:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     2ea:	eb 04                	jmp    2f0 <gettoken+0xb7>
      s++;
     2ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     2f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
     2f6:	73 42                	jae    33a <gettoken+0x101>
     2f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2fb:	0f b6 00             	movzbl (%eax),%eax
     2fe:	0f be c0             	movsbl %al,%eax
     301:	89 44 24 04          	mov    %eax,0x4(%esp)
     305:	c7 04 24 60 1e 00 00 	movl   $0x1e60,(%esp)
     30c:	e8 ea 0c 00 00       	call   ffb <strchr>
     311:	85 c0                	test   %eax,%eax
     313:	75 25                	jne    33a <gettoken+0x101>
     315:	8b 45 f4             	mov    -0xc(%ebp),%eax
     318:	0f b6 00             	movzbl (%eax),%eax
     31b:	0f be c0             	movsbl %al,%eax
     31e:	89 44 24 04          	mov    %eax,0x4(%esp)
     322:	c7 04 24 66 1e 00 00 	movl   $0x1e66,(%esp)
     329:	e8 cd 0c 00 00       	call   ffb <strchr>
     32e:	85 c0                	test   %eax,%eax
     330:	74 ba                	je     2ec <gettoken+0xb3>
      s++;
    break;
     332:	eb 06                	jmp    33a <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     334:	90                   	nop
     335:	eb 04                	jmp    33b <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     337:	90                   	nop
     338:	eb 01                	jmp    33b <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     33a:	90                   	nop
  }
  if(eq)
     33b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     33f:	74 0e                	je     34f <gettoken+0x116>
    *eq = s;
     341:	8b 45 14             	mov    0x14(%ebp),%eax
     344:	8b 55 f4             	mov    -0xc(%ebp),%edx
     347:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     349:	eb 04                	jmp    34f <gettoken+0x116>
    s++;
     34b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     34f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     352:	3b 45 0c             	cmp    0xc(%ebp),%eax
     355:	73 1d                	jae    374 <gettoken+0x13b>
     357:	8b 45 f4             	mov    -0xc(%ebp),%eax
     35a:	0f b6 00             	movzbl (%eax),%eax
     35d:	0f be c0             	movsbl %al,%eax
     360:	89 44 24 04          	mov    %eax,0x4(%esp)
     364:	c7 04 24 60 1e 00 00 	movl   $0x1e60,(%esp)
     36b:	e8 8b 0c 00 00       	call   ffb <strchr>
     370:	85 c0                	test   %eax,%eax
     372:	75 d7                	jne    34b <gettoken+0x112>
    s++;
  *ps = s;
     374:	8b 45 08             	mov    0x8(%ebp),%eax
     377:	8b 55 f4             	mov    -0xc(%ebp),%edx
     37a:	89 10                	mov    %edx,(%eax)
  return ret;
     37c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     37f:	c9                   	leave  
     380:	c3                   	ret    

00000381 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     381:	55                   	push   %ebp
     382:	89 e5                	mov    %esp,%ebp
     384:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     387:	8b 45 08             	mov    0x8(%ebp),%eax
     38a:	8b 00                	mov    (%eax),%eax
     38c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     38f:	eb 04                	jmp    395 <peek+0x14>
    s++;
     391:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     395:	8b 45 f4             	mov    -0xc(%ebp),%eax
     398:	3b 45 0c             	cmp    0xc(%ebp),%eax
     39b:	73 1d                	jae    3ba <peek+0x39>
     39d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3a0:	0f b6 00             	movzbl (%eax),%eax
     3a3:	0f be c0             	movsbl %al,%eax
     3a6:	89 44 24 04          	mov    %eax,0x4(%esp)
     3aa:	c7 04 24 60 1e 00 00 	movl   $0x1e60,(%esp)
     3b1:	e8 45 0c 00 00       	call   ffb <strchr>
     3b6:	85 c0                	test   %eax,%eax
     3b8:	75 d7                	jne    391 <peek+0x10>
    s++;
  *ps = s;
     3ba:	8b 45 08             	mov    0x8(%ebp),%eax
     3bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
     3c0:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     3c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3c5:	0f b6 00             	movzbl (%eax),%eax
     3c8:	84 c0                	test   %al,%al
     3ca:	74 23                	je     3ef <peek+0x6e>
     3cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3cf:	0f b6 00             	movzbl (%eax),%eax
     3d2:	0f be c0             	movsbl %al,%eax
     3d5:	89 44 24 04          	mov    %eax,0x4(%esp)
     3d9:	8b 45 10             	mov    0x10(%ebp),%eax
     3dc:	89 04 24             	mov    %eax,(%esp)
     3df:	e8 17 0c 00 00       	call   ffb <strchr>
     3e4:	85 c0                	test   %eax,%eax
     3e6:	74 07                	je     3ef <peek+0x6e>
     3e8:	b8 01 00 00 00       	mov    $0x1,%eax
     3ed:	eb 05                	jmp    3f4 <peek+0x73>
     3ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
     3f4:	c9                   	leave  
     3f5:	c3                   	ret    

000003f6 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     3f6:	55                   	push   %ebp
     3f7:	89 e5                	mov    %esp,%ebp
     3f9:	53                   	push   %ebx
     3fa:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     3fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
     400:	8b 45 08             	mov    0x8(%ebp),%eax
     403:	89 04 24             	mov    %eax,(%esp)
     406:	e8 a7 0b 00 00       	call   fb2 <strlen>
     40b:	01 d8                	add    %ebx,%eax
     40d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     410:	8b 45 f4             	mov    -0xc(%ebp),%eax
     413:	89 44 24 04          	mov    %eax,0x4(%esp)
     417:	8d 45 08             	lea    0x8(%ebp),%eax
     41a:	89 04 24             	mov    %eax,(%esp)
     41d:	e8 60 00 00 00       	call   482 <parseline>
     422:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     425:	c7 44 24 08 6c 18 00 	movl   $0x186c,0x8(%esp)
     42c:	00 
     42d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     430:	89 44 24 04          	mov    %eax,0x4(%esp)
     434:	8d 45 08             	lea    0x8(%ebp),%eax
     437:	89 04 24             	mov    %eax,(%esp)
     43a:	e8 42 ff ff ff       	call   381 <peek>
  if(s != es){
     43f:	8b 45 08             	mov    0x8(%ebp),%eax
     442:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     445:	74 27                	je     46e <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     447:	8b 45 08             	mov    0x8(%ebp),%eax
     44a:	89 44 24 08          	mov    %eax,0x8(%esp)
     44e:	c7 44 24 04 6d 18 00 	movl   $0x186d,0x4(%esp)
     455:	00 
     456:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     45d:	e8 39 10 00 00       	call   149b <printf>
    panic("syntax");
     462:	c7 04 24 7c 18 00 00 	movl   $0x187c,(%esp)
     469:	e8 f0 fb ff ff       	call   5e <panic>
  }
  nulterminate(cmd);
     46e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     471:	89 04 24             	mov    %eax,(%esp)
     474:	e8 a5 04 00 00       	call   91e <nulterminate>
  return cmd;
     479:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     47c:	83 c4 24             	add    $0x24,%esp
     47f:	5b                   	pop    %ebx
     480:	5d                   	pop    %ebp
     481:	c3                   	ret    

00000482 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     482:	55                   	push   %ebp
     483:	89 e5                	mov    %esp,%ebp
     485:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;
  
  cmd = parsepipe(ps, es);
     488:	8b 45 0c             	mov    0xc(%ebp),%eax
     48b:	89 44 24 04          	mov    %eax,0x4(%esp)
     48f:	8b 45 08             	mov    0x8(%ebp),%eax
     492:	89 04 24             	mov    %eax,(%esp)
     495:	e8 bc 00 00 00       	call   556 <parsepipe>
     49a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     49d:	eb 30                	jmp    4cf <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     49f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     4a6:	00 
     4a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     4ae:	00 
     4af:	8b 45 0c             	mov    0xc(%ebp),%eax
     4b2:	89 44 24 04          	mov    %eax,0x4(%esp)
     4b6:	8b 45 08             	mov    0x8(%ebp),%eax
     4b9:	89 04 24             	mov    %eax,(%esp)
     4bc:	e8 78 fd ff ff       	call   239 <gettoken>
    cmd = backcmd(cmd);
     4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c4:	89 04 24             	mov    %eax,(%esp)
     4c7:	e8 26 fd ff ff       	call   1f2 <backcmd>
     4cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;
  
  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     4cf:	c7 44 24 08 83 18 00 	movl   $0x1883,0x8(%esp)
     4d6:	00 
     4d7:	8b 45 0c             	mov    0xc(%ebp),%eax
     4da:	89 44 24 04          	mov    %eax,0x4(%esp)
     4de:	8b 45 08             	mov    0x8(%ebp),%eax
     4e1:	89 04 24             	mov    %eax,(%esp)
     4e4:	e8 98 fe ff ff       	call   381 <peek>
     4e9:	85 c0                	test   %eax,%eax
     4eb:	75 b2                	jne    49f <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
 
  if(peek(ps, es, ";")){
     4ed:	c7 44 24 08 85 18 00 	movl   $0x1885,0x8(%esp)
     4f4:	00 
     4f5:	8b 45 0c             	mov    0xc(%ebp),%eax
     4f8:	89 44 24 04          	mov    %eax,0x4(%esp)
     4fc:	8b 45 08             	mov    0x8(%ebp),%eax
     4ff:	89 04 24             	mov    %eax,(%esp)
     502:	e8 7a fe ff ff       	call   381 <peek>
     507:	85 c0                	test   %eax,%eax
     509:	74 46                	je     551 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     50b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     512:	00 
     513:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     51a:	00 
     51b:	8b 45 0c             	mov    0xc(%ebp),%eax
     51e:	89 44 24 04          	mov    %eax,0x4(%esp)
     522:	8b 45 08             	mov    0x8(%ebp),%eax
     525:	89 04 24             	mov    %eax,(%esp)
     528:	e8 0c fd ff ff       	call   239 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     52d:	8b 45 0c             	mov    0xc(%ebp),%eax
     530:	89 44 24 04          	mov    %eax,0x4(%esp)
     534:	8b 45 08             	mov    0x8(%ebp),%eax
     537:	89 04 24             	mov    %eax,(%esp)
     53a:	e8 43 ff ff ff       	call   482 <parseline>
     53f:	89 44 24 04          	mov    %eax,0x4(%esp)
     543:	8b 45 f4             	mov    -0xc(%ebp),%eax
     546:	89 04 24             	mov    %eax,(%esp)
     549:	e8 54 fc ff ff       	call   1a2 <listcmd>
     54e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     551:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     554:	c9                   	leave  
     555:	c3                   	ret    

00000556 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     556:	55                   	push   %ebp
     557:	89 e5                	mov    %esp,%ebp
     559:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     55c:	8b 45 0c             	mov    0xc(%ebp),%eax
     55f:	89 44 24 04          	mov    %eax,0x4(%esp)
     563:	8b 45 08             	mov    0x8(%ebp),%eax
     566:	89 04 24             	mov    %eax,(%esp)
     569:	e8 68 02 00 00       	call   7d6 <parseexec>
     56e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     571:	c7 44 24 08 87 18 00 	movl   $0x1887,0x8(%esp)
     578:	00 
     579:	8b 45 0c             	mov    0xc(%ebp),%eax
     57c:	89 44 24 04          	mov    %eax,0x4(%esp)
     580:	8b 45 08             	mov    0x8(%ebp),%eax
     583:	89 04 24             	mov    %eax,(%esp)
     586:	e8 f6 fd ff ff       	call   381 <peek>
     58b:	85 c0                	test   %eax,%eax
     58d:	74 46                	je     5d5 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     58f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     596:	00 
     597:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     59e:	00 
     59f:	8b 45 0c             	mov    0xc(%ebp),%eax
     5a2:	89 44 24 04          	mov    %eax,0x4(%esp)
     5a6:	8b 45 08             	mov    0x8(%ebp),%eax
     5a9:	89 04 24             	mov    %eax,(%esp)
     5ac:	e8 88 fc ff ff       	call   239 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     5b1:	8b 45 0c             	mov    0xc(%ebp),%eax
     5b4:	89 44 24 04          	mov    %eax,0x4(%esp)
     5b8:	8b 45 08             	mov    0x8(%ebp),%eax
     5bb:	89 04 24             	mov    %eax,(%esp)
     5be:	e8 93 ff ff ff       	call   556 <parsepipe>
     5c3:	89 44 24 04          	mov    %eax,0x4(%esp)
     5c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5ca:	89 04 24             	mov    %eax,(%esp)
     5cd:	e8 80 fb ff ff       	call   152 <pipecmd>
     5d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     5d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     5d8:	c9                   	leave  
     5d9:	c3                   	ret    

000005da <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     5da:	55                   	push   %ebp
     5db:	89 e5                	mov    %esp,%ebp
     5dd:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5e0:	e9 f6 00 00 00       	jmp    6db <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     5e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     5ec:	00 
     5ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     5f4:	00 
     5f5:	8b 45 10             	mov    0x10(%ebp),%eax
     5f8:	89 44 24 04          	mov    %eax,0x4(%esp)
     5fc:	8b 45 0c             	mov    0xc(%ebp),%eax
     5ff:	89 04 24             	mov    %eax,(%esp)
     602:	e8 32 fc ff ff       	call   239 <gettoken>
     607:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     60a:	8d 45 ec             	lea    -0x14(%ebp),%eax
     60d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     611:	8d 45 f0             	lea    -0x10(%ebp),%eax
     614:	89 44 24 08          	mov    %eax,0x8(%esp)
     618:	8b 45 10             	mov    0x10(%ebp),%eax
     61b:	89 44 24 04          	mov    %eax,0x4(%esp)
     61f:	8b 45 0c             	mov    0xc(%ebp),%eax
     622:	89 04 24             	mov    %eax,(%esp)
     625:	e8 0f fc ff ff       	call   239 <gettoken>
     62a:	83 f8 61             	cmp    $0x61,%eax
     62d:	74 0c                	je     63b <parseredirs+0x61>
      panic("missing file for redirection");
     62f:	c7 04 24 89 18 00 00 	movl   $0x1889,(%esp)
     636:	e8 23 fa ff ff       	call   5e <panic>
    switch(tok){
     63b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     63e:	83 f8 3c             	cmp    $0x3c,%eax
     641:	74 0f                	je     652 <parseredirs+0x78>
     643:	83 f8 3e             	cmp    $0x3e,%eax
     646:	74 38                	je     680 <parseredirs+0xa6>
     648:	83 f8 2b             	cmp    $0x2b,%eax
     64b:	74 61                	je     6ae <parseredirs+0xd4>
     64d:	e9 89 00 00 00       	jmp    6db <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     652:	8b 55 ec             	mov    -0x14(%ebp),%edx
     655:	8b 45 f0             	mov    -0x10(%ebp),%eax
     658:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     65f:	00 
     660:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     667:	00 
     668:	89 54 24 08          	mov    %edx,0x8(%esp)
     66c:	89 44 24 04          	mov    %eax,0x4(%esp)
     670:	8b 45 08             	mov    0x8(%ebp),%eax
     673:	89 04 24             	mov    %eax,(%esp)
     676:	e8 6c fa ff ff       	call   e7 <redircmd>
     67b:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     67e:	eb 5b                	jmp    6db <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     680:	8b 55 ec             	mov    -0x14(%ebp),%edx
     683:	8b 45 f0             	mov    -0x10(%ebp),%eax
     686:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     68d:	00 
     68e:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     695:	00 
     696:	89 54 24 08          	mov    %edx,0x8(%esp)
     69a:	89 44 24 04          	mov    %eax,0x4(%esp)
     69e:	8b 45 08             	mov    0x8(%ebp),%eax
     6a1:	89 04 24             	mov    %eax,(%esp)
     6a4:	e8 3e fa ff ff       	call   e7 <redircmd>
     6a9:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     6ac:	eb 2d                	jmp    6db <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     6ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
     6b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     6b4:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     6bb:	00 
     6bc:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     6c3:	00 
     6c4:	89 54 24 08          	mov    %edx,0x8(%esp)
     6c8:	89 44 24 04          	mov    %eax,0x4(%esp)
     6cc:	8b 45 08             	mov    0x8(%ebp),%eax
     6cf:	89 04 24             	mov    %eax,(%esp)
     6d2:	e8 10 fa ff ff       	call   e7 <redircmd>
     6d7:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     6da:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     6db:	c7 44 24 08 a6 18 00 	movl   $0x18a6,0x8(%esp)
     6e2:	00 
     6e3:	8b 45 10             	mov    0x10(%ebp),%eax
     6e6:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ea:	8b 45 0c             	mov    0xc(%ebp),%eax
     6ed:	89 04 24             	mov    %eax,(%esp)
     6f0:	e8 8c fc ff ff       	call   381 <peek>
     6f5:	85 c0                	test   %eax,%eax
     6f7:	0f 85 e8 fe ff ff    	jne    5e5 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     6fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
     700:	c9                   	leave  
     701:	c3                   	ret    

00000702 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     702:	55                   	push   %ebp
     703:	89 e5                	mov    %esp,%ebp
     705:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     708:	c7 44 24 08 a9 18 00 	movl   $0x18a9,0x8(%esp)
     70f:	00 
     710:	8b 45 0c             	mov    0xc(%ebp),%eax
     713:	89 44 24 04          	mov    %eax,0x4(%esp)
     717:	8b 45 08             	mov    0x8(%ebp),%eax
     71a:	89 04 24             	mov    %eax,(%esp)
     71d:	e8 5f fc ff ff       	call   381 <peek>
     722:	85 c0                	test   %eax,%eax
     724:	75 0c                	jne    732 <parseblock+0x30>
    panic("parseblock");
     726:	c7 04 24 ab 18 00 00 	movl   $0x18ab,(%esp)
     72d:	e8 2c f9 ff ff       	call   5e <panic>
  gettoken(ps, es, 0, 0);
     732:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     739:	00 
     73a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     741:	00 
     742:	8b 45 0c             	mov    0xc(%ebp),%eax
     745:	89 44 24 04          	mov    %eax,0x4(%esp)
     749:	8b 45 08             	mov    0x8(%ebp),%eax
     74c:	89 04 24             	mov    %eax,(%esp)
     74f:	e8 e5 fa ff ff       	call   239 <gettoken>
  cmd = parseline(ps, es);
     754:	8b 45 0c             	mov    0xc(%ebp),%eax
     757:	89 44 24 04          	mov    %eax,0x4(%esp)
     75b:	8b 45 08             	mov    0x8(%ebp),%eax
     75e:	89 04 24             	mov    %eax,(%esp)
     761:	e8 1c fd ff ff       	call   482 <parseline>
     766:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     769:	c7 44 24 08 b6 18 00 	movl   $0x18b6,0x8(%esp)
     770:	00 
     771:	8b 45 0c             	mov    0xc(%ebp),%eax
     774:	89 44 24 04          	mov    %eax,0x4(%esp)
     778:	8b 45 08             	mov    0x8(%ebp),%eax
     77b:	89 04 24             	mov    %eax,(%esp)
     77e:	e8 fe fb ff ff       	call   381 <peek>
     783:	85 c0                	test   %eax,%eax
     785:	75 0c                	jne    793 <parseblock+0x91>
    panic("syntax - missing )");
     787:	c7 04 24 b8 18 00 00 	movl   $0x18b8,(%esp)
     78e:	e8 cb f8 ff ff       	call   5e <panic>
  gettoken(ps, es, 0, 0);
     793:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     79a:	00 
     79b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7a2:	00 
     7a3:	8b 45 0c             	mov    0xc(%ebp),%eax
     7a6:	89 44 24 04          	mov    %eax,0x4(%esp)
     7aa:	8b 45 08             	mov    0x8(%ebp),%eax
     7ad:	89 04 24             	mov    %eax,(%esp)
     7b0:	e8 84 fa ff ff       	call   239 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     7b5:	8b 45 0c             	mov    0xc(%ebp),%eax
     7b8:	89 44 24 08          	mov    %eax,0x8(%esp)
     7bc:	8b 45 08             	mov    0x8(%ebp),%eax
     7bf:	89 44 24 04          	mov    %eax,0x4(%esp)
     7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7c6:	89 04 24             	mov    %eax,(%esp)
     7c9:	e8 0c fe ff ff       	call   5da <parseredirs>
     7ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     7d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     7d4:	c9                   	leave  
     7d5:	c3                   	ret    

000007d6 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     7d6:	55                   	push   %ebp
     7d7:	89 e5                	mov    %esp,%ebp
     7d9:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     7dc:	c7 44 24 08 a9 18 00 	movl   $0x18a9,0x8(%esp)
     7e3:	00 
     7e4:	8b 45 0c             	mov    0xc(%ebp),%eax
     7e7:	89 44 24 04          	mov    %eax,0x4(%esp)
     7eb:	8b 45 08             	mov    0x8(%ebp),%eax
     7ee:	89 04 24             	mov    %eax,(%esp)
     7f1:	e8 8b fb ff ff       	call   381 <peek>
     7f6:	85 c0                	test   %eax,%eax
     7f8:	74 17                	je     811 <parseexec+0x3b>
    return parseblock(ps, es);
     7fa:	8b 45 0c             	mov    0xc(%ebp),%eax
     7fd:	89 44 24 04          	mov    %eax,0x4(%esp)
     801:	8b 45 08             	mov    0x8(%ebp),%eax
     804:	89 04 24             	mov    %eax,(%esp)
     807:	e8 f6 fe ff ff       	call   702 <parseblock>
     80c:	e9 0b 01 00 00       	jmp    91c <parseexec+0x146>

  ret = execcmd();
     811:	e8 93 f8 ff ff       	call   a9 <execcmd>
     816:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     819:	8b 45 f0             	mov    -0x10(%ebp),%eax
     81c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     81f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     826:	8b 45 0c             	mov    0xc(%ebp),%eax
     829:	89 44 24 08          	mov    %eax,0x8(%esp)
     82d:	8b 45 08             	mov    0x8(%ebp),%eax
     830:	89 44 24 04          	mov    %eax,0x4(%esp)
     834:	8b 45 f0             	mov    -0x10(%ebp),%eax
     837:	89 04 24             	mov    %eax,(%esp)
     83a:	e8 9b fd ff ff       	call   5da <parseredirs>
     83f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     842:	e9 8e 00 00 00       	jmp    8d5 <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     847:	8d 45 e0             	lea    -0x20(%ebp),%eax
     84a:	89 44 24 0c          	mov    %eax,0xc(%esp)
     84e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     851:	89 44 24 08          	mov    %eax,0x8(%esp)
     855:	8b 45 0c             	mov    0xc(%ebp),%eax
     858:	89 44 24 04          	mov    %eax,0x4(%esp)
     85c:	8b 45 08             	mov    0x8(%ebp),%eax
     85f:	89 04 24             	mov    %eax,(%esp)
     862:	e8 d2 f9 ff ff       	call   239 <gettoken>
     867:	89 45 e8             	mov    %eax,-0x18(%ebp)
     86a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     86e:	0f 84 85 00 00 00    	je     8f9 <parseexec+0x123>
      break;
    if(tok != 'a')
     874:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     878:	74 0c                	je     886 <parseexec+0xb0>
      panic("syntax");
     87a:	c7 04 24 7c 18 00 00 	movl   $0x187c,(%esp)
     881:	e8 d8 f7 ff ff       	call   5e <panic>
    cmd->argv[argc] = q;
     886:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     889:	8b 45 ec             	mov    -0x14(%ebp),%eax
     88c:	8b 55 f4             	mov    -0xc(%ebp),%edx
     88f:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     893:	8b 55 e0             	mov    -0x20(%ebp),%edx
     896:	8b 45 ec             	mov    -0x14(%ebp),%eax
     899:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     89c:	83 c1 08             	add    $0x8,%ecx
     89f:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     8a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     8a7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     8ab:	7e 0c                	jle    8b9 <parseexec+0xe3>
      panic("too many args");
     8ad:	c7 04 24 cb 18 00 00 	movl   $0x18cb,(%esp)
     8b4:	e8 a5 f7 ff ff       	call   5e <panic>
    ret = parseredirs(ret, ps, es);
     8b9:	8b 45 0c             	mov    0xc(%ebp),%eax
     8bc:	89 44 24 08          	mov    %eax,0x8(%esp)
     8c0:	8b 45 08             	mov    0x8(%ebp),%eax
     8c3:	89 44 24 04          	mov    %eax,0x4(%esp)
     8c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     8ca:	89 04 24             	mov    %eax,(%esp)
     8cd:	e8 08 fd ff ff       	call   5da <parseredirs>
     8d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     8d5:	c7 44 24 08 d9 18 00 	movl   $0x18d9,0x8(%esp)
     8dc:	00 
     8dd:	8b 45 0c             	mov    0xc(%ebp),%eax
     8e0:	89 44 24 04          	mov    %eax,0x4(%esp)
     8e4:	8b 45 08             	mov    0x8(%ebp),%eax
     8e7:	89 04 24             	mov    %eax,(%esp)
     8ea:	e8 92 fa ff ff       	call   381 <peek>
     8ef:	85 c0                	test   %eax,%eax
     8f1:	0f 84 50 ff ff ff    	je     847 <parseexec+0x71>
     8f7:	eb 01                	jmp    8fa <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     8f9:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     8fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
     8fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
     900:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     907:	00 
  cmd->eargv[argc] = 0;
     908:	8b 45 ec             	mov    -0x14(%ebp),%eax
     90b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     90e:	83 c2 08             	add    $0x8,%edx
     911:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     918:	00 
  return ret;
     919:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     91c:	c9                   	leave  
     91d:	c3                   	ret    

0000091e <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     91e:	55                   	push   %ebp
     91f:	89 e5                	mov    %esp,%ebp
     921:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;
  
  if(cmd == 0)
     924:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     928:	75 0a                	jne    934 <nulterminate+0x16>
    return 0;
     92a:	b8 00 00 00 00       	mov    $0x0,%eax
     92f:	e9 c9 00 00 00       	jmp    9fd <nulterminate+0xdf>
  
  switch(cmd->type){
     934:	8b 45 08             	mov    0x8(%ebp),%eax
     937:	8b 00                	mov    (%eax),%eax
     939:	83 f8 05             	cmp    $0x5,%eax
     93c:	0f 87 b8 00 00 00    	ja     9fa <nulterminate+0xdc>
     942:	8b 04 85 e0 18 00 00 	mov    0x18e0(,%eax,4),%eax
     949:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     94b:	8b 45 08             	mov    0x8(%ebp),%eax
     94e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     958:	eb 14                	jmp    96e <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     95a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     95d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     960:	83 c2 08             	add    $0x8,%edx
     963:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     967:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     96a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     96e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     971:	8b 55 f4             	mov    -0xc(%ebp),%edx
     974:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     978:	85 c0                	test   %eax,%eax
     97a:	75 de                	jne    95a <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     97c:	eb 7c                	jmp    9fa <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     97e:	8b 45 08             	mov    0x8(%ebp),%eax
     981:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     984:	8b 45 ec             	mov    -0x14(%ebp),%eax
     987:	8b 40 04             	mov    0x4(%eax),%eax
     98a:	89 04 24             	mov    %eax,(%esp)
     98d:	e8 8c ff ff ff       	call   91e <nulterminate>
    *rcmd->efile = 0;
     992:	8b 45 ec             	mov    -0x14(%ebp),%eax
     995:	8b 40 0c             	mov    0xc(%eax),%eax
     998:	c6 00 00             	movb   $0x0,(%eax)
    break;
     99b:	eb 5d                	jmp    9fa <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     99d:	8b 45 08             	mov    0x8(%ebp),%eax
     9a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     9a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     9a6:	8b 40 04             	mov    0x4(%eax),%eax
     9a9:	89 04 24             	mov    %eax,(%esp)
     9ac:	e8 6d ff ff ff       	call   91e <nulterminate>
    nulterminate(pcmd->right);
     9b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     9b4:	8b 40 08             	mov    0x8(%eax),%eax
     9b7:	89 04 24             	mov    %eax,(%esp)
     9ba:	e8 5f ff ff ff       	call   91e <nulterminate>
    break;
     9bf:	eb 39                	jmp    9fa <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     9c1:	8b 45 08             	mov    0x8(%ebp),%eax
     9c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     9c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     9ca:	8b 40 04             	mov    0x4(%eax),%eax
     9cd:	89 04 24             	mov    %eax,(%esp)
     9d0:	e8 49 ff ff ff       	call   91e <nulterminate>
    nulterminate(lcmd->right);
     9d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     9d8:	8b 40 08             	mov    0x8(%eax),%eax
     9db:	89 04 24             	mov    %eax,(%esp)
     9de:	e8 3b ff ff ff       	call   91e <nulterminate>
    break;
     9e3:	eb 15                	jmp    9fa <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     9e5:	8b 45 08             	mov    0x8(%ebp),%eax
     9e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     9eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
     9ee:	8b 40 04             	mov    0x4(%eax),%eax
     9f1:	89 04 24             	mov    %eax,(%esp)
     9f4:	e8 25 ff ff ff       	call   91e <nulterminate>
    break;
     9f9:	90                   	nop
  }
  return cmd;
     9fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9fd:	c9                   	leave  
     9fe:	c3                   	ret    

000009ff <runcmd>:

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
     9ff:	55                   	push   %ebp
     a00:	89 e5                	mov    %esp,%ebp
     a02:	53                   	push   %ebx
     a03:	83 ec 64             	sub    $0x64,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;
  
  if(cmd == 0)
     a06:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     a0a:	75 05                	jne    a11 <runcmd+0x12>
    exit();
     a0c:	e8 03 09 00 00       	call   1314 <exit>
  switch(cmd->type){
     a11:	8b 45 08             	mov    0x8(%ebp),%eax
     a14:	8b 00                	mov    (%eax),%eax
     a16:	83 f8 05             	cmp    $0x5,%eax
     a19:	77 09                	ja     a24 <runcmd+0x25>
     a1b:	8b 04 85 24 19 00 00 	mov    0x1924(,%eax,4),%eax
     a22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
     a24:	c7 04 24 f8 18 00 00 	movl   $0x18f8,(%esp)
     a2b:	e8 2e f6 ff ff       	call   5e <panic>
    
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     a30:	8b 45 08             	mov    0x8(%ebp),%eax
     a33:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(ecmd->argv[0] == 0)
     a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a39:	8b 40 04             	mov    0x4(%eax),%eax
     a3c:	85 c0                	test   %eax,%eax
     a3e:	75 05                	jne    a45 <runcmd+0x46>
      exit();
     a40:	e8 cf 08 00 00       	call   1314 <exit>
    exec(ecmd->argv[0], ecmd->argv);
     a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a48:	8d 50 04             	lea    0x4(%eax),%edx
     a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a4e:	8b 40 04             	mov    0x4(%eax),%eax
     a51:	89 54 24 04          	mov    %edx,0x4(%esp)
     a55:	89 04 24             	mov    %eax,(%esp)
     a58:	e8 ff 08 00 00       	call   135c <exec>
    if(pathInit)
     a5d:	a1 14 1f 00 00       	mov    0x1f14,%eax
     a62:	85 c0                	test   %eax,%eax
     a64:	0f 84 e0 00 00 00    	je     b4a <runcmd+0x14b>
    {
      char *b = ecmd->argv[0];
     a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a6d:	8b 40 04             	mov    0x4(%eax),%eax
     a70:	89 45 ec             	mov    %eax,-0x14(%ebp)
      int i=0, x=strlen(b);
     a73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     a7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a7d:	89 04 24             	mov    %eax,(%esp)
     a80:	e8 2d 05 00 00       	call   fb2 <strlen>
     a85:	89 45 e8             	mov    %eax,-0x18(%ebp)
      char** temp2 = PATH;
     a88:	a1 10 1f 00 00       	mov    0x1f10,%eax
     a8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      for(;i<10 && *(PATH[i]);i++){
     a90:	e9 95 00 00 00       	jmp    b2a <runcmd+0x12b>
     a95:	89 e0                	mov    %esp,%eax
     a97:	89 c3                	mov    %eax,%ebx
	int z = strlen(*temp2);
     a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     a9c:	8b 00                	mov    (%eax),%eax
     a9e:	89 04 24             	mov    %eax,(%esp)
     aa1:	e8 0c 05 00 00       	call   fb2 <strlen>
     aa6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	char *a = temp2[i];
     aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aac:	c1 e0 02             	shl    $0x2,%eax
     aaf:	03 45 e4             	add    -0x1c(%ebp),%eax
     ab2:	8b 00                	mov    (%eax),%eax
     ab4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	char dest[x+z];
     ab7:	8b 45 e0             	mov    -0x20(%ebp),%eax
     aba:	8b 55 e8             	mov    -0x18(%ebp),%edx
     abd:	01 d0                	add    %edx,%eax
     abf:	8d 50 ff             	lea    -0x1(%eax),%edx
     ac2:	89 55 d8             	mov    %edx,-0x28(%ebp)
     ac5:	8d 50 0f             	lea    0xf(%eax),%edx
     ac8:	b8 10 00 00 00       	mov    $0x10,%eax
     acd:	83 e8 01             	sub    $0x1,%eax
     ad0:	01 d0                	add    %edx,%eax
     ad2:	c7 45 b4 10 00 00 00 	movl   $0x10,-0x4c(%ebp)
     ad9:	ba 00 00 00 00       	mov    $0x0,%edx
     ade:	f7 75 b4             	divl   -0x4c(%ebp)
     ae1:	6b c0 10             	imul   $0x10,%eax,%eax
     ae4:	29 c4                	sub    %eax,%esp
     ae6:	8d 44 24 0c          	lea    0xc(%esp),%eax
     aea:	83 c0 0f             	add    $0xf,%eax
     aed:	c1 e8 04             	shr    $0x4,%eax
     af0:	c1 e0 04             	shl    $0x4,%eax
     af3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	strcat(dest,a,b);
     af6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     af9:	8b 55 ec             	mov    -0x14(%ebp),%edx
     afc:	89 54 24 08          	mov    %edx,0x8(%esp)
     b00:	8b 55 dc             	mov    -0x24(%ebp),%edx
     b03:	89 54 24 04          	mov    %edx,0x4(%esp)
     b07:	89 04 24             	mov    %eax,(%esp)
     b0a:	e8 b7 07 00 00       	call   12c6 <strcat>
	exec(dest,ecmd->argv);
     b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b12:	8d 50 04             	lea    0x4(%eax),%edx
     b15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     b18:	89 54 24 04          	mov    %edx,0x4(%esp)
     b1c:	89 04 24             	mov    %eax,(%esp)
     b1f:	e8 38 08 00 00       	call   135c <exec>
     b24:	89 dc                	mov    %ebx,%esp
    if(pathInit)
    {
      char *b = ecmd->argv[0];
      int i=0, x=strlen(b);
      char** temp2 = PATH;
      for(;i<10 && *(PATH[i]);i++){
     b26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     b2a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     b2e:	7f 1a                	jg     b4a <runcmd+0x14b>
     b30:	a1 10 1f 00 00       	mov    0x1f10,%eax
     b35:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b38:	c1 e2 02             	shl    $0x2,%edx
     b3b:	01 d0                	add    %edx,%eax
     b3d:	8b 00                	mov    (%eax),%eax
     b3f:	0f b6 00             	movzbl (%eax),%eax
     b42:	84 c0                	test   %al,%al
     b44:	0f 85 4b ff ff ff    	jne    a95 <runcmd+0x96>
	char dest[x+z];
	strcat(dest,a,b);
	exec(dest,ecmd->argv);
      }
    }
    printf(2, "exec %s failed\n", ecmd->argv[0]);
     b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b4d:	8b 40 04             	mov    0x4(%eax),%eax
     b50:	89 44 24 08          	mov    %eax,0x8(%esp)
     b54:	c7 44 24 04 ff 18 00 	movl   $0x18ff,0x4(%esp)
     b5b:	00 
     b5c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     b63:	e8 33 09 00 00       	call   149b <printf>
    break;
     b68:	e9 84 01 00 00       	jmp    cf1 <runcmd+0x2f2>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     b6d:	8b 45 08             	mov    0x8(%ebp),%eax
     b70:	89 45 d0             	mov    %eax,-0x30(%ebp)
    close(rcmd->fd);
     b73:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b76:	8b 40 14             	mov    0x14(%eax),%eax
     b79:	89 04 24             	mov    %eax,(%esp)
     b7c:	e8 cb 07 00 00       	call   134c <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     b81:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b84:	8b 50 10             	mov    0x10(%eax),%edx
     b87:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b8a:	8b 40 08             	mov    0x8(%eax),%eax
     b8d:	89 54 24 04          	mov    %edx,0x4(%esp)
     b91:	89 04 24             	mov    %eax,(%esp)
     b94:	e8 cb 07 00 00       	call   1364 <open>
     b99:	85 c0                	test   %eax,%eax
     b9b:	79 23                	jns    bc0 <runcmd+0x1c1>
      printf(2, "open %s failed\n", rcmd->file);
     b9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
     ba0:	8b 40 08             	mov    0x8(%eax),%eax
     ba3:	89 44 24 08          	mov    %eax,0x8(%esp)
     ba7:	c7 44 24 04 0f 19 00 	movl   $0x190f,0x4(%esp)
     bae:	00 
     baf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     bb6:	e8 e0 08 00 00       	call   149b <printf>
      exit();
     bbb:	e8 54 07 00 00       	call   1314 <exit>
    }
    runcmd(rcmd->cmd);
     bc0:	8b 45 d0             	mov    -0x30(%ebp),%eax
     bc3:	8b 40 04             	mov    0x4(%eax),%eax
     bc6:	89 04 24             	mov    %eax,(%esp)
     bc9:	e8 31 fe ff ff       	call   9ff <runcmd>
    break;
     bce:	e9 1e 01 00 00       	jmp    cf1 <runcmd+0x2f2>

  case LIST:
    lcmd = (struct listcmd*)cmd;
     bd3:	8b 45 08             	mov    0x8(%ebp),%eax
     bd6:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(fork1() == 0)
     bd9:	e8 a6 f4 ff ff       	call   84 <fork1>
     bde:	85 c0                	test   %eax,%eax
     be0:	75 0e                	jne    bf0 <runcmd+0x1f1>
      runcmd(lcmd->left);
     be2:	8b 45 cc             	mov    -0x34(%ebp),%eax
     be5:	8b 40 04             	mov    0x4(%eax),%eax
     be8:	89 04 24             	mov    %eax,(%esp)
     beb:	e8 0f fe ff ff       	call   9ff <runcmd>
    wait();
     bf0:	e8 27 07 00 00       	call   131c <wait>
    runcmd(lcmd->right);
     bf5:	8b 45 cc             	mov    -0x34(%ebp),%eax
     bf8:	8b 40 08             	mov    0x8(%eax),%eax
     bfb:	89 04 24             	mov    %eax,(%esp)
     bfe:	e8 fc fd ff ff       	call   9ff <runcmd>
    break;
     c03:	e9 e9 00 00 00       	jmp    cf1 <runcmd+0x2f2>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c08:	8b 45 08             	mov    0x8(%ebp),%eax
     c0b:	89 45 c8             	mov    %eax,-0x38(%ebp)
    if(pipe(p) < 0)
     c0e:	8d 45 bc             	lea    -0x44(%ebp),%eax
     c11:	89 04 24             	mov    %eax,(%esp)
     c14:	e8 1b 07 00 00       	call   1334 <pipe>
     c19:	85 c0                	test   %eax,%eax
     c1b:	79 0c                	jns    c29 <runcmd+0x22a>
      panic("pipe");
     c1d:	c7 04 24 1f 19 00 00 	movl   $0x191f,(%esp)
     c24:	e8 35 f4 ff ff       	call   5e <panic>
    if(fork1() == 0){
     c29:	e8 56 f4 ff ff       	call   84 <fork1>
     c2e:	85 c0                	test   %eax,%eax
     c30:	75 3b                	jne    c6d <runcmd+0x26e>
      close(1);
     c32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c39:	e8 0e 07 00 00       	call   134c <close>
      dup(p[1]);
     c3e:	8b 45 c0             	mov    -0x40(%ebp),%eax
     c41:	89 04 24             	mov    %eax,(%esp)
     c44:	e8 53 07 00 00       	call   139c <dup>
      close(p[0]);
     c49:	8b 45 bc             	mov    -0x44(%ebp),%eax
     c4c:	89 04 24             	mov    %eax,(%esp)
     c4f:	e8 f8 06 00 00       	call   134c <close>
      close(p[1]);
     c54:	8b 45 c0             	mov    -0x40(%ebp),%eax
     c57:	89 04 24             	mov    %eax,(%esp)
     c5a:	e8 ed 06 00 00       	call   134c <close>
      runcmd(pcmd->left);
     c5f:	8b 45 c8             	mov    -0x38(%ebp),%eax
     c62:	8b 40 04             	mov    0x4(%eax),%eax
     c65:	89 04 24             	mov    %eax,(%esp)
     c68:	e8 92 fd ff ff       	call   9ff <runcmd>
    }
    if(fork1() == 0){
     c6d:	e8 12 f4 ff ff       	call   84 <fork1>
     c72:	85 c0                	test   %eax,%eax
     c74:	75 3b                	jne    cb1 <runcmd+0x2b2>
      close(0);
     c76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     c7d:	e8 ca 06 00 00       	call   134c <close>
      dup(p[0]);
     c82:	8b 45 bc             	mov    -0x44(%ebp),%eax
     c85:	89 04 24             	mov    %eax,(%esp)
     c88:	e8 0f 07 00 00       	call   139c <dup>
      close(p[0]);
     c8d:	8b 45 bc             	mov    -0x44(%ebp),%eax
     c90:	89 04 24             	mov    %eax,(%esp)
     c93:	e8 b4 06 00 00       	call   134c <close>
      close(p[1]);
     c98:	8b 45 c0             	mov    -0x40(%ebp),%eax
     c9b:	89 04 24             	mov    %eax,(%esp)
     c9e:	e8 a9 06 00 00       	call   134c <close>
      runcmd(pcmd->right);
     ca3:	8b 45 c8             	mov    -0x38(%ebp),%eax
     ca6:	8b 40 08             	mov    0x8(%eax),%eax
     ca9:	89 04 24             	mov    %eax,(%esp)
     cac:	e8 4e fd ff ff       	call   9ff <runcmd>
    }
    close(p[0]);
     cb1:	8b 45 bc             	mov    -0x44(%ebp),%eax
     cb4:	89 04 24             	mov    %eax,(%esp)
     cb7:	e8 90 06 00 00       	call   134c <close>
    close(p[1]);
     cbc:	8b 45 c0             	mov    -0x40(%ebp),%eax
     cbf:	89 04 24             	mov    %eax,(%esp)
     cc2:	e8 85 06 00 00       	call   134c <close>
    wait();
     cc7:	e8 50 06 00 00       	call   131c <wait>
    wait();
     ccc:	e8 4b 06 00 00       	call   131c <wait>
    break;
     cd1:	eb 1e                	jmp    cf1 <runcmd+0x2f2>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     cd3:	8b 45 08             	mov    0x8(%ebp),%eax
     cd6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    if(fork1() == 0)
     cd9:	e8 a6 f3 ff ff       	call   84 <fork1>
     cde:	85 c0                	test   %eax,%eax
     ce0:	75 0e                	jne    cf0 <runcmd+0x2f1>
      runcmd(bcmd->cmd);
     ce2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     ce5:	8b 40 04             	mov    0x4(%eax),%eax
     ce8:	89 04 24             	mov    %eax,(%esp)
     ceb:	e8 0f fd ff ff       	call   9ff <runcmd>
    break;
     cf0:	90                   	nop
  }
  exit();
     cf1:	e8 1e 06 00 00       	call   1314 <exit>

00000cf6 <main>:
}

int
main(void)
{
     cf6:	55                   	push   %ebp
     cf7:	89 e5                	mov    %esp,%ebp
     cf9:	53                   	push   %ebx
     cfa:	83 e4 f0             	and    $0xfffffff0,%esp
     cfd:	83 ec 30             	sub    $0x30,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     d00:	eb 19                	jmp    d1b <main+0x25>
    if(fd >= 3){
     d02:	83 7c 24 24 02       	cmpl   $0x2,0x24(%esp)
     d07:	7e 12                	jle    d1b <main+0x25>
      close(fd);
     d09:	8b 44 24 24          	mov    0x24(%esp),%eax
     d0d:	89 04 24             	mov    %eax,(%esp)
     d10:	e8 37 06 00 00       	call   134c <close>
      break;
     d15:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     d16:	e9 d9 01 00 00       	jmp    ef4 <main+0x1fe>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     d1b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     d22:	00 
     d23:	c7 04 24 3c 19 00 00 	movl   $0x193c,(%esp)
     d2a:	e8 35 06 00 00       	call   1364 <open>
     d2f:	89 44 24 24          	mov    %eax,0x24(%esp)
     d33:	83 7c 24 24 00       	cmpl   $0x0,0x24(%esp)
     d38:	79 c8                	jns    d02 <main+0xc>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     d3a:	e9 b5 01 00 00       	jmp    ef4 <main+0x1fe>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     d3f:	0f b6 05 a0 1e 00 00 	movzbl 0x1ea0,%eax
     d46:	3c 63                	cmp    $0x63,%al
     d48:	75 61                	jne    dab <main+0xb5>
     d4a:	0f b6 05 a1 1e 00 00 	movzbl 0x1ea1,%eax
     d51:	3c 64                	cmp    $0x64,%al
     d53:	75 56                	jne    dab <main+0xb5>
     d55:	0f b6 05 a2 1e 00 00 	movzbl 0x1ea2,%eax
     d5c:	3c 20                	cmp    $0x20,%al
     d5e:	75 4b                	jne    dab <main+0xb5>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     d60:	c7 04 24 a0 1e 00 00 	movl   $0x1ea0,(%esp)
     d67:	e8 46 02 00 00       	call   fb2 <strlen>
     d6c:	83 e8 01             	sub    $0x1,%eax
     d6f:	c6 80 a0 1e 00 00 00 	movb   $0x0,0x1ea0(%eax)
      if(chdir(buf+3) < 0)
     d76:	c7 04 24 a3 1e 00 00 	movl   $0x1ea3,(%esp)
     d7d:	e8 12 06 00 00       	call   1394 <chdir>
     d82:	85 c0                	test   %eax,%eax
     d84:	0f 89 69 01 00 00    	jns    ef3 <main+0x1fd>
        printf(2, "cannot cd %s\n", buf+3);
     d8a:	c7 44 24 08 a3 1e 00 	movl   $0x1ea3,0x8(%esp)
     d91:	00 
     d92:	c7 44 24 04 44 19 00 	movl   $0x1944,0x4(%esp)
     d99:	00 
     d9a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     da1:	e8 f5 06 00 00       	call   149b <printf>
      continue;
     da6:	e9 48 01 00 00       	jmp    ef3 <main+0x1fd>
    }
    if(!strncmp(buf,"export PATH",11)){
     dab:	c7 44 24 08 0b 00 00 	movl   $0xb,0x8(%esp)
     db2:	00 
     db3:	c7 44 24 04 52 19 00 	movl   $0x1952,0x4(%esp)
     dba:	00 
     dbb:	c7 04 24 a0 1e 00 00 	movl   $0x1ea0,(%esp)
     dc2:	e8 a7 04 00 00       	call   126e <strncmp>
     dc7:	85 c0                	test   %eax,%eax
     dc9:	0f 85 00 01 00 00    	jne    ecf <main+0x1d9>
      //buf = buf+12;
      PATH = malloc(10*sizeof(char*));
     dcf:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
     dd6:	e8 a4 09 00 00       	call   177f <malloc>
     ddb:	a3 10 1f 00 00       	mov    %eax,0x1f10
      memset(PATH, 0, 10*sizeof(char*));
     de0:	a1 10 1f 00 00       	mov    0x1f10,%eax
     de5:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
     dec:	00 
     ded:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     df4:	00 
     df5:	89 04 24             	mov    %eax,(%esp)
     df8:	e8 da 01 00 00       	call   fd7 <memset>
      int i;
      for(i=0;i<10;i++){
     dfd:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
     e04:	00 
     e05:	eb 4a                	jmp    e51 <main+0x15b>
	PATH[i] = malloc(100);
     e07:	a1 10 1f 00 00       	mov    0x1f10,%eax
     e0c:	8b 54 24 2c          	mov    0x2c(%esp),%edx
     e10:	c1 e2 02             	shl    $0x2,%edx
     e13:	8d 1c 10             	lea    (%eax,%edx,1),%ebx
     e16:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
     e1d:	e8 5d 09 00 00       	call   177f <malloc>
     e22:	89 03                	mov    %eax,(%ebx)
	memset(PATH[i],0,100);
     e24:	a1 10 1f 00 00       	mov    0x1f10,%eax
     e29:	8b 54 24 2c          	mov    0x2c(%esp),%edx
     e2d:	c1 e2 02             	shl    $0x2,%edx
     e30:	01 d0                	add    %edx,%eax
     e32:	8b 00                	mov    (%eax),%eax
     e34:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
     e3b:	00 
     e3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     e43:	00 
     e44:	89 04 24             	mov    %eax,(%esp)
     e47:	e8 8b 01 00 00       	call   fd7 <memset>
    if(!strncmp(buf,"export PATH",11)){
      //buf = buf+12;
      PATH = malloc(10*sizeof(char*));
      memset(PATH, 0, 10*sizeof(char*));
      int i;
      for(i=0;i<10;i++){
     e4c:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
     e51:	83 7c 24 2c 09       	cmpl   $0x9,0x2c(%esp)
     e56:	7e af                	jle    e07 <main+0x111>
	PATH[i] = malloc(100);
	memset(PATH[i],0,100);
      }
      pathInit = 1;
     e58:	c7 05 14 1f 00 00 01 	movl   $0x1,0x1f14
     e5f:	00 00 00 
      int tempIndex = 0;
     e62:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
     e69:	00 
      int* beginIndex = &tempIndex;
     e6a:	8d 44 24 18          	lea    0x18(%esp),%eax
     e6e:	89 44 24 20          	mov    %eax,0x20(%esp)
      int length = strlen(&(buf[12]));
     e72:	c7 04 24 ac 1e 00 00 	movl   $0x1eac,(%esp)
     e79:	e8 34 01 00 00       	call   fb2 <strlen>
     e7e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
      char** temp = PATH;
     e82:	a1 10 1f 00 00       	mov    0x1f10,%eax
     e87:	89 44 24 28          	mov    %eax,0x28(%esp)
      while(*beginIndex<length-1)
     e8b:	eb 2f                	jmp    ebc <main+0x1c6>
      {
	if(strtok(*temp,&(buf[12]),':',beginIndex))
     e8d:	8b 44 24 28          	mov    0x28(%esp),%eax
     e91:	8b 00                	mov    (%eax),%eax
     e93:	8b 54 24 20          	mov    0x20(%esp),%edx
     e97:	89 54 24 0c          	mov    %edx,0xc(%esp)
     e9b:	c7 44 24 08 3a 00 00 	movl   $0x3a,0x8(%esp)
     ea2:	00 
     ea3:	c7 44 24 04 ac 1e 00 	movl   $0x1eac,0x4(%esp)
     eaa:	00 
     eab:	89 04 24             	mov    %eax,(%esp)
     eae:	e8 be 02 00 00       	call   1171 <strtok>
     eb3:	85 c0                	test   %eax,%eax
     eb5:	74 05                	je     ebc <main+0x1c6>
	{
	(temp)++;
     eb7:	83 44 24 28 04       	addl   $0x4,0x28(%esp)
      pathInit = 1;
      int tempIndex = 0;
      int* beginIndex = &tempIndex;
      int length = strlen(&(buf[12]));
      char** temp = PATH;
      while(*beginIndex<length-1)
     ebc:	8b 44 24 20          	mov    0x20(%esp),%eax
     ec0:	8b 00                	mov    (%eax),%eax
     ec2:	8b 54 24 1c          	mov    0x1c(%esp),%edx
     ec6:	83 ea 01             	sub    $0x1,%edx
     ec9:	39 d0                	cmp    %edx,%eax
     ecb:	7c c0                	jl     e8d <main+0x197>
	if(strtok(*temp,&(buf[12]),':',beginIndex))
	{
	(temp)++;
	}
      }
      continue;
     ecd:	eb 25                	jmp    ef4 <main+0x1fe>
    }
    if(fork1() == 0)
     ecf:	e8 b0 f1 ff ff       	call   84 <fork1>
     ed4:	85 c0                	test   %eax,%eax
     ed6:	75 14                	jne    eec <main+0x1f6>
    {
      runcmd(parsecmd(buf));
     ed8:	c7 04 24 a0 1e 00 00 	movl   $0x1ea0,(%esp)
     edf:	e8 12 f5 ff ff       	call   3f6 <parsecmd>
     ee4:	89 04 24             	mov    %eax,(%esp)
     ee7:	e8 13 fb ff ff       	call   9ff <runcmd>
    }
    wait();
     eec:	e8 2b 04 00 00       	call   131c <wait>
     ef1:	eb 01                	jmp    ef4 <main+0x1fe>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     ef3:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     ef4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     efb:	00 
     efc:	c7 04 24 a0 1e 00 00 	movl   $0x1ea0,(%esp)
     f03:	e8 f8 f0 ff ff       	call   0 <getcmd>
     f08:	85 c0                	test   %eax,%eax
     f0a:	0f 89 2f fe ff ff    	jns    d3f <main+0x49>
    {
      runcmd(parsecmd(buf));
    }
    wait();
  }
  exit();
     f10:	e8 ff 03 00 00       	call   1314 <exit>
     f15:	90                   	nop
     f16:	90                   	nop
     f17:	90                   	nop

00000f18 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     f18:	55                   	push   %ebp
     f19:	89 e5                	mov    %esp,%ebp
     f1b:	57                   	push   %edi
     f1c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     f1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
     f20:	8b 55 10             	mov    0x10(%ebp),%edx
     f23:	8b 45 0c             	mov    0xc(%ebp),%eax
     f26:	89 cb                	mov    %ecx,%ebx
     f28:	89 df                	mov    %ebx,%edi
     f2a:	89 d1                	mov    %edx,%ecx
     f2c:	fc                   	cld    
     f2d:	f3 aa                	rep stos %al,%es:(%edi)
     f2f:	89 ca                	mov    %ecx,%edx
     f31:	89 fb                	mov    %edi,%ebx
     f33:	89 5d 08             	mov    %ebx,0x8(%ebp)
     f36:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     f39:	5b                   	pop    %ebx
     f3a:	5f                   	pop    %edi
     f3b:	5d                   	pop    %ebp
     f3c:	c3                   	ret    

00000f3d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     f3d:	55                   	push   %ebp
     f3e:	89 e5                	mov    %esp,%ebp
     f40:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     f43:	8b 45 08             	mov    0x8(%ebp),%eax
     f46:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     f49:	90                   	nop
     f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
     f4d:	0f b6 10             	movzbl (%eax),%edx
     f50:	8b 45 08             	mov    0x8(%ebp),%eax
     f53:	88 10                	mov    %dl,(%eax)
     f55:	8b 45 08             	mov    0x8(%ebp),%eax
     f58:	0f b6 00             	movzbl (%eax),%eax
     f5b:	84 c0                	test   %al,%al
     f5d:	0f 95 c0             	setne  %al
     f60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f64:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     f68:	84 c0                	test   %al,%al
     f6a:	75 de                	jne    f4a <strcpy+0xd>
    ;
  return os;
     f6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f6f:	c9                   	leave  
     f70:	c3                   	ret    

00000f71 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     f71:	55                   	push   %ebp
     f72:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     f74:	eb 08                	jmp    f7e <strcmp+0xd>
    p++, q++;
     f76:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f7a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     f7e:	8b 45 08             	mov    0x8(%ebp),%eax
     f81:	0f b6 00             	movzbl (%eax),%eax
     f84:	84 c0                	test   %al,%al
     f86:	74 10                	je     f98 <strcmp+0x27>
     f88:	8b 45 08             	mov    0x8(%ebp),%eax
     f8b:	0f b6 10             	movzbl (%eax),%edx
     f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
     f91:	0f b6 00             	movzbl (%eax),%eax
     f94:	38 c2                	cmp    %al,%dl
     f96:	74 de                	je     f76 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     f98:	8b 45 08             	mov    0x8(%ebp),%eax
     f9b:	0f b6 00             	movzbl (%eax),%eax
     f9e:	0f b6 d0             	movzbl %al,%edx
     fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
     fa4:	0f b6 00             	movzbl (%eax),%eax
     fa7:	0f b6 c0             	movzbl %al,%eax
     faa:	89 d1                	mov    %edx,%ecx
     fac:	29 c1                	sub    %eax,%ecx
     fae:	89 c8                	mov    %ecx,%eax
}
     fb0:	5d                   	pop    %ebp
     fb1:	c3                   	ret    

00000fb2 <strlen>:

uint
strlen(char *s)
{
     fb2:	55                   	push   %ebp
     fb3:	89 e5                	mov    %esp,%ebp
     fb5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
     fb8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     fbf:	eb 04                	jmp    fc5 <strlen+0x13>
     fc1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     fc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fc8:	03 45 08             	add    0x8(%ebp),%eax
     fcb:	0f b6 00             	movzbl (%eax),%eax
     fce:	84 c0                	test   %al,%al
     fd0:	75 ef                	jne    fc1 <strlen+0xf>
  return n;
     fd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     fd5:	c9                   	leave  
     fd6:	c3                   	ret    

00000fd7 <memset>:

void*
memset(void *dst, int c, uint n)
{
     fd7:	55                   	push   %ebp
     fd8:	89 e5                	mov    %esp,%ebp
     fda:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     fdd:	8b 45 10             	mov    0x10(%ebp),%eax
     fe0:	89 44 24 08          	mov    %eax,0x8(%esp)
     fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
     fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
     feb:	8b 45 08             	mov    0x8(%ebp),%eax
     fee:	89 04 24             	mov    %eax,(%esp)
     ff1:	e8 22 ff ff ff       	call   f18 <stosb>
  return dst;
     ff6:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ff9:	c9                   	leave  
     ffa:	c3                   	ret    

00000ffb <strchr>:

char*
strchr(const char *s, char c)
{
     ffb:	55                   	push   %ebp
     ffc:	89 e5                	mov    %esp,%ebp
     ffe:	83 ec 04             	sub    $0x4,%esp
    1001:	8b 45 0c             	mov    0xc(%ebp),%eax
    1004:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1007:	eb 14                	jmp    101d <strchr+0x22>
    if(*s == c)
    1009:	8b 45 08             	mov    0x8(%ebp),%eax
    100c:	0f b6 00             	movzbl (%eax),%eax
    100f:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1012:	75 05                	jne    1019 <strchr+0x1e>
      return (char*)s;
    1014:	8b 45 08             	mov    0x8(%ebp),%eax
    1017:	eb 13                	jmp    102c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1019:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    101d:	8b 45 08             	mov    0x8(%ebp),%eax
    1020:	0f b6 00             	movzbl (%eax),%eax
    1023:	84 c0                	test   %al,%al
    1025:	75 e2                	jne    1009 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1027:	b8 00 00 00 00       	mov    $0x0,%eax
}
    102c:	c9                   	leave  
    102d:	c3                   	ret    

0000102e <gets>:

char*
gets(char *buf, int max)
{
    102e:	55                   	push   %ebp
    102f:	89 e5                	mov    %esp,%ebp
    1031:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1034:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    103b:	eb 44                	jmp    1081 <gets+0x53>
    cc = read(0, &c, 1);
    103d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1044:	00 
    1045:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1048:	89 44 24 04          	mov    %eax,0x4(%esp)
    104c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1053:	e8 e4 02 00 00       	call   133c <read>
    1058:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    105b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    105f:	7e 2d                	jle    108e <gets+0x60>
      break;
    buf[i++] = c;
    1061:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1064:	03 45 08             	add    0x8(%ebp),%eax
    1067:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
    106b:	88 10                	mov    %dl,(%eax)
    106d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    1071:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1075:	3c 0a                	cmp    $0xa,%al
    1077:	74 16                	je     108f <gets+0x61>
    1079:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    107d:	3c 0d                	cmp    $0xd,%al
    107f:	74 0e                	je     108f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1081:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1084:	83 c0 01             	add    $0x1,%eax
    1087:	3b 45 0c             	cmp    0xc(%ebp),%eax
    108a:	7c b1                	jl     103d <gets+0xf>
    108c:	eb 01                	jmp    108f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    108e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    108f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1092:	03 45 08             	add    0x8(%ebp),%eax
    1095:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1098:	8b 45 08             	mov    0x8(%ebp),%eax
}
    109b:	c9                   	leave  
    109c:	c3                   	ret    

0000109d <stat>:

int
stat(char *n, struct stat *st)
{
    109d:	55                   	push   %ebp
    109e:	89 e5                	mov    %esp,%ebp
    10a0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    10a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    10aa:	00 
    10ab:	8b 45 08             	mov    0x8(%ebp),%eax
    10ae:	89 04 24             	mov    %eax,(%esp)
    10b1:	e8 ae 02 00 00       	call   1364 <open>
    10b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    10b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10bd:	79 07                	jns    10c6 <stat+0x29>
    return -1;
    10bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    10c4:	eb 23                	jmp    10e9 <stat+0x4c>
  r = fstat(fd, st);
    10c6:	8b 45 0c             	mov    0xc(%ebp),%eax
    10c9:	89 44 24 04          	mov    %eax,0x4(%esp)
    10cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10d0:	89 04 24             	mov    %eax,(%esp)
    10d3:	e8 a4 02 00 00       	call   137c <fstat>
    10d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    10db:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10de:	89 04 24             	mov    %eax,(%esp)
    10e1:	e8 66 02 00 00       	call   134c <close>
  return r;
    10e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    10e9:	c9                   	leave  
    10ea:	c3                   	ret    

000010eb <atoi>:

int
atoi(const char *s)
{
    10eb:	55                   	push   %ebp
    10ec:	89 e5                	mov    %esp,%ebp
    10ee:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    10f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    10f8:	eb 23                	jmp    111d <atoi+0x32>
    n = n*10 + *s++ - '0';
    10fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
    10fd:	89 d0                	mov    %edx,%eax
    10ff:	c1 e0 02             	shl    $0x2,%eax
    1102:	01 d0                	add    %edx,%eax
    1104:	01 c0                	add    %eax,%eax
    1106:	89 c2                	mov    %eax,%edx
    1108:	8b 45 08             	mov    0x8(%ebp),%eax
    110b:	0f b6 00             	movzbl (%eax),%eax
    110e:	0f be c0             	movsbl %al,%eax
    1111:	01 d0                	add    %edx,%eax
    1113:	83 e8 30             	sub    $0x30,%eax
    1116:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1119:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    111d:	8b 45 08             	mov    0x8(%ebp),%eax
    1120:	0f b6 00             	movzbl (%eax),%eax
    1123:	3c 2f                	cmp    $0x2f,%al
    1125:	7e 0a                	jle    1131 <atoi+0x46>
    1127:	8b 45 08             	mov    0x8(%ebp),%eax
    112a:	0f b6 00             	movzbl (%eax),%eax
    112d:	3c 39                	cmp    $0x39,%al
    112f:	7e c9                	jle    10fa <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1131:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1134:	c9                   	leave  
    1135:	c3                   	ret    

00001136 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1136:	55                   	push   %ebp
    1137:	89 e5                	mov    %esp,%ebp
    1139:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    113c:	8b 45 08             	mov    0x8(%ebp),%eax
    113f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1142:	8b 45 0c             	mov    0xc(%ebp),%eax
    1145:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1148:	eb 13                	jmp    115d <memmove+0x27>
    *dst++ = *src++;
    114a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    114d:	0f b6 10             	movzbl (%eax),%edx
    1150:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1153:	88 10                	mov    %dl,(%eax)
    1155:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1159:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    115d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    1161:	0f 9f c0             	setg   %al
    1164:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1168:	84 c0                	test   %al,%al
    116a:	75 de                	jne    114a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    116c:	8b 45 08             	mov    0x8(%ebp),%eax
}
    116f:	c9                   	leave  
    1170:	c3                   	ret    

00001171 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
    1171:	55                   	push   %ebp
    1172:	89 e5                	mov    %esp,%ebp
    1174:	83 ec 38             	sub    $0x38,%esp
    1177:	8b 45 10             	mov    0x10(%ebp),%eax
    117a:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
    117d:	8b 45 14             	mov    0x14(%ebp),%eax
    1180:	8b 00                	mov    (%eax),%eax
    1182:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1185:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
    118c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1190:	74 06                	je     1198 <strtok+0x27>
    1192:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
    1196:	75 54                	jne    11ec <strtok+0x7b>
    return match;
    1198:	8b 45 f0             	mov    -0x10(%ebp),%eax
    119b:	eb 6e                	jmp    120b <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
    119d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11a0:	03 45 0c             	add    0xc(%ebp),%eax
    11a3:	0f b6 00             	movzbl (%eax),%eax
    11a6:	3a 45 e4             	cmp    -0x1c(%ebp),%al
    11a9:	74 06                	je     11b1 <strtok+0x40>
      {
	index++;
    11ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    11af:	eb 3c                	jmp    11ed <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
    11b1:	8b 45 14             	mov    0x14(%ebp),%eax
    11b4:	8b 00                	mov    (%eax),%eax
    11b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11b9:	29 c2                	sub    %eax,%edx
    11bb:	8b 45 14             	mov    0x14(%ebp),%eax
    11be:	8b 00                	mov    (%eax),%eax
    11c0:	03 45 0c             	add    0xc(%ebp),%eax
    11c3:	89 54 24 08          	mov    %edx,0x8(%esp)
    11c7:	89 44 24 04          	mov    %eax,0x4(%esp)
    11cb:	8b 45 08             	mov    0x8(%ebp),%eax
    11ce:	89 04 24             	mov    %eax,(%esp)
    11d1:	e8 37 00 00 00       	call   120d <strncpy>
    11d6:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
    11d9:	8b 45 08             	mov    0x8(%ebp),%eax
    11dc:	0f b6 00             	movzbl (%eax),%eax
    11df:	84 c0                	test   %al,%al
    11e1:	74 19                	je     11fc <strtok+0x8b>
	  match = 1;
    11e3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
    11ea:	eb 10                	jmp    11fc <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
    11ec:	90                   	nop
    11ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11f0:	03 45 0c             	add    0xc(%ebp),%eax
    11f3:	0f b6 00             	movzbl (%eax),%eax
    11f6:	84 c0                	test   %al,%al
    11f8:	75 a3                	jne    119d <strtok+0x2c>
    11fa:	eb 01                	jmp    11fd <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
    11fc:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
    11fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1200:	8d 50 01             	lea    0x1(%eax),%edx
    1203:	8b 45 14             	mov    0x14(%ebp),%eax
    1206:	89 10                	mov    %edx,(%eax)
  return match;
    1208:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    120b:	c9                   	leave  
    120c:	c3                   	ret    

0000120d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    120d:	55                   	push   %ebp
    120e:	89 e5                	mov    %esp,%ebp
    1210:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
    1213:	8b 45 08             	mov    0x8(%ebp),%eax
    1216:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
    1219:	90                   	nop
    121a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    121e:	0f 9f c0             	setg   %al
    1221:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1225:	84 c0                	test   %al,%al
    1227:	74 30                	je     1259 <strncpy+0x4c>
    1229:	8b 45 0c             	mov    0xc(%ebp),%eax
    122c:	0f b6 10             	movzbl (%eax),%edx
    122f:	8b 45 08             	mov    0x8(%ebp),%eax
    1232:	88 10                	mov    %dl,(%eax)
    1234:	8b 45 08             	mov    0x8(%ebp),%eax
    1237:	0f b6 00             	movzbl (%eax),%eax
    123a:	84 c0                	test   %al,%al
    123c:	0f 95 c0             	setne  %al
    123f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1243:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    1247:	84 c0                	test   %al,%al
    1249:	75 cf                	jne    121a <strncpy+0xd>
    ;
  while(n-- > 0)
    124b:	eb 0c                	jmp    1259 <strncpy+0x4c>
    *s++ = 0;
    124d:	8b 45 08             	mov    0x8(%ebp),%eax
    1250:	c6 00 00             	movb   $0x0,(%eax)
    1253:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1257:	eb 01                	jmp    125a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
    1259:	90                   	nop
    125a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    125e:	0f 9f c0             	setg   %al
    1261:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1265:	84 c0                	test   %al,%al
    1267:	75 e4                	jne    124d <strncpy+0x40>
    *s++ = 0;
  return os;
    1269:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    126c:	c9                   	leave  
    126d:	c3                   	ret    

0000126e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    126e:	55                   	push   %ebp
    126f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
    1271:	eb 0c                	jmp    127f <strncmp+0x11>
    n--, p++, q++;
    1273:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1277:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    127b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
    127f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    1283:	74 1a                	je     129f <strncmp+0x31>
    1285:	8b 45 08             	mov    0x8(%ebp),%eax
    1288:	0f b6 00             	movzbl (%eax),%eax
    128b:	84 c0                	test   %al,%al
    128d:	74 10                	je     129f <strncmp+0x31>
    128f:	8b 45 08             	mov    0x8(%ebp),%eax
    1292:	0f b6 10             	movzbl (%eax),%edx
    1295:	8b 45 0c             	mov    0xc(%ebp),%eax
    1298:	0f b6 00             	movzbl (%eax),%eax
    129b:	38 c2                	cmp    %al,%dl
    129d:	74 d4                	je     1273 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
    129f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    12a3:	75 07                	jne    12ac <strncmp+0x3e>
    return 0;
    12a5:	b8 00 00 00 00       	mov    $0x0,%eax
    12aa:	eb 18                	jmp    12c4 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
    12ac:	8b 45 08             	mov    0x8(%ebp),%eax
    12af:	0f b6 00             	movzbl (%eax),%eax
    12b2:	0f b6 d0             	movzbl %al,%edx
    12b5:	8b 45 0c             	mov    0xc(%ebp),%eax
    12b8:	0f b6 00             	movzbl (%eax),%eax
    12bb:	0f b6 c0             	movzbl %al,%eax
    12be:	89 d1                	mov    %edx,%ecx
    12c0:	29 c1                	sub    %eax,%ecx
    12c2:	89 c8                	mov    %ecx,%eax
}
    12c4:	5d                   	pop    %ebp
    12c5:	c3                   	ret    

000012c6 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
    12c6:	55                   	push   %ebp
    12c7:	89 e5                	mov    %esp,%ebp
  while(*p){
    12c9:	eb 13                	jmp    12de <strcat+0x18>
    *dest++ = *p++;
    12cb:	8b 45 0c             	mov    0xc(%ebp),%eax
    12ce:	0f b6 10             	movzbl (%eax),%edx
    12d1:	8b 45 08             	mov    0x8(%ebp),%eax
    12d4:	88 10                	mov    %dl,(%eax)
    12d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    12da:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    12de:	8b 45 0c             	mov    0xc(%ebp),%eax
    12e1:	0f b6 00             	movzbl (%eax),%eax
    12e4:	84 c0                	test   %al,%al
    12e6:	75 e3                	jne    12cb <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
    12e8:	eb 13                	jmp    12fd <strcat+0x37>
    *dest++ = *q++;
    12ea:	8b 45 10             	mov    0x10(%ebp),%eax
    12ed:	0f b6 10             	movzbl (%eax),%edx
    12f0:	8b 45 08             	mov    0x8(%ebp),%eax
    12f3:	88 10                	mov    %dl,(%eax)
    12f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    12f9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
    12fd:	8b 45 10             	mov    0x10(%ebp),%eax
    1300:	0f b6 00             	movzbl (%eax),%eax
    1303:	84 c0                	test   %al,%al
    1305:	75 e3                	jne    12ea <strcat+0x24>
    *dest++ = *q++;
  }  
    1307:	5d                   	pop    %ebp
    1308:	c3                   	ret    
    1309:	90                   	nop
    130a:	90                   	nop
    130b:	90                   	nop

0000130c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    130c:	b8 01 00 00 00       	mov    $0x1,%eax
    1311:	cd 40                	int    $0x40
    1313:	c3                   	ret    

00001314 <exit>:
SYSCALL(exit)
    1314:	b8 02 00 00 00       	mov    $0x2,%eax
    1319:	cd 40                	int    $0x40
    131b:	c3                   	ret    

0000131c <wait>:
SYSCALL(wait)
    131c:	b8 03 00 00 00       	mov    $0x3,%eax
    1321:	cd 40                	int    $0x40
    1323:	c3                   	ret    

00001324 <wait2>:
SYSCALL(wait2)
    1324:	b8 16 00 00 00       	mov    $0x16,%eax
    1329:	cd 40                	int    $0x40
    132b:	c3                   	ret    

0000132c <nice>:
SYSCALL(nice)
    132c:	b8 17 00 00 00       	mov    $0x17,%eax
    1331:	cd 40                	int    $0x40
    1333:	c3                   	ret    

00001334 <pipe>:
SYSCALL(pipe)
    1334:	b8 04 00 00 00       	mov    $0x4,%eax
    1339:	cd 40                	int    $0x40
    133b:	c3                   	ret    

0000133c <read>:
SYSCALL(read)
    133c:	b8 05 00 00 00       	mov    $0x5,%eax
    1341:	cd 40                	int    $0x40
    1343:	c3                   	ret    

00001344 <write>:
SYSCALL(write)
    1344:	b8 10 00 00 00       	mov    $0x10,%eax
    1349:	cd 40                	int    $0x40
    134b:	c3                   	ret    

0000134c <close>:
SYSCALL(close)
    134c:	b8 15 00 00 00       	mov    $0x15,%eax
    1351:	cd 40                	int    $0x40
    1353:	c3                   	ret    

00001354 <kill>:
SYSCALL(kill)
    1354:	b8 06 00 00 00       	mov    $0x6,%eax
    1359:	cd 40                	int    $0x40
    135b:	c3                   	ret    

0000135c <exec>:
SYSCALL(exec)
    135c:	b8 07 00 00 00       	mov    $0x7,%eax
    1361:	cd 40                	int    $0x40
    1363:	c3                   	ret    

00001364 <open>:
SYSCALL(open)
    1364:	b8 0f 00 00 00       	mov    $0xf,%eax
    1369:	cd 40                	int    $0x40
    136b:	c3                   	ret    

0000136c <mknod>:
SYSCALL(mknod)
    136c:	b8 11 00 00 00       	mov    $0x11,%eax
    1371:	cd 40                	int    $0x40
    1373:	c3                   	ret    

00001374 <unlink>:
SYSCALL(unlink)
    1374:	b8 12 00 00 00       	mov    $0x12,%eax
    1379:	cd 40                	int    $0x40
    137b:	c3                   	ret    

0000137c <fstat>:
SYSCALL(fstat)
    137c:	b8 08 00 00 00       	mov    $0x8,%eax
    1381:	cd 40                	int    $0x40
    1383:	c3                   	ret    

00001384 <link>:
SYSCALL(link)
    1384:	b8 13 00 00 00       	mov    $0x13,%eax
    1389:	cd 40                	int    $0x40
    138b:	c3                   	ret    

0000138c <mkdir>:
SYSCALL(mkdir)
    138c:	b8 14 00 00 00       	mov    $0x14,%eax
    1391:	cd 40                	int    $0x40
    1393:	c3                   	ret    

00001394 <chdir>:
SYSCALL(chdir)
    1394:	b8 09 00 00 00       	mov    $0x9,%eax
    1399:	cd 40                	int    $0x40
    139b:	c3                   	ret    

0000139c <dup>:
SYSCALL(dup)
    139c:	b8 0a 00 00 00       	mov    $0xa,%eax
    13a1:	cd 40                	int    $0x40
    13a3:	c3                   	ret    

000013a4 <getpid>:
SYSCALL(getpid)
    13a4:	b8 0b 00 00 00       	mov    $0xb,%eax
    13a9:	cd 40                	int    $0x40
    13ab:	c3                   	ret    

000013ac <sbrk>:
SYSCALL(sbrk)
    13ac:	b8 0c 00 00 00       	mov    $0xc,%eax
    13b1:	cd 40                	int    $0x40
    13b3:	c3                   	ret    

000013b4 <sleep>:
SYSCALL(sleep)
    13b4:	b8 0d 00 00 00       	mov    $0xd,%eax
    13b9:	cd 40                	int    $0x40
    13bb:	c3                   	ret    

000013bc <uptime>:
SYSCALL(uptime)
    13bc:	b8 0e 00 00 00       	mov    $0xe,%eax
    13c1:	cd 40                	int    $0x40
    13c3:	c3                   	ret    

000013c4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    13c4:	55                   	push   %ebp
    13c5:	89 e5                	mov    %esp,%ebp
    13c7:	83 ec 28             	sub    $0x28,%esp
    13ca:	8b 45 0c             	mov    0xc(%ebp),%eax
    13cd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    13d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    13d7:	00 
    13d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
    13db:	89 44 24 04          	mov    %eax,0x4(%esp)
    13df:	8b 45 08             	mov    0x8(%ebp),%eax
    13e2:	89 04 24             	mov    %eax,(%esp)
    13e5:	e8 5a ff ff ff       	call   1344 <write>
}
    13ea:	c9                   	leave  
    13eb:	c3                   	ret    

000013ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    13ec:	55                   	push   %ebp
    13ed:	89 e5                	mov    %esp,%ebp
    13ef:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    13f9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    13fd:	74 17                	je     1416 <printint+0x2a>
    13ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1403:	79 11                	jns    1416 <printint+0x2a>
    neg = 1;
    1405:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    140c:	8b 45 0c             	mov    0xc(%ebp),%eax
    140f:	f7 d8                	neg    %eax
    1411:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1414:	eb 06                	jmp    141c <printint+0x30>
  } else {
    x = xx;
    1416:	8b 45 0c             	mov    0xc(%ebp),%eax
    1419:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    141c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1423:	8b 4d 10             	mov    0x10(%ebp),%ecx
    1426:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1429:	ba 00 00 00 00       	mov    $0x0,%edx
    142e:	f7 f1                	div    %ecx
    1430:	89 d0                	mov    %edx,%eax
    1432:	0f b6 90 70 1e 00 00 	movzbl 0x1e70(%eax),%edx
    1439:	8d 45 dc             	lea    -0x24(%ebp),%eax
    143c:	03 45 f4             	add    -0xc(%ebp),%eax
    143f:	88 10                	mov    %dl,(%eax)
    1441:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    1445:	8b 55 10             	mov    0x10(%ebp),%edx
    1448:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    144b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    144e:	ba 00 00 00 00       	mov    $0x0,%edx
    1453:	f7 75 d4             	divl   -0x2c(%ebp)
    1456:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1459:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    145d:	75 c4                	jne    1423 <printint+0x37>
  if(neg)
    145f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1463:	74 2a                	je     148f <printint+0xa3>
    buf[i++] = '-';
    1465:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1468:	03 45 f4             	add    -0xc(%ebp),%eax
    146b:	c6 00 2d             	movb   $0x2d,(%eax)
    146e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    1472:	eb 1b                	jmp    148f <printint+0xa3>
    putc(fd, buf[i]);
    1474:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1477:	03 45 f4             	add    -0xc(%ebp),%eax
    147a:	0f b6 00             	movzbl (%eax),%eax
    147d:	0f be c0             	movsbl %al,%eax
    1480:	89 44 24 04          	mov    %eax,0x4(%esp)
    1484:	8b 45 08             	mov    0x8(%ebp),%eax
    1487:	89 04 24             	mov    %eax,(%esp)
    148a:	e8 35 ff ff ff       	call   13c4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    148f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1493:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1497:	79 db                	jns    1474 <printint+0x88>
    putc(fd, buf[i]);
}
    1499:	c9                   	leave  
    149a:	c3                   	ret    

0000149b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    149b:	55                   	push   %ebp
    149c:	89 e5                	mov    %esp,%ebp
    149e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    14a1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    14a8:	8d 45 0c             	lea    0xc(%ebp),%eax
    14ab:	83 c0 04             	add    $0x4,%eax
    14ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    14b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    14b8:	e9 7d 01 00 00       	jmp    163a <printf+0x19f>
    c = fmt[i] & 0xff;
    14bd:	8b 55 0c             	mov    0xc(%ebp),%edx
    14c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14c3:	01 d0                	add    %edx,%eax
    14c5:	0f b6 00             	movzbl (%eax),%eax
    14c8:	0f be c0             	movsbl %al,%eax
    14cb:	25 ff 00 00 00       	and    $0xff,%eax
    14d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    14d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14d7:	75 2c                	jne    1505 <printf+0x6a>
      if(c == '%'){
    14d9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    14dd:	75 0c                	jne    14eb <printf+0x50>
        state = '%';
    14df:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    14e6:	e9 4b 01 00 00       	jmp    1636 <printf+0x19b>
      } else {
        putc(fd, c);
    14eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14ee:	0f be c0             	movsbl %al,%eax
    14f1:	89 44 24 04          	mov    %eax,0x4(%esp)
    14f5:	8b 45 08             	mov    0x8(%ebp),%eax
    14f8:	89 04 24             	mov    %eax,(%esp)
    14fb:	e8 c4 fe ff ff       	call   13c4 <putc>
    1500:	e9 31 01 00 00       	jmp    1636 <printf+0x19b>
      }
    } else if(state == '%'){
    1505:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1509:	0f 85 27 01 00 00    	jne    1636 <printf+0x19b>
      if(c == 'd'){
    150f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1513:	75 2d                	jne    1542 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    1515:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1518:	8b 00                	mov    (%eax),%eax
    151a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    1521:	00 
    1522:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1529:	00 
    152a:	89 44 24 04          	mov    %eax,0x4(%esp)
    152e:	8b 45 08             	mov    0x8(%ebp),%eax
    1531:	89 04 24             	mov    %eax,(%esp)
    1534:	e8 b3 fe ff ff       	call   13ec <printint>
        ap++;
    1539:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    153d:	e9 ed 00 00 00       	jmp    162f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    1542:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1546:	74 06                	je     154e <printf+0xb3>
    1548:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    154c:	75 2d                	jne    157b <printf+0xe0>
        printint(fd, *ap, 16, 0);
    154e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1551:	8b 00                	mov    (%eax),%eax
    1553:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    155a:	00 
    155b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1562:	00 
    1563:	89 44 24 04          	mov    %eax,0x4(%esp)
    1567:	8b 45 08             	mov    0x8(%ebp),%eax
    156a:	89 04 24             	mov    %eax,(%esp)
    156d:	e8 7a fe ff ff       	call   13ec <printint>
        ap++;
    1572:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1576:	e9 b4 00 00 00       	jmp    162f <printf+0x194>
      } else if(c == 's'){
    157b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    157f:	75 46                	jne    15c7 <printf+0x12c>
        s = (char*)*ap;
    1581:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1584:	8b 00                	mov    (%eax),%eax
    1586:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1589:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    158d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1591:	75 27                	jne    15ba <printf+0x11f>
          s = "(null)";
    1593:	c7 45 f4 5e 19 00 00 	movl   $0x195e,-0xc(%ebp)
        while(*s != 0){
    159a:	eb 1e                	jmp    15ba <printf+0x11f>
          putc(fd, *s);
    159c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    159f:	0f b6 00             	movzbl (%eax),%eax
    15a2:	0f be c0             	movsbl %al,%eax
    15a5:	89 44 24 04          	mov    %eax,0x4(%esp)
    15a9:	8b 45 08             	mov    0x8(%ebp),%eax
    15ac:	89 04 24             	mov    %eax,(%esp)
    15af:	e8 10 fe ff ff       	call   13c4 <putc>
          s++;
    15b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    15b8:	eb 01                	jmp    15bb <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    15ba:	90                   	nop
    15bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15be:	0f b6 00             	movzbl (%eax),%eax
    15c1:	84 c0                	test   %al,%al
    15c3:	75 d7                	jne    159c <printf+0x101>
    15c5:	eb 68                	jmp    162f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    15c7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    15cb:	75 1d                	jne    15ea <printf+0x14f>
        putc(fd, *ap);
    15cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15d0:	8b 00                	mov    (%eax),%eax
    15d2:	0f be c0             	movsbl %al,%eax
    15d5:	89 44 24 04          	mov    %eax,0x4(%esp)
    15d9:	8b 45 08             	mov    0x8(%ebp),%eax
    15dc:	89 04 24             	mov    %eax,(%esp)
    15df:	e8 e0 fd ff ff       	call   13c4 <putc>
        ap++;
    15e4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15e8:	eb 45                	jmp    162f <printf+0x194>
      } else if(c == '%'){
    15ea:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15ee:	75 17                	jne    1607 <printf+0x16c>
        putc(fd, c);
    15f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15f3:	0f be c0             	movsbl %al,%eax
    15f6:	89 44 24 04          	mov    %eax,0x4(%esp)
    15fa:	8b 45 08             	mov    0x8(%ebp),%eax
    15fd:	89 04 24             	mov    %eax,(%esp)
    1600:	e8 bf fd ff ff       	call   13c4 <putc>
    1605:	eb 28                	jmp    162f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1607:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    160e:	00 
    160f:	8b 45 08             	mov    0x8(%ebp),%eax
    1612:	89 04 24             	mov    %eax,(%esp)
    1615:	e8 aa fd ff ff       	call   13c4 <putc>
        putc(fd, c);
    161a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    161d:	0f be c0             	movsbl %al,%eax
    1620:	89 44 24 04          	mov    %eax,0x4(%esp)
    1624:	8b 45 08             	mov    0x8(%ebp),%eax
    1627:	89 04 24             	mov    %eax,(%esp)
    162a:	e8 95 fd ff ff       	call   13c4 <putc>
      }
      state = 0;
    162f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1636:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    163a:	8b 55 0c             	mov    0xc(%ebp),%edx
    163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1640:	01 d0                	add    %edx,%eax
    1642:	0f b6 00             	movzbl (%eax),%eax
    1645:	84 c0                	test   %al,%al
    1647:	0f 85 70 fe ff ff    	jne    14bd <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    164d:	c9                   	leave  
    164e:	c3                   	ret    
    164f:	90                   	nop

00001650 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1650:	55                   	push   %ebp
    1651:	89 e5                	mov    %esp,%ebp
    1653:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1656:	8b 45 08             	mov    0x8(%ebp),%eax
    1659:	83 e8 08             	sub    $0x8,%eax
    165c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    165f:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
    1664:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1667:	eb 24                	jmp    168d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1669:	8b 45 fc             	mov    -0x4(%ebp),%eax
    166c:	8b 00                	mov    (%eax),%eax
    166e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1671:	77 12                	ja     1685 <free+0x35>
    1673:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1676:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1679:	77 24                	ja     169f <free+0x4f>
    167b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167e:	8b 00                	mov    (%eax),%eax
    1680:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1683:	77 1a                	ja     169f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1685:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1688:	8b 00                	mov    (%eax),%eax
    168a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    168d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1690:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1693:	76 d4                	jbe    1669 <free+0x19>
    1695:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1698:	8b 00                	mov    (%eax),%eax
    169a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    169d:	76 ca                	jbe    1669 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    169f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a2:	8b 40 04             	mov    0x4(%eax),%eax
    16a5:	c1 e0 03             	shl    $0x3,%eax
    16a8:	89 c2                	mov    %eax,%edx
    16aa:	03 55 f8             	add    -0x8(%ebp),%edx
    16ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b0:	8b 00                	mov    (%eax),%eax
    16b2:	39 c2                	cmp    %eax,%edx
    16b4:	75 24                	jne    16da <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    16b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b9:	8b 50 04             	mov    0x4(%eax),%edx
    16bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16bf:	8b 00                	mov    (%eax),%eax
    16c1:	8b 40 04             	mov    0x4(%eax),%eax
    16c4:	01 c2                	add    %eax,%edx
    16c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    16cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16cf:	8b 00                	mov    (%eax),%eax
    16d1:	8b 10                	mov    (%eax),%edx
    16d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16d6:	89 10                	mov    %edx,(%eax)
    16d8:	eb 0a                	jmp    16e4 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    16da:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16dd:	8b 10                	mov    (%eax),%edx
    16df:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16e2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    16e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e7:	8b 40 04             	mov    0x4(%eax),%eax
    16ea:	c1 e0 03             	shl    $0x3,%eax
    16ed:	03 45 fc             	add    -0x4(%ebp),%eax
    16f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16f3:	75 20                	jne    1715 <free+0xc5>
    p->s.size += bp->s.size;
    16f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f8:	8b 50 04             	mov    0x4(%eax),%edx
    16fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16fe:	8b 40 04             	mov    0x4(%eax),%eax
    1701:	01 c2                	add    %eax,%edx
    1703:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1706:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1709:	8b 45 f8             	mov    -0x8(%ebp),%eax
    170c:	8b 10                	mov    (%eax),%edx
    170e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1711:	89 10                	mov    %edx,(%eax)
    1713:	eb 08                	jmp    171d <free+0xcd>
  } else
    p->s.ptr = bp;
    1715:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1718:	8b 55 f8             	mov    -0x8(%ebp),%edx
    171b:	89 10                	mov    %edx,(%eax)
  freep = p;
    171d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1720:	a3 0c 1f 00 00       	mov    %eax,0x1f0c
}
    1725:	c9                   	leave  
    1726:	c3                   	ret    

00001727 <morecore>:

static Header*
morecore(uint nu)
{
    1727:	55                   	push   %ebp
    1728:	89 e5                	mov    %esp,%ebp
    172a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    172d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1734:	77 07                	ja     173d <morecore+0x16>
    nu = 4096;
    1736:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    173d:	8b 45 08             	mov    0x8(%ebp),%eax
    1740:	c1 e0 03             	shl    $0x3,%eax
    1743:	89 04 24             	mov    %eax,(%esp)
    1746:	e8 61 fc ff ff       	call   13ac <sbrk>
    174b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    174e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1752:	75 07                	jne    175b <morecore+0x34>
    return 0;
    1754:	b8 00 00 00 00       	mov    $0x0,%eax
    1759:	eb 22                	jmp    177d <morecore+0x56>
  hp = (Header*)p;
    175b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    175e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1761:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1764:	8b 55 08             	mov    0x8(%ebp),%edx
    1767:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    176d:	83 c0 08             	add    $0x8,%eax
    1770:	89 04 24             	mov    %eax,(%esp)
    1773:	e8 d8 fe ff ff       	call   1650 <free>
  return freep;
    1778:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
}
    177d:	c9                   	leave  
    177e:	c3                   	ret    

0000177f <malloc>:

void*
malloc(uint nbytes)
{
    177f:	55                   	push   %ebp
    1780:	89 e5                	mov    %esp,%ebp
    1782:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1785:	8b 45 08             	mov    0x8(%ebp),%eax
    1788:	83 c0 07             	add    $0x7,%eax
    178b:	c1 e8 03             	shr    $0x3,%eax
    178e:	83 c0 01             	add    $0x1,%eax
    1791:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1794:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
    1799:	89 45 f0             	mov    %eax,-0x10(%ebp)
    179c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    17a0:	75 23                	jne    17c5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    17a2:	c7 45 f0 04 1f 00 00 	movl   $0x1f04,-0x10(%ebp)
    17a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ac:	a3 0c 1f 00 00       	mov    %eax,0x1f0c
    17b1:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
    17b6:	a3 04 1f 00 00       	mov    %eax,0x1f04
    base.s.size = 0;
    17bb:	c7 05 08 1f 00 00 00 	movl   $0x0,0x1f08
    17c2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17c8:	8b 00                	mov    (%eax),%eax
    17ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    17cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17d0:	8b 40 04             	mov    0x4(%eax),%eax
    17d3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17d6:	72 4d                	jb     1825 <malloc+0xa6>
      if(p->s.size == nunits)
    17d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17db:	8b 40 04             	mov    0x4(%eax),%eax
    17de:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17e1:	75 0c                	jne    17ef <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    17e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17e6:	8b 10                	mov    (%eax),%edx
    17e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17eb:	89 10                	mov    %edx,(%eax)
    17ed:	eb 26                	jmp    1815 <malloc+0x96>
      else {
        p->s.size -= nunits;
    17ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f2:	8b 40 04             	mov    0x4(%eax),%eax
    17f5:	89 c2                	mov    %eax,%edx
    17f7:	2b 55 ec             	sub    -0x14(%ebp),%edx
    17fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17fd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1800:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1803:	8b 40 04             	mov    0x4(%eax),%eax
    1806:	c1 e0 03             	shl    $0x3,%eax
    1809:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    180c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    180f:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1812:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1815:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1818:	a3 0c 1f 00 00       	mov    %eax,0x1f0c
      return (void*)(p + 1);
    181d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1820:	83 c0 08             	add    $0x8,%eax
    1823:	eb 38                	jmp    185d <malloc+0xde>
    }
    if(p == freep)
    1825:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
    182a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    182d:	75 1b                	jne    184a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    182f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1832:	89 04 24             	mov    %eax,(%esp)
    1835:	e8 ed fe ff ff       	call   1727 <morecore>
    183a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    183d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1841:	75 07                	jne    184a <malloc+0xcb>
        return 0;
    1843:	b8 00 00 00 00       	mov    $0x0,%eax
    1848:	eb 13                	jmp    185d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    184a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    184d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1850:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1853:	8b 00                	mov    (%eax),%eax
    1855:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1858:	e9 70 ff ff ff       	jmp    17cd <malloc+0x4e>
}
    185d:	c9                   	leave  
    185e:	c3                   	ret    
