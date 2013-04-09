
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <foo>:
}
*/

void
foo(int cid)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  int i;
  switch(cid%3)
   7:	8b 4d 08             	mov    0x8(%ebp),%ecx
   a:	ba 56 55 55 55       	mov    $0x55555556,%edx
   f:	89 c8                	mov    %ecx,%eax
  11:	f7 ea                	imul   %edx
  13:	89 c8                	mov    %ecx,%eax
  15:	c1 f8 1f             	sar    $0x1f,%eax
  18:	89 d3                	mov    %edx,%ebx
  1a:	29 c3                	sub    %eax,%ebx
  1c:	89 d8                	mov    %ebx,%eax
  1e:	89 c2                	mov    %eax,%edx
  20:	01 d2                	add    %edx,%edx
  22:	01 c2                	add    %eax,%edx
  24:	89 c8                	mov    %ecx,%eax
  26:	29 d0                	sub    %edx,%eax
  28:	85 c0                	test   %eax,%eax
  2a:	74 07                	je     33 <foo+0x33>
  2c:	83 f8 01             	cmp    $0x1,%eax
  2f:	74 09                	je     3a <foo+0x3a>
  31:	eb 12                	jmp    45 <foo+0x45>
  {
    case 0:
      nice();
  33:	e8 44 08 00 00       	call   87c <nice>
      break;
  38:	eb 0b                	jmp    45 <foo+0x45>
    case 1:
      nice();
  3a:	e8 3d 08 00 00       	call   87c <nice>
      nice();
  3f:	e8 38 08 00 00       	call   87c <nice>
      break;
  44:	90                   	nop
  }
  for (i=0;i<500;i++)
  45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4c:	eb 29                	jmp    77 <foo+0x77>
     printf(1, "child %d prints for the %d time\n",cid,i+1);
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	83 c0 01             	add    $0x1,%eax
  54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  58:	8b 45 08             	mov    0x8(%ebp),%eax
  5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  5f:	c7 44 24 04 c4 0d 00 	movl   $0xdc4,0x4(%esp)
  66:	00 
  67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6e:	e8 7e 09 00 00       	call   9f1 <printf>
    case 1:
      nice();
      nice();
      break;
  }
  for (i=0;i<500;i++)
  73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  77:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
  7e:	7e ce                	jle    4e <foo+0x4e>
     printf(1, "child %d prints for the %d time\n",cid,i+1);
}
  80:	83 c4 24             	add    $0x24,%esp
  83:	5b                   	pop    %ebx
  84:	5d                   	pop    %ebp
  85:	c3                   	ret    

00000086 <sanity>:

