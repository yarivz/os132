
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
       6:	c7 44 24 04 7c 18 00 	movl   $0x187c,0x4(%esp)
       d:	00 
       e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      15:	e8 8f 14 00 00       	call   14a9 <printf>
  memset(buf, 0, nbuf);
      1a:	8b 45 0c             	mov    0xc(%ebp),%eax
      1d:	89 44 24 08          	mov    %eax,0x8(%esp)
      21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      28:	00 
      29:	8b 45 08             	mov    0x8(%ebp),%eax
      2c:	89 04 24             	mov    %eax,(%esp)
      2f:	e8 a1 0f 00 00       	call   fd5 <memset>
  gets(buf, nbuf);
      34:	8b 45 0c             	mov    0xc(%ebp),%eax
      37:	89 44 24 04          	mov    %eax,0x4(%esp)
      3b:	8b 45 08             	mov    0x8(%ebp),%eax
      3e:	89 04 24             	mov    %eax,(%esp)
      41:	e8 e6 0f 00 00       	call   102c <gets>
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
      6b:	c7 44 24 04 7f 18 00 	movl   $0x187f,0x4(%esp)
      72:	00 
      73:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      7a:	e8 2a 14 00 00       	call   14a9 <printf>
  exit();
      7f:	e8 98 12 00 00       	call   131c <exit>

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
      8a:	e8 85 12 00 00       	call   1314 <fork>
      8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
      92:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
      96:	75 0c                	jne    a4 <fork1+0x20>
    panic("fork");
      98:	c7 04 24 83 18 00 00 	movl   $0x1883,(%esp)
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
      b6:	e8 de 16 00 00       	call   1799 <malloc>
      bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
      be:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
      c5:	00 
      c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      cd:	00 
      ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
      d1:	89 04 24             	mov    %eax,(%esp)
      d4:	e8 fc 0e 00 00       	call   fd5 <memset>
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
      f4:	e8 a0 16 00 00       	call   1799 <malloc>
      f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
      fc:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     103:	00 
     104:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     10b:	00 
     10c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     10f:	89 04 24             	mov    %eax,(%esp)
     112:	e8 be 0e 00 00       	call   fd5 <memset>
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
     15f:	e8 35 16 00 00       	call   1799 <malloc>
     164:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     167:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     16e:	00 
     16f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     176:	00 
     177:	8b 45 f4             	mov    -0xc(%ebp),%eax
     17a:	89 04 24             	mov    %eax,(%esp)
     17d:	e8 53 0e 00 00       	call   fd5 <memset>
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
     1af:	e8 e5 15 00 00       	call   1799 <malloc>
     1b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     1b7:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     1be:	00 
     1bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     1c6:	00 
     1c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1ca:	89 04 24             	mov    %eax,(%esp)
     1cd:	e8 03 0e 00 00       	call   fd5 <memset>
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
     1ff:	e8 95 15 00 00       	call   1799 <malloc>
     204:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     207:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     20e:	00 
     20f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     216:	00 
     217:	8b 45 f4             	mov    -0xc(%ebp),%eax
     21a:	89 04 24             	mov    %eax,(%esp)
     21d:	e8 b3 0d 00 00       	call   fd5 <memset>
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
     262:	c7 04 24 7c 1e 00 00 	movl   $0x1e7c,(%esp)
     269:	e8 8b 0d 00 00       	call   ff9 <strchr>
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
     305:	c7 04 24 7c 1e 00 00 	movl   $0x1e7c,(%esp)
     30c:	e8 e8 0c 00 00       	call   ff9 <strchr>
     311:	85 c0                	test   %eax,%eax
     313:	75 25                	jne    33a <gettoken+0x101>
     315:	8b 45 f4             	mov    -0xc(%ebp),%eax
     318:	0f b6 00             	movzbl (%eax),%eax
     31b:	0f be c0             	movsbl %al,%eax
     31e:	89 44 24 04          	mov    %eax,0x4(%esp)
     322:	c7 04 24 82 1e 00 00 	movl   $0x1e82,(%esp)
     329:	e8 cb 0c 00 00       	call   ff9 <strchr>
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
     364:	c7 04 24 7c 1e 00 00 	movl   $0x1e7c,(%esp)
     36b:	e8 89 0c 00 00       	call   ff9 <strchr>
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
     3aa:	c7 04 24 7c 1e 00 00 	movl   $0x1e7c,(%esp)
     3b1:	e8 43 0c 00 00       	call   ff9 <strchr>
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
     3df:	e8 15 0c 00 00       	call   ff9 <strchr>
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
     406:	e8 a3 0b 00 00       	call   fae <strlen>
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
     425:	c7 44 24 08 88 18 00 	movl   $0x1888,0x8(%esp)
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
     44e:	c7 44 24 04 89 18 00 	movl   $0x1889,0x4(%esp)
     455:	00 
     456:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     45d:	e8 47 10 00 00       	call   14a9 <printf>
    panic("syntax");
     462:	c7 04 24 98 18 00 00 	movl   $0x1898,(%esp)
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
     4cf:	c7 44 24 08 9f 18 00 	movl   $0x189f,0x8(%esp)
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
     4ed:	c7 44 24 08 a1 18 00 	movl   $0x18a1,0x8(%esp)
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
     571:	c7 44 24 08 a3 18 00 	movl   $0x18a3,0x8(%esp)
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
     62f:	c7 04 24 a5 18 00 00 	movl   $0x18a5,(%esp)
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
     6db:	c7 44 24 08 c2 18 00 	movl   $0x18c2,0x8(%esp)
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
     708:	c7 44 24 08 c5 18 00 	movl   $0x18c5,0x8(%esp)
     70f:	00 
     710:	8b 45 0c             	mov    0xc(%ebp),%eax
     713:	89 44 24 04          	mov    %eax,0x4(%esp)
     717:	8b 45 08             	mov    0x8(%ebp),%eax
     71a:	89 04 24             	mov    %eax,(%esp)
     71d:	e8 5f fc ff ff       	call   381 <peek>
     722:	85 c0                	test   %eax,%eax
     724:	75 0c                	jne    732 <parseblock+0x30>
    panic("parseblock");
     726:	c7 04 24 c7 18 00 00 	movl   $0x18c7,(%esp)
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
     769:	c7 44 24 08 d2 18 00 	movl   $0x18d2,0x8(%esp)
     770:	00 
     771:	8b 45 0c             	mov    0xc(%ebp),%eax
     774:	89 44 24 04          	mov    %eax,0x4(%esp)
     778:	8b 45 08             	mov    0x8(%ebp),%eax
     77b:	89 04 24             	mov    %eax,(%esp)
     77e:	e8 fe fb ff ff       	call   381 <peek>
     783:	85 c0                	test   %eax,%eax
     785:	75 0c                	jne    793 <parseblock+0x91>
    panic("syntax - missing )");
     787:	c7 04 24 d4 18 00 00 	movl   $0x18d4,(%esp)
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
     7dc:	c7 44 24 08 c5 18 00 	movl   $0x18c5,0x8(%esp)
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
     87a:	c7 04 24 98 18 00 00 	movl   $0x1898,(%esp)
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
     8ad:	c7 04 24 e7 18 00 00 	movl   $0x18e7,(%esp)
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
     8d5:	c7 44 24 08 f5 18 00 	movl   $0x18f5,0x8(%esp)
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
     942:	8b 04 85 fc 18 00 00 	mov    0x18fc(,%eax,4),%eax
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
     a0c:	e8 0b 09 00 00       	call   131c <exit>
  switch(cmd->type){
     a11:	8b 45 08             	mov    0x8(%ebp),%eax
     a14:	8b 00                	mov    (%eax),%eax
     a16:	83 f8 05             	cmp    $0x5,%eax
     a19:	77 09                	ja     a24 <runcmd+0x25>
     a1b:	8b 04 85 40 19 00 00 	mov    0x1940(,%eax,4),%eax
     a22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
     a24:	c7 04 24 14 19 00 00 	movl   $0x1914,(%esp)
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
     a40:	e8 d7 08 00 00       	call   131c <exit>
    exec(ecmd->argv[0], ecmd->argv);
     a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a48:	8d 50 04             	lea    0x4(%eax),%edx
     a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a4e:	8b 40 04             	mov    0x4(%eax),%eax
     a51:	89 54 24 04          	mov    %edx,0x4(%esp)
     a55:	89 04 24             	mov    %eax,(%esp)
     a58:	e8 07 09 00 00       	call   1364 <exec>
    if(pathInit)
     a5d:	a1 14 1f 00 00       	mov    0x1f14,%eax
     a62:	85 c0                	test   %eax,%eax
     a64:	0f 84 dd 00 00 00    	je     b47 <runcmd+0x148>
    {
      char *b = ecmd->argv[0];
     a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a6d:	8b 40 04             	mov    0x4(%eax),%eax
     a70:	89 45 ec             	mov    %eax,-0x14(%ebp)
      int i=0, x=strlen(b);
     a73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     a7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a7d:	89 04 24             	mov    %eax,(%esp)
     a80:	e8 29 05 00 00       	call   fae <strlen>
     a85:	89 45 e8             	mov    %eax,-0x18(%ebp)
      char** temp2 = PATH;
     a88:	a1 10 1f 00 00       	mov    0x1f10,%eax
     a8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      for(;i<10 && *(PATH[i]);i++){
     a90:	e9 92 00 00 00       	jmp    b27 <runcmd+0x128>
     a95:	89 e0                	mov    %esp,%eax
     a97:	89 c3                	mov    %eax,%ebx
	int z = strlen(*temp2);
     a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     a9c:	8b 00                	mov    (%eax),%eax
     a9e:	89 04 24             	mov    %eax,(%esp)
     aa1:	e8 08 05 00 00       	call   fae <strlen>
     aa6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	char *a = temp2[i];
     aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
     ab3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ab6:	01 d0                	add    %edx,%eax
     ab8:	8b 00                	mov    (%eax),%eax
     aba:	89 45 dc             	mov    %eax,-0x24(%ebp)
	char dest[x+z];
     abd:	8b 45 e0             	mov    -0x20(%ebp),%eax
     ac0:	8b 55 e8             	mov    -0x18(%ebp),%edx
     ac3:	01 d0                	add    %edx,%eax
     ac5:	8d 50 ff             	lea    -0x1(%eax),%edx
     ac8:	89 55 d8             	mov    %edx,-0x28(%ebp)
     acb:	ba 10 00 00 00       	mov    $0x10,%edx
     ad0:	83 ea 01             	sub    $0x1,%edx
     ad3:	01 d0                	add    %edx,%eax
     ad5:	c7 45 b4 10 00 00 00 	movl   $0x10,-0x4c(%ebp)
     adc:	ba 00 00 00 00       	mov    $0x0,%edx
     ae1:	f7 75 b4             	divl   -0x4c(%ebp)
     ae4:	6b c0 10             	imul   $0x10,%eax,%eax
     ae7:	29 c4                	sub    %eax,%esp
     ae9:	8d 44 24 0c          	lea    0xc(%esp),%eax
     aed:	83 c0 00             	add    $0x0,%eax
     af0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	strcat(dest,a,b);
     af3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     af6:	8b 55 ec             	mov    -0x14(%ebp),%edx
     af9:	89 54 24 08          	mov    %edx,0x8(%esp)
     afd:	8b 55 dc             	mov    -0x24(%ebp),%edx
     b00:	89 54 24 04          	mov    %edx,0x4(%esp)
     b04:	89 04 24             	mov    %eax,(%esp)
     b07:	e8 c4 07 00 00       	call   12d0 <strcat>
	exec(dest,ecmd->argv);
     b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b0f:	8d 50 04             	lea    0x4(%eax),%edx
     b12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     b15:	89 54 24 04          	mov    %edx,0x4(%esp)
     b19:	89 04 24             	mov    %eax,(%esp)
     b1c:	e8 43 08 00 00       	call   1364 <exec>
     b21:	89 dc                	mov    %ebx,%esp
    if(pathInit)
    {
      char *b = ecmd->argv[0];
      int i=0, x=strlen(b);
      char** temp2 = PATH;
      for(;i<10 && *(PATH[i]);i++){
     b23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     b27:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     b2b:	7f 1a                	jg     b47 <runcmd+0x148>
     b2d:	a1 10 1f 00 00       	mov    0x1f10,%eax
     b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b35:	c1 e2 02             	shl    $0x2,%edx
     b38:	01 d0                	add    %edx,%eax
     b3a:	8b 00                	mov    (%eax),%eax
     b3c:	0f b6 00             	movzbl (%eax),%eax
     b3f:	84 c0                	test   %al,%al
     b41:	0f 85 4e ff ff ff    	jne    a95 <runcmd+0x96>
	char dest[x+z];
	strcat(dest,a,b);
	exec(dest,ecmd->argv);
      }
    }
    printf(2, "exec %s failed\n", ecmd->argv[0]);
     b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b4a:	8b 40 04             	mov    0x4(%eax),%eax
     b4d:	89 44 24 08          	mov    %eax,0x8(%esp)
     b51:	c7 44 24 04 1b 19 00 	movl   $0x191b,0x4(%esp)
     b58:	00 
     b59:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     b60:	e8 44 09 00 00       	call   14a9 <printf>
    break;
     b65:	e9 84 01 00 00       	jmp    cee <runcmd+0x2ef>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     b6a:	8b 45 08             	mov    0x8(%ebp),%eax
     b6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
    close(rcmd->fd);
     b70:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b73:	8b 40 14             	mov    0x14(%eax),%eax
     b76:	89 04 24             	mov    %eax,(%esp)
     b79:	e8 d6 07 00 00       	call   1354 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     b7e:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b81:	8b 50 10             	mov    0x10(%eax),%edx
     b84:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b87:	8b 40 08             	mov    0x8(%eax),%eax
     b8a:	89 54 24 04          	mov    %edx,0x4(%esp)
     b8e:	89 04 24             	mov    %eax,(%esp)
     b91:	e8 d6 07 00 00       	call   136c <open>
     b96:	85 c0                	test   %eax,%eax
     b98:	79 23                	jns    bbd <runcmd+0x1be>
      printf(2, "open %s failed\n", rcmd->file);
     b9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b9d:	8b 40 08             	mov    0x8(%eax),%eax
     ba0:	89 44 24 08          	mov    %eax,0x8(%esp)
     ba4:	c7 44 24 04 2b 19 00 	movl   $0x192b,0x4(%esp)
     bab:	00 
     bac:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     bb3:	e8 f1 08 00 00       	call   14a9 <printf>
      exit();
     bb8:	e8 5f 07 00 00       	call   131c <exit>
    }
    runcmd(rcmd->cmd);
     bbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
     bc0:	8b 40 04             	mov    0x4(%eax),%eax
     bc3:	89 04 24             	mov    %eax,(%esp)
     bc6:	e8 34 fe ff ff       	call   9ff <runcmd>
    break;
     bcb:	e9 1e 01 00 00       	jmp    cee <runcmd+0x2ef>

  case LIST:
    lcmd = (struct listcmd*)cmd;
     bd0:	8b 45 08             	mov    0x8(%ebp),%eax
     bd3:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(fork1() == 0)
     bd6:	e8 a9 f4 ff ff       	call   84 <fork1>
     bdb:	85 c0                	test   %eax,%eax
     bdd:	75 0e                	jne    bed <runcmd+0x1ee>
      runcmd(lcmd->left);
     bdf:	8b 45 cc             	mov    -0x34(%ebp),%eax
     be2:	8b 40 04             	mov    0x4(%eax),%eax
     be5:	89 04 24             	mov    %eax,(%esp)
     be8:	e8 12 fe ff ff       	call   9ff <runcmd>
    wait();
     bed:	e8 32 07 00 00       	call   1324 <wait>
    runcmd(lcmd->right);
     bf2:	8b 45 cc             	mov    -0x34(%ebp),%eax
     bf5:	8b 40 08             	mov    0x8(%eax),%eax
     bf8:	89 04 24             	mov    %eax,(%esp)
     bfb:	e8 ff fd ff ff       	call   9ff <runcmd>
    break;
     c00:	e9 e9 00 00 00       	jmp    cee <runcmd+0x2ef>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c05:	8b 45 08             	mov    0x8(%ebp),%eax
     c08:	89 45 c8             	mov    %eax,-0x38(%ebp)
    if(pipe(p) < 0)
     c0b:	8d 45 bc             	lea    -0x44(%ebp),%eax
     c0e:	89 04 24             	mov    %eax,(%esp)
     c11:	e8 26 07 00 00       	call   133c <pipe>
     c16:	85 c0                	test   %eax,%eax
     c18:	79 0c                	jns    c26 <runcmd+0x227>
      panic("pipe");
     c1a:	c7 04 24 3b 19 00 00 	movl   $0x193b,(%esp)
     c21:	e8 38 f4 ff ff       	call   5e <panic>
    if(fork1() == 0){
     c26:	e8 59 f4 ff ff       	call   84 <fork1>
     c2b:	85 c0                	test   %eax,%eax
     c2d:	75 3b                	jne    c6a <runcmd+0x26b>
      close(1);
     c2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c36:	e8 19 07 00 00       	call   1354 <close>
      dup(p[1]);
     c3b:	8b 45 c0             	mov    -0x40(%ebp),%eax
     c3e:	89 04 24             	mov    %eax,(%esp)
     c41:	e8 5e 07 00 00       	call   13a4 <dup>
      close(p[0]);
     c46:	8b 45 bc             	mov    -0x44(%ebp),%eax
     c49:	89 04 24             	mov    %eax,(%esp)
     c4c:	e8 03 07 00 00       	call   1354 <close>
      close(p[1]);
     c51:	8b 45 c0             	mov    -0x40(%ebp),%eax
     c54:	89 04 24             	mov    %eax,(%esp)
     c57:	e8 f8 06 00 00       	call   1354 <close>
      runcmd(pcmd->left);
     c5c:	8b 45 c8             	mov    -0x38(%ebp),%eax
     c5f:	8b 40 04             	mov    0x4(%eax),%eax
     c62:	89 04 24             	mov    %eax,(%esp)
     c65:	e8 95 fd ff ff       	call   9ff <runcmd>
    }
    if(fork1() == 0){
     c6a:	e8 15 f4 ff ff       	call   84 <fork1>
     c6f:	85 c0                	test   %eax,%eax
     c71:	75 3b                	jne    cae <runcmd+0x2af>
      close(0);
     c73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     c7a:	e8 d5 06 00 00       	call   1354 <close>
      dup(p[0]);
     c7f:	8b 45 bc             	mov    -0x44(%ebp),%eax
     c82:	89 04 24             	mov    %eax,(%esp)
     c85:	e8 1a 07 00 00       	call   13a4 <dup>
      close(p[0]);
     c8a:	8b 45 bc             	mov    -0x44(%ebp),%eax
     c8d:	89 04 24             	mov    %eax,(%esp)
     c90:	e8 bf 06 00 00       	call   1354 <close>
      close(p[1]);
     c95:	8b 45 c0             	mov    -0x40(%ebp),%eax
     c98:	89 04 24             	mov    %eax,(%esp)
     c9b:	e8 b4 06 00 00       	call   1354 <close>
      runcmd(pcmd->right);
     ca0:	8b 45 c8             	mov    -0x38(%ebp),%eax
     ca3:	8b 40 08             	mov    0x8(%eax),%eax
     ca6:	89 04 24             	mov    %eax,(%esp)
     ca9:	e8 51 fd ff ff       	call   9ff <runcmd>
    }
    close(p[0]);
     cae:	8b 45 bc             	mov    -0x44(%ebp),%eax
     cb1:	89 04 24             	mov    %eax,(%esp)
     cb4:	e8 9b 06 00 00       	call   1354 <close>
    close(p[1]);
     cb9:	8b 45 c0             	mov    -0x40(%ebp),%eax
     cbc:	89 04 24             	mov    %eax,(%esp)
     cbf:	e8 90 06 00 00       	call   1354 <close>
    wait();
     cc4:	e8 5b 06 00 00       	call   1324 <wait>
    wait();
     cc9:	e8 56 06 00 00       	call   1324 <wait>
    break;
     cce:	eb 1e                	jmp    cee <runcmd+0x2ef>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     cd0:	8b 45 08             	mov    0x8(%ebp),%eax
     cd3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    if(fork1() == 0)
     cd6:	e8 a9 f3 ff ff       	call   84 <fork1>
     cdb:	85 c0                	test   %eax,%eax
     cdd:	75 0e                	jne    ced <runcmd+0x2ee>
      runcmd(bcmd->cmd);
     cdf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     ce2:	8b 40 04             	mov    0x4(%eax),%eax
     ce5:	89 04 24             	mov    %eax,(%esp)
     ce8:	e8 12 fd ff ff       	call   9ff <runcmd>
    break;
     ced:	90                   	nop
  }
  exit();
     cee:	e8 29 06 00 00       	call   131c <exit>

00000cf3 <main>:
}

