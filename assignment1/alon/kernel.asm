
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 6f 37 10 80       	mov    $0x8010376f,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 18 8a 10 	movl   $0x80108a18,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 fc 52 00 00       	call   8010534a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 eb 10 80 84 	movl   $0x8010eb84,0x8010eb90
80100055:	eb 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 eb 10 80 84 	movl   $0x8010eb84,0x8010eb94
8010005f:	eb 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 eb 10 80    	mov    0x8010eb94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 eb 10 80 	movl   $0x8010eb84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 eb 10 80       	mov    0x8010eb94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 eb 10 80       	mov    %eax,0x8010eb94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 eb 10 80 	cmpl   $0x8010eb84,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801000bd:	e8 a9 52 00 00       	call   8010536b <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 eb 10 80       	mov    0x8010eb94,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100104:	e8 c4 52 00 00       	call   801053cd <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 1f 4f 00 00       	call   80105043 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 eb 10 80 	cmpl   $0x8010eb84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 eb 10 80       	mov    0x8010eb90,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010017c:	e8 4c 52 00 00       	call   801053cd <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 eb 10 80 	cmpl   $0x8010eb84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 1f 8a 10 80 	movl   $0x80108a1f,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 44 29 00 00       	call   80102b1c <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 30 8a 10 80 	movl   $0x80108a30,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 07 29 00 00       	call   80102b1c <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 37 8a 10 80 	movl   $0x80108a37,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 2a 51 00 00       	call   8010536b <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 eb 10 80    	mov    0x8010eb94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 eb 10 80 	movl   $0x8010eb84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 eb 10 80       	mov    0x8010eb94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 eb 10 80       	mov    %eax,0x8010eb94

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 7d 4e 00 00       	call   8010511f <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 1f 51 00 00       	call   801053cd <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 46 04 00 00       	call   801007db <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bc:	e8 aa 4f 00 00       	call   8010536b <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 3e 8a 10 80 	movl   $0x80108a3e,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 e4 03 00 00       	call   801007db <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec 47 8a 10 80 	movl   $0x80108a47,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 12 03 00 00       	call   801007db <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 f3 02 00 00       	call   801007db <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 e5 02 00 00       	call   801007db <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 da 02 00 00       	call   801007db <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100536:	e8 92 4e 00 00       	call   801053cd <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 4e 8a 10 80 	movl   $0x80108a4e,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 5d 8a 10 80 	movl   $0x80108a5d,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 85 4e 00 00       	call   8010541c <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 5f 8a 10 80 	movl   $0x80108a5f,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 33                	jne    8010065b <cgaputc+0x8e>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	e9 a8 00 00 00       	jmp    80100703 <cgaputc+0x136>
  else if(c == BACKSPACE){
8010065b:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100662:	75 13                	jne    80100677 <cgaputc+0xaa>
    if(pos > 0) --pos;
80100664:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100668:	0f 8e 95 00 00 00    	jle    80100703 <cgaputc+0x136>
8010066e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100672:	e9 8c 00 00 00       	jmp    80100703 <cgaputc+0x136>
  }
  else if(c == KEY_LF){
80100677:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
8010067e:	75 2e                	jne    801006ae <cgaputc+0xe1>
    if(pos%80 > 0) --pos;
80100680:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100683:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100688:	89 c8                	mov    %ecx,%eax
8010068a:	f7 ea                	imul   %edx
8010068c:	c1 fa 05             	sar    $0x5,%edx
8010068f:	89 c8                	mov    %ecx,%eax
80100691:	c1 f8 1f             	sar    $0x1f,%eax
80100694:	29 c2                	sub    %eax,%edx
80100696:	89 d0                	mov    %edx,%eax
80100698:	c1 e0 02             	shl    $0x2,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	c1 e0 04             	shl    $0x4,%eax
801006a0:	89 ca                	mov    %ecx,%edx
801006a2:	29 c2                	sub    %eax,%edx
801006a4:	85 d2                	test   %edx,%edx
801006a6:	7e 5b                	jle    80100703 <cgaputc+0x136>
801006a8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ac:	eb 55                	jmp    80100703 <cgaputc+0x136>
  }
  else if(c == KEY_RT){
801006ae:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
801006b5:	75 2f                	jne    801006e6 <cgaputc+0x119>
    if(pos%80 < 79) ++pos;
801006b7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ba:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006bf:	89 c8                	mov    %ecx,%eax
801006c1:	f7 ea                	imul   %edx
801006c3:	c1 fa 05             	sar    $0x5,%edx
801006c6:	89 c8                	mov    %ecx,%eax
801006c8:	c1 f8 1f             	sar    $0x1f,%eax
801006cb:	29 c2                	sub    %eax,%edx
801006cd:	89 d0                	mov    %edx,%eax
801006cf:	c1 e0 02             	shl    $0x2,%eax
801006d2:	01 d0                	add    %edx,%eax
801006d4:	c1 e0 04             	shl    $0x4,%eax
801006d7:	89 ca                	mov    %ecx,%edx
801006d9:	29 c2                	sub    %eax,%edx
801006db:	83 fa 4e             	cmp    $0x4e,%edx
801006de:	7f 23                	jg     80100703 <cgaputc+0x136>
801006e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801006e4:	eb 1d                	jmp    80100703 <cgaputc+0x136>
  }
  else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006e6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006ee:	01 d2                	add    %edx,%edx
801006f0:	01 c2                	add    %eax,%edx
801006f2:	8b 45 08             	mov    0x8(%ebp),%eax
801006f5:	66 25 ff 00          	and    $0xff,%ax
801006f9:	80 cc 07             	or     $0x7,%ah
801006fc:	66 89 02             	mov    %ax,(%edx)
801006ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
80100703:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010070a:	7e 53                	jle    8010075f <cgaputc+0x192>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010070c:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100711:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100717:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010071c:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
80100723:	00 
80100724:	89 54 24 04          	mov    %edx,0x4(%esp)
80100728:	89 04 24             	mov    %eax,(%esp)
8010072b:	e8 5d 4f 00 00       	call   8010568d <memmove>
    pos -= 80;
80100730:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100734:	b8 80 07 00 00       	mov    $0x780,%eax
80100739:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010073c:	01 c0                	add    %eax,%eax
8010073e:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
80100744:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100747:	01 c9                	add    %ecx,%ecx
80100749:	01 ca                	add    %ecx,%edx
8010074b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010074f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100756:	00 
80100757:	89 14 24             	mov    %edx,(%esp)
8010075a:	e8 5b 4e 00 00       	call   801055ba <memset>
  }
  
  outb(CRTPORT, 14);
8010075f:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100766:	00 
80100767:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010076e:	e8 67 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100776:	c1 f8 08             	sar    $0x8,%eax
80100779:	0f b6 c0             	movzbl %al,%eax
8010077c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100780:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100787:	e8 4e fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
8010078c:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100793:	00 
80100794:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010079b:	e8 3a fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
801007a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007a3:	0f b6 c0             	movzbl %al,%eax
801007a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801007aa:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007b1:	e8 24 fb ff ff       	call   801002da <outb>
  if(c != KEY_LF && c != KEY_RT)
801007b6:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
801007bd:	74 1a                	je     801007d9 <cgaputc+0x20c>
801007bf:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
801007c6:	74 11                	je     801007d9 <cgaputc+0x20c>
    crt[pos] = ' ' | 0x0700;
801007c8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007d0:	01 d2                	add    %edx,%edx
801007d2:	01 d0                	add    %edx,%eax
801007d4:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007d9:	c9                   	leave  
801007da:	c3                   	ret    

801007db <consputc>:

void
consputc(int c)
{
801007db:	55                   	push   %ebp
801007dc:	89 e5                	mov    %esp,%ebp
801007de:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
801007e1:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
801007e6:	85 c0                	test   %eax,%eax
801007e8:	74 07                	je     801007f1 <consputc+0x16>
    cli();
801007ea:	e8 09 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
801007ef:	eb fe                	jmp    801007ef <consputc+0x14>
  }

  if(c == BACKSPACE){
801007f1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007f8:	75 26                	jne    80100820 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100801:	e8 77 68 00 00       	call   8010707d <uartputc>
80100806:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010080d:	e8 6b 68 00 00       	call   8010707d <uartputc>
80100812:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100819:	e8 5f 68 00 00       	call   8010707d <uartputc>
8010081e:	eb 0b                	jmp    8010082b <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
80100820:	8b 45 08             	mov    0x8(%ebp),%eax
80100823:	89 04 24             	mov    %eax,(%esp)
80100826:	e8 52 68 00 00       	call   8010707d <uartputc>
  cgaputc(c);
8010082b:	8b 45 08             	mov    0x8(%ebp),%eax
8010082e:	89 04 24             	mov    %eax,(%esp)
80100831:	e8 97 fd ff ff       	call   801005cd <cgaputc>
}
80100836:	c9                   	leave  
80100837:	c3                   	ret    

80100838 <shiftRightBuf>:

#define C(x)  ((x)-'@')  // Control-x

void
shiftRightBuf(int e, int k)
{
80100838:	55                   	push   %ebp
80100839:	89 e5                	mov    %esp,%ebp
8010083b:	83 ec 10             	sub    $0x10,%esp
  int i = e+1;
8010083e:	8b 45 08             	mov    0x8(%ebp),%eax
80100841:	83 c0 01             	add    $0x1,%eax
80100844:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
80100847:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < k ;i--,j++){
8010084e:	eb 21                	jmp    80100871 <shiftRightBuf+0x39>
    input.buf[i] = input.buf[i-1];
80100850:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100853:	83 e8 01             	sub    $0x1,%eax
80100856:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
8010085d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100860:	81 c2 d0 ed 10 80    	add    $0x8010edd0,%edx
80100866:	88 42 04             	mov    %al,0x4(%edx)
void
shiftRightBuf(int e, int k)
{
  int i = e+1;
  int j=0;
  for(;j < k ;i--,j++){
80100869:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010086d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80100871:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100874:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100877:	7c d7                	jl     80100850 <shiftRightBuf+0x18>
    input.buf[i] = input.buf[i-1];
  }
}
80100879:	c9                   	leave  
8010087a:	c3                   	ret    

8010087b <shiftLeftBuf>:

void
shiftLeftBuf(int e, int k)
{
8010087b:	55                   	push   %ebp
8010087c:	89 e5                	mov    %esp,%ebp
8010087e:	83 ec 10             	sub    $0x10,%esp
  int i = e+k;
80100881:	8b 45 0c             	mov    0xc(%ebp),%eax
80100884:	8b 55 08             	mov    0x8(%ebp),%edx
80100887:	01 d0                	add    %edx,%eax
80100889:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
8010088c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < (-1)*k ;i++,j++){
80100893:	eb 21                	jmp    801008b6 <shiftLeftBuf+0x3b>
    input.buf[i] = input.buf[i+1];
80100895:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100898:	83 c0 01             	add    $0x1,%eax
8010089b:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
801008a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801008a5:	81 c2 d0 ed 10 80    	add    $0x8010edd0,%edx
801008ab:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(int e, int k)
{
  int i = e+k;
  int j=0;
  for(;j < (-1)*k ;i++,j++){
801008ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801008b2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801008b9:	f7 d8                	neg    %eax
801008bb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801008be:	7f d5                	jg     80100895 <shiftLeftBuf+0x1a>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
801008c0:	8b 45 08             	mov    0x8(%ebp),%eax
801008c3:	05 d0 ed 10 80       	add    $0x8010edd0,%eax
801008c8:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
801008cc:	c9                   	leave  
801008cd:	c3                   	ret    

801008ce <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801008ce:	55                   	push   %ebp
801008cf:	89 e5                	mov    %esp,%ebp
801008d1:	83 ec 38             	sub    $0x38,%esp
  int c;

  acquire(&input.lock);
801008d4:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
801008db:	e8 8b 4a 00 00       	call   8010536b <acquire>
  while((c = getc()) >= 0){
801008e0:	e9 89 03 00 00       	jmp    80100c6e <consoleintr+0x3a0>
    switch(c){
801008e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801008e8:	83 f8 15             	cmp    $0x15,%eax
801008eb:	74 59                	je     80100946 <consoleintr+0x78>
801008ed:	83 f8 15             	cmp    $0x15,%eax
801008f0:	7f 0f                	jg     80100901 <consoleintr+0x33>
801008f2:	83 f8 08             	cmp    $0x8,%eax
801008f5:	74 7e                	je     80100975 <consoleintr+0xa7>
801008f7:	83 f8 10             	cmp    $0x10,%eax
801008fa:	74 25                	je     80100921 <consoleintr+0x53>
801008fc:	e9 ca 01 00 00       	jmp    80100acb <consoleintr+0x1fd>
80100901:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100906:	0f 84 40 01 00 00    	je     80100a4c <consoleintr+0x17e>
8010090c:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100911:	0f 84 78 01 00 00    	je     80100a8f <consoleintr+0x1c1>
80100917:	83 f8 7f             	cmp    $0x7f,%eax
8010091a:	74 59                	je     80100975 <consoleintr+0xa7>
8010091c:	e9 aa 01 00 00       	jmp    80100acb <consoleintr+0x1fd>
    case C('P'):  // Process listing.
      procdump();
80100921:	e8 9f 48 00 00       	call   801051c5 <procdump>
      break;
80100926:	e9 43 03 00 00       	jmp    80100c6e <consoleintr+0x3a0>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010092b:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100930:	83 e8 01             	sub    $0x1,%eax
80100933:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
        consputc(BACKSPACE);
80100938:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010093f:	e8 97 fe ff ff       	call   801007db <consputc>
80100944:	eb 01                	jmp    80100947 <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100946:	90                   	nop
80100947:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
8010094d:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
80100952:	39 c2                	cmp    %eax,%edx
80100954:	0f 84 07 03 00 00    	je     80100c61 <consoleintr+0x393>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010095a:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
8010095f:	83 e8 01             	sub    $0x1,%eax
80100962:	83 e0 7f             	and    $0x7f,%eax
80100965:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010096c:	3c 0a                	cmp    $0xa,%al
8010096e:	75 bb                	jne    8010092b <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100970:	e9 ec 02 00 00       	jmp    80100c61 <consoleintr+0x393>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100975:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
8010097b:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
80100980:	39 c2                	cmp    %eax,%edx
80100982:	0f 84 dc 02 00 00    	je     80100c64 <consoleintr+0x396>
	if(input.a<0)
80100988:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
8010098d:	85 c0                	test   %eax,%eax
8010098f:	0f 89 99 00 00 00    	jns    80100a2e <consoleintr+0x160>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
80100995:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
8010099a:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
801009a0:	83 ea 01             	sub    $0x1,%edx
801009a3:	83 e2 7f             	and    $0x7f,%edx
801009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801009aa:	89 14 24             	mov    %edx,(%esp)
801009ad:	e8 c9 fe ff ff       	call   8010087b <shiftLeftBuf>
	    int i = input.e+input.a-1;
801009b2:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
801009b8:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
801009bd:	01 d0                	add    %edx,%eax
801009bf:	83 e8 01             	sub    $0x1,%eax
801009c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);
801009c5:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009cc:	e8 0a fe ff ff       	call   801007db <consputc>
	    for(;i<input.e;i++){
801009d1:	eb 1b                	jmp    801009ee <consoleintr+0x120>
	      consputc(input.buf[i]);
801009d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801009d6:	05 d0 ed 10 80       	add    $0x8010edd0,%eax
801009db:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801009df:	0f be c0             	movsbl %al,%eax
801009e2:	89 04 24             	mov    %eax,(%esp)
801009e5:	e8 f1 fd ff ff       	call   801007db <consputc>
	if(input.a<0)
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
	    int i = input.e+input.a-1;
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
801009ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801009f1:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
801009f6:	39 c2                	cmp    %eax,%edx
801009f8:	72 d9                	jb     801009d3 <consoleintr+0x105>
	      consputc(input.buf[i]);
	    }
	    i = input.e+input.a;
801009fa:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100a00:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100a05:	01 d0                	add    %edx,%eax
80100a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){
80100a0a:	eb 10                	jmp    80100a1c <consoleintr+0x14e>
	      consputc(KEY_LF);
80100a0c:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a13:	e8 c3 fd ff ff       	call   801007db <consputc>
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
	      consputc(input.buf[i]);
	    }
	    i = input.e+input.a;
	    for(;i<input.e+1;i++){
80100a18:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a1f:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100a25:	83 c2 01             	add    $0x1,%edx
80100a28:	39 d0                	cmp    %edx,%eax
80100a2a:	72 e0                	jb     80100a0c <consoleintr+0x13e>
80100a2c:	eb 0c                	jmp    80100a3a <consoleintr+0x16c>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);
80100a2e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a35:	e8 a1 fd ff ff       	call   801007db <consputc>
	}
	input.e--;
80100a3a:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100a3f:	83 e8 01             	sub    $0x1,%eax
80100a42:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
      }
      break;
80100a47:	e9 18 02 00 00       	jmp    80100c64 <consoleintr+0x396>
    case KEY_LF: //LEFT KEY
     if(input.e % INPUT_BUF > 0 && input.e+input.a>0)
80100a4c:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100a51:	83 e0 7f             	and    $0x7f,%eax
80100a54:	85 c0                	test   %eax,%eax
80100a56:	0f 84 0b 02 00 00    	je     80100c67 <consoleintr+0x399>
80100a5c:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100a62:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100a67:	01 d0                	add    %edx,%eax
80100a69:	85 c0                	test   %eax,%eax
80100a6b:	0f 84 f6 01 00 00    	je     80100c67 <consoleintr+0x399>
      {
        input.a--;
80100a71:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100a76:	83 e8 01             	sub    $0x1,%eax
80100a79:	a3 60 ee 10 80       	mov    %eax,0x8010ee60
        consputc(KEY_LF);
80100a7e:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a85:	e8 51 fd ff ff       	call   801007db <consputc>
      }
      break;
80100a8a:	e9 d8 01 00 00       	jmp    80100c67 <consoleintr+0x399>
    case KEY_RT: //RIGHT KEY
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
80100a8f:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100a94:	85 c0                	test   %eax,%eax
80100a96:	0f 89 ce 01 00 00    	jns    80100c6a <consoleintr+0x39c>
80100a9c:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100aa1:	83 e0 7f             	and    $0x7f,%eax
80100aa4:	83 f8 7e             	cmp    $0x7e,%eax
80100aa7:	0f 87 bd 01 00 00    	ja     80100c6a <consoleintr+0x39c>
      {
        input.a++;
80100aad:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100ab2:	83 c0 01             	add    $0x1,%eax
80100ab5:	a3 60 ee 10 80       	mov    %eax,0x8010ee60
        consputc(KEY_RT);
80100aba:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100ac1:	e8 15 fd ff ff       	call   801007db <consputc>
      }
      break;
80100ac6:	e9 9f 01 00 00       	jmp    80100c6a <consoleintr+0x39c>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100acb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100acf:	0f 84 98 01 00 00    	je     80100c6d <consoleintr+0x39f>
80100ad5:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100adb:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
80100ae0:	89 d1                	mov    %edx,%ecx
80100ae2:	29 c1                	sub    %eax,%ecx
80100ae4:	89 c8                	mov    %ecx,%eax
80100ae6:	83 f8 7f             	cmp    $0x7f,%eax
80100ae9:	0f 87 7e 01 00 00    	ja     80100c6d <consoleintr+0x39f>
      {
	c = (c == '\r') ? '\n' : c;
80100aef:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100af3:	74 05                	je     80100afa <consoleintr+0x22c>
80100af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100af8:	eb 05                	jmp    80100aff <consoleintr+0x231>
80100afa:	b8 0a 00 00 00       	mov    $0xa,%eax
80100aff:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a < 0)
80100b02:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100b06:	0f 84 ef 00 00 00    	je     80100bfb <consoleintr+0x32d>
80100b0c:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100b11:	85 c0                	test   %eax,%eax
80100b13:	0f 89 e2 00 00 00    	jns    80100bfb <consoleintr+0x32d>
	{
	    int j = (INPUT_BUF-(input.e-input.w));
80100b19:	8b 15 58 ee 10 80    	mov    0x8010ee58,%edx
80100b1f:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100b24:	89 d1                	mov    %edx,%ecx
80100b26:	29 c1                	sub    %eax,%ecx
80100b28:	89 c8                	mov    %ecx,%eax
80100b2a:	83 e8 80             	sub    $0xffffff80,%eax
80100b2d:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    int k = ((-1)*input.a > j) ? j : (-1)*input.a;
80100b30:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100b35:	89 c2                	mov    %eax,%edx
80100b37:	f7 da                	neg    %edx
80100b39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b3c:	39 c2                	cmp    %eax,%edx
80100b3e:	0f 4e c2             	cmovle %edx,%eax
80100b41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
80100b44:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100b49:	83 e8 01             	sub    $0x1,%eax
80100b4c:	89 c2                	mov    %eax,%edx
80100b4e:	83 e2 7f             	and    $0x7f,%edx
80100b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b58:	89 14 24             	mov    %edx,(%esp)
80100b5b:	e8 d8 fc ff ff       	call   80100838 <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;
80100b60:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100b66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b69:	89 d1                	mov    %edx,%ecx
80100b6b:	29 c1                	sub    %eax,%ecx
80100b6d:	89 c8                	mov    %ecx,%eax
80100b6f:	89 c2                	mov    %eax,%edx
80100b71:	83 e2 7f             	and    $0x7f,%edx
80100b74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b77:	88 82 d4 ed 10 80    	mov    %al,-0x7fef122c(%edx)
	    int i = input.e-k;
80100b7d:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b86:	89 d1                	mov    %edx,%ecx
80100b88:	29 c1                	sub    %eax,%ecx
80100b8a:	89 c8                	mov    %ecx,%eax
80100b8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    
	    for(;i<input.e+1;i++){
80100b8f:	eb 1b                	jmp    80100bac <consoleintr+0x2de>
	      consputc(input.buf[i]);
80100b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b94:	05 d0 ed 10 80       	add    $0x8010edd0,%eax
80100b99:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80100b9d:	0f be c0             	movsbl %al,%eax
80100ba0:	89 04 24             	mov    %eax,(%esp)
80100ba3:	e8 33 fc ff ff       	call   801007db <consputc>
	    int k = ((-1)*input.a > j) ? j : (-1)*input.a;
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
	    input.buf[(input.e-k) % INPUT_BUF] = c;
	    int i = input.e-k;
	    
	    for(;i<input.e+1;i++){
80100ba8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100baf:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100bb5:	83 c2 01             	add    $0x1,%edx
80100bb8:	39 d0                	cmp    %edx,%eax
80100bba:	72 d5                	jb     80100b91 <consoleintr+0x2c3>
	      consputc(input.buf[i]);
	    }
	    i = input.e-k;
80100bbc:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100bc5:	89 d1                	mov    %edx,%ecx
80100bc7:	29 c1                	sub    %eax,%ecx
80100bc9:	89 c8                	mov    %ecx,%eax
80100bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++){
80100bce:	eb 10                	jmp    80100be0 <consoleintr+0x312>
	      consputc(KEY_LF);
80100bd0:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100bd7:	e8 ff fb ff ff       	call   801007db <consputc>
	    
	    for(;i<input.e+1;i++){
	      consputc(input.buf[i]);
	    }
	    i = input.e-k;
	    for(;i<input.e;i++){
80100bdc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100be0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100be3:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100be8:	39 c2                	cmp    %eax,%edx
80100bea:	72 e4                	jb     80100bd0 <consoleintr+0x302>
	      consputc(KEY_LF);
	    }
	    input.e++;
80100bec:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100bf1:	83 c0 01             	add    $0x1,%eax
80100bf4:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a < 0)
	{
80100bf9:	eb 26                	jmp    80100c21 <consoleintr+0x353>
	      consputc(KEY_LF);
	    }
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100bfb:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100c00:	89 c1                	mov    %eax,%ecx
80100c02:	83 e1 7f             	and    $0x7f,%ecx
80100c05:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c08:	88 91 d4 ed 10 80    	mov    %dl,-0x7fef122c(%ecx)
80100c0e:	83 c0 01             	add    $0x1,%eax
80100c11:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
          consputc(c);
80100c16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100c19:	89 04 24             	mov    %eax,(%esp)
80100c1c:	e8 ba fb ff ff       	call   801007db <consputc>
	}
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100c21:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100c25:	74 18                	je     80100c3f <consoleintr+0x371>
80100c27:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100c2b:	74 12                	je     80100c3f <consoleintr+0x371>
80100c2d:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100c32:	8b 15 54 ee 10 80    	mov    0x8010ee54,%edx
80100c38:	83 ea 80             	sub    $0xffffff80,%edx
80100c3b:	39 d0                	cmp    %edx,%eax
80100c3d:	75 2e                	jne    80100c6d <consoleintr+0x39f>
          input.a = 0;
80100c3f:	c7 05 60 ee 10 80 00 	movl   $0x0,0x8010ee60
80100c46:	00 00 00 
	  input.w = input.e;
80100c49:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100c4e:	a3 58 ee 10 80       	mov    %eax,0x8010ee58
          wakeup(&input.r);
80100c53:	c7 04 24 54 ee 10 80 	movl   $0x8010ee54,(%esp)
80100c5a:	e8 c0 44 00 00       	call   8010511f <wakeup>
        }
      }
      break;
80100c5f:	eb 0c                	jmp    80100c6d <consoleintr+0x39f>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c61:	90                   	nop
80100c62:	eb 0a                	jmp    80100c6e <consoleintr+0x3a0>
	{
	  consputc(BACKSPACE);
	}
	input.e--;
      }
      break;
80100c64:	90                   	nop
80100c65:	eb 07                	jmp    80100c6e <consoleintr+0x3a0>
     if(input.e % INPUT_BUF > 0 && input.e+input.a>0)
      {
        input.a--;
        consputc(KEY_LF);
      }
      break;
80100c67:	90                   	nop
80100c68:	eb 04                	jmp    80100c6e <consoleintr+0x3a0>
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
      {
        input.a++;
        consputc(KEY_RT);
      }
      break;
80100c6a:	90                   	nop
80100c6b:	eb 01                	jmp    80100c6e <consoleintr+0x3a0>
          input.a = 0;
	  input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100c6d:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100c71:	ff d0                	call   *%eax
80100c73:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100c76:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100c7a:	0f 89 65 fc ff ff    	jns    801008e5 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100c80:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100c87:	e8 41 47 00 00       	call   801053cd <release>
}
80100c8c:	c9                   	leave  
80100c8d:	c3                   	ret    

80100c8e <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c8e:	55                   	push   %ebp
80100c8f:	89 e5                	mov    %esp,%ebp
80100c91:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c94:	8b 45 08             	mov    0x8(%ebp),%eax
80100c97:	89 04 24             	mov    %eax,(%esp)
80100c9a:	e8 7f 10 00 00       	call   80101d1e <iunlock>
  target = n;
80100c9f:	8b 45 10             	mov    0x10(%ebp),%eax
80100ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100ca5:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100cac:	e8 ba 46 00 00       	call   8010536b <acquire>
  while(n > 0){
80100cb1:	e9 a8 00 00 00       	jmp    80100d5e <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100cb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cbc:	8b 40 24             	mov    0x24(%eax),%eax
80100cbf:	85 c0                	test   %eax,%eax
80100cc1:	74 21                	je     80100ce4 <consoleread+0x56>
        release(&input.lock);
80100cc3:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100cca:	e8 fe 46 00 00       	call   801053cd <release>
        ilock(ip);
80100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80100cd2:	89 04 24             	mov    %eax,(%esp)
80100cd5:	e8 f6 0e 00 00       	call   80101bd0 <ilock>
        return -1;
80100cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cdf:	e9 a9 00 00 00       	jmp    80100d8d <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100ce4:	c7 44 24 04 a0 ed 10 	movl   $0x8010eda0,0x4(%esp)
80100ceb:	80 
80100cec:	c7 04 24 54 ee 10 80 	movl   $0x8010ee54,(%esp)
80100cf3:	e8 4b 43 00 00       	call   80105043 <sleep>
80100cf8:	eb 01                	jmp    80100cfb <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100cfa:	90                   	nop
80100cfb:	8b 15 54 ee 10 80    	mov    0x8010ee54,%edx
80100d01:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
80100d06:	39 c2                	cmp    %eax,%edx
80100d08:	74 ac                	je     80100cb6 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100d0a:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
80100d0f:	89 c2                	mov    %eax,%edx
80100d11:	83 e2 7f             	and    $0x7f,%edx
80100d14:	0f b6 92 d4 ed 10 80 	movzbl -0x7fef122c(%edx),%edx
80100d1b:	0f be d2             	movsbl %dl,%edx
80100d1e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100d21:	83 c0 01             	add    $0x1,%eax
80100d24:	a3 54 ee 10 80       	mov    %eax,0x8010ee54
    if(c == C('D')){  // EOF
80100d29:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d2d:	75 17                	jne    80100d46 <consoleread+0xb8>
      if(n < target){
80100d2f:	8b 45 10             	mov    0x10(%ebp),%eax
80100d32:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100d35:	73 2f                	jae    80100d66 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100d37:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
80100d3c:	83 e8 01             	sub    $0x1,%eax
80100d3f:	a3 54 ee 10 80       	mov    %eax,0x8010ee54
      }
      break;
80100d44:	eb 20                	jmp    80100d66 <consoleread+0xd8>
    }
    *dst++ = c;
80100d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d49:	89 c2                	mov    %eax,%edx
80100d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4e:	88 10                	mov    %dl,(%eax)
80100d50:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100d54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100d58:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d5c:	74 0b                	je     80100d69 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100d5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100d62:	7f 96                	jg     80100cfa <consoleread+0x6c>
80100d64:	eb 04                	jmp    80100d6a <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100d66:	90                   	nop
80100d67:	eb 01                	jmp    80100d6a <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100d69:	90                   	nop
  }
  release(&input.lock);
80100d6a:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100d71:	e8 57 46 00 00       	call   801053cd <release>
  ilock(ip);
80100d76:	8b 45 08             	mov    0x8(%ebp),%eax
80100d79:	89 04 24             	mov    %eax,(%esp)
80100d7c:	e8 4f 0e 00 00       	call   80101bd0 <ilock>

  return target - n;
80100d81:	8b 45 10             	mov    0x10(%ebp),%eax
80100d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d87:	89 d1                	mov    %edx,%ecx
80100d89:	29 c1                	sub    %eax,%ecx
80100d8b:	89 c8                	mov    %ecx,%eax
}
80100d8d:	c9                   	leave  
80100d8e:	c3                   	ret    

80100d8f <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d8f:	55                   	push   %ebp
80100d90:	89 e5                	mov    %esp,%ebp
80100d92:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d95:	8b 45 08             	mov    0x8(%ebp),%eax
80100d98:	89 04 24             	mov    %eax,(%esp)
80100d9b:	e8 7e 0f 00 00       	call   80101d1e <iunlock>
  acquire(&cons.lock);
80100da0:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100da7:	e8 bf 45 00 00       	call   8010536b <acquire>
  for(i = 0; i < n; i++)
80100dac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100db3:	eb 1d                	jmp    80100dd2 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100db8:	03 45 0c             	add    0xc(%ebp),%eax
80100dbb:	0f b6 00             	movzbl (%eax),%eax
80100dbe:	0f be c0             	movsbl %al,%eax
80100dc1:	25 ff 00 00 00       	and    $0xff,%eax
80100dc6:	89 04 24             	mov    %eax,(%esp)
80100dc9:	e8 0d fa ff ff       	call   801007db <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100dce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100dd5:	3b 45 10             	cmp    0x10(%ebp),%eax
80100dd8:	7c db                	jl     80100db5 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100dda:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100de1:	e8 e7 45 00 00       	call   801053cd <release>
  ilock(ip);
80100de6:	8b 45 08             	mov    0x8(%ebp),%eax
80100de9:	89 04 24             	mov    %eax,(%esp)
80100dec:	e8 df 0d 00 00       	call   80101bd0 <ilock>

  return n;
80100df1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100df4:	c9                   	leave  
80100df5:	c3                   	ret    

80100df6 <consoleinit>:

void
consoleinit(void)
{
80100df6:	55                   	push   %ebp
80100df7:	89 e5                	mov    %esp,%ebp
80100df9:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100dfc:	c7 44 24 04 63 8a 10 	movl   $0x80108a63,0x4(%esp)
80100e03:	80 
80100e04:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100e0b:	e8 3a 45 00 00       	call   8010534a <initlock>
  initlock(&input.lock, "input");
80100e10:	c7 44 24 04 6b 8a 10 	movl   $0x80108a6b,0x4(%esp)
80100e17:	80 
80100e18:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100e1f:	e8 26 45 00 00       	call   8010534a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100e24:	c7 05 2c f8 10 80 8f 	movl   $0x80100d8f,0x8010f82c
80100e2b:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100e2e:	c7 05 28 f8 10 80 8e 	movl   $0x80100c8e,0x8010f828
80100e35:	0c 10 80 
  cons.locking = 1;
80100e38:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100e3f:	00 00 00 

  picenable(IRQ_KBD);
80100e42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e49:	e8 db 2f 00 00       	call   80103e29 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100e4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100e55:	00 
80100e56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e5d:	e8 7c 1e 00 00       	call   80102cde <ioapicenable>
}
80100e62:	c9                   	leave  
80100e63:	c3                   	ret    

80100e64 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100e64:	55                   	push   %ebp
80100e65:	89 e5                	mov    %esp,%ebp
80100e67:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80100e70:	89 04 24             	mov    %eax,(%esp)
80100e73:	e8 fa 18 00 00       	call   80102772 <namei>
80100e78:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100e7b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e7f:	75 0a                	jne    80100e8b <exec+0x27>
    return -1;
80100e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e86:	e9 da 03 00 00       	jmp    80101265 <exec+0x401>
  ilock(ip);
80100e8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e8e:	89 04 24             	mov    %eax,(%esp)
80100e91:	e8 3a 0d 00 00       	call   80101bd0 <ilock>
  pgdir = 0;
80100e96:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e9d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100ea4:	00 
80100ea5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100eac:	00 
80100ead:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100eb7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100eba:	89 04 24             	mov    %eax,(%esp)
80100ebd:	e8 04 12 00 00       	call   801020c6 <readi>
80100ec2:	83 f8 33             	cmp    $0x33,%eax
80100ec5:	0f 86 54 03 00 00    	jbe    8010121f <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100ecb:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ed1:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100ed6:	0f 85 46 03 00 00    	jne    80101222 <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100edc:	c7 04 24 67 2e 10 80 	movl   $0x80102e67,(%esp)
80100ee3:	e8 d9 72 00 00       	call   801081c1 <setupkvm>
80100ee8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100eeb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100eef:	0f 84 30 03 00 00    	je     80101225 <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100ef5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100efc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100f03:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100f09:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f0c:	e9 c5 00 00 00       	jmp    80100fd6 <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100f11:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f14:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100f1b:	00 
80100f1c:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f20:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100f26:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f2d:	89 04 24             	mov    %eax,(%esp)
80100f30:	e8 91 11 00 00       	call   801020c6 <readi>
80100f35:	83 f8 20             	cmp    $0x20,%eax
80100f38:	0f 85 ea 02 00 00    	jne    80101228 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100f3e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100f44:	83 f8 01             	cmp    $0x1,%eax
80100f47:	75 7f                	jne    80100fc8 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100f49:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100f4f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100f55:	39 c2                	cmp    %eax,%edx
80100f57:	0f 82 ce 02 00 00    	jb     8010122b <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f5d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100f63:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100f69:	01 d0                	add    %edx,%eax
80100f6b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f72:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f79:	89 04 24             	mov    %eax,(%esp)
80100f7c:	e8 12 76 00 00       	call   80108593 <allocuvm>
80100f81:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f84:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f88:	0f 84 a0 02 00 00    	je     8010122e <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f8e:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f94:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f9a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100fa0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100fa4:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100fa8:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100fab:	89 54 24 08          	mov    %edx,0x8(%esp)
80100faf:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fb6:	89 04 24             	mov    %eax,(%esp)
80100fb9:	e8 e6 74 00 00       	call   801084a4 <loaduvm>
80100fbe:	85 c0                	test   %eax,%eax
80100fc0:	0f 88 6b 02 00 00    	js     80101231 <exec+0x3cd>
80100fc6:	eb 01                	jmp    80100fc9 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100fc8:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100fc9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100fcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100fd0:	83 c0 20             	add    $0x20,%eax
80100fd3:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100fd6:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100fdd:	0f b7 c0             	movzwl %ax,%eax
80100fe0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100fe3:	0f 8f 28 ff ff ff    	jg     80100f11 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100fe9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fec:	89 04 24             	mov    %eax,(%esp)
80100fef:	e8 60 0e 00 00       	call   80101e54 <iunlockput>
  ip = 0;
80100ff4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100ffb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ffe:	05 ff 0f 00 00       	add    $0xfff,%eax
80101003:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80101008:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
8010100b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010100e:	05 00 20 00 00       	add    $0x2000,%eax
80101013:	89 44 24 08          	mov    %eax,0x8(%esp)
80101017:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010101a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010101e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101021:	89 04 24             	mov    %eax,(%esp)
80101024:	e8 6a 75 00 00       	call   80108593 <allocuvm>
80101029:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010102c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101030:	0f 84 fe 01 00 00    	je     80101234 <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101036:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101039:	2d 00 20 00 00       	sub    $0x2000,%eax
8010103e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101042:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101045:	89 04 24             	mov    %eax,(%esp)
80101048:	e8 6a 77 00 00       	call   801087b7 <clearpteu>
  sp = sz;
8010104d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101050:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101053:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010105a:	e9 81 00 00 00       	jmp    801010e0 <exec+0x27c>
    if(argc >= MAXARG)
8010105f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80101063:	0f 87 ce 01 00 00    	ja     80101237 <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101069:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010106c:	c1 e0 02             	shl    $0x2,%eax
8010106f:	03 45 0c             	add    0xc(%ebp),%eax
80101072:	8b 00                	mov    (%eax),%eax
80101074:	89 04 24             	mov    %eax,(%esp)
80101077:	e8 bc 47 00 00       	call   80105838 <strlen>
8010107c:	f7 d0                	not    %eax
8010107e:	03 45 dc             	add    -0x24(%ebp),%eax
80101081:	83 e0 fc             	and    $0xfffffffc,%eax
80101084:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101087:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108a:	c1 e0 02             	shl    $0x2,%eax
8010108d:	03 45 0c             	add    0xc(%ebp),%eax
80101090:	8b 00                	mov    (%eax),%eax
80101092:	89 04 24             	mov    %eax,(%esp)
80101095:	e8 9e 47 00 00       	call   80105838 <strlen>
8010109a:	83 c0 01             	add    $0x1,%eax
8010109d:	89 c2                	mov    %eax,%edx
8010109f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010a2:	c1 e0 02             	shl    $0x2,%eax
801010a5:	03 45 0c             	add    0xc(%ebp),%eax
801010a8:	8b 00                	mov    (%eax),%eax
801010aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
801010ae:	89 44 24 08          	mov    %eax,0x8(%esp)
801010b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801010b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010bc:	89 04 24             	mov    %eax,(%esp)
801010bf:	e8 a7 78 00 00       	call   8010896b <copyout>
801010c4:	85 c0                	test   %eax,%eax
801010c6:	0f 88 6e 01 00 00    	js     8010123a <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
801010cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010cf:	8d 50 03             	lea    0x3(%eax),%edx
801010d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010d5:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801010dc:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010e3:	c1 e0 02             	shl    $0x2,%eax
801010e6:	03 45 0c             	add    0xc(%ebp),%eax
801010e9:	8b 00                	mov    (%eax),%eax
801010eb:	85 c0                	test   %eax,%eax
801010ed:	0f 85 6c ff ff ff    	jne    8010105f <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010f6:	83 c0 03             	add    $0x3,%eax
801010f9:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80101100:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80101104:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
8010110b:	ff ff ff 
  ustack[1] = argc;
8010110e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101111:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010111a:	83 c0 01             	add    $0x1,%eax
8010111d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101124:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101127:	29 d0                	sub    %edx,%eax
80101129:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
8010112f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101132:	83 c0 04             	add    $0x4,%eax
80101135:	c1 e0 02             	shl    $0x2,%eax
80101138:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
8010113b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010113e:	83 c0 04             	add    $0x4,%eax
80101141:	c1 e0 02             	shl    $0x2,%eax
80101144:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101148:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010114e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101152:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101155:	89 44 24 04          	mov    %eax,0x4(%esp)
80101159:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010115c:	89 04 24             	mov    %eax,(%esp)
8010115f:	e8 07 78 00 00       	call   8010896b <copyout>
80101164:	85 c0                	test   %eax,%eax
80101166:	0f 88 d1 00 00 00    	js     8010123d <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101175:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101178:	eb 17                	jmp    80101191 <exec+0x32d>
    if(*s == '/')
8010117a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010117d:	0f b6 00             	movzbl (%eax),%eax
80101180:	3c 2f                	cmp    $0x2f,%al
80101182:	75 09                	jne    8010118d <exec+0x329>
      last = s+1;
80101184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101187:	83 c0 01             	add    $0x1,%eax
8010118a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010118d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101194:	0f b6 00             	movzbl (%eax),%eax
80101197:	84 c0                	test   %al,%al
80101199:	75 df                	jne    8010117a <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
8010119b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011a1:	8d 50 6c             	lea    0x6c(%eax),%edx
801011a4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801011ab:	00 
801011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011af:	89 44 24 04          	mov    %eax,0x4(%esp)
801011b3:	89 14 24             	mov    %edx,(%esp)
801011b6:	e8 2f 46 00 00       	call   801057ea <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801011bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011c1:	8b 40 04             	mov    0x4(%eax),%eax
801011c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
801011c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801011d0:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801011d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801011dc:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801011de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e4:	8b 40 18             	mov    0x18(%eax),%eax
801011e7:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801011ed:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011f6:	8b 40 18             	mov    0x18(%eax),%eax
801011f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011fc:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801011ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101205:	89 04 24             	mov    %eax,(%esp)
80101208:	e8 a5 70 00 00       	call   801082b2 <switchuvm>
  freevm(oldpgdir);
8010120d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101210:	89 04 24             	mov    %eax,(%esp)
80101213:	e8 11 75 00 00       	call   80108729 <freevm>
  return 0;
80101218:	b8 00 00 00 00       	mov    $0x0,%eax
8010121d:	eb 46                	jmp    80101265 <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010121f:	90                   	nop
80101220:	eb 1c                	jmp    8010123e <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101222:	90                   	nop
80101223:	eb 19                	jmp    8010123e <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101225:	90                   	nop
80101226:	eb 16                	jmp    8010123e <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101228:	90                   	nop
80101229:	eb 13                	jmp    8010123e <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010122b:	90                   	nop
8010122c:	eb 10                	jmp    8010123e <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
8010122e:	90                   	nop
8010122f:	eb 0d                	jmp    8010123e <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101231:	90                   	nop
80101232:	eb 0a                	jmp    8010123e <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101234:	90                   	nop
80101235:	eb 07                	jmp    8010123e <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101237:	90                   	nop
80101238:	eb 04                	jmp    8010123e <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
8010123a:	90                   	nop
8010123b:	eb 01                	jmp    8010123e <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
8010123d:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010123e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101242:	74 0b                	je     8010124f <exec+0x3eb>
    freevm(pgdir);
80101244:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101247:	89 04 24             	mov    %eax,(%esp)
8010124a:	e8 da 74 00 00       	call   80108729 <freevm>
  if(ip)
8010124f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101253:	74 0b                	je     80101260 <exec+0x3fc>
    iunlockput(ip);
80101255:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101258:	89 04 24             	mov    %eax,(%esp)
8010125b:	e8 f4 0b 00 00       	call   80101e54 <iunlockput>
  return -1;
80101260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101265:	c9                   	leave  
80101266:	c3                   	ret    
	...

80101268 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101268:	55                   	push   %ebp
80101269:	89 e5                	mov    %esp,%ebp
8010126b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010126e:	c7 44 24 04 71 8a 10 	movl   $0x80108a71,0x4(%esp)
80101275:	80 
80101276:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
8010127d:	e8 c8 40 00 00       	call   8010534a <initlock>
}
80101282:	c9                   	leave  
80101283:	c3                   	ret    

80101284 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101284:	55                   	push   %ebp
80101285:	89 e5                	mov    %esp,%ebp
80101287:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010128a:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
80101291:	e8 d5 40 00 00       	call   8010536b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101296:	c7 45 f4 b4 ee 10 80 	movl   $0x8010eeb4,-0xc(%ebp)
8010129d:	eb 29                	jmp    801012c8 <filealloc+0x44>
    if(f->ref == 0){
8010129f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012a2:	8b 40 04             	mov    0x4(%eax),%eax
801012a5:	85 c0                	test   %eax,%eax
801012a7:	75 1b                	jne    801012c4 <filealloc+0x40>
      f->ref = 1;
801012a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ac:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801012b3:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
801012ba:	e8 0e 41 00 00       	call   801053cd <release>
      return f;
801012bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c2:	eb 1e                	jmp    801012e2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012c4:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801012c8:	81 7d f4 14 f8 10 80 	cmpl   $0x8010f814,-0xc(%ebp)
801012cf:	72 ce                	jb     8010129f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801012d1:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
801012d8:	e8 f0 40 00 00       	call   801053cd <release>
  return 0;
801012dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801012e2:	c9                   	leave  
801012e3:	c3                   	ret    

801012e4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801012e4:	55                   	push   %ebp
801012e5:	89 e5                	mov    %esp,%ebp
801012e7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801012ea:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
801012f1:	e8 75 40 00 00       	call   8010536b <acquire>
  if(f->ref < 1)
801012f6:	8b 45 08             	mov    0x8(%ebp),%eax
801012f9:	8b 40 04             	mov    0x4(%eax),%eax
801012fc:	85 c0                	test   %eax,%eax
801012fe:	7f 0c                	jg     8010130c <filedup+0x28>
    panic("filedup");
80101300:	c7 04 24 78 8a 10 80 	movl   $0x80108a78,(%esp)
80101307:	e8 31 f2 ff ff       	call   8010053d <panic>
  f->ref++;
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 40 04             	mov    0x4(%eax),%eax
80101312:	8d 50 01             	lea    0x1(%eax),%edx
80101315:	8b 45 08             	mov    0x8(%ebp),%eax
80101318:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010131b:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
80101322:	e8 a6 40 00 00       	call   801053cd <release>
  return f;
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010132a:	c9                   	leave  
8010132b:	c3                   	ret    

8010132c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010132c:	55                   	push   %ebp
8010132d:	89 e5                	mov    %esp,%ebp
8010132f:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101332:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
80101339:	e8 2d 40 00 00       	call   8010536b <acquire>
  if(f->ref < 1)
8010133e:	8b 45 08             	mov    0x8(%ebp),%eax
80101341:	8b 40 04             	mov    0x4(%eax),%eax
80101344:	85 c0                	test   %eax,%eax
80101346:	7f 0c                	jg     80101354 <fileclose+0x28>
    panic("fileclose");
80101348:	c7 04 24 80 8a 10 80 	movl   $0x80108a80,(%esp)
8010134f:	e8 e9 f1 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101354:	8b 45 08             	mov    0x8(%ebp),%eax
80101357:	8b 40 04             	mov    0x4(%eax),%eax
8010135a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010135d:	8b 45 08             	mov    0x8(%ebp),%eax
80101360:	89 50 04             	mov    %edx,0x4(%eax)
80101363:	8b 45 08             	mov    0x8(%ebp),%eax
80101366:	8b 40 04             	mov    0x4(%eax),%eax
80101369:	85 c0                	test   %eax,%eax
8010136b:	7e 11                	jle    8010137e <fileclose+0x52>
    release(&ftable.lock);
8010136d:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
80101374:	e8 54 40 00 00       	call   801053cd <release>
    return;
80101379:	e9 82 00 00 00       	jmp    80101400 <fileclose+0xd4>
  }
  ff = *f;
8010137e:	8b 45 08             	mov    0x8(%ebp),%eax
80101381:	8b 10                	mov    (%eax),%edx
80101383:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101386:	8b 50 04             	mov    0x4(%eax),%edx
80101389:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010138c:	8b 50 08             	mov    0x8(%eax),%edx
8010138f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101392:	8b 50 0c             	mov    0xc(%eax),%edx
80101395:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101398:	8b 50 10             	mov    0x10(%eax),%edx
8010139b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010139e:	8b 40 14             	mov    0x14(%eax),%eax
801013a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801013b7:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
801013be:	e8 0a 40 00 00       	call   801053cd <release>
  
  if(ff.type == FD_PIPE)
801013c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013c6:	83 f8 01             	cmp    $0x1,%eax
801013c9:	75 18                	jne    801013e3 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801013cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801013cf:	0f be d0             	movsbl %al,%edx
801013d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801013d9:	89 04 24             	mov    %eax,(%esp)
801013dc:	e8 02 2d 00 00       	call   801040e3 <pipeclose>
801013e1:	eb 1d                	jmp    80101400 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801013e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013e6:	83 f8 02             	cmp    $0x2,%eax
801013e9:	75 15                	jne    80101400 <fileclose+0xd4>
    begin_trans();
801013eb:	e8 95 21 00 00       	call   80103585 <begin_trans>
    iput(ff.ip);
801013f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f3:	89 04 24             	mov    %eax,(%esp)
801013f6:	e8 88 09 00 00       	call   80101d83 <iput>
    commit_trans();
801013fb:	e8 ce 21 00 00       	call   801035ce <commit_trans>
  }
}
80101400:	c9                   	leave  
80101401:	c3                   	ret    

80101402 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101402:	55                   	push   %ebp
80101403:	89 e5                	mov    %esp,%ebp
80101405:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101408:	8b 45 08             	mov    0x8(%ebp),%eax
8010140b:	8b 00                	mov    (%eax),%eax
8010140d:	83 f8 02             	cmp    $0x2,%eax
80101410:	75 38                	jne    8010144a <filestat+0x48>
    ilock(f->ip);
80101412:	8b 45 08             	mov    0x8(%ebp),%eax
80101415:	8b 40 10             	mov    0x10(%eax),%eax
80101418:	89 04 24             	mov    %eax,(%esp)
8010141b:	e8 b0 07 00 00       	call   80101bd0 <ilock>
    stati(f->ip, st);
80101420:	8b 45 08             	mov    0x8(%ebp),%eax
80101423:	8b 40 10             	mov    0x10(%eax),%eax
80101426:	8b 55 0c             	mov    0xc(%ebp),%edx
80101429:	89 54 24 04          	mov    %edx,0x4(%esp)
8010142d:	89 04 24             	mov    %eax,(%esp)
80101430:	e8 4c 0c 00 00       	call   80102081 <stati>
    iunlock(f->ip);
80101435:	8b 45 08             	mov    0x8(%ebp),%eax
80101438:	8b 40 10             	mov    0x10(%eax),%eax
8010143b:	89 04 24             	mov    %eax,(%esp)
8010143e:	e8 db 08 00 00       	call   80101d1e <iunlock>
    return 0;
80101443:	b8 00 00 00 00       	mov    $0x0,%eax
80101448:	eb 05                	jmp    8010144f <filestat+0x4d>
  }
  return -1;
8010144a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010144f:	c9                   	leave  
80101450:	c3                   	ret    

80101451 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101451:	55                   	push   %ebp
80101452:	89 e5                	mov    %esp,%ebp
80101454:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101457:	8b 45 08             	mov    0x8(%ebp),%eax
8010145a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010145e:	84 c0                	test   %al,%al
80101460:	75 0a                	jne    8010146c <fileread+0x1b>
    return -1;
80101462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101467:	e9 9f 00 00 00       	jmp    8010150b <fileread+0xba>
  if(f->type == FD_PIPE)
8010146c:	8b 45 08             	mov    0x8(%ebp),%eax
8010146f:	8b 00                	mov    (%eax),%eax
80101471:	83 f8 01             	cmp    $0x1,%eax
80101474:	75 1e                	jne    80101494 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101476:	8b 45 08             	mov    0x8(%ebp),%eax
80101479:	8b 40 0c             	mov    0xc(%eax),%eax
8010147c:	8b 55 10             	mov    0x10(%ebp),%edx
8010147f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101483:	8b 55 0c             	mov    0xc(%ebp),%edx
80101486:	89 54 24 04          	mov    %edx,0x4(%esp)
8010148a:	89 04 24             	mov    %eax,(%esp)
8010148d:	e8 d3 2d 00 00       	call   80104265 <piperead>
80101492:	eb 77                	jmp    8010150b <fileread+0xba>
  if(f->type == FD_INODE){
80101494:	8b 45 08             	mov    0x8(%ebp),%eax
80101497:	8b 00                	mov    (%eax),%eax
80101499:	83 f8 02             	cmp    $0x2,%eax
8010149c:	75 61                	jne    801014ff <fileread+0xae>
    ilock(f->ip);
8010149e:	8b 45 08             	mov    0x8(%ebp),%eax
801014a1:	8b 40 10             	mov    0x10(%eax),%eax
801014a4:	89 04 24             	mov    %eax,(%esp)
801014a7:	e8 24 07 00 00       	call   80101bd0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801014ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
801014af:	8b 45 08             	mov    0x8(%ebp),%eax
801014b2:	8b 50 14             	mov    0x14(%eax),%edx
801014b5:	8b 45 08             	mov    0x8(%ebp),%eax
801014b8:	8b 40 10             	mov    0x10(%eax),%eax
801014bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801014bf:	89 54 24 08          	mov    %edx,0x8(%esp)
801014c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801014c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801014ca:	89 04 24             	mov    %eax,(%esp)
801014cd:	e8 f4 0b 00 00       	call   801020c6 <readi>
801014d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801014d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801014d9:	7e 11                	jle    801014ec <fileread+0x9b>
      f->off += r;
801014db:	8b 45 08             	mov    0x8(%ebp),%eax
801014de:	8b 50 14             	mov    0x14(%eax),%edx
801014e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e4:	01 c2                	add    %eax,%edx
801014e6:	8b 45 08             	mov    0x8(%ebp),%eax
801014e9:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801014ec:	8b 45 08             	mov    0x8(%ebp),%eax
801014ef:	8b 40 10             	mov    0x10(%eax),%eax
801014f2:	89 04 24             	mov    %eax,(%esp)
801014f5:	e8 24 08 00 00       	call   80101d1e <iunlock>
    return r;
801014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fd:	eb 0c                	jmp    8010150b <fileread+0xba>
  }
  panic("fileread");
801014ff:	c7 04 24 8a 8a 10 80 	movl   $0x80108a8a,(%esp)
80101506:	e8 32 f0 ff ff       	call   8010053d <panic>
}
8010150b:	c9                   	leave  
8010150c:	c3                   	ret    

8010150d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010150d:	55                   	push   %ebp
8010150e:	89 e5                	mov    %esp,%ebp
80101510:	53                   	push   %ebx
80101511:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101514:	8b 45 08             	mov    0x8(%ebp),%eax
80101517:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010151b:	84 c0                	test   %al,%al
8010151d:	75 0a                	jne    80101529 <filewrite+0x1c>
    return -1;
8010151f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101524:	e9 23 01 00 00       	jmp    8010164c <filewrite+0x13f>
  if(f->type == FD_PIPE)
80101529:	8b 45 08             	mov    0x8(%ebp),%eax
8010152c:	8b 00                	mov    (%eax),%eax
8010152e:	83 f8 01             	cmp    $0x1,%eax
80101531:	75 21                	jne    80101554 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101533:	8b 45 08             	mov    0x8(%ebp),%eax
80101536:	8b 40 0c             	mov    0xc(%eax),%eax
80101539:	8b 55 10             	mov    0x10(%ebp),%edx
8010153c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101540:	8b 55 0c             	mov    0xc(%ebp),%edx
80101543:	89 54 24 04          	mov    %edx,0x4(%esp)
80101547:	89 04 24             	mov    %eax,(%esp)
8010154a:	e8 26 2c 00 00       	call   80104175 <pipewrite>
8010154f:	e9 f8 00 00 00       	jmp    8010164c <filewrite+0x13f>
  if(f->type == FD_INODE){
80101554:	8b 45 08             	mov    0x8(%ebp),%eax
80101557:	8b 00                	mov    (%eax),%eax
80101559:	83 f8 02             	cmp    $0x2,%eax
8010155c:	0f 85 de 00 00 00    	jne    80101640 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101562:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101570:	e9 a8 00 00 00       	jmp    8010161d <filewrite+0x110>
      int n1 = n - i;
80101575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101578:	8b 55 10             	mov    0x10(%ebp),%edx
8010157b:	89 d1                	mov    %edx,%ecx
8010157d:	29 c1                	sub    %eax,%ecx
8010157f:	89 c8                	mov    %ecx,%eax
80101581:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101587:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010158a:	7e 06                	jle    80101592 <filewrite+0x85>
        n1 = max;
8010158c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010158f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101592:	e8 ee 1f 00 00       	call   80103585 <begin_trans>
      ilock(f->ip);
80101597:	8b 45 08             	mov    0x8(%ebp),%eax
8010159a:	8b 40 10             	mov    0x10(%eax),%eax
8010159d:	89 04 24             	mov    %eax,(%esp)
801015a0:	e8 2b 06 00 00       	call   80101bd0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801015a5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
801015a8:	8b 45 08             	mov    0x8(%ebp),%eax
801015ab:	8b 48 14             	mov    0x14(%eax),%ecx
801015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b1:	89 c2                	mov    %eax,%edx
801015b3:	03 55 0c             	add    0xc(%ebp),%edx
801015b6:	8b 45 08             	mov    0x8(%ebp),%eax
801015b9:	8b 40 10             	mov    0x10(%eax),%eax
801015bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801015c0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801015c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801015c8:	89 04 24             	mov    %eax,(%esp)
801015cb:	e8 61 0c 00 00       	call   80102231 <writei>
801015d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801015d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015d7:	7e 11                	jle    801015ea <filewrite+0xdd>
        f->off += r;
801015d9:	8b 45 08             	mov    0x8(%ebp),%eax
801015dc:	8b 50 14             	mov    0x14(%eax),%edx
801015df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015e2:	01 c2                	add    %eax,%edx
801015e4:	8b 45 08             	mov    0x8(%ebp),%eax
801015e7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801015ea:	8b 45 08             	mov    0x8(%ebp),%eax
801015ed:	8b 40 10             	mov    0x10(%eax),%eax
801015f0:	89 04 24             	mov    %eax,(%esp)
801015f3:	e8 26 07 00 00       	call   80101d1e <iunlock>
      commit_trans();
801015f8:	e8 d1 1f 00 00       	call   801035ce <commit_trans>

      if(r < 0)
801015fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101601:	78 28                	js     8010162b <filewrite+0x11e>
        break;
      if(r != n1)
80101603:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101606:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101609:	74 0c                	je     80101617 <filewrite+0x10a>
        panic("short filewrite");
8010160b:	c7 04 24 93 8a 10 80 	movl   $0x80108a93,(%esp)
80101612:	e8 26 ef ff ff       	call   8010053d <panic>
      i += r;
80101617:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010161a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010161d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101620:	3b 45 10             	cmp    0x10(%ebp),%eax
80101623:	0f 8c 4c ff ff ff    	jl     80101575 <filewrite+0x68>
80101629:	eb 01                	jmp    8010162c <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
8010162b:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010162c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101632:	75 05                	jne    80101639 <filewrite+0x12c>
80101634:	8b 45 10             	mov    0x10(%ebp),%eax
80101637:	eb 05                	jmp    8010163e <filewrite+0x131>
80101639:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010163e:	eb 0c                	jmp    8010164c <filewrite+0x13f>
  }
  panic("filewrite");
80101640:	c7 04 24 a3 8a 10 80 	movl   $0x80108aa3,(%esp)
80101647:	e8 f1 ee ff ff       	call   8010053d <panic>
}
8010164c:	83 c4 24             	add    $0x24,%esp
8010164f:	5b                   	pop    %ebx
80101650:	5d                   	pop    %ebp
80101651:	c3                   	ret    
	...

80101654 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101654:	55                   	push   %ebp
80101655:	89 e5                	mov    %esp,%ebp
80101657:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010165a:	8b 45 08             	mov    0x8(%ebp),%eax
8010165d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101664:	00 
80101665:	89 04 24             	mov    %eax,(%esp)
80101668:	e8 39 eb ff ff       	call   801001a6 <bread>
8010166d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101673:	83 c0 18             	add    $0x18,%eax
80101676:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010167d:	00 
8010167e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101682:	8b 45 0c             	mov    0xc(%ebp),%eax
80101685:	89 04 24             	mov    %eax,(%esp)
80101688:	e8 00 40 00 00       	call   8010568d <memmove>
  brelse(bp);
8010168d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101690:	89 04 24             	mov    %eax,(%esp)
80101693:	e8 7f eb ff ff       	call   80100217 <brelse>
}
80101698:	c9                   	leave  
80101699:	c3                   	ret    

8010169a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010169a:	55                   	push   %ebp
8010169b:	89 e5                	mov    %esp,%ebp
8010169d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801016a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801016a3:	8b 45 08             	mov    0x8(%ebp),%eax
801016a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801016aa:	89 04 24             	mov    %eax,(%esp)
801016ad:	e8 f4 ea ff ff       	call   801001a6 <bread>
801016b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801016b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b8:	83 c0 18             	add    $0x18,%eax
801016bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801016c2:	00 
801016c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016ca:	00 
801016cb:	89 04 24             	mov    %eax,(%esp)
801016ce:	e8 e7 3e 00 00       	call   801055ba <memset>
  log_write(bp);
801016d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d6:	89 04 24             	mov    %eax,(%esp)
801016d9:	e8 48 1f 00 00       	call   80103626 <log_write>
  brelse(bp);
801016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e1:	89 04 24             	mov    %eax,(%esp)
801016e4:	e8 2e eb ff ff       	call   80100217 <brelse>
}
801016e9:	c9                   	leave  
801016ea:	c3                   	ret    

801016eb <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801016eb:	55                   	push   %ebp
801016ec:	89 e5                	mov    %esp,%ebp
801016ee:	53                   	push   %ebx
801016ef:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801016f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801016f9:	8b 45 08             	mov    0x8(%ebp),%eax
801016fc:	8d 55 d8             	lea    -0x28(%ebp),%edx
801016ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80101703:	89 04 24             	mov    %eax,(%esp)
80101706:	e8 49 ff ff ff       	call   80101654 <readsb>
  for(b = 0; b < sb.size; b += BPB){
8010170b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101712:	e9 11 01 00 00       	jmp    80101828 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101720:	85 c0                	test   %eax,%eax
80101722:	0f 48 c2             	cmovs  %edx,%eax
80101725:	c1 f8 0c             	sar    $0xc,%eax
80101728:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010172b:	c1 ea 03             	shr    $0x3,%edx
8010172e:	01 d0                	add    %edx,%eax
80101730:	83 c0 03             	add    $0x3,%eax
80101733:	89 44 24 04          	mov    %eax,0x4(%esp)
80101737:	8b 45 08             	mov    0x8(%ebp),%eax
8010173a:	89 04 24             	mov    %eax,(%esp)
8010173d:	e8 64 ea ff ff       	call   801001a6 <bread>
80101742:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101745:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010174c:	e9 a7 00 00 00       	jmp    801017f8 <balloc+0x10d>
      m = 1 << (bi % 8);
80101751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101754:	89 c2                	mov    %eax,%edx
80101756:	c1 fa 1f             	sar    $0x1f,%edx
80101759:	c1 ea 1d             	shr    $0x1d,%edx
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 e0 07             	and    $0x7,%eax
80101761:	29 d0                	sub    %edx,%eax
80101763:	ba 01 00 00 00       	mov    $0x1,%edx
80101768:	89 d3                	mov    %edx,%ebx
8010176a:	89 c1                	mov    %eax,%ecx
8010176c:	d3 e3                	shl    %cl,%ebx
8010176e:	89 d8                	mov    %ebx,%eax
80101770:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101773:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101776:	8d 50 07             	lea    0x7(%eax),%edx
80101779:	85 c0                	test   %eax,%eax
8010177b:	0f 48 c2             	cmovs  %edx,%eax
8010177e:	c1 f8 03             	sar    $0x3,%eax
80101781:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101784:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101789:	0f b6 c0             	movzbl %al,%eax
8010178c:	23 45 e8             	and    -0x18(%ebp),%eax
8010178f:	85 c0                	test   %eax,%eax
80101791:	75 61                	jne    801017f4 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101796:	8d 50 07             	lea    0x7(%eax),%edx
80101799:	85 c0                	test   %eax,%eax
8010179b:	0f 48 c2             	cmovs  %edx,%eax
8010179e:	c1 f8 03             	sar    $0x3,%eax
801017a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017a4:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801017a9:	89 d1                	mov    %edx,%ecx
801017ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
801017ae:	09 ca                	or     %ecx,%edx
801017b0:	89 d1                	mov    %edx,%ecx
801017b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017b5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017bc:	89 04 24             	mov    %eax,(%esp)
801017bf:	e8 62 1e 00 00       	call   80103626 <log_write>
        brelse(bp);
801017c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c7:	89 04 24             	mov    %eax,(%esp)
801017ca:	e8 48 ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
801017cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017d5:	01 c2                	add    %eax,%edx
801017d7:	8b 45 08             	mov    0x8(%ebp),%eax
801017da:	89 54 24 04          	mov    %edx,0x4(%esp)
801017de:	89 04 24             	mov    %eax,(%esp)
801017e1:	e8 b4 fe ff ff       	call   8010169a <bzero>
        return b + bi;
801017e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017ec:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801017ee:	83 c4 34             	add    $0x34,%esp
801017f1:	5b                   	pop    %ebx
801017f2:	5d                   	pop    %ebp
801017f3:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801017f4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801017f8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801017ff:	7f 15                	jg     80101816 <balloc+0x12b>
80101801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101804:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101807:	01 d0                	add    %edx,%eax
80101809:	89 c2                	mov    %eax,%edx
8010180b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010180e:	39 c2                	cmp    %eax,%edx
80101810:	0f 82 3b ff ff ff    	jb     80101751 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101816:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101819:	89 04 24             	mov    %eax,(%esp)
8010181c:	e8 f6 e9 ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101821:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101828:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010182b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010182e:	39 c2                	cmp    %eax,%edx
80101830:	0f 82 e1 fe ff ff    	jb     80101717 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101836:	c7 04 24 ad 8a 10 80 	movl   $0x80108aad,(%esp)
8010183d:	e8 fb ec ff ff       	call   8010053d <panic>

80101842 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101842:	55                   	push   %ebp
80101843:	89 e5                	mov    %esp,%ebp
80101845:	53                   	push   %ebx
80101846:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101849:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010184c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101850:	8b 45 08             	mov    0x8(%ebp),%eax
80101853:	89 04 24             	mov    %eax,(%esp)
80101856:	e8 f9 fd ff ff       	call   80101654 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
8010185b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010185e:	89 c2                	mov    %eax,%edx
80101860:	c1 ea 0c             	shr    $0xc,%edx
80101863:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101866:	c1 e8 03             	shr    $0x3,%eax
80101869:	01 d0                	add    %edx,%eax
8010186b:	8d 50 03             	lea    0x3(%eax),%edx
8010186e:	8b 45 08             	mov    0x8(%ebp),%eax
80101871:	89 54 24 04          	mov    %edx,0x4(%esp)
80101875:	89 04 24             	mov    %eax,(%esp)
80101878:	e8 29 e9 ff ff       	call   801001a6 <bread>
8010187d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101880:	8b 45 0c             	mov    0xc(%ebp),%eax
80101883:	25 ff 0f 00 00       	and    $0xfff,%eax
80101888:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188e:	89 c2                	mov    %eax,%edx
80101890:	c1 fa 1f             	sar    $0x1f,%edx
80101893:	c1 ea 1d             	shr    $0x1d,%edx
80101896:	01 d0                	add    %edx,%eax
80101898:	83 e0 07             	and    $0x7,%eax
8010189b:	29 d0                	sub    %edx,%eax
8010189d:	ba 01 00 00 00       	mov    $0x1,%edx
801018a2:	89 d3                	mov    %edx,%ebx
801018a4:	89 c1                	mov    %eax,%ecx
801018a6:	d3 e3                	shl    %cl,%ebx
801018a8:	89 d8                	mov    %ebx,%eax
801018aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801018ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b0:	8d 50 07             	lea    0x7(%eax),%edx
801018b3:	85 c0                	test   %eax,%eax
801018b5:	0f 48 c2             	cmovs  %edx,%eax
801018b8:	c1 f8 03             	sar    $0x3,%eax
801018bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018be:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801018c3:	0f b6 c0             	movzbl %al,%eax
801018c6:	23 45 ec             	and    -0x14(%ebp),%eax
801018c9:	85 c0                	test   %eax,%eax
801018cb:	75 0c                	jne    801018d9 <bfree+0x97>
    panic("freeing free block");
801018cd:	c7 04 24 c3 8a 10 80 	movl   $0x80108ac3,(%esp)
801018d4:	e8 64 ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
801018d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018dc:	8d 50 07             	lea    0x7(%eax),%edx
801018df:	85 c0                	test   %eax,%eax
801018e1:	0f 48 c2             	cmovs  %edx,%eax
801018e4:	c1 f8 03             	sar    $0x3,%eax
801018e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018ea:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801018ef:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801018f2:	f7 d1                	not    %ecx
801018f4:	21 ca                	and    %ecx,%edx
801018f6:	89 d1                	mov    %edx,%ecx
801018f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018fb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101902:	89 04 24             	mov    %eax,(%esp)
80101905:	e8 1c 1d 00 00       	call   80103626 <log_write>
  brelse(bp);
8010190a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190d:	89 04 24             	mov    %eax,(%esp)
80101910:	e8 02 e9 ff ff       	call   80100217 <brelse>
}
80101915:	83 c4 34             	add    $0x34,%esp
80101918:	5b                   	pop    %ebx
80101919:	5d                   	pop    %ebp
8010191a:	c3                   	ret    

8010191b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010191b:	55                   	push   %ebp
8010191c:	89 e5                	mov    %esp,%ebp
8010191e:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101921:	c7 44 24 04 d6 8a 10 	movl   $0x80108ad6,0x4(%esp)
80101928:	80 
80101929:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101930:	e8 15 3a 00 00       	call   8010534a <initlock>
}
80101935:	c9                   	leave  
80101936:	c3                   	ret    

80101937 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101937:	55                   	push   %ebp
80101938:	89 e5                	mov    %esp,%ebp
8010193a:	83 ec 48             	sub    $0x48,%esp
8010193d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101940:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101944:	8b 45 08             	mov    0x8(%ebp),%eax
80101947:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010194a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010194e:	89 04 24             	mov    %eax,(%esp)
80101951:	e8 fe fc ff ff       	call   80101654 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101956:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010195d:	e9 98 00 00 00       	jmp    801019fa <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101965:	c1 e8 03             	shr    $0x3,%eax
80101968:	83 c0 02             	add    $0x2,%eax
8010196b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010196f:	8b 45 08             	mov    0x8(%ebp),%eax
80101972:	89 04 24             	mov    %eax,(%esp)
80101975:	e8 2c e8 ff ff       	call   801001a6 <bread>
8010197a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010197d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101980:	8d 50 18             	lea    0x18(%eax),%edx
80101983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101986:	83 e0 07             	and    $0x7,%eax
80101989:	c1 e0 06             	shl    $0x6,%eax
8010198c:	01 d0                	add    %edx,%eax
8010198e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101991:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101994:	0f b7 00             	movzwl (%eax),%eax
80101997:	66 85 c0             	test   %ax,%ax
8010199a:	75 4f                	jne    801019eb <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010199c:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801019a3:	00 
801019a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801019ab:	00 
801019ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019af:	89 04 24             	mov    %eax,(%esp)
801019b2:	e8 03 3c 00 00       	call   801055ba <memset>
      dip->type = type;
801019b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019ba:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801019be:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c4:	89 04 24             	mov    %eax,(%esp)
801019c7:	e8 5a 1c 00 00       	call   80103626 <log_write>
      brelse(bp);
801019cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cf:	89 04 24             	mov    %eax,(%esp)
801019d2:	e8 40 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801019d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019da:	89 44 24 04          	mov    %eax,0x4(%esp)
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	89 04 24             	mov    %eax,(%esp)
801019e4:	e8 e3 00 00 00       	call   80101acc <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801019e9:	c9                   	leave  
801019ea:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ee:	89 04 24             	mov    %eax,(%esp)
801019f1:	e8 21 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801019f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801019fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101a00:	39 c2                	cmp    %eax,%edx
80101a02:	0f 82 5a ff ff ff    	jb     80101962 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101a08:	c7 04 24 dd 8a 10 80 	movl   $0x80108add,(%esp)
80101a0f:	e8 29 eb ff ff       	call   8010053d <panic>

80101a14 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a14:	55                   	push   %ebp
80101a15:	89 e5                	mov    %esp,%ebp
80101a17:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	8b 40 04             	mov    0x4(%eax),%eax
80101a20:	c1 e8 03             	shr    $0x3,%eax
80101a23:	8d 50 02             	lea    0x2(%eax),%edx
80101a26:	8b 45 08             	mov    0x8(%ebp),%eax
80101a29:	8b 00                	mov    (%eax),%eax
80101a2b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a2f:	89 04 24             	mov    %eax,(%esp)
80101a32:	e8 6f e7 ff ff       	call   801001a6 <bread>
80101a37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3d:	8d 50 18             	lea    0x18(%eax),%edx
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	8b 40 04             	mov    0x4(%eax),%eax
80101a46:	83 e0 07             	and    $0x7,%eax
80101a49:	c1 e0 06             	shl    $0x6,%eax
80101a4c:	01 d0                	add    %edx,%eax
80101a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a61:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a68:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a84:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a88:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8b:	8b 50 18             	mov    0x18(%eax),%edx
80101a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a91:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a94:	8b 45 08             	mov    0x8(%ebp),%eax
80101a97:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9d:	83 c0 0c             	add    $0xc,%eax
80101aa0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101aa7:	00 
80101aa8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101aac:	89 04 24             	mov    %eax,(%esp)
80101aaf:	e8 d9 3b 00 00       	call   8010568d <memmove>
  log_write(bp);
80101ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab7:	89 04 24             	mov    %eax,(%esp)
80101aba:	e8 67 1b 00 00       	call   80103626 <log_write>
  brelse(bp);
80101abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac2:	89 04 24             	mov    %eax,(%esp)
80101ac5:	e8 4d e7 ff ff       	call   80100217 <brelse>
}
80101aca:	c9                   	leave  
80101acb:	c3                   	ret    

80101acc <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101acc:	55                   	push   %ebp
80101acd:	89 e5                	mov    %esp,%ebp
80101acf:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101ad2:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101ad9:	e8 8d 38 00 00       	call   8010536b <acquire>

  // Is the inode already cached?
  empty = 0;
80101ade:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ae5:	c7 45 f4 b4 f8 10 80 	movl   $0x8010f8b4,-0xc(%ebp)
80101aec:	eb 59                	jmp    80101b47 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af1:	8b 40 08             	mov    0x8(%eax),%eax
80101af4:	85 c0                	test   %eax,%eax
80101af6:	7e 35                	jle    80101b2d <iget+0x61>
80101af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afb:	8b 00                	mov    (%eax),%eax
80101afd:	3b 45 08             	cmp    0x8(%ebp),%eax
80101b00:	75 2b                	jne    80101b2d <iget+0x61>
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b05:	8b 40 04             	mov    0x4(%eax),%eax
80101b08:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101b0b:	75 20                	jne    80101b2d <iget+0x61>
      ip->ref++;
80101b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b10:	8b 40 08             	mov    0x8(%eax),%eax
80101b13:	8d 50 01             	lea    0x1(%eax),%edx
80101b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b19:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101b1c:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101b23:	e8 a5 38 00 00       	call   801053cd <release>
      return ip;
80101b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2b:	eb 6f                	jmp    80101b9c <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101b2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b31:	75 10                	jne    80101b43 <iget+0x77>
80101b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b36:	8b 40 08             	mov    0x8(%eax),%eax
80101b39:	85 c0                	test   %eax,%eax
80101b3b:	75 06                	jne    80101b43 <iget+0x77>
      empty = ip;
80101b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b40:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b43:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101b47:	81 7d f4 54 08 11 80 	cmpl   $0x80110854,-0xc(%ebp)
80101b4e:	72 9e                	jb     80101aee <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101b50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b54:	75 0c                	jne    80101b62 <iget+0x96>
    panic("iget: no inodes");
80101b56:	c7 04 24 ef 8a 10 80 	movl   $0x80108aef,(%esp)
80101b5d:	e8 db e9 ff ff       	call   8010053d <panic>

  ip = empty;
80101b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b6b:	8b 55 08             	mov    0x8(%ebp),%edx
80101b6e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b73:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b76:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b86:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b8d:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101b94:	e8 34 38 00 00       	call   801053cd <release>

  return ip;
80101b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b9c:	c9                   	leave  
80101b9d:	c3                   	ret    

80101b9e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b9e:	55                   	push   %ebp
80101b9f:	89 e5                	mov    %esp,%ebp
80101ba1:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101ba4:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101bab:	e8 bb 37 00 00       	call   8010536b <acquire>
  ip->ref++;
80101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb3:	8b 40 08             	mov    0x8(%eax),%eax
80101bb6:	8d 50 01             	lea    0x1(%eax),%edx
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bbf:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101bc6:	e8 02 38 00 00       	call   801053cd <release>
  return ip;
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101bce:	c9                   	leave  
80101bcf:	c3                   	ret    

80101bd0 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101bd0:	55                   	push   %ebp
80101bd1:	89 e5                	mov    %esp,%ebp
80101bd3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101bd6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bda:	74 0a                	je     80101be6 <ilock+0x16>
80101bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdf:	8b 40 08             	mov    0x8(%eax),%eax
80101be2:	85 c0                	test   %eax,%eax
80101be4:	7f 0c                	jg     80101bf2 <ilock+0x22>
    panic("ilock");
80101be6:	c7 04 24 ff 8a 10 80 	movl   $0x80108aff,(%esp)
80101bed:	e8 4b e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101bf2:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101bf9:	e8 6d 37 00 00       	call   8010536b <acquire>
  while(ip->flags & I_BUSY)
80101bfe:	eb 13                	jmp    80101c13 <ilock+0x43>
    sleep(ip, &icache.lock);
80101c00:	c7 44 24 04 80 f8 10 	movl   $0x8010f880,0x4(%esp)
80101c07:	80 
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	89 04 24             	mov    %eax,(%esp)
80101c0e:	e8 30 34 00 00       	call   80105043 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	8b 40 0c             	mov    0xc(%eax),%eax
80101c19:	83 e0 01             	and    $0x1,%eax
80101c1c:	84 c0                	test   %al,%al
80101c1e:	75 e0                	jne    80101c00 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101c20:	8b 45 08             	mov    0x8(%ebp),%eax
80101c23:	8b 40 0c             	mov    0xc(%eax),%eax
80101c26:	89 c2                	mov    %eax,%edx
80101c28:	83 ca 01             	or     $0x1,%edx
80101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2e:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101c31:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101c38:	e8 90 37 00 00       	call   801053cd <release>

  if(!(ip->flags & I_VALID)){
80101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c40:	8b 40 0c             	mov    0xc(%eax),%eax
80101c43:	83 e0 02             	and    $0x2,%eax
80101c46:	85 c0                	test   %eax,%eax
80101c48:	0f 85 ce 00 00 00    	jne    80101d1c <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c51:	8b 40 04             	mov    0x4(%eax),%eax
80101c54:	c1 e8 03             	shr    $0x3,%eax
80101c57:	8d 50 02             	lea    0x2(%eax),%edx
80101c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5d:	8b 00                	mov    (%eax),%eax
80101c5f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c63:	89 04 24             	mov    %eax,(%esp)
80101c66:	e8 3b e5 ff ff       	call   801001a6 <bread>
80101c6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c71:	8d 50 18             	lea    0x18(%eax),%edx
80101c74:	8b 45 08             	mov    0x8(%ebp),%eax
80101c77:	8b 40 04             	mov    0x4(%eax),%eax
80101c7a:	83 e0 07             	and    $0x7,%eax
80101c7d:	c1 e0 06             	shl    $0x6,%eax
80101c80:	01 d0                	add    %edx,%eax
80101c82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c88:	0f b7 10             	movzwl (%eax),%edx
80101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8e:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c95:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c99:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca3:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80101caa:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb1:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb8:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cbf:	8b 50 08             	mov    0x8(%eax),%edx
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ccb:	8d 50 0c             	lea    0xc(%eax),%edx
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	83 c0 1c             	add    $0x1c,%eax
80101cd4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101cdb:	00 
80101cdc:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce0:	89 04 24             	mov    %eax,(%esp)
80101ce3:	e8 a5 39 00 00       	call   8010568d <memmove>
    brelse(bp);
80101ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ceb:	89 04 24             	mov    %eax,(%esp)
80101cee:	e8 24 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf6:	8b 40 0c             	mov    0xc(%eax),%eax
80101cf9:	89 c2                	mov    %eax,%edx
80101cfb:	83 ca 02             	or     $0x2,%edx
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d0b:	66 85 c0             	test   %ax,%ax
80101d0e:	75 0c                	jne    80101d1c <ilock+0x14c>
      panic("ilock: no type");
80101d10:	c7 04 24 05 8b 10 80 	movl   $0x80108b05,(%esp)
80101d17:	e8 21 e8 ff ff       	call   8010053d <panic>
  }
}
80101d1c:	c9                   	leave  
80101d1d:	c3                   	ret    

80101d1e <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101d1e:	55                   	push   %ebp
80101d1f:	89 e5                	mov    %esp,%ebp
80101d21:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101d24:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101d28:	74 17                	je     80101d41 <iunlock+0x23>
80101d2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2d:	8b 40 0c             	mov    0xc(%eax),%eax
80101d30:	83 e0 01             	and    $0x1,%eax
80101d33:	85 c0                	test   %eax,%eax
80101d35:	74 0a                	je     80101d41 <iunlock+0x23>
80101d37:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3a:	8b 40 08             	mov    0x8(%eax),%eax
80101d3d:	85 c0                	test   %eax,%eax
80101d3f:	7f 0c                	jg     80101d4d <iunlock+0x2f>
    panic("iunlock");
80101d41:	c7 04 24 14 8b 10 80 	movl   $0x80108b14,(%esp)
80101d48:	e8 f0 e7 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101d4d:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101d54:	e8 12 36 00 00       	call   8010536b <acquire>
  ip->flags &= ~I_BUSY;
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	8b 40 0c             	mov    0xc(%eax),%eax
80101d5f:	89 c2                	mov    %eax,%edx
80101d61:	83 e2 fe             	and    $0xfffffffe,%edx
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	89 04 24             	mov    %eax,(%esp)
80101d70:	e8 aa 33 00 00       	call   8010511f <wakeup>
  release(&icache.lock);
80101d75:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101d7c:	e8 4c 36 00 00       	call   801053cd <release>
}
80101d81:	c9                   	leave  
80101d82:	c3                   	ret    

80101d83 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d83:	55                   	push   %ebp
80101d84:	89 e5                	mov    %esp,%ebp
80101d86:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d89:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101d90:	e8 d6 35 00 00       	call   8010536b <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	8b 40 08             	mov    0x8(%eax),%eax
80101d9b:	83 f8 01             	cmp    $0x1,%eax
80101d9e:	0f 85 93 00 00 00    	jne    80101e37 <iput+0xb4>
80101da4:	8b 45 08             	mov    0x8(%ebp),%eax
80101da7:	8b 40 0c             	mov    0xc(%eax),%eax
80101daa:	83 e0 02             	and    $0x2,%eax
80101dad:	85 c0                	test   %eax,%eax
80101daf:	0f 84 82 00 00 00    	je     80101e37 <iput+0xb4>
80101db5:	8b 45 08             	mov    0x8(%ebp),%eax
80101db8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101dbc:	66 85 c0             	test   %ax,%ax
80101dbf:	75 76                	jne    80101e37 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 40 0c             	mov    0xc(%eax),%eax
80101dc7:	83 e0 01             	and    $0x1,%eax
80101dca:	84 c0                	test   %al,%al
80101dcc:	74 0c                	je     80101dda <iput+0x57>
      panic("iput busy");
80101dce:	c7 04 24 1c 8b 10 80 	movl   $0x80108b1c,(%esp)
80101dd5:	e8 63 e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101dda:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddd:	8b 40 0c             	mov    0xc(%eax),%eax
80101de0:	89 c2                	mov    %eax,%edx
80101de2:	83 ca 01             	or     $0x1,%edx
80101de5:	8b 45 08             	mov    0x8(%ebp),%eax
80101de8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101deb:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101df2:	e8 d6 35 00 00       	call   801053cd <release>
    itrunc(ip);
80101df7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfa:	89 04 24             	mov    %eax,(%esp)
80101dfd:	e8 72 01 00 00       	call   80101f74 <itrunc>
    ip->type = 0;
80101e02:	8b 45 08             	mov    0x8(%ebp),%eax
80101e05:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0e:	89 04 24             	mov    %eax,(%esp)
80101e11:	e8 fe fb ff ff       	call   80101a14 <iupdate>
    acquire(&icache.lock);
80101e16:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101e1d:	e8 49 35 00 00       	call   8010536b <acquire>
    ip->flags = 0;
80101e22:	8b 45 08             	mov    0x8(%ebp),%eax
80101e25:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2f:	89 04 24             	mov    %eax,(%esp)
80101e32:	e8 e8 32 00 00       	call   8010511f <wakeup>
  }
  ip->ref--;
80101e37:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3a:	8b 40 08             	mov    0x8(%eax),%eax
80101e3d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101e40:	8b 45 08             	mov    0x8(%ebp),%eax
80101e43:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101e46:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101e4d:	e8 7b 35 00 00       	call   801053cd <release>
}
80101e52:	c9                   	leave  
80101e53:	c3                   	ret    

80101e54 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101e54:	55                   	push   %ebp
80101e55:	89 e5                	mov    %esp,%ebp
80101e57:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5d:	89 04 24             	mov    %eax,(%esp)
80101e60:	e8 b9 fe ff ff       	call   80101d1e <iunlock>
  iput(ip);
80101e65:	8b 45 08             	mov    0x8(%ebp),%eax
80101e68:	89 04 24             	mov    %eax,(%esp)
80101e6b:	e8 13 ff ff ff       	call   80101d83 <iput>
}
80101e70:	c9                   	leave  
80101e71:	c3                   	ret    

80101e72 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e72:	55                   	push   %ebp
80101e73:	89 e5                	mov    %esp,%ebp
80101e75:	53                   	push   %ebx
80101e76:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e79:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e7d:	77 3e                	ja     80101ebd <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e82:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e85:	83 c2 04             	add    $0x4,%edx
80101e88:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e93:	75 20                	jne    80101eb5 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 00                	mov    (%eax),%eax
80101e9a:	89 04 24             	mov    %eax,(%esp)
80101e9d:	e8 49 f8 ff ff       	call   801016eb <balloc>
80101ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea8:	8b 55 0c             	mov    0xc(%ebp),%edx
80101eab:	8d 4a 04             	lea    0x4(%edx),%ecx
80101eae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eb1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb8:	e9 b1 00 00 00       	jmp    80101f6e <bmap+0xfc>
  }
  bn -= NDIRECT;
80101ebd:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ec1:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ec5:	0f 87 97 00 00 00    	ja     80101f62 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ece:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ed1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ed4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ed8:	75 19                	jne    80101ef3 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101eda:	8b 45 08             	mov    0x8(%ebp),%eax
80101edd:	8b 00                	mov    (%eax),%eax
80101edf:	89 04 24             	mov    %eax,(%esp)
80101ee2:	e8 04 f8 ff ff       	call   801016eb <balloc>
80101ee7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ef0:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef6:	8b 00                	mov    (%eax),%eax
80101ef8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101efb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eff:	89 04 24             	mov    %eax,(%esp)
80101f02:	e8 9f e2 ff ff       	call   801001a6 <bread>
80101f07:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f0d:	83 c0 18             	add    $0x18,%eax
80101f10:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101f13:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f16:	c1 e0 02             	shl    $0x2,%eax
80101f19:	03 45 ec             	add    -0x14(%ebp),%eax
80101f1c:	8b 00                	mov    (%eax),%eax
80101f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f25:	75 2b                	jne    80101f52 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101f27:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f2a:	c1 e0 02             	shl    $0x2,%eax
80101f2d:	89 c3                	mov    %eax,%ebx
80101f2f:	03 5d ec             	add    -0x14(%ebp),%ebx
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	8b 00                	mov    (%eax),%eax
80101f37:	89 04 24             	mov    %eax,(%esp)
80101f3a:	e8 ac f7 ff ff       	call   801016eb <balloc>
80101f3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f45:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f4a:	89 04 24             	mov    %eax,(%esp)
80101f4d:	e8 d4 16 00 00       	call   80103626 <log_write>
    }
    brelse(bp);
80101f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f55:	89 04 24             	mov    %eax,(%esp)
80101f58:	e8 ba e2 ff ff       	call   80100217 <brelse>
    return addr;
80101f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f60:	eb 0c                	jmp    80101f6e <bmap+0xfc>
  }

  panic("bmap: out of range");
80101f62:	c7 04 24 26 8b 10 80 	movl   $0x80108b26,(%esp)
80101f69:	e8 cf e5 ff ff       	call   8010053d <panic>
}
80101f6e:	83 c4 24             	add    $0x24,%esp
80101f71:	5b                   	pop    %ebx
80101f72:	5d                   	pop    %ebp
80101f73:	c3                   	ret    

80101f74 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f74:	55                   	push   %ebp
80101f75:	89 e5                	mov    %esp,%ebp
80101f77:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f81:	eb 44                	jmp    80101fc7 <itrunc+0x53>
    if(ip->addrs[i]){
80101f83:	8b 45 08             	mov    0x8(%ebp),%eax
80101f86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f89:	83 c2 04             	add    $0x4,%edx
80101f8c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f90:	85 c0                	test   %eax,%eax
80101f92:	74 2f                	je     80101fc3 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f94:	8b 45 08             	mov    0x8(%ebp),%eax
80101f97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f9a:	83 c2 04             	add    $0x4,%edx
80101f9d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa4:	8b 00                	mov    (%eax),%eax
80101fa6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101faa:	89 04 24             	mov    %eax,(%esp)
80101fad:	e8 90 f8 ff ff       	call   80101842 <bfree>
      ip->addrs[i] = 0;
80101fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fb8:	83 c2 04             	add    $0x4,%edx
80101fbb:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101fc2:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101fc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101fc7:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101fcb:	7e b6                	jle    80101f83 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fd3:	85 c0                	test   %eax,%eax
80101fd5:	0f 84 8f 00 00 00    	je     8010206a <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fde:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe4:	8b 00                	mov    (%eax),%eax
80101fe6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fea:	89 04 24             	mov    %eax,(%esp)
80101fed:	e8 b4 e1 ff ff       	call   801001a6 <bread>
80101ff2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ff5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff8:	83 c0 18             	add    $0x18,%eax
80101ffb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ffe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102005:	eb 2f                	jmp    80102036 <itrunc+0xc2>
      if(a[j])
80102007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200a:	c1 e0 02             	shl    $0x2,%eax
8010200d:	03 45 e8             	add    -0x18(%ebp),%eax
80102010:	8b 00                	mov    (%eax),%eax
80102012:	85 c0                	test   %eax,%eax
80102014:	74 1c                	je     80102032 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80102016:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102019:	c1 e0 02             	shl    $0x2,%eax
8010201c:	03 45 e8             	add    -0x18(%ebp),%eax
8010201f:	8b 10                	mov    (%eax),%edx
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	8b 00                	mov    (%eax),%eax
80102026:	89 54 24 04          	mov    %edx,0x4(%esp)
8010202a:	89 04 24             	mov    %eax,(%esp)
8010202d:	e8 10 f8 ff ff       	call   80101842 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80102032:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102036:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102039:	83 f8 7f             	cmp    $0x7f,%eax
8010203c:	76 c9                	jbe    80102007 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
8010203e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102041:	89 04 24             	mov    %eax,(%esp)
80102044:	e8 ce e1 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102049:	8b 45 08             	mov    0x8(%ebp),%eax
8010204c:	8b 50 4c             	mov    0x4c(%eax),%edx
8010204f:	8b 45 08             	mov    0x8(%ebp),%eax
80102052:	8b 00                	mov    (%eax),%eax
80102054:	89 54 24 04          	mov    %edx,0x4(%esp)
80102058:	89 04 24             	mov    %eax,(%esp)
8010205b:	e8 e2 f7 ff ff       	call   80101842 <bfree>
    ip->addrs[NDIRECT] = 0;
80102060:	8b 45 08             	mov    0x8(%ebp),%eax
80102063:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	89 04 24             	mov    %eax,(%esp)
8010207a:	e8 95 f9 ff ff       	call   80101a14 <iupdate>
}
8010207f:	c9                   	leave  
80102080:	c3                   	ret    

80102081 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102081:	55                   	push   %ebp
80102082:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	8b 00                	mov    (%eax),%eax
80102089:	89 c2                	mov    %eax,%edx
8010208b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010208e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102091:	8b 45 08             	mov    0x8(%ebp),%eax
80102094:	8b 50 04             	mov    0x4(%eax),%edx
80102097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010209a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
8010209d:	8b 45 08             	mov    0x8(%ebp),%eax
801020a0:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801020a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a7:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801020b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801020b4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801020b8:	8b 45 08             	mov    0x8(%ebp),%eax
801020bb:	8b 50 18             	mov    0x18(%eax),%edx
801020be:	8b 45 0c             	mov    0xc(%ebp),%eax
801020c1:	89 50 10             	mov    %edx,0x10(%eax)
}
801020c4:	5d                   	pop    %ebp
801020c5:	c3                   	ret    

801020c6 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801020c6:	55                   	push   %ebp
801020c7:	89 e5                	mov    %esp,%ebp
801020c9:	53                   	push   %ebx
801020ca:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020cd:	8b 45 08             	mov    0x8(%ebp),%eax
801020d0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020d4:	66 83 f8 03          	cmp    $0x3,%ax
801020d8:	75 60                	jne    8010213a <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020da:	8b 45 08             	mov    0x8(%ebp),%eax
801020dd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020e1:	66 85 c0             	test   %ax,%ax
801020e4:	78 20                	js     80102106 <readi+0x40>
801020e6:	8b 45 08             	mov    0x8(%ebp),%eax
801020e9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ed:	66 83 f8 09          	cmp    $0x9,%ax
801020f1:	7f 13                	jg     80102106 <readi+0x40>
801020f3:	8b 45 08             	mov    0x8(%ebp),%eax
801020f6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020fa:	98                   	cwtl   
801020fb:	8b 04 c5 20 f8 10 80 	mov    -0x7fef07e0(,%eax,8),%eax
80102102:	85 c0                	test   %eax,%eax
80102104:	75 0a                	jne    80102110 <readi+0x4a>
      return -1;
80102106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010210b:	e9 1b 01 00 00       	jmp    8010222b <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80102110:	8b 45 08             	mov    0x8(%ebp),%eax
80102113:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102117:	98                   	cwtl   
80102118:	8b 14 c5 20 f8 10 80 	mov    -0x7fef07e0(,%eax,8),%edx
8010211f:	8b 45 14             	mov    0x14(%ebp),%eax
80102122:	89 44 24 08          	mov    %eax,0x8(%esp)
80102126:	8b 45 0c             	mov    0xc(%ebp),%eax
80102129:	89 44 24 04          	mov    %eax,0x4(%esp)
8010212d:	8b 45 08             	mov    0x8(%ebp),%eax
80102130:	89 04 24             	mov    %eax,(%esp)
80102133:	ff d2                	call   *%edx
80102135:	e9 f1 00 00 00       	jmp    8010222b <readi+0x165>
  }

  if(off > ip->size || off + n < off)
8010213a:	8b 45 08             	mov    0x8(%ebp),%eax
8010213d:	8b 40 18             	mov    0x18(%eax),%eax
80102140:	3b 45 10             	cmp    0x10(%ebp),%eax
80102143:	72 0d                	jb     80102152 <readi+0x8c>
80102145:	8b 45 14             	mov    0x14(%ebp),%eax
80102148:	8b 55 10             	mov    0x10(%ebp),%edx
8010214b:	01 d0                	add    %edx,%eax
8010214d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102150:	73 0a                	jae    8010215c <readi+0x96>
    return -1;
80102152:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102157:	e9 cf 00 00 00       	jmp    8010222b <readi+0x165>
  if(off + n > ip->size)
8010215c:	8b 45 14             	mov    0x14(%ebp),%eax
8010215f:	8b 55 10             	mov    0x10(%ebp),%edx
80102162:	01 c2                	add    %eax,%edx
80102164:	8b 45 08             	mov    0x8(%ebp),%eax
80102167:	8b 40 18             	mov    0x18(%eax),%eax
8010216a:	39 c2                	cmp    %eax,%edx
8010216c:	76 0c                	jbe    8010217a <readi+0xb4>
    n = ip->size - off;
8010216e:	8b 45 08             	mov    0x8(%ebp),%eax
80102171:	8b 40 18             	mov    0x18(%eax),%eax
80102174:	2b 45 10             	sub    0x10(%ebp),%eax
80102177:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010217a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102181:	e9 96 00 00 00       	jmp    8010221c <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102186:	8b 45 10             	mov    0x10(%ebp),%eax
80102189:	c1 e8 09             	shr    $0x9,%eax
8010218c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	89 04 24             	mov    %eax,(%esp)
80102196:	e8 d7 fc ff ff       	call   80101e72 <bmap>
8010219b:	8b 55 08             	mov    0x8(%ebp),%edx
8010219e:	8b 12                	mov    (%edx),%edx
801021a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a4:	89 14 24             	mov    %edx,(%esp)
801021a7:	e8 fa df ff ff       	call   801001a6 <bread>
801021ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021af:	8b 45 10             	mov    0x10(%ebp),%eax
801021b2:	89 c2                	mov    %eax,%edx
801021b4:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801021ba:	b8 00 02 00 00       	mov    $0x200,%eax
801021bf:	89 c1                	mov    %eax,%ecx
801021c1:	29 d1                	sub    %edx,%ecx
801021c3:	89 ca                	mov    %ecx,%edx
801021c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
801021cb:	89 cb                	mov    %ecx,%ebx
801021cd:	29 c3                	sub    %eax,%ebx
801021cf:	89 d8                	mov    %ebx,%eax
801021d1:	39 c2                	cmp    %eax,%edx
801021d3:	0f 46 c2             	cmovbe %edx,%eax
801021d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801021d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021dc:	8d 50 18             	lea    0x18(%eax),%edx
801021df:	8b 45 10             	mov    0x10(%ebp),%eax
801021e2:	25 ff 01 00 00       	and    $0x1ff,%eax
801021e7:	01 c2                	add    %eax,%edx
801021e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ec:	89 44 24 08          	mov    %eax,0x8(%esp)
801021f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801021f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801021f7:	89 04 24             	mov    %eax,(%esp)
801021fa:	e8 8e 34 00 00       	call   8010568d <memmove>
    brelse(bp);
801021ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102202:	89 04 24             	mov    %eax,(%esp)
80102205:	e8 0d e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010220a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010220d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102213:	01 45 10             	add    %eax,0x10(%ebp)
80102216:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102219:	01 45 0c             	add    %eax,0xc(%ebp)
8010221c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010221f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102222:	0f 82 5e ff ff ff    	jb     80102186 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102228:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010222b:	83 c4 24             	add    $0x24,%esp
8010222e:	5b                   	pop    %ebx
8010222f:	5d                   	pop    %ebp
80102230:	c3                   	ret    

80102231 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102231:	55                   	push   %ebp
80102232:	89 e5                	mov    %esp,%ebp
80102234:	53                   	push   %ebx
80102235:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102238:	8b 45 08             	mov    0x8(%ebp),%eax
8010223b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010223f:	66 83 f8 03          	cmp    $0x3,%ax
80102243:	75 60                	jne    801022a5 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102245:	8b 45 08             	mov    0x8(%ebp),%eax
80102248:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010224c:	66 85 c0             	test   %ax,%ax
8010224f:	78 20                	js     80102271 <writei+0x40>
80102251:	8b 45 08             	mov    0x8(%ebp),%eax
80102254:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102258:	66 83 f8 09          	cmp    $0x9,%ax
8010225c:	7f 13                	jg     80102271 <writei+0x40>
8010225e:	8b 45 08             	mov    0x8(%ebp),%eax
80102261:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102265:	98                   	cwtl   
80102266:	8b 04 c5 24 f8 10 80 	mov    -0x7fef07dc(,%eax,8),%eax
8010226d:	85 c0                	test   %eax,%eax
8010226f:	75 0a                	jne    8010227b <writei+0x4a>
      return -1;
80102271:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102276:	e9 46 01 00 00       	jmp    801023c1 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
8010227b:	8b 45 08             	mov    0x8(%ebp),%eax
8010227e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102282:	98                   	cwtl   
80102283:	8b 14 c5 24 f8 10 80 	mov    -0x7fef07dc(,%eax,8),%edx
8010228a:	8b 45 14             	mov    0x14(%ebp),%eax
8010228d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102291:	8b 45 0c             	mov    0xc(%ebp),%eax
80102294:	89 44 24 04          	mov    %eax,0x4(%esp)
80102298:	8b 45 08             	mov    0x8(%ebp),%eax
8010229b:	89 04 24             	mov    %eax,(%esp)
8010229e:	ff d2                	call   *%edx
801022a0:	e9 1c 01 00 00       	jmp    801023c1 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	8b 40 18             	mov    0x18(%eax),%eax
801022ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801022ae:	72 0d                	jb     801022bd <writei+0x8c>
801022b0:	8b 45 14             	mov    0x14(%ebp),%eax
801022b3:	8b 55 10             	mov    0x10(%ebp),%edx
801022b6:	01 d0                	add    %edx,%eax
801022b8:	3b 45 10             	cmp    0x10(%ebp),%eax
801022bb:	73 0a                	jae    801022c7 <writei+0x96>
    return -1;
801022bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c2:	e9 fa 00 00 00       	jmp    801023c1 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
801022c7:	8b 45 14             	mov    0x14(%ebp),%eax
801022ca:	8b 55 10             	mov    0x10(%ebp),%edx
801022cd:	01 d0                	add    %edx,%eax
801022cf:	3d 00 18 01 00       	cmp    $0x11800,%eax
801022d4:	76 0a                	jbe    801022e0 <writei+0xaf>
    return -1;
801022d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022db:	e9 e1 00 00 00       	jmp    801023c1 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022e7:	e9 a1 00 00 00       	jmp    8010238d <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022ec:	8b 45 10             	mov    0x10(%ebp),%eax
801022ef:	c1 e8 09             	shr    $0x9,%eax
801022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f6:	8b 45 08             	mov    0x8(%ebp),%eax
801022f9:	89 04 24             	mov    %eax,(%esp)
801022fc:	e8 71 fb ff ff       	call   80101e72 <bmap>
80102301:	8b 55 08             	mov    0x8(%ebp),%edx
80102304:	8b 12                	mov    (%edx),%edx
80102306:	89 44 24 04          	mov    %eax,0x4(%esp)
8010230a:	89 14 24             	mov    %edx,(%esp)
8010230d:	e8 94 de ff ff       	call   801001a6 <bread>
80102312:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102315:	8b 45 10             	mov    0x10(%ebp),%eax
80102318:	89 c2                	mov    %eax,%edx
8010231a:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102320:	b8 00 02 00 00       	mov    $0x200,%eax
80102325:	89 c1                	mov    %eax,%ecx
80102327:	29 d1                	sub    %edx,%ecx
80102329:	89 ca                	mov    %ecx,%edx
8010232b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232e:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102331:	89 cb                	mov    %ecx,%ebx
80102333:	29 c3                	sub    %eax,%ebx
80102335:	89 d8                	mov    %ebx,%eax
80102337:	39 c2                	cmp    %eax,%edx
80102339:	0f 46 c2             	cmovbe %edx,%eax
8010233c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010233f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102342:	8d 50 18             	lea    0x18(%eax),%edx
80102345:	8b 45 10             	mov    0x10(%ebp),%eax
80102348:	25 ff 01 00 00       	and    $0x1ff,%eax
8010234d:	01 c2                	add    %eax,%edx
8010234f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102352:	89 44 24 08          	mov    %eax,0x8(%esp)
80102356:	8b 45 0c             	mov    0xc(%ebp),%eax
80102359:	89 44 24 04          	mov    %eax,0x4(%esp)
8010235d:	89 14 24             	mov    %edx,(%esp)
80102360:	e8 28 33 00 00       	call   8010568d <memmove>
    log_write(bp);
80102365:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102368:	89 04 24             	mov    %eax,(%esp)
8010236b:	e8 b6 12 00 00       	call   80103626 <log_write>
    brelse(bp);
80102370:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102373:	89 04 24             	mov    %eax,(%esp)
80102376:	e8 9c de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010237b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010237e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102381:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102384:	01 45 10             	add    %eax,0x10(%ebp)
80102387:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010238a:	01 45 0c             	add    %eax,0xc(%ebp)
8010238d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102390:	3b 45 14             	cmp    0x14(%ebp),%eax
80102393:	0f 82 53 ff ff ff    	jb     801022ec <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102399:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010239d:	74 1f                	je     801023be <writei+0x18d>
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	8b 40 18             	mov    0x18(%eax),%eax
801023a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801023a8:	73 14                	jae    801023be <writei+0x18d>
    ip->size = off;
801023aa:	8b 45 08             	mov    0x8(%ebp),%eax
801023ad:	8b 55 10             	mov    0x10(%ebp),%edx
801023b0:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801023b3:	8b 45 08             	mov    0x8(%ebp),%eax
801023b6:	89 04 24             	mov    %eax,(%esp)
801023b9:	e8 56 f6 ff ff       	call   80101a14 <iupdate>
  }
  return n;
801023be:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023c1:	83 c4 24             	add    $0x24,%esp
801023c4:	5b                   	pop    %ebx
801023c5:	5d                   	pop    %ebp
801023c6:	c3                   	ret    

801023c7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801023c7:	55                   	push   %ebp
801023c8:	89 e5                	mov    %esp,%ebp
801023ca:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801023cd:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023d4:	00 
801023d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801023dc:	8b 45 08             	mov    0x8(%ebp),%eax
801023df:	89 04 24             	mov    %eax,(%esp)
801023e2:	e8 4a 33 00 00       	call   80105731 <strncmp>
}
801023e7:	c9                   	leave  
801023e8:	c3                   	ret    

801023e9 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023e9:	55                   	push   %ebp
801023ea:	89 e5                	mov    %esp,%ebp
801023ec:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023f6:	66 83 f8 01          	cmp    $0x1,%ax
801023fa:	74 0c                	je     80102408 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801023fc:	c7 04 24 39 8b 10 80 	movl   $0x80108b39,(%esp)
80102403:	e8 35 e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102408:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010240f:	e9 87 00 00 00       	jmp    8010249b <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102414:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010241b:	00 
8010241c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102423:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102426:	89 44 24 04          	mov    %eax,0x4(%esp)
8010242a:	8b 45 08             	mov    0x8(%ebp),%eax
8010242d:	89 04 24             	mov    %eax,(%esp)
80102430:	e8 91 fc ff ff       	call   801020c6 <readi>
80102435:	83 f8 10             	cmp    $0x10,%eax
80102438:	74 0c                	je     80102446 <dirlookup+0x5d>
      panic("dirlink read");
8010243a:	c7 04 24 4b 8b 10 80 	movl   $0x80108b4b,(%esp)
80102441:	e8 f7 e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102446:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010244a:	66 85 c0             	test   %ax,%ax
8010244d:	74 47                	je     80102496 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010244f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102452:	83 c0 02             	add    $0x2,%eax
80102455:	89 44 24 04          	mov    %eax,0x4(%esp)
80102459:	8b 45 0c             	mov    0xc(%ebp),%eax
8010245c:	89 04 24             	mov    %eax,(%esp)
8010245f:	e8 63 ff ff ff       	call   801023c7 <namecmp>
80102464:	85 c0                	test   %eax,%eax
80102466:	75 2f                	jne    80102497 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102468:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010246c:	74 08                	je     80102476 <dirlookup+0x8d>
        *poff = off;
8010246e:	8b 45 10             	mov    0x10(%ebp),%eax
80102471:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102474:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102476:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010247a:	0f b7 c0             	movzwl %ax,%eax
8010247d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102480:	8b 45 08             	mov    0x8(%ebp),%eax
80102483:	8b 00                	mov    (%eax),%eax
80102485:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102488:	89 54 24 04          	mov    %edx,0x4(%esp)
8010248c:	89 04 24             	mov    %eax,(%esp)
8010248f:	e8 38 f6 ff ff       	call   80101acc <iget>
80102494:	eb 19                	jmp    801024af <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102496:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102497:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010249b:	8b 45 08             	mov    0x8(%ebp),%eax
8010249e:	8b 40 18             	mov    0x18(%eax),%eax
801024a1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801024a4:	0f 87 6a ff ff ff    	ja     80102414 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801024aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024af:	c9                   	leave  
801024b0:	c3                   	ret    

801024b1 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801024b1:	55                   	push   %ebp
801024b2:	89 e5                	mov    %esp,%ebp
801024b4:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801024b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024be:	00 
801024bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801024c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801024c6:	8b 45 08             	mov    0x8(%ebp),%eax
801024c9:	89 04 24             	mov    %eax,(%esp)
801024cc:	e8 18 ff ff ff       	call   801023e9 <dirlookup>
801024d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024d8:	74 15                	je     801024ef <dirlink+0x3e>
    iput(ip);
801024da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dd:	89 04 24             	mov    %eax,(%esp)
801024e0:	e8 9e f8 ff ff       	call   80101d83 <iput>
    return -1;
801024e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024ea:	e9 b8 00 00 00       	jmp    801025a7 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024f6:	eb 44                	jmp    8010253c <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024fb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102502:	00 
80102503:	89 44 24 08          	mov    %eax,0x8(%esp)
80102507:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010250a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010250e:	8b 45 08             	mov    0x8(%ebp),%eax
80102511:	89 04 24             	mov    %eax,(%esp)
80102514:	e8 ad fb ff ff       	call   801020c6 <readi>
80102519:	83 f8 10             	cmp    $0x10,%eax
8010251c:	74 0c                	je     8010252a <dirlink+0x79>
      panic("dirlink read");
8010251e:	c7 04 24 4b 8b 10 80 	movl   $0x80108b4b,(%esp)
80102525:	e8 13 e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
8010252a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010252e:	66 85 c0             	test   %ax,%ax
80102531:	74 18                	je     8010254b <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102536:	83 c0 10             	add    $0x10,%eax
80102539:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010253c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010253f:	8b 45 08             	mov    0x8(%ebp),%eax
80102542:	8b 40 18             	mov    0x18(%eax),%eax
80102545:	39 c2                	cmp    %eax,%edx
80102547:	72 af                	jb     801024f8 <dirlink+0x47>
80102549:	eb 01                	jmp    8010254c <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010254b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010254c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102553:	00 
80102554:	8b 45 0c             	mov    0xc(%ebp),%eax
80102557:	89 44 24 04          	mov    %eax,0x4(%esp)
8010255b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010255e:	83 c0 02             	add    $0x2,%eax
80102561:	89 04 24             	mov    %eax,(%esp)
80102564:	e8 20 32 00 00       	call   80105789 <strncpy>
  de.inum = inum;
80102569:	8b 45 10             	mov    0x10(%ebp),%eax
8010256c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102573:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010257a:	00 
8010257b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010257f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102582:	89 44 24 04          	mov    %eax,0x4(%esp)
80102586:	8b 45 08             	mov    0x8(%ebp),%eax
80102589:	89 04 24             	mov    %eax,(%esp)
8010258c:	e8 a0 fc ff ff       	call   80102231 <writei>
80102591:	83 f8 10             	cmp    $0x10,%eax
80102594:	74 0c                	je     801025a2 <dirlink+0xf1>
    panic("dirlink");
80102596:	c7 04 24 58 8b 10 80 	movl   $0x80108b58,(%esp)
8010259d:	e8 9b df ff ff       	call   8010053d <panic>
  
  return 0;
801025a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025a7:	c9                   	leave  
801025a8:	c3                   	ret    

801025a9 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801025a9:	55                   	push   %ebp
801025aa:	89 e5                	mov    %esp,%ebp
801025ac:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801025af:	eb 04                	jmp    801025b5 <skipelem+0xc>
    path++;
801025b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801025b5:	8b 45 08             	mov    0x8(%ebp),%eax
801025b8:	0f b6 00             	movzbl (%eax),%eax
801025bb:	3c 2f                	cmp    $0x2f,%al
801025bd:	74 f2                	je     801025b1 <skipelem+0x8>
    path++;
  if(*path == 0)
801025bf:	8b 45 08             	mov    0x8(%ebp),%eax
801025c2:	0f b6 00             	movzbl (%eax),%eax
801025c5:	84 c0                	test   %al,%al
801025c7:	75 0a                	jne    801025d3 <skipelem+0x2a>
    return 0;
801025c9:	b8 00 00 00 00       	mov    $0x0,%eax
801025ce:	e9 86 00 00 00       	jmp    80102659 <skipelem+0xb0>
  s = path;
801025d3:	8b 45 08             	mov    0x8(%ebp),%eax
801025d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801025d9:	eb 04                	jmp    801025df <skipelem+0x36>
    path++;
801025db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801025df:	8b 45 08             	mov    0x8(%ebp),%eax
801025e2:	0f b6 00             	movzbl (%eax),%eax
801025e5:	3c 2f                	cmp    $0x2f,%al
801025e7:	74 0a                	je     801025f3 <skipelem+0x4a>
801025e9:	8b 45 08             	mov    0x8(%ebp),%eax
801025ec:	0f b6 00             	movzbl (%eax),%eax
801025ef:	84 c0                	test   %al,%al
801025f1:	75 e8                	jne    801025db <skipelem+0x32>
    path++;
  len = path - s;
801025f3:	8b 55 08             	mov    0x8(%ebp),%edx
801025f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f9:	89 d1                	mov    %edx,%ecx
801025fb:	29 c1                	sub    %eax,%ecx
801025fd:	89 c8                	mov    %ecx,%eax
801025ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102602:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102606:	7e 1c                	jle    80102624 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
80102608:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010260f:	00 
80102610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102613:	89 44 24 04          	mov    %eax,0x4(%esp)
80102617:	8b 45 0c             	mov    0xc(%ebp),%eax
8010261a:	89 04 24             	mov    %eax,(%esp)
8010261d:	e8 6b 30 00 00       	call   8010568d <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102622:	eb 28                	jmp    8010264c <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102627:	89 44 24 08          	mov    %eax,0x8(%esp)
8010262b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102632:	8b 45 0c             	mov    0xc(%ebp),%eax
80102635:	89 04 24             	mov    %eax,(%esp)
80102638:	e8 50 30 00 00       	call   8010568d <memmove>
    name[len] = 0;
8010263d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102640:	03 45 0c             	add    0xc(%ebp),%eax
80102643:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102646:	eb 04                	jmp    8010264c <skipelem+0xa3>
    path++;
80102648:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010264c:	8b 45 08             	mov    0x8(%ebp),%eax
8010264f:	0f b6 00             	movzbl (%eax),%eax
80102652:	3c 2f                	cmp    $0x2f,%al
80102654:	74 f2                	je     80102648 <skipelem+0x9f>
    path++;
  return path;
80102656:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102659:	c9                   	leave  
8010265a:	c3                   	ret    

8010265b <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010265b:	55                   	push   %ebp
8010265c:	89 e5                	mov    %esp,%ebp
8010265e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102661:	8b 45 08             	mov    0x8(%ebp),%eax
80102664:	0f b6 00             	movzbl (%eax),%eax
80102667:	3c 2f                	cmp    $0x2f,%al
80102669:	75 1c                	jne    80102687 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010266b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102672:	00 
80102673:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010267a:	e8 4d f4 ff ff       	call   80101acc <iget>
8010267f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102682:	e9 af 00 00 00       	jmp    80102736 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102687:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010268d:	8b 40 68             	mov    0x68(%eax),%eax
80102690:	89 04 24             	mov    %eax,(%esp)
80102693:	e8 06 f5 ff ff       	call   80101b9e <idup>
80102698:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010269b:	e9 96 00 00 00       	jmp    80102736 <namex+0xdb>
    ilock(ip);
801026a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a3:	89 04 24             	mov    %eax,(%esp)
801026a6:	e8 25 f5 ff ff       	call   80101bd0 <ilock>
    if(ip->type != T_DIR){
801026ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801026b2:	66 83 f8 01          	cmp    $0x1,%ax
801026b6:	74 15                	je     801026cd <namex+0x72>
      iunlockput(ip);
801026b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026bb:	89 04 24             	mov    %eax,(%esp)
801026be:	e8 91 f7 ff ff       	call   80101e54 <iunlockput>
      return 0;
801026c3:	b8 00 00 00 00       	mov    $0x0,%eax
801026c8:	e9 a3 00 00 00       	jmp    80102770 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801026cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026d1:	74 1d                	je     801026f0 <namex+0x95>
801026d3:	8b 45 08             	mov    0x8(%ebp),%eax
801026d6:	0f b6 00             	movzbl (%eax),%eax
801026d9:	84 c0                	test   %al,%al
801026db:	75 13                	jne    801026f0 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801026dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e0:	89 04 24             	mov    %eax,(%esp)
801026e3:	e8 36 f6 ff ff       	call   80101d1e <iunlock>
      return ip;
801026e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026eb:	e9 80 00 00 00       	jmp    80102770 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026f7:	00 
801026f8:	8b 45 10             	mov    0x10(%ebp),%eax
801026fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102702:	89 04 24             	mov    %eax,(%esp)
80102705:	e8 df fc ff ff       	call   801023e9 <dirlookup>
8010270a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010270d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102711:	75 12                	jne    80102725 <namex+0xca>
      iunlockput(ip);
80102713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102716:	89 04 24             	mov    %eax,(%esp)
80102719:	e8 36 f7 ff ff       	call   80101e54 <iunlockput>
      return 0;
8010271e:	b8 00 00 00 00       	mov    $0x0,%eax
80102723:	eb 4b                	jmp    80102770 <namex+0x115>
    }
    iunlockput(ip);
80102725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102728:	89 04 24             	mov    %eax,(%esp)
8010272b:	e8 24 f7 ff ff       	call   80101e54 <iunlockput>
    ip = next;
80102730:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102733:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102736:	8b 45 10             	mov    0x10(%ebp),%eax
80102739:	89 44 24 04          	mov    %eax,0x4(%esp)
8010273d:	8b 45 08             	mov    0x8(%ebp),%eax
80102740:	89 04 24             	mov    %eax,(%esp)
80102743:	e8 61 fe ff ff       	call   801025a9 <skipelem>
80102748:	89 45 08             	mov    %eax,0x8(%ebp)
8010274b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010274f:	0f 85 4b ff ff ff    	jne    801026a0 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102755:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102759:	74 12                	je     8010276d <namex+0x112>
    iput(ip);
8010275b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010275e:	89 04 24             	mov    %eax,(%esp)
80102761:	e8 1d f6 ff ff       	call   80101d83 <iput>
    return 0;
80102766:	b8 00 00 00 00       	mov    $0x0,%eax
8010276b:	eb 03                	jmp    80102770 <namex+0x115>
  }
  return ip;
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102770:	c9                   	leave  
80102771:	c3                   	ret    

80102772 <namei>:

struct inode*
namei(char *path)
{
80102772:	55                   	push   %ebp
80102773:	89 e5                	mov    %esp,%ebp
80102775:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102778:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010277b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010277f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102786:	00 
80102787:	8b 45 08             	mov    0x8(%ebp),%eax
8010278a:	89 04 24             	mov    %eax,(%esp)
8010278d:	e8 c9 fe ff ff       	call   8010265b <namex>
}
80102792:	c9                   	leave  
80102793:	c3                   	ret    

80102794 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102794:	55                   	push   %ebp
80102795:	89 e5                	mov    %esp,%ebp
80102797:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010279a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010279d:	89 44 24 08          	mov    %eax,0x8(%esp)
801027a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801027a8:	00 
801027a9:	8b 45 08             	mov    0x8(%ebp),%eax
801027ac:	89 04 24             	mov    %eax,(%esp)
801027af:	e8 a7 fe ff ff       	call   8010265b <namex>
}
801027b4:	c9                   	leave  
801027b5:	c3                   	ret    
	...

801027b8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027b8:	55                   	push   %ebp
801027b9:	89 e5                	mov    %esp,%ebp
801027bb:	53                   	push   %ebx
801027bc:	83 ec 14             	sub    $0x14,%esp
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027c6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801027ca:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801027ce:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801027d2:	ec                   	in     (%dx),%al
801027d3:	89 c3                	mov    %eax,%ebx
801027d5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801027d8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801027dc:	83 c4 14             	add    $0x14,%esp
801027df:	5b                   	pop    %ebx
801027e0:	5d                   	pop    %ebp
801027e1:	c3                   	ret    

801027e2 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027e2:	55                   	push   %ebp
801027e3:	89 e5                	mov    %esp,%ebp
801027e5:	57                   	push   %edi
801027e6:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027e7:	8b 55 08             	mov    0x8(%ebp),%edx
801027ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027ed:	8b 45 10             	mov    0x10(%ebp),%eax
801027f0:	89 cb                	mov    %ecx,%ebx
801027f2:	89 df                	mov    %ebx,%edi
801027f4:	89 c1                	mov    %eax,%ecx
801027f6:	fc                   	cld    
801027f7:	f3 6d                	rep insl (%dx),%es:(%edi)
801027f9:	89 c8                	mov    %ecx,%eax
801027fb:	89 fb                	mov    %edi,%ebx
801027fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102800:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102803:	5b                   	pop    %ebx
80102804:	5f                   	pop    %edi
80102805:	5d                   	pop    %ebp
80102806:	c3                   	ret    

80102807 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102807:	55                   	push   %ebp
80102808:	89 e5                	mov    %esp,%ebp
8010280a:	83 ec 08             	sub    $0x8,%esp
8010280d:	8b 55 08             	mov    0x8(%ebp),%edx
80102810:	8b 45 0c             	mov    0xc(%ebp),%eax
80102813:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102817:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010281a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010281e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102822:	ee                   	out    %al,(%dx)
}
80102823:	c9                   	leave  
80102824:	c3                   	ret    

80102825 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102825:	55                   	push   %ebp
80102826:	89 e5                	mov    %esp,%ebp
80102828:	56                   	push   %esi
80102829:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010282a:	8b 55 08             	mov    0x8(%ebp),%edx
8010282d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102830:	8b 45 10             	mov    0x10(%ebp),%eax
80102833:	89 cb                	mov    %ecx,%ebx
80102835:	89 de                	mov    %ebx,%esi
80102837:	89 c1                	mov    %eax,%ecx
80102839:	fc                   	cld    
8010283a:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010283c:	89 c8                	mov    %ecx,%eax
8010283e:	89 f3                	mov    %esi,%ebx
80102840:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102843:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102846:	5b                   	pop    %ebx
80102847:	5e                   	pop    %esi
80102848:	5d                   	pop    %ebp
80102849:	c3                   	ret    

8010284a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010284a:	55                   	push   %ebp
8010284b:	89 e5                	mov    %esp,%ebp
8010284d:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102850:	90                   	nop
80102851:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102858:	e8 5b ff ff ff       	call   801027b8 <inb>
8010285d:	0f b6 c0             	movzbl %al,%eax
80102860:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102863:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102866:	25 c0 00 00 00       	and    $0xc0,%eax
8010286b:	83 f8 40             	cmp    $0x40,%eax
8010286e:	75 e1                	jne    80102851 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102870:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102874:	74 11                	je     80102887 <idewait+0x3d>
80102876:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102879:	83 e0 21             	and    $0x21,%eax
8010287c:	85 c0                	test   %eax,%eax
8010287e:	74 07                	je     80102887 <idewait+0x3d>
    return -1;
80102880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102885:	eb 05                	jmp    8010288c <idewait+0x42>
  return 0;
80102887:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010288c:	c9                   	leave  
8010288d:	c3                   	ret    

8010288e <ideinit>:

void
ideinit(void)
{
8010288e:	55                   	push   %ebp
8010288f:	89 e5                	mov    %esp,%ebp
80102891:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102894:	c7 44 24 04 60 8b 10 	movl   $0x80108b60,0x4(%esp)
8010289b:	80 
8010289c:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801028a3:	e8 a2 2a 00 00       	call   8010534a <initlock>
  picenable(IRQ_IDE);
801028a8:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028af:	e8 75 15 00 00       	call   80103e29 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028b4:	a1 20 0f 11 80       	mov    0x80110f20,%eax
801028b9:	83 e8 01             	sub    $0x1,%eax
801028bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801028c0:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028c7:	e8 12 04 00 00       	call   80102cde <ioapicenable>
  idewait(0);
801028cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028d3:	e8 72 ff ff ff       	call   8010284a <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801028d8:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028df:	00 
801028e0:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028e7:	e8 1b ff ff ff       	call   80102807 <outb>
  for(i=0; i<1000; i++){
801028ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028f3:	eb 20                	jmp    80102915 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028f5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028fc:	e8 b7 fe ff ff       	call   801027b8 <inb>
80102901:	84 c0                	test   %al,%al
80102903:	74 0c                	je     80102911 <ideinit+0x83>
      havedisk1 = 1;
80102905:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
8010290c:	00 00 00 
      break;
8010290f:	eb 0d                	jmp    8010291e <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102911:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102915:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010291c:	7e d7                	jle    801028f5 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010291e:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102925:	00 
80102926:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010292d:	e8 d5 fe ff ff       	call   80102807 <outb>
}
80102932:	c9                   	leave  
80102933:	c3                   	ret    

80102934 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102934:	55                   	push   %ebp
80102935:	89 e5                	mov    %esp,%ebp
80102937:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010293a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010293e:	75 0c                	jne    8010294c <idestart+0x18>
    panic("idestart");
80102940:	c7 04 24 64 8b 10 80 	movl   $0x80108b64,(%esp)
80102947:	e8 f1 db ff ff       	call   8010053d <panic>

  idewait(0);
8010294c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102953:	e8 f2 fe ff ff       	call   8010284a <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102958:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010295f:	00 
80102960:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102967:	e8 9b fe ff ff       	call   80102807 <outb>
  outb(0x1f2, 1);  // number of sectors
8010296c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102973:	00 
80102974:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010297b:	e8 87 fe ff ff       	call   80102807 <outb>
  outb(0x1f3, b->sector & 0xff);
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	8b 40 08             	mov    0x8(%eax),%eax
80102986:	0f b6 c0             	movzbl %al,%eax
80102989:	89 44 24 04          	mov    %eax,0x4(%esp)
8010298d:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102994:	e8 6e fe ff ff       	call   80102807 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102999:	8b 45 08             	mov    0x8(%ebp),%eax
8010299c:	8b 40 08             	mov    0x8(%eax),%eax
8010299f:	c1 e8 08             	shr    $0x8,%eax
801029a2:	0f b6 c0             	movzbl %al,%eax
801029a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029a9:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029b0:	e8 52 fe ff ff       	call   80102807 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801029b5:	8b 45 08             	mov    0x8(%ebp),%eax
801029b8:	8b 40 08             	mov    0x8(%eax),%eax
801029bb:	c1 e8 10             	shr    $0x10,%eax
801029be:	0f b6 c0             	movzbl %al,%eax
801029c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029cc:	e8 36 fe ff ff       	call   80102807 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801029d1:	8b 45 08             	mov    0x8(%ebp),%eax
801029d4:	8b 40 04             	mov    0x4(%eax),%eax
801029d7:	83 e0 01             	and    $0x1,%eax
801029da:	89 c2                	mov    %eax,%edx
801029dc:	c1 e2 04             	shl    $0x4,%edx
801029df:	8b 45 08             	mov    0x8(%ebp),%eax
801029e2:	8b 40 08             	mov    0x8(%eax),%eax
801029e5:	c1 e8 18             	shr    $0x18,%eax
801029e8:	83 e0 0f             	and    $0xf,%eax
801029eb:	09 d0                	or     %edx,%eax
801029ed:	83 c8 e0             	or     $0xffffffe0,%eax
801029f0:	0f b6 c0             	movzbl %al,%eax
801029f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029fe:	e8 04 fe ff ff       	call   80102807 <outb>
  if(b->flags & B_DIRTY){
80102a03:	8b 45 08             	mov    0x8(%ebp),%eax
80102a06:	8b 00                	mov    (%eax),%eax
80102a08:	83 e0 04             	and    $0x4,%eax
80102a0b:	85 c0                	test   %eax,%eax
80102a0d:	74 34                	je     80102a43 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102a0f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102a16:	00 
80102a17:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a1e:	e8 e4 fd ff ff       	call   80102807 <outb>
    outsl(0x1f0, b->data, 512/4);
80102a23:	8b 45 08             	mov    0x8(%ebp),%eax
80102a26:	83 c0 18             	add    $0x18,%eax
80102a29:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a30:	00 
80102a31:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a35:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a3c:	e8 e4 fd ff ff       	call   80102825 <outsl>
80102a41:	eb 14                	jmp    80102a57 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a43:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a4a:	00 
80102a4b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a52:	e8 b0 fd ff ff       	call   80102807 <outb>
  }
}
80102a57:	c9                   	leave  
80102a58:	c3                   	ret    

80102a59 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a59:	55                   	push   %ebp
80102a5a:	89 e5                	mov    %esp,%ebp
80102a5c:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a5f:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102a66:	e8 00 29 00 00       	call   8010536b <acquire>
  if((b = idequeue) == 0){
80102a6b:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a77:	75 11                	jne    80102a8a <ideintr+0x31>
    release(&idelock);
80102a79:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102a80:	e8 48 29 00 00       	call   801053cd <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a85:	e9 90 00 00 00       	jmp    80102b1a <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8d:	8b 40 14             	mov    0x14(%eax),%eax
80102a90:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a98:	8b 00                	mov    (%eax),%eax
80102a9a:	83 e0 04             	and    $0x4,%eax
80102a9d:	85 c0                	test   %eax,%eax
80102a9f:	75 2e                	jne    80102acf <ideintr+0x76>
80102aa1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102aa8:	e8 9d fd ff ff       	call   8010284a <idewait>
80102aad:	85 c0                	test   %eax,%eax
80102aaf:	78 1e                	js     80102acf <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab4:	83 c0 18             	add    $0x18,%eax
80102ab7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102abe:	00 
80102abf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac3:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102aca:	e8 13 fd ff ff       	call   801027e2 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad2:	8b 00                	mov    (%eax),%eax
80102ad4:	89 c2                	mov    %eax,%edx
80102ad6:	83 ca 02             	or     $0x2,%edx
80102ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adc:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	8b 00                	mov    (%eax),%eax
80102ae3:	89 c2                	mov    %eax,%edx
80102ae5:	83 e2 fb             	and    $0xfffffffb,%edx
80102ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aeb:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af0:	89 04 24             	mov    %eax,(%esp)
80102af3:	e8 27 26 00 00       	call   8010511f <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102af8:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102afd:	85 c0                	test   %eax,%eax
80102aff:	74 0d                	je     80102b0e <ideintr+0xb5>
    idestart(idequeue);
80102b01:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b06:	89 04 24             	mov    %eax,(%esp)
80102b09:	e8 26 fe ff ff       	call   80102934 <idestart>

  release(&idelock);
80102b0e:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102b15:	e8 b3 28 00 00       	call   801053cd <release>
}
80102b1a:	c9                   	leave  
80102b1b:	c3                   	ret    

80102b1c <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
80102b1f:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102b22:	8b 45 08             	mov    0x8(%ebp),%eax
80102b25:	8b 00                	mov    (%eax),%eax
80102b27:	83 e0 01             	and    $0x1,%eax
80102b2a:	85 c0                	test   %eax,%eax
80102b2c:	75 0c                	jne    80102b3a <iderw+0x1e>
    panic("iderw: buf not busy");
80102b2e:	c7 04 24 6d 8b 10 80 	movl   $0x80108b6d,(%esp)
80102b35:	e8 03 da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3d:	8b 00                	mov    (%eax),%eax
80102b3f:	83 e0 06             	and    $0x6,%eax
80102b42:	83 f8 02             	cmp    $0x2,%eax
80102b45:	75 0c                	jne    80102b53 <iderw+0x37>
    panic("iderw: nothing to do");
80102b47:	c7 04 24 81 8b 10 80 	movl   $0x80108b81,(%esp)
80102b4e:	e8 ea d9 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102b53:	8b 45 08             	mov    0x8(%ebp),%eax
80102b56:	8b 40 04             	mov    0x4(%eax),%eax
80102b59:	85 c0                	test   %eax,%eax
80102b5b:	74 15                	je     80102b72 <iderw+0x56>
80102b5d:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b62:	85 c0                	test   %eax,%eax
80102b64:	75 0c                	jne    80102b72 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b66:	c7 04 24 96 8b 10 80 	movl   $0x80108b96,(%esp)
80102b6d:	e8 cb d9 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b72:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102b79:	e8 ed 27 00 00       	call   8010536b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b81:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b88:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b8f:	eb 0b                	jmp    80102b9c <iderw+0x80>
80102b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b94:	8b 00                	mov    (%eax),%eax
80102b96:	83 c0 14             	add    $0x14,%eax
80102b99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9f:	8b 00                	mov    (%eax),%eax
80102ba1:	85 c0                	test   %eax,%eax
80102ba3:	75 ec                	jne    80102b91 <iderw+0x75>
    ;
  *pp = b;
80102ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba8:	8b 55 08             	mov    0x8(%ebp),%edx
80102bab:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102bad:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102bb2:	3b 45 08             	cmp    0x8(%ebp),%eax
80102bb5:	75 22                	jne    80102bd9 <iderw+0xbd>
    idestart(b);
80102bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bba:	89 04 24             	mov    %eax,(%esp)
80102bbd:	e8 72 fd ff ff       	call   80102934 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc2:	eb 15                	jmp    80102bd9 <iderw+0xbd>
    sleep(b, &idelock);
80102bc4:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
80102bcb:	80 
80102bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bcf:	89 04 24             	mov    %eax,(%esp)
80102bd2:	e8 6c 24 00 00       	call   80105043 <sleep>
80102bd7:	eb 01                	jmp    80102bda <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bd9:	90                   	nop
80102bda:	8b 45 08             	mov    0x8(%ebp),%eax
80102bdd:	8b 00                	mov    (%eax),%eax
80102bdf:	83 e0 06             	and    $0x6,%eax
80102be2:	83 f8 02             	cmp    $0x2,%eax
80102be5:	75 dd                	jne    80102bc4 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102be7:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102bee:	e8 da 27 00 00       	call   801053cd <release>
}
80102bf3:	c9                   	leave  
80102bf4:	c3                   	ret    
80102bf5:	00 00                	add    %al,(%eax)
	...

80102bf8 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bf8:	55                   	push   %ebp
80102bf9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bfb:	a1 54 08 11 80       	mov    0x80110854,%eax
80102c00:	8b 55 08             	mov    0x8(%ebp),%edx
80102c03:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c05:	a1 54 08 11 80       	mov    0x80110854,%eax
80102c0a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c0d:	5d                   	pop    %ebp
80102c0e:	c3                   	ret    

80102c0f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c0f:	55                   	push   %ebp
80102c10:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c12:	a1 54 08 11 80       	mov    0x80110854,%eax
80102c17:	8b 55 08             	mov    0x8(%ebp),%edx
80102c1a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c1c:	a1 54 08 11 80       	mov    0x80110854,%eax
80102c21:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c24:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c27:	5d                   	pop    %ebp
80102c28:	c3                   	ret    

80102c29 <ioapicinit>:

void
ioapicinit(void)
{
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
80102c2c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102c2f:	a1 24 09 11 80       	mov    0x80110924,%eax
80102c34:	85 c0                	test   %eax,%eax
80102c36:	0f 84 9f 00 00 00    	je     80102cdb <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c3c:	c7 05 54 08 11 80 00 	movl   $0xfec00000,0x80110854
80102c43:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c4d:	e8 a6 ff ff ff       	call   80102bf8 <ioapicread>
80102c52:	c1 e8 10             	shr    $0x10,%eax
80102c55:	25 ff 00 00 00       	and    $0xff,%eax
80102c5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c64:	e8 8f ff ff ff       	call   80102bf8 <ioapicread>
80102c69:	c1 e8 18             	shr    $0x18,%eax
80102c6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c6f:	0f b6 05 20 09 11 80 	movzbl 0x80110920,%eax
80102c76:	0f b6 c0             	movzbl %al,%eax
80102c79:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c7c:	74 0c                	je     80102c8a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c7e:	c7 04 24 b4 8b 10 80 	movl   $0x80108bb4,(%esp)
80102c85:	e8 17 d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c91:	eb 3e                	jmp    80102cd1 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c96:	83 c0 20             	add    $0x20,%eax
80102c99:	0d 00 00 01 00       	or     $0x10000,%eax
80102c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102ca1:	83 c2 08             	add    $0x8,%edx
80102ca4:	01 d2                	add    %edx,%edx
80102ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
80102caa:	89 14 24             	mov    %edx,(%esp)
80102cad:	e8 5d ff ff ff       	call   80102c0f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb5:	83 c0 08             	add    $0x8,%eax
80102cb8:	01 c0                	add    %eax,%eax
80102cba:	83 c0 01             	add    $0x1,%eax
80102cbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cc4:	00 
80102cc5:	89 04 24             	mov    %eax,(%esp)
80102cc8:	e8 42 ff ff ff       	call   80102c0f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ccd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cd7:	7e ba                	jle    80102c93 <ioapicinit+0x6a>
80102cd9:	eb 01                	jmp    80102cdc <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102cdb:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102cdc:	c9                   	leave  
80102cdd:	c3                   	ret    

80102cde <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cde:	55                   	push   %ebp
80102cdf:	89 e5                	mov    %esp,%ebp
80102ce1:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102ce4:	a1 24 09 11 80       	mov    0x80110924,%eax
80102ce9:	85 c0                	test   %eax,%eax
80102ceb:	74 39                	je     80102d26 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ced:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf0:	83 c0 20             	add    $0x20,%eax
80102cf3:	8b 55 08             	mov    0x8(%ebp),%edx
80102cf6:	83 c2 08             	add    $0x8,%edx
80102cf9:	01 d2                	add    %edx,%edx
80102cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cff:	89 14 24             	mov    %edx,(%esp)
80102d02:	e8 08 ff ff ff       	call   80102c0f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d07:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d0a:	c1 e0 18             	shl    $0x18,%eax
80102d0d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d10:	83 c2 08             	add    $0x8,%edx
80102d13:	01 d2                	add    %edx,%edx
80102d15:	83 c2 01             	add    $0x1,%edx
80102d18:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d1c:	89 14 24             	mov    %edx,(%esp)
80102d1f:	e8 eb fe ff ff       	call   80102c0f <ioapicwrite>
80102d24:	eb 01                	jmp    80102d27 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102d26:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102d27:	c9                   	leave  
80102d28:	c3                   	ret    
80102d29:	00 00                	add    %al,(%eax)
	...

80102d2c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102d2c:	55                   	push   %ebp
80102d2d:	89 e5                	mov    %esp,%ebp
80102d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d32:	05 00 00 00 80       	add    $0x80000000,%eax
80102d37:	5d                   	pop    %ebp
80102d38:	c3                   	ret    

80102d39 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d39:	55                   	push   %ebp
80102d3a:	89 e5                	mov    %esp,%ebp
80102d3c:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d3f:	c7 44 24 04 e6 8b 10 	movl   $0x80108be6,0x4(%esp)
80102d46:	80 
80102d47:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102d4e:	e8 f7 25 00 00       	call   8010534a <initlock>
  kmem.use_lock = 0;
80102d53:	c7 05 94 08 11 80 00 	movl   $0x0,0x80110894
80102d5a:	00 00 00 
  freerange(vstart, vend);
80102d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d60:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d64:	8b 45 08             	mov    0x8(%ebp),%eax
80102d67:	89 04 24             	mov    %eax,(%esp)
80102d6a:	e8 26 00 00 00       	call   80102d95 <freerange>
}
80102d6f:	c9                   	leave  
80102d70:	c3                   	ret    

80102d71 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d71:	55                   	push   %ebp
80102d72:	89 e5                	mov    %esp,%ebp
80102d74:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d77:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d81:	89 04 24             	mov    %eax,(%esp)
80102d84:	e8 0c 00 00 00       	call   80102d95 <freerange>
  kmem.use_lock = 1;
80102d89:	c7 05 94 08 11 80 01 	movl   $0x1,0x80110894
80102d90:	00 00 00 
}
80102d93:	c9                   	leave  
80102d94:	c3                   	ret    

80102d95 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d95:	55                   	push   %ebp
80102d96:	89 e5                	mov    %esp,%ebp
80102d98:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102da3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102da8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102dab:	eb 12                	jmp    80102dbf <freerange+0x2a>
    kfree(p);
80102dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db0:	89 04 24             	mov    %eax,(%esp)
80102db3:	e8 16 00 00 00       	call   80102dce <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102db8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dc2:	05 00 10 00 00       	add    $0x1000,%eax
80102dc7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dca:	76 e1                	jbe    80102dad <freerange+0x18>
    kfree(p);
}
80102dcc:	c9                   	leave  
80102dcd:	c3                   	ret    

80102dce <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dce:	55                   	push   %ebp
80102dcf:	89 e5                	mov    %esp,%ebp
80102dd1:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd7:	25 ff 0f 00 00       	and    $0xfff,%eax
80102ddc:	85 c0                	test   %eax,%eax
80102dde:	75 1b                	jne    80102dfb <kfree+0x2d>
80102de0:	81 7d 08 1c 3d 11 80 	cmpl   $0x80113d1c,0x8(%ebp)
80102de7:	72 12                	jb     80102dfb <kfree+0x2d>
80102de9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dec:	89 04 24             	mov    %eax,(%esp)
80102def:	e8 38 ff ff ff       	call   80102d2c <v2p>
80102df4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102df9:	76 0c                	jbe    80102e07 <kfree+0x39>
    panic("kfree");
80102dfb:	c7 04 24 eb 8b 10 80 	movl   $0x80108beb,(%esp)
80102e02:	e8 36 d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e07:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e0e:	00 
80102e0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e16:	00 
80102e17:	8b 45 08             	mov    0x8(%ebp),%eax
80102e1a:	89 04 24             	mov    %eax,(%esp)
80102e1d:	e8 98 27 00 00       	call   801055ba <memset>

  if(kmem.use_lock)
80102e22:	a1 94 08 11 80       	mov    0x80110894,%eax
80102e27:	85 c0                	test   %eax,%eax
80102e29:	74 0c                	je     80102e37 <kfree+0x69>
    acquire(&kmem.lock);
80102e2b:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102e32:	e8 34 25 00 00       	call   8010536b <acquire>
  r = (struct run*)v;
80102e37:	8b 45 08             	mov    0x8(%ebp),%eax
80102e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e3d:	8b 15 98 08 11 80    	mov    0x80110898,%edx
80102e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e46:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e4b:	a3 98 08 11 80       	mov    %eax,0x80110898
  if(kmem.use_lock)
80102e50:	a1 94 08 11 80       	mov    0x80110894,%eax
80102e55:	85 c0                	test   %eax,%eax
80102e57:	74 0c                	je     80102e65 <kfree+0x97>
    release(&kmem.lock);
80102e59:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102e60:	e8 68 25 00 00       	call   801053cd <release>
}
80102e65:	c9                   	leave  
80102e66:	c3                   	ret    

80102e67 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e67:	55                   	push   %ebp
80102e68:	89 e5                	mov    %esp,%ebp
80102e6a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e6d:	a1 94 08 11 80       	mov    0x80110894,%eax
80102e72:	85 c0                	test   %eax,%eax
80102e74:	74 0c                	je     80102e82 <kalloc+0x1b>
    acquire(&kmem.lock);
80102e76:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102e7d:	e8 e9 24 00 00       	call   8010536b <acquire>
  r = kmem.freelist;
80102e82:	a1 98 08 11 80       	mov    0x80110898,%eax
80102e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e8e:	74 0a                	je     80102e9a <kalloc+0x33>
    kmem.freelist = r->next;
80102e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e93:	8b 00                	mov    (%eax),%eax
80102e95:	a3 98 08 11 80       	mov    %eax,0x80110898
  if(kmem.use_lock)
80102e9a:	a1 94 08 11 80       	mov    0x80110894,%eax
80102e9f:	85 c0                	test   %eax,%eax
80102ea1:	74 0c                	je     80102eaf <kalloc+0x48>
    release(&kmem.lock);
80102ea3:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102eaa:	e8 1e 25 00 00       	call   801053cd <release>
  return (char*)r;
80102eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102eb2:	c9                   	leave  
80102eb3:	c3                   	ret    

80102eb4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102eb4:	55                   	push   %ebp
80102eb5:	89 e5                	mov    %esp,%ebp
80102eb7:	53                   	push   %ebx
80102eb8:	83 ec 14             	sub    $0x14,%esp
80102ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ebe:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ec2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102ec6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102eca:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102ece:	ec                   	in     (%dx),%al
80102ecf:	89 c3                	mov    %eax,%ebx
80102ed1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102ed4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102ed8:	83 c4 14             	add    $0x14,%esp
80102edb:	5b                   	pop    %ebx
80102edc:	5d                   	pop    %ebp
80102edd:	c3                   	ret    

80102ede <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ede:	55                   	push   %ebp
80102edf:	89 e5                	mov    %esp,%ebp
80102ee1:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ee4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102eeb:	e8 c4 ff ff ff       	call   80102eb4 <inb>
80102ef0:	0f b6 c0             	movzbl %al,%eax
80102ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ef9:	83 e0 01             	and    $0x1,%eax
80102efc:	85 c0                	test   %eax,%eax
80102efe:	75 0a                	jne    80102f0a <kbdgetc+0x2c>
    return -1;
80102f00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f05:	e9 23 01 00 00       	jmp    8010302d <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102f0a:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102f11:	e8 9e ff ff ff       	call   80102eb4 <inb>
80102f16:	0f b6 c0             	movzbl %al,%eax
80102f19:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102f1c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f23:	75 17                	jne    80102f3c <kbdgetc+0x5e>
    shift |= E0ESC;
80102f25:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f2a:	83 c8 40             	or     $0x40,%eax
80102f2d:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f32:	b8 00 00 00 00       	mov    $0x0,%eax
80102f37:	e9 f1 00 00 00       	jmp    8010302d <kbdgetc+0x14f>
  } else if(data & 0x80){
80102f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f3f:	25 80 00 00 00       	and    $0x80,%eax
80102f44:	85 c0                	test   %eax,%eax
80102f46:	74 45                	je     80102f8d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f48:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f4d:	83 e0 40             	and    $0x40,%eax
80102f50:	85 c0                	test   %eax,%eax
80102f52:	75 08                	jne    80102f5c <kbdgetc+0x7e>
80102f54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f57:	83 e0 7f             	and    $0x7f,%eax
80102f5a:	eb 03                	jmp    80102f5f <kbdgetc+0x81>
80102f5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f62:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f65:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f6a:	0f b6 00             	movzbl (%eax),%eax
80102f6d:	83 c8 40             	or     $0x40,%eax
80102f70:	0f b6 c0             	movzbl %al,%eax
80102f73:	f7 d0                	not    %eax
80102f75:	89 c2                	mov    %eax,%edx
80102f77:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f7c:	21 d0                	and    %edx,%eax
80102f7e:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f83:	b8 00 00 00 00       	mov    $0x0,%eax
80102f88:	e9 a0 00 00 00       	jmp    8010302d <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f8d:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f92:	83 e0 40             	and    $0x40,%eax
80102f95:	85 c0                	test   %eax,%eax
80102f97:	74 14                	je     80102fad <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f99:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102fa0:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fa5:	83 e0 bf             	and    $0xffffffbf,%eax
80102fa8:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102fad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb0:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102fb5:	0f b6 00             	movzbl (%eax),%eax
80102fb8:	0f b6 d0             	movzbl %al,%edx
80102fbb:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fc0:	09 d0                	or     %edx,%eax
80102fc2:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102fc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fca:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102fcf:	0f b6 00             	movzbl (%eax),%eax
80102fd2:	0f b6 d0             	movzbl %al,%edx
80102fd5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fda:	31 d0                	xor    %edx,%eax
80102fdc:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fe1:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fe6:	83 e0 03             	and    $0x3,%eax
80102fe9:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80102ff0:	03 45 fc             	add    -0x4(%ebp),%eax
80102ff3:	0f b6 00             	movzbl (%eax),%eax
80102ff6:	0f b6 c0             	movzbl %al,%eax
80102ff9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ffc:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103001:	83 e0 08             	and    $0x8,%eax
80103004:	85 c0                	test   %eax,%eax
80103006:	74 22                	je     8010302a <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80103008:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010300c:	76 0c                	jbe    8010301a <kbdgetc+0x13c>
8010300e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103012:	77 06                	ja     8010301a <kbdgetc+0x13c>
      c += 'A' - 'a';
80103014:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103018:	eb 10                	jmp    8010302a <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
8010301a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010301e:	76 0a                	jbe    8010302a <kbdgetc+0x14c>
80103020:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103024:	77 04                	ja     8010302a <kbdgetc+0x14c>
      c += 'a' - 'A';
80103026:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010302a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010302d:	c9                   	leave  
8010302e:	c3                   	ret    

8010302f <kbdintr>:

void
kbdintr(void)
{
8010302f:	55                   	push   %ebp
80103030:	89 e5                	mov    %esp,%ebp
80103032:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103035:	c7 04 24 de 2e 10 80 	movl   $0x80102ede,(%esp)
8010303c:	e8 8d d8 ff ff       	call   801008ce <consoleintr>
}
80103041:	c9                   	leave  
80103042:	c3                   	ret    
	...

80103044 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103044:	55                   	push   %ebp
80103045:	89 e5                	mov    %esp,%ebp
80103047:	83 ec 08             	sub    $0x8,%esp
8010304a:	8b 55 08             	mov    0x8(%ebp),%edx
8010304d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103050:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103054:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103057:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010305b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010305f:	ee                   	out    %al,(%dx)
}
80103060:	c9                   	leave  
80103061:	c3                   	ret    

80103062 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103062:	55                   	push   %ebp
80103063:	89 e5                	mov    %esp,%ebp
80103065:	53                   	push   %ebx
80103066:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103069:	9c                   	pushf  
8010306a:	5b                   	pop    %ebx
8010306b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010306e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103071:	83 c4 10             	add    $0x10,%esp
80103074:	5b                   	pop    %ebx
80103075:	5d                   	pop    %ebp
80103076:	c3                   	ret    

80103077 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103077:	55                   	push   %ebp
80103078:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010307a:	a1 9c 08 11 80       	mov    0x8011089c,%eax
8010307f:	8b 55 08             	mov    0x8(%ebp),%edx
80103082:	c1 e2 02             	shl    $0x2,%edx
80103085:	01 c2                	add    %eax,%edx
80103087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010308a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010308c:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103091:	83 c0 20             	add    $0x20,%eax
80103094:	8b 00                	mov    (%eax),%eax
}
80103096:	5d                   	pop    %ebp
80103097:	c3                   	ret    

80103098 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103098:	55                   	push   %ebp
80103099:	89 e5                	mov    %esp,%ebp
8010309b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
8010309e:	a1 9c 08 11 80       	mov    0x8011089c,%eax
801030a3:	85 c0                	test   %eax,%eax
801030a5:	0f 84 47 01 00 00    	je     801031f2 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030ab:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
801030b2:	00 
801030b3:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801030ba:	e8 b8 ff ff ff       	call   80103077 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030bf:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801030c6:	00 
801030c7:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801030ce:	e8 a4 ff ff ff       	call   80103077 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030d3:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801030da:	00 
801030db:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030e2:	e8 90 ff ff ff       	call   80103077 <lapicw>
  lapicw(TICR, 10000000); 
801030e7:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030ee:	00 
801030ef:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030f6:	e8 7c ff ff ff       	call   80103077 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030fb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103102:	00 
80103103:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010310a:	e8 68 ff ff ff       	call   80103077 <lapicw>
  lapicw(LINT1, MASKED);
8010310f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103116:	00 
80103117:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
8010311e:	e8 54 ff ff ff       	call   80103077 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103123:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103128:	83 c0 30             	add    $0x30,%eax
8010312b:	8b 00                	mov    (%eax),%eax
8010312d:	c1 e8 10             	shr    $0x10,%eax
80103130:	25 ff 00 00 00       	and    $0xff,%eax
80103135:	83 f8 03             	cmp    $0x3,%eax
80103138:	76 14                	jbe    8010314e <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
8010313a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103141:	00 
80103142:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103149:	e8 29 ff ff ff       	call   80103077 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010314e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103155:	00 
80103156:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
8010315d:	e8 15 ff ff ff       	call   80103077 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103169:	00 
8010316a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103171:	e8 01 ff ff ff       	call   80103077 <lapicw>
  lapicw(ESR, 0);
80103176:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010317d:	00 
8010317e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103185:	e8 ed fe ff ff       	call   80103077 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010318a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103191:	00 
80103192:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103199:	e8 d9 fe ff ff       	call   80103077 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010319e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031a5:	00 
801031a6:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031ad:	e8 c5 fe ff ff       	call   80103077 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031b2:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801031b9:	00 
801031ba:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031c1:	e8 b1 fe ff ff       	call   80103077 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801031c6:	90                   	nop
801031c7:	a1 9c 08 11 80       	mov    0x8011089c,%eax
801031cc:	05 00 03 00 00       	add    $0x300,%eax
801031d1:	8b 00                	mov    (%eax),%eax
801031d3:	25 00 10 00 00       	and    $0x1000,%eax
801031d8:	85 c0                	test   %eax,%eax
801031da:	75 eb                	jne    801031c7 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031e3:	00 
801031e4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031eb:	e8 87 fe ff ff       	call   80103077 <lapicw>
801031f0:	eb 01                	jmp    801031f3 <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801031f2:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801031f3:	c9                   	leave  
801031f4:	c3                   	ret    

801031f5 <cpunum>:

int
cpunum(void)
{
801031f5:	55                   	push   %ebp
801031f6:	89 e5                	mov    %esp,%ebp
801031f8:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031fb:	e8 62 fe ff ff       	call   80103062 <readeflags>
80103200:	25 00 02 00 00       	and    $0x200,%eax
80103205:	85 c0                	test   %eax,%eax
80103207:	74 29                	je     80103232 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80103209:	a1 40 c6 10 80       	mov    0x8010c640,%eax
8010320e:	85 c0                	test   %eax,%eax
80103210:	0f 94 c2             	sete   %dl
80103213:	83 c0 01             	add    $0x1,%eax
80103216:	a3 40 c6 10 80       	mov    %eax,0x8010c640
8010321b:	84 d2                	test   %dl,%dl
8010321d:	74 13                	je     80103232 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
8010321f:	8b 45 04             	mov    0x4(%ebp),%eax
80103222:	89 44 24 04          	mov    %eax,0x4(%esp)
80103226:	c7 04 24 f4 8b 10 80 	movl   $0x80108bf4,(%esp)
8010322d:	e8 6f d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80103232:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103237:	85 c0                	test   %eax,%eax
80103239:	74 0f                	je     8010324a <cpunum+0x55>
    return lapic[ID]>>24;
8010323b:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103240:	83 c0 20             	add    $0x20,%eax
80103243:	8b 00                	mov    (%eax),%eax
80103245:	c1 e8 18             	shr    $0x18,%eax
80103248:	eb 05                	jmp    8010324f <cpunum+0x5a>
  return 0;
8010324a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010324f:	c9                   	leave  
80103250:	c3                   	ret    

80103251 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103251:	55                   	push   %ebp
80103252:	89 e5                	mov    %esp,%ebp
80103254:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103257:	a1 9c 08 11 80       	mov    0x8011089c,%eax
8010325c:	85 c0                	test   %eax,%eax
8010325e:	74 14                	je     80103274 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103260:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103267:	00 
80103268:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010326f:	e8 03 fe ff ff       	call   80103077 <lapicw>
}
80103274:	c9                   	leave  
80103275:	c3                   	ret    

80103276 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103276:	55                   	push   %ebp
80103277:	89 e5                	mov    %esp,%ebp
}
80103279:	5d                   	pop    %ebp
8010327a:	c3                   	ret    

8010327b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010327b:	55                   	push   %ebp
8010327c:	89 e5                	mov    %esp,%ebp
8010327e:	83 ec 1c             	sub    $0x1c,%esp
80103281:	8b 45 08             	mov    0x8(%ebp),%eax
80103284:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103287:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010328e:	00 
8010328f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103296:	e8 a9 fd ff ff       	call   80103044 <outb>
  outb(IO_RTC+1, 0x0A);
8010329b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801032a2:	00 
801032a3:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801032aa:	e8 95 fd ff ff       	call   80103044 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801032af:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801032b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032b9:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801032be:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032c1:	8d 50 02             	lea    0x2(%eax),%edx
801032c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801032c7:	c1 e8 04             	shr    $0x4,%eax
801032ca:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801032cd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032d1:	c1 e0 18             	shl    $0x18,%eax
801032d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d8:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032df:	e8 93 fd ff ff       	call   80103077 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032e4:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032eb:	00 
801032ec:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032f3:	e8 7f fd ff ff       	call   80103077 <lapicw>
  microdelay(200);
801032f8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032ff:	e8 72 ff ff ff       	call   80103276 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103304:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010330b:	00 
8010330c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103313:	e8 5f fd ff ff       	call   80103077 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103318:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010331f:	e8 52 ff ff ff       	call   80103276 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103324:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010332b:	eb 40                	jmp    8010336d <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
8010332d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103331:	c1 e0 18             	shl    $0x18,%eax
80103334:	89 44 24 04          	mov    %eax,0x4(%esp)
80103338:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010333f:	e8 33 fd ff ff       	call   80103077 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103344:	8b 45 0c             	mov    0xc(%ebp),%eax
80103347:	c1 e8 0c             	shr    $0xc,%eax
8010334a:	80 cc 06             	or     $0x6,%ah
8010334d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103351:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103358:	e8 1a fd ff ff       	call   80103077 <lapicw>
    microdelay(200);
8010335d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103364:	e8 0d ff ff ff       	call   80103276 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103369:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010336d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103371:	7e ba                	jle    8010332d <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103373:	c9                   	leave  
80103374:	c3                   	ret    
80103375:	00 00                	add    %al,(%eax)
	...

80103378 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103378:	55                   	push   %ebp
80103379:	89 e5                	mov    %esp,%ebp
8010337b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010337e:	c7 44 24 04 20 8c 10 	movl   $0x80108c20,0x4(%esp)
80103385:	80 
80103386:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
8010338d:	e8 b8 1f 00 00       	call   8010534a <initlock>
  readsb(ROOTDEV, &sb);
80103392:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103395:	89 44 24 04          	mov    %eax,0x4(%esp)
80103399:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801033a0:	e8 af e2 ff ff       	call   80101654 <readsb>
  log.start = sb.size - sb.nlog;
801033a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ab:	89 d1                	mov    %edx,%ecx
801033ad:	29 c1                	sub    %eax,%ecx
801033af:	89 c8                	mov    %ecx,%eax
801033b1:	a3 d4 08 11 80       	mov    %eax,0x801108d4
  log.size = sb.nlog;
801033b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b9:	a3 d8 08 11 80       	mov    %eax,0x801108d8
  log.dev = ROOTDEV;
801033be:	c7 05 e0 08 11 80 01 	movl   $0x1,0x801108e0
801033c5:	00 00 00 
  recover_from_log();
801033c8:	e8 97 01 00 00       	call   80103564 <recover_from_log>
}
801033cd:	c9                   	leave  
801033ce:	c3                   	ret    

801033cf <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033cf:	55                   	push   %ebp
801033d0:	89 e5                	mov    %esp,%ebp
801033d2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033dc:	e9 89 00 00 00       	jmp    8010346a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033e1:	a1 d4 08 11 80       	mov    0x801108d4,%eax
801033e6:	03 45 f4             	add    -0xc(%ebp),%eax
801033e9:	83 c0 01             	add    $0x1,%eax
801033ec:	89 c2                	mov    %eax,%edx
801033ee:	a1 e0 08 11 80       	mov    0x801108e0,%eax
801033f3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033f7:	89 04 24             	mov    %eax,(%esp)
801033fa:	e8 a7 cd ff ff       	call   801001a6 <bread>
801033ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103405:	83 c0 10             	add    $0x10,%eax
80103408:	8b 04 85 a8 08 11 80 	mov    -0x7feef758(,%eax,4),%eax
8010340f:	89 c2                	mov    %eax,%edx
80103411:	a1 e0 08 11 80       	mov    0x801108e0,%eax
80103416:	89 54 24 04          	mov    %edx,0x4(%esp)
8010341a:	89 04 24             	mov    %eax,(%esp)
8010341d:	e8 84 cd ff ff       	call   801001a6 <bread>
80103422:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103428:	8d 50 18             	lea    0x18(%eax),%edx
8010342b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342e:	83 c0 18             	add    $0x18,%eax
80103431:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103438:	00 
80103439:	89 54 24 04          	mov    %edx,0x4(%esp)
8010343d:	89 04 24             	mov    %eax,(%esp)
80103440:	e8 48 22 00 00       	call   8010568d <memmove>
    bwrite(dbuf);  // write dst to disk
80103445:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103448:	89 04 24             	mov    %eax,(%esp)
8010344b:	e8 8d cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103453:	89 04 24             	mov    %eax,(%esp)
80103456:	e8 bc cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010345b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345e:	89 04 24             	mov    %eax,(%esp)
80103461:	e8 b1 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010346a:	a1 e4 08 11 80       	mov    0x801108e4,%eax
8010346f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103472:	0f 8f 69 ff ff ff    	jg     801033e1 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103478:	c9                   	leave  
80103479:	c3                   	ret    

8010347a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010347a:	55                   	push   %ebp
8010347b:	89 e5                	mov    %esp,%ebp
8010347d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103480:	a1 d4 08 11 80       	mov    0x801108d4,%eax
80103485:	89 c2                	mov    %eax,%edx
80103487:	a1 e0 08 11 80       	mov    0x801108e0,%eax
8010348c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103490:	89 04 24             	mov    %eax,(%esp)
80103493:	e8 0e cd ff ff       	call   801001a6 <bread>
80103498:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010349b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349e:	83 c0 18             	add    $0x18,%eax
801034a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034a7:	8b 00                	mov    (%eax),%eax
801034a9:	a3 e4 08 11 80       	mov    %eax,0x801108e4
  for (i = 0; i < log.lh.n; i++) {
801034ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b5:	eb 1b                	jmp    801034d2 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801034b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034bd:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034c4:	83 c2 10             	add    $0x10,%edx
801034c7:	89 04 95 a8 08 11 80 	mov    %eax,-0x7feef758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d2:	a1 e4 08 11 80       	mov    0x801108e4,%eax
801034d7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034da:	7f db                	jg     801034b7 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034df:	89 04 24             	mov    %eax,(%esp)
801034e2:	e8 30 cd ff ff       	call   80100217 <brelse>
}
801034e7:	c9                   	leave  
801034e8:	c3                   	ret    

801034e9 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034e9:	55                   	push   %ebp
801034ea:	89 e5                	mov    %esp,%ebp
801034ec:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ef:	a1 d4 08 11 80       	mov    0x801108d4,%eax
801034f4:	89 c2                	mov    %eax,%edx
801034f6:	a1 e0 08 11 80       	mov    0x801108e0,%eax
801034fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ff:	89 04 24             	mov    %eax,(%esp)
80103502:	e8 9f cc ff ff       	call   801001a6 <bread>
80103507:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010350a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010350d:	83 c0 18             	add    $0x18,%eax
80103510:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103513:	8b 15 e4 08 11 80    	mov    0x801108e4,%edx
80103519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010351c:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010351e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103525:	eb 1b                	jmp    80103542 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010352a:	83 c0 10             	add    $0x10,%eax
8010352d:	8b 0c 85 a8 08 11 80 	mov    -0x7feef758(,%eax,4),%ecx
80103534:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010353a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010353e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103542:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80103547:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010354a:	7f db                	jg     80103527 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010354c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010354f:	89 04 24             	mov    %eax,(%esp)
80103552:	e8 86 cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103557:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010355a:	89 04 24             	mov    %eax,(%esp)
8010355d:	e8 b5 cc ff ff       	call   80100217 <brelse>
}
80103562:	c9                   	leave  
80103563:	c3                   	ret    

80103564 <recover_from_log>:

static void
recover_from_log(void)
{
80103564:	55                   	push   %ebp
80103565:	89 e5                	mov    %esp,%ebp
80103567:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010356a:	e8 0b ff ff ff       	call   8010347a <read_head>
  install_trans(); // if committed, copy from log to disk
8010356f:	e8 5b fe ff ff       	call   801033cf <install_trans>
  log.lh.n = 0;
80103574:	c7 05 e4 08 11 80 00 	movl   $0x0,0x801108e4
8010357b:	00 00 00 
  write_head(); // clear the log
8010357e:	e8 66 ff ff ff       	call   801034e9 <write_head>
}
80103583:	c9                   	leave  
80103584:	c3                   	ret    

80103585 <begin_trans>:

void
begin_trans(void)
{
80103585:	55                   	push   %ebp
80103586:	89 e5                	mov    %esp,%ebp
80103588:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010358b:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
80103592:	e8 d4 1d 00 00       	call   8010536b <acquire>
  while (log.busy) {
80103597:	eb 14                	jmp    801035ad <begin_trans+0x28>
    sleep(&log, &log.lock);
80103599:	c7 44 24 04 a0 08 11 	movl   $0x801108a0,0x4(%esp)
801035a0:	80 
801035a1:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
801035a8:	e8 96 1a 00 00       	call   80105043 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
801035ad:	a1 dc 08 11 80       	mov    0x801108dc,%eax
801035b2:	85 c0                	test   %eax,%eax
801035b4:	75 e3                	jne    80103599 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801035b6:	c7 05 dc 08 11 80 01 	movl   $0x1,0x801108dc
801035bd:	00 00 00 
  release(&log.lock);
801035c0:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
801035c7:	e8 01 1e 00 00       	call   801053cd <release>
}
801035cc:	c9                   	leave  
801035cd:	c3                   	ret    

801035ce <commit_trans>:

void
commit_trans(void)
{
801035ce:	55                   	push   %ebp
801035cf:	89 e5                	mov    %esp,%ebp
801035d1:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801035d4:	a1 e4 08 11 80       	mov    0x801108e4,%eax
801035d9:	85 c0                	test   %eax,%eax
801035db:	7e 19                	jle    801035f6 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801035dd:	e8 07 ff ff ff       	call   801034e9 <write_head>
    install_trans(); // Now install writes to home locations
801035e2:	e8 e8 fd ff ff       	call   801033cf <install_trans>
    log.lh.n = 0; 
801035e7:	c7 05 e4 08 11 80 00 	movl   $0x0,0x801108e4
801035ee:	00 00 00 
    write_head();    // Erase the transaction from the log
801035f1:	e8 f3 fe ff ff       	call   801034e9 <write_head>
  }
  
  acquire(&log.lock);
801035f6:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
801035fd:	e8 69 1d 00 00       	call   8010536b <acquire>
  log.busy = 0;
80103602:	c7 05 dc 08 11 80 00 	movl   $0x0,0x801108dc
80103609:	00 00 00 
  wakeup(&log);
8010360c:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
80103613:	e8 07 1b 00 00       	call   8010511f <wakeup>
  release(&log.lock);
80103618:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
8010361f:	e8 a9 1d 00 00       	call   801053cd <release>
}
80103624:	c9                   	leave  
80103625:	c3                   	ret    

80103626 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103626:	55                   	push   %ebp
80103627:	89 e5                	mov    %esp,%ebp
80103629:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010362c:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80103631:	83 f8 09             	cmp    $0x9,%eax
80103634:	7f 12                	jg     80103648 <log_write+0x22>
80103636:	a1 e4 08 11 80       	mov    0x801108e4,%eax
8010363b:	8b 15 d8 08 11 80    	mov    0x801108d8,%edx
80103641:	83 ea 01             	sub    $0x1,%edx
80103644:	39 d0                	cmp    %edx,%eax
80103646:	7c 0c                	jl     80103654 <log_write+0x2e>
    panic("too big a transaction");
80103648:	c7 04 24 24 8c 10 80 	movl   $0x80108c24,(%esp)
8010364f:	e8 e9 ce ff ff       	call   8010053d <panic>
  if (!log.busy)
80103654:	a1 dc 08 11 80       	mov    0x801108dc,%eax
80103659:	85 c0                	test   %eax,%eax
8010365b:	75 0c                	jne    80103669 <log_write+0x43>
    panic("write outside of trans");
8010365d:	c7 04 24 3a 8c 10 80 	movl   $0x80108c3a,(%esp)
80103664:	e8 d4 ce ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103670:	eb 1d                	jmp    8010368f <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103675:	83 c0 10             	add    $0x10,%eax
80103678:	8b 04 85 a8 08 11 80 	mov    -0x7feef758(,%eax,4),%eax
8010367f:	89 c2                	mov    %eax,%edx
80103681:	8b 45 08             	mov    0x8(%ebp),%eax
80103684:	8b 40 08             	mov    0x8(%eax),%eax
80103687:	39 c2                	cmp    %eax,%edx
80103689:	74 10                	je     8010369b <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010368b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010368f:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80103694:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103697:	7f d9                	jg     80103672 <log_write+0x4c>
80103699:	eb 01                	jmp    8010369c <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
8010369b:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
8010369c:	8b 45 08             	mov    0x8(%ebp),%eax
8010369f:	8b 40 08             	mov    0x8(%eax),%eax
801036a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036a5:	83 c2 10             	add    $0x10,%edx
801036a8:	89 04 95 a8 08 11 80 	mov    %eax,-0x7feef758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
801036af:	a1 d4 08 11 80       	mov    0x801108d4,%eax
801036b4:	03 45 f4             	add    -0xc(%ebp),%eax
801036b7:	83 c0 01             	add    $0x1,%eax
801036ba:	89 c2                	mov    %eax,%edx
801036bc:	8b 45 08             	mov    0x8(%ebp),%eax
801036bf:	8b 40 04             	mov    0x4(%eax),%eax
801036c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801036c6:	89 04 24             	mov    %eax,(%esp)
801036c9:	e8 d8 ca ff ff       	call   801001a6 <bread>
801036ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801036d1:	8b 45 08             	mov    0x8(%ebp),%eax
801036d4:	8d 50 18             	lea    0x18(%eax),%edx
801036d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036da:	83 c0 18             	add    $0x18,%eax
801036dd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036e4:	00 
801036e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801036e9:	89 04 24             	mov    %eax,(%esp)
801036ec:	e8 9c 1f 00 00       	call   8010568d <memmove>
  bwrite(lbuf);
801036f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036f4:	89 04 24             	mov    %eax,(%esp)
801036f7:	e8 e1 ca ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ff:	89 04 24             	mov    %eax,(%esp)
80103702:	e8 10 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
80103707:	a1 e4 08 11 80       	mov    0x801108e4,%eax
8010370c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010370f:	75 0d                	jne    8010371e <log_write+0xf8>
    log.lh.n++;
80103711:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80103716:	83 c0 01             	add    $0x1,%eax
80103719:	a3 e4 08 11 80       	mov    %eax,0x801108e4
  b->flags |= B_DIRTY; // XXX prevent eviction
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 00                	mov    (%eax),%eax
80103723:	89 c2                	mov    %eax,%edx
80103725:	83 ca 04             	or     $0x4,%edx
80103728:	8b 45 08             	mov    0x8(%ebp),%eax
8010372b:	89 10                	mov    %edx,(%eax)
}
8010372d:	c9                   	leave  
8010372e:	c3                   	ret    
	...

80103730 <v2p>:
80103730:	55                   	push   %ebp
80103731:	89 e5                	mov    %esp,%ebp
80103733:	8b 45 08             	mov    0x8(%ebp),%eax
80103736:	05 00 00 00 80       	add    $0x80000000,%eax
8010373b:	5d                   	pop    %ebp
8010373c:	c3                   	ret    

8010373d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010373d:	55                   	push   %ebp
8010373e:	89 e5                	mov    %esp,%ebp
80103740:	8b 45 08             	mov    0x8(%ebp),%eax
80103743:	05 00 00 00 80       	add    $0x80000000,%eax
80103748:	5d                   	pop    %ebp
80103749:	c3                   	ret    

8010374a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010374a:	55                   	push   %ebp
8010374b:	89 e5                	mov    %esp,%ebp
8010374d:	53                   	push   %ebx
8010374e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103751:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103754:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103757:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010375a:	89 c3                	mov    %eax,%ebx
8010375c:	89 d8                	mov    %ebx,%eax
8010375e:	f0 87 02             	lock xchg %eax,(%edx)
80103761:	89 c3                	mov    %eax,%ebx
80103763:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103766:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103769:	83 c4 10             	add    $0x10,%esp
8010376c:	5b                   	pop    %ebx
8010376d:	5d                   	pop    %ebp
8010376e:	c3                   	ret    

8010376f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010376f:	55                   	push   %ebp
80103770:	89 e5                	mov    %esp,%ebp
80103772:	83 e4 f0             	and    $0xfffffff0,%esp
80103775:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103778:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010377f:	80 
80103780:	c7 04 24 1c 3d 11 80 	movl   $0x80113d1c,(%esp)
80103787:	e8 ad f5 ff ff       	call   80102d39 <kinit1>
  kvmalloc();      // kernel page table
8010378c:	e8 ed 4a 00 00       	call   8010827e <kvmalloc>
  mpinit();        // collect info about this machine
80103791:	e8 63 04 00 00       	call   80103bf9 <mpinit>
  lapicinit(mpbcpu());
80103796:	e8 2e 02 00 00       	call   801039c9 <mpbcpu>
8010379b:	89 04 24             	mov    %eax,(%esp)
8010379e:	e8 f5 f8 ff ff       	call   80103098 <lapicinit>
  seginit();       // set up segments
801037a3:	e8 79 44 00 00       	call   80107c21 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037ae:	0f b6 00             	movzbl (%eax),%eax
801037b1:	0f b6 c0             	movzbl %al,%eax
801037b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b8:	c7 04 24 51 8c 10 80 	movl   $0x80108c51,(%esp)
801037bf:	e8 dd cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037c4:	e8 95 06 00 00       	call   80103e5e <picinit>
  ioapicinit();    // another interrupt controller
801037c9:	e8 5b f4 ff ff       	call   80102c29 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037ce:	e8 23 d6 ff ff       	call   80100df6 <consoleinit>
  uartinit();      // serial port
801037d3:	e8 94 37 00 00       	call   80106f6c <uartinit>
  pinit();         // process table
801037d8:	e8 96 0b 00 00       	call   80104373 <pinit>
  tvinit();        // trap vectors
801037dd:	e8 e9 32 00 00       	call   80106acb <tvinit>
  binit();         // buffer cache
801037e2:	e8 4d c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037e7:	e8 7c da ff ff       	call   80101268 <fileinit>
  iinit();         // inode cache
801037ec:	e8 2a e1 ff ff       	call   8010191b <iinit>
  ideinit();       // disk
801037f1:	e8 98 f0 ff ff       	call   8010288e <ideinit>
  if(!ismp)
801037f6:	a1 24 09 11 80       	mov    0x80110924,%eax
801037fb:	85 c0                	test   %eax,%eax
801037fd:	75 05                	jne    80103804 <main+0x95>
    timerinit();   // uniprocessor timer
801037ff:	e8 0a 32 00 00       	call   80106a0e <timerinit>
  startothers();   // start other processors
80103804:	e8 87 00 00 00       	call   80103890 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103809:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103810:	8e 
80103811:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103818:	e8 54 f5 ff ff       	call   80102d71 <kinit2>
  userinit();      // first user process
8010381d:	e8 6f 0c 00 00       	call   80104491 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103822:	e8 22 00 00 00       	call   80103849 <mpmain>

80103827 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103827:	55                   	push   %ebp
80103828:	89 e5                	mov    %esp,%ebp
8010382a:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
8010382d:	e8 63 4a 00 00       	call   80108295 <switchkvm>
  seginit();
80103832:	e8 ea 43 00 00       	call   80107c21 <seginit>
  lapicinit(cpunum());
80103837:	e8 b9 f9 ff ff       	call   801031f5 <cpunum>
8010383c:	89 04 24             	mov    %eax,(%esp)
8010383f:	e8 54 f8 ff ff       	call   80103098 <lapicinit>
  mpmain();
80103844:	e8 00 00 00 00       	call   80103849 <mpmain>

80103849 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103849:	55                   	push   %ebp
8010384a:	89 e5                	mov    %esp,%ebp
8010384c:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010384f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103855:	0f b6 00             	movzbl (%eax),%eax
80103858:	0f b6 c0             	movzbl %al,%eax
8010385b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010385f:	c7 04 24 68 8c 10 80 	movl   $0x80108c68,(%esp)
80103866:	e8 36 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
8010386b:	e8 cf 33 00 00       	call   80106c3f <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103870:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103876:	05 a8 00 00 00       	add    $0xa8,%eax
8010387b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103882:	00 
80103883:	89 04 24             	mov    %eax,(%esp)
80103886:	e8 bf fe ff ff       	call   8010374a <xchg>
  scheduler();     // start running processes
8010388b:	e8 c9 13 00 00       	call   80104c59 <scheduler>

80103890 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103890:	55                   	push   %ebp
80103891:	89 e5                	mov    %esp,%ebp
80103893:	53                   	push   %ebx
80103894:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103897:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010389e:	e8 9a fe ff ff       	call   8010373d <p2v>
801038a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038a6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801038af:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
801038b6:	80 
801038b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ba:	89 04 24             	mov    %eax,(%esp)
801038bd:	e8 cb 1d 00 00       	call   8010568d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038c2:	c7 45 f4 40 09 11 80 	movl   $0x80110940,-0xc(%ebp)
801038c9:	e9 86 00 00 00       	jmp    80103954 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038ce:	e8 22 f9 ff ff       	call   801031f5 <cpunum>
801038d3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038d9:	05 40 09 11 80       	add    $0x80110940,%eax
801038de:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038e1:	74 69                	je     8010394c <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038e3:	e8 7f f5 ff ff       	call   80102e67 <kalloc>
801038e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ee:	83 e8 04             	sub    $0x4,%eax
801038f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038f4:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038fa:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ff:	83 e8 08             	sub    $0x8,%eax
80103902:	c7 00 27 38 10 80    	movl   $0x80103827,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390b:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010390e:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
80103915:	e8 16 fe ff ff       	call   80103730 <v2p>
8010391a:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010391c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010391f:	89 04 24             	mov    %eax,(%esp)
80103922:	e8 09 fe ff ff       	call   80103730 <v2p>
80103927:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010392a:	0f b6 12             	movzbl (%edx),%edx
8010392d:	0f b6 d2             	movzbl %dl,%edx
80103930:	89 44 24 04          	mov    %eax,0x4(%esp)
80103934:	89 14 24             	mov    %edx,(%esp)
80103937:	e8 3f f9 ff ff       	call   8010327b <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010393c:	90                   	nop
8010393d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103940:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103946:	85 c0                	test   %eax,%eax
80103948:	74 f3                	je     8010393d <startothers+0xad>
8010394a:	eb 01                	jmp    8010394d <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010394c:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010394d:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103954:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103959:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010395f:	05 40 09 11 80       	add    $0x80110940,%eax
80103964:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103967:	0f 87 61 ff ff ff    	ja     801038ce <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010396d:	83 c4 24             	add    $0x24,%esp
80103970:	5b                   	pop    %ebx
80103971:	5d                   	pop    %ebp
80103972:	c3                   	ret    
	...

80103974 <p2v>:
80103974:	55                   	push   %ebp
80103975:	89 e5                	mov    %esp,%ebp
80103977:	8b 45 08             	mov    0x8(%ebp),%eax
8010397a:	05 00 00 00 80       	add    $0x80000000,%eax
8010397f:	5d                   	pop    %ebp
80103980:	c3                   	ret    

80103981 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103981:	55                   	push   %ebp
80103982:	89 e5                	mov    %esp,%ebp
80103984:	53                   	push   %ebx
80103985:	83 ec 14             	sub    $0x14,%esp
80103988:	8b 45 08             	mov    0x8(%ebp),%eax
8010398b:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010398f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103993:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103997:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010399b:	ec                   	in     (%dx),%al
8010399c:	89 c3                	mov    %eax,%ebx
8010399e:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801039a1:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801039a5:	83 c4 14             	add    $0x14,%esp
801039a8:	5b                   	pop    %ebx
801039a9:	5d                   	pop    %ebp
801039aa:	c3                   	ret    

801039ab <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039ab:	55                   	push   %ebp
801039ac:	89 e5                	mov    %esp,%ebp
801039ae:	83 ec 08             	sub    $0x8,%esp
801039b1:	8b 55 08             	mov    0x8(%ebp),%edx
801039b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801039b7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039bb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039be:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039c2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039c6:	ee                   	out    %al,(%dx)
}
801039c7:	c9                   	leave  
801039c8:	c3                   	ret    

801039c9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039c9:	55                   	push   %ebp
801039ca:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039cc:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801039d1:	89 c2                	mov    %eax,%edx
801039d3:	b8 40 09 11 80       	mov    $0x80110940,%eax
801039d8:	89 d1                	mov    %edx,%ecx
801039da:	29 c1                	sub    %eax,%ecx
801039dc:	89 c8                	mov    %ecx,%eax
801039de:	c1 f8 02             	sar    $0x2,%eax
801039e1:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039e7:	5d                   	pop    %ebp
801039e8:	c3                   	ret    

801039e9 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039e9:	55                   	push   %ebp
801039ea:	89 e5                	mov    %esp,%ebp
801039ec:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039ef:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039fd:	eb 13                	jmp    80103a12 <sum+0x29>
    sum += addr[i];
801039ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a02:	03 45 08             	add    0x8(%ebp),%eax
80103a05:	0f b6 00             	movzbl (%eax),%eax
80103a08:	0f b6 c0             	movzbl %al,%eax
80103a0b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a0e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a15:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a18:	7c e5                	jl     801039ff <sum+0x16>
    sum += addr[i];
  return sum;
80103a1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a1d:	c9                   	leave  
80103a1e:	c3                   	ret    

80103a1f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a1f:	55                   	push   %ebp
80103a20:	89 e5                	mov    %esp,%ebp
80103a22:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a25:	8b 45 08             	mov    0x8(%ebp),%eax
80103a28:	89 04 24             	mov    %eax,(%esp)
80103a2b:	e8 44 ff ff ff       	call   80103974 <p2v>
80103a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a33:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a36:	03 45 f0             	add    -0x10(%ebp),%eax
80103a39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a42:	eb 3f                	jmp    80103a83 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a44:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a4b:	00 
80103a4c:	c7 44 24 04 7c 8c 10 	movl   $0x80108c7c,0x4(%esp)
80103a53:	80 
80103a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a57:	89 04 24             	mov    %eax,(%esp)
80103a5a:	e8 d2 1b 00 00       	call   80105631 <memcmp>
80103a5f:	85 c0                	test   %eax,%eax
80103a61:	75 1c                	jne    80103a7f <mpsearch1+0x60>
80103a63:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a6a:	00 
80103a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6e:	89 04 24             	mov    %eax,(%esp)
80103a71:	e8 73 ff ff ff       	call   801039e9 <sum>
80103a76:	84 c0                	test   %al,%al
80103a78:	75 05                	jne    80103a7f <mpsearch1+0x60>
      return (struct mp*)p;
80103a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7d:	eb 11                	jmp    80103a90 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a7f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a86:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a89:	72 b9                	jb     80103a44 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a90:	c9                   	leave  
80103a91:	c3                   	ret    

80103a92 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a92:	55                   	push   %ebp
80103a93:	89 e5                	mov    %esp,%ebp
80103a95:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a98:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa2:	83 c0 0f             	add    $0xf,%eax
80103aa5:	0f b6 00             	movzbl (%eax),%eax
80103aa8:	0f b6 c0             	movzbl %al,%eax
80103aab:	89 c2                	mov    %eax,%edx
80103aad:	c1 e2 08             	shl    $0x8,%edx
80103ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab3:	83 c0 0e             	add    $0xe,%eax
80103ab6:	0f b6 00             	movzbl (%eax),%eax
80103ab9:	0f b6 c0             	movzbl %al,%eax
80103abc:	09 d0                	or     %edx,%eax
80103abe:	c1 e0 04             	shl    $0x4,%eax
80103ac1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ac4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ac8:	74 21                	je     80103aeb <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103aca:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ad1:	00 
80103ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad5:	89 04 24             	mov    %eax,(%esp)
80103ad8:	e8 42 ff ff ff       	call   80103a1f <mpsearch1>
80103add:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ae0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ae4:	74 50                	je     80103b36 <mpsearch+0xa4>
      return mp;
80103ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ae9:	eb 5f                	jmp    80103b4a <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aee:	83 c0 14             	add    $0x14,%eax
80103af1:	0f b6 00             	movzbl (%eax),%eax
80103af4:	0f b6 c0             	movzbl %al,%eax
80103af7:	89 c2                	mov    %eax,%edx
80103af9:	c1 e2 08             	shl    $0x8,%edx
80103afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aff:	83 c0 13             	add    $0x13,%eax
80103b02:	0f b6 00             	movzbl (%eax),%eax
80103b05:	0f b6 c0             	movzbl %al,%eax
80103b08:	09 d0                	or     %edx,%eax
80103b0a:	c1 e0 0a             	shl    $0xa,%eax
80103b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b13:	2d 00 04 00 00       	sub    $0x400,%eax
80103b18:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b1f:	00 
80103b20:	89 04 24             	mov    %eax,(%esp)
80103b23:	e8 f7 fe ff ff       	call   80103a1f <mpsearch1>
80103b28:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b2f:	74 05                	je     80103b36 <mpsearch+0xa4>
      return mp;
80103b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b34:	eb 14                	jmp    80103b4a <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b36:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b3d:	00 
80103b3e:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b45:	e8 d5 fe ff ff       	call   80103a1f <mpsearch1>
}
80103b4a:	c9                   	leave  
80103b4b:	c3                   	ret    

80103b4c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b4c:	55                   	push   %ebp
80103b4d:	89 e5                	mov    %esp,%ebp
80103b4f:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b52:	e8 3b ff ff ff       	call   80103a92 <mpsearch>
80103b57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b5e:	74 0a                	je     80103b6a <mpconfig+0x1e>
80103b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b63:	8b 40 04             	mov    0x4(%eax),%eax
80103b66:	85 c0                	test   %eax,%eax
80103b68:	75 0a                	jne    80103b74 <mpconfig+0x28>
    return 0;
80103b6a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b6f:	e9 83 00 00 00       	jmp    80103bf7 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b77:	8b 40 04             	mov    0x4(%eax),%eax
80103b7a:	89 04 24             	mov    %eax,(%esp)
80103b7d:	e8 f2 fd ff ff       	call   80103974 <p2v>
80103b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b85:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b8c:	00 
80103b8d:	c7 44 24 04 81 8c 10 	movl   $0x80108c81,0x4(%esp)
80103b94:	80 
80103b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b98:	89 04 24             	mov    %eax,(%esp)
80103b9b:	e8 91 1a 00 00       	call   80105631 <memcmp>
80103ba0:	85 c0                	test   %eax,%eax
80103ba2:	74 07                	je     80103bab <mpconfig+0x5f>
    return 0;
80103ba4:	b8 00 00 00 00       	mov    $0x0,%eax
80103ba9:	eb 4c                	jmp    80103bf7 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bae:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bb2:	3c 01                	cmp    $0x1,%al
80103bb4:	74 12                	je     80103bc8 <mpconfig+0x7c>
80103bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb9:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bbd:	3c 04                	cmp    $0x4,%al
80103bbf:	74 07                	je     80103bc8 <mpconfig+0x7c>
    return 0;
80103bc1:	b8 00 00 00 00       	mov    $0x0,%eax
80103bc6:	eb 2f                	jmp    80103bf7 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bcf:	0f b7 c0             	movzwl %ax,%eax
80103bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd9:	89 04 24             	mov    %eax,(%esp)
80103bdc:	e8 08 fe ff ff       	call   801039e9 <sum>
80103be1:	84 c0                	test   %al,%al
80103be3:	74 07                	je     80103bec <mpconfig+0xa0>
    return 0;
80103be5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bea:	eb 0b                	jmp    80103bf7 <mpconfig+0xab>
  *pmp = mp;
80103bec:	8b 45 08             	mov    0x8(%ebp),%eax
80103bef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bf2:	89 10                	mov    %edx,(%eax)
  return conf;
80103bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bf7:	c9                   	leave  
80103bf8:	c3                   	ret    

80103bf9 <mpinit>:

void
mpinit(void)
{
80103bf9:	55                   	push   %ebp
80103bfa:	89 e5                	mov    %esp,%ebp
80103bfc:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103bff:	c7 05 44 c6 10 80 40 	movl   $0x80110940,0x8010c644
80103c06:	09 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c09:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c0c:	89 04 24             	mov    %eax,(%esp)
80103c0f:	e8 38 ff ff ff       	call   80103b4c <mpconfig>
80103c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c1b:	0f 84 9c 01 00 00    	je     80103dbd <mpinit+0x1c4>
    return;
  ismp = 1;
80103c21:	c7 05 24 09 11 80 01 	movl   $0x1,0x80110924
80103c28:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2e:	8b 40 24             	mov    0x24(%eax),%eax
80103c31:	a3 9c 08 11 80       	mov    %eax,0x8011089c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c39:	83 c0 2c             	add    $0x2c,%eax
80103c3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c42:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c46:	0f b7 c0             	movzwl %ax,%eax
80103c49:	03 45 f0             	add    -0x10(%ebp),%eax
80103c4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c4f:	e9 f4 00 00 00       	jmp    80103d48 <mpinit+0x14f>
    switch(*p){
80103c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c57:	0f b6 00             	movzbl (%eax),%eax
80103c5a:	0f b6 c0             	movzbl %al,%eax
80103c5d:	83 f8 04             	cmp    $0x4,%eax
80103c60:	0f 87 bf 00 00 00    	ja     80103d25 <mpinit+0x12c>
80103c66:	8b 04 85 c4 8c 10 80 	mov    -0x7fef733c(,%eax,4),%eax
80103c6d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c72:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c78:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c7c:	0f b6 d0             	movzbl %al,%edx
80103c7f:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103c84:	39 c2                	cmp    %eax,%edx
80103c86:	74 2d                	je     80103cb5 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c8b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c8f:	0f b6 d0             	movzbl %al,%edx
80103c92:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103c97:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c9f:	c7 04 24 86 8c 10 80 	movl   $0x80108c86,(%esp)
80103ca6:	e8 f6 c6 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103cab:	c7 05 24 09 11 80 00 	movl   $0x0,0x80110924
80103cb2:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cb8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cbc:	0f b6 c0             	movzbl %al,%eax
80103cbf:	83 e0 02             	and    $0x2,%eax
80103cc2:	85 c0                	test   %eax,%eax
80103cc4:	74 15                	je     80103cdb <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cc6:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103ccb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cd1:	05 40 09 11 80       	add    $0x80110940,%eax
80103cd6:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80103cdb:	8b 15 20 0f 11 80    	mov    0x80110f20,%edx
80103ce1:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103ce6:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cec:	81 c2 40 09 11 80    	add    $0x80110940,%edx
80103cf2:	88 02                	mov    %al,(%edx)
      ncpu++;
80103cf4:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103cf9:	83 c0 01             	add    $0x1,%eax
80103cfc:	a3 20 0f 11 80       	mov    %eax,0x80110f20
      p += sizeof(struct mpproc);
80103d01:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d05:	eb 41                	jmp    80103d48 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d10:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d14:	a2 20 09 11 80       	mov    %al,0x80110920
      p += sizeof(struct mpioapic);
80103d19:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d1d:	eb 29                	jmp    80103d48 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d1f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d23:	eb 23                	jmp    80103d48 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d28:	0f b6 00             	movzbl (%eax),%eax
80103d2b:	0f b6 c0             	movzbl %al,%eax
80103d2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d32:	c7 04 24 a4 8c 10 80 	movl   $0x80108ca4,(%esp)
80103d39:	e8 63 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d3e:	c7 05 24 09 11 80 00 	movl   $0x0,0x80110924
80103d45:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d4e:	0f 82 00 ff ff ff    	jb     80103c54 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d54:	a1 24 09 11 80       	mov    0x80110924,%eax
80103d59:	85 c0                	test   %eax,%eax
80103d5b:	75 1d                	jne    80103d7a <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d5d:	c7 05 20 0f 11 80 01 	movl   $0x1,0x80110f20
80103d64:	00 00 00 
    lapic = 0;
80103d67:	c7 05 9c 08 11 80 00 	movl   $0x0,0x8011089c
80103d6e:	00 00 00 
    ioapicid = 0;
80103d71:	c6 05 20 09 11 80 00 	movb   $0x0,0x80110920
    return;
80103d78:	eb 44                	jmp    80103dbe <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d7d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d81:	84 c0                	test   %al,%al
80103d83:	74 39                	je     80103dbe <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d85:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d8c:	00 
80103d8d:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d94:	e8 12 fc ff ff       	call   801039ab <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d99:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103da0:	e8 dc fb ff ff       	call   80103981 <inb>
80103da5:	83 c8 01             	or     $0x1,%eax
80103da8:	0f b6 c0             	movzbl %al,%eax
80103dab:	89 44 24 04          	mov    %eax,0x4(%esp)
80103daf:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103db6:	e8 f0 fb ff ff       	call   801039ab <outb>
80103dbb:	eb 01                	jmp    80103dbe <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103dbd:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103dbe:	c9                   	leave  
80103dbf:	c3                   	ret    

80103dc0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dc0:	55                   	push   %ebp
80103dc1:	89 e5                	mov    %esp,%ebp
80103dc3:	83 ec 08             	sub    $0x8,%esp
80103dc6:	8b 55 08             	mov    0x8(%ebp),%edx
80103dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dcc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dd0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dd3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103dd7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ddb:	ee                   	out    %al,(%dx)
}
80103ddc:	c9                   	leave  
80103ddd:	c3                   	ret    

80103dde <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103dde:	55                   	push   %ebp
80103ddf:	89 e5                	mov    %esp,%ebp
80103de1:	83 ec 0c             	sub    $0xc,%esp
80103de4:	8b 45 08             	mov    0x8(%ebp),%eax
80103de7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103deb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103def:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103df5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103df9:	0f b6 c0             	movzbl %al,%eax
80103dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e00:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e07:	e8 b4 ff ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e0c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e10:	66 c1 e8 08          	shr    $0x8,%ax
80103e14:	0f b6 c0             	movzbl %al,%eax
80103e17:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e1b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e22:	e8 99 ff ff ff       	call   80103dc0 <outb>
}
80103e27:	c9                   	leave  
80103e28:	c3                   	ret    

80103e29 <picenable>:

void
picenable(int irq)
{
80103e29:	55                   	push   %ebp
80103e2a:	89 e5                	mov    %esp,%ebp
80103e2c:	53                   	push   %ebx
80103e2d:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e30:	8b 45 08             	mov    0x8(%ebp),%eax
80103e33:	ba 01 00 00 00       	mov    $0x1,%edx
80103e38:	89 d3                	mov    %edx,%ebx
80103e3a:	89 c1                	mov    %eax,%ecx
80103e3c:	d3 e3                	shl    %cl,%ebx
80103e3e:	89 d8                	mov    %ebx,%eax
80103e40:	89 c2                	mov    %eax,%edx
80103e42:	f7 d2                	not    %edx
80103e44:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103e4b:	21 d0                	and    %edx,%eax
80103e4d:	0f b7 c0             	movzwl %ax,%eax
80103e50:	89 04 24             	mov    %eax,(%esp)
80103e53:	e8 86 ff ff ff       	call   80103dde <picsetmask>
}
80103e58:	83 c4 04             	add    $0x4,%esp
80103e5b:	5b                   	pop    %ebx
80103e5c:	5d                   	pop    %ebp
80103e5d:	c3                   	ret    

80103e5e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e5e:	55                   	push   %ebp
80103e5f:	89 e5                	mov    %esp,%ebp
80103e61:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e64:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e6b:	00 
80103e6c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e73:	e8 48 ff ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e78:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e7f:	00 
80103e80:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e87:	e8 34 ff ff ff       	call   80103dc0 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e8c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e93:	00 
80103e94:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e9b:	e8 20 ff ff ff       	call   80103dc0 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ea0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ea7:	00 
80103ea8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eaf:	e8 0c ff ff ff       	call   80103dc0 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103eb4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ebb:	00 
80103ebc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ec3:	e8 f8 fe ff ff       	call   80103dc0 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ec8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ecf:	00 
80103ed0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ed7:	e8 e4 fe ff ff       	call   80103dc0 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103edc:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ee3:	00 
80103ee4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eeb:	e8 d0 fe ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ef0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103ef7:	00 
80103ef8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eff:	e8 bc fe ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f04:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f0b:	00 
80103f0c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f13:	e8 a8 fe ff ff       	call   80103dc0 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f18:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f1f:	00 
80103f20:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f27:	e8 94 fe ff ff       	call   80103dc0 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f2c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f33:	00 
80103f34:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f3b:	e8 80 fe ff ff       	call   80103dc0 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f40:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f47:	00 
80103f48:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f4f:	e8 6c fe ff ff       	call   80103dc0 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f54:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f5b:	00 
80103f5c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f63:	e8 58 fe ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f68:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f6f:	00 
80103f70:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f77:	e8 44 fe ff ff       	call   80103dc0 <outb>

  if(irqmask != 0xFFFF)
80103f7c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f83:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f87:	74 12                	je     80103f9b <picinit+0x13d>
    picsetmask(irqmask);
80103f89:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f90:	0f b7 c0             	movzwl %ax,%eax
80103f93:	89 04 24             	mov    %eax,(%esp)
80103f96:	e8 43 fe ff ff       	call   80103dde <picsetmask>
}
80103f9b:	c9                   	leave  
80103f9c:	c3                   	ret    
80103f9d:	00 00                	add    %al,(%eax)
	...

80103fa0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fa0:	55                   	push   %ebp
80103fa1:	89 e5                	mov    %esp,%ebp
80103fa3:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fa6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fad:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb9:	8b 10                	mov    (%eax),%edx
80103fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbe:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fc0:	e8 bf d2 ff ff       	call   80101284 <filealloc>
80103fc5:	8b 55 08             	mov    0x8(%ebp),%edx
80103fc8:	89 02                	mov    %eax,(%edx)
80103fca:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcd:	8b 00                	mov    (%eax),%eax
80103fcf:	85 c0                	test   %eax,%eax
80103fd1:	0f 84 c8 00 00 00    	je     8010409f <pipealloc+0xff>
80103fd7:	e8 a8 d2 ff ff       	call   80101284 <filealloc>
80103fdc:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fdf:	89 02                	mov    %eax,(%edx)
80103fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe4:	8b 00                	mov    (%eax),%eax
80103fe6:	85 c0                	test   %eax,%eax
80103fe8:	0f 84 b1 00 00 00    	je     8010409f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fee:	e8 74 ee ff ff       	call   80102e67 <kalloc>
80103ff3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ff6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ffa:	0f 84 9e 00 00 00    	je     8010409e <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80104000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104003:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010400a:	00 00 00 
  p->writeopen = 1;
8010400d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104010:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104017:	00 00 00 
  p->nwrite = 0;
8010401a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104024:	00 00 00 
  p->nread = 0;
80104027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104031:	00 00 00 
  initlock(&p->lock, "pipe");
80104034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104037:	c7 44 24 04 d8 8c 10 	movl   $0x80108cd8,0x4(%esp)
8010403e:	80 
8010403f:	89 04 24             	mov    %eax,(%esp)
80104042:	e8 03 13 00 00       	call   8010534a <initlock>
  (*f0)->type = FD_PIPE;
80104047:	8b 45 08             	mov    0x8(%ebp),%eax
8010404a:	8b 00                	mov    (%eax),%eax
8010404c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104052:	8b 45 08             	mov    0x8(%ebp),%eax
80104055:	8b 00                	mov    (%eax),%eax
80104057:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010405b:	8b 45 08             	mov    0x8(%ebp),%eax
8010405e:	8b 00                	mov    (%eax),%eax
80104060:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104064:	8b 45 08             	mov    0x8(%ebp),%eax
80104067:	8b 00                	mov    (%eax),%eax
80104069:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010406c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010406f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104072:	8b 00                	mov    (%eax),%eax
80104074:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010407a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407d:	8b 00                	mov    (%eax),%eax
8010407f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104083:	8b 45 0c             	mov    0xc(%ebp),%eax
80104086:	8b 00                	mov    (%eax),%eax
80104088:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010408c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408f:	8b 00                	mov    (%eax),%eax
80104091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104094:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104097:	b8 00 00 00 00       	mov    $0x0,%eax
8010409c:	eb 43                	jmp    801040e1 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010409e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010409f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040a3:	74 0b                	je     801040b0 <pipealloc+0x110>
    kfree((char*)p);
801040a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a8:	89 04 24             	mov    %eax,(%esp)
801040ab:	e8 1e ed ff ff       	call   80102dce <kfree>
  if(*f0)
801040b0:	8b 45 08             	mov    0x8(%ebp),%eax
801040b3:	8b 00                	mov    (%eax),%eax
801040b5:	85 c0                	test   %eax,%eax
801040b7:	74 0d                	je     801040c6 <pipealloc+0x126>
    fileclose(*f0);
801040b9:	8b 45 08             	mov    0x8(%ebp),%eax
801040bc:	8b 00                	mov    (%eax),%eax
801040be:	89 04 24             	mov    %eax,(%esp)
801040c1:	e8 66 d2 ff ff       	call   8010132c <fileclose>
  if(*f1)
801040c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c9:	8b 00                	mov    (%eax),%eax
801040cb:	85 c0                	test   %eax,%eax
801040cd:	74 0d                	je     801040dc <pipealloc+0x13c>
    fileclose(*f1);
801040cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d2:	8b 00                	mov    (%eax),%eax
801040d4:	89 04 24             	mov    %eax,(%esp)
801040d7:	e8 50 d2 ff ff       	call   8010132c <fileclose>
  return -1;
801040dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040e1:	c9                   	leave  
801040e2:	c3                   	ret    

801040e3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040e3:	55                   	push   %ebp
801040e4:	89 e5                	mov    %esp,%ebp
801040e6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 77 12 00 00       	call   8010536b <acquire>
  if(writable){
801040f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040f8:	74 1f                	je     80104119 <pipeclose+0x36>
    p->writeopen = 0;
801040fa:	8b 45 08             	mov    0x8(%ebp),%eax
801040fd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104104:	00 00 00 
    wakeup(&p->nread);
80104107:	8b 45 08             	mov    0x8(%ebp),%eax
8010410a:	05 34 02 00 00       	add    $0x234,%eax
8010410f:	89 04 24             	mov    %eax,(%esp)
80104112:	e8 08 10 00 00       	call   8010511f <wakeup>
80104117:	eb 1d                	jmp    80104136 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104119:	8b 45 08             	mov    0x8(%ebp),%eax
8010411c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104123:	00 00 00 
    wakeup(&p->nwrite);
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	05 38 02 00 00       	add    $0x238,%eax
8010412e:	89 04 24             	mov    %eax,(%esp)
80104131:	e8 e9 0f 00 00       	call   8010511f <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010413f:	85 c0                	test   %eax,%eax
80104141:	75 25                	jne    80104168 <pipeclose+0x85>
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010414c:	85 c0                	test   %eax,%eax
8010414e:	75 18                	jne    80104168 <pipeclose+0x85>
    release(&p->lock);
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	89 04 24             	mov    %eax,(%esp)
80104156:	e8 72 12 00 00       	call   801053cd <release>
    kfree((char*)p);
8010415b:	8b 45 08             	mov    0x8(%ebp),%eax
8010415e:	89 04 24             	mov    %eax,(%esp)
80104161:	e8 68 ec ff ff       	call   80102dce <kfree>
80104166:	eb 0b                	jmp    80104173 <pipeclose+0x90>
  } else
    release(&p->lock);
80104168:	8b 45 08             	mov    0x8(%ebp),%eax
8010416b:	89 04 24             	mov    %eax,(%esp)
8010416e:	e8 5a 12 00 00       	call   801053cd <release>
}
80104173:	c9                   	leave  
80104174:	c3                   	ret    

80104175 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104175:	55                   	push   %ebp
80104176:	89 e5                	mov    %esp,%ebp
80104178:	53                   	push   %ebx
80104179:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	89 04 24             	mov    %eax,(%esp)
80104182:	e8 e4 11 00 00       	call   8010536b <acquire>
  for(i = 0; i < n; i++){
80104187:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010418e:	e9 a6 00 00 00       	jmp    80104239 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104193:	8b 45 08             	mov    0x8(%ebp),%eax
80104196:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010419c:	85 c0                	test   %eax,%eax
8010419e:	74 0d                	je     801041ad <pipewrite+0x38>
801041a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041a6:	8b 40 24             	mov    0x24(%eax),%eax
801041a9:	85 c0                	test   %eax,%eax
801041ab:	74 15                	je     801041c2 <pipewrite+0x4d>
        release(&p->lock);
801041ad:	8b 45 08             	mov    0x8(%ebp),%eax
801041b0:	89 04 24             	mov    %eax,(%esp)
801041b3:	e8 15 12 00 00       	call   801053cd <release>
        return -1;
801041b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041bd:	e9 9d 00 00 00       	jmp    8010425f <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041c2:	8b 45 08             	mov    0x8(%ebp),%eax
801041c5:	05 34 02 00 00       	add    $0x234,%eax
801041ca:	89 04 24             	mov    %eax,(%esp)
801041cd:	e8 4d 0f 00 00       	call   8010511f <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041d2:	8b 45 08             	mov    0x8(%ebp),%eax
801041d5:	8b 55 08             	mov    0x8(%ebp),%edx
801041d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801041de:	89 44 24 04          	mov    %eax,0x4(%esp)
801041e2:	89 14 24             	mov    %edx,(%esp)
801041e5:	e8 59 0e 00 00       	call   80105043 <sleep>
801041ea:	eb 01                	jmp    801041ed <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041ec:	90                   	nop
801041ed:	8b 45 08             	mov    0x8(%ebp),%eax
801041f0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041ff:	05 00 02 00 00       	add    $0x200,%eax
80104204:	39 c2                	cmp    %eax,%edx
80104206:	74 8b                	je     80104193 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104208:	8b 45 08             	mov    0x8(%ebp),%eax
8010420b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104211:	89 c3                	mov    %eax,%ebx
80104213:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104219:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010421c:	03 55 0c             	add    0xc(%ebp),%edx
8010421f:	0f b6 0a             	movzbl (%edx),%ecx
80104222:	8b 55 08             	mov    0x8(%ebp),%edx
80104225:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104229:	8d 50 01             	lea    0x1(%eax),%edx
8010422c:	8b 45 08             	mov    0x8(%ebp),%eax
8010422f:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104235:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010423f:	7c ab                	jl     801041ec <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	05 34 02 00 00       	add    $0x234,%eax
80104249:	89 04 24             	mov    %eax,(%esp)
8010424c:	e8 ce 0e 00 00       	call   8010511f <wakeup>
  release(&p->lock);
80104251:	8b 45 08             	mov    0x8(%ebp),%eax
80104254:	89 04 24             	mov    %eax,(%esp)
80104257:	e8 71 11 00 00       	call   801053cd <release>
  return n;
8010425c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010425f:	83 c4 24             	add    $0x24,%esp
80104262:	5b                   	pop    %ebx
80104263:	5d                   	pop    %ebp
80104264:	c3                   	ret    

80104265 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104265:	55                   	push   %ebp
80104266:	89 e5                	mov    %esp,%ebp
80104268:	53                   	push   %ebx
80104269:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010426c:	8b 45 08             	mov    0x8(%ebp),%eax
8010426f:	89 04 24             	mov    %eax,(%esp)
80104272:	e8 f4 10 00 00       	call   8010536b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104277:	eb 3a                	jmp    801042b3 <piperead+0x4e>
    if(proc->killed){
80104279:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010427f:	8b 40 24             	mov    0x24(%eax),%eax
80104282:	85 c0                	test   %eax,%eax
80104284:	74 15                	je     8010429b <piperead+0x36>
      release(&p->lock);
80104286:	8b 45 08             	mov    0x8(%ebp),%eax
80104289:	89 04 24             	mov    %eax,(%esp)
8010428c:	e8 3c 11 00 00       	call   801053cd <release>
      return -1;
80104291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104296:	e9 b6 00 00 00       	jmp    80104351 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010429b:	8b 45 08             	mov    0x8(%ebp),%eax
8010429e:	8b 55 08             	mov    0x8(%ebp),%edx
801042a1:	81 c2 34 02 00 00    	add    $0x234,%edx
801042a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801042ab:	89 14 24             	mov    %edx,(%esp)
801042ae:	e8 90 0d 00 00       	call   80105043 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042b3:	8b 45 08             	mov    0x8(%ebp),%eax
801042b6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042bc:	8b 45 08             	mov    0x8(%ebp),%eax
801042bf:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c5:	39 c2                	cmp    %eax,%edx
801042c7:	75 0d                	jne    801042d6 <piperead+0x71>
801042c9:	8b 45 08             	mov    0x8(%ebp),%eax
801042cc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042d2:	85 c0                	test   %eax,%eax
801042d4:	75 a3                	jne    80104279 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042dd:	eb 49                	jmp    80104328 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042df:	8b 45 08             	mov    0x8(%ebp),%eax
801042e2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042e8:	8b 45 08             	mov    0x8(%ebp),%eax
801042eb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f1:	39 c2                	cmp    %eax,%edx
801042f3:	74 3d                	je     80104332 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f8:	89 c2                	mov    %eax,%edx
801042fa:	03 55 0c             	add    0xc(%ebp),%edx
801042fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104300:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104306:	89 c3                	mov    %eax,%ebx
80104308:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010430e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104311:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104316:	88 0a                	mov    %cl,(%edx)
80104318:	8d 50 01             	lea    0x1(%eax),%edx
8010431b:	8b 45 08             	mov    0x8(%ebp),%eax
8010431e:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104324:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010432e:	7c af                	jl     801042df <piperead+0x7a>
80104330:	eb 01                	jmp    80104333 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80104332:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104333:	8b 45 08             	mov    0x8(%ebp),%eax
80104336:	05 38 02 00 00       	add    $0x238,%eax
8010433b:	89 04 24             	mov    %eax,(%esp)
8010433e:	e8 dc 0d 00 00       	call   8010511f <wakeup>
  release(&p->lock);
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	89 04 24             	mov    %eax,(%esp)
80104349:	e8 7f 10 00 00       	call   801053cd <release>
  return i;
8010434e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104351:	83 c4 24             	add    $0x24,%esp
80104354:	5b                   	pop    %ebx
80104355:	5d                   	pop    %ebp
80104356:	c3                   	ret    
	...

80104358 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104358:	55                   	push   %ebp
80104359:	89 e5                	mov    %esp,%ebp
8010435b:	53                   	push   %ebx
8010435c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010435f:	9c                   	pushf  
80104360:	5b                   	pop    %ebx
80104361:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104364:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104367:	83 c4 10             	add    $0x10,%esp
8010436a:	5b                   	pop    %ebx
8010436b:	5d                   	pop    %ebp
8010436c:	c3                   	ret    

8010436d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010436d:	55                   	push   %ebp
8010436e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104370:	fb                   	sti    
}
80104371:	5d                   	pop    %ebp
80104372:	c3                   	ret    

80104373 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);
void
pinit(void)
{
80104373:	55                   	push   %ebp
80104374:	89 e5                	mov    %esp,%ebp
80104376:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104379:	c7 44 24 04 dd 8c 10 	movl   $0x80108cdd,0x4(%esp)
80104380:	80 
80104381:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104388:	e8 bd 0f 00 00       	call   8010534a <initlock>
}
8010438d:	c9                   	leave  
8010438e:	c3                   	ret    

8010438f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010438f:	55                   	push   %ebp
80104390:	89 e5                	mov    %esp,%ebp
80104392:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104395:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
8010439c:	e8 ca 0f 00 00       	call   8010536b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a1:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
801043a8:	eb 11                	jmp    801043bb <allocproc+0x2c>
    if(p->state == UNUSED)
801043aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ad:	8b 40 0c             	mov    0xc(%eax),%eax
801043b0:	85 c0                	test   %eax,%eax
801043b2:	74 26                	je     801043da <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043b4:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801043bb:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
801043c2:	72 e6                	jb     801043aa <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043c4:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801043cb:	e8 fd 0f 00 00       	call   801053cd <release>
  return 0;
801043d0:	b8 00 00 00 00       	mov    $0x0,%eax
801043d5:	e9 b5 00 00 00       	jmp    8010448f <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043da:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043de:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043e5:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801043ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ed:	89 42 10             	mov    %eax,0x10(%edx)
801043f0:	83 c0 01             	add    $0x1,%eax
801043f3:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  release(&ptable.lock);
801043f8:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801043ff:	e8 c9 0f 00 00       	call   801053cd <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104404:	e8 5e ea ff ff       	call   80102e67 <kalloc>
80104409:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010440c:	89 42 08             	mov    %eax,0x8(%edx)
8010440f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104412:	8b 40 08             	mov    0x8(%eax),%eax
80104415:	85 c0                	test   %eax,%eax
80104417:	75 11                	jne    8010442a <allocproc+0x9b>
    p->state = UNUSED;
80104419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104423:	b8 00 00 00 00       	mov    $0x0,%eax
80104428:	eb 65                	jmp    8010448f <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
8010442a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442d:	8b 40 08             	mov    0x8(%eax),%eax
80104430:	05 00 10 00 00       	add    $0x1000,%eax
80104435:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104438:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010443c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104442:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104445:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104449:	ba 80 6a 10 80       	mov    $0x80106a80,%edx
8010444e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104451:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104453:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010445d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104463:	8b 40 1c             	mov    0x1c(%eax),%eax
80104466:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010446d:	00 
8010446e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104475:	00 
80104476:	89 04 24             	mov    %eax,(%esp)
80104479:	e8 3c 11 00 00       	call   801055ba <memset>
  p->context->eip = (uint)forkret;
8010447e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104481:	8b 40 1c             	mov    0x1c(%eax),%eax
80104484:	ba 17 50 10 80       	mov    $0x80105017,%edx
80104489:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010448c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010448f:	c9                   	leave  
80104490:	c3                   	ret    

80104491 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104491:	55                   	push   %ebp
80104492:	89 e5                	mov    %esp,%ebp
80104494:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104497:	e8 f3 fe ff ff       	call   8010438f <allocproc>
8010449c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010449f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a2:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm(kalloc)) == 0)
801044a7:	c7 04 24 67 2e 10 80 	movl   $0x80102e67,(%esp)
801044ae:	e8 0e 3d 00 00       	call   801081c1 <setupkvm>
801044b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044b6:	89 42 04             	mov    %eax,0x4(%edx)
801044b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bc:	8b 40 04             	mov    0x4(%eax),%eax
801044bf:	85 c0                	test   %eax,%eax
801044c1:	75 0c                	jne    801044cf <userinit+0x3e>
    panic("userinit: out of memory?");
801044c3:	c7 04 24 e4 8c 10 80 	movl   $0x80108ce4,(%esp)
801044ca:	e8 6e c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044cf:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d7:	8b 40 04             	mov    0x4(%eax),%eax
801044da:	89 54 24 08          	mov    %edx,0x8(%esp)
801044de:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
801044e5:	80 
801044e6:	89 04 24             	mov    %eax,(%esp)
801044e9:	e8 2b 3f 00 00       	call   80108419 <inituvm>
  p->sz = PGSIZE;
801044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fa:	8b 40 18             	mov    0x18(%eax),%eax
801044fd:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104504:	00 
80104505:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010450c:	00 
8010450d:	89 04 24             	mov    %eax,(%esp)
80104510:	e8 a5 10 00 00       	call   801055ba <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 18             	mov    0x18(%eax),%eax
8010451b:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104524:	8b 40 18             	mov    0x18(%eax),%eax
80104527:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010452d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104530:	8b 40 18             	mov    0x18(%eax),%eax
80104533:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104536:	8b 52 18             	mov    0x18(%edx),%edx
80104539:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010453d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	8b 40 18             	mov    0x18(%eax),%eax
80104547:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010454a:	8b 52 18             	mov    0x18(%edx),%edx
8010454d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104551:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104558:	8b 40 18             	mov    0x18(%eax),%eax
8010455b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104565:	8b 40 18             	mov    0x18(%eax),%eax
80104568:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010456f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104572:	8b 40 18             	mov    0x18(%eax),%eax
80104575:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010457c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457f:	83 c0 6c             	add    $0x6c,%eax
80104582:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104589:	00 
8010458a:	c7 44 24 04 fd 8c 10 	movl   $0x80108cfd,0x4(%esp)
80104591:	80 
80104592:	89 04 24             	mov    %eax,(%esp)
80104595:	e8 50 12 00 00       	call   801057ea <safestrcpy>
  p->cwd = namei("/");
8010459a:	c7 04 24 06 8d 10 80 	movl   $0x80108d06,(%esp)
801045a1:	e8 cc e1 ff ff       	call   80102772 <namei>
801045a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a9:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
801045ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045af:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045b6:	c9                   	leave  
801045b7:	c3                   	ret    

801045b8 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045b8:	55                   	push   %ebp
801045b9:	89 e5                	mov    %esp,%ebp
801045bb:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c4:	8b 00                	mov    (%eax),%eax
801045c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045cd:	7e 34                	jle    80104603 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045cf:	8b 45 08             	mov    0x8(%ebp),%eax
801045d2:	89 c2                	mov    %eax,%edx
801045d4:	03 55 f4             	add    -0xc(%ebp),%edx
801045d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045dd:	8b 40 04             	mov    0x4(%eax),%eax
801045e0:	89 54 24 08          	mov    %edx,0x8(%esp)
801045e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801045eb:	89 04 24             	mov    %eax,(%esp)
801045ee:	e8 a0 3f 00 00       	call   80108593 <allocuvm>
801045f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045fa:	75 41                	jne    8010463d <growproc+0x85>
      return -1;
801045fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104601:	eb 58                	jmp    8010465b <growproc+0xa3>
  } else if(n < 0){
80104603:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104607:	79 34                	jns    8010463d <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104609:	8b 45 08             	mov    0x8(%ebp),%eax
8010460c:	89 c2                	mov    %eax,%edx
8010460e:	03 55 f4             	add    -0xc(%ebp),%edx
80104611:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104617:	8b 40 04             	mov    0x4(%eax),%eax
8010461a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010461e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104621:	89 54 24 04          	mov    %edx,0x4(%esp)
80104625:	89 04 24             	mov    %eax,(%esp)
80104628:	e8 40 40 00 00       	call   8010866d <deallocuvm>
8010462d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104630:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104634:	75 07                	jne    8010463d <growproc+0x85>
      return -1;
80104636:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010463b:	eb 1e                	jmp    8010465b <growproc+0xa3>
  }
  proc->sz = sz;
8010463d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104643:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104646:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104648:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464e:	89 04 24             	mov    %eax,(%esp)
80104651:	e8 5c 3c 00 00       	call   801082b2 <switchuvm>
  return 0;
80104656:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010465b:	c9                   	leave  
8010465c:	c3                   	ret    

8010465d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010465d:	55                   	push   %ebp
8010465e:	89 e5                	mov    %esp,%ebp
80104660:	57                   	push   %edi
80104661:	56                   	push   %esi
80104662:	53                   	push   %ebx
80104663:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104666:	e8 24 fd ff ff       	call   8010438f <allocproc>
8010466b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010466e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104672:	75 0a                	jne    8010467e <fork+0x21>
    return -1;
80104674:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104679:	e9 87 01 00 00       	jmp    80104805 <fork+0x1a8>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010467e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104684:	8b 10                	mov    (%eax),%edx
80104686:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468c:	8b 40 04             	mov    0x4(%eax),%eax
8010468f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104693:	89 04 24             	mov    %eax,(%esp)
80104696:	e8 62 41 00 00       	call   801087fd <copyuvm>
8010469b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010469e:	89 42 04             	mov    %eax,0x4(%edx)
801046a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a4:	8b 40 04             	mov    0x4(%eax),%eax
801046a7:	85 c0                	test   %eax,%eax
801046a9:	75 2c                	jne    801046d7 <fork+0x7a>
    kfree(np->kstack);
801046ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ae:	8b 40 08             	mov    0x8(%eax),%eax
801046b1:	89 04 24             	mov    %eax,(%esp)
801046b4:	e8 15 e7 ff ff       	call   80102dce <kfree>
    np->kstack = 0;
801046b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d2:	e9 2e 01 00 00       	jmp    80104805 <fork+0x1a8>
  }
  np->sz = proc->sz;
801046d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046dd:	8b 10                	mov    (%eax),%edx
801046df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e2:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ee:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f4:	8b 50 18             	mov    0x18(%eax),%edx
801046f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fd:	8b 40 18             	mov    0x18(%eax),%eax
80104700:	89 c3                	mov    %eax,%ebx
80104702:	b8 13 00 00 00       	mov    $0x13,%eax
80104707:	89 d7                	mov    %edx,%edi
80104709:	89 de                	mov    %ebx,%esi
8010470b:	89 c1                	mov    %eax,%ecx
8010470d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010470f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104712:	8b 40 18             	mov    0x18(%eax),%eax
80104715:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010471c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104723:	eb 3d                	jmp    80104762 <fork+0x105>
    if(proc->ofile[i])
80104725:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010472e:	83 c2 08             	add    $0x8,%edx
80104731:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104735:	85 c0                	test   %eax,%eax
80104737:	74 25                	je     8010475e <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104739:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104742:	83 c2 08             	add    $0x8,%edx
80104745:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104749:	89 04 24             	mov    %eax,(%esp)
8010474c:	e8 93 cb ff ff       	call   801012e4 <filedup>
80104751:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104754:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104757:	83 c1 08             	add    $0x8,%ecx
8010475a:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010475e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104762:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104766:	7e bd                	jle    80104725 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104768:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476e:	8b 40 68             	mov    0x68(%eax),%eax
80104771:	89 04 24             	mov    %eax,(%esp)
80104774:	e8 25 d4 ff ff       	call   80101b9e <idup>
80104779:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010477c:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
8010477f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104782:	8b 40 10             	mov    0x10(%eax),%eax
80104785:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104788:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104792:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104798:	8d 50 6c             	lea    0x6c(%eax),%edx
8010479b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479e:	83 c0 6c             	add    $0x6c,%eax
801047a1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047a8:	00 
801047a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801047ad:	89 04 24             	mov    %eax,(%esp)
801047b0:	e8 35 10 00 00       	call   801057ea <safestrcpy>
  acquire(&tickslock);
801047b5:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
801047bc:	e8 aa 0b 00 00       	call   8010536b <acquire>
  np->ctime = ticks;
801047c1:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
801047c6:	89 c2                	mov    %eax,%edx
801047c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cb:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
801047ce:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
801047d5:	e8 f3 0b 00 00       	call   801053cd <release>
  np->rtime = 0;
801047da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047dd:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047e4:	00 00 00 
      break;
    case _GRT:
      np->qvalue = 0;
      break;
    case _3Q:
      np->priority = HIGH;
801047e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ea:	c7 80 8c 00 00 00 03 	movl   $0x3,0x8c(%eax)
801047f1:	00 00 00 
      np->qvalue = 0;
801047f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f7:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801047fe:	00 00 00 
      break;
80104801:	90                   	nop
  }
  return pid;
80104802:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104805:	83 c4 2c             	add    $0x2c,%esp
80104808:	5b                   	pop    %ebx
80104809:	5e                   	pop    %esi
8010480a:	5f                   	pop    %edi
8010480b:	5d                   	pop    %ebp
8010480c:	c3                   	ret    

8010480d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010480d:	55                   	push   %ebp
8010480e:	89 e5                	mov    %esp,%ebp
80104810:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  
  if(proc == initproc)
80104813:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010481a:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010481f:	39 c2                	cmp    %eax,%edx
80104821:	75 0c                	jne    8010482f <exit+0x22>
    panic("init exiting");
80104823:	c7 04 24 08 8d 10 80 	movl   $0x80108d08,(%esp)
8010482a:	e8 0e bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010482f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104836:	eb 44                	jmp    8010487c <exit+0x6f>
    if(proc->ofile[fd]){
80104838:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104841:	83 c2 08             	add    $0x8,%edx
80104844:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104848:	85 c0                	test   %eax,%eax
8010484a:	74 2c                	je     80104878 <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010484c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104852:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104855:	83 c2 08             	add    $0x8,%edx
80104858:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010485c:	89 04 24             	mov    %eax,(%esp)
8010485f:	e8 c8 ca ff ff       	call   8010132c <fileclose>
      proc->ofile[fd] = 0;
80104864:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010486d:	83 c2 08             	add    $0x8,%edx
80104870:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104877:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104878:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010487c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104880:	7e b6                	jle    80104838 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104882:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104888:	8b 40 68             	mov    0x68(%eax),%eax
8010488b:	89 04 24             	mov    %eax,(%esp)
8010488e:	e8 f0 d4 ff ff       	call   80101d83 <iput>
  proc->cwd = 0;
80104893:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104899:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801048a0:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801048a7:	e8 bf 0a 00 00       	call   8010536b <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801048ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b2:	8b 40 14             	mov    0x14(%eax),%eax
801048b5:	89 04 24             	mov    %eax,(%esp)
801048b8:	e8 21 08 00 00       	call   801050de <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048bd:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
801048c4:	eb 3b                	jmp    80104901 <exit+0xf4>
    if(p->parent == proc){
801048c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c9:	8b 50 14             	mov    0x14(%eax),%edx
801048cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d2:	39 c2                	cmp    %eax,%edx
801048d4:	75 24                	jne    801048fa <exit+0xed>
      p->parent = initproc;
801048d6:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
801048dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048df:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e5:	8b 40 0c             	mov    0xc(%eax),%eax
801048e8:	83 f8 05             	cmp    $0x5,%eax
801048eb:	75 0d                	jne    801048fa <exit+0xed>
        wakeup1(initproc);
801048ed:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801048f2:	89 04 24             	mov    %eax,(%esp)
801048f5:	e8 e4 07 00 00       	call   801050de <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048fa:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104901:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
80104908:	72 bc                	jb     801048c6 <exit+0xb9>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->priority = -1;
8010490a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104910:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
80104917:	ff ff ff 
  acquire(&tickslock);
8010491a:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80104921:	e8 45 0a 00 00       	call   8010536b <acquire>
  proc->etime = ticks;
80104926:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492c:	8b 15 c0 3c 11 80    	mov    0x80113cc0,%edx
80104932:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
80104938:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
8010493f:	e8 89 0a 00 00       	call   801053cd <release>
  proc->state = ZOMBIE;
80104944:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104951:	e8 cc 05 00 00       	call   80104f22 <sched>
  panic("zombie exit");
80104956:	c7 04 24 15 8d 10 80 	movl   $0x80108d15,(%esp)
8010495d:	e8 db bb ff ff       	call   8010053d <panic>

80104962 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104962:	55                   	push   %ebp
80104963:	89 e5                	mov    %esp,%ebp
80104965:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104968:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
8010496f:	e8 f7 09 00 00       	call   8010536b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104974:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010497b:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
80104982:	e9 9d 00 00 00       	jmp    80104a24 <wait+0xc2>
      if(p->parent != proc)
80104987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498a:	8b 50 14             	mov    0x14(%eax),%edx
8010498d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104993:	39 c2                	cmp    %eax,%edx
80104995:	0f 85 81 00 00 00    	jne    80104a1c <wait+0xba>
        continue;
      havekids = 1;
8010499b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801049a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a5:	8b 40 0c             	mov    0xc(%eax),%eax
801049a8:	83 f8 05             	cmp    $0x5,%eax
801049ab:	75 70                	jne    80104a1d <wait+0xbb>
        // Found one.
        pid = p->pid;
801049ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b0:	8b 40 10             	mov    0x10(%eax),%eax
801049b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801049b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b9:	8b 40 08             	mov    0x8(%eax),%eax
801049bc:	89 04 24             	mov    %eax,(%esp)
801049bf:	e8 0a e4 ff ff       	call   80102dce <kfree>
        p->kstack = 0;
801049c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d1:	8b 40 04             	mov    0x4(%eax),%eax
801049d4:	89 04 24             	mov    %eax,(%esp)
801049d7:	e8 4d 3d 00 00       	call   80108729 <freevm>
        p->state = UNUSED;
801049dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049df:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801049e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e9:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fd:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a04:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104a0b:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104a12:	e8 b6 09 00 00       	call   801053cd <release>
        return pid;
80104a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a1a:	eb 56                	jmp    80104a72 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104a1c:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a1d:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104a24:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
80104a2b:	0f 82 56 ff ff ff    	jb     80104987 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104a31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a35:	74 0d                	je     80104a44 <wait+0xe2>
80104a37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3d:	8b 40 24             	mov    0x24(%eax),%eax
80104a40:	85 c0                	test   %eax,%eax
80104a42:	74 13                	je     80104a57 <wait+0xf5>
      release(&ptable.lock);
80104a44:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104a4b:	e8 7d 09 00 00       	call   801053cd <release>
      return -1;
80104a50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a55:	eb 1b                	jmp    80104a72 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a5d:	c7 44 24 04 40 0f 11 	movl   $0x80110f40,0x4(%esp)
80104a64:	80 
80104a65:	89 04 24             	mov    %eax,(%esp)
80104a68:	e8 d6 05 00 00       	call   80105043 <sleep>
  }
80104a6d:	e9 02 ff ff ff       	jmp    80104974 <wait+0x12>
}
80104a72:	c9                   	leave  
80104a73:	c3                   	ret    

80104a74 <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a74:	55                   	push   %ebp
80104a75:	89 e5                	mov    %esp,%ebp
80104a77:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a7a:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104a81:	e8 e5 08 00 00       	call   8010536b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a86:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a8d:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
80104a94:	e9 d0 00 00 00       	jmp    80104b69 <wait2+0xf5>
      if(p->parent != proc)
80104a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9c:	8b 50 14             	mov    0x14(%eax),%edx
80104a9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa5:	39 c2                	cmp    %eax,%edx
80104aa7:	0f 85 b4 00 00 00    	jne    80104b61 <wait2+0xed>
        continue;
      havekids = 1;
80104aad:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab7:	8b 40 0c             	mov    0xc(%eax),%eax
80104aba:	83 f8 05             	cmp    $0x5,%eax
80104abd:	0f 85 9f 00 00 00    	jne    80104b62 <wait2+0xee>
	*rtime = p->rtime;
80104ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac6:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104acc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104acf:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad4:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104add:	8b 40 7c             	mov    0x7c(%eax),%eax
80104ae0:	29 c2                	sub    %eax,%edx
80104ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae5:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104aeb:	29 c2                	sub    %eax,%edx
80104aed:	8b 45 08             	mov    0x8(%ebp),%eax
80104af0:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af5:	8b 40 10             	mov    0x10(%eax),%eax
80104af8:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afe:	8b 40 08             	mov    0x8(%eax),%eax
80104b01:	89 04 24             	mov    %eax,(%esp)
80104b04:	e8 c5 e2 ff ff       	call   80102dce <kfree>
        p->kstack = 0;
80104b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b16:	8b 40 04             	mov    0x4(%eax),%eax
80104b19:	89 04 24             	mov    %eax,(%esp)
80104b1c:	e8 08 3c 00 00       	call   80108729 <freevm>
        p->state = UNUSED;
80104b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b24:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b38:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b42:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b49:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b50:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104b57:	e8 71 08 00 00       	call   801053cd <release>
        return pid;
80104b5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b5f:	eb 56                	jmp    80104bb7 <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b61:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b62:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104b69:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
80104b70:	0f 82 23 ff ff ff    	jb     80104a99 <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b7a:	74 0d                	je     80104b89 <wait2+0x115>
80104b7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b82:	8b 40 24             	mov    0x24(%eax),%eax
80104b85:	85 c0                	test   %eax,%eax
80104b87:	74 13                	je     80104b9c <wait2+0x128>
      release(&ptable.lock);
80104b89:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104b90:	e8 38 08 00 00       	call   801053cd <release>
      return -1;
80104b95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b9a:	eb 1b                	jmp    80104bb7 <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba2:	c7 44 24 04 40 0f 11 	movl   $0x80110f40,0x4(%esp)
80104ba9:	80 
80104baa:	89 04 24             	mov    %eax,(%esp)
80104bad:	e8 91 04 00 00       	call   80105043 <sleep>
  }
80104bb2:	e9 cf fe ff ff       	jmp    80104a86 <wait2+0x12>
  
  
  return proc->pid;
}
80104bb7:	c9                   	leave  
80104bb8:	c3                   	ret    

80104bb9 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104bb9:	55                   	push   %ebp
80104bba:	89 e5                	mov    %esp,%ebp
80104bbc:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104bbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc5:	8b 40 18             	mov    0x18(%eax),%eax
80104bc8:	8b 40 44             	mov    0x44(%eax),%eax
80104bcb:	89 c2                	mov    %eax,%edx
80104bcd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd3:	8b 40 04             	mov    0x4(%eax),%eax
80104bd6:	89 54 24 04          	mov    %edx,0x4(%esp)
80104bda:	89 04 24             	mov    %eax,(%esp)
80104bdd:	e8 2c 3d 00 00       	call   8010890e <uva2ka>
80104be2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104be5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104beb:	8b 40 18             	mov    0x18(%eax),%eax
80104bee:	8b 40 44             	mov    0x44(%eax),%eax
80104bf1:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bf6:	85 c0                	test   %eax,%eax
80104bf8:	75 0c                	jne    80104c06 <register_handler+0x4d>
    panic("esp_offset == 0");
80104bfa:	c7 04 24 21 8d 10 80 	movl   $0x80108d21,(%esp)
80104c01:	e8 37 b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104c06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c0c:	8b 40 18             	mov    0x18(%eax),%eax
80104c0f:	8b 40 44             	mov    0x44(%eax),%eax
80104c12:	83 e8 04             	sub    $0x4,%eax
80104c15:	25 ff 0f 00 00       	and    $0xfff,%eax
80104c1a:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104c1d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c24:	8b 52 18             	mov    0x18(%edx),%edx
80104c27:	8b 52 38             	mov    0x38(%edx),%edx
80104c2a:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104c2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c32:	8b 40 18             	mov    0x18(%eax),%eax
80104c35:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c3c:	8b 52 18             	mov    0x18(%edx),%edx
80104c3f:	8b 52 44             	mov    0x44(%edx),%edx
80104c42:	83 ea 04             	sub    $0x4,%edx
80104c45:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104c48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c4e:	8b 40 18             	mov    0x18(%eax),%eax
80104c51:	8b 55 08             	mov    0x8(%ebp),%edx
80104c54:	89 50 38             	mov    %edx,0x38(%eax)
}
80104c57:	c9                   	leave  
80104c58:	c3                   	ret    

80104c59 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c59:	55                   	push   %ebp
80104c5a:	89 e5                	mov    %esp,%ebp
80104c5c:	53                   	push   %ebx
80104c5d:	83 ec 54             	sub    $0x54,%esp
  struct proc *p;
  struct proc *medium;
  struct proc *high;
  struct proc *head = 0;
80104c60:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  struct proc *t;
  
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c67:	e8 01 f7 ff ff       	call   8010436d <sti>
    int highflag = 0;
80104c6c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    int mediumflag = 0;
80104c73:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    int lowflag = 0;
80104c7a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    uint frr_min = 0;
80104c81:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    uint grt_min = 0;
80104c88:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
    if(head)
80104c8f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104c93:	74 0d                	je     80104ca2 <scheduler+0x49>
      t = ++head;
80104c95:	81 45 e8 94 00 00 00 	addl   $0x94,-0x18(%ebp)
80104c9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    acquire(&ptable.lock); 
80104ca2:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104ca9:	e8 bd 06 00 00       	call   8010536b <acquire>
    t = ptable.proc;
80104cae:	c7 45 e4 74 0f 11 80 	movl   $0x80110f74,-0x1c(%ebp)
    // Loop over process table looking for process to run.
    //for(t = ptable.proc; t < &ptable.proc[NPROC]; t++)
    int i=0;
80104cb5:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
    for(; i<NPROC; i++)
80104cbc:	e9 a9 01 00 00       	jmp    80104e6a <scheduler+0x211>
    {
      if(t >= &ptable.proc[NPROC])
80104cc1:	81 7d e4 74 34 11 80 	cmpl   $0x80113474,-0x1c(%ebp)
80104cc8:	72 07                	jb     80104cd1 <scheduler+0x78>
	t = ptable.proc;
80104cca:	c7 45 e4 74 0f 11 80 	movl   $0x80110f74,-0x1c(%ebp)
      if(t->state != RUNNABLE)
80104cd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cd4:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd7:	83 f8 03             	cmp    $0x3,%eax
80104cda:	0f 84 cd 00 00 00    	je     80104dad <scheduler+0x154>
      {
	t++;
80104ce0:	81 45 e4 94 00 00 00 	addl   $0x94,-0x1c(%ebp)
	continue;
80104ce7:	e9 7a 01 00 00       	jmp    80104e66 <scheduler+0x20d>
	  break;
	case _FRR:
FRR:	  t->quanta = QUANTA;
	  if(!frr_min)
	  {
	    frr_min = t->qvalue;
80104cec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cef:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104cf5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	    medium = t;
80104cf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  else if(t->qvalue < frr_min)
	  {
	    frr_min = t->qvalue;
	    medium = t;
	  }
	  break;
80104cfe:	e9 55 01 00 00       	jmp    80104e58 <scheduler+0x1ff>
	  if(!frr_min)
	  {
	    frr_min = t->qvalue;
	    medium = t;
	  }
	  else if(t->qvalue < frr_min)
80104d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d06:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d0c:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
80104d0f:	0f 83 43 01 00 00    	jae    80104e58 <scheduler+0x1ff>
	  {
	    frr_min = t->qvalue;
80104d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d18:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	    medium = t;
80104d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d24:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  }
	  break;
80104d27:	e9 2c 01 00 00       	jmp    80104e58 <scheduler+0x1ff>
	case _GRT:
GRT:	  acquire(&tickslock);
	  if(t->ctime!=ticks)
	  {
	    t->qvalue = t->rtime/(ticks-t->ctime);
80104d2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d2f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104d35:	8b 0d c0 3c 11 80    	mov    0x80113cc0,%ecx
80104d3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d3e:	8b 52 7c             	mov    0x7c(%edx),%edx
80104d41:	89 cb                	mov    %ecx,%ebx
80104d43:	29 d3                	sub    %edx,%ebx
80104d45:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
80104d48:	ba 00 00 00 00       	mov    $0x0,%edx
80104d4d:	f7 75 c4             	divl   -0x3c(%ebp)
80104d50:	89 c2                	mov    %eax,%edx
80104d52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d55:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
	  }
	  release(&tickslock);
80104d5b:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80104d62:	e8 66 06 00 00       	call   801053cd <release>
	  if(!grt_min)
80104d67:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80104d6b:	75 17                	jne    80104d84 <scheduler+0x12b>
	  {
	    grt_min = t->qvalue;
80104d6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d70:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d76:	89 45 d0             	mov    %eax,-0x30(%ebp)
	    high = t;
80104d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  else if(t->qvalue < grt_min)
	  {
	    grt_min = t->qvalue;
	    high = t;
	  }
	  break;
80104d7f:	e9 d7 00 00 00       	jmp    80104e5b <scheduler+0x202>
	  if(!grt_min)
	  {
	    grt_min = t->qvalue;
	    high = t;
	  }
	  else if(t->qvalue < grt_min)
80104d84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d87:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d8d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
80104d90:	0f 83 c5 00 00 00    	jae    80104e5b <scheduler+0x202>
	  {
	    grt_min = t->qvalue;
80104d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d99:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	    high = t;
80104da2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104da5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  }
	  break;
80104da8:	e9 ae 00 00 00       	jmp    80104e5b <scheduler+0x202>
	case _3Q:
	  if(t->priority == HIGH || t->priority == 0)
80104dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104db0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104db6:	83 f8 03             	cmp    $0x3,%eax
80104db9:	74 0d                	je     80104dc8 <scheduler+0x16f>
80104dbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104dbe:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104dc4:	85 c0                	test   %eax,%eax
80104dc6:	75 2e                	jne    80104df6 <scheduler+0x19d>
	  {
	    highflag = 1;
80104dc8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
	    goto GRT;
80104dcf:	90                   	nop
	    frr_min = t->qvalue;
	    medium = t;
	  }
	  break;
	case _GRT:
GRT:	  acquire(&tickslock);
80104dd0:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80104dd7:	e8 8f 05 00 00       	call   8010536b <acquire>
	  if(t->ctime!=ticks)
80104ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ddf:	8b 40 7c             	mov    0x7c(%eax),%eax
80104de2:	89 c2                	mov    %eax,%edx
80104de4:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
80104de9:	39 c2                	cmp    %eax,%edx
80104deb:	0f 84 6a ff ff ff    	je     80104d5b <scheduler+0x102>
80104df1:	e9 36 ff ff ff       	jmp    80104d2c <scheduler+0xd3>
	  if(t->priority == HIGH || t->priority == 0)
	  {
	    highflag = 1;
	    goto GRT;
	  }
	  else if(t->priority == MEDIUM)
80104df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104df9:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104dff:	83 f8 02             	cmp    $0x2,%eax
80104e02:	75 24                	jne    80104e28 <scheduler+0x1cf>
	  {
	    mediumflag = 1;
80104e04:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
	    goto FRR;
80104e0b:	90                   	nop
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
	  break;
	case _FRR:
FRR:	  t->quanta = QUANTA;
80104e0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e0f:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104e16:	00 00 00 
	  if(!frr_min)
80104e19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80104e1d:	0f 85 e0 fe ff ff    	jne    80104d03 <scheduler+0xaa>
80104e23:	e9 c4 fe ff ff       	jmp    80104cec <scheduler+0x93>
	  else if(t->priority == MEDIUM)
	  {
	    mediumflag = 1;
	    goto FRR;
	  }
	  else if(!lowflag && t->priority == LOW)	// low - no proc has been choosen yet
80104e28:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80104e2c:	75 30                	jne    80104e5e <scheduler+0x205>
80104e2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e31:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104e37:	83 f8 01             	cmp    $0x1,%eax
80104e3a:	75 22                	jne    80104e5e <scheduler+0x205>
	  {
	    head=t;
80104e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    lowflag = 1;
80104e42:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
	    t->quanta = QUANTA;
80104e49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e4c:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104e53:	00 00 00 
	  }
	  break;
80104e56:	eb 06                	jmp    80104e5e <scheduler+0x205>
	  else if(t->qvalue < frr_min)
	  {
	    frr_min = t->qvalue;
	    medium = t;
	  }
	  break;
80104e58:	90                   	nop
80104e59:	eb 04                	jmp    80104e5f <scheduler+0x206>
	  else if(t->qvalue < grt_min)
	  {
	    grt_min = t->qvalue;
	    high = t;
	  }
	  break;
80104e5b:	90                   	nop
80104e5c:	eb 01                	jmp    80104e5f <scheduler+0x206>
	  {
	    head=t;
	    lowflag = 1;
	    t->quanta = QUANTA;
	  }
	  break;
80104e5e:	90                   	nop
      }
      t++;
80104e5f:	81 45 e4 94 00 00 00 	addl   $0x94,-0x1c(%ebp)
    acquire(&ptable.lock); 
    t = ptable.proc;
    // Loop over process table looking for process to run.
    //for(t = ptable.proc; t < &ptable.proc[NPROC]; t++)
    int i=0;
    for(; i<NPROC; i++)
80104e66:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
80104e6a:	83 7d cc 3f          	cmpl   $0x3f,-0x34(%ebp)
80104e6e:	0f 8e 4d fe ff ff    	jle    80104cc1 <scheduler+0x68>
	p = medium;
      else if(SCHEDFLAG == _GRT)
	p = high;
      else
      {
	if(highflag && high)
80104e74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104e78:	74 0e                	je     80104e88 <scheduler+0x22f>
80104e7a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104e7e:	74 08                	je     80104e88 <scheduler+0x22f>
	  p = high;
80104e80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e86:	eb 2b                	jmp    80104eb3 <scheduler+0x25a>
	else if(mediumflag && medium)
80104e88:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104e8c:	74 0e                	je     80104e9c <scheduler+0x243>
80104e8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e92:	74 08                	je     80104e9c <scheduler+0x243>
	  p = medium;
80104e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e9a:	eb 17                	jmp    80104eb3 <scheduler+0x25a>
	else if(head)
80104e9c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104ea0:	74 11                	je     80104eb3 <scheduler+0x25a>
	  if(head->state == RUNNABLE)
80104ea2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ea5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea8:	83 f8 03             	cmp    $0x3,%eax
80104eab:	75 06                	jne    80104eb3 <scheduler+0x25a>
	    p = head;
80104ead:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104eb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
      }     

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      if(p)
80104eb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104eb7:	74 58                	je     80104f11 <scheduler+0x2b8>
	if(p->state == RUNNABLE)
80104eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebc:	8b 40 0c             	mov    0xc(%eax),%eax
80104ebf:	83 f8 03             	cmp    $0x3,%eax
80104ec2:	75 4d                	jne    80104f11 <scheduler+0x2b8>
      { 

	proc = p;
80104ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec7:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	switchuvm(p);
80104ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed0:	89 04 24             	mov    %eax,(%esp)
80104ed3:	e8 da 33 00 00       	call   801082b2 <switchuvm>
	p->state = RUNNING;
80104ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104edb:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	swtch(&cpu->scheduler, proc->context);
80104ee2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee8:	8b 40 1c             	mov    0x1c(%eax),%eax
80104eeb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ef2:	83 c2 04             	add    $0x4,%edx
80104ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ef9:	89 14 24             	mov    %edx,(%esp)
80104efc:	e8 5f 09 00 00       	call   80105860 <swtch>
	switchkvm();
80104f01:	e8 8f 33 00 00       	call   80108295 <switchkvm>
	// Process is done running for now.
	// It should have changed its p->state before coming back.
      proc = 0;
80104f06:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104f0d:	00 00 00 00 
      }
    }
    release(&ptable.lock);
80104f11:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104f18:	e8 b0 04 00 00       	call   801053cd <release>
    }
80104f1d:	e9 45 fd ff ff       	jmp    80104c67 <scheduler+0xe>

80104f22 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104f22:	55                   	push   %ebp
80104f23:	89 e5                	mov    %esp,%ebp
80104f25:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104f28:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104f2f:	e8 55 05 00 00       	call   80105489 <holding>
80104f34:	85 c0                	test   %eax,%eax
80104f36:	75 0c                	jne    80104f44 <sched+0x22>
    panic("sched ptable.lock");
80104f38:	c7 04 24 31 8d 10 80 	movl   $0x80108d31,(%esp)
80104f3f:	e8 f9 b5 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104f44:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f4a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f50:	83 f8 01             	cmp    $0x1,%eax
80104f53:	74 0c                	je     80104f61 <sched+0x3f>
    panic("sched locks");
80104f55:	c7 04 24 43 8d 10 80 	movl   $0x80108d43,(%esp)
80104f5c:	e8 dc b5 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104f61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f67:	8b 40 0c             	mov    0xc(%eax),%eax
80104f6a:	83 f8 04             	cmp    $0x4,%eax
80104f6d:	75 0c                	jne    80104f7b <sched+0x59>
    panic("sched running");
80104f6f:	c7 04 24 4f 8d 10 80 	movl   $0x80108d4f,(%esp)
80104f76:	e8 c2 b5 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104f7b:	e8 d8 f3 ff ff       	call   80104358 <readeflags>
80104f80:	25 00 02 00 00       	and    $0x200,%eax
80104f85:	85 c0                	test   %eax,%eax
80104f87:	74 0c                	je     80104f95 <sched+0x73>
    panic("sched interruptible");
80104f89:	c7 04 24 5d 8d 10 80 	movl   $0x80108d5d,(%esp)
80104f90:	e8 a8 b5 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104f95:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f9b:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104fa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104fa4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104faa:	8b 40 04             	mov    0x4(%eax),%eax
80104fad:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fb4:	83 c2 1c             	add    $0x1c,%edx
80104fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fbb:	89 14 24             	mov    %edx,(%esp)
80104fbe:	e8 9d 08 00 00       	call   80105860 <swtch>
  cpu->intena = intena;
80104fc3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fcc:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104fd2:	c9                   	leave  
80104fd3:	c3                   	ret    

80104fd4 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104fd4:	55                   	push   %ebp
80104fd5:	89 e5                	mov    %esp,%ebp
80104fd7:	83 ec 18             	sub    $0x18,%esp
      break;
    case _GRT:
      proc->quanta = 0;
      break;
    case _3Q:
      proc->quanta = 0;
80104fda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fe0:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104fe7:	00 00 00 
      break;
80104fea:	90                   	nop
  }
  acquire(&ptable.lock);  //DOC: yieldlock
80104feb:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104ff2:	e8 74 03 00 00       	call   8010536b <acquire>
  proc->state = RUNNABLE;
80104ff7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ffd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105004:	e8 19 ff ff ff       	call   80104f22 <sched>
  release(&ptable.lock);
80105009:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105010:	e8 b8 03 00 00       	call   801053cd <release>
  
}
80105015:	c9                   	leave  
80105016:	c3                   	ret    

80105017 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105017:	55                   	push   %ebp
80105018:	89 e5                	mov    %esp,%ebp
8010501a:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010501d:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105024:	e8 a4 03 00 00       	call   801053cd <release>

  if (first) {
80105029:	a1 20 c0 10 80       	mov    0x8010c020,%eax
8010502e:	85 c0                	test   %eax,%eax
80105030:	74 0f                	je     80105041 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105032:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80105039:	00 00 00 
    initlog();
8010503c:	e8 37 e3 ff ff       	call   80103378 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105041:	c9                   	leave  
80105042:	c3                   	ret    

80105043 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105043:	55                   	push   %ebp
80105044:	89 e5                	mov    %esp,%ebp
80105046:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80105049:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010504f:	85 c0                	test   %eax,%eax
80105051:	75 0c                	jne    8010505f <sleep+0x1c>
    panic("sleep");
80105053:	c7 04 24 71 8d 10 80 	movl   $0x80108d71,(%esp)
8010505a:	e8 de b4 ff ff       	call   8010053d <panic>

  if(lk == 0)
8010505f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105063:	75 0c                	jne    80105071 <sleep+0x2e>
    panic("sleep without lk");
80105065:	c7 04 24 77 8d 10 80 	movl   $0x80108d77,(%esp)
8010506c:	e8 cc b4 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105071:	81 7d 0c 40 0f 11 80 	cmpl   $0x80110f40,0xc(%ebp)
80105078:	74 17                	je     80105091 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010507a:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105081:	e8 e5 02 00 00       	call   8010536b <acquire>
    release(lk);
80105086:	8b 45 0c             	mov    0xc(%ebp),%eax
80105089:	89 04 24             	mov    %eax,(%esp)
8010508c:	e8 3c 03 00 00       	call   801053cd <release>
  }

  // Go to sleep.
  proc->chan = chan;
80105091:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105097:	8b 55 08             	mov    0x8(%ebp),%edx
8010509a:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010509d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801050aa:	e8 73 fe ff ff       	call   80104f22 <sched>

  // Tidy up.
  proc->chan = 0;
801050af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b5:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801050bc:	81 7d 0c 40 0f 11 80 	cmpl   $0x80110f40,0xc(%ebp)
801050c3:	74 17                	je     801050dc <sleep+0x99>
    release(&ptable.lock);
801050c5:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801050cc:	e8 fc 02 00 00       	call   801053cd <release>
    acquire(lk);
801050d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d4:	89 04 24             	mov    %eax,(%esp)
801050d7:	e8 8f 02 00 00       	call   8010536b <acquire>
  }
}
801050dc:	c9                   	leave  
801050dd:	c3                   	ret    

801050de <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801050de:	55                   	push   %ebp
801050df:	89 e5                	mov    %esp,%ebp
801050e1:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050e4:	c7 45 fc 74 0f 11 80 	movl   $0x80110f74,-0x4(%ebp)
801050eb:	eb 27                	jmp    80105114 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801050ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050f0:	8b 40 0c             	mov    0xc(%eax),%eax
801050f3:	83 f8 02             	cmp    $0x2,%eax
801050f6:	75 15                	jne    8010510d <wakeup1+0x2f>
801050f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050fb:	8b 40 20             	mov    0x20(%eax),%eax
801050fe:	3b 45 08             	cmp    0x8(%ebp),%eax
80105101:	75 0a                	jne    8010510d <wakeup1+0x2f>
      p->state = RUNNABLE;
80105103:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105106:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010510d:	81 45 fc 94 00 00 00 	addl   $0x94,-0x4(%ebp)
80105114:	81 7d fc 74 34 11 80 	cmpl   $0x80113474,-0x4(%ebp)
8010511b:	72 d0                	jb     801050ed <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010511d:	c9                   	leave  
8010511e:	c3                   	ret    

8010511f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010511f:	55                   	push   %ebp
80105120:	89 e5                	mov    %esp,%ebp
80105122:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80105125:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
8010512c:	e8 3a 02 00 00       	call   8010536b <acquire>
  wakeup1(chan);
80105131:	8b 45 08             	mov    0x8(%ebp),%eax
80105134:	89 04 24             	mov    %eax,(%esp)
80105137:	e8 a2 ff ff ff       	call   801050de <wakeup1>
  release(&ptable.lock);
8010513c:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105143:	e8 85 02 00 00       	call   801053cd <release>
}
80105148:	c9                   	leave  
80105149:	c3                   	ret    

8010514a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010514a:	55                   	push   %ebp
8010514b:	89 e5                	mov    %esp,%ebp
8010514d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105150:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105157:	e8 0f 02 00 00       	call   8010536b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010515c:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
80105163:	eb 44                	jmp    801051a9 <kill+0x5f>
    if(p->pid == pid){
80105165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105168:	8b 40 10             	mov    0x10(%eax),%eax
8010516b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010516e:	75 32                	jne    801051a2 <kill+0x58>
      p->killed = 1;
80105170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105173:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010517a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517d:	8b 40 0c             	mov    0xc(%eax),%eax
80105180:	83 f8 02             	cmp    $0x2,%eax
80105183:	75 0a                	jne    8010518f <kill+0x45>
        p->state = RUNNABLE;
80105185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105188:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010518f:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105196:	e8 32 02 00 00       	call   801053cd <release>
      return 0;
8010519b:	b8 00 00 00 00       	mov    $0x0,%eax
801051a0:	eb 21                	jmp    801051c3 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051a2:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801051a9:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
801051b0:	72 b3                	jb     80105165 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801051b2:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801051b9:	e8 0f 02 00 00       	call   801053cd <release>
  return -1;
801051be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801051c3:	c9                   	leave  
801051c4:	c3                   	ret    

801051c5 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801051c5:	55                   	push   %ebp
801051c6:	89 e5                	mov    %esp,%ebp
801051c8:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051cb:	c7 45 f0 74 0f 11 80 	movl   $0x80110f74,-0x10(%ebp)
801051d2:	e9 db 00 00 00       	jmp    801052b2 <procdump+0xed>
    if(p->state == UNUSED)
801051d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051da:	8b 40 0c             	mov    0xc(%eax),%eax
801051dd:	85 c0                	test   %eax,%eax
801051df:	0f 84 c5 00 00 00    	je     801052aa <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801051e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e8:	8b 40 0c             	mov    0xc(%eax),%eax
801051eb:	83 f8 05             	cmp    $0x5,%eax
801051ee:	77 23                	ja     80105213 <procdump+0x4e>
801051f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f3:	8b 40 0c             	mov    0xc(%eax),%eax
801051f6:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801051fd:	85 c0                	test   %eax,%eax
801051ff:	74 12                	je     80105213 <procdump+0x4e>
      state = states[p->state];
80105201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105204:	8b 40 0c             	mov    0xc(%eax),%eax
80105207:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010520e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105211:	eb 07                	jmp    8010521a <procdump+0x55>
    else
      state = "???";
80105213:	c7 45 ec 88 8d 10 80 	movl   $0x80108d88,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010521a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521d:	8d 50 6c             	lea    0x6c(%eax),%edx
80105220:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105223:	8b 40 10             	mov    0x10(%eax),%eax
80105226:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010522a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010522d:	89 54 24 08          	mov    %edx,0x8(%esp)
80105231:	89 44 24 04          	mov    %eax,0x4(%esp)
80105235:	c7 04 24 8c 8d 10 80 	movl   $0x80108d8c,(%esp)
8010523c:	e8 60 b1 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80105241:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105244:	8b 40 0c             	mov    0xc(%eax),%eax
80105247:	83 f8 02             	cmp    $0x2,%eax
8010524a:	75 50                	jne    8010529c <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010524c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105252:	8b 40 0c             	mov    0xc(%eax),%eax
80105255:	83 c0 08             	add    $0x8,%eax
80105258:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010525b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010525f:	89 04 24             	mov    %eax,(%esp)
80105262:	e8 b5 01 00 00       	call   8010541c <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105267:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010526e:	eb 1b                	jmp    8010528b <procdump+0xc6>
        cprintf(" %p", pc[i]);
80105270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105273:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105277:	89 44 24 04          	mov    %eax,0x4(%esp)
8010527b:	c7 04 24 95 8d 10 80 	movl   $0x80108d95,(%esp)
80105282:	e8 1a b1 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105287:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010528b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010528f:	7f 0b                	jg     8010529c <procdump+0xd7>
80105291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105294:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105298:	85 c0                	test   %eax,%eax
8010529a:	75 d4                	jne    80105270 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010529c:	c7 04 24 99 8d 10 80 	movl   $0x80108d99,(%esp)
801052a3:	e8 f9 b0 ff ff       	call   801003a1 <cprintf>
801052a8:	eb 01                	jmp    801052ab <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801052aa:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052ab:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
801052b2:	81 7d f0 74 34 11 80 	cmpl   $0x80113474,-0x10(%ebp)
801052b9:	0f 82 18 ff ff ff    	jb     801051d7 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801052bf:	c9                   	leave  
801052c0:	c3                   	ret    

801052c1 <nice>:

int
nice(void)
{
801052c1:	55                   	push   %ebp
801052c2:	89 e5                	mov    %esp,%ebp
  if(proc)
801052c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ca:	85 c0                	test   %eax,%eax
801052cc:	74 2d                	je     801052fb <nice+0x3a>
  {
    if(proc->priority>1)
801052ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052d4:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801052da:	83 f8 01             	cmp    $0x1,%eax
801052dd:	7e 1c                	jle    801052fb <nice+0x3a>
    {
      proc->priority--;
801052df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052e5:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801052eb:	83 ea 01             	sub    $0x1,%edx
801052ee:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      return 0;
801052f4:	b8 00 00 00 00       	mov    $0x0,%eax
801052f9:	eb 05                	jmp    80105300 <nice+0x3f>
    }
  }
  return -1;
801052fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105300:	5d                   	pop    %ebp
80105301:	c3                   	ret    
	...

80105304 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105304:	55                   	push   %ebp
80105305:	89 e5                	mov    %esp,%ebp
80105307:	53                   	push   %ebx
80105308:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010530b:	9c                   	pushf  
8010530c:	5b                   	pop    %ebx
8010530d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105310:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105313:	83 c4 10             	add    $0x10,%esp
80105316:	5b                   	pop    %ebx
80105317:	5d                   	pop    %ebp
80105318:	c3                   	ret    

80105319 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105319:	55                   	push   %ebp
8010531a:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010531c:	fa                   	cli    
}
8010531d:	5d                   	pop    %ebp
8010531e:	c3                   	ret    

8010531f <sti>:

static inline void
sti(void)
{
8010531f:	55                   	push   %ebp
80105320:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105322:	fb                   	sti    
}
80105323:	5d                   	pop    %ebp
80105324:	c3                   	ret    

80105325 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105325:	55                   	push   %ebp
80105326:	89 e5                	mov    %esp,%ebp
80105328:	53                   	push   %ebx
80105329:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
8010532c:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010532f:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105332:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105335:	89 c3                	mov    %eax,%ebx
80105337:	89 d8                	mov    %ebx,%eax
80105339:	f0 87 02             	lock xchg %eax,(%edx)
8010533c:	89 c3                	mov    %eax,%ebx
8010533e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105341:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105344:	83 c4 10             	add    $0x10,%esp
80105347:	5b                   	pop    %ebx
80105348:	5d                   	pop    %ebp
80105349:	c3                   	ret    

8010534a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010534a:	55                   	push   %ebp
8010534b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010534d:	8b 45 08             	mov    0x8(%ebp),%eax
80105350:	8b 55 0c             	mov    0xc(%ebp),%edx
80105353:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105356:	8b 45 08             	mov    0x8(%ebp),%eax
80105359:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010535f:	8b 45 08             	mov    0x8(%ebp),%eax
80105362:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105369:	5d                   	pop    %ebp
8010536a:	c3                   	ret    

8010536b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010536b:	55                   	push   %ebp
8010536c:	89 e5                	mov    %esp,%ebp
8010536e:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105371:	e8 3d 01 00 00       	call   801054b3 <pushcli>
  if(holding(lk))
80105376:	8b 45 08             	mov    0x8(%ebp),%eax
80105379:	89 04 24             	mov    %eax,(%esp)
8010537c:	e8 08 01 00 00       	call   80105489 <holding>
80105381:	85 c0                	test   %eax,%eax
80105383:	74 0c                	je     80105391 <acquire+0x26>
    panic("acquire");
80105385:	c7 04 24 c5 8d 10 80 	movl   $0x80108dc5,(%esp)
8010538c:	e8 ac b1 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105391:	90                   	nop
80105392:	8b 45 08             	mov    0x8(%ebp),%eax
80105395:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010539c:	00 
8010539d:	89 04 24             	mov    %eax,(%esp)
801053a0:	e8 80 ff ff ff       	call   80105325 <xchg>
801053a5:	85 c0                	test   %eax,%eax
801053a7:	75 e9                	jne    80105392 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801053a9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ac:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801053b3:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801053b6:	8b 45 08             	mov    0x8(%ebp),%eax
801053b9:	83 c0 0c             	add    $0xc,%eax
801053bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801053c0:	8d 45 08             	lea    0x8(%ebp),%eax
801053c3:	89 04 24             	mov    %eax,(%esp)
801053c6:	e8 51 00 00 00       	call   8010541c <getcallerpcs>
}
801053cb:	c9                   	leave  
801053cc:	c3                   	ret    

801053cd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801053cd:	55                   	push   %ebp
801053ce:	89 e5                	mov    %esp,%ebp
801053d0:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801053d3:	8b 45 08             	mov    0x8(%ebp),%eax
801053d6:	89 04 24             	mov    %eax,(%esp)
801053d9:	e8 ab 00 00 00       	call   80105489 <holding>
801053de:	85 c0                	test   %eax,%eax
801053e0:	75 0c                	jne    801053ee <release+0x21>
    panic("release");
801053e2:	c7 04 24 cd 8d 10 80 	movl   $0x80108dcd,(%esp)
801053e9:	e8 4f b1 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
801053ee:	8b 45 08             	mov    0x8(%ebp),%eax
801053f1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801053f8:	8b 45 08             	mov    0x8(%ebp),%eax
801053fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105402:	8b 45 08             	mov    0x8(%ebp),%eax
80105405:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010540c:	00 
8010540d:	89 04 24             	mov    %eax,(%esp)
80105410:	e8 10 ff ff ff       	call   80105325 <xchg>

  popcli();
80105415:	e8 e1 00 00 00       	call   801054fb <popcli>
}
8010541a:	c9                   	leave  
8010541b:	c3                   	ret    

8010541c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010541c:	55                   	push   %ebp
8010541d:	89 e5                	mov    %esp,%ebp
8010541f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105422:	8b 45 08             	mov    0x8(%ebp),%eax
80105425:	83 e8 08             	sub    $0x8,%eax
80105428:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010542b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105432:	eb 32                	jmp    80105466 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105434:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105438:	74 47                	je     80105481 <getcallerpcs+0x65>
8010543a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105441:	76 3e                	jbe    80105481 <getcallerpcs+0x65>
80105443:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105447:	74 38                	je     80105481 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105449:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010544c:	c1 e0 02             	shl    $0x2,%eax
8010544f:	03 45 0c             	add    0xc(%ebp),%eax
80105452:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105455:	8b 52 04             	mov    0x4(%edx),%edx
80105458:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
8010545a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010545d:	8b 00                	mov    (%eax),%eax
8010545f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105462:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105466:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010546a:	7e c8                	jle    80105434 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010546c:	eb 13                	jmp    80105481 <getcallerpcs+0x65>
    pcs[i] = 0;
8010546e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105471:	c1 e0 02             	shl    $0x2,%eax
80105474:	03 45 0c             	add    0xc(%ebp),%eax
80105477:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010547d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105481:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105485:	7e e7                	jle    8010546e <getcallerpcs+0x52>
    pcs[i] = 0;
}
80105487:	c9                   	leave  
80105488:	c3                   	ret    

80105489 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105489:	55                   	push   %ebp
8010548a:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010548c:	8b 45 08             	mov    0x8(%ebp),%eax
8010548f:	8b 00                	mov    (%eax),%eax
80105491:	85 c0                	test   %eax,%eax
80105493:	74 17                	je     801054ac <holding+0x23>
80105495:	8b 45 08             	mov    0x8(%ebp),%eax
80105498:	8b 50 08             	mov    0x8(%eax),%edx
8010549b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054a1:	39 c2                	cmp    %eax,%edx
801054a3:	75 07                	jne    801054ac <holding+0x23>
801054a5:	b8 01 00 00 00       	mov    $0x1,%eax
801054aa:	eb 05                	jmp    801054b1 <holding+0x28>
801054ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054b1:	5d                   	pop    %ebp
801054b2:	c3                   	ret    

801054b3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054b3:	55                   	push   %ebp
801054b4:	89 e5                	mov    %esp,%ebp
801054b6:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801054b9:	e8 46 fe ff ff       	call   80105304 <readeflags>
801054be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801054c1:	e8 53 fe ff ff       	call   80105319 <cli>
  if(cpu->ncli++ == 0)
801054c6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054cc:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801054d2:	85 d2                	test   %edx,%edx
801054d4:	0f 94 c1             	sete   %cl
801054d7:	83 c2 01             	add    $0x1,%edx
801054da:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801054e0:	84 c9                	test   %cl,%cl
801054e2:	74 15                	je     801054f9 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
801054e4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054ed:	81 e2 00 02 00 00    	and    $0x200,%edx
801054f3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801054f9:	c9                   	leave  
801054fa:	c3                   	ret    

801054fb <popcli>:

void
popcli(void)
{
801054fb:	55                   	push   %ebp
801054fc:	89 e5                	mov    %esp,%ebp
801054fe:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105501:	e8 fe fd ff ff       	call   80105304 <readeflags>
80105506:	25 00 02 00 00       	and    $0x200,%eax
8010550b:	85 c0                	test   %eax,%eax
8010550d:	74 0c                	je     8010551b <popcli+0x20>
    panic("popcli - interruptible");
8010550f:	c7 04 24 d5 8d 10 80 	movl   $0x80108dd5,(%esp)
80105516:	e8 22 b0 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
8010551b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105521:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105527:	83 ea 01             	sub    $0x1,%edx
8010552a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105530:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105536:	85 c0                	test   %eax,%eax
80105538:	79 0c                	jns    80105546 <popcli+0x4b>
    panic("popcli");
8010553a:	c7 04 24 ec 8d 10 80 	movl   $0x80108dec,(%esp)
80105541:	e8 f7 af ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105546:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010554c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105552:	85 c0                	test   %eax,%eax
80105554:	75 15                	jne    8010556b <popcli+0x70>
80105556:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010555c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105562:	85 c0                	test   %eax,%eax
80105564:	74 05                	je     8010556b <popcli+0x70>
    sti();
80105566:	e8 b4 fd ff ff       	call   8010531f <sti>
}
8010556b:	c9                   	leave  
8010556c:	c3                   	ret    
8010556d:	00 00                	add    %al,(%eax)
	...

80105570 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105570:	55                   	push   %ebp
80105571:	89 e5                	mov    %esp,%ebp
80105573:	57                   	push   %edi
80105574:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105575:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105578:	8b 55 10             	mov    0x10(%ebp),%edx
8010557b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557e:	89 cb                	mov    %ecx,%ebx
80105580:	89 df                	mov    %ebx,%edi
80105582:	89 d1                	mov    %edx,%ecx
80105584:	fc                   	cld    
80105585:	f3 aa                	rep stos %al,%es:(%edi)
80105587:	89 ca                	mov    %ecx,%edx
80105589:	89 fb                	mov    %edi,%ebx
8010558b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010558e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105591:	5b                   	pop    %ebx
80105592:	5f                   	pop    %edi
80105593:	5d                   	pop    %ebp
80105594:	c3                   	ret    

80105595 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105595:	55                   	push   %ebp
80105596:	89 e5                	mov    %esp,%ebp
80105598:	57                   	push   %edi
80105599:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010559a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010559d:	8b 55 10             	mov    0x10(%ebp),%edx
801055a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a3:	89 cb                	mov    %ecx,%ebx
801055a5:	89 df                	mov    %ebx,%edi
801055a7:	89 d1                	mov    %edx,%ecx
801055a9:	fc                   	cld    
801055aa:	f3 ab                	rep stos %eax,%es:(%edi)
801055ac:	89 ca                	mov    %ecx,%edx
801055ae:	89 fb                	mov    %edi,%ebx
801055b0:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055b3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801055b6:	5b                   	pop    %ebx
801055b7:	5f                   	pop    %edi
801055b8:	5d                   	pop    %ebp
801055b9:	c3                   	ret    

801055ba <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
801055ba:	55                   	push   %ebp
801055bb:	89 e5                	mov    %esp,%ebp
801055bd:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801055c0:	8b 45 08             	mov    0x8(%ebp),%eax
801055c3:	83 e0 03             	and    $0x3,%eax
801055c6:	85 c0                	test   %eax,%eax
801055c8:	75 49                	jne    80105613 <memset+0x59>
801055ca:	8b 45 10             	mov    0x10(%ebp),%eax
801055cd:	83 e0 03             	and    $0x3,%eax
801055d0:	85 c0                	test   %eax,%eax
801055d2:	75 3f                	jne    80105613 <memset+0x59>
    c &= 0xFF;
801055d4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801055db:	8b 45 10             	mov    0x10(%ebp),%eax
801055de:	c1 e8 02             	shr    $0x2,%eax
801055e1:	89 c2                	mov    %eax,%edx
801055e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e6:	89 c1                	mov    %eax,%ecx
801055e8:	c1 e1 18             	shl    $0x18,%ecx
801055eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ee:	c1 e0 10             	shl    $0x10,%eax
801055f1:	09 c1                	or     %eax,%ecx
801055f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f6:	c1 e0 08             	shl    $0x8,%eax
801055f9:	09 c8                	or     %ecx,%eax
801055fb:	0b 45 0c             	or     0xc(%ebp),%eax
801055fe:	89 54 24 08          	mov    %edx,0x8(%esp)
80105602:	89 44 24 04          	mov    %eax,0x4(%esp)
80105606:	8b 45 08             	mov    0x8(%ebp),%eax
80105609:	89 04 24             	mov    %eax,(%esp)
8010560c:	e8 84 ff ff ff       	call   80105595 <stosl>
80105611:	eb 19                	jmp    8010562c <memset+0x72>
  } else
    stosb(dst, c, n);
80105613:	8b 45 10             	mov    0x10(%ebp),%eax
80105616:	89 44 24 08          	mov    %eax,0x8(%esp)
8010561a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010561d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105621:	8b 45 08             	mov    0x8(%ebp),%eax
80105624:	89 04 24             	mov    %eax,(%esp)
80105627:	e8 44 ff ff ff       	call   80105570 <stosb>
  return dst;
8010562c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010562f:	c9                   	leave  
80105630:	c3                   	ret    

80105631 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105631:	55                   	push   %ebp
80105632:	89 e5                	mov    %esp,%ebp
80105634:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105637:	8b 45 08             	mov    0x8(%ebp),%eax
8010563a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010563d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105640:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105643:	eb 32                	jmp    80105677 <memcmp+0x46>
    if(*s1 != *s2)
80105645:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105648:	0f b6 10             	movzbl (%eax),%edx
8010564b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010564e:	0f b6 00             	movzbl (%eax),%eax
80105651:	38 c2                	cmp    %al,%dl
80105653:	74 1a                	je     8010566f <memcmp+0x3e>
      return *s1 - *s2;
80105655:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105658:	0f b6 00             	movzbl (%eax),%eax
8010565b:	0f b6 d0             	movzbl %al,%edx
8010565e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105661:	0f b6 00             	movzbl (%eax),%eax
80105664:	0f b6 c0             	movzbl %al,%eax
80105667:	89 d1                	mov    %edx,%ecx
80105669:	29 c1                	sub    %eax,%ecx
8010566b:	89 c8                	mov    %ecx,%eax
8010566d:	eb 1c                	jmp    8010568b <memcmp+0x5a>
    s1++, s2++;
8010566f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105673:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105677:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010567b:	0f 95 c0             	setne  %al
8010567e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105682:	84 c0                	test   %al,%al
80105684:	75 bf                	jne    80105645 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105686:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010568b:	c9                   	leave  
8010568c:	c3                   	ret    

8010568d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010568d:	55                   	push   %ebp
8010568e:	89 e5                	mov    %esp,%ebp
80105690:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105693:	8b 45 0c             	mov    0xc(%ebp),%eax
80105696:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105699:	8b 45 08             	mov    0x8(%ebp),%eax
8010569c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010569f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056a5:	73 54                	jae    801056fb <memmove+0x6e>
801056a7:	8b 45 10             	mov    0x10(%ebp),%eax
801056aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056ad:	01 d0                	add    %edx,%eax
801056af:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056b2:	76 47                	jbe    801056fb <memmove+0x6e>
    s += n;
801056b4:	8b 45 10             	mov    0x10(%ebp),%eax
801056b7:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056ba:	8b 45 10             	mov    0x10(%ebp),%eax
801056bd:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801056c0:	eb 13                	jmp    801056d5 <memmove+0x48>
      *--d = *--s;
801056c2:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801056c6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801056ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056cd:	0f b6 10             	movzbl (%eax),%edx
801056d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056d3:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801056d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056d9:	0f 95 c0             	setne  %al
801056dc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056e0:	84 c0                	test   %al,%al
801056e2:	75 de                	jne    801056c2 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801056e4:	eb 25                	jmp    8010570b <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801056e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056e9:	0f b6 10             	movzbl (%eax),%edx
801056ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056ef:	88 10                	mov    %dl,(%eax)
801056f1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801056f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056f9:	eb 01                	jmp    801056fc <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801056fb:	90                   	nop
801056fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105700:	0f 95 c0             	setne  %al
80105703:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105707:	84 c0                	test   %al,%al
80105709:	75 db                	jne    801056e6 <memmove+0x59>
      *d++ = *s++;

  return dst;
8010570b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010570e:	c9                   	leave  
8010570f:	c3                   	ret    

80105710 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105710:	55                   	push   %ebp
80105711:	89 e5                	mov    %esp,%ebp
80105713:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105716:	8b 45 10             	mov    0x10(%ebp),%eax
80105719:	89 44 24 08          	mov    %eax,0x8(%esp)
8010571d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105720:	89 44 24 04          	mov    %eax,0x4(%esp)
80105724:	8b 45 08             	mov    0x8(%ebp),%eax
80105727:	89 04 24             	mov    %eax,(%esp)
8010572a:	e8 5e ff ff ff       	call   8010568d <memmove>
}
8010572f:	c9                   	leave  
80105730:	c3                   	ret    

80105731 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105731:	55                   	push   %ebp
80105732:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105734:	eb 0c                	jmp    80105742 <strncmp+0x11>
    n--, p++, q++;
80105736:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010573a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010573e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105742:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105746:	74 1a                	je     80105762 <strncmp+0x31>
80105748:	8b 45 08             	mov    0x8(%ebp),%eax
8010574b:	0f b6 00             	movzbl (%eax),%eax
8010574e:	84 c0                	test   %al,%al
80105750:	74 10                	je     80105762 <strncmp+0x31>
80105752:	8b 45 08             	mov    0x8(%ebp),%eax
80105755:	0f b6 10             	movzbl (%eax),%edx
80105758:	8b 45 0c             	mov    0xc(%ebp),%eax
8010575b:	0f b6 00             	movzbl (%eax),%eax
8010575e:	38 c2                	cmp    %al,%dl
80105760:	74 d4                	je     80105736 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105762:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105766:	75 07                	jne    8010576f <strncmp+0x3e>
    return 0;
80105768:	b8 00 00 00 00       	mov    $0x0,%eax
8010576d:	eb 18                	jmp    80105787 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
8010576f:	8b 45 08             	mov    0x8(%ebp),%eax
80105772:	0f b6 00             	movzbl (%eax),%eax
80105775:	0f b6 d0             	movzbl %al,%edx
80105778:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577b:	0f b6 00             	movzbl (%eax),%eax
8010577e:	0f b6 c0             	movzbl %al,%eax
80105781:	89 d1                	mov    %edx,%ecx
80105783:	29 c1                	sub    %eax,%ecx
80105785:	89 c8                	mov    %ecx,%eax
}
80105787:	5d                   	pop    %ebp
80105788:	c3                   	ret    

80105789 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105789:	55                   	push   %ebp
8010578a:	89 e5                	mov    %esp,%ebp
8010578c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010578f:	8b 45 08             	mov    0x8(%ebp),%eax
80105792:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105795:	90                   	nop
80105796:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010579a:	0f 9f c0             	setg   %al
8010579d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057a1:	84 c0                	test   %al,%al
801057a3:	74 30                	je     801057d5 <strncpy+0x4c>
801057a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a8:	0f b6 10             	movzbl (%eax),%edx
801057ab:	8b 45 08             	mov    0x8(%ebp),%eax
801057ae:	88 10                	mov    %dl,(%eax)
801057b0:	8b 45 08             	mov    0x8(%ebp),%eax
801057b3:	0f b6 00             	movzbl (%eax),%eax
801057b6:	84 c0                	test   %al,%al
801057b8:	0f 95 c0             	setne  %al
801057bb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801057bf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801057c3:	84 c0                	test   %al,%al
801057c5:	75 cf                	jne    80105796 <strncpy+0xd>
    ;
  while(n-- > 0)
801057c7:	eb 0c                	jmp    801057d5 <strncpy+0x4c>
    *s++ = 0;
801057c9:	8b 45 08             	mov    0x8(%ebp),%eax
801057cc:	c6 00 00             	movb   $0x0,(%eax)
801057cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801057d3:	eb 01                	jmp    801057d6 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801057d5:	90                   	nop
801057d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057da:	0f 9f c0             	setg   %al
801057dd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057e1:	84 c0                	test   %al,%al
801057e3:	75 e4                	jne    801057c9 <strncpy+0x40>
    *s++ = 0;
  return os;
801057e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057e8:	c9                   	leave  
801057e9:	c3                   	ret    

801057ea <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801057ea:	55                   	push   %ebp
801057eb:	89 e5                	mov    %esp,%ebp
801057ed:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801057f0:	8b 45 08             	mov    0x8(%ebp),%eax
801057f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801057f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057fa:	7f 05                	jg     80105801 <safestrcpy+0x17>
    return os;
801057fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ff:	eb 35                	jmp    80105836 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105801:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105805:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105809:	7e 22                	jle    8010582d <safestrcpy+0x43>
8010580b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010580e:	0f b6 10             	movzbl (%eax),%edx
80105811:	8b 45 08             	mov    0x8(%ebp),%eax
80105814:	88 10                	mov    %dl,(%eax)
80105816:	8b 45 08             	mov    0x8(%ebp),%eax
80105819:	0f b6 00             	movzbl (%eax),%eax
8010581c:	84 c0                	test   %al,%al
8010581e:	0f 95 c0             	setne  %al
80105821:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105825:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105829:	84 c0                	test   %al,%al
8010582b:	75 d4                	jne    80105801 <safestrcpy+0x17>
    ;
  *s = 0;
8010582d:	8b 45 08             	mov    0x8(%ebp),%eax
80105830:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105833:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105836:	c9                   	leave  
80105837:	c3                   	ret    

80105838 <strlen>:

int
strlen(const char *s)
{
80105838:	55                   	push   %ebp
80105839:	89 e5                	mov    %esp,%ebp
8010583b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010583e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105845:	eb 04                	jmp    8010584b <strlen+0x13>
80105847:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010584b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010584e:	03 45 08             	add    0x8(%ebp),%eax
80105851:	0f b6 00             	movzbl (%eax),%eax
80105854:	84 c0                	test   %al,%al
80105856:	75 ef                	jne    80105847 <strlen+0xf>
    ;
  return n;
80105858:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010585b:	c9                   	leave  
8010585c:	c3                   	ret    
8010585d:	00 00                	add    %al,(%eax)
	...

80105860 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105860:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105864:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105868:	55                   	push   %ebp
  pushl %ebx
80105869:	53                   	push   %ebx
  pushl %esi
8010586a:	56                   	push   %esi
  pushl %edi
8010586b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010586c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010586e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105870:	5f                   	pop    %edi
  popl %esi
80105871:	5e                   	pop    %esi
  popl %ebx
80105872:	5b                   	pop    %ebx
  popl %ebp
80105873:	5d                   	pop    %ebp
  ret
80105874:	c3                   	ret    
80105875:	00 00                	add    %al,(%eax)
	...

80105878 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
80105878:	55                   	push   %ebp
80105879:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
8010587b:	8b 45 08             	mov    0x8(%ebp),%eax
8010587e:	8b 00                	mov    (%eax),%eax
80105880:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105883:	76 0f                	jbe    80105894 <fetchint+0x1c>
80105885:	8b 45 0c             	mov    0xc(%ebp),%eax
80105888:	8d 50 04             	lea    0x4(%eax),%edx
8010588b:	8b 45 08             	mov    0x8(%ebp),%eax
8010588e:	8b 00                	mov    (%eax),%eax
80105890:	39 c2                	cmp    %eax,%edx
80105892:	76 07                	jbe    8010589b <fetchint+0x23>
    return -1;
80105894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105899:	eb 0f                	jmp    801058aa <fetchint+0x32>
  *ip = *(int*)(addr);
8010589b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010589e:	8b 10                	mov    (%eax),%edx
801058a0:	8b 45 10             	mov    0x10(%ebp),%eax
801058a3:	89 10                	mov    %edx,(%eax)
  return 0;
801058a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058aa:	5d                   	pop    %ebp
801058ab:	c3                   	ret    

801058ac <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
801058ac:	55                   	push   %ebp
801058ad:	89 e5                	mov    %esp,%ebp
801058af:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
801058b2:	8b 45 08             	mov    0x8(%ebp),%eax
801058b5:	8b 00                	mov    (%eax),%eax
801058b7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801058ba:	77 07                	ja     801058c3 <fetchstr+0x17>
    return -1;
801058bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c1:	eb 45                	jmp    80105908 <fetchstr+0x5c>
  *pp = (char*)addr;
801058c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801058c6:	8b 45 10             	mov    0x10(%ebp),%eax
801058c9:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
801058cb:	8b 45 08             	mov    0x8(%ebp),%eax
801058ce:	8b 00                	mov    (%eax),%eax
801058d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801058d3:	8b 45 10             	mov    0x10(%ebp),%eax
801058d6:	8b 00                	mov    (%eax),%eax
801058d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801058db:	eb 1e                	jmp    801058fb <fetchstr+0x4f>
    if(*s == 0)
801058dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058e0:	0f b6 00             	movzbl (%eax),%eax
801058e3:	84 c0                	test   %al,%al
801058e5:	75 10                	jne    801058f7 <fetchstr+0x4b>
      return s - *pp;
801058e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058ea:	8b 45 10             	mov    0x10(%ebp),%eax
801058ed:	8b 00                	mov    (%eax),%eax
801058ef:	89 d1                	mov    %edx,%ecx
801058f1:	29 c1                	sub    %eax,%ecx
801058f3:	89 c8                	mov    %ecx,%eax
801058f5:	eb 11                	jmp    80105908 <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
801058f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105901:	72 da                	jb     801058dd <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105908:	c9                   	leave  
80105909:	c3                   	ret    

8010590a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010590a:	55                   	push   %ebp
8010590b:	89 e5                	mov    %esp,%ebp
8010590d:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105910:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105916:	8b 40 18             	mov    0x18(%eax),%eax
80105919:	8b 50 44             	mov    0x44(%eax),%edx
8010591c:	8b 45 08             	mov    0x8(%ebp),%eax
8010591f:	c1 e0 02             	shl    $0x2,%eax
80105922:	01 d0                	add    %edx,%eax
80105924:	8d 48 04             	lea    0x4(%eax),%ecx
80105927:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010592d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105930:	89 54 24 08          	mov    %edx,0x8(%esp)
80105934:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105938:	89 04 24             	mov    %eax,(%esp)
8010593b:	e8 38 ff ff ff       	call   80105878 <fetchint>
}
80105940:	c9                   	leave  
80105941:	c3                   	ret    

80105942 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105942:	55                   	push   %ebp
80105943:	89 e5                	mov    %esp,%ebp
80105945:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105948:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010594b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010594f:	8b 45 08             	mov    0x8(%ebp),%eax
80105952:	89 04 24             	mov    %eax,(%esp)
80105955:	e8 b0 ff ff ff       	call   8010590a <argint>
8010595a:	85 c0                	test   %eax,%eax
8010595c:	79 07                	jns    80105965 <argptr+0x23>
    return -1;
8010595e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105963:	eb 3d                	jmp    801059a2 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105965:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105968:	89 c2                	mov    %eax,%edx
8010596a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105970:	8b 00                	mov    (%eax),%eax
80105972:	39 c2                	cmp    %eax,%edx
80105974:	73 16                	jae    8010598c <argptr+0x4a>
80105976:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105979:	89 c2                	mov    %eax,%edx
8010597b:	8b 45 10             	mov    0x10(%ebp),%eax
8010597e:	01 c2                	add    %eax,%edx
80105980:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105986:	8b 00                	mov    (%eax),%eax
80105988:	39 c2                	cmp    %eax,%edx
8010598a:	76 07                	jbe    80105993 <argptr+0x51>
    return -1;
8010598c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105991:	eb 0f                	jmp    801059a2 <argptr+0x60>
  *pp = (char*)i;
80105993:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105996:	89 c2                	mov    %eax,%edx
80105998:	8b 45 0c             	mov    0xc(%ebp),%eax
8010599b:	89 10                	mov    %edx,(%eax)
  return 0;
8010599d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a2:	c9                   	leave  
801059a3:	c3                   	ret    

801059a4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059a4:	55                   	push   %ebp
801059a5:	89 e5                	mov    %esp,%ebp
801059a7:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801059aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
801059ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801059b1:	8b 45 08             	mov    0x8(%ebp),%eax
801059b4:	89 04 24             	mov    %eax,(%esp)
801059b7:	e8 4e ff ff ff       	call   8010590a <argint>
801059bc:	85 c0                	test   %eax,%eax
801059be:	79 07                	jns    801059c7 <argstr+0x23>
    return -1;
801059c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c5:	eb 1e                	jmp    801059e5 <argstr+0x41>
  return fetchstr(proc, addr, pp);
801059c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059ca:	89 c2                	mov    %eax,%edx
801059cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801059d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059d9:	89 54 24 04          	mov    %edx,0x4(%esp)
801059dd:	89 04 24             	mov    %eax,(%esp)
801059e0:	e8 c7 fe ff ff       	call   801058ac <fetchstr>
}
801059e5:	c9                   	leave  
801059e6:	c3                   	ret    

801059e7 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801059e7:	55                   	push   %ebp
801059e8:	89 e5                	mov    %esp,%ebp
801059ea:	53                   	push   %ebx
801059eb:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801059ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059f4:	8b 40 18             	mov    0x18(%eax),%eax
801059f7:	8b 40 1c             	mov    0x1c(%eax),%eax
801059fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
801059fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a01:	78 2e                	js     80105a31 <syscall+0x4a>
80105a03:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105a07:	7f 28                	jg     80105a31 <syscall+0x4a>
80105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0c:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a13:	85 c0                	test   %eax,%eax
80105a15:	74 1a                	je     80105a31 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105a17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a1d:	8b 58 18             	mov    0x18(%eax),%ebx
80105a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a23:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a2a:	ff d0                	call   *%eax
80105a2c:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105a2f:	eb 73                	jmp    80105aa4 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105a31:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105a35:	7e 30                	jle    80105a67 <syscall+0x80>
80105a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3a:	83 f8 17             	cmp    $0x17,%eax
80105a3d:	77 28                	ja     80105a67 <syscall+0x80>
80105a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a42:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a49:	85 c0                	test   %eax,%eax
80105a4b:	74 1a                	je     80105a67 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105a4d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a53:	8b 58 18             	mov    0x18(%eax),%ebx
80105a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a59:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a60:	ff d0                	call   *%eax
80105a62:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105a65:	eb 3d                	jmp    80105aa4 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105a67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a6d:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105a70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105a76:	8b 40 10             	mov    0x10(%eax),%eax
80105a79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105a80:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a84:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a88:	c7 04 24 f3 8d 10 80 	movl   $0x80108df3,(%esp)
80105a8f:	e8 0d a9 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105a94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a9a:	8b 40 18             	mov    0x18(%eax),%eax
80105a9d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105aa4:	83 c4 24             	add    $0x24,%esp
80105aa7:	5b                   	pop    %ebx
80105aa8:	5d                   	pop    %ebp
80105aa9:	c3                   	ret    
	...

80105aac <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105aac:	55                   	push   %ebp
80105aad:	89 e5                	mov    %esp,%ebp
80105aaf:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105ab2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80105abc:	89 04 24             	mov    %eax,(%esp)
80105abf:	e8 46 fe ff ff       	call   8010590a <argint>
80105ac4:	85 c0                	test   %eax,%eax
80105ac6:	79 07                	jns    80105acf <argfd+0x23>
    return -1;
80105ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105acd:	eb 50                	jmp    80105b1f <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad2:	85 c0                	test   %eax,%eax
80105ad4:	78 21                	js     80105af7 <argfd+0x4b>
80105ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad9:	83 f8 0f             	cmp    $0xf,%eax
80105adc:	7f 19                	jg     80105af7 <argfd+0x4b>
80105ade:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ae4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ae7:	83 c2 08             	add    $0x8,%edx
80105aea:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105aee:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af5:	75 07                	jne    80105afe <argfd+0x52>
    return -1;
80105af7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105afc:	eb 21                	jmp    80105b1f <argfd+0x73>
  if(pfd)
80105afe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b02:	74 08                	je     80105b0c <argfd+0x60>
    *pfd = fd;
80105b04:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b07:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b0a:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b10:	74 08                	je     80105b1a <argfd+0x6e>
    *pf = f;
80105b12:	8b 45 10             	mov    0x10(%ebp),%eax
80105b15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b18:	89 10                	mov    %edx,(%eax)
  return 0;
80105b1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b1f:	c9                   	leave  
80105b20:	c3                   	ret    

80105b21 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105b21:	55                   	push   %ebp
80105b22:	89 e5                	mov    %esp,%ebp
80105b24:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b27:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105b2e:	eb 30                	jmp    80105b60 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105b30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b36:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b39:	83 c2 08             	add    $0x8,%edx
80105b3c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b40:	85 c0                	test   %eax,%eax
80105b42:	75 18                	jne    80105b5c <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105b44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b4a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b4d:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b50:	8b 55 08             	mov    0x8(%ebp),%edx
80105b53:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b5a:	eb 0f                	jmp    80105b6b <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b5c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105b60:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105b64:	7e ca                	jle    80105b30 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105b66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b6b:	c9                   	leave  
80105b6c:	c3                   	ret    

80105b6d <sys_dup>:

int
sys_dup(void)
{
80105b6d:	55                   	push   %ebp
80105b6e:	89 e5                	mov    %esp,%ebp
80105b70:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105b73:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b76:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b81:	00 
80105b82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b89:	e8 1e ff ff ff       	call   80105aac <argfd>
80105b8e:	85 c0                	test   %eax,%eax
80105b90:	79 07                	jns    80105b99 <sys_dup+0x2c>
    return -1;
80105b92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b97:	eb 29                	jmp    80105bc2 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9c:	89 04 24             	mov    %eax,(%esp)
80105b9f:	e8 7d ff ff ff       	call   80105b21 <fdalloc>
80105ba4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bab:	79 07                	jns    80105bb4 <sys_dup+0x47>
    return -1;
80105bad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb2:	eb 0e                	jmp    80105bc2 <sys_dup+0x55>
  filedup(f);
80105bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb7:	89 04 24             	mov    %eax,(%esp)
80105bba:	e8 25 b7 ff ff       	call   801012e4 <filedup>
  return fd;
80105bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105bc2:	c9                   	leave  
80105bc3:	c3                   	ret    

80105bc4 <sys_read>:

int
sys_read(void)
{
80105bc4:	55                   	push   %ebp
80105bc5:	89 e5                	mov    %esp,%ebp
80105bc7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bcd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bd8:	00 
80105bd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105be0:	e8 c7 fe ff ff       	call   80105aac <argfd>
80105be5:	85 c0                	test   %eax,%eax
80105be7:	78 35                	js     80105c1e <sys_read+0x5a>
80105be9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bec:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bf0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105bf7:	e8 0e fd ff ff       	call   8010590a <argint>
80105bfc:	85 c0                	test   %eax,%eax
80105bfe:	78 1e                	js     80105c1e <sys_read+0x5a>
80105c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c07:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c15:	e8 28 fd ff ff       	call   80105942 <argptr>
80105c1a:	85 c0                	test   %eax,%eax
80105c1c:	79 07                	jns    80105c25 <sys_read+0x61>
    return -1;
80105c1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c23:	eb 19                	jmp    80105c3e <sys_read+0x7a>
  return fileread(f, p, n);
80105c25:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c28:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c32:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c36:	89 04 24             	mov    %eax,(%esp)
80105c39:	e8 13 b8 ff ff       	call   80101451 <fileread>
}
80105c3e:	c9                   	leave  
80105c3f:	c3                   	ret    

80105c40 <sys_write>:

int
sys_write(void)
{
80105c40:	55                   	push   %ebp
80105c41:	89 e5                	mov    %esp,%ebp
80105c43:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c46:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c49:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c54:	00 
80105c55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c5c:	e8 4b fe ff ff       	call   80105aac <argfd>
80105c61:	85 c0                	test   %eax,%eax
80105c63:	78 35                	js     80105c9a <sys_write+0x5a>
80105c65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c6c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c73:	e8 92 fc ff ff       	call   8010590a <argint>
80105c78:	85 c0                	test   %eax,%eax
80105c7a:	78 1e                	js     80105c9a <sys_write+0x5a>
80105c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c83:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c86:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c91:	e8 ac fc ff ff       	call   80105942 <argptr>
80105c96:	85 c0                	test   %eax,%eax
80105c98:	79 07                	jns    80105ca1 <sys_write+0x61>
    return -1;
80105c9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9f:	eb 19                	jmp    80105cba <sys_write+0x7a>
  return filewrite(f, p, n);
80105ca1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ca4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105cae:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cb2:	89 04 24             	mov    %eax,(%esp)
80105cb5:	e8 53 b8 ff ff       	call   8010150d <filewrite>
}
80105cba:	c9                   	leave  
80105cbb:	c3                   	ret    

80105cbc <sys_close>:

int
sys_close(void)
{
80105cbc:	55                   	push   %ebp
80105cbd:	89 e5                	mov    %esp,%ebp
80105cbf:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105cc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cc5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cd7:	e8 d0 fd ff ff       	call   80105aac <argfd>
80105cdc:	85 c0                	test   %eax,%eax
80105cde:	79 07                	jns    80105ce7 <sys_close+0x2b>
    return -1;
80105ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce5:	eb 24                	jmp    80105d0b <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105ce7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ced:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cf0:	83 c2 08             	add    $0x8,%edx
80105cf3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105cfa:	00 
  fileclose(f);
80105cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cfe:	89 04 24             	mov    %eax,(%esp)
80105d01:	e8 26 b6 ff ff       	call   8010132c <fileclose>
  return 0;
80105d06:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d0b:	c9                   	leave  
80105d0c:	c3                   	ret    

80105d0d <sys_fstat>:

int
sys_fstat(void)
{
80105d0d:	55                   	push   %ebp
80105d0e:	89 e5                	mov    %esp,%ebp
80105d10:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d13:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d16:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d21:	00 
80105d22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d29:	e8 7e fd ff ff       	call   80105aac <argfd>
80105d2e:	85 c0                	test   %eax,%eax
80105d30:	78 1f                	js     80105d51 <sys_fstat+0x44>
80105d32:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105d39:	00 
80105d3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d48:	e8 f5 fb ff ff       	call   80105942 <argptr>
80105d4d:	85 c0                	test   %eax,%eax
80105d4f:	79 07                	jns    80105d58 <sys_fstat+0x4b>
    return -1;
80105d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d56:	eb 12                	jmp    80105d6a <sys_fstat+0x5d>
  return filestat(f, st);
80105d58:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d62:	89 04 24             	mov    %eax,(%esp)
80105d65:	e8 98 b6 ff ff       	call   80101402 <filestat>
}
80105d6a:	c9                   	leave  
80105d6b:	c3                   	ret    

80105d6c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d6c:	55                   	push   %ebp
80105d6d:	89 e5                	mov    %esp,%ebp
80105d6f:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d72:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d75:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d80:	e8 1f fc ff ff       	call   801059a4 <argstr>
80105d85:	85 c0                	test   %eax,%eax
80105d87:	78 17                	js     80105da0 <sys_link+0x34>
80105d89:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d97:	e8 08 fc ff ff       	call   801059a4 <argstr>
80105d9c:	85 c0                	test   %eax,%eax
80105d9e:	79 0a                	jns    80105daa <sys_link+0x3e>
    return -1;
80105da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da5:	e9 3c 01 00 00       	jmp    80105ee6 <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105daa:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105dad:	89 04 24             	mov    %eax,(%esp)
80105db0:	e8 bd c9 ff ff       	call   80102772 <namei>
80105db5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105db8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dbc:	75 0a                	jne    80105dc8 <sys_link+0x5c>
    return -1;
80105dbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc3:	e9 1e 01 00 00       	jmp    80105ee6 <sys_link+0x17a>

  begin_trans();
80105dc8:	e8 b8 d7 ff ff       	call   80103585 <begin_trans>

  ilock(ip);
80105dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd0:	89 04 24             	mov    %eax,(%esp)
80105dd3:	e8 f8 bd ff ff       	call   80101bd0 <ilock>
  if(ip->type == T_DIR){
80105dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ddf:	66 83 f8 01          	cmp    $0x1,%ax
80105de3:	75 1a                	jne    80105dff <sys_link+0x93>
    iunlockput(ip);
80105de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de8:	89 04 24             	mov    %eax,(%esp)
80105deb:	e8 64 c0 ff ff       	call   80101e54 <iunlockput>
    commit_trans();
80105df0:	e8 d9 d7 ff ff       	call   801035ce <commit_trans>
    return -1;
80105df5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfa:	e9 e7 00 00 00       	jmp    80105ee6 <sys_link+0x17a>
  }

  ip->nlink++;
80105dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e02:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e06:	8d 50 01             	lea    0x1(%eax),%edx
80105e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e13:	89 04 24             	mov    %eax,(%esp)
80105e16:	e8 f9 bb ff ff       	call   80101a14 <iupdate>
  iunlock(ip);
80105e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1e:	89 04 24             	mov    %eax,(%esp)
80105e21:	e8 f8 be ff ff       	call   80101d1e <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105e26:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e29:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105e2c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e30:	89 04 24             	mov    %eax,(%esp)
80105e33:	e8 5c c9 ff ff       	call   80102794 <nameiparent>
80105e38:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e3f:	74 68                	je     80105ea9 <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e44:	89 04 24             	mov    %eax,(%esp)
80105e47:	e8 84 bd ff ff       	call   80101bd0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4f:	8b 10                	mov    (%eax),%edx
80105e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e54:	8b 00                	mov    (%eax),%eax
80105e56:	39 c2                	cmp    %eax,%edx
80105e58:	75 20                	jne    80105e7a <sys_link+0x10e>
80105e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5d:	8b 40 04             	mov    0x4(%eax),%eax
80105e60:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e64:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e67:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6e:	89 04 24             	mov    %eax,(%esp)
80105e71:	e8 3b c6 ff ff       	call   801024b1 <dirlink>
80105e76:	85 c0                	test   %eax,%eax
80105e78:	79 0d                	jns    80105e87 <sys_link+0x11b>
    iunlockput(dp);
80105e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7d:	89 04 24             	mov    %eax,(%esp)
80105e80:	e8 cf bf ff ff       	call   80101e54 <iunlockput>
    goto bad;
80105e85:	eb 23                	jmp    80105eaa <sys_link+0x13e>
  }
  iunlockput(dp);
80105e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8a:	89 04 24             	mov    %eax,(%esp)
80105e8d:	e8 c2 bf ff ff       	call   80101e54 <iunlockput>
  iput(ip);
80105e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e95:	89 04 24             	mov    %eax,(%esp)
80105e98:	e8 e6 be ff ff       	call   80101d83 <iput>

  commit_trans();
80105e9d:	e8 2c d7 ff ff       	call   801035ce <commit_trans>

  return 0;
80105ea2:	b8 00 00 00 00       	mov    $0x0,%eax
80105ea7:	eb 3d                	jmp    80105ee6 <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105ea9:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ead:	89 04 24             	mov    %eax,(%esp)
80105eb0:	e8 1b bd ff ff       	call   80101bd0 <ilock>
  ip->nlink--;
80105eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ebc:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec2:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec9:	89 04 24             	mov    %eax,(%esp)
80105ecc:	e8 43 bb ff ff       	call   80101a14 <iupdate>
  iunlockput(ip);
80105ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed4:	89 04 24             	mov    %eax,(%esp)
80105ed7:	e8 78 bf ff ff       	call   80101e54 <iunlockput>
  commit_trans();
80105edc:	e8 ed d6 ff ff       	call   801035ce <commit_trans>
  return -1;
80105ee1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ee6:	c9                   	leave  
80105ee7:	c3                   	ret    

80105ee8 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105ee8:	55                   	push   %ebp
80105ee9:	89 e5                	mov    %esp,%ebp
80105eeb:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eee:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ef5:	eb 4b                	jmp    80105f42 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efa:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f01:	00 
80105f02:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f06:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f09:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f10:	89 04 24             	mov    %eax,(%esp)
80105f13:	e8 ae c1 ff ff       	call   801020c6 <readi>
80105f18:	83 f8 10             	cmp    $0x10,%eax
80105f1b:	74 0c                	je     80105f29 <isdirempty+0x41>
      panic("isdirempty: readi");
80105f1d:	c7 04 24 0f 8e 10 80 	movl   $0x80108e0f,(%esp)
80105f24:	e8 14 a6 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105f29:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105f2d:	66 85 c0             	test   %ax,%ax
80105f30:	74 07                	je     80105f39 <isdirempty+0x51>
      return 0;
80105f32:	b8 00 00 00 00       	mov    $0x0,%eax
80105f37:	eb 1b                	jmp    80105f54 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3c:	83 c0 10             	add    $0x10,%eax
80105f3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f45:	8b 45 08             	mov    0x8(%ebp),%eax
80105f48:	8b 40 18             	mov    0x18(%eax),%eax
80105f4b:	39 c2                	cmp    %eax,%edx
80105f4d:	72 a8                	jb     80105ef7 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105f4f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f54:	c9                   	leave  
80105f55:	c3                   	ret    

80105f56 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f56:	55                   	push   %ebp
80105f57:	89 e5                	mov    %esp,%ebp
80105f59:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f5c:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f6a:	e8 35 fa ff ff       	call   801059a4 <argstr>
80105f6f:	85 c0                	test   %eax,%eax
80105f71:	79 0a                	jns    80105f7d <sys_unlink+0x27>
    return -1;
80105f73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f78:	e9 aa 01 00 00       	jmp    80106127 <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105f7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f80:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f83:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f87:	89 04 24             	mov    %eax,(%esp)
80105f8a:	e8 05 c8 ff ff       	call   80102794 <nameiparent>
80105f8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f96:	75 0a                	jne    80105fa2 <sys_unlink+0x4c>
    return -1;
80105f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f9d:	e9 85 01 00 00       	jmp    80106127 <sys_unlink+0x1d1>

  begin_trans();
80105fa2:	e8 de d5 ff ff       	call   80103585 <begin_trans>

  ilock(dp);
80105fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105faa:	89 04 24             	mov    %eax,(%esp)
80105fad:	e8 1e bc ff ff       	call   80101bd0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105fb2:	c7 44 24 04 21 8e 10 	movl   $0x80108e21,0x4(%esp)
80105fb9:	80 
80105fba:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fbd:	89 04 24             	mov    %eax,(%esp)
80105fc0:	e8 02 c4 ff ff       	call   801023c7 <namecmp>
80105fc5:	85 c0                	test   %eax,%eax
80105fc7:	0f 84 45 01 00 00    	je     80106112 <sys_unlink+0x1bc>
80105fcd:	c7 44 24 04 23 8e 10 	movl   $0x80108e23,0x4(%esp)
80105fd4:	80 
80105fd5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fd8:	89 04 24             	mov    %eax,(%esp)
80105fdb:	e8 e7 c3 ff ff       	call   801023c7 <namecmp>
80105fe0:	85 c0                	test   %eax,%eax
80105fe2:	0f 84 2a 01 00 00    	je     80106112 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105fe8:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105feb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fef:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff9:	89 04 24             	mov    %eax,(%esp)
80105ffc:	e8 e8 c3 ff ff       	call   801023e9 <dirlookup>
80106001:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106004:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106008:	0f 84 03 01 00 00    	je     80106111 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
8010600e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106011:	89 04 24             	mov    %eax,(%esp)
80106014:	e8 b7 bb ff ff       	call   80101bd0 <ilock>

  if(ip->nlink < 1)
80106019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106020:	66 85 c0             	test   %ax,%ax
80106023:	7f 0c                	jg     80106031 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80106025:	c7 04 24 26 8e 10 80 	movl   $0x80108e26,(%esp)
8010602c:	e8 0c a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106034:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106038:	66 83 f8 01          	cmp    $0x1,%ax
8010603c:	75 1f                	jne    8010605d <sys_unlink+0x107>
8010603e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106041:	89 04 24             	mov    %eax,(%esp)
80106044:	e8 9f fe ff ff       	call   80105ee8 <isdirempty>
80106049:	85 c0                	test   %eax,%eax
8010604b:	75 10                	jne    8010605d <sys_unlink+0x107>
    iunlockput(ip);
8010604d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106050:	89 04 24             	mov    %eax,(%esp)
80106053:	e8 fc bd ff ff       	call   80101e54 <iunlockput>
    goto bad;
80106058:	e9 b5 00 00 00       	jmp    80106112 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
8010605d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106064:	00 
80106065:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010606c:	00 
8010606d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106070:	89 04 24             	mov    %eax,(%esp)
80106073:	e8 42 f5 ff ff       	call   801055ba <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106078:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010607b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106082:	00 
80106083:	89 44 24 08          	mov    %eax,0x8(%esp)
80106087:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010608a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010608e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106091:	89 04 24             	mov    %eax,(%esp)
80106094:	e8 98 c1 ff ff       	call   80102231 <writei>
80106099:	83 f8 10             	cmp    $0x10,%eax
8010609c:	74 0c                	je     801060aa <sys_unlink+0x154>
    panic("unlink: writei");
8010609e:	c7 04 24 38 8e 10 80 	movl   $0x80108e38,(%esp)
801060a5:	e8 93 a4 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
801060aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ad:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060b1:	66 83 f8 01          	cmp    $0x1,%ax
801060b5:	75 1c                	jne    801060d3 <sys_unlink+0x17d>
    dp->nlink--;
801060b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ba:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060be:	8d 50 ff             	lea    -0x1(%eax),%edx
801060c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801060c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cb:	89 04 24             	mov    %eax,(%esp)
801060ce:	e8 41 b9 ff ff       	call   80101a14 <iupdate>
  }
  iunlockput(dp);
801060d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d6:	89 04 24             	mov    %eax,(%esp)
801060d9:	e8 76 bd ff ff       	call   80101e54 <iunlockput>

  ip->nlink--;
801060de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060e5:	8d 50 ff             	lea    -0x1(%eax),%edx
801060e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060eb:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801060ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f2:	89 04 24             	mov    %eax,(%esp)
801060f5:	e8 1a b9 ff ff       	call   80101a14 <iupdate>
  iunlockput(ip);
801060fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fd:	89 04 24             	mov    %eax,(%esp)
80106100:	e8 4f bd ff ff       	call   80101e54 <iunlockput>

  commit_trans();
80106105:	e8 c4 d4 ff ff       	call   801035ce <commit_trans>

  return 0;
8010610a:	b8 00 00 00 00       	mov    $0x0,%eax
8010610f:	eb 16                	jmp    80106127 <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106111:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80106112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106115:	89 04 24             	mov    %eax,(%esp)
80106118:	e8 37 bd ff ff       	call   80101e54 <iunlockput>
  commit_trans();
8010611d:	e8 ac d4 ff ff       	call   801035ce <commit_trans>
  return -1;
80106122:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106127:	c9                   	leave  
80106128:	c3                   	ret    

80106129 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106129:	55                   	push   %ebp
8010612a:	89 e5                	mov    %esp,%ebp
8010612c:	83 ec 48             	sub    $0x48,%esp
8010612f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106132:	8b 55 10             	mov    0x10(%ebp),%edx
80106135:	8b 45 14             	mov    0x14(%ebp),%eax
80106138:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010613c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106140:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106144:	8d 45 de             	lea    -0x22(%ebp),%eax
80106147:	89 44 24 04          	mov    %eax,0x4(%esp)
8010614b:	8b 45 08             	mov    0x8(%ebp),%eax
8010614e:	89 04 24             	mov    %eax,(%esp)
80106151:	e8 3e c6 ff ff       	call   80102794 <nameiparent>
80106156:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106159:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010615d:	75 0a                	jne    80106169 <create+0x40>
    return 0;
8010615f:	b8 00 00 00 00       	mov    $0x0,%eax
80106164:	e9 7e 01 00 00       	jmp    801062e7 <create+0x1be>
  ilock(dp);
80106169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616c:	89 04 24             	mov    %eax,(%esp)
8010616f:	e8 5c ba ff ff       	call   80101bd0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106174:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106177:	89 44 24 08          	mov    %eax,0x8(%esp)
8010617b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010617e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106185:	89 04 24             	mov    %eax,(%esp)
80106188:	e8 5c c2 ff ff       	call   801023e9 <dirlookup>
8010618d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106190:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106194:	74 47                	je     801061dd <create+0xb4>
    iunlockput(dp);
80106196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106199:	89 04 24             	mov    %eax,(%esp)
8010619c:	e8 b3 bc ff ff       	call   80101e54 <iunlockput>
    ilock(ip);
801061a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a4:	89 04 24             	mov    %eax,(%esp)
801061a7:	e8 24 ba ff ff       	call   80101bd0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801061ac:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801061b1:	75 15                	jne    801061c8 <create+0x9f>
801061b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061ba:	66 83 f8 02          	cmp    $0x2,%ax
801061be:	75 08                	jne    801061c8 <create+0x9f>
      return ip;
801061c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c3:	e9 1f 01 00 00       	jmp    801062e7 <create+0x1be>
    iunlockput(ip);
801061c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061cb:	89 04 24             	mov    %eax,(%esp)
801061ce:	e8 81 bc ff ff       	call   80101e54 <iunlockput>
    return 0;
801061d3:	b8 00 00 00 00       	mov    $0x0,%eax
801061d8:	e9 0a 01 00 00       	jmp    801062e7 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801061dd:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e4:	8b 00                	mov    (%eax),%eax
801061e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801061ea:	89 04 24             	mov    %eax,(%esp)
801061ed:	e8 45 b7 ff ff       	call   80101937 <ialloc>
801061f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061f9:	75 0c                	jne    80106207 <create+0xde>
    panic("create: ialloc");
801061fb:	c7 04 24 47 8e 10 80 	movl   $0x80108e47,(%esp)
80106202:	e8 36 a3 ff ff       	call   8010053d <panic>

  ilock(ip);
80106207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620a:	89 04 24             	mov    %eax,(%esp)
8010620d:	e8 be b9 ff ff       	call   80101bd0 <ilock>
  ip->major = major;
80106212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106215:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106219:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
8010621d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106220:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106224:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106228:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622b:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106234:	89 04 24             	mov    %eax,(%esp)
80106237:	e8 d8 b7 ff ff       	call   80101a14 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010623c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106241:	75 6a                	jne    801062ad <create+0x184>
    dp->nlink++;  // for ".."
80106243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106246:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010624a:	8d 50 01             	lea    0x1(%eax),%edx
8010624d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106250:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106257:	89 04 24             	mov    %eax,(%esp)
8010625a:	e8 b5 b7 ff ff       	call   80101a14 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010625f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106262:	8b 40 04             	mov    0x4(%eax),%eax
80106265:	89 44 24 08          	mov    %eax,0x8(%esp)
80106269:	c7 44 24 04 21 8e 10 	movl   $0x80108e21,0x4(%esp)
80106270:	80 
80106271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106274:	89 04 24             	mov    %eax,(%esp)
80106277:	e8 35 c2 ff ff       	call   801024b1 <dirlink>
8010627c:	85 c0                	test   %eax,%eax
8010627e:	78 21                	js     801062a1 <create+0x178>
80106280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106283:	8b 40 04             	mov    0x4(%eax),%eax
80106286:	89 44 24 08          	mov    %eax,0x8(%esp)
8010628a:	c7 44 24 04 23 8e 10 	movl   $0x80108e23,0x4(%esp)
80106291:	80 
80106292:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106295:	89 04 24             	mov    %eax,(%esp)
80106298:	e8 14 c2 ff ff       	call   801024b1 <dirlink>
8010629d:	85 c0                	test   %eax,%eax
8010629f:	79 0c                	jns    801062ad <create+0x184>
      panic("create dots");
801062a1:	c7 04 24 56 8e 10 80 	movl   $0x80108e56,(%esp)
801062a8:	e8 90 a2 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801062ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b0:	8b 40 04             	mov    0x4(%eax),%eax
801062b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801062b7:	8d 45 de             	lea    -0x22(%ebp),%eax
801062ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801062be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c1:	89 04 24             	mov    %eax,(%esp)
801062c4:	e8 e8 c1 ff ff       	call   801024b1 <dirlink>
801062c9:	85 c0                	test   %eax,%eax
801062cb:	79 0c                	jns    801062d9 <create+0x1b0>
    panic("create: dirlink");
801062cd:	c7 04 24 62 8e 10 80 	movl   $0x80108e62,(%esp)
801062d4:	e8 64 a2 ff ff       	call   8010053d <panic>

  iunlockput(dp);
801062d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062dc:	89 04 24             	mov    %eax,(%esp)
801062df:	e8 70 bb ff ff       	call   80101e54 <iunlockput>

  return ip;
801062e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062e7:	c9                   	leave  
801062e8:	c3                   	ret    

801062e9 <sys_open>:

int
sys_open(void)
{
801062e9:	55                   	push   %ebp
801062ea:	89 e5                	mov    %esp,%ebp
801062ec:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062ef:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801062f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062fd:	e8 a2 f6 ff ff       	call   801059a4 <argstr>
80106302:	85 c0                	test   %eax,%eax
80106304:	78 17                	js     8010631d <sys_open+0x34>
80106306:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106309:	89 44 24 04          	mov    %eax,0x4(%esp)
8010630d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106314:	e8 f1 f5 ff ff       	call   8010590a <argint>
80106319:	85 c0                	test   %eax,%eax
8010631b:	79 0a                	jns    80106327 <sys_open+0x3e>
    return -1;
8010631d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106322:	e9 46 01 00 00       	jmp    8010646d <sys_open+0x184>
  if(omode & O_CREATE){
80106327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010632a:	25 00 02 00 00       	and    $0x200,%eax
8010632f:	85 c0                	test   %eax,%eax
80106331:	74 40                	je     80106373 <sys_open+0x8a>
    begin_trans();
80106333:	e8 4d d2 ff ff       	call   80103585 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80106338:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010633b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106342:	00 
80106343:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010634a:	00 
8010634b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106352:	00 
80106353:	89 04 24             	mov    %eax,(%esp)
80106356:	e8 ce fd ff ff       	call   80106129 <create>
8010635b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
8010635e:	e8 6b d2 ff ff       	call   801035ce <commit_trans>
    if(ip == 0)
80106363:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106367:	75 5c                	jne    801063c5 <sys_open+0xdc>
      return -1;
80106369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010636e:	e9 fa 00 00 00       	jmp    8010646d <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
80106373:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106376:	89 04 24             	mov    %eax,(%esp)
80106379:	e8 f4 c3 ff ff       	call   80102772 <namei>
8010637e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106381:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106385:	75 0a                	jne    80106391 <sys_open+0xa8>
      return -1;
80106387:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638c:	e9 dc 00 00 00       	jmp    8010646d <sys_open+0x184>
    ilock(ip);
80106391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106394:	89 04 24             	mov    %eax,(%esp)
80106397:	e8 34 b8 ff ff       	call   80101bd0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010639c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063a3:	66 83 f8 01          	cmp    $0x1,%ax
801063a7:	75 1c                	jne    801063c5 <sys_open+0xdc>
801063a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ac:	85 c0                	test   %eax,%eax
801063ae:	74 15                	je     801063c5 <sys_open+0xdc>
      iunlockput(ip);
801063b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b3:	89 04 24             	mov    %eax,(%esp)
801063b6:	e8 99 ba ff ff       	call   80101e54 <iunlockput>
      return -1;
801063bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c0:	e9 a8 00 00 00       	jmp    8010646d <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063c5:	e8 ba ae ff ff       	call   80101284 <filealloc>
801063ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063d1:	74 14                	je     801063e7 <sys_open+0xfe>
801063d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d6:	89 04 24             	mov    %eax,(%esp)
801063d9:	e8 43 f7 ff ff       	call   80105b21 <fdalloc>
801063de:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063e1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063e5:	79 23                	jns    8010640a <sys_open+0x121>
    if(f)
801063e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063eb:	74 0b                	je     801063f8 <sys_open+0x10f>
      fileclose(f);
801063ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f0:	89 04 24             	mov    %eax,(%esp)
801063f3:	e8 34 af ff ff       	call   8010132c <fileclose>
    iunlockput(ip);
801063f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fb:	89 04 24             	mov    %eax,(%esp)
801063fe:	e8 51 ba ff ff       	call   80101e54 <iunlockput>
    return -1;
80106403:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106408:	eb 63                	jmp    8010646d <sys_open+0x184>
  }
  iunlock(ip);
8010640a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640d:	89 04 24             	mov    %eax,(%esp)
80106410:	e8 09 b9 ff ff       	call   80101d1e <iunlock>

  f->type = FD_INODE;
80106415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106418:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010641e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106421:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106424:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106427:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106434:	83 e0 01             	and    $0x1,%eax
80106437:	85 c0                	test   %eax,%eax
80106439:	0f 94 c2             	sete   %dl
8010643c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010643f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106442:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106445:	83 e0 01             	and    $0x1,%eax
80106448:	84 c0                	test   %al,%al
8010644a:	75 0a                	jne    80106456 <sys_open+0x16d>
8010644c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010644f:	83 e0 02             	and    $0x2,%eax
80106452:	85 c0                	test   %eax,%eax
80106454:	74 07                	je     8010645d <sys_open+0x174>
80106456:	b8 01 00 00 00       	mov    $0x1,%eax
8010645b:	eb 05                	jmp    80106462 <sys_open+0x179>
8010645d:	b8 00 00 00 00       	mov    $0x0,%eax
80106462:	89 c2                	mov    %eax,%edx
80106464:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106467:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010646a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010646d:	c9                   	leave  
8010646e:	c3                   	ret    

8010646f <sys_mkdir>:

int
sys_mkdir(void)
{
8010646f:	55                   	push   %ebp
80106470:	89 e5                	mov    %esp,%ebp
80106472:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80106475:	e8 0b d1 ff ff       	call   80103585 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010647a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010647d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106481:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106488:	e8 17 f5 ff ff       	call   801059a4 <argstr>
8010648d:	85 c0                	test   %eax,%eax
8010648f:	78 2c                	js     801064bd <sys_mkdir+0x4e>
80106491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106494:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010649b:	00 
8010649c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801064a3:	00 
801064a4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801064ab:	00 
801064ac:	89 04 24             	mov    %eax,(%esp)
801064af:	e8 75 fc ff ff       	call   80106129 <create>
801064b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064bb:	75 0c                	jne    801064c9 <sys_mkdir+0x5a>
    commit_trans();
801064bd:	e8 0c d1 ff ff       	call   801035ce <commit_trans>
    return -1;
801064c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c7:	eb 15                	jmp    801064de <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801064c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064cc:	89 04 24             	mov    %eax,(%esp)
801064cf:	e8 80 b9 ff ff       	call   80101e54 <iunlockput>
  commit_trans();
801064d4:	e8 f5 d0 ff ff       	call   801035ce <commit_trans>
  return 0;
801064d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064de:	c9                   	leave  
801064df:	c3                   	ret    

801064e0 <sys_mknod>:

int
sys_mknod(void)
{
801064e0:	55                   	push   %ebp
801064e1:	89 e5                	mov    %esp,%ebp
801064e3:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
801064e6:	e8 9a d0 ff ff       	call   80103585 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
801064eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801064f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f9:	e8 a6 f4 ff ff       	call   801059a4 <argstr>
801064fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106501:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106505:	78 5e                	js     80106565 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106507:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010650a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010650e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106515:	e8 f0 f3 ff ff       	call   8010590a <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
8010651a:	85 c0                	test   %eax,%eax
8010651c:	78 47                	js     80106565 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010651e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106521:	89 44 24 04          	mov    %eax,0x4(%esp)
80106525:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010652c:	e8 d9 f3 ff ff       	call   8010590a <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106531:	85 c0                	test   %eax,%eax
80106533:	78 30                	js     80106565 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106538:	0f bf c8             	movswl %ax,%ecx
8010653b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010653e:	0f bf d0             	movswl %ax,%edx
80106541:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106544:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106548:	89 54 24 08          	mov    %edx,0x8(%esp)
8010654c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106553:	00 
80106554:	89 04 24             	mov    %eax,(%esp)
80106557:	e8 cd fb ff ff       	call   80106129 <create>
8010655c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010655f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106563:	75 0c                	jne    80106571 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80106565:	e8 64 d0 ff ff       	call   801035ce <commit_trans>
    return -1;
8010656a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656f:	eb 15                	jmp    80106586 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106574:	89 04 24             	mov    %eax,(%esp)
80106577:	e8 d8 b8 ff ff       	call   80101e54 <iunlockput>
  commit_trans();
8010657c:	e8 4d d0 ff ff       	call   801035ce <commit_trans>
  return 0;
80106581:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106586:	c9                   	leave  
80106587:	c3                   	ret    

80106588 <sys_chdir>:

int
sys_chdir(void)
{
80106588:	55                   	push   %ebp
80106589:	89 e5                	mov    %esp,%ebp
8010658b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
8010658e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106591:	89 44 24 04          	mov    %eax,0x4(%esp)
80106595:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010659c:	e8 03 f4 ff ff       	call   801059a4 <argstr>
801065a1:	85 c0                	test   %eax,%eax
801065a3:	78 14                	js     801065b9 <sys_chdir+0x31>
801065a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a8:	89 04 24             	mov    %eax,(%esp)
801065ab:	e8 c2 c1 ff ff       	call   80102772 <namei>
801065b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065b7:	75 07                	jne    801065c0 <sys_chdir+0x38>
    return -1;
801065b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065be:	eb 57                	jmp    80106617 <sys_chdir+0x8f>
  ilock(ip);
801065c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c3:	89 04 24             	mov    %eax,(%esp)
801065c6:	e8 05 b6 ff ff       	call   80101bd0 <ilock>
  if(ip->type != T_DIR){
801065cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ce:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065d2:	66 83 f8 01          	cmp    $0x1,%ax
801065d6:	74 12                	je     801065ea <sys_chdir+0x62>
    iunlockput(ip);
801065d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065db:	89 04 24             	mov    %eax,(%esp)
801065de:	e8 71 b8 ff ff       	call   80101e54 <iunlockput>
    return -1;
801065e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e8:	eb 2d                	jmp    80106617 <sys_chdir+0x8f>
  }
  iunlock(ip);
801065ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ed:	89 04 24             	mov    %eax,(%esp)
801065f0:	e8 29 b7 ff ff       	call   80101d1e <iunlock>
  iput(proc->cwd);
801065f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065fb:	8b 40 68             	mov    0x68(%eax),%eax
801065fe:	89 04 24             	mov    %eax,(%esp)
80106601:	e8 7d b7 ff ff       	call   80101d83 <iput>
  proc->cwd = ip;
80106606:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010660c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010660f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106612:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106617:	c9                   	leave  
80106618:	c3                   	ret    

80106619 <sys_exec>:

int
sys_exec(void)
{
80106619:	55                   	push   %ebp
8010661a:	89 e5                	mov    %esp,%ebp
8010661c:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106622:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106625:	89 44 24 04          	mov    %eax,0x4(%esp)
80106629:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106630:	e8 6f f3 ff ff       	call   801059a4 <argstr>
80106635:	85 c0                	test   %eax,%eax
80106637:	78 1a                	js     80106653 <sys_exec+0x3a>
80106639:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010663f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106643:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010664a:	e8 bb f2 ff ff       	call   8010590a <argint>
8010664f:	85 c0                	test   %eax,%eax
80106651:	79 0a                	jns    8010665d <sys_exec+0x44>
    return -1;
80106653:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106658:	e9 e2 00 00 00       	jmp    8010673f <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
8010665d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106664:	00 
80106665:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010666c:	00 
8010666d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106673:	89 04 24             	mov    %eax,(%esp)
80106676:	e8 3f ef ff ff       	call   801055ba <memset>
  for(i=0;; i++){
8010667b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106685:	83 f8 1f             	cmp    $0x1f,%eax
80106688:	76 0a                	jbe    80106694 <sys_exec+0x7b>
      return -1;
8010668a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010668f:	e9 ab 00 00 00       	jmp    8010673f <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
80106694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106697:	c1 e0 02             	shl    $0x2,%eax
8010669a:	89 c2                	mov    %eax,%edx
8010669c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066a2:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801066a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066ab:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
801066b1:	89 54 24 08          	mov    %edx,0x8(%esp)
801066b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801066b9:	89 04 24             	mov    %eax,(%esp)
801066bc:	e8 b7 f1 ff ff       	call   80105878 <fetchint>
801066c1:	85 c0                	test   %eax,%eax
801066c3:	79 07                	jns    801066cc <sys_exec+0xb3>
      return -1;
801066c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ca:	eb 73                	jmp    8010673f <sys_exec+0x126>
    if(uarg == 0){
801066cc:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066d2:	85 c0                	test   %eax,%eax
801066d4:	75 26                	jne    801066fc <sys_exec+0xe3>
      argv[i] = 0;
801066d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d9:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066e0:	00 00 00 00 
      break;
801066e4:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066e8:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066ee:	89 54 24 04          	mov    %edx,0x4(%esp)
801066f2:	89 04 24             	mov    %eax,(%esp)
801066f5:	e8 6a a7 ff ff       	call   80100e64 <exec>
801066fa:	eb 43                	jmp    8010673f <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
801066fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106706:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010670c:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
8010670f:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106715:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010671b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010671f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106723:	89 04 24             	mov    %eax,(%esp)
80106726:	e8 81 f1 ff ff       	call   801058ac <fetchstr>
8010672b:	85 c0                	test   %eax,%eax
8010672d:	79 07                	jns    80106736 <sys_exec+0x11d>
      return -1;
8010672f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106734:	eb 09                	jmp    8010673f <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106736:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
8010673a:	e9 43 ff ff ff       	jmp    80106682 <sys_exec+0x69>
  return exec(path, argv);
}
8010673f:	c9                   	leave  
80106740:	c3                   	ret    

80106741 <sys_pipe>:

int
sys_pipe(void)
{
80106741:	55                   	push   %ebp
80106742:	89 e5                	mov    %esp,%ebp
80106744:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106747:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010674e:	00 
8010674f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106752:	89 44 24 04          	mov    %eax,0x4(%esp)
80106756:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010675d:	e8 e0 f1 ff ff       	call   80105942 <argptr>
80106762:	85 c0                	test   %eax,%eax
80106764:	79 0a                	jns    80106770 <sys_pipe+0x2f>
    return -1;
80106766:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676b:	e9 9b 00 00 00       	jmp    8010680b <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106770:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106773:	89 44 24 04          	mov    %eax,0x4(%esp)
80106777:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010677a:	89 04 24             	mov    %eax,(%esp)
8010677d:	e8 1e d8 ff ff       	call   80103fa0 <pipealloc>
80106782:	85 c0                	test   %eax,%eax
80106784:	79 07                	jns    8010678d <sys_pipe+0x4c>
    return -1;
80106786:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678b:	eb 7e                	jmp    8010680b <sys_pipe+0xca>
  fd0 = -1;
8010678d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106794:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106797:	89 04 24             	mov    %eax,(%esp)
8010679a:	e8 82 f3 ff ff       	call   80105b21 <fdalloc>
8010679f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a6:	78 14                	js     801067bc <sys_pipe+0x7b>
801067a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067ab:	89 04 24             	mov    %eax,(%esp)
801067ae:	e8 6e f3 ff ff       	call   80105b21 <fdalloc>
801067b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067ba:	79 37                	jns    801067f3 <sys_pipe+0xb2>
    if(fd0 >= 0)
801067bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067c0:	78 14                	js     801067d6 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801067c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067cb:	83 c2 08             	add    $0x8,%edx
801067ce:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067d5:	00 
    fileclose(rf);
801067d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067d9:	89 04 24             	mov    %eax,(%esp)
801067dc:	e8 4b ab ff ff       	call   8010132c <fileclose>
    fileclose(wf);
801067e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067e4:	89 04 24             	mov    %eax,(%esp)
801067e7:	e8 40 ab ff ff       	call   8010132c <fileclose>
    return -1;
801067ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f1:	eb 18                	jmp    8010680b <sys_pipe+0xca>
  }
  fd[0] = fd0;
801067f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067f9:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067fe:	8d 50 04             	lea    0x4(%eax),%edx
80106801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106804:	89 02                	mov    %eax,(%edx)
  return 0;
80106806:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010680b:	c9                   	leave  
8010680c:	c3                   	ret    
8010680d:	00 00                	add    %al,(%eax)
	...

80106810 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106810:	55                   	push   %ebp
80106811:	89 e5                	mov    %esp,%ebp
80106813:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106816:	e8 42 de ff ff       	call   8010465d <fork>
}
8010681b:	c9                   	leave  
8010681c:	c3                   	ret    

8010681d <sys_exit>:

int
sys_exit(void)
{
8010681d:	55                   	push   %ebp
8010681e:	89 e5                	mov    %esp,%ebp
80106820:	83 ec 08             	sub    $0x8,%esp
  exit();
80106823:	e8 e5 df ff ff       	call   8010480d <exit>
  return 0;  // not reached
80106828:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010682d:	c9                   	leave  
8010682e:	c3                   	ret    

8010682f <sys_wait>:

int
sys_wait(void)
{
8010682f:	55                   	push   %ebp
80106830:	89 e5                	mov    %esp,%ebp
80106832:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106835:	e8 28 e1 ff ff       	call   80104962 <wait>
}
8010683a:	c9                   	leave  
8010683b:	c3                   	ret    

8010683c <sys_wait2>:

int
sys_wait2(void)
{
8010683c:	55                   	push   %ebp
8010683d:	89 e5                	mov    %esp,%ebp
8010683f:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
80106842:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
80106849:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
80106850:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106857:	00 
80106858:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010685b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010685f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106866:	e8 d7 f0 ff ff       	call   80105942 <argptr>
  argptr(0,&wtime,sizeof(wtime));
8010686b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106872:	00 
80106873:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106876:	89 44 24 04          	mov    %eax,0x4(%esp)
8010687a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106881:	e8 bc f0 ff ff       	call   80105942 <argptr>
  return wait2((int*)wtime, (int*)rtime);
80106886:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010688c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106890:	89 04 24             	mov    %eax,(%esp)
80106893:	e8 dc e1 ff ff       	call   80104a74 <wait2>
}
80106898:	c9                   	leave  
80106899:	c3                   	ret    

8010689a <sys_nice>:

int
sys_nice(void)
{
8010689a:	55                   	push   %ebp
8010689b:	89 e5                	mov    %esp,%ebp
8010689d:	83 ec 08             	sub    $0x8,%esp
  return nice();
801068a0:	e8 1c ea ff ff       	call   801052c1 <nice>
}
801068a5:	c9                   	leave  
801068a6:	c3                   	ret    

801068a7 <sys_kill>:
int
sys_kill(void)
{
801068a7:	55                   	push   %ebp
801068a8:	89 e5                	mov    %esp,%ebp
801068aa:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801068ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801068b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068bb:	e8 4a f0 ff ff       	call   8010590a <argint>
801068c0:	85 c0                	test   %eax,%eax
801068c2:	79 07                	jns    801068cb <sys_kill+0x24>
    return -1;
801068c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c9:	eb 0b                	jmp    801068d6 <sys_kill+0x2f>
  return kill(pid);
801068cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ce:	89 04 24             	mov    %eax,(%esp)
801068d1:	e8 74 e8 ff ff       	call   8010514a <kill>
}
801068d6:	c9                   	leave  
801068d7:	c3                   	ret    

801068d8 <sys_getpid>:

int
sys_getpid(void)
{
801068d8:	55                   	push   %ebp
801068d9:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801068db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068e1:	8b 40 10             	mov    0x10(%eax),%eax
}
801068e4:	5d                   	pop    %ebp
801068e5:	c3                   	ret    

801068e6 <sys_sbrk>:

int
sys_sbrk(void)
{
801068e6:	55                   	push   %ebp
801068e7:	89 e5                	mov    %esp,%ebp
801068e9:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801068ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801068f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068fa:	e8 0b f0 ff ff       	call   8010590a <argint>
801068ff:	85 c0                	test   %eax,%eax
80106901:	79 07                	jns    8010690a <sys_sbrk+0x24>
    return -1;
80106903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106908:	eb 24                	jmp    8010692e <sys_sbrk+0x48>
  addr = proc->sz;
8010690a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106910:	8b 00                	mov    (%eax),%eax
80106912:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106918:	89 04 24             	mov    %eax,(%esp)
8010691b:	e8 98 dc ff ff       	call   801045b8 <growproc>
80106920:	85 c0                	test   %eax,%eax
80106922:	79 07                	jns    8010692b <sys_sbrk+0x45>
    return -1;
80106924:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106929:	eb 03                	jmp    8010692e <sys_sbrk+0x48>
  return addr;
8010692b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010692e:	c9                   	leave  
8010692f:	c3                   	ret    

80106930 <sys_sleep>:

int
sys_sleep(void)
{
80106930:	55                   	push   %ebp
80106931:	89 e5                	mov    %esp,%ebp
80106933:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106936:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106939:	89 44 24 04          	mov    %eax,0x4(%esp)
8010693d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106944:	e8 c1 ef ff ff       	call   8010590a <argint>
80106949:	85 c0                	test   %eax,%eax
8010694b:	79 07                	jns    80106954 <sys_sleep+0x24>
    return -1;
8010694d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106952:	eb 6c                	jmp    801069c0 <sys_sleep+0x90>
  acquire(&tickslock);
80106954:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
8010695b:	e8 0b ea ff ff       	call   8010536b <acquire>
  ticks0 = ticks;
80106960:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
80106965:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106968:	eb 34                	jmp    8010699e <sys_sleep+0x6e>
    if(proc->killed){
8010696a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106970:	8b 40 24             	mov    0x24(%eax),%eax
80106973:	85 c0                	test   %eax,%eax
80106975:	74 13                	je     8010698a <sys_sleep+0x5a>
      release(&tickslock);
80106977:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
8010697e:	e8 4a ea ff ff       	call   801053cd <release>
      return -1;
80106983:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106988:	eb 36                	jmp    801069c0 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010698a:	c7 44 24 04 80 34 11 	movl   $0x80113480,0x4(%esp)
80106991:	80 
80106992:	c7 04 24 c0 3c 11 80 	movl   $0x80113cc0,(%esp)
80106999:	e8 a5 e6 ff ff       	call   80105043 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010699e:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
801069a3:	89 c2                	mov    %eax,%edx
801069a5:	2b 55 f4             	sub    -0xc(%ebp),%edx
801069a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ab:	39 c2                	cmp    %eax,%edx
801069ad:	72 bb                	jb     8010696a <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801069af:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
801069b6:	e8 12 ea ff ff       	call   801053cd <release>
  return 0;
801069bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069c0:	c9                   	leave  
801069c1:	c3                   	ret    

801069c2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801069c2:	55                   	push   %ebp
801069c3:	89 e5                	mov    %esp,%ebp
801069c5:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801069c8:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
801069cf:	e8 97 e9 ff ff       	call   8010536b <acquire>
  xticks = ticks;
801069d4:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
801069d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801069dc:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
801069e3:	e8 e5 e9 ff ff       	call   801053cd <release>
  return xticks;
801069e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069eb:	c9                   	leave  
801069ec:	c3                   	ret    
801069ed:	00 00                	add    %al,(%eax)
	...

801069f0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801069f0:	55                   	push   %ebp
801069f1:	89 e5                	mov    %esp,%ebp
801069f3:	83 ec 08             	sub    $0x8,%esp
801069f6:	8b 55 08             	mov    0x8(%ebp),%edx
801069f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801069fc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106a00:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a03:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a07:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106a0b:	ee                   	out    %al,(%dx)
}
80106a0c:	c9                   	leave  
80106a0d:	c3                   	ret    

80106a0e <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106a0e:	55                   	push   %ebp
80106a0f:	89 e5                	mov    %esp,%ebp
80106a11:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106a14:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106a1b:	00 
80106a1c:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106a23:	e8 c8 ff ff ff       	call   801069f0 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106a28:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106a2f:	00 
80106a30:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106a37:	e8 b4 ff ff ff       	call   801069f0 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106a3c:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106a43:	00 
80106a44:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106a4b:	e8 a0 ff ff ff       	call   801069f0 <outb>
  picenable(IRQ_TIMER);
80106a50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a57:	e8 cd d3 ff ff       	call   80103e29 <picenable>
}
80106a5c:	c9                   	leave  
80106a5d:	c3                   	ret    
	...

80106a60 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a60:	1e                   	push   %ds
  pushl %es
80106a61:	06                   	push   %es
  pushl %fs
80106a62:	0f a0                	push   %fs
  pushl %gs
80106a64:	0f a8                	push   %gs
  pushal
80106a66:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106a67:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106a6b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106a6d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106a6f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106a73:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106a75:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106a77:	54                   	push   %esp
  call trap
80106a78:	e8 de 01 00 00       	call   80106c5b <trap>
  addl $4, %esp
80106a7d:	83 c4 04             	add    $0x4,%esp

80106a80 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106a80:	61                   	popa   
  popl %gs
80106a81:	0f a9                	pop    %gs
  popl %fs
80106a83:	0f a1                	pop    %fs
  popl %es
80106a85:	07                   	pop    %es
  popl %ds
80106a86:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a87:	83 c4 08             	add    $0x8,%esp
  iret
80106a8a:	cf                   	iret   
	...

80106a8c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106a8c:	55                   	push   %ebp
80106a8d:	89 e5                	mov    %esp,%ebp
80106a8f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106a92:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a95:	83 e8 01             	sub    $0x1,%eax
80106a98:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa6:	c1 e8 10             	shr    $0x10,%eax
80106aa9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106aad:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106ab0:	0f 01 18             	lidtl  (%eax)
}
80106ab3:	c9                   	leave  
80106ab4:	c3                   	ret    

80106ab5 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106ab5:	55                   	push   %ebp
80106ab6:	89 e5                	mov    %esp,%ebp
80106ab8:	53                   	push   %ebx
80106ab9:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106abc:	0f 20 d3             	mov    %cr2,%ebx
80106abf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106ac2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106ac5:	83 c4 10             	add    $0x10,%esp
80106ac8:	5b                   	pop    %ebx
80106ac9:	5d                   	pop    %ebp
80106aca:	c3                   	ret    

80106acb <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106acb:	55                   	push   %ebp
80106acc:	89 e5                	mov    %esp,%ebp
80106ace:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106ad1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ad8:	e9 c3 00 00 00       	jmp    80106ba0 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae0:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106ae7:	89 c2                	mov    %eax,%edx
80106ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aec:	66 89 14 c5 c0 34 11 	mov    %dx,-0x7feecb40(,%eax,8)
80106af3:	80 
80106af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af7:	66 c7 04 c5 c2 34 11 	movw   $0x8,-0x7feecb3e(,%eax,8)
80106afe:	80 08 00 
80106b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b04:	0f b6 14 c5 c4 34 11 	movzbl -0x7feecb3c(,%eax,8),%edx
80106b0b:	80 
80106b0c:	83 e2 e0             	and    $0xffffffe0,%edx
80106b0f:	88 14 c5 c4 34 11 80 	mov    %dl,-0x7feecb3c(,%eax,8)
80106b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b19:	0f b6 14 c5 c4 34 11 	movzbl -0x7feecb3c(,%eax,8),%edx
80106b20:	80 
80106b21:	83 e2 1f             	and    $0x1f,%edx
80106b24:	88 14 c5 c4 34 11 80 	mov    %dl,-0x7feecb3c(,%eax,8)
80106b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2e:	0f b6 14 c5 c5 34 11 	movzbl -0x7feecb3b(,%eax,8),%edx
80106b35:	80 
80106b36:	83 e2 f0             	and    $0xfffffff0,%edx
80106b39:	83 ca 0e             	or     $0xe,%edx
80106b3c:	88 14 c5 c5 34 11 80 	mov    %dl,-0x7feecb3b(,%eax,8)
80106b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b46:	0f b6 14 c5 c5 34 11 	movzbl -0x7feecb3b(,%eax,8),%edx
80106b4d:	80 
80106b4e:	83 e2 ef             	and    $0xffffffef,%edx
80106b51:	88 14 c5 c5 34 11 80 	mov    %dl,-0x7feecb3b(,%eax,8)
80106b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5b:	0f b6 14 c5 c5 34 11 	movzbl -0x7feecb3b(,%eax,8),%edx
80106b62:	80 
80106b63:	83 e2 9f             	and    $0xffffff9f,%edx
80106b66:	88 14 c5 c5 34 11 80 	mov    %dl,-0x7feecb3b(,%eax,8)
80106b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b70:	0f b6 14 c5 c5 34 11 	movzbl -0x7feecb3b(,%eax,8),%edx
80106b77:	80 
80106b78:	83 ca 80             	or     $0xffffff80,%edx
80106b7b:	88 14 c5 c5 34 11 80 	mov    %dl,-0x7feecb3b(,%eax,8)
80106b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b85:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106b8c:	c1 e8 10             	shr    $0x10,%eax
80106b8f:	89 c2                	mov    %eax,%edx
80106b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b94:	66 89 14 c5 c6 34 11 	mov    %dx,-0x7feecb3a(,%eax,8)
80106b9b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106b9c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ba0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106ba7:	0f 8e 30 ff ff ff    	jle    80106add <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106bad:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106bb2:	66 a3 c0 36 11 80    	mov    %ax,0x801136c0
80106bb8:	66 c7 05 c2 36 11 80 	movw   $0x8,0x801136c2
80106bbf:	08 00 
80106bc1:	0f b6 05 c4 36 11 80 	movzbl 0x801136c4,%eax
80106bc8:	83 e0 e0             	and    $0xffffffe0,%eax
80106bcb:	a2 c4 36 11 80       	mov    %al,0x801136c4
80106bd0:	0f b6 05 c4 36 11 80 	movzbl 0x801136c4,%eax
80106bd7:	83 e0 1f             	and    $0x1f,%eax
80106bda:	a2 c4 36 11 80       	mov    %al,0x801136c4
80106bdf:	0f b6 05 c5 36 11 80 	movzbl 0x801136c5,%eax
80106be6:	83 c8 0f             	or     $0xf,%eax
80106be9:	a2 c5 36 11 80       	mov    %al,0x801136c5
80106bee:	0f b6 05 c5 36 11 80 	movzbl 0x801136c5,%eax
80106bf5:	83 e0 ef             	and    $0xffffffef,%eax
80106bf8:	a2 c5 36 11 80       	mov    %al,0x801136c5
80106bfd:	0f b6 05 c5 36 11 80 	movzbl 0x801136c5,%eax
80106c04:	83 c8 60             	or     $0x60,%eax
80106c07:	a2 c5 36 11 80       	mov    %al,0x801136c5
80106c0c:	0f b6 05 c5 36 11 80 	movzbl 0x801136c5,%eax
80106c13:	83 c8 80             	or     $0xffffff80,%eax
80106c16:	a2 c5 36 11 80       	mov    %al,0x801136c5
80106c1b:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106c20:	c1 e8 10             	shr    $0x10,%eax
80106c23:	66 a3 c6 36 11 80    	mov    %ax,0x801136c6
  
  initlock(&tickslock, "time");
80106c29:	c7 44 24 04 74 8e 10 	movl   $0x80108e74,0x4(%esp)
80106c30:	80 
80106c31:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106c38:	e8 0d e7 ff ff       	call   8010534a <initlock>
}
80106c3d:	c9                   	leave  
80106c3e:	c3                   	ret    

80106c3f <idtinit>:

void
idtinit(void)
{
80106c3f:	55                   	push   %ebp
80106c40:	89 e5                	mov    %esp,%ebp
80106c42:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106c45:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106c4c:	00 
80106c4d:	c7 04 24 c0 34 11 80 	movl   $0x801134c0,(%esp)
80106c54:	e8 33 fe ff ff       	call   80106a8c <lidt>
}
80106c59:	c9                   	leave  
80106c5a:	c3                   	ret    

80106c5b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c5b:	55                   	push   %ebp
80106c5c:	89 e5                	mov    %esp,%ebp
80106c5e:	57                   	push   %edi
80106c5f:	56                   	push   %esi
80106c60:	53                   	push   %ebx
80106c61:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106c64:	8b 45 08             	mov    0x8(%ebp),%eax
80106c67:	8b 40 30             	mov    0x30(%eax),%eax
80106c6a:	83 f8 40             	cmp    $0x40,%eax
80106c6d:	75 3e                	jne    80106cad <trap+0x52>
    if(proc->killed)
80106c6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c75:	8b 40 24             	mov    0x24(%eax),%eax
80106c78:	85 c0                	test   %eax,%eax
80106c7a:	74 05                	je     80106c81 <trap+0x26>
      exit();
80106c7c:	e8 8c db ff ff       	call   8010480d <exit>
    proc->tf = tf;
80106c81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c87:	8b 55 08             	mov    0x8(%ebp),%edx
80106c8a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106c8d:	e8 55 ed ff ff       	call   801059e7 <syscall>
    if(proc->killed)
80106c92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c98:	8b 40 24             	mov    0x24(%eax),%eax
80106c9b:	85 c0                	test   %eax,%eax
80106c9d:	0f 84 78 02 00 00    	je     80106f1b <trap+0x2c0>
      exit();
80106ca3:	e8 65 db ff ff       	call   8010480d <exit>
    return;
80106ca8:	e9 6e 02 00 00       	jmp    80106f1b <trap+0x2c0>
  }

  switch(tf->trapno){
80106cad:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb0:	8b 40 30             	mov    0x30(%eax),%eax
80106cb3:	83 e8 20             	sub    $0x20,%eax
80106cb6:	83 f8 1f             	cmp    $0x1f,%eax
80106cb9:	0f 87 f0 00 00 00    	ja     80106daf <trap+0x154>
80106cbf:	8b 04 85 1c 8f 10 80 	mov    -0x7fef70e4(,%eax,4),%eax
80106cc6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106cc8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106cce:	0f b6 00             	movzbl (%eax),%eax
80106cd1:	84 c0                	test   %al,%al
80106cd3:	75 65                	jne    80106d3a <trap+0xdf>
      acquire(&tickslock);
80106cd5:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106cdc:	e8 8a e6 ff ff       	call   8010536b <acquire>
      ticks++;
80106ce1:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
80106ce6:	83 c0 01             	add    $0x1,%eax
80106ce9:	a3 c0 3c 11 80       	mov    %eax,0x80113cc0
      if(proc)
80106cee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cf4:	85 c0                	test   %eax,%eax
80106cf6:	74 2a                	je     80106d22 <trap+0xc7>
      {
	proc->rtime++;
80106cf8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cfe:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106d04:	83 c2 01             	add    $0x1,%edx
80106d07:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	proc->quanta--;
80106d0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d13:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106d19:	83 ea 01             	sub    $0x1,%edx
80106d1c:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
      wakeup(&ticks);
80106d22:	c7 04 24 c0 3c 11 80 	movl   $0x80113cc0,(%esp)
80106d29:	e8 f1 e3 ff ff       	call   8010511f <wakeup>
      release(&tickslock);
80106d2e:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106d35:	e8 93 e6 ff ff       	call   801053cd <release>
    }
    lapiceoi();
80106d3a:	e8 12 c5 ff ff       	call   80103251 <lapiceoi>
    break;
80106d3f:	e9 41 01 00 00       	jmp    80106e85 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106d44:	e8 10 bd ff ff       	call   80102a59 <ideintr>
    lapiceoi();
80106d49:	e8 03 c5 ff ff       	call   80103251 <lapiceoi>
    break;
80106d4e:	e9 32 01 00 00       	jmp    80106e85 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106d53:	e8 d7 c2 ff ff       	call   8010302f <kbdintr>
    lapiceoi();
80106d58:	e8 f4 c4 ff ff       	call   80103251 <lapiceoi>
    break;
80106d5d:	e9 23 01 00 00       	jmp    80106e85 <trap+0x22a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d62:	e8 b9 03 00 00       	call   80107120 <uartintr>
    lapiceoi();
80106d67:	e8 e5 c4 ff ff       	call   80103251 <lapiceoi>
    break;
80106d6c:	e9 14 01 00 00       	jmp    80106e85 <trap+0x22a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106d71:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d74:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106d77:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d7e:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106d81:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d87:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d8a:	0f b6 c0             	movzbl %al,%eax
80106d8d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106d91:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d95:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d99:	c7 04 24 7c 8e 10 80 	movl   $0x80108e7c,(%esp)
80106da0:	e8 fc 95 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106da5:	e8 a7 c4 ff ff       	call   80103251 <lapiceoi>
    break;
80106daa:	e9 d6 00 00 00       	jmp    80106e85 <trap+0x22a>
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106daf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106db5:	85 c0                	test   %eax,%eax
80106db7:	74 11                	je     80106dca <trap+0x16f>
80106db9:	8b 45 08             	mov    0x8(%ebp),%eax
80106dbc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106dc0:	0f b7 c0             	movzwl %ax,%eax
80106dc3:	83 e0 03             	and    $0x3,%eax
80106dc6:	85 c0                	test   %eax,%eax
80106dc8:	75 46                	jne    80106e10 <trap+0x1b5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106dca:	e8 e6 fc ff ff       	call   80106ab5 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106dcf:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106dd2:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106dd5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106ddc:	0f b6 12             	movzbl (%edx),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ddf:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106de2:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106de5:	8b 52 30             	mov    0x30(%edx),%edx
80106de8:	89 44 24 10          	mov    %eax,0x10(%esp)
80106dec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106df0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106df4:	89 54 24 04          	mov    %edx,0x4(%esp)
80106df8:	c7 04 24 a0 8e 10 80 	movl   $0x80108ea0,(%esp)
80106dff:	e8 9d 95 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106e04:	c7 04 24 d2 8e 10 80 	movl   $0x80108ed2,(%esp)
80106e0b:	e8 2d 97 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e10:	e8 a0 fc ff ff       	call   80106ab5 <rcr2>
80106e15:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e17:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e1a:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e1d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e23:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e26:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e29:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e2c:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e2f:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e32:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e3b:	83 c0 6c             	add    $0x6c,%eax
80106e3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106e41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e47:	8b 40 10             	mov    0x10(%eax),%eax
80106e4a:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106e4e:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106e52:	89 74 24 14          	mov    %esi,0x14(%esp)
80106e56:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106e5a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106e5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106e61:	89 54 24 08          	mov    %edx,0x8(%esp)
80106e65:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e69:	c7 04 24 d8 8e 10 80 	movl   $0x80108ed8,(%esp)
80106e70:	e8 2c 95 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106e75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e7b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106e82:	eb 01                	jmp    80106e85 <trap+0x22a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106e84:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106e85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e8b:	85 c0                	test   %eax,%eax
80106e8d:	74 24                	je     80106eb3 <trap+0x258>
80106e8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e95:	8b 40 24             	mov    0x24(%eax),%eax
80106e98:	85 c0                	test   %eax,%eax
80106e9a:	74 17                	je     80106eb3 <trap+0x258>
80106e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ea3:	0f b7 c0             	movzwl %ax,%eax
80106ea6:	83 e0 03             	and    $0x3,%eax
80106ea9:	83 f8 03             	cmp    $0x3,%eax
80106eac:	75 05                	jne    80106eb3 <trap+0x258>
    exit();
80106eae:	e8 5a d9 ff ff       	call   8010480d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && proc->quanta <= 0)
80106eb3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eb9:	85 c0                	test   %eax,%eax
80106ebb:	74 2e                	je     80106eeb <trap+0x290>
80106ebd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ec3:	8b 40 0c             	mov    0xc(%eax),%eax
80106ec6:	83 f8 04             	cmp    $0x4,%eax
80106ec9:	75 20                	jne    80106eeb <trap+0x290>
80106ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ece:	8b 40 30             	mov    0x30(%eax),%eax
80106ed1:	83 f8 20             	cmp    $0x20,%eax
80106ed4:	75 15                	jne    80106eeb <trap+0x290>
80106ed6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106edc:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106ee2:	85 c0                	test   %eax,%eax
80106ee4:	7f 05                	jg     80106eeb <trap+0x290>
    yield();
80106ee6:	e8 e9 e0 ff ff       	call   80104fd4 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106eeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ef1:	85 c0                	test   %eax,%eax
80106ef3:	74 27                	je     80106f1c <trap+0x2c1>
80106ef5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106efb:	8b 40 24             	mov    0x24(%eax),%eax
80106efe:	85 c0                	test   %eax,%eax
80106f00:	74 1a                	je     80106f1c <trap+0x2c1>
80106f02:	8b 45 08             	mov    0x8(%ebp),%eax
80106f05:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f09:	0f b7 c0             	movzwl %ax,%eax
80106f0c:	83 e0 03             	and    $0x3,%eax
80106f0f:	83 f8 03             	cmp    $0x3,%eax
80106f12:	75 08                	jne    80106f1c <trap+0x2c1>
    exit();
80106f14:	e8 f4 d8 ff ff       	call   8010480d <exit>
80106f19:	eb 01                	jmp    80106f1c <trap+0x2c1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106f1b:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106f1c:	83 c4 3c             	add    $0x3c,%esp
80106f1f:	5b                   	pop    %ebx
80106f20:	5e                   	pop    %esi
80106f21:	5f                   	pop    %edi
80106f22:	5d                   	pop    %ebp
80106f23:	c3                   	ret    

80106f24 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106f24:	55                   	push   %ebp
80106f25:	89 e5                	mov    %esp,%ebp
80106f27:	53                   	push   %ebx
80106f28:	83 ec 14             	sub    $0x14,%esp
80106f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f32:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106f36:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106f3a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106f3e:	ec                   	in     (%dx),%al
80106f3f:	89 c3                	mov    %eax,%ebx
80106f41:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106f44:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106f48:	83 c4 14             	add    $0x14,%esp
80106f4b:	5b                   	pop    %ebx
80106f4c:	5d                   	pop    %ebp
80106f4d:	c3                   	ret    

80106f4e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106f4e:	55                   	push   %ebp
80106f4f:	89 e5                	mov    %esp,%ebp
80106f51:	83 ec 08             	sub    $0x8,%esp
80106f54:	8b 55 08             	mov    0x8(%ebp),%edx
80106f57:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f5a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106f5e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f61:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f65:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f69:	ee                   	out    %al,(%dx)
}
80106f6a:	c9                   	leave  
80106f6b:	c3                   	ret    

80106f6c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f6c:	55                   	push   %ebp
80106f6d:	89 e5                	mov    %esp,%ebp
80106f6f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106f79:	00 
80106f7a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106f81:	e8 c8 ff ff ff       	call   80106f4e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f86:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106f8d:	00 
80106f8e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106f95:	e8 b4 ff ff ff       	call   80106f4e <outb>
  outb(COM1+0, 115200/9600);
80106f9a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106fa1:	00 
80106fa2:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106fa9:	e8 a0 ff ff ff       	call   80106f4e <outb>
  outb(COM1+1, 0);
80106fae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106fb5:	00 
80106fb6:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106fbd:	e8 8c ff ff ff       	call   80106f4e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106fc2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106fc9:	00 
80106fca:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106fd1:	e8 78 ff ff ff       	call   80106f4e <outb>
  outb(COM1+4, 0);
80106fd6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106fdd:	00 
80106fde:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106fe5:	e8 64 ff ff ff       	call   80106f4e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106fea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106ff1:	00 
80106ff2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106ff9:	e8 50 ff ff ff       	call   80106f4e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106ffe:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107005:	e8 1a ff ff ff       	call   80106f24 <inb>
8010700a:	3c ff                	cmp    $0xff,%al
8010700c:	74 6c                	je     8010707a <uartinit+0x10e>
    return;
  uart = 1;
8010700e:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80107015:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107018:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010701f:	e8 00 ff ff ff       	call   80106f24 <inb>
  inb(COM1+0);
80107024:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010702b:	e8 f4 fe ff ff       	call   80106f24 <inb>
  picenable(IRQ_COM1);
80107030:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107037:	e8 ed cd ff ff       	call   80103e29 <picenable>
  ioapicenable(IRQ_COM1, 0);
8010703c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107043:	00 
80107044:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010704b:	e8 8e bc ff ff       	call   80102cde <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107050:	c7 45 f4 9c 8f 10 80 	movl   $0x80108f9c,-0xc(%ebp)
80107057:	eb 15                	jmp    8010706e <uartinit+0x102>
    uartputc(*p);
80107059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705c:	0f b6 00             	movzbl (%eax),%eax
8010705f:	0f be c0             	movsbl %al,%eax
80107062:	89 04 24             	mov    %eax,(%esp)
80107065:	e8 13 00 00 00       	call   8010707d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010706a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010706e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107071:	0f b6 00             	movzbl (%eax),%eax
80107074:	84 c0                	test   %al,%al
80107076:	75 e1                	jne    80107059 <uartinit+0xed>
80107078:	eb 01                	jmp    8010707b <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010707a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
8010707b:	c9                   	leave  
8010707c:	c3                   	ret    

8010707d <uartputc>:

void
uartputc(int c)
{
8010707d:	55                   	push   %ebp
8010707e:	89 e5                	mov    %esp,%ebp
80107080:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107083:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107088:	85 c0                	test   %eax,%eax
8010708a:	74 4d                	je     801070d9 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010708c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107093:	eb 10                	jmp    801070a5 <uartputc+0x28>
    microdelay(10);
80107095:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010709c:	e8 d5 c1 ff ff       	call   80103276 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070a5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070a9:	7f 16                	jg     801070c1 <uartputc+0x44>
801070ab:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801070b2:	e8 6d fe ff ff       	call   80106f24 <inb>
801070b7:	0f b6 c0             	movzbl %al,%eax
801070ba:	83 e0 20             	and    $0x20,%eax
801070bd:	85 c0                	test   %eax,%eax
801070bf:	74 d4                	je     80107095 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801070c1:	8b 45 08             	mov    0x8(%ebp),%eax
801070c4:	0f b6 c0             	movzbl %al,%eax
801070c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801070cb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801070d2:	e8 77 fe ff ff       	call   80106f4e <outb>
801070d7:	eb 01                	jmp    801070da <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801070d9:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801070da:	c9                   	leave  
801070db:	c3                   	ret    

801070dc <uartgetc>:

static int
uartgetc(void)
{
801070dc:	55                   	push   %ebp
801070dd:	89 e5                	mov    %esp,%ebp
801070df:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801070e2:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
801070e7:	85 c0                	test   %eax,%eax
801070e9:	75 07                	jne    801070f2 <uartgetc+0x16>
    return -1;
801070eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070f0:	eb 2c                	jmp    8010711e <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801070f2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801070f9:	e8 26 fe ff ff       	call   80106f24 <inb>
801070fe:	0f b6 c0             	movzbl %al,%eax
80107101:	83 e0 01             	and    $0x1,%eax
80107104:	85 c0                	test   %eax,%eax
80107106:	75 07                	jne    8010710f <uartgetc+0x33>
    return -1;
80107108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010710d:	eb 0f                	jmp    8010711e <uartgetc+0x42>
  return inb(COM1+0);
8010710f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107116:	e8 09 fe ff ff       	call   80106f24 <inb>
8010711b:	0f b6 c0             	movzbl %al,%eax
}
8010711e:	c9                   	leave  
8010711f:	c3                   	ret    

80107120 <uartintr>:

void
uartintr(void)
{
80107120:	55                   	push   %ebp
80107121:	89 e5                	mov    %esp,%ebp
80107123:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107126:	c7 04 24 dc 70 10 80 	movl   $0x801070dc,(%esp)
8010712d:	e8 9c 97 ff ff       	call   801008ce <consoleintr>
}
80107132:	c9                   	leave  
80107133:	c3                   	ret    

80107134 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $0
80107136:	6a 00                	push   $0x0
  jmp alltraps
80107138:	e9 23 f9 ff ff       	jmp    80106a60 <alltraps>

8010713d <vector1>:
.globl vector1
vector1:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $1
8010713f:	6a 01                	push   $0x1
  jmp alltraps
80107141:	e9 1a f9 ff ff       	jmp    80106a60 <alltraps>

80107146 <vector2>:
.globl vector2
vector2:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $2
80107148:	6a 02                	push   $0x2
  jmp alltraps
8010714a:	e9 11 f9 ff ff       	jmp    80106a60 <alltraps>

8010714f <vector3>:
.globl vector3
vector3:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $3
80107151:	6a 03                	push   $0x3
  jmp alltraps
80107153:	e9 08 f9 ff ff       	jmp    80106a60 <alltraps>

80107158 <vector4>:
.globl vector4
vector4:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $4
8010715a:	6a 04                	push   $0x4
  jmp alltraps
8010715c:	e9 ff f8 ff ff       	jmp    80106a60 <alltraps>

80107161 <vector5>:
.globl vector5
vector5:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $5
80107163:	6a 05                	push   $0x5
  jmp alltraps
80107165:	e9 f6 f8 ff ff       	jmp    80106a60 <alltraps>

8010716a <vector6>:
.globl vector6
vector6:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $6
8010716c:	6a 06                	push   $0x6
  jmp alltraps
8010716e:	e9 ed f8 ff ff       	jmp    80106a60 <alltraps>

80107173 <vector7>:
.globl vector7
vector7:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $7
80107175:	6a 07                	push   $0x7
  jmp alltraps
80107177:	e9 e4 f8 ff ff       	jmp    80106a60 <alltraps>

8010717c <vector8>:
.globl vector8
vector8:
  pushl $8
8010717c:	6a 08                	push   $0x8
  jmp alltraps
8010717e:	e9 dd f8 ff ff       	jmp    80106a60 <alltraps>

80107183 <vector9>:
.globl vector9
vector9:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $9
80107185:	6a 09                	push   $0x9
  jmp alltraps
80107187:	e9 d4 f8 ff ff       	jmp    80106a60 <alltraps>

8010718c <vector10>:
.globl vector10
vector10:
  pushl $10
8010718c:	6a 0a                	push   $0xa
  jmp alltraps
8010718e:	e9 cd f8 ff ff       	jmp    80106a60 <alltraps>

80107193 <vector11>:
.globl vector11
vector11:
  pushl $11
80107193:	6a 0b                	push   $0xb
  jmp alltraps
80107195:	e9 c6 f8 ff ff       	jmp    80106a60 <alltraps>

8010719a <vector12>:
.globl vector12
vector12:
  pushl $12
8010719a:	6a 0c                	push   $0xc
  jmp alltraps
8010719c:	e9 bf f8 ff ff       	jmp    80106a60 <alltraps>

801071a1 <vector13>:
.globl vector13
vector13:
  pushl $13
801071a1:	6a 0d                	push   $0xd
  jmp alltraps
801071a3:	e9 b8 f8 ff ff       	jmp    80106a60 <alltraps>

801071a8 <vector14>:
.globl vector14
vector14:
  pushl $14
801071a8:	6a 0e                	push   $0xe
  jmp alltraps
801071aa:	e9 b1 f8 ff ff       	jmp    80106a60 <alltraps>

801071af <vector15>:
.globl vector15
vector15:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $15
801071b1:	6a 0f                	push   $0xf
  jmp alltraps
801071b3:	e9 a8 f8 ff ff       	jmp    80106a60 <alltraps>

801071b8 <vector16>:
.globl vector16
vector16:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $16
801071ba:	6a 10                	push   $0x10
  jmp alltraps
801071bc:	e9 9f f8 ff ff       	jmp    80106a60 <alltraps>

801071c1 <vector17>:
.globl vector17
vector17:
  pushl $17
801071c1:	6a 11                	push   $0x11
  jmp alltraps
801071c3:	e9 98 f8 ff ff       	jmp    80106a60 <alltraps>

801071c8 <vector18>:
.globl vector18
vector18:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $18
801071ca:	6a 12                	push   $0x12
  jmp alltraps
801071cc:	e9 8f f8 ff ff       	jmp    80106a60 <alltraps>

801071d1 <vector19>:
.globl vector19
vector19:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $19
801071d3:	6a 13                	push   $0x13
  jmp alltraps
801071d5:	e9 86 f8 ff ff       	jmp    80106a60 <alltraps>

801071da <vector20>:
.globl vector20
vector20:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $20
801071dc:	6a 14                	push   $0x14
  jmp alltraps
801071de:	e9 7d f8 ff ff       	jmp    80106a60 <alltraps>

801071e3 <vector21>:
.globl vector21
vector21:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $21
801071e5:	6a 15                	push   $0x15
  jmp alltraps
801071e7:	e9 74 f8 ff ff       	jmp    80106a60 <alltraps>

801071ec <vector22>:
.globl vector22
vector22:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $22
801071ee:	6a 16                	push   $0x16
  jmp alltraps
801071f0:	e9 6b f8 ff ff       	jmp    80106a60 <alltraps>

801071f5 <vector23>:
.globl vector23
vector23:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $23
801071f7:	6a 17                	push   $0x17
  jmp alltraps
801071f9:	e9 62 f8 ff ff       	jmp    80106a60 <alltraps>

801071fe <vector24>:
.globl vector24
vector24:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $24
80107200:	6a 18                	push   $0x18
  jmp alltraps
80107202:	e9 59 f8 ff ff       	jmp    80106a60 <alltraps>

80107207 <vector25>:
.globl vector25
vector25:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $25
80107209:	6a 19                	push   $0x19
  jmp alltraps
8010720b:	e9 50 f8 ff ff       	jmp    80106a60 <alltraps>

80107210 <vector26>:
.globl vector26
vector26:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $26
80107212:	6a 1a                	push   $0x1a
  jmp alltraps
80107214:	e9 47 f8 ff ff       	jmp    80106a60 <alltraps>

80107219 <vector27>:
.globl vector27
vector27:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $27
8010721b:	6a 1b                	push   $0x1b
  jmp alltraps
8010721d:	e9 3e f8 ff ff       	jmp    80106a60 <alltraps>

80107222 <vector28>:
.globl vector28
vector28:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $28
80107224:	6a 1c                	push   $0x1c
  jmp alltraps
80107226:	e9 35 f8 ff ff       	jmp    80106a60 <alltraps>

8010722b <vector29>:
.globl vector29
vector29:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $29
8010722d:	6a 1d                	push   $0x1d
  jmp alltraps
8010722f:	e9 2c f8 ff ff       	jmp    80106a60 <alltraps>

80107234 <vector30>:
.globl vector30
vector30:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $30
80107236:	6a 1e                	push   $0x1e
  jmp alltraps
80107238:	e9 23 f8 ff ff       	jmp    80106a60 <alltraps>

8010723d <vector31>:
.globl vector31
vector31:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $31
8010723f:	6a 1f                	push   $0x1f
  jmp alltraps
80107241:	e9 1a f8 ff ff       	jmp    80106a60 <alltraps>

80107246 <vector32>:
.globl vector32
vector32:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $32
80107248:	6a 20                	push   $0x20
  jmp alltraps
8010724a:	e9 11 f8 ff ff       	jmp    80106a60 <alltraps>

8010724f <vector33>:
.globl vector33
vector33:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $33
80107251:	6a 21                	push   $0x21
  jmp alltraps
80107253:	e9 08 f8 ff ff       	jmp    80106a60 <alltraps>

80107258 <vector34>:
.globl vector34
vector34:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $34
8010725a:	6a 22                	push   $0x22
  jmp alltraps
8010725c:	e9 ff f7 ff ff       	jmp    80106a60 <alltraps>

80107261 <vector35>:
.globl vector35
vector35:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $35
80107263:	6a 23                	push   $0x23
  jmp alltraps
80107265:	e9 f6 f7 ff ff       	jmp    80106a60 <alltraps>

8010726a <vector36>:
.globl vector36
vector36:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $36
8010726c:	6a 24                	push   $0x24
  jmp alltraps
8010726e:	e9 ed f7 ff ff       	jmp    80106a60 <alltraps>

80107273 <vector37>:
.globl vector37
vector37:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $37
80107275:	6a 25                	push   $0x25
  jmp alltraps
80107277:	e9 e4 f7 ff ff       	jmp    80106a60 <alltraps>

8010727c <vector38>:
.globl vector38
vector38:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $38
8010727e:	6a 26                	push   $0x26
  jmp alltraps
80107280:	e9 db f7 ff ff       	jmp    80106a60 <alltraps>

80107285 <vector39>:
.globl vector39
vector39:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $39
80107287:	6a 27                	push   $0x27
  jmp alltraps
80107289:	e9 d2 f7 ff ff       	jmp    80106a60 <alltraps>

8010728e <vector40>:
.globl vector40
vector40:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $40
80107290:	6a 28                	push   $0x28
  jmp alltraps
80107292:	e9 c9 f7 ff ff       	jmp    80106a60 <alltraps>

80107297 <vector41>:
.globl vector41
vector41:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $41
80107299:	6a 29                	push   $0x29
  jmp alltraps
8010729b:	e9 c0 f7 ff ff       	jmp    80106a60 <alltraps>

801072a0 <vector42>:
.globl vector42
vector42:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $42
801072a2:	6a 2a                	push   $0x2a
  jmp alltraps
801072a4:	e9 b7 f7 ff ff       	jmp    80106a60 <alltraps>

801072a9 <vector43>:
.globl vector43
vector43:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $43
801072ab:	6a 2b                	push   $0x2b
  jmp alltraps
801072ad:	e9 ae f7 ff ff       	jmp    80106a60 <alltraps>

801072b2 <vector44>:
.globl vector44
vector44:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $44
801072b4:	6a 2c                	push   $0x2c
  jmp alltraps
801072b6:	e9 a5 f7 ff ff       	jmp    80106a60 <alltraps>

801072bb <vector45>:
.globl vector45
vector45:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $45
801072bd:	6a 2d                	push   $0x2d
  jmp alltraps
801072bf:	e9 9c f7 ff ff       	jmp    80106a60 <alltraps>

801072c4 <vector46>:
.globl vector46
vector46:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $46
801072c6:	6a 2e                	push   $0x2e
  jmp alltraps
801072c8:	e9 93 f7 ff ff       	jmp    80106a60 <alltraps>

801072cd <vector47>:
.globl vector47
vector47:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $47
801072cf:	6a 2f                	push   $0x2f
  jmp alltraps
801072d1:	e9 8a f7 ff ff       	jmp    80106a60 <alltraps>

801072d6 <vector48>:
.globl vector48
vector48:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $48
801072d8:	6a 30                	push   $0x30
  jmp alltraps
801072da:	e9 81 f7 ff ff       	jmp    80106a60 <alltraps>

801072df <vector49>:
.globl vector49
vector49:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $49
801072e1:	6a 31                	push   $0x31
  jmp alltraps
801072e3:	e9 78 f7 ff ff       	jmp    80106a60 <alltraps>

801072e8 <vector50>:
.globl vector50
vector50:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $50
801072ea:	6a 32                	push   $0x32
  jmp alltraps
801072ec:	e9 6f f7 ff ff       	jmp    80106a60 <alltraps>

801072f1 <vector51>:
.globl vector51
vector51:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $51
801072f3:	6a 33                	push   $0x33
  jmp alltraps
801072f5:	e9 66 f7 ff ff       	jmp    80106a60 <alltraps>

801072fa <vector52>:
.globl vector52
vector52:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $52
801072fc:	6a 34                	push   $0x34
  jmp alltraps
801072fe:	e9 5d f7 ff ff       	jmp    80106a60 <alltraps>

80107303 <vector53>:
.globl vector53
vector53:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $53
80107305:	6a 35                	push   $0x35
  jmp alltraps
80107307:	e9 54 f7 ff ff       	jmp    80106a60 <alltraps>

8010730c <vector54>:
.globl vector54
vector54:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $54
8010730e:	6a 36                	push   $0x36
  jmp alltraps
80107310:	e9 4b f7 ff ff       	jmp    80106a60 <alltraps>

80107315 <vector55>:
.globl vector55
vector55:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $55
80107317:	6a 37                	push   $0x37
  jmp alltraps
80107319:	e9 42 f7 ff ff       	jmp    80106a60 <alltraps>

8010731e <vector56>:
.globl vector56
vector56:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $56
80107320:	6a 38                	push   $0x38
  jmp alltraps
80107322:	e9 39 f7 ff ff       	jmp    80106a60 <alltraps>

80107327 <vector57>:
.globl vector57
vector57:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $57
80107329:	6a 39                	push   $0x39
  jmp alltraps
8010732b:	e9 30 f7 ff ff       	jmp    80106a60 <alltraps>

80107330 <vector58>:
.globl vector58
vector58:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $58
80107332:	6a 3a                	push   $0x3a
  jmp alltraps
80107334:	e9 27 f7 ff ff       	jmp    80106a60 <alltraps>

80107339 <vector59>:
.globl vector59
vector59:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $59
8010733b:	6a 3b                	push   $0x3b
  jmp alltraps
8010733d:	e9 1e f7 ff ff       	jmp    80106a60 <alltraps>

80107342 <vector60>:
.globl vector60
vector60:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $60
80107344:	6a 3c                	push   $0x3c
  jmp alltraps
80107346:	e9 15 f7 ff ff       	jmp    80106a60 <alltraps>

8010734b <vector61>:
.globl vector61
vector61:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $61
8010734d:	6a 3d                	push   $0x3d
  jmp alltraps
8010734f:	e9 0c f7 ff ff       	jmp    80106a60 <alltraps>

80107354 <vector62>:
.globl vector62
vector62:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $62
80107356:	6a 3e                	push   $0x3e
  jmp alltraps
80107358:	e9 03 f7 ff ff       	jmp    80106a60 <alltraps>

8010735d <vector63>:
.globl vector63
vector63:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $63
8010735f:	6a 3f                	push   $0x3f
  jmp alltraps
80107361:	e9 fa f6 ff ff       	jmp    80106a60 <alltraps>

80107366 <vector64>:
.globl vector64
vector64:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $64
80107368:	6a 40                	push   $0x40
  jmp alltraps
8010736a:	e9 f1 f6 ff ff       	jmp    80106a60 <alltraps>

8010736f <vector65>:
.globl vector65
vector65:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $65
80107371:	6a 41                	push   $0x41
  jmp alltraps
80107373:	e9 e8 f6 ff ff       	jmp    80106a60 <alltraps>

80107378 <vector66>:
.globl vector66
vector66:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $66
8010737a:	6a 42                	push   $0x42
  jmp alltraps
8010737c:	e9 df f6 ff ff       	jmp    80106a60 <alltraps>

80107381 <vector67>:
.globl vector67
vector67:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $67
80107383:	6a 43                	push   $0x43
  jmp alltraps
80107385:	e9 d6 f6 ff ff       	jmp    80106a60 <alltraps>

8010738a <vector68>:
.globl vector68
vector68:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $68
8010738c:	6a 44                	push   $0x44
  jmp alltraps
8010738e:	e9 cd f6 ff ff       	jmp    80106a60 <alltraps>

80107393 <vector69>:
.globl vector69
vector69:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $69
80107395:	6a 45                	push   $0x45
  jmp alltraps
80107397:	e9 c4 f6 ff ff       	jmp    80106a60 <alltraps>

8010739c <vector70>:
.globl vector70
vector70:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $70
8010739e:	6a 46                	push   $0x46
  jmp alltraps
801073a0:	e9 bb f6 ff ff       	jmp    80106a60 <alltraps>

801073a5 <vector71>:
.globl vector71
vector71:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $71
801073a7:	6a 47                	push   $0x47
  jmp alltraps
801073a9:	e9 b2 f6 ff ff       	jmp    80106a60 <alltraps>

801073ae <vector72>:
.globl vector72
vector72:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $72
801073b0:	6a 48                	push   $0x48
  jmp alltraps
801073b2:	e9 a9 f6 ff ff       	jmp    80106a60 <alltraps>

801073b7 <vector73>:
.globl vector73
vector73:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $73
801073b9:	6a 49                	push   $0x49
  jmp alltraps
801073bb:	e9 a0 f6 ff ff       	jmp    80106a60 <alltraps>

801073c0 <vector74>:
.globl vector74
vector74:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $74
801073c2:	6a 4a                	push   $0x4a
  jmp alltraps
801073c4:	e9 97 f6 ff ff       	jmp    80106a60 <alltraps>

801073c9 <vector75>:
.globl vector75
vector75:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $75
801073cb:	6a 4b                	push   $0x4b
  jmp alltraps
801073cd:	e9 8e f6 ff ff       	jmp    80106a60 <alltraps>

801073d2 <vector76>:
.globl vector76
vector76:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $76
801073d4:	6a 4c                	push   $0x4c
  jmp alltraps
801073d6:	e9 85 f6 ff ff       	jmp    80106a60 <alltraps>

801073db <vector77>:
.globl vector77
vector77:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $77
801073dd:	6a 4d                	push   $0x4d
  jmp alltraps
801073df:	e9 7c f6 ff ff       	jmp    80106a60 <alltraps>

801073e4 <vector78>:
.globl vector78
vector78:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $78
801073e6:	6a 4e                	push   $0x4e
  jmp alltraps
801073e8:	e9 73 f6 ff ff       	jmp    80106a60 <alltraps>

801073ed <vector79>:
.globl vector79
vector79:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $79
801073ef:	6a 4f                	push   $0x4f
  jmp alltraps
801073f1:	e9 6a f6 ff ff       	jmp    80106a60 <alltraps>

801073f6 <vector80>:
.globl vector80
vector80:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $80
801073f8:	6a 50                	push   $0x50
  jmp alltraps
801073fa:	e9 61 f6 ff ff       	jmp    80106a60 <alltraps>

801073ff <vector81>:
.globl vector81
vector81:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $81
80107401:	6a 51                	push   $0x51
  jmp alltraps
80107403:	e9 58 f6 ff ff       	jmp    80106a60 <alltraps>

80107408 <vector82>:
.globl vector82
vector82:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $82
8010740a:	6a 52                	push   $0x52
  jmp alltraps
8010740c:	e9 4f f6 ff ff       	jmp    80106a60 <alltraps>

80107411 <vector83>:
.globl vector83
vector83:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $83
80107413:	6a 53                	push   $0x53
  jmp alltraps
80107415:	e9 46 f6 ff ff       	jmp    80106a60 <alltraps>

8010741a <vector84>:
.globl vector84
vector84:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $84
8010741c:	6a 54                	push   $0x54
  jmp alltraps
8010741e:	e9 3d f6 ff ff       	jmp    80106a60 <alltraps>

80107423 <vector85>:
.globl vector85
vector85:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $85
80107425:	6a 55                	push   $0x55
  jmp alltraps
80107427:	e9 34 f6 ff ff       	jmp    80106a60 <alltraps>

8010742c <vector86>:
.globl vector86
vector86:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $86
8010742e:	6a 56                	push   $0x56
  jmp alltraps
80107430:	e9 2b f6 ff ff       	jmp    80106a60 <alltraps>

80107435 <vector87>:
.globl vector87
vector87:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $87
80107437:	6a 57                	push   $0x57
  jmp alltraps
80107439:	e9 22 f6 ff ff       	jmp    80106a60 <alltraps>

8010743e <vector88>:
.globl vector88
vector88:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $88
80107440:	6a 58                	push   $0x58
  jmp alltraps
80107442:	e9 19 f6 ff ff       	jmp    80106a60 <alltraps>

80107447 <vector89>:
.globl vector89
vector89:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $89
80107449:	6a 59                	push   $0x59
  jmp alltraps
8010744b:	e9 10 f6 ff ff       	jmp    80106a60 <alltraps>

80107450 <vector90>:
.globl vector90
vector90:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $90
80107452:	6a 5a                	push   $0x5a
  jmp alltraps
80107454:	e9 07 f6 ff ff       	jmp    80106a60 <alltraps>

80107459 <vector91>:
.globl vector91
vector91:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $91
8010745b:	6a 5b                	push   $0x5b
  jmp alltraps
8010745d:	e9 fe f5 ff ff       	jmp    80106a60 <alltraps>

80107462 <vector92>:
.globl vector92
vector92:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $92
80107464:	6a 5c                	push   $0x5c
  jmp alltraps
80107466:	e9 f5 f5 ff ff       	jmp    80106a60 <alltraps>

8010746b <vector93>:
.globl vector93
vector93:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $93
8010746d:	6a 5d                	push   $0x5d
  jmp alltraps
8010746f:	e9 ec f5 ff ff       	jmp    80106a60 <alltraps>

80107474 <vector94>:
.globl vector94
vector94:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $94
80107476:	6a 5e                	push   $0x5e
  jmp alltraps
80107478:	e9 e3 f5 ff ff       	jmp    80106a60 <alltraps>

8010747d <vector95>:
.globl vector95
vector95:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $95
8010747f:	6a 5f                	push   $0x5f
  jmp alltraps
80107481:	e9 da f5 ff ff       	jmp    80106a60 <alltraps>

80107486 <vector96>:
.globl vector96
vector96:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $96
80107488:	6a 60                	push   $0x60
  jmp alltraps
8010748a:	e9 d1 f5 ff ff       	jmp    80106a60 <alltraps>

8010748f <vector97>:
.globl vector97
vector97:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $97
80107491:	6a 61                	push   $0x61
  jmp alltraps
80107493:	e9 c8 f5 ff ff       	jmp    80106a60 <alltraps>

80107498 <vector98>:
.globl vector98
vector98:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $98
8010749a:	6a 62                	push   $0x62
  jmp alltraps
8010749c:	e9 bf f5 ff ff       	jmp    80106a60 <alltraps>

801074a1 <vector99>:
.globl vector99
vector99:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $99
801074a3:	6a 63                	push   $0x63
  jmp alltraps
801074a5:	e9 b6 f5 ff ff       	jmp    80106a60 <alltraps>

801074aa <vector100>:
.globl vector100
vector100:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $100
801074ac:	6a 64                	push   $0x64
  jmp alltraps
801074ae:	e9 ad f5 ff ff       	jmp    80106a60 <alltraps>

801074b3 <vector101>:
.globl vector101
vector101:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $101
801074b5:	6a 65                	push   $0x65
  jmp alltraps
801074b7:	e9 a4 f5 ff ff       	jmp    80106a60 <alltraps>

801074bc <vector102>:
.globl vector102
vector102:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $102
801074be:	6a 66                	push   $0x66
  jmp alltraps
801074c0:	e9 9b f5 ff ff       	jmp    80106a60 <alltraps>

801074c5 <vector103>:
.globl vector103
vector103:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $103
801074c7:	6a 67                	push   $0x67
  jmp alltraps
801074c9:	e9 92 f5 ff ff       	jmp    80106a60 <alltraps>

801074ce <vector104>:
.globl vector104
vector104:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $104
801074d0:	6a 68                	push   $0x68
  jmp alltraps
801074d2:	e9 89 f5 ff ff       	jmp    80106a60 <alltraps>

801074d7 <vector105>:
.globl vector105
vector105:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $105
801074d9:	6a 69                	push   $0x69
  jmp alltraps
801074db:	e9 80 f5 ff ff       	jmp    80106a60 <alltraps>

801074e0 <vector106>:
.globl vector106
vector106:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $106
801074e2:	6a 6a                	push   $0x6a
  jmp alltraps
801074e4:	e9 77 f5 ff ff       	jmp    80106a60 <alltraps>

801074e9 <vector107>:
.globl vector107
vector107:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $107
801074eb:	6a 6b                	push   $0x6b
  jmp alltraps
801074ed:	e9 6e f5 ff ff       	jmp    80106a60 <alltraps>

801074f2 <vector108>:
.globl vector108
vector108:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $108
801074f4:	6a 6c                	push   $0x6c
  jmp alltraps
801074f6:	e9 65 f5 ff ff       	jmp    80106a60 <alltraps>

801074fb <vector109>:
.globl vector109
vector109:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $109
801074fd:	6a 6d                	push   $0x6d
  jmp alltraps
801074ff:	e9 5c f5 ff ff       	jmp    80106a60 <alltraps>

80107504 <vector110>:
.globl vector110
vector110:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $110
80107506:	6a 6e                	push   $0x6e
  jmp alltraps
80107508:	e9 53 f5 ff ff       	jmp    80106a60 <alltraps>

8010750d <vector111>:
.globl vector111
vector111:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $111
8010750f:	6a 6f                	push   $0x6f
  jmp alltraps
80107511:	e9 4a f5 ff ff       	jmp    80106a60 <alltraps>

80107516 <vector112>:
.globl vector112
vector112:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $112
80107518:	6a 70                	push   $0x70
  jmp alltraps
8010751a:	e9 41 f5 ff ff       	jmp    80106a60 <alltraps>

8010751f <vector113>:
.globl vector113
vector113:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $113
80107521:	6a 71                	push   $0x71
  jmp alltraps
80107523:	e9 38 f5 ff ff       	jmp    80106a60 <alltraps>

80107528 <vector114>:
.globl vector114
vector114:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $114
8010752a:	6a 72                	push   $0x72
  jmp alltraps
8010752c:	e9 2f f5 ff ff       	jmp    80106a60 <alltraps>

80107531 <vector115>:
.globl vector115
vector115:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $115
80107533:	6a 73                	push   $0x73
  jmp alltraps
80107535:	e9 26 f5 ff ff       	jmp    80106a60 <alltraps>

8010753a <vector116>:
.globl vector116
vector116:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $116
8010753c:	6a 74                	push   $0x74
  jmp alltraps
8010753e:	e9 1d f5 ff ff       	jmp    80106a60 <alltraps>

80107543 <vector117>:
.globl vector117
vector117:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $117
80107545:	6a 75                	push   $0x75
  jmp alltraps
80107547:	e9 14 f5 ff ff       	jmp    80106a60 <alltraps>

8010754c <vector118>:
.globl vector118
vector118:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $118
8010754e:	6a 76                	push   $0x76
  jmp alltraps
80107550:	e9 0b f5 ff ff       	jmp    80106a60 <alltraps>

80107555 <vector119>:
.globl vector119
vector119:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $119
80107557:	6a 77                	push   $0x77
  jmp alltraps
80107559:	e9 02 f5 ff ff       	jmp    80106a60 <alltraps>

8010755e <vector120>:
.globl vector120
vector120:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $120
80107560:	6a 78                	push   $0x78
  jmp alltraps
80107562:	e9 f9 f4 ff ff       	jmp    80106a60 <alltraps>

80107567 <vector121>:
.globl vector121
vector121:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $121
80107569:	6a 79                	push   $0x79
  jmp alltraps
8010756b:	e9 f0 f4 ff ff       	jmp    80106a60 <alltraps>

80107570 <vector122>:
.globl vector122
vector122:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $122
80107572:	6a 7a                	push   $0x7a
  jmp alltraps
80107574:	e9 e7 f4 ff ff       	jmp    80106a60 <alltraps>

80107579 <vector123>:
.globl vector123
vector123:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $123
8010757b:	6a 7b                	push   $0x7b
  jmp alltraps
8010757d:	e9 de f4 ff ff       	jmp    80106a60 <alltraps>

80107582 <vector124>:
.globl vector124
vector124:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $124
80107584:	6a 7c                	push   $0x7c
  jmp alltraps
80107586:	e9 d5 f4 ff ff       	jmp    80106a60 <alltraps>

8010758b <vector125>:
.globl vector125
vector125:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $125
8010758d:	6a 7d                	push   $0x7d
  jmp alltraps
8010758f:	e9 cc f4 ff ff       	jmp    80106a60 <alltraps>

80107594 <vector126>:
.globl vector126
vector126:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $126
80107596:	6a 7e                	push   $0x7e
  jmp alltraps
80107598:	e9 c3 f4 ff ff       	jmp    80106a60 <alltraps>

8010759d <vector127>:
.globl vector127
vector127:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $127
8010759f:	6a 7f                	push   $0x7f
  jmp alltraps
801075a1:	e9 ba f4 ff ff       	jmp    80106a60 <alltraps>

801075a6 <vector128>:
.globl vector128
vector128:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $128
801075a8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075ad:	e9 ae f4 ff ff       	jmp    80106a60 <alltraps>

801075b2 <vector129>:
.globl vector129
vector129:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $129
801075b4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075b9:	e9 a2 f4 ff ff       	jmp    80106a60 <alltraps>

801075be <vector130>:
.globl vector130
vector130:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $130
801075c0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075c5:	e9 96 f4 ff ff       	jmp    80106a60 <alltraps>

801075ca <vector131>:
.globl vector131
vector131:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $131
801075cc:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801075d1:	e9 8a f4 ff ff       	jmp    80106a60 <alltraps>

801075d6 <vector132>:
.globl vector132
vector132:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $132
801075d8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801075dd:	e9 7e f4 ff ff       	jmp    80106a60 <alltraps>

801075e2 <vector133>:
.globl vector133
vector133:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $133
801075e4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801075e9:	e9 72 f4 ff ff       	jmp    80106a60 <alltraps>

801075ee <vector134>:
.globl vector134
vector134:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $134
801075f0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801075f5:	e9 66 f4 ff ff       	jmp    80106a60 <alltraps>

801075fa <vector135>:
.globl vector135
vector135:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $135
801075fc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107601:	e9 5a f4 ff ff       	jmp    80106a60 <alltraps>

80107606 <vector136>:
.globl vector136
vector136:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $136
80107608:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010760d:	e9 4e f4 ff ff       	jmp    80106a60 <alltraps>

80107612 <vector137>:
.globl vector137
vector137:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $137
80107614:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107619:	e9 42 f4 ff ff       	jmp    80106a60 <alltraps>

8010761e <vector138>:
.globl vector138
vector138:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $138
80107620:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107625:	e9 36 f4 ff ff       	jmp    80106a60 <alltraps>

8010762a <vector139>:
.globl vector139
vector139:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $139
8010762c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107631:	e9 2a f4 ff ff       	jmp    80106a60 <alltraps>

80107636 <vector140>:
.globl vector140
vector140:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $140
80107638:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010763d:	e9 1e f4 ff ff       	jmp    80106a60 <alltraps>

80107642 <vector141>:
.globl vector141
vector141:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $141
80107644:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107649:	e9 12 f4 ff ff       	jmp    80106a60 <alltraps>

8010764e <vector142>:
.globl vector142
vector142:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $142
80107650:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107655:	e9 06 f4 ff ff       	jmp    80106a60 <alltraps>

8010765a <vector143>:
.globl vector143
vector143:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $143
8010765c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107661:	e9 fa f3 ff ff       	jmp    80106a60 <alltraps>

80107666 <vector144>:
.globl vector144
vector144:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $144
80107668:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010766d:	e9 ee f3 ff ff       	jmp    80106a60 <alltraps>

80107672 <vector145>:
.globl vector145
vector145:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $145
80107674:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107679:	e9 e2 f3 ff ff       	jmp    80106a60 <alltraps>

8010767e <vector146>:
.globl vector146
vector146:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $146
80107680:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107685:	e9 d6 f3 ff ff       	jmp    80106a60 <alltraps>

8010768a <vector147>:
.globl vector147
vector147:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $147
8010768c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107691:	e9 ca f3 ff ff       	jmp    80106a60 <alltraps>

80107696 <vector148>:
.globl vector148
vector148:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $148
80107698:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010769d:	e9 be f3 ff ff       	jmp    80106a60 <alltraps>

801076a2 <vector149>:
.globl vector149
vector149:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $149
801076a4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076a9:	e9 b2 f3 ff ff       	jmp    80106a60 <alltraps>

801076ae <vector150>:
.globl vector150
vector150:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $150
801076b0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076b5:	e9 a6 f3 ff ff       	jmp    80106a60 <alltraps>

801076ba <vector151>:
.globl vector151
vector151:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $151
801076bc:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076c1:	e9 9a f3 ff ff       	jmp    80106a60 <alltraps>

801076c6 <vector152>:
.globl vector152
vector152:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $152
801076c8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801076cd:	e9 8e f3 ff ff       	jmp    80106a60 <alltraps>

801076d2 <vector153>:
.globl vector153
vector153:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $153
801076d4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801076d9:	e9 82 f3 ff ff       	jmp    80106a60 <alltraps>

801076de <vector154>:
.globl vector154
vector154:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $154
801076e0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801076e5:	e9 76 f3 ff ff       	jmp    80106a60 <alltraps>

801076ea <vector155>:
.globl vector155
vector155:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $155
801076ec:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801076f1:	e9 6a f3 ff ff       	jmp    80106a60 <alltraps>

801076f6 <vector156>:
.globl vector156
vector156:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $156
801076f8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801076fd:	e9 5e f3 ff ff       	jmp    80106a60 <alltraps>

80107702 <vector157>:
.globl vector157
vector157:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $157
80107704:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107709:	e9 52 f3 ff ff       	jmp    80106a60 <alltraps>

8010770e <vector158>:
.globl vector158
vector158:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $158
80107710:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107715:	e9 46 f3 ff ff       	jmp    80106a60 <alltraps>

8010771a <vector159>:
.globl vector159
vector159:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $159
8010771c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107721:	e9 3a f3 ff ff       	jmp    80106a60 <alltraps>

80107726 <vector160>:
.globl vector160
vector160:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $160
80107728:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010772d:	e9 2e f3 ff ff       	jmp    80106a60 <alltraps>

80107732 <vector161>:
.globl vector161
vector161:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $161
80107734:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107739:	e9 22 f3 ff ff       	jmp    80106a60 <alltraps>

8010773e <vector162>:
.globl vector162
vector162:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $162
80107740:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107745:	e9 16 f3 ff ff       	jmp    80106a60 <alltraps>

8010774a <vector163>:
.globl vector163
vector163:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $163
8010774c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107751:	e9 0a f3 ff ff       	jmp    80106a60 <alltraps>

80107756 <vector164>:
.globl vector164
vector164:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $164
80107758:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010775d:	e9 fe f2 ff ff       	jmp    80106a60 <alltraps>

80107762 <vector165>:
.globl vector165
vector165:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $165
80107764:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107769:	e9 f2 f2 ff ff       	jmp    80106a60 <alltraps>

8010776e <vector166>:
.globl vector166
vector166:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $166
80107770:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107775:	e9 e6 f2 ff ff       	jmp    80106a60 <alltraps>

8010777a <vector167>:
.globl vector167
vector167:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $167
8010777c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107781:	e9 da f2 ff ff       	jmp    80106a60 <alltraps>

80107786 <vector168>:
.globl vector168
vector168:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $168
80107788:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010778d:	e9 ce f2 ff ff       	jmp    80106a60 <alltraps>

80107792 <vector169>:
.globl vector169
vector169:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $169
80107794:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107799:	e9 c2 f2 ff ff       	jmp    80106a60 <alltraps>

8010779e <vector170>:
.globl vector170
vector170:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $170
801077a0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077a5:	e9 b6 f2 ff ff       	jmp    80106a60 <alltraps>

801077aa <vector171>:
.globl vector171
vector171:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $171
801077ac:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077b1:	e9 aa f2 ff ff       	jmp    80106a60 <alltraps>

801077b6 <vector172>:
.globl vector172
vector172:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $172
801077b8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077bd:	e9 9e f2 ff ff       	jmp    80106a60 <alltraps>

801077c2 <vector173>:
.globl vector173
vector173:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $173
801077c4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801077c9:	e9 92 f2 ff ff       	jmp    80106a60 <alltraps>

801077ce <vector174>:
.globl vector174
vector174:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $174
801077d0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801077d5:	e9 86 f2 ff ff       	jmp    80106a60 <alltraps>

801077da <vector175>:
.globl vector175
vector175:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $175
801077dc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801077e1:	e9 7a f2 ff ff       	jmp    80106a60 <alltraps>

801077e6 <vector176>:
.globl vector176
vector176:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $176
801077e8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801077ed:	e9 6e f2 ff ff       	jmp    80106a60 <alltraps>

801077f2 <vector177>:
.globl vector177
vector177:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $177
801077f4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801077f9:	e9 62 f2 ff ff       	jmp    80106a60 <alltraps>

801077fe <vector178>:
.globl vector178
vector178:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $178
80107800:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107805:	e9 56 f2 ff ff       	jmp    80106a60 <alltraps>

8010780a <vector179>:
.globl vector179
vector179:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $179
8010780c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107811:	e9 4a f2 ff ff       	jmp    80106a60 <alltraps>

80107816 <vector180>:
.globl vector180
vector180:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $180
80107818:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010781d:	e9 3e f2 ff ff       	jmp    80106a60 <alltraps>

80107822 <vector181>:
.globl vector181
vector181:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $181
80107824:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107829:	e9 32 f2 ff ff       	jmp    80106a60 <alltraps>

8010782e <vector182>:
.globl vector182
vector182:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $182
80107830:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107835:	e9 26 f2 ff ff       	jmp    80106a60 <alltraps>

8010783a <vector183>:
.globl vector183
vector183:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $183
8010783c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107841:	e9 1a f2 ff ff       	jmp    80106a60 <alltraps>

80107846 <vector184>:
.globl vector184
vector184:
  pushl $0
80107846:	6a 00                	push   $0x0
  pushl $184
80107848:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010784d:	e9 0e f2 ff ff       	jmp    80106a60 <alltraps>

80107852 <vector185>:
.globl vector185
vector185:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $185
80107854:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107859:	e9 02 f2 ff ff       	jmp    80106a60 <alltraps>

8010785e <vector186>:
.globl vector186
vector186:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $186
80107860:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107865:	e9 f6 f1 ff ff       	jmp    80106a60 <alltraps>

8010786a <vector187>:
.globl vector187
vector187:
  pushl $0
8010786a:	6a 00                	push   $0x0
  pushl $187
8010786c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107871:	e9 ea f1 ff ff       	jmp    80106a60 <alltraps>

80107876 <vector188>:
.globl vector188
vector188:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $188
80107878:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010787d:	e9 de f1 ff ff       	jmp    80106a60 <alltraps>

80107882 <vector189>:
.globl vector189
vector189:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $189
80107884:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107889:	e9 d2 f1 ff ff       	jmp    80106a60 <alltraps>

8010788e <vector190>:
.globl vector190
vector190:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $190
80107890:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107895:	e9 c6 f1 ff ff       	jmp    80106a60 <alltraps>

8010789a <vector191>:
.globl vector191
vector191:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $191
8010789c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078a1:	e9 ba f1 ff ff       	jmp    80106a60 <alltraps>

801078a6 <vector192>:
.globl vector192
vector192:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $192
801078a8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078ad:	e9 ae f1 ff ff       	jmp    80106a60 <alltraps>

801078b2 <vector193>:
.globl vector193
vector193:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $193
801078b4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078b9:	e9 a2 f1 ff ff       	jmp    80106a60 <alltraps>

801078be <vector194>:
.globl vector194
vector194:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $194
801078c0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078c5:	e9 96 f1 ff ff       	jmp    80106a60 <alltraps>

801078ca <vector195>:
.globl vector195
vector195:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $195
801078cc:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801078d1:	e9 8a f1 ff ff       	jmp    80106a60 <alltraps>

801078d6 <vector196>:
.globl vector196
vector196:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $196
801078d8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801078dd:	e9 7e f1 ff ff       	jmp    80106a60 <alltraps>

801078e2 <vector197>:
.globl vector197
vector197:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $197
801078e4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801078e9:	e9 72 f1 ff ff       	jmp    80106a60 <alltraps>

801078ee <vector198>:
.globl vector198
vector198:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $198
801078f0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801078f5:	e9 66 f1 ff ff       	jmp    80106a60 <alltraps>

801078fa <vector199>:
.globl vector199
vector199:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $199
801078fc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107901:	e9 5a f1 ff ff       	jmp    80106a60 <alltraps>

80107906 <vector200>:
.globl vector200
vector200:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $200
80107908:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010790d:	e9 4e f1 ff ff       	jmp    80106a60 <alltraps>

80107912 <vector201>:
.globl vector201
vector201:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $201
80107914:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107919:	e9 42 f1 ff ff       	jmp    80106a60 <alltraps>

8010791e <vector202>:
.globl vector202
vector202:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $202
80107920:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107925:	e9 36 f1 ff ff       	jmp    80106a60 <alltraps>

8010792a <vector203>:
.globl vector203
vector203:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $203
8010792c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107931:	e9 2a f1 ff ff       	jmp    80106a60 <alltraps>

80107936 <vector204>:
.globl vector204
vector204:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $204
80107938:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010793d:	e9 1e f1 ff ff       	jmp    80106a60 <alltraps>

80107942 <vector205>:
.globl vector205
vector205:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $205
80107944:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107949:	e9 12 f1 ff ff       	jmp    80106a60 <alltraps>

8010794e <vector206>:
.globl vector206
vector206:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $206
80107950:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107955:	e9 06 f1 ff ff       	jmp    80106a60 <alltraps>

8010795a <vector207>:
.globl vector207
vector207:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $207
8010795c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107961:	e9 fa f0 ff ff       	jmp    80106a60 <alltraps>

80107966 <vector208>:
.globl vector208
vector208:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $208
80107968:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010796d:	e9 ee f0 ff ff       	jmp    80106a60 <alltraps>

80107972 <vector209>:
.globl vector209
vector209:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $209
80107974:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107979:	e9 e2 f0 ff ff       	jmp    80106a60 <alltraps>

8010797e <vector210>:
.globl vector210
vector210:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $210
80107980:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107985:	e9 d6 f0 ff ff       	jmp    80106a60 <alltraps>

8010798a <vector211>:
.globl vector211
vector211:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $211
8010798c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107991:	e9 ca f0 ff ff       	jmp    80106a60 <alltraps>

80107996 <vector212>:
.globl vector212
vector212:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $212
80107998:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010799d:	e9 be f0 ff ff       	jmp    80106a60 <alltraps>

801079a2 <vector213>:
.globl vector213
vector213:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $213
801079a4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079a9:	e9 b2 f0 ff ff       	jmp    80106a60 <alltraps>

801079ae <vector214>:
.globl vector214
vector214:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $214
801079b0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079b5:	e9 a6 f0 ff ff       	jmp    80106a60 <alltraps>

801079ba <vector215>:
.globl vector215
vector215:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $215
801079bc:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079c1:	e9 9a f0 ff ff       	jmp    80106a60 <alltraps>

801079c6 <vector216>:
.globl vector216
vector216:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $216
801079c8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801079cd:	e9 8e f0 ff ff       	jmp    80106a60 <alltraps>

801079d2 <vector217>:
.globl vector217
vector217:
  pushl $0
801079d2:	6a 00                	push   $0x0
  pushl $217
801079d4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801079d9:	e9 82 f0 ff ff       	jmp    80106a60 <alltraps>

801079de <vector218>:
.globl vector218
vector218:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $218
801079e0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801079e5:	e9 76 f0 ff ff       	jmp    80106a60 <alltraps>

801079ea <vector219>:
.globl vector219
vector219:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $219
801079ec:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801079f1:	e9 6a f0 ff ff       	jmp    80106a60 <alltraps>

801079f6 <vector220>:
.globl vector220
vector220:
  pushl $0
801079f6:	6a 00                	push   $0x0
  pushl $220
801079f8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801079fd:	e9 5e f0 ff ff       	jmp    80106a60 <alltraps>

80107a02 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $221
80107a04:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a09:	e9 52 f0 ff ff       	jmp    80106a60 <alltraps>

80107a0e <vector222>:
.globl vector222
vector222:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $222
80107a10:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a15:	e9 46 f0 ff ff       	jmp    80106a60 <alltraps>

80107a1a <vector223>:
.globl vector223
vector223:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $223
80107a1c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a21:	e9 3a f0 ff ff       	jmp    80106a60 <alltraps>

80107a26 <vector224>:
.globl vector224
vector224:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $224
80107a28:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a2d:	e9 2e f0 ff ff       	jmp    80106a60 <alltraps>

80107a32 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $225
80107a34:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a39:	e9 22 f0 ff ff       	jmp    80106a60 <alltraps>

80107a3e <vector226>:
.globl vector226
vector226:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $226
80107a40:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a45:	e9 16 f0 ff ff       	jmp    80106a60 <alltraps>

80107a4a <vector227>:
.globl vector227
vector227:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $227
80107a4c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a51:	e9 0a f0 ff ff       	jmp    80106a60 <alltraps>

80107a56 <vector228>:
.globl vector228
vector228:
  pushl $0
80107a56:	6a 00                	push   $0x0
  pushl $228
80107a58:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a5d:	e9 fe ef ff ff       	jmp    80106a60 <alltraps>

80107a62 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $229
80107a64:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a69:	e9 f2 ef ff ff       	jmp    80106a60 <alltraps>

80107a6e <vector230>:
.globl vector230
vector230:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $230
80107a70:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a75:	e9 e6 ef ff ff       	jmp    80106a60 <alltraps>

80107a7a <vector231>:
.globl vector231
vector231:
  pushl $0
80107a7a:	6a 00                	push   $0x0
  pushl $231
80107a7c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a81:	e9 da ef ff ff       	jmp    80106a60 <alltraps>

80107a86 <vector232>:
.globl vector232
vector232:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $232
80107a88:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a8d:	e9 ce ef ff ff       	jmp    80106a60 <alltraps>

80107a92 <vector233>:
.globl vector233
vector233:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $233
80107a94:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a99:	e9 c2 ef ff ff       	jmp    80106a60 <alltraps>

80107a9e <vector234>:
.globl vector234
vector234:
  pushl $0
80107a9e:	6a 00                	push   $0x0
  pushl $234
80107aa0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107aa5:	e9 b6 ef ff ff       	jmp    80106a60 <alltraps>

80107aaa <vector235>:
.globl vector235
vector235:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $235
80107aac:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ab1:	e9 aa ef ff ff       	jmp    80106a60 <alltraps>

80107ab6 <vector236>:
.globl vector236
vector236:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $236
80107ab8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107abd:	e9 9e ef ff ff       	jmp    80106a60 <alltraps>

80107ac2 <vector237>:
.globl vector237
vector237:
  pushl $0
80107ac2:	6a 00                	push   $0x0
  pushl $237
80107ac4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107ac9:	e9 92 ef ff ff       	jmp    80106a60 <alltraps>

80107ace <vector238>:
.globl vector238
vector238:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $238
80107ad0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107ad5:	e9 86 ef ff ff       	jmp    80106a60 <alltraps>

80107ada <vector239>:
.globl vector239
vector239:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $239
80107adc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ae1:	e9 7a ef ff ff       	jmp    80106a60 <alltraps>

80107ae6 <vector240>:
.globl vector240
vector240:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $240
80107ae8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107aed:	e9 6e ef ff ff       	jmp    80106a60 <alltraps>

80107af2 <vector241>:
.globl vector241
vector241:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $241
80107af4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107af9:	e9 62 ef ff ff       	jmp    80106a60 <alltraps>

80107afe <vector242>:
.globl vector242
vector242:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $242
80107b00:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b05:	e9 56 ef ff ff       	jmp    80106a60 <alltraps>

80107b0a <vector243>:
.globl vector243
vector243:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $243
80107b0c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b11:	e9 4a ef ff ff       	jmp    80106a60 <alltraps>

80107b16 <vector244>:
.globl vector244
vector244:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $244
80107b18:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b1d:	e9 3e ef ff ff       	jmp    80106a60 <alltraps>

80107b22 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $245
80107b24:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b29:	e9 32 ef ff ff       	jmp    80106a60 <alltraps>

80107b2e <vector246>:
.globl vector246
vector246:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $246
80107b30:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b35:	e9 26 ef ff ff       	jmp    80106a60 <alltraps>

80107b3a <vector247>:
.globl vector247
vector247:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $247
80107b3c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b41:	e9 1a ef ff ff       	jmp    80106a60 <alltraps>

80107b46 <vector248>:
.globl vector248
vector248:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $248
80107b48:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b4d:	e9 0e ef ff ff       	jmp    80106a60 <alltraps>

80107b52 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b52:	6a 00                	push   $0x0
  pushl $249
80107b54:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b59:	e9 02 ef ff ff       	jmp    80106a60 <alltraps>

80107b5e <vector250>:
.globl vector250
vector250:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $250
80107b60:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b65:	e9 f6 ee ff ff       	jmp    80106a60 <alltraps>

80107b6a <vector251>:
.globl vector251
vector251:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $251
80107b6c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b71:	e9 ea ee ff ff       	jmp    80106a60 <alltraps>

80107b76 <vector252>:
.globl vector252
vector252:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $252
80107b78:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b7d:	e9 de ee ff ff       	jmp    80106a60 <alltraps>

80107b82 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $253
80107b84:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b89:	e9 d2 ee ff ff       	jmp    80106a60 <alltraps>

80107b8e <vector254>:
.globl vector254
vector254:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $254
80107b90:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b95:	e9 c6 ee ff ff       	jmp    80106a60 <alltraps>

80107b9a <vector255>:
.globl vector255
vector255:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $255
80107b9c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107ba1:	e9 ba ee ff ff       	jmp    80106a60 <alltraps>
	...

80107ba8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107ba8:	55                   	push   %ebp
80107ba9:	89 e5                	mov    %esp,%ebp
80107bab:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107bae:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bb1:	83 e8 01             	sub    $0x1,%eax
80107bb4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80107bbb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80107bc2:	c1 e8 10             	shr    $0x10,%eax
80107bc5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107bc9:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107bcc:	0f 01 10             	lgdtl  (%eax)
}
80107bcf:	c9                   	leave  
80107bd0:	c3                   	ret    

80107bd1 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107bd1:	55                   	push   %ebp
80107bd2:	89 e5                	mov    %esp,%ebp
80107bd4:	83 ec 04             	sub    $0x4,%esp
80107bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80107bda:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107bde:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107be2:	0f 00 d8             	ltr    %ax
}
80107be5:	c9                   	leave  
80107be6:	c3                   	ret    

80107be7 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107be7:	55                   	push   %ebp
80107be8:	89 e5                	mov    %esp,%ebp
80107bea:	83 ec 04             	sub    $0x4,%esp
80107bed:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107bf4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107bf8:	8e e8                	mov    %eax,%gs
}
80107bfa:	c9                   	leave  
80107bfb:	c3                   	ret    

80107bfc <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107bfc:	55                   	push   %ebp
80107bfd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107bff:	8b 45 08             	mov    0x8(%ebp),%eax
80107c02:	0f 22 d8             	mov    %eax,%cr3
}
80107c05:	5d                   	pop    %ebp
80107c06:	c3                   	ret    

80107c07 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107c07:	55                   	push   %ebp
80107c08:	89 e5                	mov    %esp,%ebp
80107c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80107c0d:	05 00 00 00 80       	add    $0x80000000,%eax
80107c12:	5d                   	pop    %ebp
80107c13:	c3                   	ret    

80107c14 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107c14:	55                   	push   %ebp
80107c15:	89 e5                	mov    %esp,%ebp
80107c17:	8b 45 08             	mov    0x8(%ebp),%eax
80107c1a:	05 00 00 00 80       	add    $0x80000000,%eax
80107c1f:	5d                   	pop    %ebp
80107c20:	c3                   	ret    

80107c21 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c21:	55                   	push   %ebp
80107c22:	89 e5                	mov    %esp,%ebp
80107c24:	53                   	push   %ebx
80107c25:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107c28:	e8 c8 b5 ff ff       	call   801031f5 <cpunum>
80107c2d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107c33:	05 40 09 11 80       	add    $0x80110940,%eax
80107c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c47:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c50:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c57:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c5b:	83 e2 f0             	and    $0xfffffff0,%edx
80107c5e:	83 ca 0a             	or     $0xa,%edx
80107c61:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c67:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c6b:	83 ca 10             	or     $0x10,%edx
80107c6e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c74:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c78:	83 e2 9f             	and    $0xffffff9f,%edx
80107c7b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c81:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c85:	83 ca 80             	or     $0xffffff80,%edx
80107c88:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c92:	83 ca 0f             	or     $0xf,%edx
80107c95:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c9f:	83 e2 ef             	and    $0xffffffef,%edx
80107ca2:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cac:	83 e2 df             	and    $0xffffffdf,%edx
80107caf:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cb9:	83 ca 40             	or     $0x40,%edx
80107cbc:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cc6:	83 ca 80             	or     $0xffffff80,%edx
80107cc9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccf:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107cdd:	ff ff 
80107cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce2:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ce9:	00 00 
80107ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cee:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cff:	83 e2 f0             	and    $0xfffffff0,%edx
80107d02:	83 ca 02             	or     $0x2,%edx
80107d05:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d15:	83 ca 10             	or     $0x10,%edx
80107d18:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d28:	83 e2 9f             	and    $0xffffff9f,%edx
80107d2b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d34:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d3b:	83 ca 80             	or     $0xffffff80,%edx
80107d3e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d47:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d4e:	83 ca 0f             	or     $0xf,%edx
80107d51:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d61:	83 e2 ef             	and    $0xffffffef,%edx
80107d64:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d74:	83 e2 df             	and    $0xffffffdf,%edx
80107d77:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d80:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d87:	83 ca 40             	or     $0x40,%edx
80107d8a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d93:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d9a:	83 ca 80             	or     $0xffffff80,%edx
80107d9d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107db7:	ff ff 
80107db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107dc3:	00 00 
80107dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dd9:	83 e2 f0             	and    $0xfffffff0,%edx
80107ddc:	83 ca 0a             	or     $0xa,%edx
80107ddf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107def:	83 ca 10             	or     $0x10,%edx
80107df2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e02:	83 ca 60             	or     $0x60,%edx
80107e05:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e15:	83 ca 80             	or     $0xffffff80,%edx
80107e18:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e21:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e28:	83 ca 0f             	or     $0xf,%edx
80107e2b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e3b:	83 e2 ef             	and    $0xffffffef,%edx
80107e3e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e47:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e4e:	83 e2 df             	and    $0xffffffdf,%edx
80107e51:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e61:	83 ca 40             	or     $0x40,%edx
80107e64:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e74:	83 ca 80             	or     $0xffffff80,%edx
80107e77:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107e91:	ff ff 
80107e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e96:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107e9d:	00 00 
80107e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea2:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eac:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107eb3:	83 e2 f0             	and    $0xfffffff0,%edx
80107eb6:	83 ca 02             	or     $0x2,%edx
80107eb9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ec9:	83 ca 10             	or     $0x10,%edx
80107ecc:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107edc:	83 ca 60             	or     $0x60,%edx
80107edf:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107eef:	83 ca 80             	or     $0xffffff80,%edx
80107ef2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f02:	83 ca 0f             	or     $0xf,%edx
80107f05:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f15:	83 e2 ef             	and    $0xffffffef,%edx
80107f18:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f28:	83 e2 df             	and    $0xffffffdf,%edx
80107f2b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f34:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f3b:	83 ca 40             	or     $0x40,%edx
80107f3e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f47:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f4e:	83 ca 80             	or     $0xffffff80,%edx
80107f51:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f64:	05 b4 00 00 00       	add    $0xb4,%eax
80107f69:	89 c3                	mov    %eax,%ebx
80107f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6e:	05 b4 00 00 00       	add    $0xb4,%eax
80107f73:	c1 e8 10             	shr    $0x10,%eax
80107f76:	89 c1                	mov    %eax,%ecx
80107f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7b:	05 b4 00 00 00       	add    $0xb4,%eax
80107f80:	c1 e8 18             	shr    $0x18,%eax
80107f83:	89 c2                	mov    %eax,%edx
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f88:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107f8f:	00 00 
80107f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f94:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9e:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa7:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107fae:	83 e1 f0             	and    $0xfffffff0,%ecx
80107fb1:	83 c9 02             	or     $0x2,%ecx
80107fb4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbd:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107fc4:	83 c9 10             	or     $0x10,%ecx
80107fc7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd0:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107fd7:	83 e1 9f             	and    $0xffffff9f,%ecx
80107fda:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107fea:	83 c9 80             	or     $0xffffff80,%ecx
80107fed:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ffd:	83 e1 f0             	and    $0xfffffff0,%ecx
80108000:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108009:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108010:	83 e1 ef             	and    $0xffffffef,%ecx
80108013:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108023:	83 e1 df             	and    $0xffffffdf,%ecx
80108026:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010802c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108036:	83 c9 40             	or     $0x40,%ecx
80108039:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010803f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108042:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108049:	83 c9 80             	or     $0xffffff80,%ecx
8010804c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108055:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010805b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805e:	83 c0 70             	add    $0x70,%eax
80108061:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108068:	00 
80108069:	89 04 24             	mov    %eax,(%esp)
8010806c:	e8 37 fb ff ff       	call   80107ba8 <lgdt>
  loadgs(SEG_KCPU << 3);
80108071:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108078:	e8 6a fb ff ff       	call   80107be7 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010807d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108080:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108086:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010808d:	00 00 00 00 
}
80108091:	83 c4 24             	add    $0x24,%esp
80108094:	5b                   	pop    %ebx
80108095:	5d                   	pop    %ebp
80108096:	c3                   	ret    

80108097 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108097:	55                   	push   %ebp
80108098:	89 e5                	mov    %esp,%ebp
8010809a:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010809d:	8b 45 0c             	mov    0xc(%ebp),%eax
801080a0:	c1 e8 16             	shr    $0x16,%eax
801080a3:	c1 e0 02             	shl    $0x2,%eax
801080a6:	03 45 08             	add    0x8(%ebp),%eax
801080a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801080ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080af:	8b 00                	mov    (%eax),%eax
801080b1:	83 e0 01             	and    $0x1,%eax
801080b4:	84 c0                	test   %al,%al
801080b6:	74 17                	je     801080cf <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801080b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080bb:	8b 00                	mov    (%eax),%eax
801080bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080c2:	89 04 24             	mov    %eax,(%esp)
801080c5:	e8 4a fb ff ff       	call   80107c14 <p2v>
801080ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080cd:	eb 4b                	jmp    8010811a <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801080cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801080d3:	74 0e                	je     801080e3 <walkpgdir+0x4c>
801080d5:	e8 8d ad ff ff       	call   80102e67 <kalloc>
801080da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801080e1:	75 07                	jne    801080ea <walkpgdir+0x53>
      return 0;
801080e3:	b8 00 00 00 00       	mov    $0x0,%eax
801080e8:	eb 41                	jmp    8010812b <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801080ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080f1:	00 
801080f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801080f9:	00 
801080fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fd:	89 04 24             	mov    %eax,(%esp)
80108100:	e8 b5 d4 ff ff       	call   801055ba <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108108:	89 04 24             	mov    %eax,(%esp)
8010810b:	e8 f7 fa ff ff       	call   80107c07 <v2p>
80108110:	89 c2                	mov    %eax,%edx
80108112:	83 ca 07             	or     $0x7,%edx
80108115:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108118:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010811a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010811d:	c1 e8 0c             	shr    $0xc,%eax
80108120:	25 ff 03 00 00       	and    $0x3ff,%eax
80108125:	c1 e0 02             	shl    $0x2,%eax
80108128:	03 45 f4             	add    -0xc(%ebp),%eax
}
8010812b:	c9                   	leave  
8010812c:	c3                   	ret    

8010812d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010812d:	55                   	push   %ebp
8010812e:	89 e5                	mov    %esp,%ebp
80108130:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108133:	8b 45 0c             	mov    0xc(%ebp),%eax
80108136:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010813b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010813e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108141:	03 45 10             	add    0x10(%ebp),%eax
80108144:	83 e8 01             	sub    $0x1,%eax
80108147:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010814c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010814f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108156:	00 
80108157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010815e:	8b 45 08             	mov    0x8(%ebp),%eax
80108161:	89 04 24             	mov    %eax,(%esp)
80108164:	e8 2e ff ff ff       	call   80108097 <walkpgdir>
80108169:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010816c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108170:	75 07                	jne    80108179 <mappages+0x4c>
      return -1;
80108172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108177:	eb 46                	jmp    801081bf <mappages+0x92>
    if(*pte & PTE_P)
80108179:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010817c:	8b 00                	mov    (%eax),%eax
8010817e:	83 e0 01             	and    $0x1,%eax
80108181:	84 c0                	test   %al,%al
80108183:	74 0c                	je     80108191 <mappages+0x64>
      panic("remap");
80108185:	c7 04 24 a4 8f 10 80 	movl   $0x80108fa4,(%esp)
8010818c:	e8 ac 83 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108191:	8b 45 18             	mov    0x18(%ebp),%eax
80108194:	0b 45 14             	or     0x14(%ebp),%eax
80108197:	89 c2                	mov    %eax,%edx
80108199:	83 ca 01             	or     $0x1,%edx
8010819c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010819f:	89 10                	mov    %edx,(%eax)
    if(a == last)
801081a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801081a7:	74 10                	je     801081b9 <mappages+0x8c>
      break;
    a += PGSIZE;
801081a9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801081b0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801081b7:	eb 96                	jmp    8010814f <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801081b9:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801081ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081bf:	c9                   	leave  
801081c0:	c3                   	ret    

801081c1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
801081c1:	55                   	push   %ebp
801081c2:	89 e5                	mov    %esp,%ebp
801081c4:	53                   	push   %ebx
801081c5:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801081c8:	e8 9a ac ff ff       	call   80102e67 <kalloc>
801081cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081d4:	75 0a                	jne    801081e0 <setupkvm+0x1f>
    return 0;
801081d6:	b8 00 00 00 00       	mov    $0x0,%eax
801081db:	e9 98 00 00 00       	jmp    80108278 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801081e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081e7:	00 
801081e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081ef:	00 
801081f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f3:	89 04 24             	mov    %eax,(%esp)
801081f6:	e8 bf d3 ff ff       	call   801055ba <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801081fb:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108202:	e8 0d fa ff ff       	call   80107c14 <p2v>
80108207:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010820c:	76 0c                	jbe    8010821a <setupkvm+0x59>
    panic("PHYSTOP too high");
8010820e:	c7 04 24 aa 8f 10 80 	movl   $0x80108faa,(%esp)
80108215:	e8 23 83 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010821a:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108221:	eb 49                	jmp    8010826c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80108223:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108226:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108229:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010822c:	8b 50 04             	mov    0x4(%eax),%edx
8010822f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108232:	8b 58 08             	mov    0x8(%eax),%ebx
80108235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108238:	8b 40 04             	mov    0x4(%eax),%eax
8010823b:	29 c3                	sub    %eax,%ebx
8010823d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108240:	8b 00                	mov    (%eax),%eax
80108242:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108246:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010824a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010824e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108255:	89 04 24             	mov    %eax,(%esp)
80108258:	e8 d0 fe ff ff       	call   8010812d <mappages>
8010825d:	85 c0                	test   %eax,%eax
8010825f:	79 07                	jns    80108268 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108261:	b8 00 00 00 00       	mov    $0x0,%eax
80108266:	eb 10                	jmp    80108278 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108268:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010826c:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108273:	72 ae                	jb     80108223 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108275:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108278:	83 c4 34             	add    $0x34,%esp
8010827b:	5b                   	pop    %ebx
8010827c:	5d                   	pop    %ebp
8010827d:	c3                   	ret    

8010827e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010827e:	55                   	push   %ebp
8010827f:	89 e5                	mov    %esp,%ebp
80108281:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108284:	e8 38 ff ff ff       	call   801081c1 <setupkvm>
80108289:	a3 18 3d 11 80       	mov    %eax,0x80113d18
  switchkvm();
8010828e:	e8 02 00 00 00       	call   80108295 <switchkvm>
}
80108293:	c9                   	leave  
80108294:	c3                   	ret    

80108295 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108295:	55                   	push   %ebp
80108296:	89 e5                	mov    %esp,%ebp
80108298:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010829b:	a1 18 3d 11 80       	mov    0x80113d18,%eax
801082a0:	89 04 24             	mov    %eax,(%esp)
801082a3:	e8 5f f9 ff ff       	call   80107c07 <v2p>
801082a8:	89 04 24             	mov    %eax,(%esp)
801082ab:	e8 4c f9 ff ff       	call   80107bfc <lcr3>
}
801082b0:	c9                   	leave  
801082b1:	c3                   	ret    

801082b2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801082b2:	55                   	push   %ebp
801082b3:	89 e5                	mov    %esp,%ebp
801082b5:	53                   	push   %ebx
801082b6:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801082b9:	e8 f5 d1 ff ff       	call   801054b3 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801082be:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082c4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082cb:	83 c2 08             	add    $0x8,%edx
801082ce:	89 d3                	mov    %edx,%ebx
801082d0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082d7:	83 c2 08             	add    $0x8,%edx
801082da:	c1 ea 10             	shr    $0x10,%edx
801082dd:	89 d1                	mov    %edx,%ecx
801082df:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082e6:	83 c2 08             	add    $0x8,%edx
801082e9:	c1 ea 18             	shr    $0x18,%edx
801082ec:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801082f3:	67 00 
801082f5:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801082fc:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108302:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108309:	83 e1 f0             	and    $0xfffffff0,%ecx
8010830c:	83 c9 09             	or     $0x9,%ecx
8010830f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108315:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010831c:	83 c9 10             	or     $0x10,%ecx
8010831f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108325:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010832c:	83 e1 9f             	and    $0xffffff9f,%ecx
8010832f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108335:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010833c:	83 c9 80             	or     $0xffffff80,%ecx
8010833f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108345:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010834c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010834f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108355:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010835c:	83 e1 ef             	and    $0xffffffef,%ecx
8010835f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108365:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010836c:	83 e1 df             	and    $0xffffffdf,%ecx
8010836f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108375:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010837c:	83 c9 40             	or     $0x40,%ecx
8010837f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108385:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010838c:	83 e1 7f             	and    $0x7f,%ecx
8010838f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108395:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010839b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083a1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801083a8:	83 e2 ef             	and    $0xffffffef,%edx
801083ab:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801083b1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083b7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801083bd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083c3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801083ca:	8b 52 08             	mov    0x8(%edx),%edx
801083cd:	81 c2 00 10 00 00    	add    $0x1000,%edx
801083d3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801083d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801083dd:	e8 ef f7 ff ff       	call   80107bd1 <ltr>
  if(p->pgdir == 0)
801083e2:	8b 45 08             	mov    0x8(%ebp),%eax
801083e5:	8b 40 04             	mov    0x4(%eax),%eax
801083e8:	85 c0                	test   %eax,%eax
801083ea:	75 0c                	jne    801083f8 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801083ec:	c7 04 24 bb 8f 10 80 	movl   $0x80108fbb,(%esp)
801083f3:	e8 45 81 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801083f8:	8b 45 08             	mov    0x8(%ebp),%eax
801083fb:	8b 40 04             	mov    0x4(%eax),%eax
801083fe:	89 04 24             	mov    %eax,(%esp)
80108401:	e8 01 f8 ff ff       	call   80107c07 <v2p>
80108406:	89 04 24             	mov    %eax,(%esp)
80108409:	e8 ee f7 ff ff       	call   80107bfc <lcr3>
  popcli();
8010840e:	e8 e8 d0 ff ff       	call   801054fb <popcli>
}
80108413:	83 c4 14             	add    $0x14,%esp
80108416:	5b                   	pop    %ebx
80108417:	5d                   	pop    %ebp
80108418:	c3                   	ret    

80108419 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108419:	55                   	push   %ebp
8010841a:	89 e5                	mov    %esp,%ebp
8010841c:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010841f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108426:	76 0c                	jbe    80108434 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108428:	c7 04 24 cf 8f 10 80 	movl   $0x80108fcf,(%esp)
8010842f:	e8 09 81 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108434:	e8 2e aa ff ff       	call   80102e67 <kalloc>
80108439:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010843c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108443:	00 
80108444:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010844b:	00 
8010844c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844f:	89 04 24             	mov    %eax,(%esp)
80108452:	e8 63 d1 ff ff       	call   801055ba <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845a:	89 04 24             	mov    %eax,(%esp)
8010845d:	e8 a5 f7 ff ff       	call   80107c07 <v2p>
80108462:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108469:	00 
8010846a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010846e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108475:	00 
80108476:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010847d:	00 
8010847e:	8b 45 08             	mov    0x8(%ebp),%eax
80108481:	89 04 24             	mov    %eax,(%esp)
80108484:	e8 a4 fc ff ff       	call   8010812d <mappages>
  memmove(mem, init, sz);
80108489:	8b 45 10             	mov    0x10(%ebp),%eax
8010848c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108490:	8b 45 0c             	mov    0xc(%ebp),%eax
80108493:	89 44 24 04          	mov    %eax,0x4(%esp)
80108497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849a:	89 04 24             	mov    %eax,(%esp)
8010849d:	e8 eb d1 ff ff       	call   8010568d <memmove>
}
801084a2:	c9                   	leave  
801084a3:	c3                   	ret    

801084a4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801084a4:	55                   	push   %ebp
801084a5:	89 e5                	mov    %esp,%ebp
801084a7:	53                   	push   %ebx
801084a8:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801084ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ae:	25 ff 0f 00 00       	and    $0xfff,%eax
801084b3:	85 c0                	test   %eax,%eax
801084b5:	74 0c                	je     801084c3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801084b7:	c7 04 24 ec 8f 10 80 	movl   $0x80108fec,(%esp)
801084be:	e8 7a 80 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
801084c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084ca:	e9 ad 00 00 00       	jmp    8010857c <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d2:	8b 55 0c             	mov    0xc(%ebp),%edx
801084d5:	01 d0                	add    %edx,%eax
801084d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084de:	00 
801084df:	89 44 24 04          	mov    %eax,0x4(%esp)
801084e3:	8b 45 08             	mov    0x8(%ebp),%eax
801084e6:	89 04 24             	mov    %eax,(%esp)
801084e9:	e8 a9 fb ff ff       	call   80108097 <walkpgdir>
801084ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084f5:	75 0c                	jne    80108503 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801084f7:	c7 04 24 0f 90 10 80 	movl   $0x8010900f,(%esp)
801084fe:	e8 3a 80 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108503:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108506:	8b 00                	mov    (%eax),%eax
80108508:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010850d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108513:	8b 55 18             	mov    0x18(%ebp),%edx
80108516:	89 d1                	mov    %edx,%ecx
80108518:	29 c1                	sub    %eax,%ecx
8010851a:	89 c8                	mov    %ecx,%eax
8010851c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108521:	77 11                	ja     80108534 <loaduvm+0x90>
      n = sz - i;
80108523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108526:	8b 55 18             	mov    0x18(%ebp),%edx
80108529:	89 d1                	mov    %edx,%ecx
8010852b:	29 c1                	sub    %eax,%ecx
8010852d:	89 c8                	mov    %ecx,%eax
8010852f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108532:	eb 07                	jmp    8010853b <loaduvm+0x97>
    else
      n = PGSIZE;
80108534:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010853b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853e:	8b 55 14             	mov    0x14(%ebp),%edx
80108541:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108544:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108547:	89 04 24             	mov    %eax,(%esp)
8010854a:	e8 c5 f6 ff ff       	call   80107c14 <p2v>
8010854f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108552:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108556:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010855a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010855e:	8b 45 10             	mov    0x10(%ebp),%eax
80108561:	89 04 24             	mov    %eax,(%esp)
80108564:	e8 5d 9b ff ff       	call   801020c6 <readi>
80108569:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010856c:	74 07                	je     80108575 <loaduvm+0xd1>
      return -1;
8010856e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108573:	eb 18                	jmp    8010858d <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108575:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010857c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857f:	3b 45 18             	cmp    0x18(%ebp),%eax
80108582:	0f 82 47 ff ff ff    	jb     801084cf <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108588:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010858d:	83 c4 24             	add    $0x24,%esp
80108590:	5b                   	pop    %ebx
80108591:	5d                   	pop    %ebp
80108592:	c3                   	ret    

80108593 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108593:	55                   	push   %ebp
80108594:	89 e5                	mov    %esp,%ebp
80108596:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108599:	8b 45 10             	mov    0x10(%ebp),%eax
8010859c:	85 c0                	test   %eax,%eax
8010859e:	79 0a                	jns    801085aa <allocuvm+0x17>
    return 0;
801085a0:	b8 00 00 00 00       	mov    $0x0,%eax
801085a5:	e9 c1 00 00 00       	jmp    8010866b <allocuvm+0xd8>
  if(newsz < oldsz)
801085aa:	8b 45 10             	mov    0x10(%ebp),%eax
801085ad:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085b0:	73 08                	jae    801085ba <allocuvm+0x27>
    return oldsz;
801085b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801085b5:	e9 b1 00 00 00       	jmp    8010866b <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801085ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801085bd:	05 ff 0f 00 00       	add    $0xfff,%eax
801085c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801085ca:	e9 8d 00 00 00       	jmp    8010865c <allocuvm+0xc9>
    mem = kalloc();
801085cf:	e8 93 a8 ff ff       	call   80102e67 <kalloc>
801085d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801085d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085db:	75 2c                	jne    80108609 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801085dd:	c7 04 24 2d 90 10 80 	movl   $0x8010902d,(%esp)
801085e4:	e8 b8 7d ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801085e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801085ec:	89 44 24 08          	mov    %eax,0x8(%esp)
801085f0:	8b 45 10             	mov    0x10(%ebp),%eax
801085f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801085f7:	8b 45 08             	mov    0x8(%ebp),%eax
801085fa:	89 04 24             	mov    %eax,(%esp)
801085fd:	e8 6b 00 00 00       	call   8010866d <deallocuvm>
      return 0;
80108602:	b8 00 00 00 00       	mov    $0x0,%eax
80108607:	eb 62                	jmp    8010866b <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108609:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108610:	00 
80108611:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108618:	00 
80108619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010861c:	89 04 24             	mov    %eax,(%esp)
8010861f:	e8 96 cf ff ff       	call   801055ba <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108627:	89 04 24             	mov    %eax,(%esp)
8010862a:	e8 d8 f5 ff ff       	call   80107c07 <v2p>
8010862f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108632:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108639:	00 
8010863a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010863e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108645:	00 
80108646:	89 54 24 04          	mov    %edx,0x4(%esp)
8010864a:	8b 45 08             	mov    0x8(%ebp),%eax
8010864d:	89 04 24             	mov    %eax,(%esp)
80108650:	e8 d8 fa ff ff       	call   8010812d <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108655:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010865c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865f:	3b 45 10             	cmp    0x10(%ebp),%eax
80108662:	0f 82 67 ff ff ff    	jb     801085cf <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108668:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010866b:	c9                   	leave  
8010866c:	c3                   	ret    

8010866d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010866d:	55                   	push   %ebp
8010866e:	89 e5                	mov    %esp,%ebp
80108670:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108673:	8b 45 10             	mov    0x10(%ebp),%eax
80108676:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108679:	72 08                	jb     80108683 <deallocuvm+0x16>
    return oldsz;
8010867b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010867e:	e9 a4 00 00 00       	jmp    80108727 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108683:	8b 45 10             	mov    0x10(%ebp),%eax
80108686:	05 ff 0f 00 00       	add    $0xfff,%eax
8010868b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108690:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108693:	e9 80 00 00 00       	jmp    80108718 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086a2:	00 
801086a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801086a7:	8b 45 08             	mov    0x8(%ebp),%eax
801086aa:	89 04 24             	mov    %eax,(%esp)
801086ad:	e8 e5 f9 ff ff       	call   80108097 <walkpgdir>
801086b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801086b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086b9:	75 09                	jne    801086c4 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801086bb:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801086c2:	eb 4d                	jmp    80108711 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801086c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086c7:	8b 00                	mov    (%eax),%eax
801086c9:	83 e0 01             	and    $0x1,%eax
801086cc:	84 c0                	test   %al,%al
801086ce:	74 41                	je     80108711 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801086d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d3:	8b 00                	mov    (%eax),%eax
801086d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086da:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801086dd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086e1:	75 0c                	jne    801086ef <deallocuvm+0x82>
        panic("kfree");
801086e3:	c7 04 24 45 90 10 80 	movl   $0x80109045,(%esp)
801086ea:	e8 4e 7e ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801086ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f2:	89 04 24             	mov    %eax,(%esp)
801086f5:	e8 1a f5 ff ff       	call   80107c14 <p2v>
801086fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801086fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108700:	89 04 24             	mov    %eax,(%esp)
80108703:	e8 c6 a6 ff ff       	call   80102dce <kfree>
      *pte = 0;
80108708:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010870b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108711:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010871e:	0f 82 74 ff ff ff    	jb     80108698 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108724:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108727:	c9                   	leave  
80108728:	c3                   	ret    

80108729 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108729:	55                   	push   %ebp
8010872a:	89 e5                	mov    %esp,%ebp
8010872c:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010872f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108733:	75 0c                	jne    80108741 <freevm+0x18>
    panic("freevm: no pgdir");
80108735:	c7 04 24 4b 90 10 80 	movl   $0x8010904b,(%esp)
8010873c:	e8 fc 7d ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108741:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108748:	00 
80108749:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108750:	80 
80108751:	8b 45 08             	mov    0x8(%ebp),%eax
80108754:	89 04 24             	mov    %eax,(%esp)
80108757:	e8 11 ff ff ff       	call   8010866d <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010875c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108763:	eb 3c                	jmp    801087a1 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108768:	c1 e0 02             	shl    $0x2,%eax
8010876b:	03 45 08             	add    0x8(%ebp),%eax
8010876e:	8b 00                	mov    (%eax),%eax
80108770:	83 e0 01             	and    $0x1,%eax
80108773:	84 c0                	test   %al,%al
80108775:	74 26                	je     8010879d <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877a:	c1 e0 02             	shl    $0x2,%eax
8010877d:	03 45 08             	add    0x8(%ebp),%eax
80108780:	8b 00                	mov    (%eax),%eax
80108782:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108787:	89 04 24             	mov    %eax,(%esp)
8010878a:	e8 85 f4 ff ff       	call   80107c14 <p2v>
8010878f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108792:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108795:	89 04 24             	mov    %eax,(%esp)
80108798:	e8 31 a6 ff ff       	call   80102dce <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010879d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087a1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801087a8:	76 bb                	jbe    80108765 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801087aa:	8b 45 08             	mov    0x8(%ebp),%eax
801087ad:	89 04 24             	mov    %eax,(%esp)
801087b0:	e8 19 a6 ff ff       	call   80102dce <kfree>
}
801087b5:	c9                   	leave  
801087b6:	c3                   	ret    

801087b7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801087b7:	55                   	push   %ebp
801087b8:	89 e5                	mov    %esp,%ebp
801087ba:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087c4:	00 
801087c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801087c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801087cc:	8b 45 08             	mov    0x8(%ebp),%eax
801087cf:	89 04 24             	mov    %eax,(%esp)
801087d2:	e8 c0 f8 ff ff       	call   80108097 <walkpgdir>
801087d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801087da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087de:	75 0c                	jne    801087ec <clearpteu+0x35>
    panic("clearpteu");
801087e0:	c7 04 24 5c 90 10 80 	movl   $0x8010905c,(%esp)
801087e7:	e8 51 7d ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801087ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ef:	8b 00                	mov    (%eax),%eax
801087f1:	89 c2                	mov    %eax,%edx
801087f3:	83 e2 fb             	and    $0xfffffffb,%edx
801087f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f9:	89 10                	mov    %edx,(%eax)
}
801087fb:	c9                   	leave  
801087fc:	c3                   	ret    

801087fd <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801087fd:	55                   	push   %ebp
801087fe:	89 e5                	mov    %esp,%ebp
80108800:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108803:	e8 b9 f9 ff ff       	call   801081c1 <setupkvm>
80108808:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010880b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010880f:	75 0a                	jne    8010881b <copyuvm+0x1e>
    return 0;
80108811:	b8 00 00 00 00       	mov    $0x0,%eax
80108816:	e9 f1 00 00 00       	jmp    8010890c <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
8010881b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108822:	e9 c0 00 00 00       	jmp    801088e7 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108831:	00 
80108832:	89 44 24 04          	mov    %eax,0x4(%esp)
80108836:	8b 45 08             	mov    0x8(%ebp),%eax
80108839:	89 04 24             	mov    %eax,(%esp)
8010883c:	e8 56 f8 ff ff       	call   80108097 <walkpgdir>
80108841:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108844:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108848:	75 0c                	jne    80108856 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010884a:	c7 04 24 66 90 10 80 	movl   $0x80109066,(%esp)
80108851:	e8 e7 7c ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108856:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108859:	8b 00                	mov    (%eax),%eax
8010885b:	83 e0 01             	and    $0x1,%eax
8010885e:	85 c0                	test   %eax,%eax
80108860:	75 0c                	jne    8010886e <copyuvm+0x71>
      panic("copyuvm: page not present");
80108862:	c7 04 24 80 90 10 80 	movl   $0x80109080,(%esp)
80108869:	e8 cf 7c ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010886e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108871:	8b 00                	mov    (%eax),%eax
80108873:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108878:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
8010887b:	e8 e7 a5 ff ff       	call   80102e67 <kalloc>
80108880:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108883:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108887:	74 6f                	je     801088f8 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108889:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010888c:	89 04 24             	mov    %eax,(%esp)
8010888f:	e8 80 f3 ff ff       	call   80107c14 <p2v>
80108894:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010889b:	00 
8010889c:	89 44 24 04          	mov    %eax,0x4(%esp)
801088a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088a3:	89 04 24             	mov    %eax,(%esp)
801088a6:	e8 e2 cd ff ff       	call   8010568d <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801088ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088ae:	89 04 24             	mov    %eax,(%esp)
801088b1:	e8 51 f3 ff ff       	call   80107c07 <v2p>
801088b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088b9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801088c0:	00 
801088c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801088c5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088cc:	00 
801088cd:	89 54 24 04          	mov    %edx,0x4(%esp)
801088d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d4:	89 04 24             	mov    %eax,(%esp)
801088d7:	e8 51 f8 ff ff       	call   8010812d <mappages>
801088dc:	85 c0                	test   %eax,%eax
801088de:	78 1b                	js     801088fb <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801088e0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ea:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088ed:	0f 82 34 ff ff ff    	jb     80108827 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
801088f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088f6:	eb 14                	jmp    8010890c <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801088f8:	90                   	nop
801088f9:	eb 01                	jmp    801088fc <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
801088fb:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801088fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ff:	89 04 24             	mov    %eax,(%esp)
80108902:	e8 22 fe ff ff       	call   80108729 <freevm>
  return 0;
80108907:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010890c:	c9                   	leave  
8010890d:	c3                   	ret    

8010890e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010890e:	55                   	push   %ebp
8010890f:	89 e5                	mov    %esp,%ebp
80108911:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108914:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010891b:	00 
8010891c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010891f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108923:	8b 45 08             	mov    0x8(%ebp),%eax
80108926:	89 04 24             	mov    %eax,(%esp)
80108929:	e8 69 f7 ff ff       	call   80108097 <walkpgdir>
8010892e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108934:	8b 00                	mov    (%eax),%eax
80108936:	83 e0 01             	and    $0x1,%eax
80108939:	85 c0                	test   %eax,%eax
8010893b:	75 07                	jne    80108944 <uva2ka+0x36>
    return 0;
8010893d:	b8 00 00 00 00       	mov    $0x0,%eax
80108942:	eb 25                	jmp    80108969 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108947:	8b 00                	mov    (%eax),%eax
80108949:	83 e0 04             	and    $0x4,%eax
8010894c:	85 c0                	test   %eax,%eax
8010894e:	75 07                	jne    80108957 <uva2ka+0x49>
    return 0;
80108950:	b8 00 00 00 00       	mov    $0x0,%eax
80108955:	eb 12                	jmp    80108969 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895a:	8b 00                	mov    (%eax),%eax
8010895c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108961:	89 04 24             	mov    %eax,(%esp)
80108964:	e8 ab f2 ff ff       	call   80107c14 <p2v>
}
80108969:	c9                   	leave  
8010896a:	c3                   	ret    

8010896b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010896b:	55                   	push   %ebp
8010896c:	89 e5                	mov    %esp,%ebp
8010896e:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108971:	8b 45 10             	mov    0x10(%ebp),%eax
80108974:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108977:	e9 8b 00 00 00       	jmp    80108a07 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
8010897c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010897f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108984:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108987:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010898e:	8b 45 08             	mov    0x8(%ebp),%eax
80108991:	89 04 24             	mov    %eax,(%esp)
80108994:	e8 75 ff ff ff       	call   8010890e <uva2ka>
80108999:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010899c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801089a0:	75 07                	jne    801089a9 <copyout+0x3e>
      return -1;
801089a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089a7:	eb 6d                	jmp    80108a16 <copyout+0xab>
    n = PGSIZE - (va - va0);
801089a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801089ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
801089af:	89 d1                	mov    %edx,%ecx
801089b1:	29 c1                	sub    %eax,%ecx
801089b3:	89 c8                	mov    %ecx,%eax
801089b5:	05 00 10 00 00       	add    $0x1000,%eax
801089ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801089bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089c0:	3b 45 14             	cmp    0x14(%ebp),%eax
801089c3:	76 06                	jbe    801089cb <copyout+0x60>
      n = len;
801089c5:	8b 45 14             	mov    0x14(%ebp),%eax
801089c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801089cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801089d1:	89 d1                	mov    %edx,%ecx
801089d3:	29 c1                	sub    %eax,%ecx
801089d5:	89 c8                	mov    %ecx,%eax
801089d7:	03 45 e8             	add    -0x18(%ebp),%eax
801089da:	8b 55 f0             	mov    -0x10(%ebp),%edx
801089dd:	89 54 24 08          	mov    %edx,0x8(%esp)
801089e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089e4:	89 54 24 04          	mov    %edx,0x4(%esp)
801089e8:	89 04 24             	mov    %eax,(%esp)
801089eb:	e8 9d cc ff ff       	call   8010568d <memmove>
    len -= n;
801089f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089f3:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801089f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089f9:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801089fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ff:	05 00 10 00 00       	add    $0x1000,%eax
80108a04:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108a07:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a0b:	0f 85 6b ff ff ff    	jne    8010897c <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108a11:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a16:	c9                   	leave  
80108a17:	c3                   	ret    