void
sanity(void)
{
  86:	55                   	push   %ebp
  87:	89 e5                	mov    %esp,%ebp
  89:	56                   	push   %esi
  8a:	53                   	push   %ebx
  8b:	81 ec c0 01 00 00    	sub    $0x1c0,%esp
  int avg_medium_wtime;
  int avg_medium_rtime;
  int avg_low_wtime;
  int avg_low_rtime;
  int temp;
  int found = 0;
  91:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  
  printf(1, "sanity test\n");
  98:	c7 44 24 04 e5 0d 00 	movl   $0xde5,0x4(%esp)
  9f:	00 
  a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a7:	e8 45 09 00 00       	call   9f1 <printf>

  int i,cid;
  for(;cid<30;cid++)
  ac:	eb 31                	jmp    df <sanity+0x59>
  {  
    pid[cid] = fork();
  ae:	e8 a9 07 00 00       	call   85c <fork>
  b3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  b6:	89 84 95 58 fe ff ff 	mov    %eax,-0x1a8(%ebp,%edx,4)
    if(pid[cid] == 0)
  bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  c0:	8b 84 85 58 fe ff ff 	mov    -0x1a8(%ebp,%eax,4),%eax
  c7:	85 c0                	test   %eax,%eax
  c9:	75 10                	jne    db <sanity+0x55>
    {
      foo(cid);
  cb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  ce:	89 04 24             	mov    %eax,(%esp)
  d1:	e8 2a ff ff ff       	call   0 <foo>
      exit();      
  d6:	e8 89 07 00 00       	call   864 <exit>
  int found = 0;
  
  printf(1, "sanity test\n");

  int i,cid;
  for(;cid<30;cid++)
  db:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
  df:	83 7d cc 1d          	cmpl   $0x1d,-0x34(%ebp)
  e3:	7e c9                	jle    ae <sanity+0x28>
      foo(cid);
      exit();      
    }
  }
  
  for(i=0;i<30;i++,found=0)
  e5:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  ec:	e9 11 01 00 00       	jmp    202 <sanity+0x17c>
  {
    temp = wait2(&tempwtime,&temprtime);
  f1:	8d 85 d0 fe ff ff    	lea    -0x130(%ebp),%eax
  f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  fb:	8d 85 d4 fe ff ff    	lea    -0x12c(%ebp),%eax
 101:	89 04 24             	mov    %eax,(%esp)
 104:	e8 6b 07 00 00       	call   874 <wait2>
 109:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for(cid=0;cid<30 && !found;cid++)
 10c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 113:	eb 3a                	jmp    14f <sanity+0xc9>
    {
      if(pid[cid] == temp)
 115:	8b 45 cc             	mov    -0x34(%ebp),%eax
 118:	8b 84 85 58 fe ff ff 	mov    -0x1a8(%ebp,%eax,4),%eax
 11f:	3b 45 c8             	cmp    -0x38(%ebp),%eax
 122:	75 27                	jne    14b <sanity+0xc5>
      {
	 wTime[cid] = tempwtime;
 124:	8b 95 d4 fe ff ff    	mov    -0x12c(%ebp),%edx
 12a:	8b 45 cc             	mov    -0x34(%ebp),%eax
 12d:	89 94 85 50 ff ff ff 	mov    %edx,-0xb0(%ebp,%eax,4)
	 rTime[cid] = temprtime;
 134:	8b 95 d0 fe ff ff    	mov    -0x130(%ebp),%edx
 13a:	8b 45 cc             	mov    -0x34(%ebp),%eax
 13d:	89 94 85 d8 fe ff ff 	mov    %edx,-0x128(%ebp,%eax,4)
	found = 1;
 144:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  }
  
  for(i=0;i<30;i++,found=0)
  {
    temp = wait2(&tempwtime,&temprtime);
    for(cid=0;cid<30 && !found;cid++)
 14b:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 14f:	83 7d cc 1d          	cmpl   $0x1d,-0x34(%ebp)
 153:	7f 06                	jg     15b <sanity+0xd5>
 155:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 159:	74 ba                	je     115 <sanity+0x8f>
	 wTime[cid] = tempwtime;
	 rTime[cid] = temprtime;
	found = 1;
      }
    }
    avg_all_wtime += wTime[cid];
 15b:	8b 45 cc             	mov    -0x34(%ebp),%eax
 15e:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 165:	01 45 f4             	add    %eax,-0xc(%ebp)
    avg_all_rtime += rTime[cid];
 168:	8b 45 cc             	mov    -0x34(%ebp),%eax
 16b:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 172:	01 45 f0             	add    %eax,-0x10(%ebp)
    
    switch(cid%3)
 175:	8b 4d cc             	mov    -0x34(%ebp),%ecx
 178:	ba 56 55 55 55       	mov    $0x55555556,%edx
 17d:	89 c8                	mov    %ecx,%eax
 17f:	f7 ea                	imul   %edx
 181:	89 c8                	mov    %ecx,%eax
 183:	c1 f8 1f             	sar    $0x1f,%eax
 186:	89 d3                	mov    %edx,%ebx
 188:	29 c3                	sub    %eax,%ebx
 18a:	89 d8                	mov    %ebx,%eax
 18c:	89 c2                	mov    %eax,%edx
 18e:	01 d2                	add    %edx,%edx
 190:	01 c2                	add    %eax,%edx
 192:	89 c8                	mov    %ecx,%eax
 194:	29 d0                	sub    %edx,%eax
 196:	83 f8 01             	cmp    $0x1,%eax
 199:	74 25                	je     1c0 <sanity+0x13a>
 19b:	83 f8 02             	cmp    $0x2,%eax
 19e:	74 3c                	je     1dc <sanity+0x156>
 1a0:	85 c0                	test   %eax,%eax
 1a2:	75 53                	jne    1f7 <sanity+0x171>
    {
      case 0:
	avg_medium_wtime += wTime[cid];
 1a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1a7:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1ae:	01 45 e4             	add    %eax,-0x1c(%ebp)
	avg_medium_rtime += rTime[cid];
 1b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1b4:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1bb:	01 45 e0             	add    %eax,-0x20(%ebp)
	break;
 1be:	eb 37                	jmp    1f7 <sanity+0x171>
      case 1:
	avg_low_wtime += wTime[cid];
 1c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1c3:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1ca:	01 45 dc             	add    %eax,-0x24(%ebp)
	avg_low_rtime += rTime[cid];
 1cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1d0:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1d7:	01 45 d8             	add    %eax,-0x28(%ebp)
	break;
 1da:	eb 1b                	jmp    1f7 <sanity+0x171>
      case 2:
	avg_high_wtime += wTime[cid];
 1dc:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1df:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1e6:	01 45 ec             	add    %eax,-0x14(%ebp)
	avg_high_rtime += rTime[cid];
 1e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1ec:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1f3:	01 45 e8             	add    %eax,-0x18(%ebp)
	break;
 1f6:	90                   	nop
      foo(cid);
      exit();      
    }
  }
  
  for(i=0;i<30;i++,found=0)
 1f7:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 1fb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 202:	83 7d d0 1d          	cmpl   $0x1d,-0x30(%ebp)
 206:	0f 8e e5 fe ff ff    	jle    f1 <sanity+0x6b>
	avg_high_rtime += rTime[cid];
	break;
    }
  }

  printf(1, "All: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_all_wtime/30, avg_all_rtime/30, (avg_all_wtime + avg_all_rtime)/30);
 20c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 20f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 212:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 215:	ba 89 88 88 88       	mov    $0x88888889,%edx
 21a:	89 c8                	mov    %ecx,%eax
 21c:	f7 ea                	imul   %edx
 21e:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 221:	89 c2                	mov    %eax,%edx
 223:	c1 fa 04             	sar    $0x4,%edx
 226:	89 c8                	mov    %ecx,%eax
 228:	c1 f8 1f             	sar    $0x1f,%eax
 22b:	89 d6                	mov    %edx,%esi
 22d:	29 c6                	sub    %eax,%esi
 22f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
 232:	ba 89 88 88 88       	mov    $0x88888889,%edx
 237:	89 c8                	mov    %ecx,%eax
 239:	f7 ea                	imul   %edx
 23b:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 23e:	89 c2                	mov    %eax,%edx
 240:	c1 fa 04             	sar    $0x4,%edx
 243:	89 c8                	mov    %ecx,%eax
 245:	c1 f8 1f             	sar    $0x1f,%eax
 248:	89 d3                	mov    %edx,%ebx
 24a:	29 c3                	sub    %eax,%ebx
 24c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 24f:	ba 89 88 88 88       	mov    $0x88888889,%edx
 254:	89 c8                	mov    %ecx,%eax
 256:	f7 ea                	imul   %edx
 258:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 25b:	89 c2                	mov    %eax,%edx
 25d:	c1 fa 04             	sar    $0x4,%edx
 260:	89 c8                	mov    %ecx,%eax
 262:	c1 f8 1f             	sar    $0x1f,%eax
 265:	89 d1                	mov    %edx,%ecx
 267:	29 c1                	sub    %eax,%ecx
 269:	89 c8                	mov    %ecx,%eax
 26b:	89 74 24 10          	mov    %esi,0x10(%esp)
 26f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 273:	89 44 24 08          	mov    %eax,0x8(%esp)
 277:	c7 44 24 04 f4 0d 00 	movl   $0xdf4,0x4(%esp)
 27e:	00 
 27f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 286:	e8 66 07 00 00       	call   9f1 <printf>
  printf(1, "High priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_high_wtime/10, avg_high_rtime/10, (avg_high_wtime + avg_high_rtime)/10);
 28b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 28e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 291:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 294:	ba 67 66 66 66       	mov    $0x66666667,%edx
 299:	89 c8                	mov    %ecx,%eax
 29b:	f7 ea                	imul   %edx
 29d:	c1 fa 02             	sar    $0x2,%edx
 2a0:	89 c8                	mov    %ecx,%eax
 2a2:	c1 f8 1f             	sar    $0x1f,%eax
 2a5:	89 d6                	mov    %edx,%esi
 2a7:	29 c6                	sub    %eax,%esi
 2a9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
 2ac:	ba 67 66 66 66       	mov    $0x66666667,%edx
 2b1:	89 c8                	mov    %ecx,%eax
 2b3:	f7 ea                	imul   %edx
 2b5:	c1 fa 02             	sar    $0x2,%edx
 2b8:	89 c8                	mov    %ecx,%eax
 2ba:	c1 f8 1f             	sar    $0x1f,%eax
 2bd:	89 d3                	mov    %edx,%ebx
 2bf:	29 c3                	sub    %eax,%ebx
 2c1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 2c4:	ba 67 66 66 66       	mov    $0x66666667,%edx
 2c9:	89 c8                	mov    %ecx,%eax
 2cb:	f7 ea                	imul   %edx
 2cd:	c1 fa 02             	sar    $0x2,%edx
 2d0:	89 c8                	mov    %ecx,%eax
 2d2:	c1 f8 1f             	sar    $0x1f,%eax
 2d5:	89 d1                	mov    %edx,%ecx
 2d7:	29 c1                	sub    %eax,%ecx
 2d9:	89 c8                	mov    %ecx,%eax
 2db:	89 74 24 10          	mov    %esi,0x10(%esp)
 2df:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2e3:	89 44 24 08          	mov    %eax,0x8(%esp)
 2e7:	c7 44 24 04 4c 0e 00 	movl   $0xe4c,0x4(%esp)
 2ee:	00 
 2ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f6:	e8 f6 06 00 00       	call   9f1 <printf>
  printf(1, "Medium priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_medium_wtime/10, avg_medium_rtime/10, (avg_medium_wtime + avg_medium_rtime)/10);
 2fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
 2fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 301:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 304:	ba 67 66 66 66       	mov    $0x66666667,%edx
 309:	89 c8                	mov    %ecx,%eax
 30b:	f7 ea                	imul   %edx
 30d:	c1 fa 02             	sar    $0x2,%edx
 310:	89 c8                	mov    %ecx,%eax
 312:	c1 f8 1f             	sar    $0x1f,%eax
 315:	89 d6                	mov    %edx,%esi
 317:	29 c6                	sub    %eax,%esi
 319:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 31c:	ba 67 66 66 66       	mov    $0x66666667,%edx
 321:	89 c8                	mov    %ecx,%eax
 323:	f7 ea                	imul   %edx
 325:	c1 fa 02             	sar    $0x2,%edx
 328:	89 c8                	mov    %ecx,%eax
 32a:	c1 f8 1f             	sar    $0x1f,%eax
 32d:	89 d3                	mov    %edx,%ebx
 32f:	29 c3                	sub    %eax,%ebx
 331:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 334:	ba 67 66 66 66       	mov    $0x66666667,%edx
 339:	89 c8                	mov    %ecx,%eax
 33b:	f7 ea                	imul   %edx
 33d:	c1 fa 02             	sar    $0x2,%edx
 340:	89 c8                	mov    %ecx,%eax
 342:	c1 f8 1f             	sar    $0x1f,%eax
 345:	89 d1                	mov    %edx,%ecx
 347:	29 c1                	sub    %eax,%ecx
 349:	89 c8                	mov    %ecx,%eax
 34b:	89 74 24 10          	mov    %esi,0x10(%esp)
 34f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 353:	89 44 24 08          	mov    %eax,0x8(%esp)
 357:	c7 44 24 04 b0 0e 00 	movl   $0xeb0,0x4(%esp)
 35e:	00 
 35f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 366:	e8 86 06 00 00       	call   9f1 <printf>
  printf(1, "Low priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_low_wtime/10, avg_low_rtime/10, (avg_low_wtime + avg_low_rtime)/10);
 36b:	8b 45 d8             	mov    -0x28(%ebp),%eax
 36e:	8b 55 dc             	mov    -0x24(%ebp),%edx
 371:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 374:	ba 67 66 66 66       	mov    $0x66666667,%edx
 379:	89 c8                	mov    %ecx,%eax
 37b:	f7 ea                	imul   %edx
 37d:	c1 fa 02             	sar    $0x2,%edx
 380:	89 c8                	mov    %ecx,%eax
 382:	c1 f8 1f             	sar    $0x1f,%eax
 385:	89 d6                	mov    %edx,%esi
 387:	29 c6                	sub    %eax,%esi
 389:	8b 4d d8             	mov    -0x28(%ebp),%ecx
 38c:	ba 67 66 66 66       	mov    $0x66666667,%edx
 391:	89 c8                	mov    %ecx,%eax
 393:	f7 ea                	imul   %edx
 395:	c1 fa 02             	sar    $0x2,%edx
 398:	89 c8                	mov    %ecx,%eax
 39a:	c1 f8 1f             	sar    $0x1f,%eax
 39d:	89 d3                	mov    %edx,%ebx
 39f:	29 c3                	sub    %eax,%ebx
 3a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
 3a4:	ba 67 66 66 66       	mov    $0x66666667,%edx
 3a9:	89 c8                	mov    %ecx,%eax
 3ab:	f7 ea                	imul   %edx
 3ad:	c1 fa 02             	sar    $0x2,%edx
 3b0:	89 c8                	mov    %ecx,%eax
 3b2:	c1 f8 1f             	sar    $0x1f,%eax
 3b5:	89 d1                	mov    %edx,%ecx
 3b7:	29 c1                	sub    %eax,%ecx
 3b9:	89 c8                	mov    %ecx,%eax
 3bb:	89 74 24 10          	mov    %esi,0x10(%esp)
 3bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 3c3:	89 44 24 08          	mov    %eax,0x8(%esp)
 3c7:	c7 44 24 04 14 0f 00 	movl   $0xf14,0x4(%esp)
 3ce:	00 
 3cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3d6:	e8 16 06 00 00       	call   9f1 <printf>

  for(i=0;i<30;i++)
 3db:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 3e2:	eb 56                	jmp    43a <sanity+0x3b4>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",i,wTime[i],rTime[i],wTime[i]+rTime[i]);
 3e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3e7:	8b 94 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%edx
 3ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3f1:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 3f8:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 3fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3fe:	8b 94 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%edx
 405:	8b 45 d0             	mov    -0x30(%ebp),%eax
 408:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 40f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 413:	89 54 24 10          	mov    %edx,0x10(%esp)
 417:	89 44 24 0c          	mov    %eax,0xc(%esp)
 41b:	8b 45 d0             	mov    -0x30(%ebp),%eax
 41e:	89 44 24 08          	mov    %eax,0x8(%esp)
 422:	c7 44 24 04 78 0f 00 	movl   $0xf78,0x4(%esp)
 429:	00 
 42a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 431:	e8 bb 05 00 00       	call   9f1 <printf>
  printf(1, "All: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_all_wtime/30, avg_all_rtime/30, (avg_all_wtime + avg_all_rtime)/30);
  printf(1, "High priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_high_wtime/10, avg_high_rtime/10, (avg_high_wtime + avg_high_rtime)/10);
  printf(1, "Medium priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_medium_wtime/10, avg_medium_rtime/10, (avg_medium_wtime + avg_medium_rtime)/10);
  printf(1, "Low priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_low_wtime/10, avg_low_rtime/10, (avg_low_wtime + avg_low_rtime)/10);

  for(i=0;i<30;i++)
 436:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 43a:	83 7d d0 1d          	cmpl   $0x1d,-0x30(%ebp)
 43e:	7e a4                	jle    3e4 <sanity+0x35e>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",i,wTime[i],rTime[i],wTime[i]+rTime[i]);

}
 440:	81 c4 c0 01 00 00    	add    $0x1c0,%esp
 446:	5b                   	pop    %ebx
 447:	5e                   	pop    %esi
 448:	5d                   	pop    %ebp
 449:	c3                   	ret    

0000044a <main>:
int
main(void)
{
 44a:	55                   	push   %ebp
 44b:	89 e5                	mov    %esp,%ebp
 44d:	83 e4 f0             	and    $0xfffffff0,%esp
  sanity();
 450:	e8 31 fc ff ff       	call   86 <sanity>
  exit();
 455:	e8 0a 04 00 00       	call   864 <exit>
 45a:	66 90                	xchg   %ax,%ax

0000045c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 45c:	55                   	push   %ebp
 45d:	89 e5                	mov    %esp,%ebp
 45f:	57                   	push   %edi
 460:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 461:	8b 4d 08             	mov    0x8(%ebp),%ecx
 464:	8b 55 10             	mov    0x10(%ebp),%edx
 467:	8b 45 0c             	mov    0xc(%ebp),%eax
 46a:	89 cb                	mov    %ecx,%ebx
 46c:	89 df                	mov    %ebx,%edi
 46e:	89 d1                	mov    %edx,%ecx
 470:	fc                   	cld    
 471:	f3 aa                	rep stos %al,%es:(%edi)
 473:	89 ca                	mov    %ecx,%edx
 475:	89 fb                	mov    %edi,%ebx
 477:	89 5d 08             	mov    %ebx,0x8(%ebp)
 47a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 47d:	5b                   	pop    %ebx
 47e:	5f                   	pop    %edi
 47f:	5d                   	pop    %ebp
 480:	c3                   	ret    

00000481 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 481:	55                   	push   %ebp
 482:	89 e5                	mov    %esp,%ebp
 484:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 48d:	90                   	nop
 48e:	8b 45 0c             	mov    0xc(%ebp),%eax
 491:	0f b6 10             	movzbl (%eax),%edx
 494:	8b 45 08             	mov    0x8(%ebp),%eax
 497:	88 10                	mov    %dl,(%eax)
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	0f b6 00             	movzbl (%eax),%eax
 49f:	84 c0                	test   %al,%al
 4a1:	0f 95 c0             	setne  %al
 4a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 4ac:	84 c0                	test   %al,%al
 4ae:	75 de                	jne    48e <strcpy+0xd>
    ;
  return os;
 4b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b3:	c9                   	leave  
 4b4:	c3                   	ret    

000004b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4b5:	55                   	push   %ebp
 4b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4b8:	eb 08                	jmp    4c2 <strcmp+0xd>
    p++, q++;
 4ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	0f b6 00             	movzbl (%eax),%eax
 4c8:	84 c0                	test   %al,%al
 4ca:	74 10                	je     4dc <strcmp+0x27>
 4cc:	8b 45 08             	mov    0x8(%ebp),%eax
 4cf:	0f b6 10             	movzbl (%eax),%edx
 4d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d5:	0f b6 00             	movzbl (%eax),%eax
 4d8:	38 c2                	cmp    %al,%dl
 4da:	74 de                	je     4ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	0f b6 00             	movzbl (%eax),%eax
 4e2:	0f b6 d0             	movzbl %al,%edx
 4e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e8:	0f b6 00             	movzbl (%eax),%eax
 4eb:	0f b6 c0             	movzbl %al,%eax
 4ee:	89 d1                	mov    %edx,%ecx
 4f0:	29 c1                	sub    %eax,%ecx
 4f2:	89 c8                	mov    %ecx,%eax
}
 4f4:	5d                   	pop    %ebp
 4f5:	c3                   	ret    

000004f6 <strlen>:

uint
strlen(char *s)
{
 4f6:	55                   	push   %ebp
 4f7:	89 e5                	mov    %esp,%ebp
 4f9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 4fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 503:	eb 04                	jmp    509 <strlen+0x13>
 505:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 509:	8b 55 fc             	mov    -0x4(%ebp),%edx
 50c:	8b 45 08             	mov    0x8(%ebp),%eax
 50f:	01 d0                	add    %edx,%eax
 511:	0f b6 00             	movzbl (%eax),%eax
 514:	84 c0                	test   %al,%al
 516:	75 ed                	jne    505 <strlen+0xf>
  return n;
 518:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 51b:	c9                   	leave  
 51c:	c3                   	ret    

0000051d <memset>:

void*
memset(void *dst, int c, uint n)
{
 51d:	55                   	push   %ebp
 51e:	89 e5                	mov    %esp,%ebp
 520:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 523:	8b 45 10             	mov    0x10(%ebp),%eax
 526:	89 44 24 08          	mov    %eax,0x8(%esp)
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	89 44 24 04          	mov    %eax,0x4(%esp)
 531:	8b 45 08             	mov    0x8(%ebp),%eax
 534:	89 04 24             	mov    %eax,(%esp)
 537:	e8 20 ff ff ff       	call   45c <stosb>
  return dst;
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 53f:	c9                   	leave  
 540:	c3                   	ret    

00000541 <strchr>:

char*
strchr(const char *s, char c)
{
 541:	55                   	push   %ebp
 542:	89 e5                	mov    %esp,%ebp
 544:	83 ec 04             	sub    $0x4,%esp
 547:	8b 45 0c             	mov    0xc(%ebp),%eax
 54a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 54d:	eb 14                	jmp    563 <strchr+0x22>
    if(*s == c)
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	0f b6 00             	movzbl (%eax),%eax
 555:	3a 45 fc             	cmp    -0x4(%ebp),%al
 558:	75 05                	jne    55f <strchr+0x1e>
      return (char*)s;
 55a:	8b 45 08             	mov    0x8(%ebp),%eax
 55d:	eb 13                	jmp    572 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 55f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	0f b6 00             	movzbl (%eax),%eax
 569:	84 c0                	test   %al,%al
 56b:	75 e2                	jne    54f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 56d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 572:	c9                   	leave  
 573:	c3                   	ret    

00000574 <gets>:

char*
gets(char *buf, int max)
{
 574:	55                   	push   %ebp
 575:	89 e5                	mov    %esp,%ebp
 577:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 57a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 581:	eb 46                	jmp    5c9 <gets+0x55>
    cc = read(0, &c, 1);
 583:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 58a:	00 
 58b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 58e:	89 44 24 04          	mov    %eax,0x4(%esp)
 592:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 599:	e8 ee 02 00 00       	call   88c <read>
 59e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a5:	7e 2f                	jle    5d6 <gets+0x62>
      break;
    buf[i++] = c;
 5a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5aa:	8b 45 08             	mov    0x8(%ebp),%eax
 5ad:	01 c2                	add    %eax,%edx
 5af:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5b3:	88 02                	mov    %al,(%edx)
 5b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 5b9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5bd:	3c 0a                	cmp    $0xa,%al
 5bf:	74 16                	je     5d7 <gets+0x63>
 5c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5c5:	3c 0d                	cmp    $0xd,%al
 5c7:	74 0e                	je     5d7 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cc:	83 c0 01             	add    $0x1,%eax
 5cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 5d2:	7c af                	jl     583 <gets+0xf>
 5d4:	eb 01                	jmp    5d7 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 5d6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 5d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5da:	8b 45 08             	mov    0x8(%ebp),%eax
 5dd:	01 d0                	add    %edx,%eax
 5df:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5e5:	c9                   	leave  
 5e6:	c3                   	ret    

000005e7 <stat>:

int
stat(char *n, struct stat *st)
{
 5e7:	55                   	push   %ebp
 5e8:	89 e5                	mov    %esp,%ebp
 5ea:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 5f4:	00 
 5f5:	8b 45 08             	mov    0x8(%ebp),%eax
 5f8:	89 04 24             	mov    %eax,(%esp)
 5fb:	e8 b4 02 00 00       	call   8b4 <open>
 600:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 603:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 607:	79 07                	jns    610 <stat+0x29>
    return -1;
 609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 60e:	eb 23                	jmp    633 <stat+0x4c>
  r = fstat(fd, st);
 610:	8b 45 0c             	mov    0xc(%ebp),%eax
 613:	89 44 24 04          	mov    %eax,0x4(%esp)
 617:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61a:	89 04 24             	mov    %eax,(%esp)
 61d:	e8 aa 02 00 00       	call   8cc <fstat>
 622:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 625:	8b 45 f4             	mov    -0xc(%ebp),%eax
 628:	89 04 24             	mov    %eax,(%esp)
 62b:	e8 6c 02 00 00       	call   89c <close>
  return r;
 630:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 633:	c9                   	leave  
 634:	c3                   	ret    

00000635 <atoi>:

int
atoi(const char *s)
{
 635:	55                   	push   %ebp
 636:	89 e5                	mov    %esp,%ebp
 638:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 63b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 642:	eb 23                	jmp    667 <atoi+0x32>
    n = n*10 + *s++ - '0';
 644:	8b 55 fc             	mov    -0x4(%ebp),%edx
 647:	89 d0                	mov    %edx,%eax
 649:	c1 e0 02             	shl    $0x2,%eax
 64c:	01 d0                	add    %edx,%eax
 64e:	01 c0                	add    %eax,%eax
 650:	89 c2                	mov    %eax,%edx
 652:	8b 45 08             	mov    0x8(%ebp),%eax
 655:	0f b6 00             	movzbl (%eax),%eax
 658:	0f be c0             	movsbl %al,%eax
 65b:	01 d0                	add    %edx,%eax
 65d:	83 e8 30             	sub    $0x30,%eax
 660:	89 45 fc             	mov    %eax,-0x4(%ebp)
 663:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	0f b6 00             	movzbl (%eax),%eax
 66d:	3c 2f                	cmp    $0x2f,%al
 66f:	7e 0a                	jle    67b <atoi+0x46>
 671:	8b 45 08             	mov    0x8(%ebp),%eax
 674:	0f b6 00             	movzbl (%eax),%eax
 677:	3c 39                	cmp    $0x39,%al
 679:	7e c9                	jle    644 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 67b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 67e:	c9                   	leave  
 67f:	c3                   	ret    

00000680 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 680:	55                   	push   %ebp
 681:	89 e5                	mov    %esp,%ebp
 683:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 686:	8b 45 08             	mov    0x8(%ebp),%eax
 689:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 68c:	8b 45 0c             	mov    0xc(%ebp),%eax
 68f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 692:	eb 13                	jmp    6a7 <memmove+0x27>
    *dst++ = *src++;
 694:	8b 45 f8             	mov    -0x8(%ebp),%eax
 697:	0f b6 10             	movzbl (%eax),%edx
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	88 10                	mov    %dl,(%eax)
 69f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 6a3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 6a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6ab:	0f 9f c0             	setg   %al
 6ae:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6b2:	84 c0                	test   %al,%al
 6b4:	75 de                	jne    694 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 6b6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6b9:	c9                   	leave  
 6ba:	c3                   	ret    

000006bb <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 6bb:	55                   	push   %ebp
 6bc:	89 e5                	mov    %esp,%ebp
 6be:	83 ec 38             	sub    $0x38,%esp
 6c1:	8b 45 10             	mov    0x10(%ebp),%eax
 6c4:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 6c7:	8b 45 14             	mov    0x14(%ebp),%eax
 6ca:	8b 00                	mov    (%eax),%eax
 6cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 6d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6da:	74 06                	je     6e2 <strtok+0x27>
 6dc:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 6e0:	75 5a                	jne    73c <strtok+0x81>
    return match;
 6e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e5:	eb 76                	jmp    75d <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 6e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ed:	01 d0                	add    %edx,%eax
 6ef:	0f b6 00             	movzbl (%eax),%eax
 6f2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 6f5:	74 06                	je     6fd <strtok+0x42>
      {
	index++;
 6f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6fb:	eb 40                	jmp    73d <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 6fd:	8b 45 14             	mov    0x14(%ebp),%eax
 700:	8b 00                	mov    (%eax),%eax
 702:	8b 55 f4             	mov    -0xc(%ebp),%edx
 705:	29 c2                	sub    %eax,%edx
 707:	8b 45 14             	mov    0x14(%ebp),%eax
 70a:	8b 00                	mov    (%eax),%eax
 70c:	89 c1                	mov    %eax,%ecx
 70e:	8b 45 0c             	mov    0xc(%ebp),%eax
 711:	01 c8                	add    %ecx,%eax
 713:	89 54 24 08          	mov    %edx,0x8(%esp)
 717:	89 44 24 04          	mov    %eax,0x4(%esp)
 71b:	8b 45 08             	mov    0x8(%ebp),%eax
 71e:	89 04 24             	mov    %eax,(%esp)
 721:	e8 39 00 00 00       	call   75f <strncpy>
 726:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 729:	8b 45 08             	mov    0x8(%ebp),%eax
 72c:	0f b6 00             	movzbl (%eax),%eax
 72f:	84 c0                	test   %al,%al
 731:	74 1b                	je     74e <strtok+0x93>
	  match = 1;
 733:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 73a:	eb 12                	jmp    74e <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 73c:	90                   	nop
 73d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 740:	8b 45 0c             	mov    0xc(%ebp),%eax
 743:	01 d0                	add    %edx,%eax
 745:	0f b6 00             	movzbl (%eax),%eax
 748:	84 c0                	test   %al,%al
 74a:	75 9b                	jne    6e7 <strtok+0x2c>
 74c:	eb 01                	jmp    74f <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 74e:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 74f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 752:	8d 50 01             	lea    0x1(%eax),%edx
 755:	8b 45 14             	mov    0x14(%ebp),%eax
 758:	89 10                	mov    %edx,(%eax)
  return match;
 75a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 75d:	c9                   	leave  
 75e:	c3                   	ret    

0000075f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 75f:	55                   	push   %ebp
 760:	89 e5                	mov    %esp,%ebp
 762:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 765:	8b 45 08             	mov    0x8(%ebp),%eax
 768:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 76b:	90                   	nop
 76c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 770:	0f 9f c0             	setg   %al
 773:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 777:	84 c0                	test   %al,%al
 779:	74 30                	je     7ab <strncpy+0x4c>
 77b:	8b 45 0c             	mov    0xc(%ebp),%eax
 77e:	0f b6 10             	movzbl (%eax),%edx
 781:	8b 45 08             	mov    0x8(%ebp),%eax
 784:	88 10                	mov    %dl,(%eax)
 786:	8b 45 08             	mov    0x8(%ebp),%eax
 789:	0f b6 00             	movzbl (%eax),%eax
 78c:	84 c0                	test   %al,%al
 78e:	0f 95 c0             	setne  %al
 791:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 795:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 799:	84 c0                	test   %al,%al
 79b:	75 cf                	jne    76c <strncpy+0xd>
    ;
  while(n-- > 0)
 79d:	eb 0c                	jmp    7ab <strncpy+0x4c>
    *s++ = 0;
 79f:	8b 45 08             	mov    0x8(%ebp),%eax
 7a2:	c6 00 00             	movb   $0x0,(%eax)
 7a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 7a9:	eb 01                	jmp    7ac <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 7ab:	90                   	nop
 7ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 7b0:	0f 9f c0             	setg   %al
 7b3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 7b7:	84 c0                	test   %al,%al
 7b9:	75 e4                	jne    79f <strncpy+0x40>
    *s++ = 0;
  return os;
 7bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7be:	c9                   	leave  
 7bf:	c3                   	ret    

000007c0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 7c0:	55                   	push   %ebp
 7c1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 7c3:	eb 0c                	jmp    7d1 <strncmp+0x11>
    n--, p++, q++;
 7c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 7c9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 7cd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 7d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 7d5:	74 1a                	je     7f1 <strncmp+0x31>
 7d7:	8b 45 08             	mov    0x8(%ebp),%eax
 7da:	0f b6 00             	movzbl (%eax),%eax
 7dd:	84 c0                	test   %al,%al
 7df:	74 10                	je     7f1 <strncmp+0x31>
 7e1:	8b 45 08             	mov    0x8(%ebp),%eax
 7e4:	0f b6 10             	movzbl (%eax),%edx
 7e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 7ea:	0f b6 00             	movzbl (%eax),%eax
 7ed:	38 c2                	cmp    %al,%dl
 7ef:	74 d4                	je     7c5 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 7f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 7f5:	75 07                	jne    7fe <strncmp+0x3e>
    return 0;
 7f7:	b8 00 00 00 00       	mov    $0x0,%eax
 7fc:	eb 18                	jmp    816 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 7fe:	8b 45 08             	mov    0x8(%ebp),%eax
 801:	0f b6 00             	movzbl (%eax),%eax
 804:	0f b6 d0             	movzbl %al,%edx
 807:	8b 45 0c             	mov    0xc(%ebp),%eax
 80a:	0f b6 00             	movzbl (%eax),%eax
 80d:	0f b6 c0             	movzbl %al,%eax
 810:	89 d1                	mov    %edx,%ecx
 812:	29 c1                	sub    %eax,%ecx
 814:	89 c8                	mov    %ecx,%eax
}
 816:	5d                   	pop    %ebp
 817:	c3                   	ret    

00000818 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 818:	55                   	push   %ebp
 819:	89 e5                	mov    %esp,%ebp
  while(*p){
 81b:	eb 13                	jmp    830 <strcat+0x18>
    *dest++ = *p++;
 81d:	8b 45 0c             	mov    0xc(%ebp),%eax
 820:	0f b6 10             	movzbl (%eax),%edx
 823:	8b 45 08             	mov    0x8(%ebp),%eax
 826:	88 10                	mov    %dl,(%eax)
 828:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 82c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 830:	8b 45 0c             	mov    0xc(%ebp),%eax
 833:	0f b6 00             	movzbl (%eax),%eax
 836:	84 c0                	test   %al,%al
 838:	75 e3                	jne    81d <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 83a:	eb 13                	jmp    84f <strcat+0x37>
    *dest++ = *q++;
 83c:	8b 45 10             	mov    0x10(%ebp),%eax
 83f:	0f b6 10             	movzbl (%eax),%edx
 842:	8b 45 08             	mov    0x8(%ebp),%eax
 845:	88 10                	mov    %dl,(%eax)
 847:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 84b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 84f:	8b 45 10             	mov    0x10(%ebp),%eax
 852:	0f b6 00             	movzbl (%eax),%eax
 855:	84 c0                	test   %al,%al
 857:	75 e3                	jne    83c <strcat+0x24>
    *dest++ = *q++;
  }  
 859:	5d                   	pop    %ebp
 85a:	c3                   	ret    
 85b:	90                   	nop

0000085c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 85c:	b8 01 00 00 00       	mov    $0x1,%eax
 861:	cd 40                	int    $0x40
 863:	c3                   	ret    

00000864 <exit>:
SYSCALL(exit)
 864:	b8 02 00 00 00       	mov    $0x2,%eax
 869:	cd 40                	int    $0x40
 86b:	c3                   	ret    

0000086c <wait>:
SYSCALL(wait)
 86c:	b8 03 00 00 00       	mov    $0x3,%eax
 871:	cd 40                	int    $0x40
 873:	c3                   	ret    

00000874 <wait2>:
SYSCALL(wait2)
 874:	b8 16 00 00 00       	mov    $0x16,%eax
 879:	cd 40                	int    $0x40
 87b:	c3                   	ret    

0000087c <nice>:
SYSCALL(nice)
 87c:	b8 17 00 00 00       	mov    $0x17,%eax
 881:	cd 40                	int    $0x40
 883:	c3                   	ret    

00000884 <pipe>:
SYSCALL(pipe)
 884:	b8 04 00 00 00       	mov    $0x4,%eax
 889:	cd 40                	int    $0x40
 88b:	c3                   	ret    

0000088c <read>:
SYSCALL(read)
 88c:	b8 05 00 00 00       	mov    $0x5,%eax
 891:	cd 40                	int    $0x40
 893:	c3                   	ret    

00000894 <write>:
SYSCALL(write)
 894:	b8 10 00 00 00       	mov    $0x10,%eax
 899:	cd 40                	int    $0x40
 89b:	c3                   	ret    

0000089c <close>:
SYSCALL(close)
 89c:	b8 15 00 00 00       	mov    $0x15,%eax
 8a1:	cd 40                	int    $0x40
 8a3:	c3                   	ret    

000008a4 <kill>:
SYSCALL(kill)
 8a4:	b8 06 00 00 00       	mov    $0x6,%eax
 8a9:	cd 40                	int    $0x40
 8ab:	c3                   	ret    

000008ac <exec>:
SYSCALL(exec)
 8ac:	b8 07 00 00 00       	mov    $0x7,%eax
 8b1:	cd 40                	int    $0x40
 8b3:	c3                   	ret    

000008b4 <open>:
SYSCALL(open)
 8b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 8b9:	cd 40                	int    $0x40
 8bb:	c3                   	ret    

000008bc <mknod>:
SYSCALL(mknod)
 8bc:	b8 11 00 00 00       	mov    $0x11,%eax
 8c1:	cd 40                	int    $0x40
 8c3:	c3                   	ret    

000008c4 <unlink>:
SYSCALL(unlink)
 8c4:	b8 12 00 00 00       	mov    $0x12,%eax
 8c9:	cd 40                	int    $0x40
 8cb:	c3                   	ret    

000008cc <fstat>:
SYSCALL(fstat)
 8cc:	b8 08 00 00 00       	mov    $0x8,%eax
 8d1:	cd 40                	int    $0x40
 8d3:	c3                   	ret    

000008d4 <link>:
SYSCALL(link)
 8d4:	b8 13 00 00 00       	mov    $0x13,%eax
 8d9:	cd 40                	int    $0x40
 8db:	c3                   	ret    

000008dc <mkdir>:
SYSCALL(mkdir)
 8dc:	b8 14 00 00 00       	mov    $0x14,%eax
 8e1:	cd 40                	int    $0x40
 8e3:	c3                   	ret    

000008e4 <chdir>:
SYSCALL(chdir)
 8e4:	b8 09 00 00 00       	mov    $0x9,%eax
 8e9:	cd 40                	int    $0x40
 8eb:	c3                   	ret    

000008ec <dup>:
SYSCALL(dup)
 8ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 8f1:	cd 40                	int    $0x40
 8f3:	c3                   	ret    

000008f4 <getpid>:
SYSCALL(getpid)
 8f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 8f9:	cd 40                	int    $0x40
 8fb:	c3                   	ret    

000008fc <sbrk>:
SYSCALL(sbrk)
 8fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 901:	cd 40                	int    $0x40
 903:	c3                   	ret    

00000904 <sleep>:
SYSCALL(sleep)
 904:	b8 0d 00 00 00       	mov    $0xd,%eax
 909:	cd 40                	int    $0x40
 90b:	c3                   	ret    

0000090c <uptime>:
SYSCALL(uptime)
 90c:	b8 0e 00 00 00       	mov    $0xe,%eax
 911:	cd 40                	int    $0x40
 913:	c3                   	ret    

00000914 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 914:	55                   	push   %ebp
 915:	89 e5                	mov    %esp,%ebp
 917:	83 ec 28             	sub    $0x28,%esp
 91a:	8b 45 0c             	mov    0xc(%ebp),%eax
 91d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 920:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 927:	00 
 928:	8d 45 f4             	lea    -0xc(%ebp),%eax
 92b:	89 44 24 04          	mov    %eax,0x4(%esp)
 92f:	8b 45 08             	mov    0x8(%ebp),%eax
 932:	89 04 24             	mov    %eax,(%esp)
 935:	e8 5a ff ff ff       	call   894 <write>
}
 93a:	c9                   	leave  
 93b:	c3                   	ret    

0000093c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 93c:	55                   	push   %ebp
 93d:	89 e5                	mov    %esp,%ebp
 93f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 942:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 949:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 94d:	74 17                	je     966 <printint+0x2a>
 94f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 953:	79 11                	jns    966 <printint+0x2a>
    neg = 1;
 955:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 95c:	8b 45 0c             	mov    0xc(%ebp),%eax
 95f:	f7 d8                	neg    %eax
 961:	89 45 ec             	mov    %eax,-0x14(%ebp)
 964:	eb 06                	jmp    96c <printint+0x30>
  } else {
    x = xx;
 966:	8b 45 0c             	mov    0xc(%ebp),%eax
 969:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 96c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 973:	8b 4d 10             	mov    0x10(%ebp),%ecx
 976:	8b 45 ec             	mov    -0x14(%ebp),%eax
 979:	ba 00 00 00 00       	mov    $0x0,%edx
 97e:	f7 f1                	div    %ecx
 980:	89 d0                	mov    %edx,%eax
 982:	0f b6 80 cc 12 00 00 	movzbl 0x12cc(%eax),%eax
 989:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 98c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 98f:	01 ca                	add    %ecx,%edx
 991:	88 02                	mov    %al,(%edx)
 993:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 997:	8b 55 10             	mov    0x10(%ebp),%edx
 99a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 99d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9a0:	ba 00 00 00 00       	mov    $0x0,%edx
 9a5:	f7 75 d4             	divl   -0x2c(%ebp)
 9a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 9ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9af:	75 c2                	jne    973 <printint+0x37>
  if(neg)
 9b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9b5:	74 2e                	je     9e5 <printint+0xa9>
    buf[i++] = '-';
 9b7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	01 d0                	add    %edx,%eax
 9bf:	c6 00 2d             	movb   $0x2d,(%eax)
 9c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 9c6:	eb 1d                	jmp    9e5 <printint+0xa9>
    putc(fd, buf[i]);
 9c8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 9cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ce:	01 d0                	add    %edx,%eax
 9d0:	0f b6 00             	movzbl (%eax),%eax
 9d3:	0f be c0             	movsbl %al,%eax
 9d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 9da:	8b 45 08             	mov    0x8(%ebp),%eax
 9dd:	89 04 24             	mov    %eax,(%esp)
 9e0:	e8 2f ff ff ff       	call   914 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 9e5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 9e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9ed:	79 d9                	jns    9c8 <printint+0x8c>
    putc(fd, buf[i]);
}
 9ef:	c9                   	leave  
 9f0:	c3                   	ret    

000009f1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 9f1:	55                   	push   %ebp
 9f2:	89 e5                	mov    %esp,%ebp
 9f4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 9f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 9fe:	8d 45 0c             	lea    0xc(%ebp),%eax
 a01:	83 c0 04             	add    $0x4,%eax
 a04:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 a07:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 a0e:	e9 7d 01 00 00       	jmp    b90 <printf+0x19f>
    c = fmt[i] & 0xff;
 a13:	8b 55 0c             	mov    0xc(%ebp),%edx
 a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a19:	01 d0                	add    %edx,%eax
 a1b:	0f b6 00             	movzbl (%eax),%eax
 a1e:	0f be c0             	movsbl %al,%eax
 a21:	25 ff 00 00 00       	and    $0xff,%eax
 a26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a29:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a2d:	75 2c                	jne    a5b <printf+0x6a>
      if(c == '%'){
 a2f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a33:	75 0c                	jne    a41 <printf+0x50>
        state = '%';
 a35:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a3c:	e9 4b 01 00 00       	jmp    b8c <printf+0x19b>
      } else {
        putc(fd, c);
 a41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a44:	0f be c0             	movsbl %al,%eax
 a47:	89 44 24 04          	mov    %eax,0x4(%esp)
 a4b:	8b 45 08             	mov    0x8(%ebp),%eax
 a4e:	89 04 24             	mov    %eax,(%esp)
 a51:	e8 be fe ff ff       	call   914 <putc>
 a56:	e9 31 01 00 00       	jmp    b8c <printf+0x19b>
      }
    } else if(state == '%'){
 a5b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a5f:	0f 85 27 01 00 00    	jne    b8c <printf+0x19b>
      if(c == 'd'){
 a65:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a69:	75 2d                	jne    a98 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 a6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a6e:	8b 00                	mov    (%eax),%eax
 a70:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 a77:	00 
 a78:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 a7f:	00 
 a80:	89 44 24 04          	mov    %eax,0x4(%esp)
 a84:	8b 45 08             	mov    0x8(%ebp),%eax
 a87:	89 04 24             	mov    %eax,(%esp)
 a8a:	e8 ad fe ff ff       	call   93c <printint>
        ap++;
 a8f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a93:	e9 ed 00 00 00       	jmp    b85 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 a98:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a9c:	74 06                	je     aa4 <printf+0xb3>
 a9e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 aa2:	75 2d                	jne    ad1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 aa4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 aa7:	8b 00                	mov    (%eax),%eax
 aa9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 ab0:	00 
 ab1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 ab8:	00 
 ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
 abd:	8b 45 08             	mov    0x8(%ebp),%eax
 ac0:	89 04 24             	mov    %eax,(%esp)
 ac3:	e8 74 fe ff ff       	call   93c <printint>
        ap++;
 ac8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 acc:	e9 b4 00 00 00       	jmp    b85 <printf+0x194>
      } else if(c == 's'){
 ad1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 ad5:	75 46                	jne    b1d <printf+0x12c>
        s = (char*)*ap;
 ad7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ada:	8b 00                	mov    (%eax),%eax
 adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 adf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 ae3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae7:	75 27                	jne    b10 <printf+0x11f>
          s = "(null)";
 ae9:	c7 45 f4 b9 0f 00 00 	movl   $0xfb9,-0xc(%ebp)
        while(*s != 0){
 af0:	eb 1e                	jmp    b10 <printf+0x11f>
          putc(fd, *s);
 af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af5:	0f b6 00             	movzbl (%eax),%eax
 af8:	0f be c0             	movsbl %al,%eax
 afb:	89 44 24 04          	mov    %eax,0x4(%esp)
 aff:	8b 45 08             	mov    0x8(%ebp),%eax
 b02:	89 04 24             	mov    %eax,(%esp)
 b05:	e8 0a fe ff ff       	call   914 <putc>
          s++;
 b0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 b0e:	eb 01                	jmp    b11 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 b10:	90                   	nop
 b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b14:	0f b6 00             	movzbl (%eax),%eax
 b17:	84 c0                	test   %al,%al
 b19:	75 d7                	jne    af2 <printf+0x101>
 b1b:	eb 68                	jmp    b85 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b1d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b21:	75 1d                	jne    b40 <printf+0x14f>
        putc(fd, *ap);
 b23:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b26:	8b 00                	mov    (%eax),%eax
 b28:	0f be c0             	movsbl %al,%eax
 b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
 b2f:	8b 45 08             	mov    0x8(%ebp),%eax
 b32:	89 04 24             	mov    %eax,(%esp)
 b35:	e8 da fd ff ff       	call   914 <putc>
        ap++;
 b3a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b3e:	eb 45                	jmp    b85 <printf+0x194>
      } else if(c == '%'){
 b40:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b44:	75 17                	jne    b5d <printf+0x16c>
        putc(fd, c);
 b46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b49:	0f be c0             	movsbl %al,%eax
 b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
 b50:	8b 45 08             	mov    0x8(%ebp),%eax
 b53:	89 04 24             	mov    %eax,(%esp)
 b56:	e8 b9 fd ff ff       	call   914 <putc>
 b5b:	eb 28                	jmp    b85 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b5d:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 b64:	00 
 b65:	8b 45 08             	mov    0x8(%ebp),%eax
 b68:	89 04 24             	mov    %eax,(%esp)
 b6b:	e8 a4 fd ff ff       	call   914 <putc>
        putc(fd, c);
 b70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b73:	0f be c0             	movsbl %al,%eax
 b76:	89 44 24 04          	mov    %eax,0x4(%esp)
 b7a:	8b 45 08             	mov    0x8(%ebp),%eax
 b7d:	89 04 24             	mov    %eax,(%esp)
 b80:	e8 8f fd ff ff       	call   914 <putc>
      }
      state = 0;
 b85:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 b8c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 b90:	8b 55 0c             	mov    0xc(%ebp),%edx
 b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b96:	01 d0                	add    %edx,%eax
 b98:	0f b6 00             	movzbl (%eax),%eax
 b9b:	84 c0                	test   %al,%al
 b9d:	0f 85 70 fe ff ff    	jne    a13 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 ba3:	c9                   	leave  
 ba4:	c3                   	ret    
 ba5:	66 90                	xchg   %ax,%ax
 ba7:	90                   	nop

00000ba8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ba8:	55                   	push   %ebp
 ba9:	89 e5                	mov    %esp,%ebp
 bab:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bae:	8b 45 08             	mov    0x8(%ebp),%eax
 bb1:	83 e8 08             	sub    $0x8,%eax
 bb4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bb7:	a1 e8 12 00 00       	mov    0x12e8,%eax
 bbc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bbf:	eb 24                	jmp    be5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc4:	8b 00                	mov    (%eax),%eax
 bc6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bc9:	77 12                	ja     bdd <free+0x35>
 bcb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bd1:	77 24                	ja     bf7 <free+0x4f>
 bd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd6:	8b 00                	mov    (%eax),%eax
 bd8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bdb:	77 1a                	ja     bf7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 be0:	8b 00                	mov    (%eax),%eax
 be2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 be5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 beb:	76 d4                	jbe    bc1 <free+0x19>
 bed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf0:	8b 00                	mov    (%eax),%eax
 bf2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bf5:	76 ca                	jbe    bc1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 bf7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bfa:	8b 40 04             	mov    0x4(%eax),%eax
 bfd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c04:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c07:	01 c2                	add    %eax,%edx
 c09:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c0c:	8b 00                	mov    (%eax),%eax
 c0e:	39 c2                	cmp    %eax,%edx
 c10:	75 24                	jne    c36 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 c12:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c15:	8b 50 04             	mov    0x4(%eax),%edx
 c18:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c1b:	8b 00                	mov    (%eax),%eax
 c1d:	8b 40 04             	mov    0x4(%eax),%eax
 c20:	01 c2                	add    %eax,%edx
 c22:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c25:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c28:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c2b:	8b 00                	mov    (%eax),%eax
 c2d:	8b 10                	mov    (%eax),%edx
 c2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c32:	89 10                	mov    %edx,(%eax)
 c34:	eb 0a                	jmp    c40 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 c36:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c39:	8b 10                	mov    (%eax),%edx
 c3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c3e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c40:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c43:	8b 40 04             	mov    0x4(%eax),%eax
 c46:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c50:	01 d0                	add    %edx,%eax
 c52:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c55:	75 20                	jne    c77 <free+0xcf>
    p->s.size += bp->s.size;
 c57:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c5a:	8b 50 04             	mov    0x4(%eax),%edx
 c5d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c60:	8b 40 04             	mov    0x4(%eax),%eax
 c63:	01 c2                	add    %eax,%edx
 c65:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c68:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c6e:	8b 10                	mov    (%eax),%edx
 c70:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c73:	89 10                	mov    %edx,(%eax)
 c75:	eb 08                	jmp    c7f <free+0xd7>
  } else
    p->s.ptr = bp;
 c77:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c7a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c7d:	89 10                	mov    %edx,(%eax)
  freep = p;
 c7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c82:	a3 e8 12 00 00       	mov    %eax,0x12e8
}
 c87:	c9                   	leave  
 c88:	c3                   	ret    

00000c89 <morecore>:

static Header*
morecore(uint nu)
{
 c89:	55                   	push   %ebp
 c8a:	89 e5                	mov    %esp,%ebp
 c8c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c8f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c96:	77 07                	ja     c9f <morecore+0x16>
    nu = 4096;
 c98:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c9f:	8b 45 08             	mov    0x8(%ebp),%eax
 ca2:	c1 e0 03             	shl    $0x3,%eax
 ca5:	89 04 24             	mov    %eax,(%esp)
 ca8:	e8 4f fc ff ff       	call   8fc <sbrk>
 cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 cb0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 cb4:	75 07                	jne    cbd <morecore+0x34>
    return 0;
 cb6:	b8 00 00 00 00       	mov    $0x0,%eax
 cbb:	eb 22                	jmp    cdf <morecore+0x56>
  hp = (Header*)p;
 cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cc6:	8b 55 08             	mov    0x8(%ebp),%edx
 cc9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ccf:	83 c0 08             	add    $0x8,%eax
 cd2:	89 04 24             	mov    %eax,(%esp)
 cd5:	e8 ce fe ff ff       	call   ba8 <free>
  return freep;
 cda:	a1 e8 12 00 00       	mov    0x12e8,%eax
}
 cdf:	c9                   	leave  
 ce0:	c3                   	ret    

00000ce1 <malloc>:

void*
malloc(uint nbytes)
{
 ce1:	55                   	push   %ebp
 ce2:	89 e5                	mov    %esp,%ebp
 ce4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ce7:	8b 45 08             	mov    0x8(%ebp),%eax
 cea:	83 c0 07             	add    $0x7,%eax
 ced:	c1 e8 03             	shr    $0x3,%eax
 cf0:	83 c0 01             	add    $0x1,%eax
 cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 cf6:	a1 e8 12 00 00       	mov    0x12e8,%eax
 cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cfe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 d02:	75 23                	jne    d27 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 d04:	c7 45 f0 e0 12 00 00 	movl   $0x12e0,-0x10(%ebp)
 d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d0e:	a3 e8 12 00 00       	mov    %eax,0x12e8
 d13:	a1 e8 12 00 00       	mov    0x12e8,%eax
 d18:	a3 e0 12 00 00       	mov    %eax,0x12e0
    base.s.size = 0;
 d1d:	c7 05 e4 12 00 00 00 	movl   $0x0,0x12e4
 d24:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d2a:	8b 00                	mov    (%eax),%eax
 d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d32:	8b 40 04             	mov    0x4(%eax),%eax
 d35:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d38:	72 4d                	jb     d87 <malloc+0xa6>
      if(p->s.size == nunits)
 d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d3d:	8b 40 04             	mov    0x4(%eax),%eax
 d40:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d43:	75 0c                	jne    d51 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d48:	8b 10                	mov    (%eax),%edx
 d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d4d:	89 10                	mov    %edx,(%eax)
 d4f:	eb 26                	jmp    d77 <malloc+0x96>
      else {
        p->s.size -= nunits;
 d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d54:	8b 40 04             	mov    0x4(%eax),%eax
 d57:	89 c2                	mov    %eax,%edx
 d59:	2b 55 ec             	sub    -0x14(%ebp),%edx
 d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d5f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d65:	8b 40 04             	mov    0x4(%eax),%eax
 d68:	c1 e0 03             	shl    $0x3,%eax
 d6b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d71:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d74:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d7a:	a3 e8 12 00 00       	mov    %eax,0x12e8
      return (void*)(p + 1);
 d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d82:	83 c0 08             	add    $0x8,%eax
 d85:	eb 38                	jmp    dbf <malloc+0xde>
    }
    if(p == freep)
 d87:	a1 e8 12 00 00       	mov    0x12e8,%eax
 d8c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d8f:	75 1b                	jne    dac <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 d91:	8b 45 ec             	mov    -0x14(%ebp),%eax
 d94:	89 04 24             	mov    %eax,(%esp)
 d97:	e8 ed fe ff ff       	call   c89 <morecore>
 d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 da3:	75 07                	jne    dac <malloc+0xcb>
        return 0;
 da5:	b8 00 00 00 00       	mov    $0x0,%eax
 daa:	eb 13                	jmp    dbf <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 daf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 db5:	8b 00                	mov    (%eax),%eax
 db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 dba:	e9 70 ff ff ff       	jmp    d2f <malloc+0x4e>
}
 dbf:	c9                   	leave  
 dc0:	c3                   	ret    