int
main(void)
{
     cf3:	55                   	push   %ebp
     cf4:	89 e5                	mov    %esp,%ebp
     cf6:	53                   	push   %ebx
     cf7:	83 e4 f0             	and    $0xfffffff0,%esp
     cfa:	83 ec 30             	sub    $0x30,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     cfd:	eb 19                	jmp    d18 <main+0x25>
    if(fd >= 3){
     cff:	83 7c 24 24 02       	cmpl   $0x2,0x24(%esp)
     d04:	7e 12                	jle    d18 <main+0x25>
      close(fd);
     d06:	8b 44 24 24          	mov    0x24(%esp),%eax
     d0a:	89 04 24             	mov    %eax,(%esp)
     d0d:	e8 42 06 00 00       	call   1354 <close>
      break;
     d12:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     d13:	e9 d9 01 00 00       	jmp    ef1 <main+0x1fe>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     d18:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     d1f:	00 
     d20:	c7 04 24 58 19 00 00 	movl   $0x1958,(%esp)
     d27:	e8 40 06 00 00       	call   136c <open>
     d2c:	89 44 24 24          	mov    %eax,0x24(%esp)
     d30:	83 7c 24 24 00       	cmpl   $0x0,0x24(%esp)
     d35:	79 c8                	jns    cff <main+0xc>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     d37:	e9 b5 01 00 00       	jmp    ef1 <main+0x1fe>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     d3c:	0f b6 05 a0 1e 00 00 	movzbl 0x1ea0,%eax
     d43:	3c 63                	cmp    $0x63,%al
     d45:	75 61                	jne    da8 <main+0xb5>
     d47:	0f b6 05 a1 1e 00 00 	movzbl 0x1ea1,%eax
     d4e:	3c 64                	cmp    $0x64,%al
     d50:	75 56                	jne    da8 <main+0xb5>
     d52:	0f b6 05 a2 1e 00 00 	movzbl 0x1ea2,%eax
     d59:	3c 20                	cmp    $0x20,%al
     d5b:	75 4b                	jne    da8 <main+0xb5>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     d5d:	c7 04 24 a0 1e 00 00 	movl   $0x1ea0,(%esp)
     d64:	e8 45 02 00 00       	call   fae <strlen>
     d69:	83 e8 01             	sub    $0x1,%eax
     d6c:	c6 80 a0 1e 00 00 00 	movb   $0x0,0x1ea0(%eax)
      if(chdir(buf+3) < 0)
     d73:	c7 04 24 a3 1e 00 00 	movl   $0x1ea3,(%esp)
     d7a:	e8 1d 06 00 00       	call   139c <chdir>
     d7f:	85 c0                	test   %eax,%eax
     d81:	0f 89 69 01 00 00    	jns    ef0 <main+0x1fd>
        printf(2, "cannot cd %s\n", buf+3);
     d87:	c7 44 24 08 a3 1e 00 	movl   $0x1ea3,0x8(%esp)
     d8e:	00 
     d8f:	c7 44 24 04 60 19 00 	movl   $0x1960,0x4(%esp)
     d96:	00 
     d97:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     d9e:	e8 06 07 00 00       	call   14a9 <printf>
      continue;
     da3:	e9 48 01 00 00       	jmp    ef0 <main+0x1fd>
    }
    if(!strncmp(buf,"export PATH",11)){
     da8:	c7 44 24 08 0b 00 00 	movl   $0xb,0x8(%esp)
     daf:	00 
     db0:	c7 44 24 04 6e 19 00 	movl   $0x196e,0x4(%esp)
     db7:	00 
     db8:	c7 04 24 a0 1e 00 00 	movl   $0x1ea0,(%esp)
     dbf:	e8 b4 04 00 00       	call   1278 <strncmp>
     dc4:	85 c0                	test   %eax,%eax
     dc6:	0f 85 00 01 00 00    	jne    ecc <main+0x1d9>
      //buf = buf+12;
      PATH = malloc(10*sizeof(char*));
     dcc:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
     dd3:	e8 c1 09 00 00       	call   1799 <malloc>
     dd8:	a3 10 1f 00 00       	mov    %eax,0x1f10
      memset(PATH, 0, 10*sizeof(char*));
     ddd:	a1 10 1f 00 00       	mov    0x1f10,%eax
     de2:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
     de9:	00 
     dea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     df1:	00 
     df2:	89 04 24             	mov    %eax,(%esp)
     df5:	e8 db 01 00 00       	call   fd5 <memset>
      int i;
      for(i=0;i<10;i++){
     dfa:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
     e01:	00 
     e02:	eb 4a                	jmp    e4e <main+0x15b>
	PATH[i] = malloc(100);
     e04:	a1 10 1f 00 00       	mov    0x1f10,%eax
     e09:	8b 54 24 2c          	mov    0x2c(%esp),%edx
     e0d:	c1 e2 02             	shl    $0x2,%edx
     e10:	8d 1c 10             	lea    (%eax,%edx,1),%ebx
     e13:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
     e1a:	e8 7a 09 00 00       	call   1799 <malloc>
     e1f:	89 03                	mov    %eax,(%ebx)
	memset(PATH[i],0,100);
     e21:	a1 10 1f 00 00       	mov    0x1f10,%eax
     e26:	8b 54 24 2c          	mov    0x2c(%esp),%edx
     e2a:	c1 e2 02             	shl    $0x2,%edx
     e2d:	01 d0                	add    %edx,%eax
     e2f:	8b 00                	mov    (%eax),%eax
     e31:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
     e38:	00 
     e39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     e40:	00 
     e41:	89 04 24             	mov    %eax,(%esp)
     e44:	e8 8c 01 00 00       	call   fd5 <memset>
    if(!strncmp(buf,"export PATH",11)){
      //buf = buf+12;
      PATH = malloc(10*sizeof(char*));
      memset(PATH, 0, 10*sizeof(char*));
      int i;
      for(i=0;i<10;i++){
     e49:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
     e4e:	83 7c 24 2c 09       	cmpl   $0x9,0x2c(%esp)
     e53:	7e af                	jle    e04 <main+0x111>
	PATH[i] = malloc(100);
	memset(PATH[i],0,100);
      }
      pathInit = 1;
     e55:	c7 05 14 1f 00 00 01 	movl   $0x1,0x1f14
     e5c:	00 00 00 
      int tempIndex = 0;
     e5f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
     e66:	00 
      int* beginIndex = &tempIndex;
     e67:	8d 44 24 18          	lea    0x18(%esp),%eax
     e6b:	89 44 24 20          	mov    %eax,0x20(%esp)
      int length = strlen(&(buf[12]));
     e6f:	c7 04 24 ac 1e 00 00 	movl   $0x1eac,(%esp)
     e76:	e8 33 01 00 00       	call   fae <strlen>
     e7b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
      char** temp = PATH;
     e7f:	a1 10 1f 00 00       	mov    0x1f10,%eax
     e84:	89 44 24 28          	mov    %eax,0x28(%esp)
      while(*beginIndex<length-1)
     e88:	eb 2f                	jmp    eb9 <main+0x1c6>
      {
	if(strtok(*temp,&(buf[12]),':',beginIndex))
     e8a:	8b 44 24 28          	mov    0x28(%esp),%eax
     e8e:	8b 00                	mov    (%eax),%eax
     e90:	8b 54 24 20          	mov    0x20(%esp),%edx
     e94:	89 54 24 0c          	mov    %edx,0xc(%esp)
     e98:	c7 44 24 08 3a 00 00 	movl   $0x3a,0x8(%esp)
     e9f:	00 
     ea0:	c7 44 24 04 ac 1e 00 	movl   $0x1eac,0x4(%esp)
     ea7:	00 
     ea8:	89 04 24             	mov    %eax,(%esp)
     eab:	e8 c3 02 00 00       	call   1173 <strtok>
     eb0:	85 c0                	test   %eax,%eax
     eb2:	74 05                	je     eb9 <main+0x1c6>
	{
	(temp)++;
     eb4:	83 44 24 28 04       	addl   $0x4,0x28(%esp)
      pathInit = 1;
      int tempIndex = 0;
      int* beginIndex = &tempIndex;
      int length = strlen(&(buf[12]));
      char** temp = PATH;
      while(*beginIndex<length-1)
     eb9:	8b 44 24 20          	mov    0x20(%esp),%eax
     ebd:	8b 00                	mov    (%eax),%eax
     ebf:	8b 54 24 1c          	mov    0x1c(%esp),%edx
     ec3:	83 ea 01             	sub    $0x1,%edx
     ec6:	39 d0                	cmp    %edx,%eax
     ec8:	7c c0                	jl     e8a <main+0x197>
     eca:	eb 25                	jmp    ef1 <main+0x1fe>
	(temp)++;
	}
      }
      continue;
    }
    if(fork1() == 0)
     ecc:	e8 b3 f1 ff ff       	call   84 <fork1>
     ed1:	85 c0                	test   %eax,%eax
     ed3:	75 14                	jne    ee9 <main+0x1f6>
    {
      runcmd(parsecmd(buf));
     ed5:	c7 04 24 a0 1e 00 00 	movl   $0x1ea0,(%esp)
     edc:	e8 15 f5 ff ff       	call   3f6 <parsecmd>
     ee1:	89 04 24             	mov    %eax,(%esp)
     ee4:	e8 16 fb ff ff       	call   9ff <runcmd>
    }
    wait();
     ee9:	e8 36 04 00 00       	call   1324 <wait>
     eee:	eb 01                	jmp    ef1 <main+0x1fe>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     ef0:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     ef1:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     ef8:	00 
     ef9:	c7 04 24 a0 1e 00 00 	movl   $0x1ea0,(%esp)
     f00:	e8 fb f0 ff ff       	call   0 <getcmd>
     f05:	85 c0                	test   %eax,%eax
     f07:	0f 89 2f fe ff ff    	jns    d3c <main+0x49>
    {
      runcmd(parsecmd(buf));
    }
    wait();
  }
  exit();
     f0d:	e8 0a 04 00 00       	call   131c <exit>
     f12:	66 90                	xchg   %ax,%ax

00000f14 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     f14:	55                   	push   %ebp
     f15:	89 e5                	mov    %esp,%ebp
     f17:	57                   	push   %edi
     f18:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     f19:	8b 4d 08             	mov    0x8(%ebp),%ecx
     f1c:	8b 55 10             	mov    0x10(%ebp),%edx
     f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
     f22:	89 cb                	mov    %ecx,%ebx
     f24:	89 df                	mov    %ebx,%edi
     f26:	89 d1                	mov    %edx,%ecx
     f28:	fc                   	cld    
     f29:	f3 aa                	rep stos %al,%es:(%edi)
     f2b:	89 ca                	mov    %ecx,%edx
     f2d:	89 fb                	mov    %edi,%ebx
     f2f:	89 5d 08             	mov    %ebx,0x8(%ebp)
     f32:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     f35:	5b                   	pop    %ebx
     f36:	5f                   	pop    %edi
     f37:	5d                   	pop    %ebp
     f38:	c3                   	ret    

00000f39 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     f39:	55                   	push   %ebp
     f3a:	89 e5                	mov    %esp,%ebp
     f3c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     f3f:	8b 45 08             	mov    0x8(%ebp),%eax
     f42:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     f45:	90                   	nop
     f46:	8b 45 0c             	mov    0xc(%ebp),%eax
     f49:	0f b6 10             	movzbl (%eax),%edx
     f4c:	8b 45 08             	mov    0x8(%ebp),%eax
     f4f:	88 10                	mov    %dl,(%eax)
     f51:	8b 45 08             	mov    0x8(%ebp),%eax
     f54:	0f b6 00             	movzbl (%eax),%eax
     f57:	84 c0                	test   %al,%al
     f59:	0f 95 c0             	setne  %al
     f5c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f60:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     f64:	84 c0                	test   %al,%al
     f66:	75 de                	jne    f46 <strcpy+0xd>
    ;
  return os;
     f68:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f6b:	c9                   	leave  
     f6c:	c3                   	ret    

00000f6d <strcmp>:

int
strcmp(const char *p, const char *q)
{
     f6d:	55                   	push   %ebp
     f6e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     f70:	eb 08                	jmp    f7a <strcmp+0xd>
    p++, q++;
     f72:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f76:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     f7a:	8b 45 08             	mov    0x8(%ebp),%eax
     f7d:	0f b6 00             	movzbl (%eax),%eax
     f80:	84 c0                	test   %al,%al
     f82:	74 10                	je     f94 <strcmp+0x27>
     f84:	8b 45 08             	mov    0x8(%ebp),%eax
     f87:	0f b6 10             	movzbl (%eax),%edx
     f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
     f8d:	0f b6 00             	movzbl (%eax),%eax
     f90:	38 c2                	cmp    %al,%dl
     f92:	74 de                	je     f72 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     f94:	8b 45 08             	mov    0x8(%ebp),%eax
     f97:	0f b6 00             	movzbl (%eax),%eax
     f9a:	0f b6 d0             	movzbl %al,%edx
     f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
     fa0:	0f b6 00             	movzbl (%eax),%eax
     fa3:	0f b6 c0             	movzbl %al,%eax
     fa6:	89 d1                	mov    %edx,%ecx
     fa8:	29 c1                	sub    %eax,%ecx
     faa:	89 c8                	mov    %ecx,%eax
}
     fac:	5d                   	pop    %ebp
     fad:	c3                   	ret    

00000fae <strlen>:

uint
strlen(char *s)
{
     fae:	55                   	push   %ebp
     faf:	89 e5                	mov    %esp,%ebp
     fb1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
     fb4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     fbb:	eb 04                	jmp    fc1 <strlen+0x13>
     fbd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     fc1:	8b 55 fc             	mov    -0x4(%ebp),%edx
     fc4:	8b 45 08             	mov    0x8(%ebp),%eax
     fc7:	01 d0                	add    %edx,%eax
     fc9:	0f b6 00             	movzbl (%eax),%eax
     fcc:	84 c0                	test   %al,%al
     fce:	75 ed                	jne    fbd <strlen+0xf>
  return n;
     fd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     fd3:	c9                   	leave  
     fd4:	c3                   	ret    

00000fd5 <memset>:

void*
memset(void *dst, int c, uint n)
{
     fd5:	55                   	push   %ebp
     fd6:	89 e5                	mov    %esp,%ebp
     fd8:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     fdb:	8b 45 10             	mov    0x10(%ebp),%eax
     fde:	89 44 24 08          	mov    %eax,0x8(%esp)
     fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
     fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
     fe9:	8b 45 08             	mov    0x8(%ebp),%eax
     fec:	89 04 24             	mov    %eax,(%esp)
     fef:	e8 20 ff ff ff       	call   f14 <stosb>
  return dst;
     ff4:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ff7:	c9                   	leave  
     ff8:	c3                   	ret    

00000ff9 <strchr>:

char*
strchr(const char *s, char c)
{
     ff9:	55                   	push   %ebp
     ffa:	89 e5                	mov    %esp,%ebp
     ffc:	83 ec 04             	sub    $0x4,%esp
     fff:	8b 45 0c             	mov    0xc(%ebp),%eax
    1002:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1005:	eb 14                	jmp    101b <strchr+0x22>
    if(*s == c)
    1007:	8b 45 08             	mov    0x8(%ebp),%eax
    100a:	0f b6 00             	movzbl (%eax),%eax
    100d:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1010:	75 05                	jne    1017 <strchr+0x1e>
      return (char*)s;
    1012:	8b 45 08             	mov    0x8(%ebp),%eax
    1015:	eb 13                	jmp    102a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1017:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    101b:	8b 45 08             	mov    0x8(%ebp),%eax
    101e:	0f b6 00             	movzbl (%eax),%eax
    1021:	84 c0                	test   %al,%al
    1023:	75 e2                	jne    1007 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1025:	b8 00 00 00 00       	mov    $0x0,%eax
}
    102a:	c9                   	leave  
    102b:	c3                   	ret    

0000102c <gets>:

char*
gets(char *buf, int max)
{
    102c:	55                   	push   %ebp
    102d:	89 e5                	mov    %esp,%ebp
    102f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1032:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1039:	eb 46                	jmp    1081 <gets+0x55>
    cc = read(0, &c, 1);
    103b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1042:	00 
    1043:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1046:	89 44 24 04          	mov    %eax,0x4(%esp)
    104a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1051:	e8 ee 02 00 00       	call   1344 <read>
    1056:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1059:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    105d:	7e 2f                	jle    108e <gets+0x62>
      break;
    buf[i++] = c;
    105f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1062:	8b 45 08             	mov    0x8(%ebp),%eax
    1065:	01 c2                	add    %eax,%edx
    1067:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    106b:	88 02                	mov    %al,(%edx)
    106d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    1071:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1075:	3c 0a                	cmp    $0xa,%al
    1077:	74 16                	je     108f <gets+0x63>
    1079:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    107d:	3c 0d                	cmp    $0xd,%al
    107f:	74 0e                	je     108f <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1081:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1084:	83 c0 01             	add    $0x1,%eax
    1087:	3b 45 0c             	cmp    0xc(%ebp),%eax
    108a:	7c af                	jl     103b <gets+0xf>
    108c:	eb 01                	jmp    108f <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    108e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    108f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1092:	8b 45 08             	mov    0x8(%ebp),%eax
    1095:	01 d0                	add    %edx,%eax
    1097:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    109a:	8b 45 08             	mov    0x8(%ebp),%eax
}
    109d:	c9                   	leave  
    109e:	c3                   	ret    

0000109f <stat>:

int
stat(char *n, struct stat *st)
{
    109f:	55                   	push   %ebp
    10a0:	89 e5                	mov    %esp,%ebp
    10a2:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    10a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    10ac:	00 
    10ad:	8b 45 08             	mov    0x8(%ebp),%eax
    10b0:	89 04 24             	mov    %eax,(%esp)
    10b3:	e8 b4 02 00 00       	call   136c <open>
    10b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    10bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10bf:	79 07                	jns    10c8 <stat+0x29>
    return -1;
    10c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    10c6:	eb 23                	jmp    10eb <stat+0x4c>
  r = fstat(fd, st);
    10c8:	8b 45 0c             	mov    0xc(%ebp),%eax
    10cb:	89 44 24 04          	mov    %eax,0x4(%esp)
    10cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10d2:	89 04 24             	mov    %eax,(%esp)
    10d5:	e8 aa 02 00 00       	call   1384 <fstat>
    10da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    10dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10e0:	89 04 24             	mov    %eax,(%esp)
    10e3:	e8 6c 02 00 00       	call   1354 <close>
  return r;
    10e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    10eb:	c9                   	leave  
    10ec:	c3                   	ret    

000010ed <atoi>:

int
atoi(const char *s)
{
    10ed:	55                   	push   %ebp
    10ee:	89 e5                	mov    %esp,%ebp
    10f0:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    10f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    10fa:	eb 23                	jmp    111f <atoi+0x32>
    n = n*10 + *s++ - '0';
    10fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
    10ff:	89 d0                	mov    %edx,%eax
    1101:	c1 e0 02             	shl    $0x2,%eax
    1104:	01 d0                	add    %edx,%eax
    1106:	01 c0                	add    %eax,%eax
    1108:	89 c2                	mov    %eax,%edx
    110a:	8b 45 08             	mov    0x8(%ebp),%eax
    110d:	0f b6 00             	movzbl (%eax),%eax
    1110:	0f be c0             	movsbl %al,%eax
    1113:	01 d0                	add    %edx,%eax
    1115:	83 e8 30             	sub    $0x30,%eax
    1118:	89 45 fc             	mov    %eax,-0x4(%ebp)
    111b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    111f:	8b 45 08             	mov    0x8(%ebp),%eax
    1122:	0f b6 00             	movzbl (%eax),%eax
    1125:	3c 2f                	cmp    $0x2f,%al
    1127:	7e 0a                	jle    1133 <atoi+0x46>
    1129:	8b 45 08             	mov    0x8(%ebp),%eax
    112c:	0f b6 00             	movzbl (%eax),%eax
    112f:	3c 39                	cmp    $0x39,%al
    1131:	7e c9                	jle    10fc <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1133:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1136:	c9                   	leave  
    1137:	c3                   	ret    

00001138 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1138:	55                   	push   %ebp
    1139:	89 e5                	mov    %esp,%ebp
    113b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    113e:	8b 45 08             	mov    0x8(%ebp),%eax
    1141:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1144:	8b 45 0c             	mov    0xc(%ebp),%eax
    1147:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    114a:	eb 13                	jmp    115f <memmove+0x27>
    *dst++ = *src++;
    114c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    114f:	0f b6 10             	movzbl (%eax),%edx
    1152:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1155:	88 10                	mov    %dl,(%eax)
    1157:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    115b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    115f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    1163:	0f 9f c0             	setg   %al
    1166:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    116a:	84 c0                	test   %al,%al
    116c:	75 de                	jne    114c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    116e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1171:	c9                   	leave  
    1172:	c3                   	ret    

00001173 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
    1173:	55                   	push   %ebp
    1174:	89 e5                	mov    %esp,%ebp
    1176:	83 ec 38             	sub    $0x38,%esp
    1179:	8b 45 10             	mov    0x10(%ebp),%eax
    117c:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
    117f:	8b 45 14             	mov    0x14(%ebp),%eax
    1182:	8b 00                	mov    (%eax),%eax
    1184:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1187:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
    118e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1192:	74 06                	je     119a <strtok+0x27>
    1194:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
    1198:	75 5a                	jne    11f4 <strtok+0x81>
    return match;
    119a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    119d:	eb 76                	jmp    1215 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
    119f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11a2:	8b 45 0c             	mov    0xc(%ebp),%eax
    11a5:	01 d0                	add    %edx,%eax
    11a7:	0f b6 00             	movzbl (%eax),%eax
    11aa:	3a 45 e4             	cmp    -0x1c(%ebp),%al
    11ad:	74 06                	je     11b5 <strtok+0x42>
      {
	index++;
    11af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    11b3:	eb 40                	jmp    11f5 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
    11b5:	8b 45 14             	mov    0x14(%ebp),%eax
    11b8:	8b 00                	mov    (%eax),%eax
    11ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11bd:	29 c2                	sub    %eax,%edx
    11bf:	8b 45 14             	mov    0x14(%ebp),%eax
    11c2:	8b 00                	mov    (%eax),%eax
    11c4:	89 c1                	mov    %eax,%ecx
    11c6:	8b 45 0c             	mov    0xc(%ebp),%eax
    11c9:	01 c8                	add    %ecx,%eax
    11cb:	89 54 24 08          	mov    %edx,0x8(%esp)
    11cf:	89 44 24 04          	mov    %eax,0x4(%esp)
    11d3:	8b 45 08             	mov    0x8(%ebp),%eax
    11d6:	89 04 24             	mov    %eax,(%esp)
    11d9:	e8 39 00 00 00       	call   1217 <strncpy>
    11de:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
    11e1:	8b 45 08             	mov    0x8(%ebp),%eax
    11e4:	0f b6 00             	movzbl (%eax),%eax
    11e7:	84 c0                	test   %al,%al
    11e9:	74 1b                	je     1206 <strtok+0x93>
	  match = 1;
    11eb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
    11f2:	eb 12                	jmp    1206 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
    11f4:	90                   	nop
    11f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11f8:	8b 45 0c             	mov    0xc(%ebp),%eax
    11fb:	01 d0                	add    %edx,%eax
    11fd:	0f b6 00             	movzbl (%eax),%eax
    1200:	84 c0                	test   %al,%al
    1202:	75 9b                	jne    119f <strtok+0x2c>
    1204:	eb 01                	jmp    1207 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
    1206:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
    1207:	8b 45 f4             	mov    -0xc(%ebp),%eax
    120a:	8d 50 01             	lea    0x1(%eax),%edx
    120d:	8b 45 14             	mov    0x14(%ebp),%eax
    1210:	89 10                	mov    %edx,(%eax)
  return match;
    1212:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1215:	c9                   	leave  
    1216:	c3                   	ret    

00001217 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    1217:	55                   	push   %ebp
    1218:	89 e5                	mov    %esp,%ebp
    121a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
    121d:	8b 45 08             	mov    0x8(%ebp),%eax
    1220:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
    1223:	90                   	nop
    1224:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    1228:	0f 9f c0             	setg   %al
    122b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    122f:	84 c0                	test   %al,%al
    1231:	74 30                	je     1263 <strncpy+0x4c>
    1233:	8b 45 0c             	mov    0xc(%ebp),%eax
    1236:	0f b6 10             	movzbl (%eax),%edx
    1239:	8b 45 08             	mov    0x8(%ebp),%eax
    123c:	88 10                	mov    %dl,(%eax)
    123e:	8b 45 08             	mov    0x8(%ebp),%eax
    1241:	0f b6 00             	movzbl (%eax),%eax
    1244:	84 c0                	test   %al,%al
    1246:	0f 95 c0             	setne  %al
    1249:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    124d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    1251:	84 c0                	test   %al,%al
    1253:	75 cf                	jne    1224 <strncpy+0xd>
    ;
  while(n-- > 0)
    1255:	eb 0c                	jmp    1263 <strncpy+0x4c>
    *s++ = 0;
    1257:	8b 45 08             	mov    0x8(%ebp),%eax
    125a:	c6 00 00             	movb   $0x0,(%eax)
    125d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1261:	eb 01                	jmp    1264 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
    1263:	90                   	nop
    1264:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    1268:	0f 9f c0             	setg   %al
    126b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    126f:	84 c0                	test   %al,%al
    1271:	75 e4                	jne    1257 <strncpy+0x40>
    *s++ = 0;
  return os;
    1273:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1276:	c9                   	leave  
    1277:	c3                   	ret    

00001278 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    1278:	55                   	push   %ebp
    1279:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
    127b:	eb 0c                	jmp    1289 <strncmp+0x11>
    n--, p++, q++;
    127d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1281:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1285:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
    1289:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    128d:	74 1a                	je     12a9 <strncmp+0x31>
    128f:	8b 45 08             	mov    0x8(%ebp),%eax
    1292:	0f b6 00             	movzbl (%eax),%eax
    1295:	84 c0                	test   %al,%al
    1297:	74 10                	je     12a9 <strncmp+0x31>
    1299:	8b 45 08             	mov    0x8(%ebp),%eax
    129c:	0f b6 10             	movzbl (%eax),%edx
    129f:	8b 45 0c             	mov    0xc(%ebp),%eax
    12a2:	0f b6 00             	movzbl (%eax),%eax
    12a5:	38 c2                	cmp    %al,%dl
    12a7:	74 d4                	je     127d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
    12a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    12ad:	75 07                	jne    12b6 <strncmp+0x3e>
    return 0;
    12af:	b8 00 00 00 00       	mov    $0x0,%eax
    12b4:	eb 18                	jmp    12ce <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
    12b6:	8b 45 08             	mov    0x8(%ebp),%eax
    12b9:	0f b6 00             	movzbl (%eax),%eax
    12bc:	0f b6 d0             	movzbl %al,%edx
    12bf:	8b 45 0c             	mov    0xc(%ebp),%eax
    12c2:	0f b6 00             	movzbl (%eax),%eax
    12c5:	0f b6 c0             	movzbl %al,%eax
    12c8:	89 d1                	mov    %edx,%ecx
    12ca:	29 c1                	sub    %eax,%ecx
    12cc:	89 c8                	mov    %ecx,%eax
}
    12ce:	5d                   	pop    %ebp
    12cf:	c3                   	ret    

000012d0 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
    12d0:	55                   	push   %ebp
    12d1:	89 e5                	mov    %esp,%ebp
  while(*p){
    12d3:	eb 13                	jmp    12e8 <strcat+0x18>
    *dest++ = *p++;
    12d5:	8b 45 0c             	mov    0xc(%ebp),%eax
    12d8:	0f b6 10             	movzbl (%eax),%edx
    12db:	8b 45 08             	mov    0x8(%ebp),%eax
    12de:	88 10                	mov    %dl,(%eax)
    12e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    12e4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    12e8:	8b 45 0c             	mov    0xc(%ebp),%eax
    12eb:	0f b6 00             	movzbl (%eax),%eax
    12ee:	84 c0                	test   %al,%al
    12f0:	75 e3                	jne    12d5 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
    12f2:	eb 13                	jmp    1307 <strcat+0x37>
    *dest++ = *q++;
    12f4:	8b 45 10             	mov    0x10(%ebp),%eax
    12f7:	0f b6 10             	movzbl (%eax),%edx
    12fa:	8b 45 08             	mov    0x8(%ebp),%eax
    12fd:	88 10                	mov    %dl,(%eax)
    12ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1303:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
    1307:	8b 45 10             	mov    0x10(%ebp),%eax
    130a:	0f b6 00             	movzbl (%eax),%eax
    130d:	84 c0                	test   %al,%al
    130f:	75 e3                	jne    12f4 <strcat+0x24>
    *dest++ = *q++;
  }  
    1311:	5d                   	pop    %ebp
    1312:	c3                   	ret    
    1313:	90                   	nop

00001314 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1314:	b8 01 00 00 00       	mov    $0x1,%eax
    1319:	cd 40                	int    $0x40
    131b:	c3                   	ret    

0000131c <exit>:
SYSCALL(exit)
    131c:	b8 02 00 00 00       	mov    $0x2,%eax
    1321:	cd 40                	int    $0x40
    1323:	c3                   	ret    

00001324 <wait>:
SYSCALL(wait)
    1324:	b8 03 00 00 00       	mov    $0x3,%eax
    1329:	cd 40                	int    $0x40
    132b:	c3                   	ret    

0000132c <wait2>:
SYSCALL(wait2)
    132c:	b8 16 00 00 00       	mov    $0x16,%eax
    1331:	cd 40                	int    $0x40
    1333:	c3                   	ret    

00001334 <nice>:
SYSCALL(nice)
    1334:	b8 17 00 00 00       	mov    $0x17,%eax
    1339:	cd 40                	int    $0x40
    133b:	c3                   	ret    

0000133c <pipe>:
SYSCALL(pipe)
    133c:	b8 04 00 00 00       	mov    $0x4,%eax
    1341:	cd 40                	int    $0x40
    1343:	c3                   	ret    

00001344 <read>:
SYSCALL(read)
    1344:	b8 05 00 00 00       	mov    $0x5,%eax
    1349:	cd 40                	int    $0x40
    134b:	c3                   	ret    

0000134c <write>:
SYSCALL(write)
    134c:	b8 10 00 00 00       	mov    $0x10,%eax
    1351:	cd 40                	int    $0x40
    1353:	c3                   	ret    

00001354 <close>:
SYSCALL(close)
    1354:	b8 15 00 00 00       	mov    $0x15,%eax
    1359:	cd 40                	int    $0x40
    135b:	c3                   	ret    

0000135c <kill>:
SYSCALL(kill)
    135c:	b8 06 00 00 00       	mov    $0x6,%eax
    1361:	cd 40                	int    $0x40
    1363:	c3                   	ret    

00001364 <exec>:
SYSCALL(exec)
    1364:	b8 07 00 00 00       	mov    $0x7,%eax
    1369:	cd 40                	int    $0x40
    136b:	c3                   	ret    

0000136c <open>:
SYSCALL(open)
    136c:	b8 0f 00 00 00       	mov    $0xf,%eax
    1371:	cd 40                	int    $0x40
    1373:	c3                   	ret    

00001374 <mknod>:
SYSCALL(mknod)
    1374:	b8 11 00 00 00       	mov    $0x11,%eax
    1379:	cd 40                	int    $0x40
    137b:	c3                   	ret    

0000137c <unlink>:
SYSCALL(unlink)
    137c:	b8 12 00 00 00       	mov    $0x12,%eax
    1381:	cd 40                	int    $0x40
    1383:	c3                   	ret    

00001384 <fstat>:
SYSCALL(fstat)
    1384:	b8 08 00 00 00       	mov    $0x8,%eax
    1389:	cd 40                	int    $0x40
    138b:	c3                   	ret    

0000138c <link>:
SYSCALL(link)
    138c:	b8 13 00 00 00       	mov    $0x13,%eax
    1391:	cd 40                	int    $0x40
    1393:	c3                   	ret    

00001394 <mkdir>:
SYSCALL(mkdir)
    1394:	b8 14 00 00 00       	mov    $0x14,%eax
    1399:	cd 40                	int    $0x40
    139b:	c3                   	ret    

0000139c <chdir>:
SYSCALL(chdir)
    139c:	b8 09 00 00 00       	mov    $0x9,%eax
    13a1:	cd 40                	int    $0x40
    13a3:	c3                   	ret    

000013a4 <dup>:
SYSCALL(dup)
    13a4:	b8 0a 00 00 00       	mov    $0xa,%eax
    13a9:	cd 40                	int    $0x40
    13ab:	c3                   	ret    

000013ac <getpid>:
SYSCALL(getpid)
    13ac:	b8 0b 00 00 00       	mov    $0xb,%eax
    13b1:	cd 40                	int    $0x40
    13b3:	c3                   	ret    

000013b4 <sbrk>:
SYSCALL(sbrk)
    13b4:	b8 0c 00 00 00       	mov    $0xc,%eax
    13b9:	cd 40                	int    $0x40
    13bb:	c3                   	ret    

000013bc <sleep>:
SYSCALL(sleep)
    13bc:	b8 0d 00 00 00       	mov    $0xd,%eax
    13c1:	cd 40                	int    $0x40
    13c3:	c3                   	ret    

000013c4 <uptime>:
SYSCALL(uptime)
    13c4:	b8 0e 00 00 00       	mov    $0xe,%eax
    13c9:	cd 40                	int    $0x40
    13cb:	c3                   	ret    

000013cc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    13cc:	55                   	push   %ebp
    13cd:	89 e5                	mov    %esp,%ebp
    13cf:	83 ec 28             	sub    $0x28,%esp
    13d2:	8b 45 0c             	mov    0xc(%ebp),%eax
    13d5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    13d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    13df:	00 
    13e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
    13e3:	89 44 24 04          	mov    %eax,0x4(%esp)
    13e7:	8b 45 08             	mov    0x8(%ebp),%eax
    13ea:	89 04 24             	mov    %eax,(%esp)
    13ed:	e8 5a ff ff ff       	call   134c <write>
}
    13f2:	c9                   	leave  
    13f3:	c3                   	ret    

000013f4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    13f4:	55                   	push   %ebp
    13f5:	89 e5                	mov    %esp,%ebp
    13f7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    13fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1401:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1405:	74 17                	je     141e <printint+0x2a>
    1407:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    140b:	79 11                	jns    141e <printint+0x2a>
    neg = 1;
    140d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1414:	8b 45 0c             	mov    0xc(%ebp),%eax
    1417:	f7 d8                	neg    %eax
    1419:	89 45 ec             	mov    %eax,-0x14(%ebp)
    141c:	eb 06                	jmp    1424 <printint+0x30>
  } else {
    x = xx;
    141e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1421:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1424:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    142b:	8b 4d 10             	mov    0x10(%ebp),%ecx
    142e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1431:	ba 00 00 00 00       	mov    $0x0,%edx
    1436:	f7 f1                	div    %ecx
    1438:	89 d0                	mov    %edx,%eax
    143a:	0f b6 80 8c 1e 00 00 	movzbl 0x1e8c(%eax),%eax
    1441:	8d 4d dc             	lea    -0x24(%ebp),%ecx
    1444:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1447:	01 ca                	add    %ecx,%edx
    1449:	88 02                	mov    %al,(%edx)
    144b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    144f:	8b 55 10             	mov    0x10(%ebp),%edx
    1452:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    1455:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1458:	ba 00 00 00 00       	mov    $0x0,%edx
    145d:	f7 75 d4             	divl   -0x2c(%ebp)
    1460:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1463:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1467:	75 c2                	jne    142b <printint+0x37>
  if(neg)
    1469:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    146d:	74 2e                	je     149d <printint+0xa9>
    buf[i++] = '-';
    146f:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1472:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1475:	01 d0                	add    %edx,%eax
    1477:	c6 00 2d             	movb   $0x2d,(%eax)
    147a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    147e:	eb 1d                	jmp    149d <printint+0xa9>
    putc(fd, buf[i]);
    1480:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1483:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1486:	01 d0                	add    %edx,%eax
    1488:	0f b6 00             	movzbl (%eax),%eax
    148b:	0f be c0             	movsbl %al,%eax
    148e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1492:	8b 45 08             	mov    0x8(%ebp),%eax
    1495:	89 04 24             	mov    %eax,(%esp)
    1498:	e8 2f ff ff ff       	call   13cc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    149d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    14a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14a5:	79 d9                	jns    1480 <printint+0x8c>
    putc(fd, buf[i]);
}
    14a7:	c9                   	leave  
    14a8:	c3                   	ret    

000014a9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    14a9:	55                   	push   %ebp
    14aa:	89 e5                	mov    %esp,%ebp
    14ac:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    14af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    14b6:	8d 45 0c             	lea    0xc(%ebp),%eax
    14b9:	83 c0 04             	add    $0x4,%eax
    14bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    14bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    14c6:	e9 7d 01 00 00       	jmp    1648 <printf+0x19f>
    c = fmt[i] & 0xff;
    14cb:	8b 55 0c             	mov    0xc(%ebp),%edx
    14ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14d1:	01 d0                	add    %edx,%eax
    14d3:	0f b6 00             	movzbl (%eax),%eax
    14d6:	0f be c0             	movsbl %al,%eax
    14d9:	25 ff 00 00 00       	and    $0xff,%eax
    14de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    14e1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14e5:	75 2c                	jne    1513 <printf+0x6a>
      if(c == '%'){
    14e7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    14eb:	75 0c                	jne    14f9 <printf+0x50>
        state = '%';
    14ed:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    14f4:	e9 4b 01 00 00       	jmp    1644 <printf+0x19b>
      } else {
        putc(fd, c);
    14f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    14fc:	0f be c0             	movsbl %al,%eax
    14ff:	89 44 24 04          	mov    %eax,0x4(%esp)
    1503:	8b 45 08             	mov    0x8(%ebp),%eax
    1506:	89 04 24             	mov    %eax,(%esp)
    1509:	e8 be fe ff ff       	call   13cc <putc>
    150e:	e9 31 01 00 00       	jmp    1644 <printf+0x19b>
      }
    } else if(state == '%'){
    1513:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1517:	0f 85 27 01 00 00    	jne    1644 <printf+0x19b>
      if(c == 'd'){
    151d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1521:	75 2d                	jne    1550 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    1523:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1526:	8b 00                	mov    (%eax),%eax
    1528:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    152f:	00 
    1530:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1537:	00 
    1538:	89 44 24 04          	mov    %eax,0x4(%esp)
    153c:	8b 45 08             	mov    0x8(%ebp),%eax
    153f:	89 04 24             	mov    %eax,(%esp)
    1542:	e8 ad fe ff ff       	call   13f4 <printint>
        ap++;
    1547:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    154b:	e9 ed 00 00 00       	jmp    163d <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    1550:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1554:	74 06                	je     155c <printf+0xb3>
    1556:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    155a:	75 2d                	jne    1589 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    155c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    155f:	8b 00                	mov    (%eax),%eax
    1561:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1568:	00 
    1569:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1570:	00 
    1571:	89 44 24 04          	mov    %eax,0x4(%esp)
    1575:	8b 45 08             	mov    0x8(%ebp),%eax
    1578:	89 04 24             	mov    %eax,(%esp)
    157b:	e8 74 fe ff ff       	call   13f4 <printint>
        ap++;
    1580:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1584:	e9 b4 00 00 00       	jmp    163d <printf+0x194>
      } else if(c == 's'){
    1589:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    158d:	75 46                	jne    15d5 <printf+0x12c>
        s = (char*)*ap;
    158f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1592:	8b 00                	mov    (%eax),%eax
    1594:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1597:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    159b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    159f:	75 27                	jne    15c8 <printf+0x11f>
          s = "(null)";
    15a1:	c7 45 f4 7a 19 00 00 	movl   $0x197a,-0xc(%ebp)
        while(*s != 0){
    15a8:	eb 1e                	jmp    15c8 <printf+0x11f>
          putc(fd, *s);
    15aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15ad:	0f b6 00             	movzbl (%eax),%eax
    15b0:	0f be c0             	movsbl %al,%eax
    15b3:	89 44 24 04          	mov    %eax,0x4(%esp)
    15b7:	8b 45 08             	mov    0x8(%ebp),%eax
    15ba:	89 04 24             	mov    %eax,(%esp)
    15bd:	e8 0a fe ff ff       	call   13cc <putc>
          s++;
    15c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    15c6:	eb 01                	jmp    15c9 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    15c8:	90                   	nop
    15c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15cc:	0f b6 00             	movzbl (%eax),%eax
    15cf:	84 c0                	test   %al,%al
    15d1:	75 d7                	jne    15aa <printf+0x101>
    15d3:	eb 68                	jmp    163d <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    15d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    15d9:	75 1d                	jne    15f8 <printf+0x14f>
        putc(fd, *ap);
    15db:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15de:	8b 00                	mov    (%eax),%eax
    15e0:	0f be c0             	movsbl %al,%eax
    15e3:	89 44 24 04          	mov    %eax,0x4(%esp)
    15e7:	8b 45 08             	mov    0x8(%ebp),%eax
    15ea:	89 04 24             	mov    %eax,(%esp)
    15ed:	e8 da fd ff ff       	call   13cc <putc>
        ap++;
    15f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    15f6:	eb 45                	jmp    163d <printf+0x194>
      } else if(c == '%'){
    15f8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15fc:	75 17                	jne    1615 <printf+0x16c>
        putc(fd, c);
    15fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1601:	0f be c0             	movsbl %al,%eax
    1604:	89 44 24 04          	mov    %eax,0x4(%esp)
    1608:	8b 45 08             	mov    0x8(%ebp),%eax
    160b:	89 04 24             	mov    %eax,(%esp)
    160e:	e8 b9 fd ff ff       	call   13cc <putc>
    1613:	eb 28                	jmp    163d <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1615:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    161c:	00 
    161d:	8b 45 08             	mov    0x8(%ebp),%eax
    1620:	89 04 24             	mov    %eax,(%esp)
    1623:	e8 a4 fd ff ff       	call   13cc <putc>
        putc(fd, c);
    1628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    162b:	0f be c0             	movsbl %al,%eax
    162e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1632:	8b 45 08             	mov    0x8(%ebp),%eax
    1635:	89 04 24             	mov    %eax,(%esp)
    1638:	e8 8f fd ff ff       	call   13cc <putc>
      }
      state = 0;
    163d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1644:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1648:	8b 55 0c             	mov    0xc(%ebp),%edx
    164b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    164e:	01 d0                	add    %edx,%eax
    1650:	0f b6 00             	movzbl (%eax),%eax
    1653:	84 c0                	test   %al,%al
    1655:	0f 85 70 fe ff ff    	jne    14cb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    165b:	c9                   	leave  
    165c:	c3                   	ret    
    165d:	66 90                	xchg   %ax,%ax
    165f:	90                   	nop

00001660 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1660:	55                   	push   %ebp
    1661:	89 e5                	mov    %esp,%ebp
    1663:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1666:	8b 45 08             	mov    0x8(%ebp),%eax
    1669:	83 e8 08             	sub    $0x8,%eax
    166c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    166f:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
    1674:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1677:	eb 24                	jmp    169d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1679:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167c:	8b 00                	mov    (%eax),%eax
    167e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1681:	77 12                	ja     1695 <free+0x35>
    1683:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1686:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1689:	77 24                	ja     16af <free+0x4f>
    168b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168e:	8b 00                	mov    (%eax),%eax
    1690:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1693:	77 1a                	ja     16af <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1695:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1698:	8b 00                	mov    (%eax),%eax
    169a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    169d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16a0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16a3:	76 d4                	jbe    1679 <free+0x19>
    16a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a8:	8b 00                	mov    (%eax),%eax
    16aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16ad:	76 ca                	jbe    1679 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    16af:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b2:	8b 40 04             	mov    0x4(%eax),%eax
    16b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    16bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16bf:	01 c2                	add    %eax,%edx
    16c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16c4:	8b 00                	mov    (%eax),%eax
    16c6:	39 c2                	cmp    %eax,%edx
    16c8:	75 24                	jne    16ee <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    16ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16cd:	8b 50 04             	mov    0x4(%eax),%edx
    16d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d3:	8b 00                	mov    (%eax),%eax
    16d5:	8b 40 04             	mov    0x4(%eax),%eax
    16d8:	01 c2                	add    %eax,%edx
    16da:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16dd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    16e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16e3:	8b 00                	mov    (%eax),%eax
    16e5:	8b 10                	mov    (%eax),%edx
    16e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16ea:	89 10                	mov    %edx,(%eax)
    16ec:	eb 0a                	jmp    16f8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    16ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16f1:	8b 10                	mov    (%eax),%edx
    16f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16f6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    16f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16fb:	8b 40 04             	mov    0x4(%eax),%eax
    16fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1705:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1708:	01 d0                	add    %edx,%eax
    170a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    170d:	75 20                	jne    172f <free+0xcf>
    p->s.size += bp->s.size;
    170f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1712:	8b 50 04             	mov    0x4(%eax),%edx
    1715:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1718:	8b 40 04             	mov    0x4(%eax),%eax
    171b:	01 c2                	add    %eax,%edx
    171d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1720:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1723:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1726:	8b 10                	mov    (%eax),%edx
    1728:	8b 45 fc             	mov    -0x4(%ebp),%eax
    172b:	89 10                	mov    %edx,(%eax)
    172d:	eb 08                	jmp    1737 <free+0xd7>
  } else
    p->s.ptr = bp;
    172f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1732:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1735:	89 10                	mov    %edx,(%eax)
  freep = p;
    1737:	8b 45 fc             	mov    -0x4(%ebp),%eax
    173a:	a3 0c 1f 00 00       	mov    %eax,0x1f0c
}
    173f:	c9                   	leave  
    1740:	c3                   	ret    

00001741 <morecore>:

static Header*
morecore(uint nu)
{
    1741:	55                   	push   %ebp
    1742:	89 e5                	mov    %esp,%ebp
    1744:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1747:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    174e:	77 07                	ja     1757 <morecore+0x16>
    nu = 4096;
    1750:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1757:	8b 45 08             	mov    0x8(%ebp),%eax
    175a:	c1 e0 03             	shl    $0x3,%eax
    175d:	89 04 24             	mov    %eax,(%esp)
    1760:	e8 4f fc ff ff       	call   13b4 <sbrk>
    1765:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1768:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    176c:	75 07                	jne    1775 <morecore+0x34>
    return 0;
    176e:	b8 00 00 00 00       	mov    $0x0,%eax
    1773:	eb 22                	jmp    1797 <morecore+0x56>
  hp = (Header*)p;
    1775:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1778:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    177e:	8b 55 08             	mov    0x8(%ebp),%edx
    1781:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1784:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1787:	83 c0 08             	add    $0x8,%eax
    178a:	89 04 24             	mov    %eax,(%esp)
    178d:	e8 ce fe ff ff       	call   1660 <free>
  return freep;
    1792:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
}
    1797:	c9                   	leave  
    1798:	c3                   	ret    

00001799 <malloc>:

void*
malloc(uint nbytes)
{
    1799:	55                   	push   %ebp
    179a:	89 e5                	mov    %esp,%ebp
    179c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    179f:	8b 45 08             	mov    0x8(%ebp),%eax
    17a2:	83 c0 07             	add    $0x7,%eax
    17a5:	c1 e8 03             	shr    $0x3,%eax
    17a8:	83 c0 01             	add    $0x1,%eax
    17ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    17ae:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
    17b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    17ba:	75 23                	jne    17df <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    17bc:	c7 45 f0 04 1f 00 00 	movl   $0x1f04,-0x10(%ebp)
    17c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17c6:	a3 0c 1f 00 00       	mov    %eax,0x1f0c
    17cb:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
    17d0:	a3 04 1f 00 00       	mov    %eax,0x1f04
    base.s.size = 0;
    17d5:	c7 05 08 1f 00 00 00 	movl   $0x0,0x1f08
    17dc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17df:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17e2:	8b 00                	mov    (%eax),%eax
    17e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    17e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17ea:	8b 40 04             	mov    0x4(%eax),%eax
    17ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17f0:	72 4d                	jb     183f <malloc+0xa6>
      if(p->s.size == nunits)
    17f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f5:	8b 40 04             	mov    0x4(%eax),%eax
    17f8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17fb:	75 0c                	jne    1809 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    17fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1800:	8b 10                	mov    (%eax),%edx
    1802:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1805:	89 10                	mov    %edx,(%eax)
    1807:	eb 26                	jmp    182f <malloc+0x96>
      else {
        p->s.size -= nunits;
    1809:	8b 45 f4             	mov    -0xc(%ebp),%eax
    180c:	8b 40 04             	mov    0x4(%eax),%eax
    180f:	89 c2                	mov    %eax,%edx
    1811:	2b 55 ec             	sub    -0x14(%ebp),%edx
    1814:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1817:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    181a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    181d:	8b 40 04             	mov    0x4(%eax),%eax
    1820:	c1 e0 03             	shl    $0x3,%eax
    1823:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1826:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1829:	8b 55 ec             	mov    -0x14(%ebp),%edx
    182c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    182f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1832:	a3 0c 1f 00 00       	mov    %eax,0x1f0c
      return (void*)(p + 1);
    1837:	8b 45 f4             	mov    -0xc(%ebp),%eax
    183a:	83 c0 08             	add    $0x8,%eax
    183d:	eb 38                	jmp    1877 <malloc+0xde>
    }
    if(p == freep)
    183f:	a1 0c 1f 00 00       	mov    0x1f0c,%eax
    1844:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1847:	75 1b                	jne    1864 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    1849:	8b 45 ec             	mov    -0x14(%ebp),%eax
    184c:	89 04 24             	mov    %eax,(%esp)
    184f:	e8 ed fe ff ff       	call   1741 <morecore>
    1854:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1857:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    185b:	75 07                	jne    1864 <malloc+0xcb>
        return 0;
    185d:	b8 00 00 00 00       	mov    $0x0,%eax
    1862:	eb 13                	jmp    1877 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1864:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1867:	89 45 f0             	mov    %eax,-0x10(%ebp)
    186a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    186d:	8b 00                	mov    (%eax),%eax
    186f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1872:	e9 70 ff ff ff       	jmp    17e7 <malloc+0x4e>
}
    1877:	c9                   	leave  
    1878:	c3                   	ret    
