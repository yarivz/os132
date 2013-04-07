
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
8010002d:	b8 77 37 10 80       	mov    $0x80103777,%eax
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
8010003a:	c7 44 24 04 a0 8a 10 	movl   $0x80108aa0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 84 53 00 00       	call   801053d2 <initlock>

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
801000bd:	e8 31 53 00 00       	call   801053f3 <acquire>

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
80100104:	e8 4c 53 00 00       	call   80105455 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 63 4f 00 00       	call   80105087 <sleep>
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
8010017c:	e8 d4 52 00 00       	call   80105455 <release>
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
80100198:	c7 04 24 a7 8a 10 80 	movl   $0x80108aa7,(%esp)
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
801001d3:	e8 4c 29 00 00       	call   80102b24 <iderw>
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
801001ef:	c7 04 24 b8 8a 10 80 	movl   $0x80108ab8,(%esp)
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
80100210:	e8 0f 29 00 00       	call   80102b24 <iderw>
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
80100229:	c7 04 24 bf 8a 10 80 	movl   $0x80108abf,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 b2 51 00 00       	call   801053f3 <acquire>

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
8010029d:	e8 c1 4e 00 00       	call   80105163 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 a7 51 00 00       	call   80105455 <release>
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
801003bc:	e8 32 50 00 00       	call   801053f3 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 c6 8a 10 80 	movl   $0x80108ac6,(%esp)
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
801004af:	c7 45 ec cf 8a 10 80 	movl   $0x80108acf,-0x14(%ebp)
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
80100536:	e8 1a 4f 00 00       	call   80105455 <release>
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
80100562:	c7 04 24 d6 8a 10 80 	movl   $0x80108ad6,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 e5 8a 10 80 	movl   $0x80108ae5,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 0d 4f 00 00       	call   801054a4 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 e7 8a 10 80 	movl   $0x80108ae7,(%esp)
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
8010072b:	e8 e5 4f 00 00       	call   80105715 <memmove>
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
8010075a:	e8 e3 4e 00 00       	call   80105642 <memset>
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
80100801:	e8 ff 68 00 00       	call   80107105 <uartputc>
80100806:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010080d:	e8 f3 68 00 00       	call   80107105 <uartputc>
80100812:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100819:	e8 e7 68 00 00       	call   80107105 <uartputc>
8010081e:	eb 0b                	jmp    8010082b <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
80100820:	8b 45 08             	mov    0x8(%ebp),%eax
80100823:	89 04 24             	mov    %eax,(%esp)
80100826:	e8 da 68 00 00       	call   80107105 <uartputc>
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
  for(;j < k && e+j < INPUT_BUF;i--,j++){
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
  for(;j < k && e+j < INPUT_BUF;i--,j++){
80100869:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010086d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80100871:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100874:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100877:	7d 0d                	jge    80100886 <shiftRightBuf+0x4e>
80100879:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010087c:	8b 55 08             	mov    0x8(%ebp),%edx
8010087f:	01 d0                	add    %edx,%eax
80100881:	83 f8 7f             	cmp    $0x7f,%eax
80100884:	7e ca                	jle    80100850 <shiftRightBuf+0x18>
    input.buf[i] = input.buf[i-1];
  }
}
80100886:	c9                   	leave  
80100887:	c3                   	ret    

80100888 <shiftLeftBuf>:

void
shiftLeftBuf(int e, int k)
{
80100888:	55                   	push   %ebp
80100889:	89 e5                	mov    %esp,%ebp
8010088b:	83 ec 10             	sub    $0x10,%esp
  int i = e+k;
8010088e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100891:	8b 55 08             	mov    0x8(%ebp),%edx
80100894:	01 d0                	add    %edx,%eax
80100896:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
80100899:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < (-1)*k ;i++,j++){
801008a0:	eb 21                	jmp    801008c3 <shiftLeftBuf+0x3b>
    input.buf[i] = input.buf[i+1];
801008a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801008a5:	83 c0 01             	add    $0x1,%eax
801008a8:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
801008af:	8b 55 fc             	mov    -0x4(%ebp),%edx
801008b2:	81 c2 d0 ed 10 80    	add    $0x8010edd0,%edx
801008b8:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(int e, int k)
{
  int i = e+k;
  int j=0;
  for(;j < (-1)*k ;i++,j++){
801008bb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801008bf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801008c6:	f7 d8                	neg    %eax
801008c8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801008cb:	7f d5                	jg     801008a2 <shiftLeftBuf+0x1a>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
801008cd:	8b 45 08             	mov    0x8(%ebp),%eax
801008d0:	05 d0 ed 10 80       	add    $0x8010edd0,%eax
801008d5:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
801008d9:	c9                   	leave  
801008da:	c3                   	ret    

801008db <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801008db:	55                   	push   %ebp
801008dc:	89 e5                	mov    %esp,%ebp
801008de:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801008e1:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
801008e8:	e8 06 4b 00 00       	call   801053f3 <acquire>
  while((c = getc()) >= 0){
801008ed:	e9 82 03 00 00       	jmp    80100c74 <consoleintr+0x399>
    switch(c){
801008f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801008f5:	83 f8 15             	cmp    $0x15,%eax
801008f8:	74 59                	je     80100953 <consoleintr+0x78>
801008fa:	83 f8 15             	cmp    $0x15,%eax
801008fd:	7f 0f                	jg     8010090e <consoleintr+0x33>
801008ff:	83 f8 08             	cmp    $0x8,%eax
80100902:	74 7e                	je     80100982 <consoleintr+0xa7>
80100904:	83 f8 10             	cmp    $0x10,%eax
80100907:	74 25                	je     8010092e <consoleintr+0x53>
80100909:	e9 d7 01 00 00       	jmp    80100ae5 <consoleintr+0x20a>
8010090e:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100913:	0f 84 4d 01 00 00    	je     80100a66 <consoleintr+0x18b>
80100919:	3d e5 00 00 00       	cmp    $0xe5,%eax
8010091e:	0f 84 85 01 00 00    	je     80100aa9 <consoleintr+0x1ce>
80100924:	83 f8 7f             	cmp    $0x7f,%eax
80100927:	74 59                	je     80100982 <consoleintr+0xa7>
80100929:	e9 b7 01 00 00       	jmp    80100ae5 <consoleintr+0x20a>
    case C('P'):  // Process listing.
      procdump();
8010092e:	e8 d6 48 00 00       	call   80105209 <procdump>
      break;
80100933:	e9 3c 03 00 00       	jmp    80100c74 <consoleintr+0x399>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100938:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
8010093d:	83 e8 01             	sub    $0x1,%eax
80100940:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
        consputc(BACKSPACE);
80100945:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010094c:	e8 8a fe ff ff       	call   801007db <consputc>
80100951:	eb 01                	jmp    80100954 <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100953:	90                   	nop
80100954:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
8010095a:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
8010095f:	39 c2                	cmp    %eax,%edx
80100961:	0f 84 00 03 00 00    	je     80100c67 <consoleintr+0x38c>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100967:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
8010096c:	83 e8 01             	sub    $0x1,%eax
8010096f:	83 e0 7f             	and    $0x7f,%eax
80100972:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100979:	3c 0a                	cmp    $0xa,%al
8010097b:	75 bb                	jne    80100938 <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010097d:	e9 e5 02 00 00       	jmp    80100c67 <consoleintr+0x38c>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100982:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100988:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
8010098d:	39 c2                	cmp    %eax,%edx
8010098f:	0f 84 d5 02 00 00    	je     80100c6a <consoleintr+0x38f>
	if(input.a<0)
80100995:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
8010099a:	85 c0                	test   %eax,%eax
8010099c:	0f 89 a6 00 00 00    	jns    80100a48 <consoleintr+0x16d>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
801009a2:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
801009a7:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
801009ad:	83 ea 01             	sub    $0x1,%edx
801009b0:	83 e2 7f             	and    $0x7f,%edx
801009b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801009b7:	89 14 24             	mov    %edx,(%esp)
801009ba:	e8 c9 fe ff ff       	call   80100888 <shiftLeftBuf>
	    int i = input.e+input.a-1;
801009bf:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
801009c5:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
801009ca:	01 d0                	add    %edx,%eax
801009cc:	83 e8 01             	sub    $0x1,%eax
801009cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);
801009d2:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009d9:	e8 fd fd ff ff       	call   801007db <consputc>
	    for(;i<input.e;i++){
801009de:	eb 28                	jmp    80100a08 <consoleintr+0x12d>
	      consputc(input.buf[i%INPUT_BUF]);
801009e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801009e3:	89 c2                	mov    %eax,%edx
801009e5:	c1 fa 1f             	sar    $0x1f,%edx
801009e8:	c1 ea 19             	shr    $0x19,%edx
801009eb:	01 d0                	add    %edx,%eax
801009ed:	83 e0 7f             	and    $0x7f,%eax
801009f0:	29 d0                	sub    %edx,%eax
801009f2:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
801009f9:	0f be c0             	movsbl %al,%eax
801009fc:	89 04 24             	mov    %eax,(%esp)
801009ff:	e8 d7 fd ff ff       	call   801007db <consputc>
	if(input.a<0)
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
	    int i = input.e+input.a-1;
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
80100a04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a0b:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100a10:	39 c2                	cmp    %eax,%edx
80100a12:	72 cc                	jb     801009e0 <consoleintr+0x105>
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e+input.a;
80100a14:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100a1a:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100a1f:	01 d0                	add    %edx,%eax
80100a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){
80100a24:	eb 10                	jmp    80100a36 <consoleintr+0x15b>
	      consputc(KEY_LF);
80100a26:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a2d:	e8 a9 fd ff ff       	call   801007db <consputc>
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e+input.a;
	    for(;i<input.e+1;i++){
80100a32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a39:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100a3f:	83 c2 01             	add    $0x1,%edx
80100a42:	39 d0                	cmp    %edx,%eax
80100a44:	72 e0                	jb     80100a26 <consoleintr+0x14b>
80100a46:	eb 0c                	jmp    80100a54 <consoleintr+0x179>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);
80100a48:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a4f:	e8 87 fd ff ff       	call   801007db <consputc>
	}
	input.e--;
80100a54:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100a59:	83 e8 01             	sub    $0x1,%eax
80100a5c:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
      }
      break;
80100a61:	e9 04 02 00 00       	jmp    80100c6a <consoleintr+0x38f>
    case KEY_LF: //LEFT KEY
     if(input.e % INPUT_BUF > 0 && input.e+input.a>0)
80100a66:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100a6b:	83 e0 7f             	and    $0x7f,%eax
80100a6e:	85 c0                	test   %eax,%eax
80100a70:	0f 84 f7 01 00 00    	je     80100c6d <consoleintr+0x392>
80100a76:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100a7c:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100a81:	01 d0                	add    %edx,%eax
80100a83:	85 c0                	test   %eax,%eax
80100a85:	0f 84 e2 01 00 00    	je     80100c6d <consoleintr+0x392>
      {
        input.a--;
80100a8b:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100a90:	83 e8 01             	sub    $0x1,%eax
80100a93:	a3 60 ee 10 80       	mov    %eax,0x8010ee60
        consputc(KEY_LF);
80100a98:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a9f:	e8 37 fd ff ff       	call   801007db <consputc>
      }
      break;
80100aa4:	e9 c4 01 00 00       	jmp    80100c6d <consoleintr+0x392>
    case KEY_RT: //RIGHT KEY
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
80100aa9:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100aae:	85 c0                	test   %eax,%eax
80100ab0:	0f 89 ba 01 00 00    	jns    80100c70 <consoleintr+0x395>
80100ab6:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100abb:	83 e0 7f             	and    $0x7f,%eax
80100abe:	83 f8 7e             	cmp    $0x7e,%eax
80100ac1:	0f 87 a9 01 00 00    	ja     80100c70 <consoleintr+0x395>
      {
        input.a++;
80100ac7:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100acc:	83 c0 01             	add    $0x1,%eax
80100acf:	a3 60 ee 10 80       	mov    %eax,0x8010ee60
        consputc(KEY_RT);
80100ad4:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100adb:	e8 fb fc ff ff       	call   801007db <consputc>
      }
      break;
80100ae0:	e9 8b 01 00 00       	jmp    80100c70 <consoleintr+0x395>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100ae5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100ae9:	0f 84 84 01 00 00    	je     80100c73 <consoleintr+0x398>
80100aef:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100af5:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
80100afa:	89 d1                	mov    %edx,%ecx
80100afc:	29 c1                	sub    %eax,%ecx
80100afe:	89 c8                	mov    %ecx,%eax
80100b00:	83 f8 7f             	cmp    $0x7f,%eax
80100b03:	0f 87 6a 01 00 00    	ja     80100c73 <consoleintr+0x398>
      {
	c = (c == '\r') ? '\n' : c;
80100b09:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100b0d:	74 05                	je     80100b14 <consoleintr+0x239>
80100b0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b12:	eb 05                	jmp    80100b19 <consoleintr+0x23e>
80100b14:	b8 0a 00 00 00       	mov    $0xa,%eax
80100b19:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a < 0)
80100b1c:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100b20:	0f 84 db 00 00 00    	je     80100c01 <consoleintr+0x326>
80100b26:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100b2b:	85 c0                	test   %eax,%eax
80100b2d:	0f 89 ce 00 00 00    	jns    80100c01 <consoleintr+0x326>
	{
	    int k = (-1)*input.a;
80100b33:	a1 60 ee 10 80       	mov    0x8010ee60,%eax
80100b38:	f7 d8                	neg    %eax
80100b3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
80100b3d:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100b42:	83 e8 01             	sub    $0x1,%eax
80100b45:	89 c2                	mov    %eax,%edx
80100b47:	83 e2 7f             	and    $0x7f,%edx
80100b4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b51:	89 14 24             	mov    %edx,(%esp)
80100b54:	e8 df fc ff ff       	call   80100838 <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;
80100b59:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100b5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b62:	89 d1                	mov    %edx,%ecx
80100b64:	29 c1                	sub    %eax,%ecx
80100b66:	89 c8                	mov    %ecx,%eax
80100b68:	89 c2                	mov    %eax,%edx
80100b6a:	83 e2 7f             	and    $0x7f,%edx
80100b6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b70:	88 82 d4 ed 10 80    	mov    %al,-0x7fef122c(%edx)
	    int i = input.e-k;
80100b76:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100b7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b7f:	89 d1                	mov    %edx,%ecx
80100b81:	29 c1                	sub    %eax,%ecx
80100b83:	89 c8                	mov    %ecx,%eax
80100b85:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    
	    for(;i<input.e+1;i++){
80100b88:	eb 28                	jmp    80100bb2 <consoleintr+0x2d7>
	      consputc(input.buf[i%INPUT_BUF]);
80100b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b8d:	89 c2                	mov    %eax,%edx
80100b8f:	c1 fa 1f             	sar    $0x1f,%edx
80100b92:	c1 ea 19             	shr    $0x19,%edx
80100b95:	01 d0                	add    %edx,%eax
80100b97:	83 e0 7f             	and    $0x7f,%eax
80100b9a:	29 d0                	sub    %edx,%eax
80100b9c:	0f b6 80 d4 ed 10 80 	movzbl -0x7fef122c(%eax),%eax
80100ba3:	0f be c0             	movsbl %al,%eax
80100ba6:	89 04 24             	mov    %eax,(%esp)
80100ba9:	e8 2d fc ff ff       	call   801007db <consputc>
	    int k = (-1)*input.a;
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
	    input.buf[(input.e-k) % INPUT_BUF] = c;
	    int i = input.e-k;
	    
	    for(;i<input.e+1;i++){
80100bae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100bb5:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100bbb:	83 c2 01             	add    $0x1,%edx
80100bbe:	39 d0                	cmp    %edx,%eax
80100bc0:	72 c8                	jb     80100b8a <consoleintr+0x2af>
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e-k;
80100bc2:	8b 15 5c ee 10 80    	mov    0x8010ee5c,%edx
80100bc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bcb:	89 d1                	mov    %edx,%ecx
80100bcd:	29 c1                	sub    %eax,%ecx
80100bcf:	89 c8                	mov    %ecx,%eax
80100bd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++){
80100bd4:	eb 10                	jmp    80100be6 <consoleintr+0x30b>
	      consputc(KEY_LF);
80100bd6:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100bdd:	e8 f9 fb ff ff       	call   801007db <consputc>
	    
	    for(;i<input.e+1;i++){
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e-k;
	    for(;i<input.e;i++){
80100be2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100be6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100be9:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100bee:	39 c2                	cmp    %eax,%edx
80100bf0:	72 e4                	jb     80100bd6 <consoleintr+0x2fb>
	      consputc(KEY_LF);
	    }
	    input.e++;
80100bf2:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100bf7:	83 c0 01             	add    $0x1,%eax
80100bfa:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a < 0)
	{
80100bff:	eb 26                	jmp    80100c27 <consoleintr+0x34c>
	      consputc(KEY_LF);
	    }
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100c01:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100c06:	89 c1                	mov    %eax,%ecx
80100c08:	83 e1 7f             	and    $0x7f,%ecx
80100c0b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c0e:	88 91 d4 ed 10 80    	mov    %dl,-0x7fef122c(%ecx)
80100c14:	83 c0 01             	add    $0x1,%eax
80100c17:	a3 5c ee 10 80       	mov    %eax,0x8010ee5c
          consputc(c);
80100c1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100c1f:	89 04 24             	mov    %eax,(%esp)
80100c22:	e8 b4 fb ff ff       	call   801007db <consputc>
	}
	if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100c27:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100c2b:	74 18                	je     80100c45 <consoleintr+0x36a>
80100c2d:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100c31:	74 12                	je     80100c45 <consoleintr+0x36a>
80100c33:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100c38:	8b 15 54 ee 10 80    	mov    0x8010ee54,%edx
80100c3e:	83 ea 80             	sub    $0xffffff80,%edx
80100c41:	39 d0                	cmp    %edx,%eax
80100c43:	75 2e                	jne    80100c73 <consoleintr+0x398>
          input.a = 0;
80100c45:	c7 05 60 ee 10 80 00 	movl   $0x0,0x8010ee60
80100c4c:	00 00 00 
	  input.w = input.e;
80100c4f:	a1 5c ee 10 80       	mov    0x8010ee5c,%eax
80100c54:	a3 58 ee 10 80       	mov    %eax,0x8010ee58
          wakeup(&input.r);
80100c59:	c7 04 24 54 ee 10 80 	movl   $0x8010ee54,(%esp)
80100c60:	e8 fe 44 00 00       	call   80105163 <wakeup>
        }
      }
      break;
80100c65:	eb 0c                	jmp    80100c73 <consoleintr+0x398>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c67:	90                   	nop
80100c68:	eb 0a                	jmp    80100c74 <consoleintr+0x399>
	{
	  consputc(BACKSPACE);
	}
	input.e--;
      }
      break;
80100c6a:	90                   	nop
80100c6b:	eb 07                	jmp    80100c74 <consoleintr+0x399>
     if(input.e % INPUT_BUF > 0 && input.e+input.a>0)
      {
        input.a--;
        consputc(KEY_LF);
      }
      break;
80100c6d:	90                   	nop
80100c6e:	eb 04                	jmp    80100c74 <consoleintr+0x399>
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
      {
        input.a++;
        consputc(KEY_RT);
      }
      break;
80100c70:	90                   	nop
80100c71:	eb 01                	jmp    80100c74 <consoleintr+0x399>
          input.a = 0;
	  input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100c73:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100c74:	8b 45 08             	mov    0x8(%ebp),%eax
80100c77:	ff d0                	call   *%eax
80100c79:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100c7c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100c80:	0f 89 6c fc ff ff    	jns    801008f2 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100c86:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100c8d:	e8 c3 47 00 00       	call   80105455 <release>
}
80100c92:	c9                   	leave  
80100c93:	c3                   	ret    

80100c94 <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c94:	55                   	push   %ebp
80100c95:	89 e5                	mov    %esp,%ebp
80100c97:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100c9d:	89 04 24             	mov    %eax,(%esp)
80100ca0:	e8 81 10 00 00       	call   80101d26 <iunlock>
  target = n;
80100ca5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100cab:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100cb2:	e8 3c 47 00 00       	call   801053f3 <acquire>
  while(n > 0){
80100cb7:	e9 a8 00 00 00       	jmp    80100d64 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100cbc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cc2:	8b 40 24             	mov    0x24(%eax),%eax
80100cc5:	85 c0                	test   %eax,%eax
80100cc7:	74 21                	je     80100cea <consoleread+0x56>
        release(&input.lock);
80100cc9:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100cd0:	e8 80 47 00 00       	call   80105455 <release>
        ilock(ip);
80100cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80100cd8:	89 04 24             	mov    %eax,(%esp)
80100cdb:	e8 f8 0e 00 00       	call   80101bd8 <ilock>
        return -1;
80100ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ce5:	e9 a9 00 00 00       	jmp    80100d93 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100cea:	c7 44 24 04 a0 ed 10 	movl   $0x8010eda0,0x4(%esp)
80100cf1:	80 
80100cf2:	c7 04 24 54 ee 10 80 	movl   $0x8010ee54,(%esp)
80100cf9:	e8 89 43 00 00       	call   80105087 <sleep>
80100cfe:	eb 01                	jmp    80100d01 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100d00:	90                   	nop
80100d01:	8b 15 54 ee 10 80    	mov    0x8010ee54,%edx
80100d07:	a1 58 ee 10 80       	mov    0x8010ee58,%eax
80100d0c:	39 c2                	cmp    %eax,%edx
80100d0e:	74 ac                	je     80100cbc <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100d10:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
80100d15:	89 c2                	mov    %eax,%edx
80100d17:	83 e2 7f             	and    $0x7f,%edx
80100d1a:	0f b6 92 d4 ed 10 80 	movzbl -0x7fef122c(%edx),%edx
80100d21:	0f be d2             	movsbl %dl,%edx
80100d24:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100d27:	83 c0 01             	add    $0x1,%eax
80100d2a:	a3 54 ee 10 80       	mov    %eax,0x8010ee54
    if(c == C('D')){  // EOF
80100d2f:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d33:	75 17                	jne    80100d4c <consoleread+0xb8>
      if(n < target){
80100d35:	8b 45 10             	mov    0x10(%ebp),%eax
80100d38:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100d3b:	73 2f                	jae    80100d6c <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100d3d:	a1 54 ee 10 80       	mov    0x8010ee54,%eax
80100d42:	83 e8 01             	sub    $0x1,%eax
80100d45:	a3 54 ee 10 80       	mov    %eax,0x8010ee54
      }
      break;
80100d4a:	eb 20                	jmp    80100d6c <consoleread+0xd8>
    }
    *dst++ = c;
80100d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d4f:	89 c2                	mov    %eax,%edx
80100d51:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d54:	88 10                	mov    %dl,(%eax)
80100d56:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100d5a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100d5e:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d62:	74 0b                	je     80100d6f <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100d64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100d68:	7f 96                	jg     80100d00 <consoleread+0x6c>
80100d6a:	eb 04                	jmp    80100d70 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100d6c:	90                   	nop
80100d6d:	eb 01                	jmp    80100d70 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100d6f:	90                   	nop
  }
  release(&input.lock);
80100d70:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100d77:	e8 d9 46 00 00       	call   80105455 <release>
  ilock(ip);
80100d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80100d7f:	89 04 24             	mov    %eax,(%esp)
80100d82:	e8 51 0e 00 00       	call   80101bd8 <ilock>

  return target - n;
80100d87:	8b 45 10             	mov    0x10(%ebp),%eax
80100d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d8d:	89 d1                	mov    %edx,%ecx
80100d8f:	29 c1                	sub    %eax,%ecx
80100d91:	89 c8                	mov    %ecx,%eax
}
80100d93:	c9                   	leave  
80100d94:	c3                   	ret    

80100d95 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d95:	55                   	push   %ebp
80100d96:	89 e5                	mov    %esp,%ebp
80100d98:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80100d9e:	89 04 24             	mov    %eax,(%esp)
80100da1:	e8 80 0f 00 00       	call   80101d26 <iunlock>
  acquire(&cons.lock);
80100da6:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100dad:	e8 41 46 00 00       	call   801053f3 <acquire>
  for(i = 0; i < n; i++)
80100db2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100db9:	eb 1d                	jmp    80100dd8 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100dbe:	03 45 0c             	add    0xc(%ebp),%eax
80100dc1:	0f b6 00             	movzbl (%eax),%eax
80100dc4:	0f be c0             	movsbl %al,%eax
80100dc7:	25 ff 00 00 00       	and    $0xff,%eax
80100dcc:	89 04 24             	mov    %eax,(%esp)
80100dcf:	e8 07 fa ff ff       	call   801007db <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100dd4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ddb:	3b 45 10             	cmp    0x10(%ebp),%eax
80100dde:	7c db                	jl     80100dbb <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100de0:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100de7:	e8 69 46 00 00       	call   80105455 <release>
  ilock(ip);
80100dec:	8b 45 08             	mov    0x8(%ebp),%eax
80100def:	89 04 24             	mov    %eax,(%esp)
80100df2:	e8 e1 0d 00 00       	call   80101bd8 <ilock>

  return n;
80100df7:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100dfa:	c9                   	leave  
80100dfb:	c3                   	ret    

80100dfc <consoleinit>:

void
consoleinit(void)
{
80100dfc:	55                   	push   %ebp
80100dfd:	89 e5                	mov    %esp,%ebp
80100dff:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100e02:	c7 44 24 04 eb 8a 10 	movl   $0x80108aeb,0x4(%esp)
80100e09:	80 
80100e0a:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100e11:	e8 bc 45 00 00       	call   801053d2 <initlock>
  initlock(&input.lock, "input");
80100e16:	c7 44 24 04 f3 8a 10 	movl   $0x80108af3,0x4(%esp)
80100e1d:	80 
80100e1e:	c7 04 24 a0 ed 10 80 	movl   $0x8010eda0,(%esp)
80100e25:	e8 a8 45 00 00       	call   801053d2 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100e2a:	c7 05 2c f8 10 80 95 	movl   $0x80100d95,0x8010f82c
80100e31:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100e34:	c7 05 28 f8 10 80 94 	movl   $0x80100c94,0x8010f828
80100e3b:	0c 10 80 
  cons.locking = 1;
80100e3e:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100e45:	00 00 00 

  picenable(IRQ_KBD);
80100e48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e4f:	e8 dd 2f 00 00       	call   80103e31 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100e54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100e5b:	00 
80100e5c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e63:	e8 7e 1e 00 00       	call   80102ce6 <ioapicenable>
}
80100e68:	c9                   	leave  
80100e69:	c3                   	ret    
	...

80100e6c <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100e6c:	55                   	push   %ebp
80100e6d:	89 e5                	mov    %esp,%ebp
80100e6f:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100e75:	8b 45 08             	mov    0x8(%ebp),%eax
80100e78:	89 04 24             	mov    %eax,(%esp)
80100e7b:	e8 fa 18 00 00       	call   8010277a <namei>
80100e80:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100e83:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e87:	75 0a                	jne    80100e93 <exec+0x27>
    return -1;
80100e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e8e:	e9 da 03 00 00       	jmp    8010126d <exec+0x401>
  ilock(ip);
80100e93:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e96:	89 04 24             	mov    %eax,(%esp)
80100e99:	e8 3a 0d 00 00       	call   80101bd8 <ilock>
  pgdir = 0;
80100e9e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100ea5:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100eac:	00 
80100ead:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100eb4:	00 
80100eb5:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ebf:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ec2:	89 04 24             	mov    %eax,(%esp)
80100ec5:	e8 04 12 00 00       	call   801020ce <readi>
80100eca:	83 f8 33             	cmp    $0x33,%eax
80100ecd:	0f 86 54 03 00 00    	jbe    80101227 <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100ed3:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ed9:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100ede:	0f 85 46 03 00 00    	jne    8010122a <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100ee4:	c7 04 24 6f 2e 10 80 	movl   $0x80102e6f,(%esp)
80100eeb:	e8 59 73 00 00       	call   80108249 <setupkvm>
80100ef0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ef3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ef7:	0f 84 30 03 00 00    	je     8010122d <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100efd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f04:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100f0b:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100f11:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f14:	e9 c5 00 00 00       	jmp    80100fde <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100f19:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f1c:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100f23:	00 
80100f24:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f28:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f32:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f35:	89 04 24             	mov    %eax,(%esp)
80100f38:	e8 91 11 00 00       	call   801020ce <readi>
80100f3d:	83 f8 20             	cmp    $0x20,%eax
80100f40:	0f 85 ea 02 00 00    	jne    80101230 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100f46:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100f4c:	83 f8 01             	cmp    $0x1,%eax
80100f4f:	75 7f                	jne    80100fd0 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100f51:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100f57:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100f5d:	39 c2                	cmp    %eax,%edx
80100f5f:	0f 82 ce 02 00 00    	jb     80101233 <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f65:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100f6b:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100f71:	01 d0                	add    %edx,%eax
80100f73:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f77:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f81:	89 04 24             	mov    %eax,(%esp)
80100f84:	e8 92 76 00 00       	call   8010861b <allocuvm>
80100f89:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f8c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f90:	0f 84 a0 02 00 00    	je     80101236 <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f96:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f9c:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100fa2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100fa8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100fac:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100fb0:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100fb3:	89 54 24 08          	mov    %edx,0x8(%esp)
80100fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fbb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fbe:	89 04 24             	mov    %eax,(%esp)
80100fc1:	e8 66 75 00 00       	call   8010852c <loaduvm>
80100fc6:	85 c0                	test   %eax,%eax
80100fc8:	0f 88 6b 02 00 00    	js     80101239 <exec+0x3cd>
80100fce:	eb 01                	jmp    80100fd1 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100fd0:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100fd1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100fd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100fd8:	83 c0 20             	add    $0x20,%eax
80100fdb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100fde:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100fe5:	0f b7 c0             	movzwl %ax,%eax
80100fe8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100feb:	0f 8f 28 ff ff ff    	jg     80100f19 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100ff1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ff4:	89 04 24             	mov    %eax,(%esp)
80100ff7:	e8 60 0e 00 00       	call   80101e5c <iunlockput>
  ip = 0;
80100ffc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80101003:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101006:	05 ff 0f 00 00       	add    $0xfff,%eax
8010100b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80101010:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80101013:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101016:	05 00 20 00 00       	add    $0x2000,%eax
8010101b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010101f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101022:	89 44 24 04          	mov    %eax,0x4(%esp)
80101026:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101029:	89 04 24             	mov    %eax,(%esp)
8010102c:	e8 ea 75 00 00       	call   8010861b <allocuvm>
80101031:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101034:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101038:	0f 84 fe 01 00 00    	je     8010123c <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
8010103e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101041:	2d 00 20 00 00       	sub    $0x2000,%eax
80101046:	89 44 24 04          	mov    %eax,0x4(%esp)
8010104a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010104d:	89 04 24             	mov    %eax,(%esp)
80101050:	e8 ea 77 00 00       	call   8010883f <clearpteu>
  sp = sz;
80101055:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101058:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
8010105b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101062:	e9 81 00 00 00       	jmp    801010e8 <exec+0x27c>
    if(argc >= MAXARG)
80101067:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
8010106b:	0f 87 ce 01 00 00    	ja     8010123f <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101071:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101074:	c1 e0 02             	shl    $0x2,%eax
80101077:	03 45 0c             	add    0xc(%ebp),%eax
8010107a:	8b 00                	mov    (%eax),%eax
8010107c:	89 04 24             	mov    %eax,(%esp)
8010107f:	e8 3c 48 00 00       	call   801058c0 <strlen>
80101084:	f7 d0                	not    %eax
80101086:	03 45 dc             	add    -0x24(%ebp),%eax
80101089:	83 e0 fc             	and    $0xfffffffc,%eax
8010108c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
8010108f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101092:	c1 e0 02             	shl    $0x2,%eax
80101095:	03 45 0c             	add    0xc(%ebp),%eax
80101098:	8b 00                	mov    (%eax),%eax
8010109a:	89 04 24             	mov    %eax,(%esp)
8010109d:	e8 1e 48 00 00       	call   801058c0 <strlen>
801010a2:	83 c0 01             	add    $0x1,%eax
801010a5:	89 c2                	mov    %eax,%edx
801010a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010aa:	c1 e0 02             	shl    $0x2,%eax
801010ad:	03 45 0c             	add    0xc(%ebp),%eax
801010b0:	8b 00                	mov    (%eax),%eax
801010b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
801010b6:	89 44 24 08          	mov    %eax,0x8(%esp)
801010ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801010c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010c4:	89 04 24             	mov    %eax,(%esp)
801010c7:	e8 27 79 00 00       	call   801089f3 <copyout>
801010cc:	85 c0                	test   %eax,%eax
801010ce:	0f 88 6e 01 00 00    	js     80101242 <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
801010d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010d7:	8d 50 03             	lea    0x3(%eax),%edx
801010da:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010dd:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801010e4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010eb:	c1 e0 02             	shl    $0x2,%eax
801010ee:	03 45 0c             	add    0xc(%ebp),%eax
801010f1:	8b 00                	mov    (%eax),%eax
801010f3:	85 c0                	test   %eax,%eax
801010f5:	0f 85 6c ff ff ff    	jne    80101067 <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010fe:	83 c0 03             	add    $0x3,%eax
80101101:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80101108:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
8010110c:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80101113:	ff ff ff 
  ustack[1] = argc;
80101116:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101119:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
8010111f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101122:	83 c0 01             	add    $0x1,%eax
80101125:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010112c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010112f:	29 d0                	sub    %edx,%eax
80101131:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80101137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010113a:	83 c0 04             	add    $0x4,%eax
8010113d:	c1 e0 02             	shl    $0x2,%eax
80101140:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101146:	83 c0 04             	add    $0x4,%eax
80101149:	c1 e0 02             	shl    $0x2,%eax
8010114c:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101150:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80101156:	89 44 24 08          	mov    %eax,0x8(%esp)
8010115a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010115d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101161:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101164:	89 04 24             	mov    %eax,(%esp)
80101167:	e8 87 78 00 00       	call   801089f3 <copyout>
8010116c:	85 c0                	test   %eax,%eax
8010116e:	0f 88 d1 00 00 00    	js     80101245 <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010117a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010117d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101180:	eb 17                	jmp    80101199 <exec+0x32d>
    if(*s == '/')
80101182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101185:	0f b6 00             	movzbl (%eax),%eax
80101188:	3c 2f                	cmp    $0x2f,%al
8010118a:	75 09                	jne    80101195 <exec+0x329>
      last = s+1;
8010118c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010118f:	83 c0 01             	add    $0x1,%eax
80101192:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101195:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010119c:	0f b6 00             	movzbl (%eax),%eax
8010119f:	84 c0                	test   %al,%al
801011a1:	75 df                	jne    80101182 <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
801011a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011a9:	8d 50 6c             	lea    0x6c(%eax),%edx
801011ac:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801011b3:	00 
801011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801011bb:	89 14 24             	mov    %edx,(%esp)
801011be:	e8 af 46 00 00       	call   80105872 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801011c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011c9:	8b 40 04             	mov    0x4(%eax),%eax
801011cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
801011cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801011d8:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801011db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801011e4:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801011e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011ec:	8b 40 18             	mov    0x18(%eax),%eax
801011ef:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801011f5:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011fe:	8b 40 18             	mov    0x18(%eax),%eax
80101201:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101204:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80101207:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010120d:	89 04 24             	mov    %eax,(%esp)
80101210:	e8 25 71 00 00       	call   8010833a <switchuvm>
  freevm(oldpgdir);
80101215:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101218:	89 04 24             	mov    %eax,(%esp)
8010121b:	e8 91 75 00 00       	call   801087b1 <freevm>
  return 0;
80101220:	b8 00 00 00 00       	mov    $0x0,%eax
80101225:	eb 46                	jmp    8010126d <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80101227:	90                   	nop
80101228:	eb 1c                	jmp    80101246 <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010122a:	90                   	nop
8010122b:	eb 19                	jmp    80101246 <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
8010122d:	90                   	nop
8010122e:	eb 16                	jmp    80101246 <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101230:	90                   	nop
80101231:	eb 13                	jmp    80101246 <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101233:	90                   	nop
80101234:	eb 10                	jmp    80101246 <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101236:	90                   	nop
80101237:	eb 0d                	jmp    80101246 <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101239:	90                   	nop
8010123a:	eb 0a                	jmp    80101246 <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
8010123c:	90                   	nop
8010123d:	eb 07                	jmp    80101246 <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
8010123f:	90                   	nop
80101240:	eb 04                	jmp    80101246 <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101242:	90                   	nop
80101243:	eb 01                	jmp    80101246 <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101245:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80101246:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010124a:	74 0b                	je     80101257 <exec+0x3eb>
    freevm(pgdir);
8010124c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010124f:	89 04 24             	mov    %eax,(%esp)
80101252:	e8 5a 75 00 00       	call   801087b1 <freevm>
  if(ip)
80101257:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010125b:	74 0b                	je     80101268 <exec+0x3fc>
    iunlockput(ip);
8010125d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101260:	89 04 24             	mov    %eax,(%esp)
80101263:	e8 f4 0b 00 00       	call   80101e5c <iunlockput>
  return -1;
80101268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010126d:	c9                   	leave  
8010126e:	c3                   	ret    
	...

80101270 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101270:	55                   	push   %ebp
80101271:	89 e5                	mov    %esp,%ebp
80101273:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80101276:	c7 44 24 04 f9 8a 10 	movl   $0x80108af9,0x4(%esp)
8010127d:	80 
8010127e:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
80101285:	e8 48 41 00 00       	call   801053d2 <initlock>
}
8010128a:	c9                   	leave  
8010128b:	c3                   	ret    

8010128c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010128c:	55                   	push   %ebp
8010128d:	89 e5                	mov    %esp,%ebp
8010128f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101292:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
80101299:	e8 55 41 00 00       	call   801053f3 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010129e:	c7 45 f4 b4 ee 10 80 	movl   $0x8010eeb4,-0xc(%ebp)
801012a5:	eb 29                	jmp    801012d0 <filealloc+0x44>
    if(f->ref == 0){
801012a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012aa:	8b 40 04             	mov    0x4(%eax),%eax
801012ad:	85 c0                	test   %eax,%eax
801012af:	75 1b                	jne    801012cc <filealloc+0x40>
      f->ref = 1;
801012b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801012bb:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
801012c2:	e8 8e 41 00 00       	call   80105455 <release>
      return f;
801012c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ca:	eb 1e                	jmp    801012ea <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012cc:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801012d0:	81 7d f4 14 f8 10 80 	cmpl   $0x8010f814,-0xc(%ebp)
801012d7:	72 ce                	jb     801012a7 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801012d9:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
801012e0:	e8 70 41 00 00       	call   80105455 <release>
  return 0;
801012e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801012ea:	c9                   	leave  
801012eb:	c3                   	ret    

801012ec <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801012f2:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
801012f9:	e8 f5 40 00 00       	call   801053f3 <acquire>
  if(f->ref < 1)
801012fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101301:	8b 40 04             	mov    0x4(%eax),%eax
80101304:	85 c0                	test   %eax,%eax
80101306:	7f 0c                	jg     80101314 <filedup+0x28>
    panic("filedup");
80101308:	c7 04 24 00 8b 10 80 	movl   $0x80108b00,(%esp)
8010130f:	e8 29 f2 ff ff       	call   8010053d <panic>
  f->ref++;
80101314:	8b 45 08             	mov    0x8(%ebp),%eax
80101317:	8b 40 04             	mov    0x4(%eax),%eax
8010131a:	8d 50 01             	lea    0x1(%eax),%edx
8010131d:	8b 45 08             	mov    0x8(%ebp),%eax
80101320:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101323:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
8010132a:	e8 26 41 00 00       	call   80105455 <release>
  return f;
8010132f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101332:	c9                   	leave  
80101333:	c3                   	ret    

80101334 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101334:	55                   	push   %ebp
80101335:	89 e5                	mov    %esp,%ebp
80101337:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
8010133a:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
80101341:	e8 ad 40 00 00       	call   801053f3 <acquire>
  if(f->ref < 1)
80101346:	8b 45 08             	mov    0x8(%ebp),%eax
80101349:	8b 40 04             	mov    0x4(%eax),%eax
8010134c:	85 c0                	test   %eax,%eax
8010134e:	7f 0c                	jg     8010135c <fileclose+0x28>
    panic("fileclose");
80101350:	c7 04 24 08 8b 10 80 	movl   $0x80108b08,(%esp)
80101357:	e8 e1 f1 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
8010135c:	8b 45 08             	mov    0x8(%ebp),%eax
8010135f:	8b 40 04             	mov    0x4(%eax),%eax
80101362:	8d 50 ff             	lea    -0x1(%eax),%edx
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	89 50 04             	mov    %edx,0x4(%eax)
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	8b 40 04             	mov    0x4(%eax),%eax
80101371:	85 c0                	test   %eax,%eax
80101373:	7e 11                	jle    80101386 <fileclose+0x52>
    release(&ftable.lock);
80101375:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
8010137c:	e8 d4 40 00 00       	call   80105455 <release>
    return;
80101381:	e9 82 00 00 00       	jmp    80101408 <fileclose+0xd4>
  }
  ff = *f;
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	8b 10                	mov    (%eax),%edx
8010138b:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010138e:	8b 50 04             	mov    0x4(%eax),%edx
80101391:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101394:	8b 50 08             	mov    0x8(%eax),%edx
80101397:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010139a:	8b 50 0c             	mov    0xc(%eax),%edx
8010139d:	89 55 ec             	mov    %edx,-0x14(%ebp)
801013a0:	8b 50 10             	mov    0x10(%eax),%edx
801013a3:	89 55 f0             	mov    %edx,-0x10(%ebp)
801013a6:	8b 40 14             	mov    0x14(%eax),%eax
801013a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801013ac:	8b 45 08             	mov    0x8(%ebp),%eax
801013af:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801013b6:	8b 45 08             	mov    0x8(%ebp),%eax
801013b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801013bf:	c7 04 24 80 ee 10 80 	movl   $0x8010ee80,(%esp)
801013c6:	e8 8a 40 00 00       	call   80105455 <release>
  
  if(ff.type == FD_PIPE)
801013cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013ce:	83 f8 01             	cmp    $0x1,%eax
801013d1:	75 18                	jne    801013eb <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801013d3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801013d7:	0f be d0             	movsbl %al,%edx
801013da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801013e1:	89 04 24             	mov    %eax,(%esp)
801013e4:	e8 02 2d 00 00       	call   801040eb <pipeclose>
801013e9:	eb 1d                	jmp    80101408 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801013eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013ee:	83 f8 02             	cmp    $0x2,%eax
801013f1:	75 15                	jne    80101408 <fileclose+0xd4>
    begin_trans();
801013f3:	e8 95 21 00 00       	call   8010358d <begin_trans>
    iput(ff.ip);
801013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013fb:	89 04 24             	mov    %eax,(%esp)
801013fe:	e8 88 09 00 00       	call   80101d8b <iput>
    commit_trans();
80101403:	e8 ce 21 00 00       	call   801035d6 <commit_trans>
  }
}
80101408:	c9                   	leave  
80101409:	c3                   	ret    

8010140a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010140a:	55                   	push   %ebp
8010140b:	89 e5                	mov    %esp,%ebp
8010140d:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	8b 00                	mov    (%eax),%eax
80101415:	83 f8 02             	cmp    $0x2,%eax
80101418:	75 38                	jne    80101452 <filestat+0x48>
    ilock(f->ip);
8010141a:	8b 45 08             	mov    0x8(%ebp),%eax
8010141d:	8b 40 10             	mov    0x10(%eax),%eax
80101420:	89 04 24             	mov    %eax,(%esp)
80101423:	e8 b0 07 00 00       	call   80101bd8 <ilock>
    stati(f->ip, st);
80101428:	8b 45 08             	mov    0x8(%ebp),%eax
8010142b:	8b 40 10             	mov    0x10(%eax),%eax
8010142e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101431:	89 54 24 04          	mov    %edx,0x4(%esp)
80101435:	89 04 24             	mov    %eax,(%esp)
80101438:	e8 4c 0c 00 00       	call   80102089 <stati>
    iunlock(f->ip);
8010143d:	8b 45 08             	mov    0x8(%ebp),%eax
80101440:	8b 40 10             	mov    0x10(%eax),%eax
80101443:	89 04 24             	mov    %eax,(%esp)
80101446:	e8 db 08 00 00       	call   80101d26 <iunlock>
    return 0;
8010144b:	b8 00 00 00 00       	mov    $0x0,%eax
80101450:	eb 05                	jmp    80101457 <filestat+0x4d>
  }
  return -1;
80101452:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101457:	c9                   	leave  
80101458:	c3                   	ret    

80101459 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101459:	55                   	push   %ebp
8010145a:	89 e5                	mov    %esp,%ebp
8010145c:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010145f:	8b 45 08             	mov    0x8(%ebp),%eax
80101462:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101466:	84 c0                	test   %al,%al
80101468:	75 0a                	jne    80101474 <fileread+0x1b>
    return -1;
8010146a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010146f:	e9 9f 00 00 00       	jmp    80101513 <fileread+0xba>
  if(f->type == FD_PIPE)
80101474:	8b 45 08             	mov    0x8(%ebp),%eax
80101477:	8b 00                	mov    (%eax),%eax
80101479:	83 f8 01             	cmp    $0x1,%eax
8010147c:	75 1e                	jne    8010149c <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010147e:	8b 45 08             	mov    0x8(%ebp),%eax
80101481:	8b 40 0c             	mov    0xc(%eax),%eax
80101484:	8b 55 10             	mov    0x10(%ebp),%edx
80101487:	89 54 24 08          	mov    %edx,0x8(%esp)
8010148b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010148e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101492:	89 04 24             	mov    %eax,(%esp)
80101495:	e8 d3 2d 00 00       	call   8010426d <piperead>
8010149a:	eb 77                	jmp    80101513 <fileread+0xba>
  if(f->type == FD_INODE){
8010149c:	8b 45 08             	mov    0x8(%ebp),%eax
8010149f:	8b 00                	mov    (%eax),%eax
801014a1:	83 f8 02             	cmp    $0x2,%eax
801014a4:	75 61                	jne    80101507 <fileread+0xae>
    ilock(f->ip);
801014a6:	8b 45 08             	mov    0x8(%ebp),%eax
801014a9:	8b 40 10             	mov    0x10(%eax),%eax
801014ac:	89 04 24             	mov    %eax,(%esp)
801014af:	e8 24 07 00 00       	call   80101bd8 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801014b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
801014b7:	8b 45 08             	mov    0x8(%ebp),%eax
801014ba:	8b 50 14             	mov    0x14(%eax),%edx
801014bd:	8b 45 08             	mov    0x8(%ebp),%eax
801014c0:	8b 40 10             	mov    0x10(%eax),%eax
801014c3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801014c7:	89 54 24 08          	mov    %edx,0x8(%esp)
801014cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801014ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801014d2:	89 04 24             	mov    %eax,(%esp)
801014d5:	e8 f4 0b 00 00       	call   801020ce <readi>
801014da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801014dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801014e1:	7e 11                	jle    801014f4 <fileread+0x9b>
      f->off += r;
801014e3:	8b 45 08             	mov    0x8(%ebp),%eax
801014e6:	8b 50 14             	mov    0x14(%eax),%edx
801014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ec:	01 c2                	add    %eax,%edx
801014ee:	8b 45 08             	mov    0x8(%ebp),%eax
801014f1:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801014f4:	8b 45 08             	mov    0x8(%ebp),%eax
801014f7:	8b 40 10             	mov    0x10(%eax),%eax
801014fa:	89 04 24             	mov    %eax,(%esp)
801014fd:	e8 24 08 00 00       	call   80101d26 <iunlock>
    return r;
80101502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101505:	eb 0c                	jmp    80101513 <fileread+0xba>
  }
  panic("fileread");
80101507:	c7 04 24 12 8b 10 80 	movl   $0x80108b12,(%esp)
8010150e:	e8 2a f0 ff ff       	call   8010053d <panic>
}
80101513:	c9                   	leave  
80101514:	c3                   	ret    

80101515 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101515:	55                   	push   %ebp
80101516:	89 e5                	mov    %esp,%ebp
80101518:	53                   	push   %ebx
80101519:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
8010151c:	8b 45 08             	mov    0x8(%ebp),%eax
8010151f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101523:	84 c0                	test   %al,%al
80101525:	75 0a                	jne    80101531 <filewrite+0x1c>
    return -1;
80101527:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010152c:	e9 23 01 00 00       	jmp    80101654 <filewrite+0x13f>
  if(f->type == FD_PIPE)
80101531:	8b 45 08             	mov    0x8(%ebp),%eax
80101534:	8b 00                	mov    (%eax),%eax
80101536:	83 f8 01             	cmp    $0x1,%eax
80101539:	75 21                	jne    8010155c <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
8010153b:	8b 45 08             	mov    0x8(%ebp),%eax
8010153e:	8b 40 0c             	mov    0xc(%eax),%eax
80101541:	8b 55 10             	mov    0x10(%ebp),%edx
80101544:	89 54 24 08          	mov    %edx,0x8(%esp)
80101548:	8b 55 0c             	mov    0xc(%ebp),%edx
8010154b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010154f:	89 04 24             	mov    %eax,(%esp)
80101552:	e8 26 2c 00 00       	call   8010417d <pipewrite>
80101557:	e9 f8 00 00 00       	jmp    80101654 <filewrite+0x13f>
  if(f->type == FD_INODE){
8010155c:	8b 45 08             	mov    0x8(%ebp),%eax
8010155f:	8b 00                	mov    (%eax),%eax
80101561:	83 f8 02             	cmp    $0x2,%eax
80101564:	0f 85 de 00 00 00    	jne    80101648 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010156a:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101571:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101578:	e9 a8 00 00 00       	jmp    80101625 <filewrite+0x110>
      int n1 = n - i;
8010157d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101580:	8b 55 10             	mov    0x10(%ebp),%edx
80101583:	89 d1                	mov    %edx,%ecx
80101585:	29 c1                	sub    %eax,%ecx
80101587:	89 c8                	mov    %ecx,%eax
80101589:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010158f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101592:	7e 06                	jle    8010159a <filewrite+0x85>
        n1 = max;
80101594:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101597:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010159a:	e8 ee 1f 00 00       	call   8010358d <begin_trans>
      ilock(f->ip);
8010159f:	8b 45 08             	mov    0x8(%ebp),%eax
801015a2:	8b 40 10             	mov    0x10(%eax),%eax
801015a5:	89 04 24             	mov    %eax,(%esp)
801015a8:	e8 2b 06 00 00       	call   80101bd8 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801015ad:	8b 5d f0             	mov    -0x10(%ebp),%ebx
801015b0:	8b 45 08             	mov    0x8(%ebp),%eax
801015b3:	8b 48 14             	mov    0x14(%eax),%ecx
801015b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b9:	89 c2                	mov    %eax,%edx
801015bb:	03 55 0c             	add    0xc(%ebp),%edx
801015be:	8b 45 08             	mov    0x8(%ebp),%eax
801015c1:	8b 40 10             	mov    0x10(%eax),%eax
801015c4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801015c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801015cc:	89 54 24 04          	mov    %edx,0x4(%esp)
801015d0:	89 04 24             	mov    %eax,(%esp)
801015d3:	e8 61 0c 00 00       	call   80102239 <writei>
801015d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
801015db:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015df:	7e 11                	jle    801015f2 <filewrite+0xdd>
        f->off += r;
801015e1:	8b 45 08             	mov    0x8(%ebp),%eax
801015e4:	8b 50 14             	mov    0x14(%eax),%edx
801015e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015ea:	01 c2                	add    %eax,%edx
801015ec:	8b 45 08             	mov    0x8(%ebp),%eax
801015ef:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801015f2:	8b 45 08             	mov    0x8(%ebp),%eax
801015f5:	8b 40 10             	mov    0x10(%eax),%eax
801015f8:	89 04 24             	mov    %eax,(%esp)
801015fb:	e8 26 07 00 00       	call   80101d26 <iunlock>
      commit_trans();
80101600:	e8 d1 1f 00 00       	call   801035d6 <commit_trans>

      if(r < 0)
80101605:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101609:	78 28                	js     80101633 <filewrite+0x11e>
        break;
      if(r != n1)
8010160b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010160e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101611:	74 0c                	je     8010161f <filewrite+0x10a>
        panic("short filewrite");
80101613:	c7 04 24 1b 8b 10 80 	movl   $0x80108b1b,(%esp)
8010161a:	e8 1e ef ff ff       	call   8010053d <panic>
      i += r;
8010161f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101622:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101628:	3b 45 10             	cmp    0x10(%ebp),%eax
8010162b:	0f 8c 4c ff ff ff    	jl     8010157d <filewrite+0x68>
80101631:	eb 01                	jmp    80101634 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
80101633:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101637:	3b 45 10             	cmp    0x10(%ebp),%eax
8010163a:	75 05                	jne    80101641 <filewrite+0x12c>
8010163c:	8b 45 10             	mov    0x10(%ebp),%eax
8010163f:	eb 05                	jmp    80101646 <filewrite+0x131>
80101641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101646:	eb 0c                	jmp    80101654 <filewrite+0x13f>
  }
  panic("filewrite");
80101648:	c7 04 24 2b 8b 10 80 	movl   $0x80108b2b,(%esp)
8010164f:	e8 e9 ee ff ff       	call   8010053d <panic>
}
80101654:	83 c4 24             	add    $0x24,%esp
80101657:	5b                   	pop    %ebx
80101658:	5d                   	pop    %ebp
80101659:	c3                   	ret    
	...

8010165c <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010165c:	55                   	push   %ebp
8010165d:	89 e5                	mov    %esp,%ebp
8010165f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101662:	8b 45 08             	mov    0x8(%ebp),%eax
80101665:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010166c:	00 
8010166d:	89 04 24             	mov    %eax,(%esp)
80101670:	e8 31 eb ff ff       	call   801001a6 <bread>
80101675:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167b:	83 c0 18             	add    $0x18,%eax
8010167e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101685:	00 
80101686:	89 44 24 04          	mov    %eax,0x4(%esp)
8010168a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010168d:	89 04 24             	mov    %eax,(%esp)
80101690:	e8 80 40 00 00       	call   80105715 <memmove>
  brelse(bp);
80101695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101698:	89 04 24             	mov    %eax,(%esp)
8010169b:	e8 77 eb ff ff       	call   80100217 <brelse>
}
801016a0:	c9                   	leave  
801016a1:	c3                   	ret    

801016a2 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801016a2:	55                   	push   %ebp
801016a3:	89 e5                	mov    %esp,%ebp
801016a5:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801016a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801016ab:	8b 45 08             	mov    0x8(%ebp),%eax
801016ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801016b2:	89 04 24             	mov    %eax,(%esp)
801016b5:	e8 ec ea ff ff       	call   801001a6 <bread>
801016ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c0:	83 c0 18             	add    $0x18,%eax
801016c3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801016ca:	00 
801016cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016d2:	00 
801016d3:	89 04 24             	mov    %eax,(%esp)
801016d6:	e8 67 3f 00 00       	call   80105642 <memset>
  log_write(bp);
801016db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016de:	89 04 24             	mov    %eax,(%esp)
801016e1:	e8 48 1f 00 00       	call   8010362e <log_write>
  brelse(bp);
801016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e9:	89 04 24             	mov    %eax,(%esp)
801016ec:	e8 26 eb ff ff       	call   80100217 <brelse>
}
801016f1:	c9                   	leave  
801016f2:	c3                   	ret    

801016f3 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801016f3:	55                   	push   %ebp
801016f4:	89 e5                	mov    %esp,%ebp
801016f6:	53                   	push   %ebx
801016f7:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801016fa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101701:	8b 45 08             	mov    0x8(%ebp),%eax
80101704:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101707:	89 54 24 04          	mov    %edx,0x4(%esp)
8010170b:	89 04 24             	mov    %eax,(%esp)
8010170e:	e8 49 ff ff ff       	call   8010165c <readsb>
  for(b = 0; b < sb.size; b += BPB){
80101713:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010171a:	e9 11 01 00 00       	jmp    80101830 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010171f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101722:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101728:	85 c0                	test   %eax,%eax
8010172a:	0f 48 c2             	cmovs  %edx,%eax
8010172d:	c1 f8 0c             	sar    $0xc,%eax
80101730:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101733:	c1 ea 03             	shr    $0x3,%edx
80101736:	01 d0                	add    %edx,%eax
80101738:	83 c0 03             	add    $0x3,%eax
8010173b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010173f:	8b 45 08             	mov    0x8(%ebp),%eax
80101742:	89 04 24             	mov    %eax,(%esp)
80101745:	e8 5c ea ff ff       	call   801001a6 <bread>
8010174a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010174d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101754:	e9 a7 00 00 00       	jmp    80101800 <balloc+0x10d>
      m = 1 << (bi % 8);
80101759:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175c:	89 c2                	mov    %eax,%edx
8010175e:	c1 fa 1f             	sar    $0x1f,%edx
80101761:	c1 ea 1d             	shr    $0x1d,%edx
80101764:	01 d0                	add    %edx,%eax
80101766:	83 e0 07             	and    $0x7,%eax
80101769:	29 d0                	sub    %edx,%eax
8010176b:	ba 01 00 00 00       	mov    $0x1,%edx
80101770:	89 d3                	mov    %edx,%ebx
80101772:	89 c1                	mov    %eax,%ecx
80101774:	d3 e3                	shl    %cl,%ebx
80101776:	89 d8                	mov    %ebx,%eax
80101778:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177e:	8d 50 07             	lea    0x7(%eax),%edx
80101781:	85 c0                	test   %eax,%eax
80101783:	0f 48 c2             	cmovs  %edx,%eax
80101786:	c1 f8 03             	sar    $0x3,%eax
80101789:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010178c:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101791:	0f b6 c0             	movzbl %al,%eax
80101794:	23 45 e8             	and    -0x18(%ebp),%eax
80101797:	85 c0                	test   %eax,%eax
80101799:	75 61                	jne    801017fc <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
8010179b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010179e:	8d 50 07             	lea    0x7(%eax),%edx
801017a1:	85 c0                	test   %eax,%eax
801017a3:	0f 48 c2             	cmovs  %edx,%eax
801017a6:	c1 f8 03             	sar    $0x3,%eax
801017a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017ac:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801017b1:	89 d1                	mov    %edx,%ecx
801017b3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801017b6:	09 ca                	or     %ecx,%edx
801017b8:	89 d1                	mov    %edx,%ecx
801017ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017bd:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c4:	89 04 24             	mov    %eax,(%esp)
801017c7:	e8 62 1e 00 00       	call   8010362e <log_write>
        brelse(bp);
801017cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017cf:	89 04 24             	mov    %eax,(%esp)
801017d2:	e8 40 ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
801017d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017dd:	01 c2                	add    %eax,%edx
801017df:	8b 45 08             	mov    0x8(%ebp),%eax
801017e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801017e6:	89 04 24             	mov    %eax,(%esp)
801017e9:	e8 b4 fe ff ff       	call   801016a2 <bzero>
        return b + bi;
801017ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017f4:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801017f6:	83 c4 34             	add    $0x34,%esp
801017f9:	5b                   	pop    %ebx
801017fa:	5d                   	pop    %ebp
801017fb:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801017fc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101800:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101807:	7f 15                	jg     8010181e <balloc+0x12b>
80101809:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010180f:	01 d0                	add    %edx,%eax
80101811:	89 c2                	mov    %eax,%edx
80101813:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101816:	39 c2                	cmp    %eax,%edx
80101818:	0f 82 3b ff ff ff    	jb     80101759 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010181e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101821:	89 04 24             	mov    %eax,(%esp)
80101824:	e8 ee e9 ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101829:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101830:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101833:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101836:	39 c2                	cmp    %eax,%edx
80101838:	0f 82 e1 fe ff ff    	jb     8010171f <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010183e:	c7 04 24 35 8b 10 80 	movl   $0x80108b35,(%esp)
80101845:	e8 f3 ec ff ff       	call   8010053d <panic>

8010184a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010184a:	55                   	push   %ebp
8010184b:	89 e5                	mov    %esp,%ebp
8010184d:	53                   	push   %ebx
8010184e:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101851:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101854:	89 44 24 04          	mov    %eax,0x4(%esp)
80101858:	8b 45 08             	mov    0x8(%ebp),%eax
8010185b:	89 04 24             	mov    %eax,(%esp)
8010185e:	e8 f9 fd ff ff       	call   8010165c <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101863:	8b 45 0c             	mov    0xc(%ebp),%eax
80101866:	89 c2                	mov    %eax,%edx
80101868:	c1 ea 0c             	shr    $0xc,%edx
8010186b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010186e:	c1 e8 03             	shr    $0x3,%eax
80101871:	01 d0                	add    %edx,%eax
80101873:	8d 50 03             	lea    0x3(%eax),%edx
80101876:	8b 45 08             	mov    0x8(%ebp),%eax
80101879:	89 54 24 04          	mov    %edx,0x4(%esp)
8010187d:	89 04 24             	mov    %eax,(%esp)
80101880:	e8 21 e9 ff ff       	call   801001a6 <bread>
80101885:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101888:	8b 45 0c             	mov    0xc(%ebp),%eax
8010188b:	25 ff 0f 00 00       	and    $0xfff,%eax
80101890:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101896:	89 c2                	mov    %eax,%edx
80101898:	c1 fa 1f             	sar    $0x1f,%edx
8010189b:	c1 ea 1d             	shr    $0x1d,%edx
8010189e:	01 d0                	add    %edx,%eax
801018a0:	83 e0 07             	and    $0x7,%eax
801018a3:	29 d0                	sub    %edx,%eax
801018a5:	ba 01 00 00 00       	mov    $0x1,%edx
801018aa:	89 d3                	mov    %edx,%ebx
801018ac:	89 c1                	mov    %eax,%ecx
801018ae:	d3 e3                	shl    %cl,%ebx
801018b0:	89 d8                	mov    %ebx,%eax
801018b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801018b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b8:	8d 50 07             	lea    0x7(%eax),%edx
801018bb:	85 c0                	test   %eax,%eax
801018bd:	0f 48 c2             	cmovs  %edx,%eax
801018c0:	c1 f8 03             	sar    $0x3,%eax
801018c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018c6:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801018cb:	0f b6 c0             	movzbl %al,%eax
801018ce:	23 45 ec             	and    -0x14(%ebp),%eax
801018d1:	85 c0                	test   %eax,%eax
801018d3:	75 0c                	jne    801018e1 <bfree+0x97>
    panic("freeing free block");
801018d5:	c7 04 24 4b 8b 10 80 	movl   $0x80108b4b,(%esp)
801018dc:	e8 5c ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
801018e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e4:	8d 50 07             	lea    0x7(%eax),%edx
801018e7:	85 c0                	test   %eax,%eax
801018e9:	0f 48 c2             	cmovs  %edx,%eax
801018ec:	c1 f8 03             	sar    $0x3,%eax
801018ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018f2:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801018f7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801018fa:	f7 d1                	not    %ecx
801018fc:	21 ca                	and    %ecx,%edx
801018fe:	89 d1                	mov    %edx,%ecx
80101900:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101903:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	89 04 24             	mov    %eax,(%esp)
8010190d:	e8 1c 1d 00 00       	call   8010362e <log_write>
  brelse(bp);
80101912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101915:	89 04 24             	mov    %eax,(%esp)
80101918:	e8 fa e8 ff ff       	call   80100217 <brelse>
}
8010191d:	83 c4 34             	add    $0x34,%esp
80101920:	5b                   	pop    %ebx
80101921:	5d                   	pop    %ebp
80101922:	c3                   	ret    

80101923 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101923:	55                   	push   %ebp
80101924:	89 e5                	mov    %esp,%ebp
80101926:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101929:	c7 44 24 04 5e 8b 10 	movl   $0x80108b5e,0x4(%esp)
80101930:	80 
80101931:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101938:	e8 95 3a 00 00       	call   801053d2 <initlock>
}
8010193d:	c9                   	leave  
8010193e:	c3                   	ret    

8010193f <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010193f:	55                   	push   %ebp
80101940:	89 e5                	mov    %esp,%ebp
80101942:	83 ec 48             	sub    $0x48,%esp
80101945:	8b 45 0c             	mov    0xc(%ebp),%eax
80101948:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
8010194c:	8b 45 08             	mov    0x8(%ebp),%eax
8010194f:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101952:	89 54 24 04          	mov    %edx,0x4(%esp)
80101956:	89 04 24             	mov    %eax,(%esp)
80101959:	e8 fe fc ff ff       	call   8010165c <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
8010195e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101965:	e9 98 00 00 00       	jmp    80101a02 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
8010196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196d:	c1 e8 03             	shr    $0x3,%eax
80101970:	83 c0 02             	add    $0x2,%eax
80101973:	89 44 24 04          	mov    %eax,0x4(%esp)
80101977:	8b 45 08             	mov    0x8(%ebp),%eax
8010197a:	89 04 24             	mov    %eax,(%esp)
8010197d:	e8 24 e8 ff ff       	call   801001a6 <bread>
80101982:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101988:	8d 50 18             	lea    0x18(%eax),%edx
8010198b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198e:	83 e0 07             	and    $0x7,%eax
80101991:	c1 e0 06             	shl    $0x6,%eax
80101994:	01 d0                	add    %edx,%eax
80101996:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101999:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010199c:	0f b7 00             	movzwl (%eax),%eax
8010199f:	66 85 c0             	test   %ax,%ax
801019a2:	75 4f                	jne    801019f3 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
801019a4:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801019ab:	00 
801019ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801019b3:	00 
801019b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019b7:	89 04 24             	mov    %eax,(%esp)
801019ba:	e8 83 3c 00 00       	call   80105642 <memset>
      dip->type = type;
801019bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019c2:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801019c6:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801019c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cc:	89 04 24             	mov    %eax,(%esp)
801019cf:	e8 5a 1c 00 00       	call   8010362e <log_write>
      brelse(bp);
801019d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d7:	89 04 24             	mov    %eax,(%esp)
801019da:	e8 38 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801019df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
801019e9:	89 04 24             	mov    %eax,(%esp)
801019ec:	e8 e3 00 00 00       	call   80101ad4 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801019f1:	c9                   	leave  
801019f2:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f6:	89 04 24             	mov    %eax,(%esp)
801019f9:	e8 19 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801019fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101a05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101a08:	39 c2                	cmp    %eax,%edx
80101a0a:	0f 82 5a ff ff ff    	jb     8010196a <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101a10:	c7 04 24 65 8b 10 80 	movl   $0x80108b65,(%esp)
80101a17:	e8 21 eb ff ff       	call   8010053d <panic>

80101a1c <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a1c:	55                   	push   %ebp
80101a1d:	89 e5                	mov    %esp,%ebp
80101a1f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	8b 40 04             	mov    0x4(%eax),%eax
80101a28:	c1 e8 03             	shr    $0x3,%eax
80101a2b:	8d 50 02             	lea    0x2(%eax),%edx
80101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a31:	8b 00                	mov    (%eax),%eax
80101a33:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a37:	89 04 24             	mov    %eax,(%esp)
80101a3a:	e8 67 e7 ff ff       	call   801001a6 <bread>
80101a3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a45:	8d 50 18             	lea    0x18(%eax),%edx
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	8b 40 04             	mov    0x4(%eax),%eax
80101a4e:	83 e0 07             	and    $0x7,%eax
80101a51:	c1 e0 06             	shl    $0x6,%eax
80101a54:	01 d0                	add    %edx,%eax
80101a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a63:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a66:	8b 45 08             	mov    0x8(%ebp),%eax
80101a69:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a70:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a82:	8b 45 08             	mov    0x8(%ebp),%eax
80101a85:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a90:	8b 45 08             	mov    0x8(%ebp),%eax
80101a93:	8b 50 18             	mov    0x18(%eax),%edx
80101a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a99:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	8d 50 1c             	lea    0x1c(%eax),%edx
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	83 c0 0c             	add    $0xc,%eax
80101aa8:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101aaf:	00 
80101ab0:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ab4:	89 04 24             	mov    %eax,(%esp)
80101ab7:	e8 59 3c 00 00       	call   80105715 <memmove>
  log_write(bp);
80101abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abf:	89 04 24             	mov    %eax,(%esp)
80101ac2:	e8 67 1b 00 00       	call   8010362e <log_write>
  brelse(bp);
80101ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aca:	89 04 24             	mov    %eax,(%esp)
80101acd:	e8 45 e7 ff ff       	call   80100217 <brelse>
}
80101ad2:	c9                   	leave  
80101ad3:	c3                   	ret    

80101ad4 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101ad4:	55                   	push   %ebp
80101ad5:	89 e5                	mov    %esp,%ebp
80101ad7:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101ada:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101ae1:	e8 0d 39 00 00       	call   801053f3 <acquire>

  // Is the inode already cached?
  empty = 0;
80101ae6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101aed:	c7 45 f4 b4 f8 10 80 	movl   $0x8010f8b4,-0xc(%ebp)
80101af4:	eb 59                	jmp    80101b4f <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af9:	8b 40 08             	mov    0x8(%eax),%eax
80101afc:	85 c0                	test   %eax,%eax
80101afe:	7e 35                	jle    80101b35 <iget+0x61>
80101b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b03:	8b 00                	mov    (%eax),%eax
80101b05:	3b 45 08             	cmp    0x8(%ebp),%eax
80101b08:	75 2b                	jne    80101b35 <iget+0x61>
80101b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b0d:	8b 40 04             	mov    0x4(%eax),%eax
80101b10:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101b13:	75 20                	jne    80101b35 <iget+0x61>
      ip->ref++;
80101b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b18:	8b 40 08             	mov    0x8(%eax),%eax
80101b1b:	8d 50 01             	lea    0x1(%eax),%edx
80101b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b21:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101b24:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101b2b:	e8 25 39 00 00       	call   80105455 <release>
      return ip;
80101b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b33:	eb 6f                	jmp    80101ba4 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101b35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b39:	75 10                	jne    80101b4b <iget+0x77>
80101b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b3e:	8b 40 08             	mov    0x8(%eax),%eax
80101b41:	85 c0                	test   %eax,%eax
80101b43:	75 06                	jne    80101b4b <iget+0x77>
      empty = ip;
80101b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b48:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b4b:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101b4f:	81 7d f4 54 08 11 80 	cmpl   $0x80110854,-0xc(%ebp)
80101b56:	72 9e                	jb     80101af6 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101b58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b5c:	75 0c                	jne    80101b6a <iget+0x96>
    panic("iget: no inodes");
80101b5e:	c7 04 24 77 8b 10 80 	movl   $0x80108b77,(%esp)
80101b65:	e8 d3 e9 ff ff       	call   8010053d <panic>

  ip = empty;
80101b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b73:	8b 55 08             	mov    0x8(%ebp),%edx
80101b76:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b7e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b84:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b8e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b95:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101b9c:	e8 b4 38 00 00       	call   80105455 <release>

  return ip;
80101ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ba4:	c9                   	leave  
80101ba5:	c3                   	ret    

80101ba6 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101ba6:	55                   	push   %ebp
80101ba7:	89 e5                	mov    %esp,%ebp
80101ba9:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101bac:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101bb3:	e8 3b 38 00 00       	call   801053f3 <acquire>
  ip->ref++;
80101bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbb:	8b 40 08             	mov    0x8(%eax),%eax
80101bbe:	8d 50 01             	lea    0x1(%eax),%edx
80101bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc4:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bc7:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101bce:	e8 82 38 00 00       	call   80105455 <release>
  return ip;
80101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101bd6:	c9                   	leave  
80101bd7:	c3                   	ret    

80101bd8 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101bd8:	55                   	push   %ebp
80101bd9:	89 e5                	mov    %esp,%ebp
80101bdb:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101bde:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101be2:	74 0a                	je     80101bee <ilock+0x16>
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	8b 40 08             	mov    0x8(%eax),%eax
80101bea:	85 c0                	test   %eax,%eax
80101bec:	7f 0c                	jg     80101bfa <ilock+0x22>
    panic("ilock");
80101bee:	c7 04 24 87 8b 10 80 	movl   $0x80108b87,(%esp)
80101bf5:	e8 43 e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101bfa:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101c01:	e8 ed 37 00 00       	call   801053f3 <acquire>
  while(ip->flags & I_BUSY)
80101c06:	eb 13                	jmp    80101c1b <ilock+0x43>
    sleep(ip, &icache.lock);
80101c08:	c7 44 24 04 80 f8 10 	movl   $0x8010f880,0x4(%esp)
80101c0f:	80 
80101c10:	8b 45 08             	mov    0x8(%ebp),%eax
80101c13:	89 04 24             	mov    %eax,(%esp)
80101c16:	e8 6c 34 00 00       	call   80105087 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	8b 40 0c             	mov    0xc(%eax),%eax
80101c21:	83 e0 01             	and    $0x1,%eax
80101c24:	84 c0                	test   %al,%al
80101c26:	75 e0                	jne    80101c08 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101c28:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2b:	8b 40 0c             	mov    0xc(%eax),%eax
80101c2e:	89 c2                	mov    %eax,%edx
80101c30:	83 ca 01             	or     $0x1,%edx
80101c33:	8b 45 08             	mov    0x8(%ebp),%eax
80101c36:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101c39:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101c40:	e8 10 38 00 00       	call   80105455 <release>

  if(!(ip->flags & I_VALID)){
80101c45:	8b 45 08             	mov    0x8(%ebp),%eax
80101c48:	8b 40 0c             	mov    0xc(%eax),%eax
80101c4b:	83 e0 02             	and    $0x2,%eax
80101c4e:	85 c0                	test   %eax,%eax
80101c50:	0f 85 ce 00 00 00    	jne    80101d24 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	8b 40 04             	mov    0x4(%eax),%eax
80101c5c:	c1 e8 03             	shr    $0x3,%eax
80101c5f:	8d 50 02             	lea    0x2(%eax),%edx
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c6b:	89 04 24             	mov    %eax,(%esp)
80101c6e:	e8 33 e5 ff ff       	call   801001a6 <bread>
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c79:	8d 50 18             	lea    0x18(%eax),%edx
80101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7f:	8b 40 04             	mov    0x4(%eax),%eax
80101c82:	83 e0 07             	and    $0x7,%eax
80101c85:	c1 e0 06             	shl    $0x6,%eax
80101c88:	01 d0                	add    %edx,%eax
80101c8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c90:	0f b7 10             	movzwl (%eax),%edx
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c9d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca4:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cab:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc0:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc7:	8b 50 08             	mov    0x8(%eax),%edx
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd3:	8d 50 0c             	lea    0xc(%eax),%edx
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	83 c0 1c             	add    $0x1c,%eax
80101cdc:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101ce3:	00 
80101ce4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce8:	89 04 24             	mov    %eax,(%esp)
80101ceb:	e8 25 3a 00 00       	call   80105715 <memmove>
    brelse(bp);
80101cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf3:	89 04 24             	mov    %eax,(%esp)
80101cf6:	e8 1c e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfe:	8b 40 0c             	mov    0xc(%eax),%eax
80101d01:	89 c2                	mov    %eax,%edx
80101d03:	83 ca 02             	or     $0x2,%edx
80101d06:	8b 45 08             	mov    0x8(%ebp),%eax
80101d09:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d13:	66 85 c0             	test   %ax,%ax
80101d16:	75 0c                	jne    80101d24 <ilock+0x14c>
      panic("ilock: no type");
80101d18:	c7 04 24 8d 8b 10 80 	movl   $0x80108b8d,(%esp)
80101d1f:	e8 19 e8 ff ff       	call   8010053d <panic>
  }
}
80101d24:	c9                   	leave  
80101d25:	c3                   	ret    

80101d26 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101d26:	55                   	push   %ebp
80101d27:	89 e5                	mov    %esp,%ebp
80101d29:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101d2c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101d30:	74 17                	je     80101d49 <iunlock+0x23>
80101d32:	8b 45 08             	mov    0x8(%ebp),%eax
80101d35:	8b 40 0c             	mov    0xc(%eax),%eax
80101d38:	83 e0 01             	and    $0x1,%eax
80101d3b:	85 c0                	test   %eax,%eax
80101d3d:	74 0a                	je     80101d49 <iunlock+0x23>
80101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d42:	8b 40 08             	mov    0x8(%eax),%eax
80101d45:	85 c0                	test   %eax,%eax
80101d47:	7f 0c                	jg     80101d55 <iunlock+0x2f>
    panic("iunlock");
80101d49:	c7 04 24 9c 8b 10 80 	movl   $0x80108b9c,(%esp)
80101d50:	e8 e8 e7 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101d55:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101d5c:	e8 92 36 00 00       	call   801053f3 <acquire>
  ip->flags &= ~I_BUSY;
80101d61:	8b 45 08             	mov    0x8(%ebp),%eax
80101d64:	8b 40 0c             	mov    0xc(%eax),%eax
80101d67:	89 c2                	mov    %eax,%edx
80101d69:	83 e2 fe             	and    $0xfffffffe,%edx
80101d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6f:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	89 04 24             	mov    %eax,(%esp)
80101d78:	e8 e6 33 00 00       	call   80105163 <wakeup>
  release(&icache.lock);
80101d7d:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101d84:	e8 cc 36 00 00       	call   80105455 <release>
}
80101d89:	c9                   	leave  
80101d8a:	c3                   	ret    

80101d8b <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d8b:	55                   	push   %ebp
80101d8c:	89 e5                	mov    %esp,%ebp
80101d8e:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d91:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101d98:	e8 56 36 00 00       	call   801053f3 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101da0:	8b 40 08             	mov    0x8(%eax),%eax
80101da3:	83 f8 01             	cmp    $0x1,%eax
80101da6:	0f 85 93 00 00 00    	jne    80101e3f <iput+0xb4>
80101dac:	8b 45 08             	mov    0x8(%ebp),%eax
80101daf:	8b 40 0c             	mov    0xc(%eax),%eax
80101db2:	83 e0 02             	and    $0x2,%eax
80101db5:	85 c0                	test   %eax,%eax
80101db7:	0f 84 82 00 00 00    	je     80101e3f <iput+0xb4>
80101dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101dc4:	66 85 c0             	test   %ax,%ax
80101dc7:	75 76                	jne    80101e3f <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcc:	8b 40 0c             	mov    0xc(%eax),%eax
80101dcf:	83 e0 01             	and    $0x1,%eax
80101dd2:	84 c0                	test   %al,%al
80101dd4:	74 0c                	je     80101de2 <iput+0x57>
      panic("iput busy");
80101dd6:	c7 04 24 a4 8b 10 80 	movl   $0x80108ba4,(%esp)
80101ddd:	e8 5b e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 40 0c             	mov    0xc(%eax),%eax
80101de8:	89 c2                	mov    %eax,%edx
80101dea:	83 ca 01             	or     $0x1,%edx
80101ded:	8b 45 08             	mov    0x8(%ebp),%eax
80101df0:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101df3:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101dfa:	e8 56 36 00 00       	call   80105455 <release>
    itrunc(ip);
80101dff:	8b 45 08             	mov    0x8(%ebp),%eax
80101e02:	89 04 24             	mov    %eax,(%esp)
80101e05:	e8 72 01 00 00       	call   80101f7c <itrunc>
    ip->type = 0;
80101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0d:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101e13:	8b 45 08             	mov    0x8(%ebp),%eax
80101e16:	89 04 24             	mov    %eax,(%esp)
80101e19:	e8 fe fb ff ff       	call   80101a1c <iupdate>
    acquire(&icache.lock);
80101e1e:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101e25:	e8 c9 35 00 00       	call   801053f3 <acquire>
    ip->flags = 0;
80101e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101e34:	8b 45 08             	mov    0x8(%ebp),%eax
80101e37:	89 04 24             	mov    %eax,(%esp)
80101e3a:	e8 24 33 00 00       	call   80105163 <wakeup>
  }
  ip->ref--;
80101e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e42:	8b 40 08             	mov    0x8(%eax),%eax
80101e45:	8d 50 ff             	lea    -0x1(%eax),%edx
80101e48:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4b:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101e4e:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80101e55:	e8 fb 35 00 00       	call   80105455 <release>
}
80101e5a:	c9                   	leave  
80101e5b:	c3                   	ret    

80101e5c <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101e5c:	55                   	push   %ebp
80101e5d:	89 e5                	mov    %esp,%ebp
80101e5f:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101e62:	8b 45 08             	mov    0x8(%ebp),%eax
80101e65:	89 04 24             	mov    %eax,(%esp)
80101e68:	e8 b9 fe ff ff       	call   80101d26 <iunlock>
  iput(ip);
80101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e70:	89 04 24             	mov    %eax,(%esp)
80101e73:	e8 13 ff ff ff       	call   80101d8b <iput>
}
80101e78:	c9                   	leave  
80101e79:	c3                   	ret    

80101e7a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e7a:	55                   	push   %ebp
80101e7b:	89 e5                	mov    %esp,%ebp
80101e7d:	53                   	push   %ebx
80101e7e:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e81:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e85:	77 3e                	ja     80101ec5 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e8d:	83 c2 04             	add    $0x4,%edx
80101e90:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e94:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e9b:	75 20                	jne    80101ebd <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea0:	8b 00                	mov    (%eax),%eax
80101ea2:	89 04 24             	mov    %eax,(%esp)
80101ea5:	e8 49 f8 ff ff       	call   801016f3 <balloc>
80101eaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	8b 55 0c             	mov    0xc(%ebp),%edx
80101eb3:	8d 4a 04             	lea    0x4(%edx),%ecx
80101eb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eb9:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ec0:	e9 b1 00 00 00       	jmp    80101f76 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101ec5:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ec9:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ecd:	0f 87 97 00 00 00    	ja     80101f6a <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ed3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed6:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ed9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101edc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ee0:	75 19                	jne    80101efb <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	8b 00                	mov    (%eax),%eax
80101ee7:	89 04 24             	mov    %eax,(%esp)
80101eea:	e8 04 f8 ff ff       	call   801016f3 <balloc>
80101eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ef8:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101efb:	8b 45 08             	mov    0x8(%ebp),%eax
80101efe:	8b 00                	mov    (%eax),%eax
80101f00:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f03:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f07:	89 04 24             	mov    %eax,(%esp)
80101f0a:	e8 97 e2 ff ff       	call   801001a6 <bread>
80101f0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f15:	83 c0 18             	add    $0x18,%eax
80101f18:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f1e:	c1 e0 02             	shl    $0x2,%eax
80101f21:	03 45 ec             	add    -0x14(%ebp),%eax
80101f24:	8b 00                	mov    (%eax),%eax
80101f26:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f2d:	75 2b                	jne    80101f5a <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f32:	c1 e0 02             	shl    $0x2,%eax
80101f35:	89 c3                	mov    %eax,%ebx
80101f37:	03 5d ec             	add    -0x14(%ebp),%ebx
80101f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3d:	8b 00                	mov    (%eax),%eax
80101f3f:	89 04 24             	mov    %eax,(%esp)
80101f42:	e8 ac f7 ff ff       	call   801016f3 <balloc>
80101f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f4d:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f52:	89 04 24             	mov    %eax,(%esp)
80101f55:	e8 d4 16 00 00       	call   8010362e <log_write>
    }
    brelse(bp);
80101f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f5d:	89 04 24             	mov    %eax,(%esp)
80101f60:	e8 b2 e2 ff ff       	call   80100217 <brelse>
    return addr;
80101f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f68:	eb 0c                	jmp    80101f76 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101f6a:	c7 04 24 ae 8b 10 80 	movl   $0x80108bae,(%esp)
80101f71:	e8 c7 e5 ff ff       	call   8010053d <panic>
}
80101f76:	83 c4 24             	add    $0x24,%esp
80101f79:	5b                   	pop    %ebx
80101f7a:	5d                   	pop    %ebp
80101f7b:	c3                   	ret    

80101f7c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f7c:	55                   	push   %ebp
80101f7d:	89 e5                	mov    %esp,%ebp
80101f7f:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f89:	eb 44                	jmp    80101fcf <itrunc+0x53>
    if(ip->addrs[i]){
80101f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f91:	83 c2 04             	add    $0x4,%edx
80101f94:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f98:	85 c0                	test   %eax,%eax
80101f9a:	74 2f                	je     80101fcb <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fa2:	83 c2 04             	add    $0x4,%edx
80101fa5:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fac:	8b 00                	mov    (%eax),%eax
80101fae:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fb2:	89 04 24             	mov    %eax,(%esp)
80101fb5:	e8 90 f8 ff ff       	call   8010184a <bfree>
      ip->addrs[i] = 0;
80101fba:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fc0:	83 c2 04             	add    $0x4,%edx
80101fc3:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101fca:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101fcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101fcf:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101fd3:	7e b6                	jle    80101f8b <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fdb:	85 c0                	test   %eax,%eax
80101fdd:	0f 84 8f 00 00 00    	je     80102072 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe6:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	8b 00                	mov    (%eax),%eax
80101fee:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ff2:	89 04 24             	mov    %eax,(%esp)
80101ff5:	e8 ac e1 ff ff       	call   801001a6 <bread>
80101ffa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102000:	83 c0 18             	add    $0x18,%eax
80102003:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80102006:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010200d:	eb 2f                	jmp    8010203e <itrunc+0xc2>
      if(a[j])
8010200f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102012:	c1 e0 02             	shl    $0x2,%eax
80102015:	03 45 e8             	add    -0x18(%ebp),%eax
80102018:	8b 00                	mov    (%eax),%eax
8010201a:	85 c0                	test   %eax,%eax
8010201c:	74 1c                	je     8010203a <itrunc+0xbe>
        bfree(ip->dev, a[j]);
8010201e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102021:	c1 e0 02             	shl    $0x2,%eax
80102024:	03 45 e8             	add    -0x18(%ebp),%eax
80102027:	8b 10                	mov    (%eax),%edx
80102029:	8b 45 08             	mov    0x8(%ebp),%eax
8010202c:	8b 00                	mov    (%eax),%eax
8010202e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102032:	89 04 24             	mov    %eax,(%esp)
80102035:	e8 10 f8 ff ff       	call   8010184a <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
8010203a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010203e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102041:	83 f8 7f             	cmp    $0x7f,%eax
80102044:	76 c9                	jbe    8010200f <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80102046:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102049:	89 04 24             	mov    %eax,(%esp)
8010204c:	e8 c6 e1 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102051:	8b 45 08             	mov    0x8(%ebp),%eax
80102054:	8b 50 4c             	mov    0x4c(%eax),%edx
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	8b 00                	mov    (%eax),%eax
8010205c:	89 54 24 04          	mov    %edx,0x4(%esp)
80102060:	89 04 24             	mov    %eax,(%esp)
80102063:	e8 e2 f7 ff ff       	call   8010184a <bfree>
    ip->addrs[NDIRECT] = 0;
80102068:	8b 45 08             	mov    0x8(%ebp),%eax
8010206b:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102072:	8b 45 08             	mov    0x8(%ebp),%eax
80102075:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	89 04 24             	mov    %eax,(%esp)
80102082:	e8 95 f9 ff ff       	call   80101a1c <iupdate>
}
80102087:	c9                   	leave  
80102088:	c3                   	ret    

80102089 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102089:	55                   	push   %ebp
8010208a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010208c:	8b 45 08             	mov    0x8(%ebp),%eax
8010208f:	8b 00                	mov    (%eax),%eax
80102091:	89 c2                	mov    %eax,%edx
80102093:	8b 45 0c             	mov    0xc(%ebp),%eax
80102096:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102099:	8b 45 08             	mov    0x8(%ebp),%eax
8010209c:	8b 50 04             	mov    0x4(%eax),%edx
8010209f:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a2:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
801020a5:	8b 45 08             	mov    0x8(%ebp),%eax
801020a8:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801020ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801020af:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801020b2:	8b 45 08             	mov    0x8(%ebp),%eax
801020b5:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801020b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801020bc:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801020c0:	8b 45 08             	mov    0x8(%ebp),%eax
801020c3:	8b 50 18             	mov    0x18(%eax),%edx
801020c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801020c9:	89 50 10             	mov    %edx,0x10(%eax)
}
801020cc:	5d                   	pop    %ebp
801020cd:	c3                   	ret    

801020ce <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801020ce:	55                   	push   %ebp
801020cf:	89 e5                	mov    %esp,%ebp
801020d1:	53                   	push   %ebx
801020d2:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020d5:	8b 45 08             	mov    0x8(%ebp),%eax
801020d8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020dc:	66 83 f8 03          	cmp    $0x3,%ax
801020e0:	75 60                	jne    80102142 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020e9:	66 85 c0             	test   %ax,%ax
801020ec:	78 20                	js     8010210e <readi+0x40>
801020ee:	8b 45 08             	mov    0x8(%ebp),%eax
801020f1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020f5:	66 83 f8 09          	cmp    $0x9,%ax
801020f9:	7f 13                	jg     8010210e <readi+0x40>
801020fb:	8b 45 08             	mov    0x8(%ebp),%eax
801020fe:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102102:	98                   	cwtl   
80102103:	8b 04 c5 20 f8 10 80 	mov    -0x7fef07e0(,%eax,8),%eax
8010210a:	85 c0                	test   %eax,%eax
8010210c:	75 0a                	jne    80102118 <readi+0x4a>
      return -1;
8010210e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102113:	e9 1b 01 00 00       	jmp    80102233 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80102118:	8b 45 08             	mov    0x8(%ebp),%eax
8010211b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010211f:	98                   	cwtl   
80102120:	8b 14 c5 20 f8 10 80 	mov    -0x7fef07e0(,%eax,8),%edx
80102127:	8b 45 14             	mov    0x14(%ebp),%eax
8010212a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010212e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102131:	89 44 24 04          	mov    %eax,0x4(%esp)
80102135:	8b 45 08             	mov    0x8(%ebp),%eax
80102138:	89 04 24             	mov    %eax,(%esp)
8010213b:	ff d2                	call   *%edx
8010213d:	e9 f1 00 00 00       	jmp    80102233 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80102142:	8b 45 08             	mov    0x8(%ebp),%eax
80102145:	8b 40 18             	mov    0x18(%eax),%eax
80102148:	3b 45 10             	cmp    0x10(%ebp),%eax
8010214b:	72 0d                	jb     8010215a <readi+0x8c>
8010214d:	8b 45 14             	mov    0x14(%ebp),%eax
80102150:	8b 55 10             	mov    0x10(%ebp),%edx
80102153:	01 d0                	add    %edx,%eax
80102155:	3b 45 10             	cmp    0x10(%ebp),%eax
80102158:	73 0a                	jae    80102164 <readi+0x96>
    return -1;
8010215a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010215f:	e9 cf 00 00 00       	jmp    80102233 <readi+0x165>
  if(off + n > ip->size)
80102164:	8b 45 14             	mov    0x14(%ebp),%eax
80102167:	8b 55 10             	mov    0x10(%ebp),%edx
8010216a:	01 c2                	add    %eax,%edx
8010216c:	8b 45 08             	mov    0x8(%ebp),%eax
8010216f:	8b 40 18             	mov    0x18(%eax),%eax
80102172:	39 c2                	cmp    %eax,%edx
80102174:	76 0c                	jbe    80102182 <readi+0xb4>
    n = ip->size - off;
80102176:	8b 45 08             	mov    0x8(%ebp),%eax
80102179:	8b 40 18             	mov    0x18(%eax),%eax
8010217c:	2b 45 10             	sub    0x10(%ebp),%eax
8010217f:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102182:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102189:	e9 96 00 00 00       	jmp    80102224 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010218e:	8b 45 10             	mov    0x10(%ebp),%eax
80102191:	c1 e8 09             	shr    $0x9,%eax
80102194:	89 44 24 04          	mov    %eax,0x4(%esp)
80102198:	8b 45 08             	mov    0x8(%ebp),%eax
8010219b:	89 04 24             	mov    %eax,(%esp)
8010219e:	e8 d7 fc ff ff       	call   80101e7a <bmap>
801021a3:	8b 55 08             	mov    0x8(%ebp),%edx
801021a6:	8b 12                	mov    (%edx),%edx
801021a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ac:	89 14 24             	mov    %edx,(%esp)
801021af:	e8 f2 df ff ff       	call   801001a6 <bread>
801021b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021b7:	8b 45 10             	mov    0x10(%ebp),%eax
801021ba:	89 c2                	mov    %eax,%edx
801021bc:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801021c2:	b8 00 02 00 00       	mov    $0x200,%eax
801021c7:	89 c1                	mov    %eax,%ecx
801021c9:	29 d1                	sub    %edx,%ecx
801021cb:	89 ca                	mov    %ecx,%edx
801021cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021d0:	8b 4d 14             	mov    0x14(%ebp),%ecx
801021d3:	89 cb                	mov    %ecx,%ebx
801021d5:	29 c3                	sub    %eax,%ebx
801021d7:	89 d8                	mov    %ebx,%eax
801021d9:	39 c2                	cmp    %eax,%edx
801021db:	0f 46 c2             	cmovbe %edx,%eax
801021de:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801021e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e4:	8d 50 18             	lea    0x18(%eax),%edx
801021e7:	8b 45 10             	mov    0x10(%ebp),%eax
801021ea:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ef:	01 c2                	add    %eax,%edx
801021f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021f4:	89 44 24 08          	mov    %eax,0x8(%esp)
801021f8:	89 54 24 04          	mov    %edx,0x4(%esp)
801021fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801021ff:	89 04 24             	mov    %eax,(%esp)
80102202:	e8 0e 35 00 00       	call   80105715 <memmove>
    brelse(bp);
80102207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010220a:	89 04 24             	mov    %eax,(%esp)
8010220d:	e8 05 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102212:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102215:	01 45 f4             	add    %eax,-0xc(%ebp)
80102218:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221b:	01 45 10             	add    %eax,0x10(%ebp)
8010221e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102221:	01 45 0c             	add    %eax,0xc(%ebp)
80102224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102227:	3b 45 14             	cmp    0x14(%ebp),%eax
8010222a:	0f 82 5e ff ff ff    	jb     8010218e <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102230:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102233:	83 c4 24             	add    $0x24,%esp
80102236:	5b                   	pop    %ebx
80102237:	5d                   	pop    %ebp
80102238:	c3                   	ret    

80102239 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102239:	55                   	push   %ebp
8010223a:	89 e5                	mov    %esp,%ebp
8010223c:	53                   	push   %ebx
8010223d:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102247:	66 83 f8 03          	cmp    $0x3,%ax
8010224b:	75 60                	jne    801022ad <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010224d:	8b 45 08             	mov    0x8(%ebp),%eax
80102250:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102254:	66 85 c0             	test   %ax,%ax
80102257:	78 20                	js     80102279 <writei+0x40>
80102259:	8b 45 08             	mov    0x8(%ebp),%eax
8010225c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102260:	66 83 f8 09          	cmp    $0x9,%ax
80102264:	7f 13                	jg     80102279 <writei+0x40>
80102266:	8b 45 08             	mov    0x8(%ebp),%eax
80102269:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010226d:	98                   	cwtl   
8010226e:	8b 04 c5 24 f8 10 80 	mov    -0x7fef07dc(,%eax,8),%eax
80102275:	85 c0                	test   %eax,%eax
80102277:	75 0a                	jne    80102283 <writei+0x4a>
      return -1;
80102279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010227e:	e9 46 01 00 00       	jmp    801023c9 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80102283:	8b 45 08             	mov    0x8(%ebp),%eax
80102286:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010228a:	98                   	cwtl   
8010228b:	8b 14 c5 24 f8 10 80 	mov    -0x7fef07dc(,%eax,8),%edx
80102292:	8b 45 14             	mov    0x14(%ebp),%eax
80102295:	89 44 24 08          	mov    %eax,0x8(%esp)
80102299:	8b 45 0c             	mov    0xc(%ebp),%eax
8010229c:	89 44 24 04          	mov    %eax,0x4(%esp)
801022a0:	8b 45 08             	mov    0x8(%ebp),%eax
801022a3:	89 04 24             	mov    %eax,(%esp)
801022a6:	ff d2                	call   *%edx
801022a8:	e9 1c 01 00 00       	jmp    801023c9 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
801022ad:	8b 45 08             	mov    0x8(%ebp),%eax
801022b0:	8b 40 18             	mov    0x18(%eax),%eax
801022b3:	3b 45 10             	cmp    0x10(%ebp),%eax
801022b6:	72 0d                	jb     801022c5 <writei+0x8c>
801022b8:	8b 45 14             	mov    0x14(%ebp),%eax
801022bb:	8b 55 10             	mov    0x10(%ebp),%edx
801022be:	01 d0                	add    %edx,%eax
801022c0:	3b 45 10             	cmp    0x10(%ebp),%eax
801022c3:	73 0a                	jae    801022cf <writei+0x96>
    return -1;
801022c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022ca:	e9 fa 00 00 00       	jmp    801023c9 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
801022cf:	8b 45 14             	mov    0x14(%ebp),%eax
801022d2:	8b 55 10             	mov    0x10(%ebp),%edx
801022d5:	01 d0                	add    %edx,%eax
801022d7:	3d 00 18 01 00       	cmp    $0x11800,%eax
801022dc:	76 0a                	jbe    801022e8 <writei+0xaf>
    return -1;
801022de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022e3:	e9 e1 00 00 00       	jmp    801023c9 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022ef:	e9 a1 00 00 00       	jmp    80102395 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022f4:	8b 45 10             	mov    0x10(%ebp),%eax
801022f7:	c1 e8 09             	shr    $0x9,%eax
801022fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801022fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102301:	89 04 24             	mov    %eax,(%esp)
80102304:	e8 71 fb ff ff       	call   80101e7a <bmap>
80102309:	8b 55 08             	mov    0x8(%ebp),%edx
8010230c:	8b 12                	mov    (%edx),%edx
8010230e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102312:	89 14 24             	mov    %edx,(%esp)
80102315:	e8 8c de ff ff       	call   801001a6 <bread>
8010231a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010231d:	8b 45 10             	mov    0x10(%ebp),%eax
80102320:	89 c2                	mov    %eax,%edx
80102322:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102328:	b8 00 02 00 00       	mov    $0x200,%eax
8010232d:	89 c1                	mov    %eax,%ecx
8010232f:	29 d1                	sub    %edx,%ecx
80102331:	89 ca                	mov    %ecx,%edx
80102333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102336:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102339:	89 cb                	mov    %ecx,%ebx
8010233b:	29 c3                	sub    %eax,%ebx
8010233d:	89 d8                	mov    %ebx,%eax
8010233f:	39 c2                	cmp    %eax,%edx
80102341:	0f 46 c2             	cmovbe %edx,%eax
80102344:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102347:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010234a:	8d 50 18             	lea    0x18(%eax),%edx
8010234d:	8b 45 10             	mov    0x10(%ebp),%eax
80102350:	25 ff 01 00 00       	and    $0x1ff,%eax
80102355:	01 c2                	add    %eax,%edx
80102357:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010235a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010235e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102361:	89 44 24 04          	mov    %eax,0x4(%esp)
80102365:	89 14 24             	mov    %edx,(%esp)
80102368:	e8 a8 33 00 00       	call   80105715 <memmove>
    log_write(bp);
8010236d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102370:	89 04 24             	mov    %eax,(%esp)
80102373:	e8 b6 12 00 00       	call   8010362e <log_write>
    brelse(bp);
80102378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010237b:	89 04 24             	mov    %eax,(%esp)
8010237e:	e8 94 de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102383:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102386:	01 45 f4             	add    %eax,-0xc(%ebp)
80102389:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010238c:	01 45 10             	add    %eax,0x10(%ebp)
8010238f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102392:	01 45 0c             	add    %eax,0xc(%ebp)
80102395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102398:	3b 45 14             	cmp    0x14(%ebp),%eax
8010239b:	0f 82 53 ff ff ff    	jb     801022f4 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801023a1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801023a5:	74 1f                	je     801023c6 <writei+0x18d>
801023a7:	8b 45 08             	mov    0x8(%ebp),%eax
801023aa:	8b 40 18             	mov    0x18(%eax),%eax
801023ad:	3b 45 10             	cmp    0x10(%ebp),%eax
801023b0:	73 14                	jae    801023c6 <writei+0x18d>
    ip->size = off;
801023b2:	8b 45 08             	mov    0x8(%ebp),%eax
801023b5:	8b 55 10             	mov    0x10(%ebp),%edx
801023b8:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801023bb:	8b 45 08             	mov    0x8(%ebp),%eax
801023be:	89 04 24             	mov    %eax,(%esp)
801023c1:	e8 56 f6 ff ff       	call   80101a1c <iupdate>
  }
  return n;
801023c6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023c9:	83 c4 24             	add    $0x24,%esp
801023cc:	5b                   	pop    %ebx
801023cd:	5d                   	pop    %ebp
801023ce:	c3                   	ret    

801023cf <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801023cf:	55                   	push   %ebp
801023d0:	89 e5                	mov    %esp,%ebp
801023d2:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801023d5:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023dc:	00 
801023dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e4:	8b 45 08             	mov    0x8(%ebp),%eax
801023e7:	89 04 24             	mov    %eax,(%esp)
801023ea:	e8 ca 33 00 00       	call   801057b9 <strncmp>
}
801023ef:	c9                   	leave  
801023f0:	c3                   	ret    

801023f1 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023f1:	55                   	push   %ebp
801023f2:	89 e5                	mov    %esp,%ebp
801023f4:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023fe:	66 83 f8 01          	cmp    $0x1,%ax
80102402:	74 0c                	je     80102410 <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102404:	c7 04 24 c1 8b 10 80 	movl   $0x80108bc1,(%esp)
8010240b:	e8 2d e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102410:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102417:	e9 87 00 00 00       	jmp    801024a3 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010241c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102423:	00 
80102424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102427:	89 44 24 08          	mov    %eax,0x8(%esp)
8010242b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010242e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102432:	8b 45 08             	mov    0x8(%ebp),%eax
80102435:	89 04 24             	mov    %eax,(%esp)
80102438:	e8 91 fc ff ff       	call   801020ce <readi>
8010243d:	83 f8 10             	cmp    $0x10,%eax
80102440:	74 0c                	je     8010244e <dirlookup+0x5d>
      panic("dirlink read");
80102442:	c7 04 24 d3 8b 10 80 	movl   $0x80108bd3,(%esp)
80102449:	e8 ef e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
8010244e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102452:	66 85 c0             	test   %ax,%ax
80102455:	74 47                	je     8010249e <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
80102457:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010245a:	83 c0 02             	add    $0x2,%eax
8010245d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102461:	8b 45 0c             	mov    0xc(%ebp),%eax
80102464:	89 04 24             	mov    %eax,(%esp)
80102467:	e8 63 ff ff ff       	call   801023cf <namecmp>
8010246c:	85 c0                	test   %eax,%eax
8010246e:	75 2f                	jne    8010249f <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102470:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102474:	74 08                	je     8010247e <dirlookup+0x8d>
        *poff = off;
80102476:	8b 45 10             	mov    0x10(%ebp),%eax
80102479:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010247c:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010247e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102482:	0f b7 c0             	movzwl %ax,%eax
80102485:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102488:	8b 45 08             	mov    0x8(%ebp),%eax
8010248b:	8b 00                	mov    (%eax),%eax
8010248d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102490:	89 54 24 04          	mov    %edx,0x4(%esp)
80102494:	89 04 24             	mov    %eax,(%esp)
80102497:	e8 38 f6 ff ff       	call   80101ad4 <iget>
8010249c:	eb 19                	jmp    801024b7 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010249e:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010249f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801024a3:	8b 45 08             	mov    0x8(%ebp),%eax
801024a6:	8b 40 18             	mov    0x18(%eax),%eax
801024a9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801024ac:	0f 87 6a ff ff ff    	ja     8010241c <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801024b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024b7:	c9                   	leave  
801024b8:	c3                   	ret    

801024b9 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801024b9:	55                   	push   %ebp
801024ba:	89 e5                	mov    %esp,%ebp
801024bc:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801024bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024c6:	00 
801024c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	89 04 24             	mov    %eax,(%esp)
801024d4:	e8 18 ff ff ff       	call   801023f1 <dirlookup>
801024d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024e0:	74 15                	je     801024f7 <dirlink+0x3e>
    iput(ip);
801024e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e5:	89 04 24             	mov    %eax,(%esp)
801024e8:	e8 9e f8 ff ff       	call   80101d8b <iput>
    return -1;
801024ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024f2:	e9 b8 00 00 00       	jmp    801025af <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024fe:	eb 44                	jmp    80102544 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102503:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010250a:	00 
8010250b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010250f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102512:	89 44 24 04          	mov    %eax,0x4(%esp)
80102516:	8b 45 08             	mov    0x8(%ebp),%eax
80102519:	89 04 24             	mov    %eax,(%esp)
8010251c:	e8 ad fb ff ff       	call   801020ce <readi>
80102521:	83 f8 10             	cmp    $0x10,%eax
80102524:	74 0c                	je     80102532 <dirlink+0x79>
      panic("dirlink read");
80102526:	c7 04 24 d3 8b 10 80 	movl   $0x80108bd3,(%esp)
8010252d:	e8 0b e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102532:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102536:	66 85 c0             	test   %ax,%ax
80102539:	74 18                	je     80102553 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010253b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010253e:	83 c0 10             	add    $0x10,%eax
80102541:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102544:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102547:	8b 45 08             	mov    0x8(%ebp),%eax
8010254a:	8b 40 18             	mov    0x18(%eax),%eax
8010254d:	39 c2                	cmp    %eax,%edx
8010254f:	72 af                	jb     80102500 <dirlink+0x47>
80102551:	eb 01                	jmp    80102554 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102553:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102554:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010255b:	00 
8010255c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010255f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102563:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102566:	83 c0 02             	add    $0x2,%eax
80102569:	89 04 24             	mov    %eax,(%esp)
8010256c:	e8 a0 32 00 00       	call   80105811 <strncpy>
  de.inum = inum;
80102571:	8b 45 10             	mov    0x10(%ebp),%eax
80102574:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010257b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102582:	00 
80102583:	89 44 24 08          	mov    %eax,0x8(%esp)
80102587:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010258a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010258e:	8b 45 08             	mov    0x8(%ebp),%eax
80102591:	89 04 24             	mov    %eax,(%esp)
80102594:	e8 a0 fc ff ff       	call   80102239 <writei>
80102599:	83 f8 10             	cmp    $0x10,%eax
8010259c:	74 0c                	je     801025aa <dirlink+0xf1>
    panic("dirlink");
8010259e:	c7 04 24 e0 8b 10 80 	movl   $0x80108be0,(%esp)
801025a5:	e8 93 df ff ff       	call   8010053d <panic>
  
  return 0;
801025aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025af:	c9                   	leave  
801025b0:	c3                   	ret    

801025b1 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801025b1:	55                   	push   %ebp
801025b2:	89 e5                	mov    %esp,%ebp
801025b4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801025b7:	eb 04                	jmp    801025bd <skipelem+0xc>
    path++;
801025b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801025bd:	8b 45 08             	mov    0x8(%ebp),%eax
801025c0:	0f b6 00             	movzbl (%eax),%eax
801025c3:	3c 2f                	cmp    $0x2f,%al
801025c5:	74 f2                	je     801025b9 <skipelem+0x8>
    path++;
  if(*path == 0)
801025c7:	8b 45 08             	mov    0x8(%ebp),%eax
801025ca:	0f b6 00             	movzbl (%eax),%eax
801025cd:	84 c0                	test   %al,%al
801025cf:	75 0a                	jne    801025db <skipelem+0x2a>
    return 0;
801025d1:	b8 00 00 00 00       	mov    $0x0,%eax
801025d6:	e9 86 00 00 00       	jmp    80102661 <skipelem+0xb0>
  s = path;
801025db:	8b 45 08             	mov    0x8(%ebp),%eax
801025de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801025e1:	eb 04                	jmp    801025e7 <skipelem+0x36>
    path++;
801025e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801025e7:	8b 45 08             	mov    0x8(%ebp),%eax
801025ea:	0f b6 00             	movzbl (%eax),%eax
801025ed:	3c 2f                	cmp    $0x2f,%al
801025ef:	74 0a                	je     801025fb <skipelem+0x4a>
801025f1:	8b 45 08             	mov    0x8(%ebp),%eax
801025f4:	0f b6 00             	movzbl (%eax),%eax
801025f7:	84 c0                	test   %al,%al
801025f9:	75 e8                	jne    801025e3 <skipelem+0x32>
    path++;
  len = path - s;
801025fb:	8b 55 08             	mov    0x8(%ebp),%edx
801025fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102601:	89 d1                	mov    %edx,%ecx
80102603:	29 c1                	sub    %eax,%ecx
80102605:	89 c8                	mov    %ecx,%eax
80102607:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010260a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010260e:	7e 1c                	jle    8010262c <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
80102610:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102617:	00 
80102618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010261b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010261f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102622:	89 04 24             	mov    %eax,(%esp)
80102625:	e8 eb 30 00 00       	call   80105715 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010262a:	eb 28                	jmp    80102654 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
8010262c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010262f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102636:	89 44 24 04          	mov    %eax,0x4(%esp)
8010263a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010263d:	89 04 24             	mov    %eax,(%esp)
80102640:	e8 d0 30 00 00       	call   80105715 <memmove>
    name[len] = 0;
80102645:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102648:	03 45 0c             	add    0xc(%ebp),%eax
8010264b:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010264e:	eb 04                	jmp    80102654 <skipelem+0xa3>
    path++;
80102650:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102654:	8b 45 08             	mov    0x8(%ebp),%eax
80102657:	0f b6 00             	movzbl (%eax),%eax
8010265a:	3c 2f                	cmp    $0x2f,%al
8010265c:	74 f2                	je     80102650 <skipelem+0x9f>
    path++;
  return path;
8010265e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102661:	c9                   	leave  
80102662:	c3                   	ret    

80102663 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102663:	55                   	push   %ebp
80102664:	89 e5                	mov    %esp,%ebp
80102666:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102669:	8b 45 08             	mov    0x8(%ebp),%eax
8010266c:	0f b6 00             	movzbl (%eax),%eax
8010266f:	3c 2f                	cmp    $0x2f,%al
80102671:	75 1c                	jne    8010268f <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102673:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010267a:	00 
8010267b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102682:	e8 4d f4 ff ff       	call   80101ad4 <iget>
80102687:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010268a:	e9 af 00 00 00       	jmp    8010273e <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010268f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102695:	8b 40 68             	mov    0x68(%eax),%eax
80102698:	89 04 24             	mov    %eax,(%esp)
8010269b:	e8 06 f5 ff ff       	call   80101ba6 <idup>
801026a0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801026a3:	e9 96 00 00 00       	jmp    8010273e <namex+0xdb>
    ilock(ip);
801026a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ab:	89 04 24             	mov    %eax,(%esp)
801026ae:	e8 25 f5 ff ff       	call   80101bd8 <ilock>
    if(ip->type != T_DIR){
801026b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026b6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801026ba:	66 83 f8 01          	cmp    $0x1,%ax
801026be:	74 15                	je     801026d5 <namex+0x72>
      iunlockput(ip);
801026c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c3:	89 04 24             	mov    %eax,(%esp)
801026c6:	e8 91 f7 ff ff       	call   80101e5c <iunlockput>
      return 0;
801026cb:	b8 00 00 00 00       	mov    $0x0,%eax
801026d0:	e9 a3 00 00 00       	jmp    80102778 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801026d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026d9:	74 1d                	je     801026f8 <namex+0x95>
801026db:	8b 45 08             	mov    0x8(%ebp),%eax
801026de:	0f b6 00             	movzbl (%eax),%eax
801026e1:	84 c0                	test   %al,%al
801026e3:	75 13                	jne    801026f8 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801026e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e8:	89 04 24             	mov    %eax,(%esp)
801026eb:	e8 36 f6 ff ff       	call   80101d26 <iunlock>
      return ip;
801026f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f3:	e9 80 00 00 00       	jmp    80102778 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026ff:	00 
80102700:	8b 45 10             	mov    0x10(%ebp),%eax
80102703:	89 44 24 04          	mov    %eax,0x4(%esp)
80102707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010270a:	89 04 24             	mov    %eax,(%esp)
8010270d:	e8 df fc ff ff       	call   801023f1 <dirlookup>
80102712:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102715:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102719:	75 12                	jne    8010272d <namex+0xca>
      iunlockput(ip);
8010271b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271e:	89 04 24             	mov    %eax,(%esp)
80102721:	e8 36 f7 ff ff       	call   80101e5c <iunlockput>
      return 0;
80102726:	b8 00 00 00 00       	mov    $0x0,%eax
8010272b:	eb 4b                	jmp    80102778 <namex+0x115>
    }
    iunlockput(ip);
8010272d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102730:	89 04 24             	mov    %eax,(%esp)
80102733:	e8 24 f7 ff ff       	call   80101e5c <iunlockput>
    ip = next;
80102738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010273b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010273e:	8b 45 10             	mov    0x10(%ebp),%eax
80102741:	89 44 24 04          	mov    %eax,0x4(%esp)
80102745:	8b 45 08             	mov    0x8(%ebp),%eax
80102748:	89 04 24             	mov    %eax,(%esp)
8010274b:	e8 61 fe ff ff       	call   801025b1 <skipelem>
80102750:	89 45 08             	mov    %eax,0x8(%ebp)
80102753:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102757:	0f 85 4b ff ff ff    	jne    801026a8 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010275d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102761:	74 12                	je     80102775 <namex+0x112>
    iput(ip);
80102763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102766:	89 04 24             	mov    %eax,(%esp)
80102769:	e8 1d f6 ff ff       	call   80101d8b <iput>
    return 0;
8010276e:	b8 00 00 00 00       	mov    $0x0,%eax
80102773:	eb 03                	jmp    80102778 <namex+0x115>
  }
  return ip;
80102775:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102778:	c9                   	leave  
80102779:	c3                   	ret    

8010277a <namei>:

struct inode*
namei(char *path)
{
8010277a:	55                   	push   %ebp
8010277b:	89 e5                	mov    %esp,%ebp
8010277d:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102780:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102783:	89 44 24 08          	mov    %eax,0x8(%esp)
80102787:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010278e:	00 
8010278f:	8b 45 08             	mov    0x8(%ebp),%eax
80102792:	89 04 24             	mov    %eax,(%esp)
80102795:	e8 c9 fe ff ff       	call   80102663 <namex>
}
8010279a:	c9                   	leave  
8010279b:	c3                   	ret    

8010279c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010279c:	55                   	push   %ebp
8010279d:	89 e5                	mov    %esp,%ebp
8010279f:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801027a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801027a5:	89 44 24 08          	mov    %eax,0x8(%esp)
801027a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801027b0:	00 
801027b1:	8b 45 08             	mov    0x8(%ebp),%eax
801027b4:	89 04 24             	mov    %eax,(%esp)
801027b7:	e8 a7 fe ff ff       	call   80102663 <namex>
}
801027bc:	c9                   	leave  
801027bd:	c3                   	ret    
	...

801027c0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027c0:	55                   	push   %ebp
801027c1:	89 e5                	mov    %esp,%ebp
801027c3:	53                   	push   %ebx
801027c4:	83 ec 14             	sub    $0x14,%esp
801027c7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ca:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027ce:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801027d2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801027d6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801027da:	ec                   	in     (%dx),%al
801027db:	89 c3                	mov    %eax,%ebx
801027dd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801027e0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801027e4:	83 c4 14             	add    $0x14,%esp
801027e7:	5b                   	pop    %ebx
801027e8:	5d                   	pop    %ebp
801027e9:	c3                   	ret    

801027ea <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027ea:	55                   	push   %ebp
801027eb:	89 e5                	mov    %esp,%ebp
801027ed:	57                   	push   %edi
801027ee:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027ef:	8b 55 08             	mov    0x8(%ebp),%edx
801027f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027f5:	8b 45 10             	mov    0x10(%ebp),%eax
801027f8:	89 cb                	mov    %ecx,%ebx
801027fa:	89 df                	mov    %ebx,%edi
801027fc:	89 c1                	mov    %eax,%ecx
801027fe:	fc                   	cld    
801027ff:	f3 6d                	rep insl (%dx),%es:(%edi)
80102801:	89 c8                	mov    %ecx,%eax
80102803:	89 fb                	mov    %edi,%ebx
80102805:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102808:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010280b:	5b                   	pop    %ebx
8010280c:	5f                   	pop    %edi
8010280d:	5d                   	pop    %ebp
8010280e:	c3                   	ret    

8010280f <outb>:

static inline void
outb(ushort port, uchar data)
{
8010280f:	55                   	push   %ebp
80102810:	89 e5                	mov    %esp,%ebp
80102812:	83 ec 08             	sub    $0x8,%esp
80102815:	8b 55 08             	mov    0x8(%ebp),%edx
80102818:	8b 45 0c             	mov    0xc(%ebp),%eax
8010281b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010281f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102822:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102826:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010282a:	ee                   	out    %al,(%dx)
}
8010282b:	c9                   	leave  
8010282c:	c3                   	ret    

8010282d <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010282d:	55                   	push   %ebp
8010282e:	89 e5                	mov    %esp,%ebp
80102830:	56                   	push   %esi
80102831:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102832:	8b 55 08             	mov    0x8(%ebp),%edx
80102835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102838:	8b 45 10             	mov    0x10(%ebp),%eax
8010283b:	89 cb                	mov    %ecx,%ebx
8010283d:	89 de                	mov    %ebx,%esi
8010283f:	89 c1                	mov    %eax,%ecx
80102841:	fc                   	cld    
80102842:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102844:	89 c8                	mov    %ecx,%eax
80102846:	89 f3                	mov    %esi,%ebx
80102848:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010284b:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010284e:	5b                   	pop    %ebx
8010284f:	5e                   	pop    %esi
80102850:	5d                   	pop    %ebp
80102851:	c3                   	ret    

80102852 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102852:	55                   	push   %ebp
80102853:	89 e5                	mov    %esp,%ebp
80102855:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102858:	90                   	nop
80102859:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102860:	e8 5b ff ff ff       	call   801027c0 <inb>
80102865:	0f b6 c0             	movzbl %al,%eax
80102868:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010286b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286e:	25 c0 00 00 00       	and    $0xc0,%eax
80102873:	83 f8 40             	cmp    $0x40,%eax
80102876:	75 e1                	jne    80102859 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102878:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010287c:	74 11                	je     8010288f <idewait+0x3d>
8010287e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102881:	83 e0 21             	and    $0x21,%eax
80102884:	85 c0                	test   %eax,%eax
80102886:	74 07                	je     8010288f <idewait+0x3d>
    return -1;
80102888:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010288d:	eb 05                	jmp    80102894 <idewait+0x42>
  return 0;
8010288f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102894:	c9                   	leave  
80102895:	c3                   	ret    

80102896 <ideinit>:

void
ideinit(void)
{
80102896:	55                   	push   %ebp
80102897:	89 e5                	mov    %esp,%ebp
80102899:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010289c:	c7 44 24 04 e8 8b 10 	movl   $0x80108be8,0x4(%esp)
801028a3:	80 
801028a4:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801028ab:	e8 22 2b 00 00       	call   801053d2 <initlock>
  picenable(IRQ_IDE);
801028b0:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028b7:	e8 75 15 00 00       	call   80103e31 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028bc:	a1 20 0f 11 80       	mov    0x80110f20,%eax
801028c1:	83 e8 01             	sub    $0x1,%eax
801028c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801028c8:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028cf:	e8 12 04 00 00       	call   80102ce6 <ioapicenable>
  idewait(0);
801028d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028db:	e8 72 ff ff ff       	call   80102852 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801028e0:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028e7:	00 
801028e8:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028ef:	e8 1b ff ff ff       	call   8010280f <outb>
  for(i=0; i<1000; i++){
801028f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028fb:	eb 20                	jmp    8010291d <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028fd:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102904:	e8 b7 fe ff ff       	call   801027c0 <inb>
80102909:	84 c0                	test   %al,%al
8010290b:	74 0c                	je     80102919 <ideinit+0x83>
      havedisk1 = 1;
8010290d:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102914:	00 00 00 
      break;
80102917:	eb 0d                	jmp    80102926 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102919:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010291d:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102924:	7e d7                	jle    801028fd <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102926:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
8010292d:	00 
8010292e:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102935:	e8 d5 fe ff ff       	call   8010280f <outb>
}
8010293a:	c9                   	leave  
8010293b:	c3                   	ret    

8010293c <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010293c:	55                   	push   %ebp
8010293d:	89 e5                	mov    %esp,%ebp
8010293f:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102942:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102946:	75 0c                	jne    80102954 <idestart+0x18>
    panic("idestart");
80102948:	c7 04 24 ec 8b 10 80 	movl   $0x80108bec,(%esp)
8010294f:	e8 e9 db ff ff       	call   8010053d <panic>

  idewait(0);
80102954:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010295b:	e8 f2 fe ff ff       	call   80102852 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102960:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102967:	00 
80102968:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010296f:	e8 9b fe ff ff       	call   8010280f <outb>
  outb(0x1f2, 1);  // number of sectors
80102974:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010297b:	00 
8010297c:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102983:	e8 87 fe ff ff       	call   8010280f <outb>
  outb(0x1f3, b->sector & 0xff);
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	8b 40 08             	mov    0x8(%eax),%eax
8010298e:	0f b6 c0             	movzbl %al,%eax
80102991:	89 44 24 04          	mov    %eax,0x4(%esp)
80102995:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010299c:	e8 6e fe ff ff       	call   8010280f <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
801029a1:	8b 45 08             	mov    0x8(%ebp),%eax
801029a4:	8b 40 08             	mov    0x8(%eax),%eax
801029a7:	c1 e8 08             	shr    $0x8,%eax
801029aa:	0f b6 c0             	movzbl %al,%eax
801029ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b1:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029b8:	e8 52 fe ff ff       	call   8010280f <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801029bd:	8b 45 08             	mov    0x8(%ebp),%eax
801029c0:	8b 40 08             	mov    0x8(%eax),%eax
801029c3:	c1 e8 10             	shr    $0x10,%eax
801029c6:	0f b6 c0             	movzbl %al,%eax
801029c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801029cd:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029d4:	e8 36 fe ff ff       	call   8010280f <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801029d9:	8b 45 08             	mov    0x8(%ebp),%eax
801029dc:	8b 40 04             	mov    0x4(%eax),%eax
801029df:	83 e0 01             	and    $0x1,%eax
801029e2:	89 c2                	mov    %eax,%edx
801029e4:	c1 e2 04             	shl    $0x4,%edx
801029e7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ea:	8b 40 08             	mov    0x8(%eax),%eax
801029ed:	c1 e8 18             	shr    $0x18,%eax
801029f0:	83 e0 0f             	and    $0xf,%eax
801029f3:	09 d0                	or     %edx,%eax
801029f5:	83 c8 e0             	or     $0xffffffe0,%eax
801029f8:	0f b6 c0             	movzbl %al,%eax
801029fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ff:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102a06:	e8 04 fe ff ff       	call   8010280f <outb>
  if(b->flags & B_DIRTY){
80102a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0e:	8b 00                	mov    (%eax),%eax
80102a10:	83 e0 04             	and    $0x4,%eax
80102a13:	85 c0                	test   %eax,%eax
80102a15:	74 34                	je     80102a4b <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102a17:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102a1e:	00 
80102a1f:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a26:	e8 e4 fd ff ff       	call   8010280f <outb>
    outsl(0x1f0, b->data, 512/4);
80102a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2e:	83 c0 18             	add    $0x18,%eax
80102a31:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a38:	00 
80102a39:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a3d:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a44:	e8 e4 fd ff ff       	call   8010282d <outsl>
80102a49:	eb 14                	jmp    80102a5f <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a4b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a52:	00 
80102a53:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a5a:	e8 b0 fd ff ff       	call   8010280f <outb>
  }
}
80102a5f:	c9                   	leave  
80102a60:	c3                   	ret    

80102a61 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a61:	55                   	push   %ebp
80102a62:	89 e5                	mov    %esp,%ebp
80102a64:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a67:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102a6e:	e8 80 29 00 00       	call   801053f3 <acquire>
  if((b = idequeue) == 0){
80102a73:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102a78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a7f:	75 11                	jne    80102a92 <ideintr+0x31>
    release(&idelock);
80102a81:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102a88:	e8 c8 29 00 00       	call   80105455 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a8d:	e9 90 00 00 00       	jmp    80102b22 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a95:	8b 40 14             	mov    0x14(%eax),%eax
80102a98:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa0:	8b 00                	mov    (%eax),%eax
80102aa2:	83 e0 04             	and    $0x4,%eax
80102aa5:	85 c0                	test   %eax,%eax
80102aa7:	75 2e                	jne    80102ad7 <ideintr+0x76>
80102aa9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ab0:	e8 9d fd ff ff       	call   80102852 <idewait>
80102ab5:	85 c0                	test   %eax,%eax
80102ab7:	78 1e                	js     80102ad7 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abc:	83 c0 18             	add    $0x18,%eax
80102abf:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102ac6:	00 
80102ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
80102acb:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102ad2:	e8 13 fd ff ff       	call   801027ea <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ada:	8b 00                	mov    (%eax),%eax
80102adc:	89 c2                	mov    %eax,%edx
80102ade:	83 ca 02             	or     $0x2,%edx
80102ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae9:	8b 00                	mov    (%eax),%eax
80102aeb:	89 c2                	mov    %eax,%edx
80102aed:	83 e2 fb             	and    $0xfffffffb,%edx
80102af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af8:	89 04 24             	mov    %eax,(%esp)
80102afb:	e8 63 26 00 00       	call   80105163 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102b00:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b05:	85 c0                	test   %eax,%eax
80102b07:	74 0d                	je     80102b16 <ideintr+0xb5>
    idestart(idequeue);
80102b09:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102b0e:	89 04 24             	mov    %eax,(%esp)
80102b11:	e8 26 fe ff ff       	call   8010293c <idestart>

  release(&idelock);
80102b16:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102b1d:	e8 33 29 00 00       	call   80105455 <release>
}
80102b22:	c9                   	leave  
80102b23:	c3                   	ret    

80102b24 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b24:	55                   	push   %ebp
80102b25:	89 e5                	mov    %esp,%ebp
80102b27:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2d:	8b 00                	mov    (%eax),%eax
80102b2f:	83 e0 01             	and    $0x1,%eax
80102b32:	85 c0                	test   %eax,%eax
80102b34:	75 0c                	jne    80102b42 <iderw+0x1e>
    panic("iderw: buf not busy");
80102b36:	c7 04 24 f5 8b 10 80 	movl   $0x80108bf5,(%esp)
80102b3d:	e8 fb d9 ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b42:	8b 45 08             	mov    0x8(%ebp),%eax
80102b45:	8b 00                	mov    (%eax),%eax
80102b47:	83 e0 06             	and    $0x6,%eax
80102b4a:	83 f8 02             	cmp    $0x2,%eax
80102b4d:	75 0c                	jne    80102b5b <iderw+0x37>
    panic("iderw: nothing to do");
80102b4f:	c7 04 24 09 8c 10 80 	movl   $0x80108c09,(%esp)
80102b56:	e8 e2 d9 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5e:	8b 40 04             	mov    0x4(%eax),%eax
80102b61:	85 c0                	test   %eax,%eax
80102b63:	74 15                	je     80102b7a <iderw+0x56>
80102b65:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102b6a:	85 c0                	test   %eax,%eax
80102b6c:	75 0c                	jne    80102b7a <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b6e:	c7 04 24 1e 8c 10 80 	movl   $0x80108c1e,(%esp)
80102b75:	e8 c3 d9 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b7a:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102b81:	e8 6d 28 00 00       	call   801053f3 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b86:	8b 45 08             	mov    0x8(%ebp),%eax
80102b89:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b90:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80102b97:	eb 0b                	jmp    80102ba4 <iderw+0x80>
80102b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9c:	8b 00                	mov    (%eax),%eax
80102b9e:	83 c0 14             	add    $0x14,%eax
80102ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba7:	8b 00                	mov    (%eax),%eax
80102ba9:	85 c0                	test   %eax,%eax
80102bab:	75 ec                	jne    80102b99 <iderw+0x75>
    ;
  *pp = b;
80102bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb0:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb3:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102bb5:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102bba:	3b 45 08             	cmp    0x8(%ebp),%eax
80102bbd:	75 22                	jne    80102be1 <iderw+0xbd>
    idestart(b);
80102bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc2:	89 04 24             	mov    %eax,(%esp)
80102bc5:	e8 72 fd ff ff       	call   8010293c <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bca:	eb 15                	jmp    80102be1 <iderw+0xbd>
    sleep(b, &idelock);
80102bcc:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
80102bd3:	80 
80102bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd7:	89 04 24             	mov    %eax,(%esp)
80102bda:	e8 a8 24 00 00       	call   80105087 <sleep>
80102bdf:	eb 01                	jmp    80102be2 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102be1:	90                   	nop
80102be2:	8b 45 08             	mov    0x8(%ebp),%eax
80102be5:	8b 00                	mov    (%eax),%eax
80102be7:	83 e0 06             	and    $0x6,%eax
80102bea:	83 f8 02             	cmp    $0x2,%eax
80102bed:	75 dd                	jne    80102bcc <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102bef:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102bf6:	e8 5a 28 00 00       	call   80105455 <release>
}
80102bfb:	c9                   	leave  
80102bfc:	c3                   	ret    
80102bfd:	00 00                	add    %al,(%eax)
	...

80102c00 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102c00:	55                   	push   %ebp
80102c01:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c03:	a1 54 08 11 80       	mov    0x80110854,%eax
80102c08:	8b 55 08             	mov    0x8(%ebp),%edx
80102c0b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c0d:	a1 54 08 11 80       	mov    0x80110854,%eax
80102c12:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c15:	5d                   	pop    %ebp
80102c16:	c3                   	ret    

80102c17 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c17:	55                   	push   %ebp
80102c18:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c1a:	a1 54 08 11 80       	mov    0x80110854,%eax
80102c1f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c22:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c24:	a1 54 08 11 80       	mov    0x80110854,%eax
80102c29:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c2c:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c2f:	5d                   	pop    %ebp
80102c30:	c3                   	ret    

80102c31 <ioapicinit>:

void
ioapicinit(void)
{
80102c31:	55                   	push   %ebp
80102c32:	89 e5                	mov    %esp,%ebp
80102c34:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102c37:	a1 24 09 11 80       	mov    0x80110924,%eax
80102c3c:	85 c0                	test   %eax,%eax
80102c3e:	0f 84 9f 00 00 00    	je     80102ce3 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c44:	c7 05 54 08 11 80 00 	movl   $0xfec00000,0x80110854
80102c4b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c55:	e8 a6 ff ff ff       	call   80102c00 <ioapicread>
80102c5a:	c1 e8 10             	shr    $0x10,%eax
80102c5d:	25 ff 00 00 00       	and    $0xff,%eax
80102c62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c6c:	e8 8f ff ff ff       	call   80102c00 <ioapicread>
80102c71:	c1 e8 18             	shr    $0x18,%eax
80102c74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c77:	0f b6 05 20 09 11 80 	movzbl 0x80110920,%eax
80102c7e:	0f b6 c0             	movzbl %al,%eax
80102c81:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c84:	74 0c                	je     80102c92 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c86:	c7 04 24 3c 8c 10 80 	movl   $0x80108c3c,(%esp)
80102c8d:	e8 0f d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c99:	eb 3e                	jmp    80102cd9 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9e:	83 c0 20             	add    $0x20,%eax
80102ca1:	0d 00 00 01 00       	or     $0x10000,%eax
80102ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102ca9:	83 c2 08             	add    $0x8,%edx
80102cac:	01 d2                	add    %edx,%edx
80102cae:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cb2:	89 14 24             	mov    %edx,(%esp)
80102cb5:	e8 5d ff ff ff       	call   80102c17 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cbd:	83 c0 08             	add    $0x8,%eax
80102cc0:	01 c0                	add    %eax,%eax
80102cc2:	83 c0 01             	add    $0x1,%eax
80102cc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ccc:	00 
80102ccd:	89 04 24             	mov    %eax,(%esp)
80102cd0:	e8 42 ff ff ff       	call   80102c17 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cd5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cdc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cdf:	7e ba                	jle    80102c9b <ioapicinit+0x6a>
80102ce1:	eb 01                	jmp    80102ce4 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102ce3:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ce4:	c9                   	leave  
80102ce5:	c3                   	ret    

80102ce6 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ce6:	55                   	push   %ebp
80102ce7:	89 e5                	mov    %esp,%ebp
80102ce9:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102cec:	a1 24 09 11 80       	mov    0x80110924,%eax
80102cf1:	85 c0                	test   %eax,%eax
80102cf3:	74 39                	je     80102d2e <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf8:	83 c0 20             	add    $0x20,%eax
80102cfb:	8b 55 08             	mov    0x8(%ebp),%edx
80102cfe:	83 c2 08             	add    $0x8,%edx
80102d01:	01 d2                	add    %edx,%edx
80102d03:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d07:	89 14 24             	mov    %edx,(%esp)
80102d0a:	e8 08 ff ff ff       	call   80102c17 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d12:	c1 e0 18             	shl    $0x18,%eax
80102d15:	8b 55 08             	mov    0x8(%ebp),%edx
80102d18:	83 c2 08             	add    $0x8,%edx
80102d1b:	01 d2                	add    %edx,%edx
80102d1d:	83 c2 01             	add    $0x1,%edx
80102d20:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d24:	89 14 24             	mov    %edx,(%esp)
80102d27:	e8 eb fe ff ff       	call   80102c17 <ioapicwrite>
80102d2c:	eb 01                	jmp    80102d2f <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102d2e:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102d2f:	c9                   	leave  
80102d30:	c3                   	ret    
80102d31:	00 00                	add    %al,(%eax)
	...

80102d34 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102d34:	55                   	push   %ebp
80102d35:	89 e5                	mov    %esp,%ebp
80102d37:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3a:	05 00 00 00 80       	add    $0x80000000,%eax
80102d3f:	5d                   	pop    %ebp
80102d40:	c3                   	ret    

80102d41 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d41:	55                   	push   %ebp
80102d42:	89 e5                	mov    %esp,%ebp
80102d44:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d47:	c7 44 24 04 6e 8c 10 	movl   $0x80108c6e,0x4(%esp)
80102d4e:	80 
80102d4f:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102d56:	e8 77 26 00 00       	call   801053d2 <initlock>
  kmem.use_lock = 0;
80102d5b:	c7 05 94 08 11 80 00 	movl   $0x0,0x80110894
80102d62:	00 00 00 
  freerange(vstart, vend);
80102d65:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d68:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d6f:	89 04 24             	mov    %eax,(%esp)
80102d72:	e8 26 00 00 00       	call   80102d9d <freerange>
}
80102d77:	c9                   	leave  
80102d78:	c3                   	ret    

80102d79 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d79:	55                   	push   %ebp
80102d7a:	89 e5                	mov    %esp,%ebp
80102d7c:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d82:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d86:	8b 45 08             	mov    0x8(%ebp),%eax
80102d89:	89 04 24             	mov    %eax,(%esp)
80102d8c:	e8 0c 00 00 00       	call   80102d9d <freerange>
  kmem.use_lock = 1;
80102d91:	c7 05 94 08 11 80 01 	movl   $0x1,0x80110894
80102d98:	00 00 00 
}
80102d9b:	c9                   	leave  
80102d9c:	c3                   	ret    

80102d9d <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d9d:	55                   	push   %ebp
80102d9e:	89 e5                	mov    %esp,%ebp
80102da0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102da3:	8b 45 08             	mov    0x8(%ebp),%eax
80102da6:	05 ff 0f 00 00       	add    $0xfff,%eax
80102dab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102db0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102db3:	eb 12                	jmp    80102dc7 <freerange+0x2a>
    kfree(p);
80102db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db8:	89 04 24             	mov    %eax,(%esp)
80102dbb:	e8 16 00 00 00       	call   80102dd6 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102dc0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dca:	05 00 10 00 00       	add    $0x1000,%eax
80102dcf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dd2:	76 e1                	jbe    80102db5 <freerange+0x18>
    kfree(p);
}
80102dd4:	c9                   	leave  
80102dd5:	c3                   	ret    

80102dd6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dd6:	55                   	push   %ebp
80102dd7:	89 e5                	mov    %esp,%ebp
80102dd9:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80102ddf:	25 ff 0f 00 00       	and    $0xfff,%eax
80102de4:	85 c0                	test   %eax,%eax
80102de6:	75 1b                	jne    80102e03 <kfree+0x2d>
80102de8:	81 7d 08 1c 3d 11 80 	cmpl   $0x80113d1c,0x8(%ebp)
80102def:	72 12                	jb     80102e03 <kfree+0x2d>
80102df1:	8b 45 08             	mov    0x8(%ebp),%eax
80102df4:	89 04 24             	mov    %eax,(%esp)
80102df7:	e8 38 ff ff ff       	call   80102d34 <v2p>
80102dfc:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102e01:	76 0c                	jbe    80102e0f <kfree+0x39>
    panic("kfree");
80102e03:	c7 04 24 73 8c 10 80 	movl   $0x80108c73,(%esp)
80102e0a:	e8 2e d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e0f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e16:	00 
80102e17:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e1e:	00 
80102e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e22:	89 04 24             	mov    %eax,(%esp)
80102e25:	e8 18 28 00 00       	call   80105642 <memset>

  if(kmem.use_lock)
80102e2a:	a1 94 08 11 80       	mov    0x80110894,%eax
80102e2f:	85 c0                	test   %eax,%eax
80102e31:	74 0c                	je     80102e3f <kfree+0x69>
    acquire(&kmem.lock);
80102e33:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102e3a:	e8 b4 25 00 00       	call   801053f3 <acquire>
  r = (struct run*)v;
80102e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e45:	8b 15 98 08 11 80    	mov    0x80110898,%edx
80102e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e4e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e53:	a3 98 08 11 80       	mov    %eax,0x80110898
  if(kmem.use_lock)
80102e58:	a1 94 08 11 80       	mov    0x80110894,%eax
80102e5d:	85 c0                	test   %eax,%eax
80102e5f:	74 0c                	je     80102e6d <kfree+0x97>
    release(&kmem.lock);
80102e61:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102e68:	e8 e8 25 00 00       	call   80105455 <release>
}
80102e6d:	c9                   	leave  
80102e6e:	c3                   	ret    

80102e6f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e6f:	55                   	push   %ebp
80102e70:	89 e5                	mov    %esp,%ebp
80102e72:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e75:	a1 94 08 11 80       	mov    0x80110894,%eax
80102e7a:	85 c0                	test   %eax,%eax
80102e7c:	74 0c                	je     80102e8a <kalloc+0x1b>
    acquire(&kmem.lock);
80102e7e:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102e85:	e8 69 25 00 00       	call   801053f3 <acquire>
  r = kmem.freelist;
80102e8a:	a1 98 08 11 80       	mov    0x80110898,%eax
80102e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e96:	74 0a                	je     80102ea2 <kalloc+0x33>
    kmem.freelist = r->next;
80102e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e9b:	8b 00                	mov    (%eax),%eax
80102e9d:	a3 98 08 11 80       	mov    %eax,0x80110898
  if(kmem.use_lock)
80102ea2:	a1 94 08 11 80       	mov    0x80110894,%eax
80102ea7:	85 c0                	test   %eax,%eax
80102ea9:	74 0c                	je     80102eb7 <kalloc+0x48>
    release(&kmem.lock);
80102eab:	c7 04 24 60 08 11 80 	movl   $0x80110860,(%esp)
80102eb2:	e8 9e 25 00 00       	call   80105455 <release>
  return (char*)r;
80102eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102eba:	c9                   	leave  
80102ebb:	c3                   	ret    

80102ebc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ebc:	55                   	push   %ebp
80102ebd:	89 e5                	mov    %esp,%ebp
80102ebf:	53                   	push   %ebx
80102ec0:	83 ec 14             	sub    $0x14,%esp
80102ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ec6:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eca:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102ece:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102ed2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102ed6:	ec                   	in     (%dx),%al
80102ed7:	89 c3                	mov    %eax,%ebx
80102ed9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102edc:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102ee0:	83 c4 14             	add    $0x14,%esp
80102ee3:	5b                   	pop    %ebx
80102ee4:	5d                   	pop    %ebp
80102ee5:	c3                   	ret    

80102ee6 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ee6:	55                   	push   %ebp
80102ee7:	89 e5                	mov    %esp,%ebp
80102ee9:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102eec:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102ef3:	e8 c4 ff ff ff       	call   80102ebc <inb>
80102ef8:	0f b6 c0             	movzbl %al,%eax
80102efb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f01:	83 e0 01             	and    $0x1,%eax
80102f04:	85 c0                	test   %eax,%eax
80102f06:	75 0a                	jne    80102f12 <kbdgetc+0x2c>
    return -1;
80102f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f0d:	e9 23 01 00 00       	jmp    80103035 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102f12:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102f19:	e8 9e ff ff ff       	call   80102ebc <inb>
80102f1e:	0f b6 c0             	movzbl %al,%eax
80102f21:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102f24:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f2b:	75 17                	jne    80102f44 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f2d:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f32:	83 c8 40             	or     $0x40,%eax
80102f35:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f3a:	b8 00 00 00 00       	mov    $0x0,%eax
80102f3f:	e9 f1 00 00 00       	jmp    80103035 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102f44:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f47:	25 80 00 00 00       	and    $0x80,%eax
80102f4c:	85 c0                	test   %eax,%eax
80102f4e:	74 45                	je     80102f95 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f50:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f55:	83 e0 40             	and    $0x40,%eax
80102f58:	85 c0                	test   %eax,%eax
80102f5a:	75 08                	jne    80102f64 <kbdgetc+0x7e>
80102f5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5f:	83 e0 7f             	and    $0x7f,%eax
80102f62:	eb 03                	jmp    80102f67 <kbdgetc+0x81>
80102f64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f67:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f6d:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f72:	0f b6 00             	movzbl (%eax),%eax
80102f75:	83 c8 40             	or     $0x40,%eax
80102f78:	0f b6 c0             	movzbl %al,%eax
80102f7b:	f7 d0                	not    %eax
80102f7d:	89 c2                	mov    %eax,%edx
80102f7f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f84:	21 d0                	and    %edx,%eax
80102f86:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102f8b:	b8 00 00 00 00       	mov    $0x0,%eax
80102f90:	e9 a0 00 00 00       	jmp    80103035 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f95:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102f9a:	83 e0 40             	and    $0x40,%eax
80102f9d:	85 c0                	test   %eax,%eax
80102f9f:	74 14                	je     80102fb5 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102fa1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102fa8:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fad:	83 e0 bf             	and    $0xffffffbf,%eax
80102fb0:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102fb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb8:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102fbd:	0f b6 00             	movzbl (%eax),%eax
80102fc0:	0f b6 d0             	movzbl %al,%edx
80102fc3:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fc8:	09 d0                	or     %edx,%eax
80102fca:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102fcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fd2:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102fd7:	0f b6 00             	movzbl (%eax),%eax
80102fda:	0f b6 d0             	movzbl %al,%edx
80102fdd:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fe2:	31 d0                	xor    %edx,%eax
80102fe4:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fe9:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102fee:	83 e0 03             	and    $0x3,%eax
80102ff1:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80102ff8:	03 45 fc             	add    -0x4(%ebp),%eax
80102ffb:	0f b6 00             	movzbl (%eax),%eax
80102ffe:	0f b6 c0             	movzbl %al,%eax
80103001:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103004:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103009:	83 e0 08             	and    $0x8,%eax
8010300c:	85 c0                	test   %eax,%eax
8010300e:	74 22                	je     80103032 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80103010:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103014:	76 0c                	jbe    80103022 <kbdgetc+0x13c>
80103016:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010301a:	77 06                	ja     80103022 <kbdgetc+0x13c>
      c += 'A' - 'a';
8010301c:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103020:	eb 10                	jmp    80103032 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80103022:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80103026:	76 0a                	jbe    80103032 <kbdgetc+0x14c>
80103028:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010302c:	77 04                	ja     80103032 <kbdgetc+0x14c>
      c += 'a' - 'A';
8010302e:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103032:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103035:	c9                   	leave  
80103036:	c3                   	ret    

80103037 <kbdintr>:

void
kbdintr(void)
{
80103037:	55                   	push   %ebp
80103038:	89 e5                	mov    %esp,%ebp
8010303a:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
8010303d:	c7 04 24 e6 2e 10 80 	movl   $0x80102ee6,(%esp)
80103044:	e8 92 d8 ff ff       	call   801008db <consoleintr>
}
80103049:	c9                   	leave  
8010304a:	c3                   	ret    
	...

8010304c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010304c:	55                   	push   %ebp
8010304d:	89 e5                	mov    %esp,%ebp
8010304f:	83 ec 08             	sub    $0x8,%esp
80103052:	8b 55 08             	mov    0x8(%ebp),%edx
80103055:	8b 45 0c             	mov    0xc(%ebp),%eax
80103058:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010305c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010305f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103063:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103067:	ee                   	out    %al,(%dx)
}
80103068:	c9                   	leave  
80103069:	c3                   	ret    

8010306a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010306a:	55                   	push   %ebp
8010306b:	89 e5                	mov    %esp,%ebp
8010306d:	53                   	push   %ebx
8010306e:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103071:	9c                   	pushf  
80103072:	5b                   	pop    %ebx
80103073:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80103076:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103079:	83 c4 10             	add    $0x10,%esp
8010307c:	5b                   	pop    %ebx
8010307d:	5d                   	pop    %ebp
8010307e:	c3                   	ret    

8010307f <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010307f:	55                   	push   %ebp
80103080:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103082:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103087:	8b 55 08             	mov    0x8(%ebp),%edx
8010308a:	c1 e2 02             	shl    $0x2,%edx
8010308d:	01 c2                	add    %eax,%edx
8010308f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103092:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103094:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103099:	83 c0 20             	add    $0x20,%eax
8010309c:	8b 00                	mov    (%eax),%eax
}
8010309e:	5d                   	pop    %ebp
8010309f:	c3                   	ret    

801030a0 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
801030a0:	55                   	push   %ebp
801030a1:	89 e5                	mov    %esp,%ebp
801030a3:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
801030a6:	a1 9c 08 11 80       	mov    0x8011089c,%eax
801030ab:	85 c0                	test   %eax,%eax
801030ad:	0f 84 47 01 00 00    	je     801031fa <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030b3:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
801030ba:	00 
801030bb:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801030c2:	e8 b8 ff ff ff       	call   8010307f <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030c7:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801030ce:	00 
801030cf:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801030d6:	e8 a4 ff ff ff       	call   8010307f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030db:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801030e2:	00 
801030e3:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030ea:	e8 90 ff ff ff       	call   8010307f <lapicw>
  lapicw(TICR, 10000000); 
801030ef:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030f6:	00 
801030f7:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030fe:	e8 7c ff ff ff       	call   8010307f <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103103:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010310a:	00 
8010310b:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80103112:	e8 68 ff ff ff       	call   8010307f <lapicw>
  lapicw(LINT1, MASKED);
80103117:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010311e:	00 
8010311f:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103126:	e8 54 ff ff ff       	call   8010307f <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010312b:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103130:	83 c0 30             	add    $0x30,%eax
80103133:	8b 00                	mov    (%eax),%eax
80103135:	c1 e8 10             	shr    $0x10,%eax
80103138:	25 ff 00 00 00       	and    $0xff,%eax
8010313d:	83 f8 03             	cmp    $0x3,%eax
80103140:	76 14                	jbe    80103156 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80103142:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103149:	00 
8010314a:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103151:	e8 29 ff ff ff       	call   8010307f <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103156:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
8010315d:	00 
8010315e:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103165:	e8 15 ff ff ff       	call   8010307f <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010316a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103171:	00 
80103172:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103179:	e8 01 ff ff ff       	call   8010307f <lapicw>
  lapicw(ESR, 0);
8010317e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103185:	00 
80103186:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010318d:	e8 ed fe ff ff       	call   8010307f <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103192:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103199:	00 
8010319a:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801031a1:	e8 d9 fe ff ff       	call   8010307f <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801031a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031ad:	00 
801031ae:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031b5:	e8 c5 fe ff ff       	call   8010307f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031ba:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801031c1:	00 
801031c2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031c9:	e8 b1 fe ff ff       	call   8010307f <lapicw>
  while(lapic[ICRLO] & DELIVS)
801031ce:	90                   	nop
801031cf:	a1 9c 08 11 80       	mov    0x8011089c,%eax
801031d4:	05 00 03 00 00       	add    $0x300,%eax
801031d9:	8b 00                	mov    (%eax),%eax
801031db:	25 00 10 00 00       	and    $0x1000,%eax
801031e0:	85 c0                	test   %eax,%eax
801031e2:	75 eb                	jne    801031cf <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031eb:	00 
801031ec:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031f3:	e8 87 fe ff ff       	call   8010307f <lapicw>
801031f8:	eb 01                	jmp    801031fb <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801031fa:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801031fb:	c9                   	leave  
801031fc:	c3                   	ret    

801031fd <cpunum>:

int
cpunum(void)
{
801031fd:	55                   	push   %ebp
801031fe:	89 e5                	mov    %esp,%ebp
80103200:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103203:	e8 62 fe ff ff       	call   8010306a <readeflags>
80103208:	25 00 02 00 00       	and    $0x200,%eax
8010320d:	85 c0                	test   %eax,%eax
8010320f:	74 29                	je     8010323a <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80103211:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80103216:	85 c0                	test   %eax,%eax
80103218:	0f 94 c2             	sete   %dl
8010321b:	83 c0 01             	add    $0x1,%eax
8010321e:	a3 40 c6 10 80       	mov    %eax,0x8010c640
80103223:	84 d2                	test   %dl,%dl
80103225:	74 13                	je     8010323a <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80103227:	8b 45 04             	mov    0x4(%ebp),%eax
8010322a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010322e:	c7 04 24 7c 8c 10 80 	movl   $0x80108c7c,(%esp)
80103235:	e8 67 d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
8010323a:	a1 9c 08 11 80       	mov    0x8011089c,%eax
8010323f:	85 c0                	test   %eax,%eax
80103241:	74 0f                	je     80103252 <cpunum+0x55>
    return lapic[ID]>>24;
80103243:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103248:	83 c0 20             	add    $0x20,%eax
8010324b:	8b 00                	mov    (%eax),%eax
8010324d:	c1 e8 18             	shr    $0x18,%eax
80103250:	eb 05                	jmp    80103257 <cpunum+0x5a>
  return 0;
80103252:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103257:	c9                   	leave  
80103258:	c3                   	ret    

80103259 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103259:	55                   	push   %ebp
8010325a:	89 e5                	mov    %esp,%ebp
8010325c:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
8010325f:	a1 9c 08 11 80       	mov    0x8011089c,%eax
80103264:	85 c0                	test   %eax,%eax
80103266:	74 14                	je     8010327c <lapiceoi+0x23>
    lapicw(EOI, 0);
80103268:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010326f:	00 
80103270:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103277:	e8 03 fe ff ff       	call   8010307f <lapicw>
}
8010327c:	c9                   	leave  
8010327d:	c3                   	ret    

8010327e <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010327e:	55                   	push   %ebp
8010327f:	89 e5                	mov    %esp,%ebp
}
80103281:	5d                   	pop    %ebp
80103282:	c3                   	ret    

80103283 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103283:	55                   	push   %ebp
80103284:	89 e5                	mov    %esp,%ebp
80103286:	83 ec 1c             	sub    $0x1c,%esp
80103289:	8b 45 08             	mov    0x8(%ebp),%eax
8010328c:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
8010328f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103296:	00 
80103297:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010329e:	e8 a9 fd ff ff       	call   8010304c <outb>
  outb(IO_RTC+1, 0x0A);
801032a3:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801032aa:	00 
801032ab:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801032b2:	e8 95 fd ff ff       	call   8010304c <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801032b7:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801032be:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032c1:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801032c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032c9:	8d 50 02             	lea    0x2(%eax),%edx
801032cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801032cf:	c1 e8 04             	shr    $0x4,%eax
801032d2:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801032d5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032d9:	c1 e0 18             	shl    $0x18,%eax
801032dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801032e0:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032e7:	e8 93 fd ff ff       	call   8010307f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032ec:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032f3:	00 
801032f4:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032fb:	e8 7f fd ff ff       	call   8010307f <lapicw>
  microdelay(200);
80103300:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103307:	e8 72 ff ff ff       	call   8010327e <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010330c:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103313:	00 
80103314:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010331b:	e8 5f fd ff ff       	call   8010307f <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103320:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103327:	e8 52 ff ff ff       	call   8010327e <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010332c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103333:	eb 40                	jmp    80103375 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103335:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103339:	c1 e0 18             	shl    $0x18,%eax
8010333c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103340:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103347:	e8 33 fd ff ff       	call   8010307f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010334c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010334f:	c1 e8 0c             	shr    $0xc,%eax
80103352:	80 cc 06             	or     $0x6,%ah
80103355:	89 44 24 04          	mov    %eax,0x4(%esp)
80103359:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103360:	e8 1a fd ff ff       	call   8010307f <lapicw>
    microdelay(200);
80103365:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010336c:	e8 0d ff ff ff       	call   8010327e <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103371:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103375:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103379:	7e ba                	jle    80103335 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010337b:	c9                   	leave  
8010337c:	c3                   	ret    
8010337d:	00 00                	add    %al,(%eax)
	...

80103380 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103380:	55                   	push   %ebp
80103381:	89 e5                	mov    %esp,%ebp
80103383:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103386:	c7 44 24 04 a8 8c 10 	movl   $0x80108ca8,0x4(%esp)
8010338d:	80 
8010338e:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
80103395:	e8 38 20 00 00       	call   801053d2 <initlock>
  readsb(ROOTDEV, &sb);
8010339a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010339d:	89 44 24 04          	mov    %eax,0x4(%esp)
801033a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801033a8:	e8 af e2 ff ff       	call   8010165c <readsb>
  log.start = sb.size - sb.nlog;
801033ad:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b3:	89 d1                	mov    %edx,%ecx
801033b5:	29 c1                	sub    %eax,%ecx
801033b7:	89 c8                	mov    %ecx,%eax
801033b9:	a3 d4 08 11 80       	mov    %eax,0x801108d4
  log.size = sb.nlog;
801033be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033c1:	a3 d8 08 11 80       	mov    %eax,0x801108d8
  log.dev = ROOTDEV;
801033c6:	c7 05 e0 08 11 80 01 	movl   $0x1,0x801108e0
801033cd:	00 00 00 
  recover_from_log();
801033d0:	e8 97 01 00 00       	call   8010356c <recover_from_log>
}
801033d5:	c9                   	leave  
801033d6:	c3                   	ret    

801033d7 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033d7:	55                   	push   %ebp
801033d8:	89 e5                	mov    %esp,%ebp
801033da:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033e4:	e9 89 00 00 00       	jmp    80103472 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033e9:	a1 d4 08 11 80       	mov    0x801108d4,%eax
801033ee:	03 45 f4             	add    -0xc(%ebp),%eax
801033f1:	83 c0 01             	add    $0x1,%eax
801033f4:	89 c2                	mov    %eax,%edx
801033f6:	a1 e0 08 11 80       	mov    0x801108e0,%eax
801033fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801033ff:	89 04 24             	mov    %eax,(%esp)
80103402:	e8 9f cd ff ff       	call   801001a6 <bread>
80103407:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010340a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010340d:	83 c0 10             	add    $0x10,%eax
80103410:	8b 04 85 a8 08 11 80 	mov    -0x7feef758(,%eax,4),%eax
80103417:	89 c2                	mov    %eax,%edx
80103419:	a1 e0 08 11 80       	mov    0x801108e0,%eax
8010341e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103422:	89 04 24             	mov    %eax,(%esp)
80103425:	e8 7c cd ff ff       	call   801001a6 <bread>
8010342a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010342d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103430:	8d 50 18             	lea    0x18(%eax),%edx
80103433:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103436:	83 c0 18             	add    $0x18,%eax
80103439:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103440:	00 
80103441:	89 54 24 04          	mov    %edx,0x4(%esp)
80103445:	89 04 24             	mov    %eax,(%esp)
80103448:	e8 c8 22 00 00       	call   80105715 <memmove>
    bwrite(dbuf);  // write dst to disk
8010344d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103450:	89 04 24             	mov    %eax,(%esp)
80103453:	e8 85 cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010345b:	89 04 24             	mov    %eax,(%esp)
8010345e:	e8 b4 cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103463:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103466:	89 04 24             	mov    %eax,(%esp)
80103469:	e8 a9 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010346e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103472:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80103477:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010347a:	0f 8f 69 ff ff ff    	jg     801033e9 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103480:	c9                   	leave  
80103481:	c3                   	ret    

80103482 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103482:	55                   	push   %ebp
80103483:	89 e5                	mov    %esp,%ebp
80103485:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103488:	a1 d4 08 11 80       	mov    0x801108d4,%eax
8010348d:	89 c2                	mov    %eax,%edx
8010348f:	a1 e0 08 11 80       	mov    0x801108e0,%eax
80103494:	89 54 24 04          	mov    %edx,0x4(%esp)
80103498:	89 04 24             	mov    %eax,(%esp)
8010349b:	e8 06 cd ff ff       	call   801001a6 <bread>
801034a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a6:	83 c0 18             	add    $0x18,%eax
801034a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034af:	8b 00                	mov    (%eax),%eax
801034b1:	a3 e4 08 11 80       	mov    %eax,0x801108e4
  for (i = 0; i < log.lh.n; i++) {
801034b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034bd:	eb 1b                	jmp    801034da <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801034bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034c5:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cc:	83 c2 10             	add    $0x10,%edx
801034cf:	89 04 95 a8 08 11 80 	mov    %eax,-0x7feef758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034da:	a1 e4 08 11 80       	mov    0x801108e4,%eax
801034df:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034e2:	7f db                	jg     801034bf <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e7:	89 04 24             	mov    %eax,(%esp)
801034ea:	e8 28 cd ff ff       	call   80100217 <brelse>
}
801034ef:	c9                   	leave  
801034f0:	c3                   	ret    

801034f1 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034f1:	55                   	push   %ebp
801034f2:	89 e5                	mov    %esp,%ebp
801034f4:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034f7:	a1 d4 08 11 80       	mov    0x801108d4,%eax
801034fc:	89 c2                	mov    %eax,%edx
801034fe:	a1 e0 08 11 80       	mov    0x801108e0,%eax
80103503:	89 54 24 04          	mov    %edx,0x4(%esp)
80103507:	89 04 24             	mov    %eax,(%esp)
8010350a:	e8 97 cc ff ff       	call   801001a6 <bread>
8010350f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103512:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103515:	83 c0 18             	add    $0x18,%eax
80103518:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010351b:	8b 15 e4 08 11 80    	mov    0x801108e4,%edx
80103521:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103524:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103526:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010352d:	eb 1b                	jmp    8010354a <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
8010352f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103532:	83 c0 10             	add    $0x10,%eax
80103535:	8b 0c 85 a8 08 11 80 	mov    -0x7feef758(,%eax,4),%ecx
8010353c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010353f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103542:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103546:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010354a:	a1 e4 08 11 80       	mov    0x801108e4,%eax
8010354f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103552:	7f db                	jg     8010352f <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103554:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103557:	89 04 24             	mov    %eax,(%esp)
8010355a:	e8 7e cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010355f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103562:	89 04 24             	mov    %eax,(%esp)
80103565:	e8 ad cc ff ff       	call   80100217 <brelse>
}
8010356a:	c9                   	leave  
8010356b:	c3                   	ret    

8010356c <recover_from_log>:

static void
recover_from_log(void)
{
8010356c:	55                   	push   %ebp
8010356d:	89 e5                	mov    %esp,%ebp
8010356f:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103572:	e8 0b ff ff ff       	call   80103482 <read_head>
  install_trans(); // if committed, copy from log to disk
80103577:	e8 5b fe ff ff       	call   801033d7 <install_trans>
  log.lh.n = 0;
8010357c:	c7 05 e4 08 11 80 00 	movl   $0x0,0x801108e4
80103583:	00 00 00 
  write_head(); // clear the log
80103586:	e8 66 ff ff ff       	call   801034f1 <write_head>
}
8010358b:	c9                   	leave  
8010358c:	c3                   	ret    

8010358d <begin_trans>:

void
begin_trans(void)
{
8010358d:	55                   	push   %ebp
8010358e:	89 e5                	mov    %esp,%ebp
80103590:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103593:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
8010359a:	e8 54 1e 00 00       	call   801053f3 <acquire>
  while (log.busy) {
8010359f:	eb 14                	jmp    801035b5 <begin_trans+0x28>
    sleep(&log, &log.lock);
801035a1:	c7 44 24 04 a0 08 11 	movl   $0x801108a0,0x4(%esp)
801035a8:	80 
801035a9:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
801035b0:	e8 d2 1a 00 00       	call   80105087 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
801035b5:	a1 dc 08 11 80       	mov    0x801108dc,%eax
801035ba:	85 c0                	test   %eax,%eax
801035bc:	75 e3                	jne    801035a1 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801035be:	c7 05 dc 08 11 80 01 	movl   $0x1,0x801108dc
801035c5:	00 00 00 
  release(&log.lock);
801035c8:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
801035cf:	e8 81 1e 00 00       	call   80105455 <release>
}
801035d4:	c9                   	leave  
801035d5:	c3                   	ret    

801035d6 <commit_trans>:

void
commit_trans(void)
{
801035d6:	55                   	push   %ebp
801035d7:	89 e5                	mov    %esp,%ebp
801035d9:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801035dc:	a1 e4 08 11 80       	mov    0x801108e4,%eax
801035e1:	85 c0                	test   %eax,%eax
801035e3:	7e 19                	jle    801035fe <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801035e5:	e8 07 ff ff ff       	call   801034f1 <write_head>
    install_trans(); // Now install writes to home locations
801035ea:	e8 e8 fd ff ff       	call   801033d7 <install_trans>
    log.lh.n = 0; 
801035ef:	c7 05 e4 08 11 80 00 	movl   $0x0,0x801108e4
801035f6:	00 00 00 
    write_head();    // Erase the transaction from the log
801035f9:	e8 f3 fe ff ff       	call   801034f1 <write_head>
  }
  
  acquire(&log.lock);
801035fe:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
80103605:	e8 e9 1d 00 00       	call   801053f3 <acquire>
  log.busy = 0;
8010360a:	c7 05 dc 08 11 80 00 	movl   $0x0,0x801108dc
80103611:	00 00 00 
  wakeup(&log);
80103614:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
8010361b:	e8 43 1b 00 00       	call   80105163 <wakeup>
  release(&log.lock);
80103620:	c7 04 24 a0 08 11 80 	movl   $0x801108a0,(%esp)
80103627:	e8 29 1e 00 00       	call   80105455 <release>
}
8010362c:	c9                   	leave  
8010362d:	c3                   	ret    

8010362e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010362e:	55                   	push   %ebp
8010362f:	89 e5                	mov    %esp,%ebp
80103631:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103634:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80103639:	83 f8 09             	cmp    $0x9,%eax
8010363c:	7f 12                	jg     80103650 <log_write+0x22>
8010363e:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80103643:	8b 15 d8 08 11 80    	mov    0x801108d8,%edx
80103649:	83 ea 01             	sub    $0x1,%edx
8010364c:	39 d0                	cmp    %edx,%eax
8010364e:	7c 0c                	jl     8010365c <log_write+0x2e>
    panic("too big a transaction");
80103650:	c7 04 24 ac 8c 10 80 	movl   $0x80108cac,(%esp)
80103657:	e8 e1 ce ff ff       	call   8010053d <panic>
  if (!log.busy)
8010365c:	a1 dc 08 11 80       	mov    0x801108dc,%eax
80103661:	85 c0                	test   %eax,%eax
80103663:	75 0c                	jne    80103671 <log_write+0x43>
    panic("write outside of trans");
80103665:	c7 04 24 c2 8c 10 80 	movl   $0x80108cc2,(%esp)
8010366c:	e8 cc ce ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103678:	eb 1d                	jmp    80103697 <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
8010367a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010367d:	83 c0 10             	add    $0x10,%eax
80103680:	8b 04 85 a8 08 11 80 	mov    -0x7feef758(,%eax,4),%eax
80103687:	89 c2                	mov    %eax,%edx
80103689:	8b 45 08             	mov    0x8(%ebp),%eax
8010368c:	8b 40 08             	mov    0x8(%eax),%eax
8010368f:	39 c2                	cmp    %eax,%edx
80103691:	74 10                	je     801036a3 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103693:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103697:	a1 e4 08 11 80       	mov    0x801108e4,%eax
8010369c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010369f:	7f d9                	jg     8010367a <log_write+0x4c>
801036a1:	eb 01                	jmp    801036a4 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
801036a3:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801036a4:	8b 45 08             	mov    0x8(%ebp),%eax
801036a7:	8b 40 08             	mov    0x8(%eax),%eax
801036aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036ad:	83 c2 10             	add    $0x10,%edx
801036b0:	89 04 95 a8 08 11 80 	mov    %eax,-0x7feef758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
801036b7:	a1 d4 08 11 80       	mov    0x801108d4,%eax
801036bc:	03 45 f4             	add    -0xc(%ebp),%eax
801036bf:	83 c0 01             	add    $0x1,%eax
801036c2:	89 c2                	mov    %eax,%edx
801036c4:	8b 45 08             	mov    0x8(%ebp),%eax
801036c7:	8b 40 04             	mov    0x4(%eax),%eax
801036ca:	89 54 24 04          	mov    %edx,0x4(%esp)
801036ce:	89 04 24             	mov    %eax,(%esp)
801036d1:	e8 d0 ca ff ff       	call   801001a6 <bread>
801036d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801036d9:	8b 45 08             	mov    0x8(%ebp),%eax
801036dc:	8d 50 18             	lea    0x18(%eax),%edx
801036df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e2:	83 c0 18             	add    $0x18,%eax
801036e5:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036ec:	00 
801036ed:	89 54 24 04          	mov    %edx,0x4(%esp)
801036f1:	89 04 24             	mov    %eax,(%esp)
801036f4:	e8 1c 20 00 00       	call   80105715 <memmove>
  bwrite(lbuf);
801036f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036fc:	89 04 24             	mov    %eax,(%esp)
801036ff:	e8 d9 ca ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103704:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103707:	89 04 24             	mov    %eax,(%esp)
8010370a:	e8 08 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
8010370f:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80103714:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103717:	75 0d                	jne    80103726 <log_write+0xf8>
    log.lh.n++;
80103719:	a1 e4 08 11 80       	mov    0x801108e4,%eax
8010371e:	83 c0 01             	add    $0x1,%eax
80103721:	a3 e4 08 11 80       	mov    %eax,0x801108e4
  b->flags |= B_DIRTY; // XXX prevent eviction
80103726:	8b 45 08             	mov    0x8(%ebp),%eax
80103729:	8b 00                	mov    (%eax),%eax
8010372b:	89 c2                	mov    %eax,%edx
8010372d:	83 ca 04             	or     $0x4,%edx
80103730:	8b 45 08             	mov    0x8(%ebp),%eax
80103733:	89 10                	mov    %edx,(%eax)
}
80103735:	c9                   	leave  
80103736:	c3                   	ret    
	...

80103738 <v2p>:
80103738:	55                   	push   %ebp
80103739:	89 e5                	mov    %esp,%ebp
8010373b:	8b 45 08             	mov    0x8(%ebp),%eax
8010373e:	05 00 00 00 80       	add    $0x80000000,%eax
80103743:	5d                   	pop    %ebp
80103744:	c3                   	ret    

80103745 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103745:	55                   	push   %ebp
80103746:	89 e5                	mov    %esp,%ebp
80103748:	8b 45 08             	mov    0x8(%ebp),%eax
8010374b:	05 00 00 00 80       	add    $0x80000000,%eax
80103750:	5d                   	pop    %ebp
80103751:	c3                   	ret    

80103752 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103752:	55                   	push   %ebp
80103753:	89 e5                	mov    %esp,%ebp
80103755:	53                   	push   %ebx
80103756:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103759:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010375c:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010375f:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103762:	89 c3                	mov    %eax,%ebx
80103764:	89 d8                	mov    %ebx,%eax
80103766:	f0 87 02             	lock xchg %eax,(%edx)
80103769:	89 c3                	mov    %eax,%ebx
8010376b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010376e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103771:	83 c4 10             	add    $0x10,%esp
80103774:	5b                   	pop    %ebx
80103775:	5d                   	pop    %ebp
80103776:	c3                   	ret    

80103777 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103777:	55                   	push   %ebp
80103778:	89 e5                	mov    %esp,%ebp
8010377a:	83 e4 f0             	and    $0xfffffff0,%esp
8010377d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103780:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103787:	80 
80103788:	c7 04 24 1c 3d 11 80 	movl   $0x80113d1c,(%esp)
8010378f:	e8 ad f5 ff ff       	call   80102d41 <kinit1>
  kvmalloc();      // kernel page table
80103794:	e8 6d 4b 00 00       	call   80108306 <kvmalloc>
  mpinit();        // collect info about this machine
80103799:	e8 63 04 00 00       	call   80103c01 <mpinit>
  lapicinit(mpbcpu());
8010379e:	e8 2e 02 00 00       	call   801039d1 <mpbcpu>
801037a3:	89 04 24             	mov    %eax,(%esp)
801037a6:	e8 f5 f8 ff ff       	call   801030a0 <lapicinit>
  seginit();       // set up segments
801037ab:	e8 f9 44 00 00       	call   80107ca9 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037b0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037b6:	0f b6 00             	movzbl (%eax),%eax
801037b9:	0f b6 c0             	movzbl %al,%eax
801037bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801037c0:	c7 04 24 d9 8c 10 80 	movl   $0x80108cd9,(%esp)
801037c7:	e8 d5 cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037cc:	e8 95 06 00 00       	call   80103e66 <picinit>
  ioapicinit();    // another interrupt controller
801037d1:	e8 5b f4 ff ff       	call   80102c31 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037d6:	e8 21 d6 ff ff       	call   80100dfc <consoleinit>
  uartinit();      // serial port
801037db:	e8 14 38 00 00       	call   80106ff4 <uartinit>
  pinit();         // process table
801037e0:	e8 96 0b 00 00       	call   8010437b <pinit>
  tvinit();        // trap vectors
801037e5:	e8 69 33 00 00       	call   80106b53 <tvinit>
  binit();         // buffer cache
801037ea:	e8 45 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037ef:	e8 7c da ff ff       	call   80101270 <fileinit>
  iinit();         // inode cache
801037f4:	e8 2a e1 ff ff       	call   80101923 <iinit>
  ideinit();       // disk
801037f9:	e8 98 f0 ff ff       	call   80102896 <ideinit>
  if(!ismp)
801037fe:	a1 24 09 11 80       	mov    0x80110924,%eax
80103803:	85 c0                	test   %eax,%eax
80103805:	75 05                	jne    8010380c <main+0x95>
    timerinit();   // uniprocessor timer
80103807:	e8 8a 32 00 00       	call   80106a96 <timerinit>
  startothers();   // start other processors
8010380c:	e8 87 00 00 00       	call   80103898 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103811:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103818:	8e 
80103819:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103820:	e8 54 f5 ff ff       	call   80102d79 <kinit2>
  userinit();      // first user process
80103825:	e8 6f 0c 00 00       	call   80104499 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010382a:	e8 22 00 00 00       	call   80103851 <mpmain>

8010382f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010382f:	55                   	push   %ebp
80103830:	89 e5                	mov    %esp,%ebp
80103832:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
80103835:	e8 e3 4a 00 00       	call   8010831d <switchkvm>
  seginit();
8010383a:	e8 6a 44 00 00       	call   80107ca9 <seginit>
  lapicinit(cpunum());
8010383f:	e8 b9 f9 ff ff       	call   801031fd <cpunum>
80103844:	89 04 24             	mov    %eax,(%esp)
80103847:	e8 54 f8 ff ff       	call   801030a0 <lapicinit>
  mpmain();
8010384c:	e8 00 00 00 00       	call   80103851 <mpmain>

80103851 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103851:	55                   	push   %ebp
80103852:	89 e5                	mov    %esp,%ebp
80103854:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103857:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010385d:	0f b6 00             	movzbl (%eax),%eax
80103860:	0f b6 c0             	movzbl %al,%eax
80103863:	89 44 24 04          	mov    %eax,0x4(%esp)
80103867:	c7 04 24 f0 8c 10 80 	movl   $0x80108cf0,(%esp)
8010386e:	e8 2e cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103873:	e8 4f 34 00 00       	call   80106cc7 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103878:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010387e:	05 a8 00 00 00       	add    $0xa8,%eax
80103883:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010388a:	00 
8010388b:	89 04 24             	mov    %eax,(%esp)
8010388e:	e8 bf fe ff ff       	call   80103752 <xchg>
  scheduler();     // start running processes
80103893:	e8 c9 13 00 00       	call   80104c61 <scheduler>

80103898 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103898:	55                   	push   %ebp
80103899:	89 e5                	mov    %esp,%ebp
8010389b:	53                   	push   %ebx
8010389c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010389f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038a6:	e8 9a fe ff ff       	call   80103745 <p2v>
801038ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038ae:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801038b7:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
801038be:	80 
801038bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c2:	89 04 24             	mov    %eax,(%esp)
801038c5:	e8 4b 1e 00 00       	call   80105715 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038ca:	c7 45 f4 40 09 11 80 	movl   $0x80110940,-0xc(%ebp)
801038d1:	e9 86 00 00 00       	jmp    8010395c <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038d6:	e8 22 f9 ff ff       	call   801031fd <cpunum>
801038db:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038e1:	05 40 09 11 80       	add    $0x80110940,%eax
801038e6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038e9:	74 69                	je     80103954 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038eb:	e8 7f f5 ff ff       	call   80102e6f <kalloc>
801038f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f6:	83 e8 04             	sub    $0x4,%eax
801038f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038fc:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103902:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103907:	83 e8 08             	sub    $0x8,%eax
8010390a:	c7 00 2f 38 10 80    	movl   $0x8010382f,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103913:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103916:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
8010391d:	e8 16 fe ff ff       	call   80103738 <v2p>
80103922:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103927:	89 04 24             	mov    %eax,(%esp)
8010392a:	e8 09 fe ff ff       	call   80103738 <v2p>
8010392f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103932:	0f b6 12             	movzbl (%edx),%edx
80103935:	0f b6 d2             	movzbl %dl,%edx
80103938:	89 44 24 04          	mov    %eax,0x4(%esp)
8010393c:	89 14 24             	mov    %edx,(%esp)
8010393f:	e8 3f f9 ff ff       	call   80103283 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103944:	90                   	nop
80103945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103948:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010394e:	85 c0                	test   %eax,%eax
80103950:	74 f3                	je     80103945 <startothers+0xad>
80103952:	eb 01                	jmp    80103955 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103954:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103955:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010395c:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103961:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103967:	05 40 09 11 80       	add    $0x80110940,%eax
8010396c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010396f:	0f 87 61 ff ff ff    	ja     801038d6 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103975:	83 c4 24             	add    $0x24,%esp
80103978:	5b                   	pop    %ebx
80103979:	5d                   	pop    %ebp
8010397a:	c3                   	ret    
	...

8010397c <p2v>:
8010397c:	55                   	push   %ebp
8010397d:	89 e5                	mov    %esp,%ebp
8010397f:	8b 45 08             	mov    0x8(%ebp),%eax
80103982:	05 00 00 00 80       	add    $0x80000000,%eax
80103987:	5d                   	pop    %ebp
80103988:	c3                   	ret    

80103989 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103989:	55                   	push   %ebp
8010398a:	89 e5                	mov    %esp,%ebp
8010398c:	53                   	push   %ebx
8010398d:	83 ec 14             	sub    $0x14,%esp
80103990:	8b 45 08             	mov    0x8(%ebp),%eax
80103993:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103997:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010399b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010399f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801039a3:	ec                   	in     (%dx),%al
801039a4:	89 c3                	mov    %eax,%ebx
801039a6:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801039a9:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801039ad:	83 c4 14             	add    $0x14,%esp
801039b0:	5b                   	pop    %ebx
801039b1:	5d                   	pop    %ebp
801039b2:	c3                   	ret    

801039b3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039b3:	55                   	push   %ebp
801039b4:	89 e5                	mov    %esp,%ebp
801039b6:	83 ec 08             	sub    $0x8,%esp
801039b9:	8b 55 08             	mov    0x8(%ebp),%edx
801039bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801039bf:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039c3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039c6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039ca:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039ce:	ee                   	out    %al,(%dx)
}
801039cf:	c9                   	leave  
801039d0:	c3                   	ret    

801039d1 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039d1:	55                   	push   %ebp
801039d2:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039d4:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801039d9:	89 c2                	mov    %eax,%edx
801039db:	b8 40 09 11 80       	mov    $0x80110940,%eax
801039e0:	89 d1                	mov    %edx,%ecx
801039e2:	29 c1                	sub    %eax,%ecx
801039e4:	89 c8                	mov    %ecx,%eax
801039e6:	c1 f8 02             	sar    $0x2,%eax
801039e9:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039ef:	5d                   	pop    %ebp
801039f0:	c3                   	ret    

801039f1 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039f1:	55                   	push   %ebp
801039f2:	89 e5                	mov    %esp,%ebp
801039f4:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039f7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a05:	eb 13                	jmp    80103a1a <sum+0x29>
    sum += addr[i];
80103a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a0a:	03 45 08             	add    0x8(%ebp),%eax
80103a0d:	0f b6 00             	movzbl (%eax),%eax
80103a10:	0f b6 c0             	movzbl %al,%eax
80103a13:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a1d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a20:	7c e5                	jl     80103a07 <sum+0x16>
    sum += addr[i];
  return sum;
80103a22:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a25:	c9                   	leave  
80103a26:	c3                   	ret    

80103a27 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a27:	55                   	push   %ebp
80103a28:	89 e5                	mov    %esp,%ebp
80103a2a:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a30:	89 04 24             	mov    %eax,(%esp)
80103a33:	e8 44 ff ff ff       	call   8010397c <p2v>
80103a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a3e:	03 45 f0             	add    -0x10(%ebp),%eax
80103a41:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a4a:	eb 3f                	jmp    80103a8b <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a4c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a53:	00 
80103a54:	c7 44 24 04 04 8d 10 	movl   $0x80108d04,0x4(%esp)
80103a5b:	80 
80103a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5f:	89 04 24             	mov    %eax,(%esp)
80103a62:	e8 52 1c 00 00       	call   801056b9 <memcmp>
80103a67:	85 c0                	test   %eax,%eax
80103a69:	75 1c                	jne    80103a87 <mpsearch1+0x60>
80103a6b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a72:	00 
80103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a76:	89 04 24             	mov    %eax,(%esp)
80103a79:	e8 73 ff ff ff       	call   801039f1 <sum>
80103a7e:	84 c0                	test   %al,%al
80103a80:	75 05                	jne    80103a87 <mpsearch1+0x60>
      return (struct mp*)p;
80103a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a85:	eb 11                	jmp    80103a98 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a87:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a91:	72 b9                	jb     80103a4c <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a98:	c9                   	leave  
80103a99:	c3                   	ret    

80103a9a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a9a:	55                   	push   %ebp
80103a9b:	89 e5                	mov    %esp,%ebp
80103a9d:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103aa0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aaa:	83 c0 0f             	add    $0xf,%eax
80103aad:	0f b6 00             	movzbl (%eax),%eax
80103ab0:	0f b6 c0             	movzbl %al,%eax
80103ab3:	89 c2                	mov    %eax,%edx
80103ab5:	c1 e2 08             	shl    $0x8,%edx
80103ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abb:	83 c0 0e             	add    $0xe,%eax
80103abe:	0f b6 00             	movzbl (%eax),%eax
80103ac1:	0f b6 c0             	movzbl %al,%eax
80103ac4:	09 d0                	or     %edx,%eax
80103ac6:	c1 e0 04             	shl    $0x4,%eax
80103ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103acc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ad0:	74 21                	je     80103af3 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103ad2:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ad9:	00 
80103ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103add:	89 04 24             	mov    %eax,(%esp)
80103ae0:	e8 42 ff ff ff       	call   80103a27 <mpsearch1>
80103ae5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ae8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aec:	74 50                	je     80103b3e <mpsearch+0xa4>
      return mp;
80103aee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af1:	eb 5f                	jmp    80103b52 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af6:	83 c0 14             	add    $0x14,%eax
80103af9:	0f b6 00             	movzbl (%eax),%eax
80103afc:	0f b6 c0             	movzbl %al,%eax
80103aff:	89 c2                	mov    %eax,%edx
80103b01:	c1 e2 08             	shl    $0x8,%edx
80103b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b07:	83 c0 13             	add    $0x13,%eax
80103b0a:	0f b6 00             	movzbl (%eax),%eax
80103b0d:	0f b6 c0             	movzbl %al,%eax
80103b10:	09 d0                	or     %edx,%eax
80103b12:	c1 e0 0a             	shl    $0xa,%eax
80103b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1b:	2d 00 04 00 00       	sub    $0x400,%eax
80103b20:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b27:	00 
80103b28:	89 04 24             	mov    %eax,(%esp)
80103b2b:	e8 f7 fe ff ff       	call   80103a27 <mpsearch1>
80103b30:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b33:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b37:	74 05                	je     80103b3e <mpsearch+0xa4>
      return mp;
80103b39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b3c:	eb 14                	jmp    80103b52 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b3e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b45:	00 
80103b46:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b4d:	e8 d5 fe ff ff       	call   80103a27 <mpsearch1>
}
80103b52:	c9                   	leave  
80103b53:	c3                   	ret    

80103b54 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b54:	55                   	push   %ebp
80103b55:	89 e5                	mov    %esp,%ebp
80103b57:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b5a:	e8 3b ff ff ff       	call   80103a9a <mpsearch>
80103b5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b66:	74 0a                	je     80103b72 <mpconfig+0x1e>
80103b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6b:	8b 40 04             	mov    0x4(%eax),%eax
80103b6e:	85 c0                	test   %eax,%eax
80103b70:	75 0a                	jne    80103b7c <mpconfig+0x28>
    return 0;
80103b72:	b8 00 00 00 00       	mov    $0x0,%eax
80103b77:	e9 83 00 00 00       	jmp    80103bff <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	8b 40 04             	mov    0x4(%eax),%eax
80103b82:	89 04 24             	mov    %eax,(%esp)
80103b85:	e8 f2 fd ff ff       	call   8010397c <p2v>
80103b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b8d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b94:	00 
80103b95:	c7 44 24 04 09 8d 10 	movl   $0x80108d09,0x4(%esp)
80103b9c:	80 
80103b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba0:	89 04 24             	mov    %eax,(%esp)
80103ba3:	e8 11 1b 00 00       	call   801056b9 <memcmp>
80103ba8:	85 c0                	test   %eax,%eax
80103baa:	74 07                	je     80103bb3 <mpconfig+0x5f>
    return 0;
80103bac:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb1:	eb 4c                	jmp    80103bff <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bba:	3c 01                	cmp    $0x1,%al
80103bbc:	74 12                	je     80103bd0 <mpconfig+0x7c>
80103bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc1:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bc5:	3c 04                	cmp    $0x4,%al
80103bc7:	74 07                	je     80103bd0 <mpconfig+0x7c>
    return 0;
80103bc9:	b8 00 00 00 00       	mov    $0x0,%eax
80103bce:	eb 2f                	jmp    80103bff <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bd7:	0f b7 c0             	movzwl %ax,%eax
80103bda:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be1:	89 04 24             	mov    %eax,(%esp)
80103be4:	e8 08 fe ff ff       	call   801039f1 <sum>
80103be9:	84 c0                	test   %al,%al
80103beb:	74 07                	je     80103bf4 <mpconfig+0xa0>
    return 0;
80103bed:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf2:	eb 0b                	jmp    80103bff <mpconfig+0xab>
  *pmp = mp;
80103bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bfa:	89 10                	mov    %edx,(%eax)
  return conf;
80103bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bff:	c9                   	leave  
80103c00:	c3                   	ret    

80103c01 <mpinit>:

void
mpinit(void)
{
80103c01:	55                   	push   %ebp
80103c02:	89 e5                	mov    %esp,%ebp
80103c04:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c07:	c7 05 44 c6 10 80 40 	movl   $0x80110940,0x8010c644
80103c0e:	09 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c11:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c14:	89 04 24             	mov    %eax,(%esp)
80103c17:	e8 38 ff ff ff       	call   80103b54 <mpconfig>
80103c1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c23:	0f 84 9c 01 00 00    	je     80103dc5 <mpinit+0x1c4>
    return;
  ismp = 1;
80103c29:	c7 05 24 09 11 80 01 	movl   $0x1,0x80110924
80103c30:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c36:	8b 40 24             	mov    0x24(%eax),%eax
80103c39:	a3 9c 08 11 80       	mov    %eax,0x8011089c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c41:	83 c0 2c             	add    $0x2c,%eax
80103c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c4a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c4e:	0f b7 c0             	movzwl %ax,%eax
80103c51:	03 45 f0             	add    -0x10(%ebp),%eax
80103c54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c57:	e9 f4 00 00 00       	jmp    80103d50 <mpinit+0x14f>
    switch(*p){
80103c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5f:	0f b6 00             	movzbl (%eax),%eax
80103c62:	0f b6 c0             	movzbl %al,%eax
80103c65:	83 f8 04             	cmp    $0x4,%eax
80103c68:	0f 87 bf 00 00 00    	ja     80103d2d <mpinit+0x12c>
80103c6e:	8b 04 85 4c 8d 10 80 	mov    -0x7fef72b4(,%eax,4),%eax
80103c75:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c80:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c84:	0f b6 d0             	movzbl %al,%edx
80103c87:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103c8c:	39 c2                	cmp    %eax,%edx
80103c8e:	74 2d                	je     80103cbd <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c93:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c97:	0f b6 d0             	movzbl %al,%edx
80103c9a:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103c9f:	89 54 24 08          	mov    %edx,0x8(%esp)
80103ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ca7:	c7 04 24 0e 8d 10 80 	movl   $0x80108d0e,(%esp)
80103cae:	e8 ee c6 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103cb3:	c7 05 24 09 11 80 00 	movl   $0x0,0x80110924
80103cba:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cc0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cc4:	0f b6 c0             	movzbl %al,%eax
80103cc7:	83 e0 02             	and    $0x2,%eax
80103cca:	85 c0                	test   %eax,%eax
80103ccc:	74 15                	je     80103ce3 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cce:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103cd3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cd9:	05 40 09 11 80       	add    $0x80110940,%eax
80103cde:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80103ce3:	8b 15 20 0f 11 80    	mov    0x80110f20,%edx
80103ce9:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103cee:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cf4:	81 c2 40 09 11 80    	add    $0x80110940,%edx
80103cfa:	88 02                	mov    %al,(%edx)
      ncpu++;
80103cfc:	a1 20 0f 11 80       	mov    0x80110f20,%eax
80103d01:	83 c0 01             	add    $0x1,%eax
80103d04:	a3 20 0f 11 80       	mov    %eax,0x80110f20
      p += sizeof(struct mpproc);
80103d09:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d0d:	eb 41                	jmp    80103d50 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d18:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d1c:	a2 20 09 11 80       	mov    %al,0x80110920
      p += sizeof(struct mpioapic);
80103d21:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d25:	eb 29                	jmp    80103d50 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d27:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d2b:	eb 23                	jmp    80103d50 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d30:	0f b6 00             	movzbl (%eax),%eax
80103d33:	0f b6 c0             	movzbl %al,%eax
80103d36:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d3a:	c7 04 24 2c 8d 10 80 	movl   $0x80108d2c,(%esp)
80103d41:	e8 5b c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d46:	c7 05 24 09 11 80 00 	movl   $0x0,0x80110924
80103d4d:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d53:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d56:	0f 82 00 ff ff ff    	jb     80103c5c <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d5c:	a1 24 09 11 80       	mov    0x80110924,%eax
80103d61:	85 c0                	test   %eax,%eax
80103d63:	75 1d                	jne    80103d82 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d65:	c7 05 20 0f 11 80 01 	movl   $0x1,0x80110f20
80103d6c:	00 00 00 
    lapic = 0;
80103d6f:	c7 05 9c 08 11 80 00 	movl   $0x0,0x8011089c
80103d76:	00 00 00 
    ioapicid = 0;
80103d79:	c6 05 20 09 11 80 00 	movb   $0x0,0x80110920
    return;
80103d80:	eb 44                	jmp    80103dc6 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d85:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d89:	84 c0                	test   %al,%al
80103d8b:	74 39                	je     80103dc6 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d8d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d94:	00 
80103d95:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d9c:	e8 12 fc ff ff       	call   801039b3 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103da1:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103da8:	e8 dc fb ff ff       	call   80103989 <inb>
80103dad:	83 c8 01             	or     $0x1,%eax
80103db0:	0f b6 c0             	movzbl %al,%eax
80103db3:	89 44 24 04          	mov    %eax,0x4(%esp)
80103db7:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dbe:	e8 f0 fb ff ff       	call   801039b3 <outb>
80103dc3:	eb 01                	jmp    80103dc6 <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103dc5:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103dc6:	c9                   	leave  
80103dc7:	c3                   	ret    

80103dc8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dc8:	55                   	push   %ebp
80103dc9:	89 e5                	mov    %esp,%ebp
80103dcb:	83 ec 08             	sub    $0x8,%esp
80103dce:	8b 55 08             	mov    0x8(%ebp),%edx
80103dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dd4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dd8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ddb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ddf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103de3:	ee                   	out    %al,(%dx)
}
80103de4:	c9                   	leave  
80103de5:	c3                   	ret    

80103de6 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103de6:	55                   	push   %ebp
80103de7:	89 e5                	mov    %esp,%ebp
80103de9:	83 ec 0c             	sub    $0xc,%esp
80103dec:	8b 45 08             	mov    0x8(%ebp),%eax
80103def:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103df3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103df7:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103dfd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e01:	0f b6 c0             	movzbl %al,%eax
80103e04:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e08:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e0f:	e8 b4 ff ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e14:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e18:	66 c1 e8 08          	shr    $0x8,%ax
80103e1c:	0f b6 c0             	movzbl %al,%eax
80103e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e23:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e2a:	e8 99 ff ff ff       	call   80103dc8 <outb>
}
80103e2f:	c9                   	leave  
80103e30:	c3                   	ret    

80103e31 <picenable>:

void
picenable(int irq)
{
80103e31:	55                   	push   %ebp
80103e32:	89 e5                	mov    %esp,%ebp
80103e34:	53                   	push   %ebx
80103e35:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	ba 01 00 00 00       	mov    $0x1,%edx
80103e40:	89 d3                	mov    %edx,%ebx
80103e42:	89 c1                	mov    %eax,%ecx
80103e44:	d3 e3                	shl    %cl,%ebx
80103e46:	89 d8                	mov    %ebx,%eax
80103e48:	89 c2                	mov    %eax,%edx
80103e4a:	f7 d2                	not    %edx
80103e4c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103e53:	21 d0                	and    %edx,%eax
80103e55:	0f b7 c0             	movzwl %ax,%eax
80103e58:	89 04 24             	mov    %eax,(%esp)
80103e5b:	e8 86 ff ff ff       	call   80103de6 <picsetmask>
}
80103e60:	83 c4 04             	add    $0x4,%esp
80103e63:	5b                   	pop    %ebx
80103e64:	5d                   	pop    %ebp
80103e65:	c3                   	ret    

80103e66 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e66:	55                   	push   %ebp
80103e67:	89 e5                	mov    %esp,%ebp
80103e69:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e6c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e73:	00 
80103e74:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e7b:	e8 48 ff ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e80:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e87:	00 
80103e88:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e8f:	e8 34 ff ff ff       	call   80103dc8 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e94:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e9b:	00 
80103e9c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ea3:	e8 20 ff ff ff       	call   80103dc8 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ea8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103eaf:	00 
80103eb0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eb7:	e8 0c ff ff ff       	call   80103dc8 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ebc:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ec3:	00 
80103ec4:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ecb:	e8 f8 fe ff ff       	call   80103dc8 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ed0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ed7:	00 
80103ed8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103edf:	e8 e4 fe ff ff       	call   80103dc8 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ee4:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103eeb:	00 
80103eec:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ef3:	e8 d0 fe ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ef8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103eff:	00 
80103f00:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f07:	e8 bc fe ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f0c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f13:	00 
80103f14:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f1b:	e8 a8 fe ff ff       	call   80103dc8 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f20:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f27:	00 
80103f28:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f2f:	e8 94 fe ff ff       	call   80103dc8 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f34:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f3b:	00 
80103f3c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f43:	e8 80 fe ff ff       	call   80103dc8 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f48:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f4f:	00 
80103f50:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f57:	e8 6c fe ff ff       	call   80103dc8 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f5c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f63:	00 
80103f64:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f6b:	e8 58 fe ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f70:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f77:	00 
80103f78:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f7f:	e8 44 fe ff ff       	call   80103dc8 <outb>

  if(irqmask != 0xFFFF)
80103f84:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f8b:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f8f:	74 12                	je     80103fa3 <picinit+0x13d>
    picsetmask(irqmask);
80103f91:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f98:	0f b7 c0             	movzwl %ax,%eax
80103f9b:	89 04 24             	mov    %eax,(%esp)
80103f9e:	e8 43 fe ff ff       	call   80103de6 <picsetmask>
}
80103fa3:	c9                   	leave  
80103fa4:	c3                   	ret    
80103fa5:	00 00                	add    %al,(%eax)
	...

80103fa8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fa8:	55                   	push   %ebp
80103fa9:	89 e5                	mov    %esp,%ebp
80103fab:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc1:	8b 10                	mov    (%eax),%edx
80103fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fc8:	e8 bf d2 ff ff       	call   8010128c <filealloc>
80103fcd:	8b 55 08             	mov    0x8(%ebp),%edx
80103fd0:	89 02                	mov    %eax,(%edx)
80103fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd5:	8b 00                	mov    (%eax),%eax
80103fd7:	85 c0                	test   %eax,%eax
80103fd9:	0f 84 c8 00 00 00    	je     801040a7 <pipealloc+0xff>
80103fdf:	e8 a8 d2 ff ff       	call   8010128c <filealloc>
80103fe4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fe7:	89 02                	mov    %eax,(%edx)
80103fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fec:	8b 00                	mov    (%eax),%eax
80103fee:	85 c0                	test   %eax,%eax
80103ff0:	0f 84 b1 00 00 00    	je     801040a7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103ff6:	e8 74 ee ff ff       	call   80102e6f <kalloc>
80103ffb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ffe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104002:	0f 84 9e 00 00 00    	je     801040a6 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80104008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104012:	00 00 00 
  p->writeopen = 1;
80104015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104018:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010401f:	00 00 00 
  p->nwrite = 0;
80104022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104025:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010402c:	00 00 00 
  p->nread = 0;
8010402f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104032:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104039:	00 00 00 
  initlock(&p->lock, "pipe");
8010403c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403f:	c7 44 24 04 60 8d 10 	movl   $0x80108d60,0x4(%esp)
80104046:	80 
80104047:	89 04 24             	mov    %eax,(%esp)
8010404a:	e8 83 13 00 00       	call   801053d2 <initlock>
  (*f0)->type = FD_PIPE;
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	8b 00                	mov    (%eax),%eax
80104054:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010405a:	8b 45 08             	mov    0x8(%ebp),%eax
8010405d:	8b 00                	mov    (%eax),%eax
8010405f:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104063:	8b 45 08             	mov    0x8(%ebp),%eax
80104066:	8b 00                	mov    (%eax),%eax
80104068:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010406c:	8b 45 08             	mov    0x8(%ebp),%eax
8010406f:	8b 00                	mov    (%eax),%eax
80104071:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104074:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407a:	8b 00                	mov    (%eax),%eax
8010407c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104082:	8b 45 0c             	mov    0xc(%ebp),%eax
80104085:	8b 00                	mov    (%eax),%eax
80104087:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010408b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408e:	8b 00                	mov    (%eax),%eax
80104090:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104094:	8b 45 0c             	mov    0xc(%ebp),%eax
80104097:	8b 00                	mov    (%eax),%eax
80104099:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010409c:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010409f:	b8 00 00 00 00       	mov    $0x0,%eax
801040a4:	eb 43                	jmp    801040e9 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040a6:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040ab:	74 0b                	je     801040b8 <pipealloc+0x110>
    kfree((char*)p);
801040ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b0:	89 04 24             	mov    %eax,(%esp)
801040b3:	e8 1e ed ff ff       	call   80102dd6 <kfree>
  if(*f0)
801040b8:	8b 45 08             	mov    0x8(%ebp),%eax
801040bb:	8b 00                	mov    (%eax),%eax
801040bd:	85 c0                	test   %eax,%eax
801040bf:	74 0d                	je     801040ce <pipealloc+0x126>
    fileclose(*f0);
801040c1:	8b 45 08             	mov    0x8(%ebp),%eax
801040c4:	8b 00                	mov    (%eax),%eax
801040c6:	89 04 24             	mov    %eax,(%esp)
801040c9:	e8 66 d2 ff ff       	call   80101334 <fileclose>
  if(*f1)
801040ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d1:	8b 00                	mov    (%eax),%eax
801040d3:	85 c0                	test   %eax,%eax
801040d5:	74 0d                	je     801040e4 <pipealloc+0x13c>
    fileclose(*f1);
801040d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801040da:	8b 00                	mov    (%eax),%eax
801040dc:	89 04 24             	mov    %eax,(%esp)
801040df:	e8 50 d2 ff ff       	call   80101334 <fileclose>
  return -1;
801040e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040e9:	c9                   	leave  
801040ea:	c3                   	ret    

801040eb <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040eb:	55                   	push   %ebp
801040ec:	89 e5                	mov    %esp,%ebp
801040ee:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040f1:	8b 45 08             	mov    0x8(%ebp),%eax
801040f4:	89 04 24             	mov    %eax,(%esp)
801040f7:	e8 f7 12 00 00       	call   801053f3 <acquire>
  if(writable){
801040fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104100:	74 1f                	je     80104121 <pipeclose+0x36>
    p->writeopen = 0;
80104102:	8b 45 08             	mov    0x8(%ebp),%eax
80104105:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010410c:	00 00 00 
    wakeup(&p->nread);
8010410f:	8b 45 08             	mov    0x8(%ebp),%eax
80104112:	05 34 02 00 00       	add    $0x234,%eax
80104117:	89 04 24             	mov    %eax,(%esp)
8010411a:	e8 44 10 00 00       	call   80105163 <wakeup>
8010411f:	eb 1d                	jmp    8010413e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104121:	8b 45 08             	mov    0x8(%ebp),%eax
80104124:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010412b:	00 00 00 
    wakeup(&p->nwrite);
8010412e:	8b 45 08             	mov    0x8(%ebp),%eax
80104131:	05 38 02 00 00       	add    $0x238,%eax
80104136:	89 04 24             	mov    %eax,(%esp)
80104139:	e8 25 10 00 00       	call   80105163 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010413e:	8b 45 08             	mov    0x8(%ebp),%eax
80104141:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104147:	85 c0                	test   %eax,%eax
80104149:	75 25                	jne    80104170 <pipeclose+0x85>
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104154:	85 c0                	test   %eax,%eax
80104156:	75 18                	jne    80104170 <pipeclose+0x85>
    release(&p->lock);
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	89 04 24             	mov    %eax,(%esp)
8010415e:	e8 f2 12 00 00       	call   80105455 <release>
    kfree((char*)p);
80104163:	8b 45 08             	mov    0x8(%ebp),%eax
80104166:	89 04 24             	mov    %eax,(%esp)
80104169:	e8 68 ec ff ff       	call   80102dd6 <kfree>
8010416e:	eb 0b                	jmp    8010417b <pipeclose+0x90>
  } else
    release(&p->lock);
80104170:	8b 45 08             	mov    0x8(%ebp),%eax
80104173:	89 04 24             	mov    %eax,(%esp)
80104176:	e8 da 12 00 00       	call   80105455 <release>
}
8010417b:	c9                   	leave  
8010417c:	c3                   	ret    

8010417d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010417d:	55                   	push   %ebp
8010417e:	89 e5                	mov    %esp,%ebp
80104180:	53                   	push   %ebx
80104181:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104184:	8b 45 08             	mov    0x8(%ebp),%eax
80104187:	89 04 24             	mov    %eax,(%esp)
8010418a:	e8 64 12 00 00       	call   801053f3 <acquire>
  for(i = 0; i < n; i++){
8010418f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104196:	e9 a6 00 00 00       	jmp    80104241 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010419b:	8b 45 08             	mov    0x8(%ebp),%eax
8010419e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041a4:	85 c0                	test   %eax,%eax
801041a6:	74 0d                	je     801041b5 <pipewrite+0x38>
801041a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041ae:	8b 40 24             	mov    0x24(%eax),%eax
801041b1:	85 c0                	test   %eax,%eax
801041b3:	74 15                	je     801041ca <pipewrite+0x4d>
        release(&p->lock);
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	89 04 24             	mov    %eax,(%esp)
801041bb:	e8 95 12 00 00       	call   80105455 <release>
        return -1;
801041c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c5:	e9 9d 00 00 00       	jmp    80104267 <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041ca:	8b 45 08             	mov    0x8(%ebp),%eax
801041cd:	05 34 02 00 00       	add    $0x234,%eax
801041d2:	89 04 24             	mov    %eax,(%esp)
801041d5:	e8 89 0f 00 00       	call   80105163 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041da:	8b 45 08             	mov    0x8(%ebp),%eax
801041dd:	8b 55 08             	mov    0x8(%ebp),%edx
801041e0:	81 c2 38 02 00 00    	add    $0x238,%edx
801041e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ea:	89 14 24             	mov    %edx,(%esp)
801041ed:	e8 95 0e 00 00       	call   80105087 <sleep>
801041f2:	eb 01                	jmp    801041f5 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041f4:	90                   	nop
801041f5:	8b 45 08             	mov    0x8(%ebp),%eax
801041f8:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104201:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104207:	05 00 02 00 00       	add    $0x200,%eax
8010420c:	39 c2                	cmp    %eax,%edx
8010420e:	74 8b                	je     8010419b <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104210:	8b 45 08             	mov    0x8(%ebp),%eax
80104213:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104219:	89 c3                	mov    %eax,%ebx
8010421b:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104221:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104224:	03 55 0c             	add    0xc(%ebp),%edx
80104227:	0f b6 0a             	movzbl (%edx),%ecx
8010422a:	8b 55 08             	mov    0x8(%ebp),%edx
8010422d:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104231:	8d 50 01             	lea    0x1(%eax),%edx
80104234:	8b 45 08             	mov    0x8(%ebp),%eax
80104237:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010423d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104244:	3b 45 10             	cmp    0x10(%ebp),%eax
80104247:	7c ab                	jl     801041f4 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104249:	8b 45 08             	mov    0x8(%ebp),%eax
8010424c:	05 34 02 00 00       	add    $0x234,%eax
80104251:	89 04 24             	mov    %eax,(%esp)
80104254:	e8 0a 0f 00 00       	call   80105163 <wakeup>
  release(&p->lock);
80104259:	8b 45 08             	mov    0x8(%ebp),%eax
8010425c:	89 04 24             	mov    %eax,(%esp)
8010425f:	e8 f1 11 00 00       	call   80105455 <release>
  return n;
80104264:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104267:	83 c4 24             	add    $0x24,%esp
8010426a:	5b                   	pop    %ebx
8010426b:	5d                   	pop    %ebp
8010426c:	c3                   	ret    

8010426d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010426d:	55                   	push   %ebp
8010426e:	89 e5                	mov    %esp,%ebp
80104270:	53                   	push   %ebx
80104271:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104274:	8b 45 08             	mov    0x8(%ebp),%eax
80104277:	89 04 24             	mov    %eax,(%esp)
8010427a:	e8 74 11 00 00       	call   801053f3 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010427f:	eb 3a                	jmp    801042bb <piperead+0x4e>
    if(proc->killed){
80104281:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104287:	8b 40 24             	mov    0x24(%eax),%eax
8010428a:	85 c0                	test   %eax,%eax
8010428c:	74 15                	je     801042a3 <piperead+0x36>
      release(&p->lock);
8010428e:	8b 45 08             	mov    0x8(%ebp),%eax
80104291:	89 04 24             	mov    %eax,(%esp)
80104294:	e8 bc 11 00 00       	call   80105455 <release>
      return -1;
80104299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010429e:	e9 b6 00 00 00       	jmp    80104359 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042a3:	8b 45 08             	mov    0x8(%ebp),%eax
801042a6:	8b 55 08             	mov    0x8(%ebp),%edx
801042a9:	81 c2 34 02 00 00    	add    $0x234,%edx
801042af:	89 44 24 04          	mov    %eax,0x4(%esp)
801042b3:	89 14 24             	mov    %edx,(%esp)
801042b6:	e8 cc 0d 00 00       	call   80105087 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042bb:	8b 45 08             	mov    0x8(%ebp),%eax
801042be:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042c4:	8b 45 08             	mov    0x8(%ebp),%eax
801042c7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042cd:	39 c2                	cmp    %eax,%edx
801042cf:	75 0d                	jne    801042de <piperead+0x71>
801042d1:	8b 45 08             	mov    0x8(%ebp),%eax
801042d4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042da:	85 c0                	test   %eax,%eax
801042dc:	75 a3                	jne    80104281 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042e5:	eb 49                	jmp    80104330 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042e7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ea:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f9:	39 c2                	cmp    %eax,%edx
801042fb:	74 3d                	je     8010433a <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104300:	89 c2                	mov    %eax,%edx
80104302:	03 55 0c             	add    0xc(%ebp),%edx
80104305:	8b 45 08             	mov    0x8(%ebp),%eax
80104308:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010430e:	89 c3                	mov    %eax,%ebx
80104310:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104316:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104319:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
8010431e:	88 0a                	mov    %cl,(%edx)
80104320:	8d 50 01             	lea    0x1(%eax),%edx
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010432c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104333:	3b 45 10             	cmp    0x10(%ebp),%eax
80104336:	7c af                	jl     801042e7 <piperead+0x7a>
80104338:	eb 01                	jmp    8010433b <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
8010433a:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010433b:	8b 45 08             	mov    0x8(%ebp),%eax
8010433e:	05 38 02 00 00       	add    $0x238,%eax
80104343:	89 04 24             	mov    %eax,(%esp)
80104346:	e8 18 0e 00 00       	call   80105163 <wakeup>
  release(&p->lock);
8010434b:	8b 45 08             	mov    0x8(%ebp),%eax
8010434e:	89 04 24             	mov    %eax,(%esp)
80104351:	e8 ff 10 00 00       	call   80105455 <release>
  return i;
80104356:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104359:	83 c4 24             	add    $0x24,%esp
8010435c:	5b                   	pop    %ebx
8010435d:	5d                   	pop    %ebp
8010435e:	c3                   	ret    
	...

80104360 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104360:	55                   	push   %ebp
80104361:	89 e5                	mov    %esp,%ebp
80104363:	53                   	push   %ebx
80104364:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104367:	9c                   	pushf  
80104368:	5b                   	pop    %ebx
80104369:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010436c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010436f:	83 c4 10             	add    $0x10,%esp
80104372:	5b                   	pop    %ebx
80104373:	5d                   	pop    %ebp
80104374:	c3                   	ret    

80104375 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104375:	55                   	push   %ebp
80104376:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104378:	fb                   	sti    
}
80104379:	5d                   	pop    %ebp
8010437a:	c3                   	ret    

8010437b <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);
void
pinit(void)
{
8010437b:	55                   	push   %ebp
8010437c:	89 e5                	mov    %esp,%ebp
8010437e:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104381:	c7 44 24 04 65 8d 10 	movl   $0x80108d65,0x4(%esp)
80104388:	80 
80104389:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104390:	e8 3d 10 00 00       	call   801053d2 <initlock>
}
80104395:	c9                   	leave  
80104396:	c3                   	ret    

80104397 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104397:	55                   	push   %ebp
80104398:	89 e5                	mov    %esp,%ebp
8010439a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010439d:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801043a4:	e8 4a 10 00 00       	call   801053f3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a9:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
801043b0:	eb 11                	jmp    801043c3 <allocproc+0x2c>
    if(p->state == UNUSED)
801043b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b5:	8b 40 0c             	mov    0xc(%eax),%eax
801043b8:	85 c0                	test   %eax,%eax
801043ba:	74 26                	je     801043e2 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043bc:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801043c3:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
801043ca:	72 e6                	jb     801043b2 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043cc:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801043d3:	e8 7d 10 00 00       	call   80105455 <release>
  return 0;
801043d8:	b8 00 00 00 00       	mov    $0x0,%eax
801043dd:	e9 b5 00 00 00       	jmp    80104497 <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043e2:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e6:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043ed:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801043f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f5:	89 42 10             	mov    %eax,0x10(%edx)
801043f8:	83 c0 01             	add    $0x1,%eax
801043fb:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  release(&ptable.lock);
80104400:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104407:	e8 49 10 00 00       	call   80105455 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010440c:	e8 5e ea ff ff       	call   80102e6f <kalloc>
80104411:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104414:	89 42 08             	mov    %eax,0x8(%edx)
80104417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441a:	8b 40 08             	mov    0x8(%eax),%eax
8010441d:	85 c0                	test   %eax,%eax
8010441f:	75 11                	jne    80104432 <allocproc+0x9b>
    p->state = UNUSED;
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010442b:	b8 00 00 00 00       	mov    $0x0,%eax
80104430:	eb 65                	jmp    80104497 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
80104432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104435:	8b 40 08             	mov    0x8(%eax),%eax
80104438:	05 00 10 00 00       	add    $0x1000,%eax
8010443d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104440:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104447:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010444a:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010444d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104451:	ba 08 6b 10 80       	mov    $0x80106b08,%edx
80104456:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104459:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010445b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010445f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104462:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104465:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010446e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104475:	00 
80104476:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010447d:	00 
8010447e:	89 04 24             	mov    %eax,(%esp)
80104481:	e8 bc 11 00 00       	call   80105642 <memset>
  p->context->eip = (uint)forkret;
80104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104489:	8b 40 1c             	mov    0x1c(%eax),%eax
8010448c:	ba 5b 50 10 80       	mov    $0x8010505b,%edx
80104491:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104494:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104497:	c9                   	leave  
80104498:	c3                   	ret    

80104499 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104499:	55                   	push   %ebp
8010449a:	89 e5                	mov    %esp,%ebp
8010449c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010449f:	e8 f3 fe ff ff       	call   80104397 <allocproc>
801044a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044aa:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm(kalloc)) == 0)
801044af:	c7 04 24 6f 2e 10 80 	movl   $0x80102e6f,(%esp)
801044b6:	e8 8e 3d 00 00       	call   80108249 <setupkvm>
801044bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044be:	89 42 04             	mov    %eax,0x4(%edx)
801044c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c4:	8b 40 04             	mov    0x4(%eax),%eax
801044c7:	85 c0                	test   %eax,%eax
801044c9:	75 0c                	jne    801044d7 <userinit+0x3e>
    panic("userinit: out of memory?");
801044cb:	c7 04 24 6c 8d 10 80 	movl   $0x80108d6c,(%esp)
801044d2:	e8 66 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044d7:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044df:	8b 40 04             	mov    0x4(%eax),%eax
801044e2:	89 54 24 08          	mov    %edx,0x8(%esp)
801044e6:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
801044ed:	80 
801044ee:	89 04 24             	mov    %eax,(%esp)
801044f1:	e8 ab 3f 00 00       	call   801084a1 <inituvm>
  p->sz = PGSIZE;
801044f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104502:	8b 40 18             	mov    0x18(%eax),%eax
80104505:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010450c:	00 
8010450d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104514:	00 
80104515:	89 04 24             	mov    %eax,(%esp)
80104518:	e8 25 11 00 00       	call   80105642 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010451d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104520:	8b 40 18             	mov    0x18(%eax),%eax
80104523:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	8b 40 18             	mov    0x18(%eax),%eax
8010452f:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104538:	8b 40 18             	mov    0x18(%eax),%eax
8010453b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453e:	8b 52 18             	mov    0x18(%edx),%edx
80104541:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104545:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454c:	8b 40 18             	mov    0x18(%eax),%eax
8010454f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104552:	8b 52 18             	mov    0x18(%edx),%edx
80104555:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104559:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010455d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104560:	8b 40 18             	mov    0x18(%eax),%eax
80104563:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010456a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456d:	8b 40 18             	mov    0x18(%eax),%eax
80104570:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457a:	8b 40 18             	mov    0x18(%eax),%eax
8010457d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104587:	83 c0 6c             	add    $0x6c,%eax
8010458a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104591:	00 
80104592:	c7 44 24 04 85 8d 10 	movl   $0x80108d85,0x4(%esp)
80104599:	80 
8010459a:	89 04 24             	mov    %eax,(%esp)
8010459d:	e8 d0 12 00 00       	call   80105872 <safestrcpy>
  p->cwd = namei("/");
801045a2:	c7 04 24 8e 8d 10 80 	movl   $0x80108d8e,(%esp)
801045a9:	e8 cc e1 ff ff       	call   8010277a <namei>
801045ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b1:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
801045b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045be:	c9                   	leave  
801045bf:	c3                   	ret    

801045c0 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045c0:	55                   	push   %ebp
801045c1:	89 e5                	mov    %esp,%ebp
801045c3:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045cc:	8b 00                	mov    (%eax),%eax
801045ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045d1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045d5:	7e 34                	jle    8010460b <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045d7:	8b 45 08             	mov    0x8(%ebp),%eax
801045da:	89 c2                	mov    %eax,%edx
801045dc:	03 55 f4             	add    -0xc(%ebp),%edx
801045df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045e5:	8b 40 04             	mov    0x4(%eax),%eax
801045e8:	89 54 24 08          	mov    %edx,0x8(%esp)
801045ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801045f3:	89 04 24             	mov    %eax,(%esp)
801045f6:	e8 20 40 00 00       	call   8010861b <allocuvm>
801045fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104602:	75 41                	jne    80104645 <growproc+0x85>
      return -1;
80104604:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104609:	eb 58                	jmp    80104663 <growproc+0xa3>
  } else if(n < 0){
8010460b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010460f:	79 34                	jns    80104645 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104611:	8b 45 08             	mov    0x8(%ebp),%eax
80104614:	89 c2                	mov    %eax,%edx
80104616:	03 55 f4             	add    -0xc(%ebp),%edx
80104619:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010461f:	8b 40 04             	mov    0x4(%eax),%eax
80104622:	89 54 24 08          	mov    %edx,0x8(%esp)
80104626:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104629:	89 54 24 04          	mov    %edx,0x4(%esp)
8010462d:	89 04 24             	mov    %eax,(%esp)
80104630:	e8 c0 40 00 00       	call   801086f5 <deallocuvm>
80104635:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104638:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010463c:	75 07                	jne    80104645 <growproc+0x85>
      return -1;
8010463e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104643:	eb 1e                	jmp    80104663 <growproc+0xa3>
  }
  proc->sz = sz;
80104645:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464e:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104650:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104656:	89 04 24             	mov    %eax,(%esp)
80104659:	e8 dc 3c 00 00       	call   8010833a <switchuvm>
  return 0;
8010465e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104663:	c9                   	leave  
80104664:	c3                   	ret    

80104665 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104665:	55                   	push   %ebp
80104666:	89 e5                	mov    %esp,%ebp
80104668:	57                   	push   %edi
80104669:	56                   	push   %esi
8010466a:	53                   	push   %ebx
8010466b:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010466e:	e8 24 fd ff ff       	call   80104397 <allocproc>
80104673:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104676:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010467a:	75 0a                	jne    80104686 <fork+0x21>
    return -1;
8010467c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104681:	e9 87 01 00 00       	jmp    8010480d <fork+0x1a8>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104686:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468c:	8b 10                	mov    (%eax),%edx
8010468e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104694:	8b 40 04             	mov    0x4(%eax),%eax
80104697:	89 54 24 04          	mov    %edx,0x4(%esp)
8010469b:	89 04 24             	mov    %eax,(%esp)
8010469e:	e8 e2 41 00 00       	call   80108885 <copyuvm>
801046a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046a6:	89 42 04             	mov    %eax,0x4(%edx)
801046a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ac:	8b 40 04             	mov    0x4(%eax),%eax
801046af:	85 c0                	test   %eax,%eax
801046b1:	75 2c                	jne    801046df <fork+0x7a>
    kfree(np->kstack);
801046b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b6:	8b 40 08             	mov    0x8(%eax),%eax
801046b9:	89 04 24             	mov    %eax,(%esp)
801046bc:	e8 15 e7 ff ff       	call   80102dd6 <kfree>
    np->kstack = 0;
801046c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ce:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046da:	e9 2e 01 00 00       	jmp    8010480d <fork+0x1a8>
  }
  np->sz = proc->sz;
801046df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e5:	8b 10                	mov    (%eax),%edx
801046e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ea:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046ec:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f6:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fc:	8b 50 18             	mov    0x18(%eax),%edx
801046ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104705:	8b 40 18             	mov    0x18(%eax),%eax
80104708:	89 c3                	mov    %eax,%ebx
8010470a:	b8 13 00 00 00       	mov    $0x13,%eax
8010470f:	89 d7                	mov    %edx,%edi
80104711:	89 de                	mov    %ebx,%esi
80104713:	89 c1                	mov    %eax,%ecx
80104715:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104717:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471a:	8b 40 18             	mov    0x18(%eax),%eax
8010471d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104724:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010472b:	eb 3d                	jmp    8010476a <fork+0x105>
    if(proc->ofile[i])
8010472d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104733:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104736:	83 c2 08             	add    $0x8,%edx
80104739:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010473d:	85 c0                	test   %eax,%eax
8010473f:	74 25                	je     80104766 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104741:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104747:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010474a:	83 c2 08             	add    $0x8,%edx
8010474d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104751:	89 04 24             	mov    %eax,(%esp)
80104754:	e8 93 cb ff ff       	call   801012ec <filedup>
80104759:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010475c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010475f:	83 c1 08             	add    $0x8,%ecx
80104762:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104766:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010476a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010476e:	7e bd                	jle    8010472d <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104770:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104776:	8b 40 68             	mov    0x68(%eax),%eax
80104779:	89 04 24             	mov    %eax,(%esp)
8010477c:	e8 25 d4 ff ff       	call   80101ba6 <idup>
80104781:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104784:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104787:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478a:	8b 40 10             	mov    0x10(%eax),%eax
8010478d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104790:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104793:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010479a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a0:	8d 50 6c             	lea    0x6c(%eax),%edx
801047a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a6:	83 c0 6c             	add    $0x6c,%eax
801047a9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047b0:	00 
801047b1:	89 54 24 04          	mov    %edx,0x4(%esp)
801047b5:	89 04 24             	mov    %eax,(%esp)
801047b8:	e8 b5 10 00 00       	call   80105872 <safestrcpy>
  acquire(&tickslock);
801047bd:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
801047c4:	e8 2a 0c 00 00       	call   801053f3 <acquire>
  np->ctime = ticks;
801047c9:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
801047ce:	89 c2                	mov    %eax,%edx
801047d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d3:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
801047d6:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
801047dd:	e8 73 0c 00 00       	call   80105455 <release>
  np->rtime = 0;
801047e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e5:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047ec:	00 00 00 
      break;
    case _GRT:
      np->qvalue = 0;
      break;
    case _3Q:
      np->priority = HIGH;
801047ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f2:	c7 80 8c 00 00 00 03 	movl   $0x3,0x8c(%eax)
801047f9:	00 00 00 
      np->qvalue = 0;
801047fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ff:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80104806:	00 00 00 
      break;
80104809:	90                   	nop
  }
  return pid;
8010480a:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010480d:	83 c4 2c             	add    $0x2c,%esp
80104810:	5b                   	pop    %ebx
80104811:	5e                   	pop    %esi
80104812:	5f                   	pop    %edi
80104813:	5d                   	pop    %ebp
80104814:	c3                   	ret    

80104815 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104815:	55                   	push   %ebp
80104816:	89 e5                	mov    %esp,%ebp
80104818:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  
  if(proc == initproc)
8010481b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104822:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104827:	39 c2                	cmp    %eax,%edx
80104829:	75 0c                	jne    80104837 <exit+0x22>
    panic("init exiting");
8010482b:	c7 04 24 90 8d 10 80 	movl   $0x80108d90,(%esp)
80104832:	e8 06 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104837:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010483e:	eb 44                	jmp    80104884 <exit+0x6f>
    if(proc->ofile[fd]){
80104840:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104846:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104849:	83 c2 08             	add    $0x8,%edx
8010484c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104850:	85 c0                	test   %eax,%eax
80104852:	74 2c                	je     80104880 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104854:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010485d:	83 c2 08             	add    $0x8,%edx
80104860:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104864:	89 04 24             	mov    %eax,(%esp)
80104867:	e8 c8 ca ff ff       	call   80101334 <fileclose>
      proc->ofile[fd] = 0;
8010486c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104872:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104875:	83 c2 08             	add    $0x8,%edx
80104878:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010487f:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104880:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104884:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104888:	7e b6                	jle    80104840 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
8010488a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104890:	8b 40 68             	mov    0x68(%eax),%eax
80104893:	89 04 24             	mov    %eax,(%esp)
80104896:	e8 f0 d4 ff ff       	call   80101d8b <iput>
  proc->cwd = 0;
8010489b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a1:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801048a8:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801048af:	e8 3f 0b 00 00       	call   801053f3 <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801048b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ba:	8b 40 14             	mov    0x14(%eax),%eax
801048bd:	89 04 24             	mov    %eax,(%esp)
801048c0:	e8 5d 08 00 00       	call   80105122 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048c5:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
801048cc:	eb 3b                	jmp    80104909 <exit+0xf4>
    if(p->parent == proc){
801048ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d1:	8b 50 14             	mov    0x14(%eax),%edx
801048d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048da:	39 c2                	cmp    %eax,%edx
801048dc:	75 24                	jne    80104902 <exit+0xed>
      p->parent = initproc;
801048de:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
801048e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e7:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ed:	8b 40 0c             	mov    0xc(%eax),%eax
801048f0:	83 f8 05             	cmp    $0x5,%eax
801048f3:	75 0d                	jne    80104902 <exit+0xed>
        wakeup1(initproc);
801048f5:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801048fa:	89 04 24             	mov    %eax,(%esp)
801048fd:	e8 20 08 00 00       	call   80105122 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104902:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104909:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
80104910:	72 bc                	jb     801048ce <exit+0xb9>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->priority = -1;
80104912:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104918:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
8010491f:	ff ff ff 
  acquire(&tickslock);
80104922:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80104929:	e8 c5 0a 00 00       	call   801053f3 <acquire>
  proc->etime = ticks;
8010492e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104934:	8b 15 c0 3c 11 80    	mov    0x80113cc0,%edx
8010493a:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
80104940:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80104947:	e8 09 0b 00 00       	call   80105455 <release>
  proc->state = ZOMBIE;
8010494c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104952:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104959:	e8 dd 05 00 00       	call   80104f3b <sched>
  panic("zombie exit");
8010495e:	c7 04 24 9d 8d 10 80 	movl   $0x80108d9d,(%esp)
80104965:	e8 d3 bb ff ff       	call   8010053d <panic>

8010496a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010496a:	55                   	push   %ebp
8010496b:	89 e5                	mov    %esp,%ebp
8010496d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104970:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104977:	e8 77 0a 00 00       	call   801053f3 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010497c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104983:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
8010498a:	e9 9d 00 00 00       	jmp    80104a2c <wait+0xc2>
      if(p->parent != proc)
8010498f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104992:	8b 50 14             	mov    0x14(%eax),%edx
80104995:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010499b:	39 c2                	cmp    %eax,%edx
8010499d:	0f 85 81 00 00 00    	jne    80104a24 <wait+0xba>
        continue;
      havekids = 1;
801049a3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801049aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ad:	8b 40 0c             	mov    0xc(%eax),%eax
801049b0:	83 f8 05             	cmp    $0x5,%eax
801049b3:	75 70                	jne    80104a25 <wait+0xbb>
        // Found one.
        pid = p->pid;
801049b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b8:	8b 40 10             	mov    0x10(%eax),%eax
801049bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801049be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c1:	8b 40 08             	mov    0x8(%eax),%eax
801049c4:	89 04 24             	mov    %eax,(%esp)
801049c7:	e8 0a e4 ff ff       	call   80102dd6 <kfree>
        p->kstack = 0;
801049cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d9:	8b 40 04             	mov    0x4(%eax),%eax
801049dc:	89 04 24             	mov    %eax,(%esp)
801049df:	e8 cd 3d 00 00       	call   801087b1 <freevm>
        p->state = UNUSED;
801049e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801049ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a05:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104a13:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104a1a:	e8 36 0a 00 00       	call   80105455 <release>
        return pid;
80104a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a22:	eb 56                	jmp    80104a7a <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104a24:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a25:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104a2c:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
80104a33:	0f 82 56 ff ff ff    	jb     8010498f <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104a39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a3d:	74 0d                	je     80104a4c <wait+0xe2>
80104a3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a45:	8b 40 24             	mov    0x24(%eax),%eax
80104a48:	85 c0                	test   %eax,%eax
80104a4a:	74 13                	je     80104a5f <wait+0xf5>
      release(&ptable.lock);
80104a4c:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104a53:	e8 fd 09 00 00       	call   80105455 <release>
      return -1;
80104a58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a5d:	eb 1b                	jmp    80104a7a <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a65:	c7 44 24 04 40 0f 11 	movl   $0x80110f40,0x4(%esp)
80104a6c:	80 
80104a6d:	89 04 24             	mov    %eax,(%esp)
80104a70:	e8 12 06 00 00       	call   80105087 <sleep>
  }
80104a75:	e9 02 ff ff ff       	jmp    8010497c <wait+0x12>
}
80104a7a:	c9                   	leave  
80104a7b:	c3                   	ret    

80104a7c <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a7c:	55                   	push   %ebp
80104a7d:	89 e5                	mov    %esp,%ebp
80104a7f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a82:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104a89:	e8 65 09 00 00       	call   801053f3 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a95:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
80104a9c:	e9 d0 00 00 00       	jmp    80104b71 <wait2+0xf5>
      if(p->parent != proc)
80104aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa4:	8b 50 14             	mov    0x14(%eax),%edx
80104aa7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aad:	39 c2                	cmp    %eax,%edx
80104aaf:	0f 85 b4 00 00 00    	jne    80104b69 <wait2+0xed>
        continue;
      havekids = 1;
80104ab5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abf:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac2:	83 f8 05             	cmp    $0x5,%eax
80104ac5:	0f 85 9f 00 00 00    	jne    80104b6a <wait2+0xee>
	*rtime = p->rtime;
80104acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ace:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ad7:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adc:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae5:	8b 40 7c             	mov    0x7c(%eax),%eax
80104ae8:	29 c2                	sub    %eax,%edx
80104aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aed:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104af3:	29 c2                	sub    %eax,%edx
80104af5:	8b 45 08             	mov    0x8(%ebp),%eax
80104af8:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afd:	8b 40 10             	mov    0x10(%eax),%eax
80104b00:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b06:	8b 40 08             	mov    0x8(%eax),%eax
80104b09:	89 04 24             	mov    %eax,(%esp)
80104b0c:	e8 c5 e2 ff ff       	call   80102dd6 <kfree>
        p->kstack = 0;
80104b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b14:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1e:	8b 40 04             	mov    0x4(%eax),%eax
80104b21:	89 04 24             	mov    %eax,(%esp)
80104b24:	e8 88 3c 00 00       	call   801087b1 <freevm>
        p->state = UNUSED;
80104b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b36:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b40:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b51:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b58:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104b5f:	e8 f1 08 00 00       	call   80105455 <release>
        return pid;
80104b64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b67:	eb 56                	jmp    80104bbf <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b69:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b6a:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104b71:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
80104b78:	0f 82 23 ff ff ff    	jb     80104aa1 <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b82:	74 0d                	je     80104b91 <wait2+0x115>
80104b84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b8a:	8b 40 24             	mov    0x24(%eax),%eax
80104b8d:	85 c0                	test   %eax,%eax
80104b8f:	74 13                	je     80104ba4 <wait2+0x128>
      release(&ptable.lock);
80104b91:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104b98:	e8 b8 08 00 00       	call   80105455 <release>
      return -1;
80104b9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba2:	eb 1b                	jmp    80104bbf <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104ba4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104baa:	c7 44 24 04 40 0f 11 	movl   $0x80110f40,0x4(%esp)
80104bb1:	80 
80104bb2:	89 04 24             	mov    %eax,(%esp)
80104bb5:	e8 cd 04 00 00       	call   80105087 <sleep>
  }
80104bba:	e9 cf fe ff ff       	jmp    80104a8e <wait2+0x12>
  
  
  return proc->pid;
}
80104bbf:	c9                   	leave  
80104bc0:	c3                   	ret    

80104bc1 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104bc1:	55                   	push   %ebp
80104bc2:	89 e5                	mov    %esp,%ebp
80104bc4:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104bc7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bcd:	8b 40 18             	mov    0x18(%eax),%eax
80104bd0:	8b 40 44             	mov    0x44(%eax),%eax
80104bd3:	89 c2                	mov    %eax,%edx
80104bd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdb:	8b 40 04             	mov    0x4(%eax),%eax
80104bde:	89 54 24 04          	mov    %edx,0x4(%esp)
80104be2:	89 04 24             	mov    %eax,(%esp)
80104be5:	e8 ac 3d 00 00       	call   80108996 <uva2ka>
80104bea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104bed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf3:	8b 40 18             	mov    0x18(%eax),%eax
80104bf6:	8b 40 44             	mov    0x44(%eax),%eax
80104bf9:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bfe:	85 c0                	test   %eax,%eax
80104c00:	75 0c                	jne    80104c0e <register_handler+0x4d>
    panic("esp_offset == 0");
80104c02:	c7 04 24 a9 8d 10 80 	movl   $0x80108da9,(%esp)
80104c09:	e8 2f b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104c0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c14:	8b 40 18             	mov    0x18(%eax),%eax
80104c17:	8b 40 44             	mov    0x44(%eax),%eax
80104c1a:	83 e8 04             	sub    $0x4,%eax
80104c1d:	25 ff 0f 00 00       	and    $0xfff,%eax
80104c22:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104c25:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c2c:	8b 52 18             	mov    0x18(%edx),%edx
80104c2f:	8b 52 38             	mov    0x38(%edx),%edx
80104c32:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104c34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c3a:	8b 40 18             	mov    0x18(%eax),%eax
80104c3d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c44:	8b 52 18             	mov    0x18(%edx),%edx
80104c47:	8b 52 44             	mov    0x44(%edx),%edx
80104c4a:	83 ea 04             	sub    $0x4,%edx
80104c4d:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104c50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c56:	8b 40 18             	mov    0x18(%eax),%eax
80104c59:	8b 55 08             	mov    0x8(%ebp),%edx
80104c5c:	89 50 38             	mov    %edx,0x38(%eax)
}
80104c5f:	c9                   	leave  
80104c60:	c3                   	ret    

80104c61 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c61:	55                   	push   %ebp
80104c62:	89 e5                	mov    %esp,%ebp
80104c64:	53                   	push   %ebx
80104c65:	83 ec 54             	sub    $0x54,%esp
  struct proc *p;
  struct proc *medium;
  struct proc *high;
  struct proc *head = 0;
80104c68:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  struct proc *t = ptable.proc;
80104c6f:	c7 45 e4 74 0f 11 80 	movl   $0x80110f74,-0x1c(%ebp)
  uint grt_min;
  
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c76:	e8 fa f6 ff ff       	call   80104375 <sti>
    highflag = 0;
80104c7b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    mediumflag = 0;
80104c82:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    lowflag = 0;
80104c89:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    frr_min = 0;
80104c90:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    grt_min = 0;
80104c97:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
    
    if(head && p==head)
80104c9e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104ca2:	74 17                	je     80104cbb <scheduler+0x5a>
80104ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca7:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80104caa:	75 0f                	jne    80104cbb <scheduler+0x5a>
      t = ++head;
80104cac:	81 45 e8 94 00 00 00 	addl   $0x94,-0x18(%ebp)
80104cb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104cb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104cb9:	eb 0c                	jmp    80104cc7 <scheduler+0x66>
    else if(head)
80104cbb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104cbf:	74 06                	je     80104cc7 <scheduler+0x66>
      t = head;
80104cc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104cc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    
    acquire(&tickslock);
80104cc7:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80104cce:	e8 20 07 00 00       	call   801053f3 <acquire>
    currentime = ticks;
80104cd3:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
80104cd8:	89 45 c8             	mov    %eax,-0x38(%ebp)
    release(&tickslock);  
80104cdb:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80104ce2:	e8 6e 07 00 00       	call   80105455 <release>
    int i=0;
80104ce7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
    acquire(&ptable.lock); 
80104cee:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104cf5:	e8 f9 06 00 00       	call   801053f3 <acquire>
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104cfa:	e9 84 01 00 00       	jmp    80104e83 <scheduler+0x222>
    {
      if(t >= &ptable.proc[NPROC])
80104cff:	81 7d e4 74 34 11 80 	cmpl   $0x80113474,-0x1c(%ebp)
80104d06:	72 07                	jb     80104d0f <scheduler+0xae>
	t = ptable.proc;
80104d08:	c7 45 e4 74 0f 11 80 	movl   $0x80110f74,-0x1c(%ebp)
      if(t->state != RUNNABLE)
80104d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d12:	8b 40 0c             	mov    0xc(%eax),%eax
80104d15:	83 f8 03             	cmp    $0x3,%eax
80104d18:	0f 84 be 00 00 00    	je     80104ddc <scheduler+0x17b>
      {
	t++;
80104d1e:	81 45 e4 94 00 00 00 	addl   $0x94,-0x1c(%ebp)
	continue;
80104d25:	e9 55 01 00 00       	jmp    80104e7f <scheduler+0x21e>
	  break;
	case _FRR:
FRR:	  t->quanta = QUANTA;
	  if(!frr_min)
	  {
	    frr_min = t->qvalue;
80104d2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d2d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d33:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	    medium = t;
80104d36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d39:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  else if(t->qvalue < frr_min)
	  {
	    frr_min = t->qvalue;
	    medium = t;
	  }
	  break;
80104d3c:	e9 30 01 00 00       	jmp    80104e71 <scheduler+0x210>
	  if(!frr_min)
	  {
	    frr_min = t->qvalue;
	    medium = t;
	  }
	  else if(t->qvalue < frr_min)
80104d41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d44:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d4a:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
80104d4d:	0f 83 1e 01 00 00    	jae    80104e71 <scheduler+0x210>
	  {
	    frr_min = t->qvalue;
80104d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d56:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104d5c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	    medium = t;
80104d5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d62:	89 45 f0             	mov    %eax,-0x10(%ebp)
	  }
	  break;
80104d65:	e9 07 01 00 00       	jmp    80104e71 <scheduler+0x210>
	case _GRT:
GRT:	  if(t->ctime!=currentime)
	    t->qvalue = t->rtime/(currentime-t->ctime);
80104d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d6d:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104d73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d76:	8b 52 7c             	mov    0x7c(%edx),%edx
80104d79:	8b 4d c8             	mov    -0x38(%ebp),%ecx
80104d7c:	89 cb                	mov    %ecx,%ebx
80104d7e:	29 d3                	sub    %edx,%ebx
80104d80:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
80104d83:	89 c2                	mov    %eax,%edx
80104d85:	c1 fa 1f             	sar    $0x1f,%edx
80104d88:	f7 7d c4             	idivl  -0x3c(%ebp)
80104d8b:	89 c2                	mov    %eax,%edx
80104d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d90:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
	  if(!grt_min)
80104d96:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80104d9a:	75 17                	jne    80104db3 <scheduler+0x152>
	  {
	    grt_min = t->qvalue;
80104d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d9f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104da5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	    high = t;
80104da8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104dab:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  else if(t->qvalue < grt_min)
	  {
	    grt_min = t->qvalue;
	    high = t;
	  }
	  break;
80104dae:	e9 c1 00 00 00       	jmp    80104e74 <scheduler+0x213>
	  if(!grt_min)
	  {
	    grt_min = t->qvalue;
	    high = t;
	  }
	  else if(t->qvalue < grt_min)
80104db3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104db6:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104dbc:	3b 45 d0             	cmp    -0x30(%ebp),%eax
80104dbf:	0f 83 af 00 00 00    	jae    80104e74 <scheduler+0x213>
	  {
	    grt_min = t->qvalue;
80104dc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104dc8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104dce:	89 45 d0             	mov    %eax,-0x30(%ebp)
	    high = t;
80104dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104dd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	  }
	  break;
80104dd7:	e9 98 00 00 00       	jmp    80104e74 <scheduler+0x213>
	case _3Q:
	  if(t->priority == HIGH || t->priority == 0)
80104ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ddf:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104de5:	83 f8 03             	cmp    $0x3,%eax
80104de8:	74 0d                	je     80104df7 <scheduler+0x196>
80104dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ded:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104df3:	85 c0                	test   %eax,%eax
80104df5:	75 18                	jne    80104e0f <scheduler+0x1ae>
	  {
	    highflag = 1;
80104df7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
	    goto GRT;
80104dfe:	90                   	nop
	    frr_min = t->qvalue;
	    medium = t;
	  }
	  break;
	case _GRT:
GRT:	  if(t->ctime!=currentime)
80104dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e02:	8b 40 7c             	mov    0x7c(%eax),%eax
80104e05:	3b 45 c8             	cmp    -0x38(%ebp),%eax
80104e08:	74 8c                	je     80104d96 <scheduler+0x135>
80104e0a:	e9 5b ff ff ff       	jmp    80104d6a <scheduler+0x109>
	  if(t->priority == HIGH || t->priority == 0)
	  {
	    highflag = 1;
	    goto GRT;
	  }
	  else if(t->priority == MEDIUM)
80104e0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e12:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104e18:	83 f8 02             	cmp    $0x2,%eax
80104e1b:	75 24                	jne    80104e41 <scheduler+0x1e0>
	  {
	    mediumflag = 1;
80104e1d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
	    goto FRR;
80104e24:	90                   	nop
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
	  break;
	case _FRR:
FRR:	  t->quanta = QUANTA;
80104e25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e28:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104e2f:	00 00 00 
	  if(!frr_min)
80104e32:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80104e36:	0f 85 05 ff ff ff    	jne    80104d41 <scheduler+0xe0>
80104e3c:	e9 e9 fe ff ff       	jmp    80104d2a <scheduler+0xc9>
	  else if(t->priority == MEDIUM)
	  {
	    mediumflag = 1;
	    goto FRR;
	  }
	  else if(!lowflag && t->priority == LOW)	// low - no proc has been choosen yet
80104e41:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80104e45:	75 30                	jne    80104e77 <scheduler+0x216>
80104e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e4a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104e50:	83 f8 01             	cmp    $0x1,%eax
80104e53:	75 22                	jne    80104e77 <scheduler+0x216>
	  {
	    head=t;
80104e55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e58:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    lowflag = 1;
80104e5b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
	    t->quanta = QUANTA;
80104e62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e65:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104e6c:	00 00 00 
	  }
	  break;
80104e6f:	eb 06                	jmp    80104e77 <scheduler+0x216>
	  else if(t->qvalue < frr_min)
	  {
	    frr_min = t->qvalue;
	    medium = t;
	  }
	  break;
80104e71:	90                   	nop
80104e72:	eb 04                	jmp    80104e78 <scheduler+0x217>
	  else if(t->qvalue < grt_min)
	  {
	    grt_min = t->qvalue;
	    high = t;
	  }
	  break;
80104e74:	90                   	nop
80104e75:	eb 01                	jmp    80104e78 <scheduler+0x217>
	  {
	    head=t;
	    lowflag = 1;
	    t->quanta = QUANTA;
	  }
	  break;
80104e77:	90                   	nop
      }
      t++;
80104e78:	81 45 e4 94 00 00 00 	addl   $0x94,-0x1c(%ebp)
    acquire(&tickslock);
    currentime = ticks;
    release(&tickslock);  
    int i=0;
    acquire(&ptable.lock); 
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104e7f:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
80104e83:	83 7d cc 3f          	cmpl   $0x3f,-0x34(%ebp)
80104e87:	0f 8e 72 fe ff ff    	jle    80104cff <scheduler+0x9e>
	p = medium;
      else if(SCHEDFLAG == _GRT)
	p = high;
      else
      {
	if(highflag && high)
80104e8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104e91:	74 0e                	je     80104ea1 <scheduler+0x240>
80104e93:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104e97:	74 08                	je     80104ea1 <scheduler+0x240>
	  p = high;
80104e99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e9f:	eb 2b                	jmp    80104ecc <scheduler+0x26b>
	else if(mediumflag && medium)
80104ea1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104ea5:	74 0e                	je     80104eb5 <scheduler+0x254>
80104ea7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104eab:	74 08                	je     80104eb5 <scheduler+0x254>
	  p = medium;
80104ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104eb3:	eb 17                	jmp    80104ecc <scheduler+0x26b>
	else if(head && head->state == RUNNABLE)
80104eb5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104eb9:	74 11                	je     80104ecc <scheduler+0x26b>
80104ebb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ebe:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec1:	83 f8 03             	cmp    $0x3,%eax
80104ec4:	75 06                	jne    80104ecc <scheduler+0x26b>
	    p = head;
80104ec6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      }     

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      if(p && p->state == RUNNABLE)
80104ecc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ed0:	74 58                	je     80104f2a <scheduler+0x2c9>
80104ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed8:	83 f8 03             	cmp    $0x3,%eax
80104edb:	75 4d                	jne    80104f2a <scheduler+0x2c9>
      {
	proc = p;
80104edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee0:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	switchuvm(p);
80104ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee9:	89 04 24             	mov    %eax,(%esp)
80104eec:	e8 49 34 00 00       	call   8010833a <switchuvm>
	p->state = RUNNING;
80104ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	swtch(&cpu->scheduler, proc->context);
80104efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f01:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f04:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f0b:	83 c2 04             	add    $0x4,%edx
80104f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f12:	89 14 24             	mov    %edx,(%esp)
80104f15:	e8 ce 09 00 00       	call   801058e8 <swtch>
	switchkvm();
80104f1a:	e8 fe 33 00 00       	call   8010831d <switchkvm>
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
80104f1f:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104f26:	00 00 00 00 
      }
    }
    release(&ptable.lock);
80104f2a:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104f31:	e8 1f 05 00 00       	call   80105455 <release>
    }
80104f36:	e9 3b fd ff ff       	jmp    80104c76 <scheduler+0x15>

80104f3b <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104f3b:	55                   	push   %ebp
80104f3c:	89 e5                	mov    %esp,%ebp
80104f3e:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104f41:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80104f48:	e8 c4 05 00 00       	call   80105511 <holding>
80104f4d:	85 c0                	test   %eax,%eax
80104f4f:	75 0c                	jne    80104f5d <sched+0x22>
    panic("sched ptable.lock");
80104f51:	c7 04 24 b9 8d 10 80 	movl   $0x80108db9,(%esp)
80104f58:	e8 e0 b5 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104f5d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f63:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f69:	83 f8 01             	cmp    $0x1,%eax
80104f6c:	74 0c                	je     80104f7a <sched+0x3f>
    panic("sched locks");
80104f6e:	c7 04 24 cb 8d 10 80 	movl   $0x80108dcb,(%esp)
80104f75:	e8 c3 b5 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104f7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f80:	8b 40 0c             	mov    0xc(%eax),%eax
80104f83:	83 f8 04             	cmp    $0x4,%eax
80104f86:	75 0c                	jne    80104f94 <sched+0x59>
    panic("sched running");
80104f88:	c7 04 24 d7 8d 10 80 	movl   $0x80108dd7,(%esp)
80104f8f:	e8 a9 b5 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104f94:	e8 c7 f3 ff ff       	call   80104360 <readeflags>
80104f99:	25 00 02 00 00       	and    $0x200,%eax
80104f9e:	85 c0                	test   %eax,%eax
80104fa0:	74 0c                	je     80104fae <sched+0x73>
    panic("sched interruptible");
80104fa2:	c7 04 24 e5 8d 10 80 	movl   $0x80108de5,(%esp)
80104fa9:	e8 8f b5 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104fae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fb4:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104fba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104fbd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fc3:	8b 40 04             	mov    0x4(%eax),%eax
80104fc6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104fcd:	83 c2 1c             	add    $0x1c,%edx
80104fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fd4:	89 14 24             	mov    %edx,(%esp)
80104fd7:	e8 0c 09 00 00       	call   801058e8 <swtch>
  cpu->intena = intena;
80104fdc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fe2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fe5:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104feb:	c9                   	leave  
80104fec:	c3                   	ret    

80104fed <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104fed:	55                   	push   %ebp
80104fee:	89 e5                	mov    %esp,%ebp
80104ff0:	83 ec 18             	sub    $0x18,%esp
      release(&tickslock);
      break;
    case _GRT:
      break;
    case _3Q:
      if(proc->priority == MEDIUM)
80104ff3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff9:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80104fff:	83 f8 02             	cmp    $0x2,%eax
80105002:	75 2a                	jne    8010502e <yield+0x41>
      {
	acquire(&tickslock);
80105004:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
8010500b:	e8 e3 03 00 00       	call   801053f3 <acquire>
	proc->qvalue = ticks;
80105010:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105016:	8b 15 c0 3c 11 80    	mov    0x80113cc0,%edx
8010501c:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
	release(&tickslock);
80105022:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80105029:	e8 27 04 00 00       	call   80105455 <release>
      }
      break;
8010502e:	90                   	nop
  }
  acquire(&ptable.lock);  //DOC: yieldlock
8010502f:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105036:	e8 b8 03 00 00       	call   801053f3 <acquire>
  proc->state = RUNNABLE;
8010503b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105041:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105048:	e8 ee fe ff ff       	call   80104f3b <sched>
  release(&ptable.lock);
8010504d:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105054:	e8 fc 03 00 00       	call   80105455 <release>
  
}
80105059:	c9                   	leave  
8010505a:	c3                   	ret    

8010505b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010505b:	55                   	push   %ebp
8010505c:	89 e5                	mov    %esp,%ebp
8010505e:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105061:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105068:	e8 e8 03 00 00       	call   80105455 <release>

  if (first) {
8010506d:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80105072:	85 c0                	test   %eax,%eax
80105074:	74 0f                	je     80105085 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105076:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
8010507d:	00 00 00 
    initlog();
80105080:	e8 fb e2 ff ff       	call   80103380 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105085:	c9                   	leave  
80105086:	c3                   	ret    

80105087 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105087:	55                   	push   %ebp
80105088:	89 e5                	mov    %esp,%ebp
8010508a:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
8010508d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105093:	85 c0                	test   %eax,%eax
80105095:	75 0c                	jne    801050a3 <sleep+0x1c>
    panic("sleep");
80105097:	c7 04 24 f9 8d 10 80 	movl   $0x80108df9,(%esp)
8010509e:	e8 9a b4 ff ff       	call   8010053d <panic>

  if(lk == 0)
801050a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801050a7:	75 0c                	jne    801050b5 <sleep+0x2e>
    panic("sleep without lk");
801050a9:	c7 04 24 ff 8d 10 80 	movl   $0x80108dff,(%esp)
801050b0:	e8 88 b4 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801050b5:	81 7d 0c 40 0f 11 80 	cmpl   $0x80110f40,0xc(%ebp)
801050bc:	74 17                	je     801050d5 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801050be:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801050c5:	e8 29 03 00 00       	call   801053f3 <acquire>
    release(lk);
801050ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801050cd:	89 04 24             	mov    %eax,(%esp)
801050d0:	e8 80 03 00 00       	call   80105455 <release>
  }

  // Go to sleep.
  proc->chan = chan;
801050d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050db:	8b 55 08             	mov    0x8(%ebp),%edx
801050de:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801050e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801050ee:	e8 48 fe ff ff       	call   80104f3b <sched>

  // Tidy up.
  proc->chan = 0;
801050f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050f9:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105100:	81 7d 0c 40 0f 11 80 	cmpl   $0x80110f40,0xc(%ebp)
80105107:	74 17                	je     80105120 <sleep+0x99>
    release(&ptable.lock);
80105109:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105110:	e8 40 03 00 00       	call   80105455 <release>
    acquire(lk);
80105115:	8b 45 0c             	mov    0xc(%ebp),%eax
80105118:	89 04 24             	mov    %eax,(%esp)
8010511b:	e8 d3 02 00 00       	call   801053f3 <acquire>
  }
}
80105120:	c9                   	leave  
80105121:	c3                   	ret    

80105122 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105122:	55                   	push   %ebp
80105123:	89 e5                	mov    %esp,%ebp
80105125:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105128:	c7 45 fc 74 0f 11 80 	movl   $0x80110f74,-0x4(%ebp)
8010512f:	eb 27                	jmp    80105158 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80105131:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105134:	8b 40 0c             	mov    0xc(%eax),%eax
80105137:	83 f8 02             	cmp    $0x2,%eax
8010513a:	75 15                	jne    80105151 <wakeup1+0x2f>
8010513c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010513f:	8b 40 20             	mov    0x20(%eax),%eax
80105142:	3b 45 08             	cmp    0x8(%ebp),%eax
80105145:	75 0a                	jne    80105151 <wakeup1+0x2f>
    {
      p->state = RUNNABLE;
80105147:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010514a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105151:	81 45 fc 94 00 00 00 	addl   $0x94,-0x4(%ebp)
80105158:	81 7d fc 74 34 11 80 	cmpl   $0x80113474,-0x4(%ebp)
8010515f:	72 d0                	jb     80105131 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
    }
}
80105161:	c9                   	leave  
80105162:	c3                   	ret    

80105163 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105163:	55                   	push   %ebp
80105164:	89 e5                	mov    %esp,%ebp
80105166:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80105169:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105170:	e8 7e 02 00 00       	call   801053f3 <acquire>
  wakeup1(chan);
80105175:	8b 45 08             	mov    0x8(%ebp),%eax
80105178:	89 04 24             	mov    %eax,(%esp)
8010517b:	e8 a2 ff ff ff       	call   80105122 <wakeup1>
  release(&ptable.lock);
80105180:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
80105187:	e8 c9 02 00 00       	call   80105455 <release>
}
8010518c:	c9                   	leave  
8010518d:	c3                   	ret    

8010518e <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010518e:	55                   	push   %ebp
8010518f:	89 e5                	mov    %esp,%ebp
80105191:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105194:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
8010519b:	e8 53 02 00 00       	call   801053f3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051a0:	c7 45 f4 74 0f 11 80 	movl   $0x80110f74,-0xc(%ebp)
801051a7:	eb 44                	jmp    801051ed <kill+0x5f>
    if(p->pid == pid){
801051a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ac:	8b 40 10             	mov    0x10(%eax),%eax
801051af:	3b 45 08             	cmp    0x8(%ebp),%eax
801051b2:	75 32                	jne    801051e6 <kill+0x58>
      p->killed = 1;
801051b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801051be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c1:	8b 40 0c             	mov    0xc(%eax),%eax
801051c4:	83 f8 02             	cmp    $0x2,%eax
801051c7:	75 0a                	jne    801051d3 <kill+0x45>
        p->state = RUNNABLE;
801051c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801051d3:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801051da:	e8 76 02 00 00       	call   80105455 <release>
      return 0;
801051df:	b8 00 00 00 00       	mov    $0x0,%eax
801051e4:	eb 21                	jmp    80105207 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051e6:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801051ed:	81 7d f4 74 34 11 80 	cmpl   $0x80113474,-0xc(%ebp)
801051f4:	72 b3                	jb     801051a9 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801051f6:	c7 04 24 40 0f 11 80 	movl   $0x80110f40,(%esp)
801051fd:	e8 53 02 00 00       	call   80105455 <release>
  return -1;
80105202:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105207:	c9                   	leave  
80105208:	c3                   	ret    

80105209 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105209:	55                   	push   %ebp
8010520a:	89 e5                	mov    %esp,%ebp
8010520c:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010520f:	c7 45 f0 74 0f 11 80 	movl   $0x80110f74,-0x10(%ebp)
80105216:	e9 db 00 00 00       	jmp    801052f6 <procdump+0xed>
    if(p->state == UNUSED)
8010521b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521e:	8b 40 0c             	mov    0xc(%eax),%eax
80105221:	85 c0                	test   %eax,%eax
80105223:	0f 84 c5 00 00 00    	je     801052ee <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105229:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010522c:	8b 40 0c             	mov    0xc(%eax),%eax
8010522f:	83 f8 05             	cmp    $0x5,%eax
80105232:	77 23                	ja     80105257 <procdump+0x4e>
80105234:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105237:	8b 40 0c             	mov    0xc(%eax),%eax
8010523a:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105241:	85 c0                	test   %eax,%eax
80105243:	74 12                	je     80105257 <procdump+0x4e>
      state = states[p->state];
80105245:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105248:	8b 40 0c             	mov    0xc(%eax),%eax
8010524b:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105252:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105255:	eb 07                	jmp    8010525e <procdump+0x55>
    else
      state = "???";
80105257:	c7 45 ec 10 8e 10 80 	movl   $0x80108e10,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010525e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105261:	8d 50 6c             	lea    0x6c(%eax),%edx
80105264:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105267:	8b 40 10             	mov    0x10(%eax),%eax
8010526a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010526e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105271:	89 54 24 08          	mov    %edx,0x8(%esp)
80105275:	89 44 24 04          	mov    %eax,0x4(%esp)
80105279:	c7 04 24 14 8e 10 80 	movl   $0x80108e14,(%esp)
80105280:	e8 1c b1 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80105285:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105288:	8b 40 0c             	mov    0xc(%eax),%eax
8010528b:	83 f8 02             	cmp    $0x2,%eax
8010528e:	75 50                	jne    801052e0 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105290:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105293:	8b 40 1c             	mov    0x1c(%eax),%eax
80105296:	8b 40 0c             	mov    0xc(%eax),%eax
80105299:	83 c0 08             	add    $0x8,%eax
8010529c:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010529f:	89 54 24 04          	mov    %edx,0x4(%esp)
801052a3:	89 04 24             	mov    %eax,(%esp)
801052a6:	e8 f9 01 00 00       	call   801054a4 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801052ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052b2:	eb 1b                	jmp    801052cf <procdump+0xc6>
        cprintf(" %p", pc[i]);
801052b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b7:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801052bf:	c7 04 24 1d 8e 10 80 	movl   $0x80108e1d,(%esp)
801052c6:	e8 d6 b0 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801052cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052cf:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801052d3:	7f 0b                	jg     801052e0 <procdump+0xd7>
801052d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052dc:	85 c0                	test   %eax,%eax
801052de:	75 d4                	jne    801052b4 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801052e0:	c7 04 24 21 8e 10 80 	movl   $0x80108e21,(%esp)
801052e7:	e8 b5 b0 ff ff       	call   801003a1 <cprintf>
801052ec:	eb 01                	jmp    801052ef <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801052ee:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052ef:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
801052f6:	81 7d f0 74 34 11 80 	cmpl   $0x80113474,-0x10(%ebp)
801052fd:	0f 82 18 ff ff ff    	jb     8010521b <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105303:	c9                   	leave  
80105304:	c3                   	ret    

80105305 <nice>:

int
nice(void)
{
80105305:	55                   	push   %ebp
80105306:	89 e5                	mov    %esp,%ebp
  if(proc)
80105308:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010530e:	85 c0                	test   %eax,%eax
80105310:	74 70                	je     80105382 <nice+0x7d>
  {
    if(proc->priority == HIGH)
80105312:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105318:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010531e:	83 f8 03             	cmp    $0x3,%eax
80105321:	75 32                	jne    80105355 <nice+0x50>
    {
      proc->priority--;
80105323:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105329:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
8010532f:	83 ea 01             	sub    $0x1,%edx
80105332:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      proc->qvalue = proc->ctime;
80105338:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010533e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105345:	8b 52 7c             	mov    0x7c(%edx),%edx
80105348:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
      return 0;
8010534e:	b8 00 00 00 00       	mov    $0x0,%eax
80105353:	eb 32                	jmp    80105387 <nice+0x82>
    }
    else if(proc->priority == MEDIUM)
80105355:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010535b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105361:	83 f8 02             	cmp    $0x2,%eax
80105364:	75 1c                	jne    80105382 <nice+0x7d>
    {
      proc->priority--;
80105366:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010536c:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80105372:	83 ea 01             	sub    $0x1,%edx
80105375:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      return 0;
8010537b:	b8 00 00 00 00       	mov    $0x0,%eax
80105380:	eb 05                	jmp    80105387 <nice+0x82>
    }
    
  }
  return -1;
80105382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105387:	5d                   	pop    %ebp
80105388:	c3                   	ret    
80105389:	00 00                	add    %al,(%eax)
	...

8010538c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010538c:	55                   	push   %ebp
8010538d:	89 e5                	mov    %esp,%ebp
8010538f:	53                   	push   %ebx
80105390:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105393:	9c                   	pushf  
80105394:	5b                   	pop    %ebx
80105395:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105398:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010539b:	83 c4 10             	add    $0x10,%esp
8010539e:	5b                   	pop    %ebx
8010539f:	5d                   	pop    %ebp
801053a0:	c3                   	ret    

801053a1 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801053a1:	55                   	push   %ebp
801053a2:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801053a4:	fa                   	cli    
}
801053a5:	5d                   	pop    %ebp
801053a6:	c3                   	ret    

801053a7 <sti>:

static inline void
sti(void)
{
801053a7:	55                   	push   %ebp
801053a8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801053aa:	fb                   	sti    
}
801053ab:	5d                   	pop    %ebp
801053ac:	c3                   	ret    

801053ad <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801053ad:	55                   	push   %ebp
801053ae:	89 e5                	mov    %esp,%ebp
801053b0:	53                   	push   %ebx
801053b1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801053b4:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801053b7:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801053ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801053bd:	89 c3                	mov    %eax,%ebx
801053bf:	89 d8                	mov    %ebx,%eax
801053c1:	f0 87 02             	lock xchg %eax,(%edx)
801053c4:	89 c3                	mov    %eax,%ebx
801053c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801053c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801053cc:	83 c4 10             	add    $0x10,%esp
801053cf:	5b                   	pop    %ebx
801053d0:	5d                   	pop    %ebp
801053d1:	c3                   	ret    

801053d2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801053d2:	55                   	push   %ebp
801053d3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801053d5:	8b 45 08             	mov    0x8(%ebp),%eax
801053d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801053db:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801053de:	8b 45 08             	mov    0x8(%ebp),%eax
801053e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801053e7:	8b 45 08             	mov    0x8(%ebp),%eax
801053ea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801053f1:	5d                   	pop    %ebp
801053f2:	c3                   	ret    

801053f3 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801053f3:	55                   	push   %ebp
801053f4:	89 e5                	mov    %esp,%ebp
801053f6:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801053f9:	e8 3d 01 00 00       	call   8010553b <pushcli>
  if(holding(lk))
801053fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105401:	89 04 24             	mov    %eax,(%esp)
80105404:	e8 08 01 00 00       	call   80105511 <holding>
80105409:	85 c0                	test   %eax,%eax
8010540b:	74 0c                	je     80105419 <acquire+0x26>
    panic("acquire");
8010540d:	c7 04 24 4d 8e 10 80 	movl   $0x80108e4d,(%esp)
80105414:	e8 24 b1 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105419:	90                   	nop
8010541a:	8b 45 08             	mov    0x8(%ebp),%eax
8010541d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105424:	00 
80105425:	89 04 24             	mov    %eax,(%esp)
80105428:	e8 80 ff ff ff       	call   801053ad <xchg>
8010542d:	85 c0                	test   %eax,%eax
8010542f:	75 e9                	jne    8010541a <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105431:	8b 45 08             	mov    0x8(%ebp),%eax
80105434:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010543b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010543e:	8b 45 08             	mov    0x8(%ebp),%eax
80105441:	83 c0 0c             	add    $0xc,%eax
80105444:	89 44 24 04          	mov    %eax,0x4(%esp)
80105448:	8d 45 08             	lea    0x8(%ebp),%eax
8010544b:	89 04 24             	mov    %eax,(%esp)
8010544e:	e8 51 00 00 00       	call   801054a4 <getcallerpcs>
}
80105453:	c9                   	leave  
80105454:	c3                   	ret    

80105455 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105455:	55                   	push   %ebp
80105456:	89 e5                	mov    %esp,%ebp
80105458:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010545b:	8b 45 08             	mov    0x8(%ebp),%eax
8010545e:	89 04 24             	mov    %eax,(%esp)
80105461:	e8 ab 00 00 00       	call   80105511 <holding>
80105466:	85 c0                	test   %eax,%eax
80105468:	75 0c                	jne    80105476 <release+0x21>
    panic("release");
8010546a:	c7 04 24 55 8e 10 80 	movl   $0x80108e55,(%esp)
80105471:	e8 c7 b0 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105476:	8b 45 08             	mov    0x8(%ebp),%eax
80105479:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105480:	8b 45 08             	mov    0x8(%ebp),%eax
80105483:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010548a:	8b 45 08             	mov    0x8(%ebp),%eax
8010548d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105494:	00 
80105495:	89 04 24             	mov    %eax,(%esp)
80105498:	e8 10 ff ff ff       	call   801053ad <xchg>

  popcli();
8010549d:	e8 e1 00 00 00       	call   80105583 <popcli>
}
801054a2:	c9                   	leave  
801054a3:	c3                   	ret    

801054a4 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801054a4:	55                   	push   %ebp
801054a5:	89 e5                	mov    %esp,%ebp
801054a7:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801054aa:	8b 45 08             	mov    0x8(%ebp),%eax
801054ad:	83 e8 08             	sub    $0x8,%eax
801054b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801054b3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801054ba:	eb 32                	jmp    801054ee <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801054bc:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801054c0:	74 47                	je     80105509 <getcallerpcs+0x65>
801054c2:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801054c9:	76 3e                	jbe    80105509 <getcallerpcs+0x65>
801054cb:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801054cf:	74 38                	je     80105509 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
801054d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054d4:	c1 e0 02             	shl    $0x2,%eax
801054d7:	03 45 0c             	add    0xc(%ebp),%eax
801054da:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054dd:	8b 52 04             	mov    0x4(%edx),%edx
801054e0:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
801054e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054e5:	8b 00                	mov    (%eax),%eax
801054e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801054ea:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054ee:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054f2:	7e c8                	jle    801054bc <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054f4:	eb 13                	jmp    80105509 <getcallerpcs+0x65>
    pcs[i] = 0;
801054f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054f9:	c1 e0 02             	shl    $0x2,%eax
801054fc:	03 45 0c             	add    0xc(%ebp),%eax
801054ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105505:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105509:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010550d:	7e e7                	jle    801054f6 <getcallerpcs+0x52>
    pcs[i] = 0;
}
8010550f:	c9                   	leave  
80105510:	c3                   	ret    

80105511 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105511:	55                   	push   %ebp
80105512:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105514:	8b 45 08             	mov    0x8(%ebp),%eax
80105517:	8b 00                	mov    (%eax),%eax
80105519:	85 c0                	test   %eax,%eax
8010551b:	74 17                	je     80105534 <holding+0x23>
8010551d:	8b 45 08             	mov    0x8(%ebp),%eax
80105520:	8b 50 08             	mov    0x8(%eax),%edx
80105523:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105529:	39 c2                	cmp    %eax,%edx
8010552b:	75 07                	jne    80105534 <holding+0x23>
8010552d:	b8 01 00 00 00       	mov    $0x1,%eax
80105532:	eb 05                	jmp    80105539 <holding+0x28>
80105534:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105539:	5d                   	pop    %ebp
8010553a:	c3                   	ret    

8010553b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010553b:	55                   	push   %ebp
8010553c:	89 e5                	mov    %esp,%ebp
8010553e:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105541:	e8 46 fe ff ff       	call   8010538c <readeflags>
80105546:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105549:	e8 53 fe ff ff       	call   801053a1 <cli>
  if(cpu->ncli++ == 0)
8010554e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105554:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010555a:	85 d2                	test   %edx,%edx
8010555c:	0f 94 c1             	sete   %cl
8010555f:	83 c2 01             	add    $0x1,%edx
80105562:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105568:	84 c9                	test   %cl,%cl
8010556a:	74 15                	je     80105581 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
8010556c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105572:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105575:	81 e2 00 02 00 00    	and    $0x200,%edx
8010557b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105581:	c9                   	leave  
80105582:	c3                   	ret    

80105583 <popcli>:

void
popcli(void)
{
80105583:	55                   	push   %ebp
80105584:	89 e5                	mov    %esp,%ebp
80105586:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105589:	e8 fe fd ff ff       	call   8010538c <readeflags>
8010558e:	25 00 02 00 00       	and    $0x200,%eax
80105593:	85 c0                	test   %eax,%eax
80105595:	74 0c                	je     801055a3 <popcli+0x20>
    panic("popcli - interruptible");
80105597:	c7 04 24 5d 8e 10 80 	movl   $0x80108e5d,(%esp)
8010559e:	e8 9a af ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
801055a3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055a9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801055af:	83 ea 01             	sub    $0x1,%edx
801055b2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801055b8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801055be:	85 c0                	test   %eax,%eax
801055c0:	79 0c                	jns    801055ce <popcli+0x4b>
    panic("popcli");
801055c2:	c7 04 24 74 8e 10 80 	movl   $0x80108e74,(%esp)
801055c9:	e8 6f af ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
801055ce:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055d4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801055da:	85 c0                	test   %eax,%eax
801055dc:	75 15                	jne    801055f3 <popcli+0x70>
801055de:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055e4:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801055ea:	85 c0                	test   %eax,%eax
801055ec:	74 05                	je     801055f3 <popcli+0x70>
    sti();
801055ee:	e8 b4 fd ff ff       	call   801053a7 <sti>
}
801055f3:	c9                   	leave  
801055f4:	c3                   	ret    
801055f5:	00 00                	add    %al,(%eax)
	...

801055f8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801055f8:	55                   	push   %ebp
801055f9:	89 e5                	mov    %esp,%ebp
801055fb:	57                   	push   %edi
801055fc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801055fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105600:	8b 55 10             	mov    0x10(%ebp),%edx
80105603:	8b 45 0c             	mov    0xc(%ebp),%eax
80105606:	89 cb                	mov    %ecx,%ebx
80105608:	89 df                	mov    %ebx,%edi
8010560a:	89 d1                	mov    %edx,%ecx
8010560c:	fc                   	cld    
8010560d:	f3 aa                	rep stos %al,%es:(%edi)
8010560f:	89 ca                	mov    %ecx,%edx
80105611:	89 fb                	mov    %edi,%ebx
80105613:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105616:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105619:	5b                   	pop    %ebx
8010561a:	5f                   	pop    %edi
8010561b:	5d                   	pop    %ebp
8010561c:	c3                   	ret    

8010561d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010561d:	55                   	push   %ebp
8010561e:	89 e5                	mov    %esp,%ebp
80105620:	57                   	push   %edi
80105621:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105622:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105625:	8b 55 10             	mov    0x10(%ebp),%edx
80105628:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562b:	89 cb                	mov    %ecx,%ebx
8010562d:	89 df                	mov    %ebx,%edi
8010562f:	89 d1                	mov    %edx,%ecx
80105631:	fc                   	cld    
80105632:	f3 ab                	rep stos %eax,%es:(%edi)
80105634:	89 ca                	mov    %ecx,%edx
80105636:	89 fb                	mov    %edi,%ebx
80105638:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010563b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010563e:	5b                   	pop    %ebx
8010563f:	5f                   	pop    %edi
80105640:	5d                   	pop    %ebp
80105641:	c3                   	ret    

80105642 <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
80105642:	55                   	push   %ebp
80105643:	89 e5                	mov    %esp,%ebp
80105645:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105648:	8b 45 08             	mov    0x8(%ebp),%eax
8010564b:	83 e0 03             	and    $0x3,%eax
8010564e:	85 c0                	test   %eax,%eax
80105650:	75 49                	jne    8010569b <memset+0x59>
80105652:	8b 45 10             	mov    0x10(%ebp),%eax
80105655:	83 e0 03             	and    $0x3,%eax
80105658:	85 c0                	test   %eax,%eax
8010565a:	75 3f                	jne    8010569b <memset+0x59>
    c &= 0xFF;
8010565c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105663:	8b 45 10             	mov    0x10(%ebp),%eax
80105666:	c1 e8 02             	shr    $0x2,%eax
80105669:	89 c2                	mov    %eax,%edx
8010566b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010566e:	89 c1                	mov    %eax,%ecx
80105670:	c1 e1 18             	shl    $0x18,%ecx
80105673:	8b 45 0c             	mov    0xc(%ebp),%eax
80105676:	c1 e0 10             	shl    $0x10,%eax
80105679:	09 c1                	or     %eax,%ecx
8010567b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010567e:	c1 e0 08             	shl    $0x8,%eax
80105681:	09 c8                	or     %ecx,%eax
80105683:	0b 45 0c             	or     0xc(%ebp),%eax
80105686:	89 54 24 08          	mov    %edx,0x8(%esp)
8010568a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010568e:	8b 45 08             	mov    0x8(%ebp),%eax
80105691:	89 04 24             	mov    %eax,(%esp)
80105694:	e8 84 ff ff ff       	call   8010561d <stosl>
80105699:	eb 19                	jmp    801056b4 <memset+0x72>
  } else
    stosb(dst, c, n);
8010569b:	8b 45 10             	mov    0x10(%ebp),%eax
8010569e:	89 44 24 08          	mov    %eax,0x8(%esp)
801056a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801056a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801056a9:	8b 45 08             	mov    0x8(%ebp),%eax
801056ac:	89 04 24             	mov    %eax,(%esp)
801056af:	e8 44 ff ff ff       	call   801055f8 <stosb>
  return dst;
801056b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056b7:	c9                   	leave  
801056b8:	c3                   	ret    

801056b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801056b9:	55                   	push   %ebp
801056ba:	89 e5                	mov    %esp,%ebp
801056bc:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801056bf:	8b 45 08             	mov    0x8(%ebp),%eax
801056c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801056c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801056cb:	eb 32                	jmp    801056ff <memcmp+0x46>
    if(*s1 != *s2)
801056cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056d0:	0f b6 10             	movzbl (%eax),%edx
801056d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056d6:	0f b6 00             	movzbl (%eax),%eax
801056d9:	38 c2                	cmp    %al,%dl
801056db:	74 1a                	je     801056f7 <memcmp+0x3e>
      return *s1 - *s2;
801056dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056e0:	0f b6 00             	movzbl (%eax),%eax
801056e3:	0f b6 d0             	movzbl %al,%edx
801056e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056e9:	0f b6 00             	movzbl (%eax),%eax
801056ec:	0f b6 c0             	movzbl %al,%eax
801056ef:	89 d1                	mov    %edx,%ecx
801056f1:	29 c1                	sub    %eax,%ecx
801056f3:	89 c8                	mov    %ecx,%eax
801056f5:	eb 1c                	jmp    80105713 <memcmp+0x5a>
    s1++, s2++;
801056f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056fb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801056ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105703:	0f 95 c0             	setne  %al
80105706:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010570a:	84 c0                	test   %al,%al
8010570c:	75 bf                	jne    801056cd <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010570e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105713:	c9                   	leave  
80105714:	c3                   	ret    

80105715 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105715:	55                   	push   %ebp
80105716:	89 e5                	mov    %esp,%ebp
80105718:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010571b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010571e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105721:	8b 45 08             	mov    0x8(%ebp),%eax
80105724:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105727:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010572a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010572d:	73 54                	jae    80105783 <memmove+0x6e>
8010572f:	8b 45 10             	mov    0x10(%ebp),%eax
80105732:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105735:	01 d0                	add    %edx,%eax
80105737:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010573a:	76 47                	jbe    80105783 <memmove+0x6e>
    s += n;
8010573c:	8b 45 10             	mov    0x10(%ebp),%eax
8010573f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105742:	8b 45 10             	mov    0x10(%ebp),%eax
80105745:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105748:	eb 13                	jmp    8010575d <memmove+0x48>
      *--d = *--s;
8010574a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010574e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105752:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105755:	0f b6 10             	movzbl (%eax),%edx
80105758:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010575b:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010575d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105761:	0f 95 c0             	setne  %al
80105764:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105768:	84 c0                	test   %al,%al
8010576a:	75 de                	jne    8010574a <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010576c:	eb 25                	jmp    80105793 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010576e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105771:	0f b6 10             	movzbl (%eax),%edx
80105774:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105777:	88 10                	mov    %dl,(%eax)
80105779:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010577d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105781:	eb 01                	jmp    80105784 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105783:	90                   	nop
80105784:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105788:	0f 95 c0             	setne  %al
8010578b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010578f:	84 c0                	test   %al,%al
80105791:	75 db                	jne    8010576e <memmove+0x59>
      *d++ = *s++;

  return dst;
80105793:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105796:	c9                   	leave  
80105797:	c3                   	ret    

80105798 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105798:	55                   	push   %ebp
80105799:	89 e5                	mov    %esp,%ebp
8010579b:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010579e:	8b 45 10             	mov    0x10(%ebp),%eax
801057a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801057a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801057ac:	8b 45 08             	mov    0x8(%ebp),%eax
801057af:	89 04 24             	mov    %eax,(%esp)
801057b2:	e8 5e ff ff ff       	call   80105715 <memmove>
}
801057b7:	c9                   	leave  
801057b8:	c3                   	ret    

801057b9 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801057b9:	55                   	push   %ebp
801057ba:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801057bc:	eb 0c                	jmp    801057ca <strncmp+0x11>
    n--, p++, q++;
801057be:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801057c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801057ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057ce:	74 1a                	je     801057ea <strncmp+0x31>
801057d0:	8b 45 08             	mov    0x8(%ebp),%eax
801057d3:	0f b6 00             	movzbl (%eax),%eax
801057d6:	84 c0                	test   %al,%al
801057d8:	74 10                	je     801057ea <strncmp+0x31>
801057da:	8b 45 08             	mov    0x8(%ebp),%eax
801057dd:	0f b6 10             	movzbl (%eax),%edx
801057e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801057e3:	0f b6 00             	movzbl (%eax),%eax
801057e6:	38 c2                	cmp    %al,%dl
801057e8:	74 d4                	je     801057be <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801057ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057ee:	75 07                	jne    801057f7 <strncmp+0x3e>
    return 0;
801057f0:	b8 00 00 00 00       	mov    $0x0,%eax
801057f5:	eb 18                	jmp    8010580f <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801057f7:	8b 45 08             	mov    0x8(%ebp),%eax
801057fa:	0f b6 00             	movzbl (%eax),%eax
801057fd:	0f b6 d0             	movzbl %al,%edx
80105800:	8b 45 0c             	mov    0xc(%ebp),%eax
80105803:	0f b6 00             	movzbl (%eax),%eax
80105806:	0f b6 c0             	movzbl %al,%eax
80105809:	89 d1                	mov    %edx,%ecx
8010580b:	29 c1                	sub    %eax,%ecx
8010580d:	89 c8                	mov    %ecx,%eax
}
8010580f:	5d                   	pop    %ebp
80105810:	c3                   	ret    

80105811 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105811:	55                   	push   %ebp
80105812:	89 e5                	mov    %esp,%ebp
80105814:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105817:	8b 45 08             	mov    0x8(%ebp),%eax
8010581a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010581d:	90                   	nop
8010581e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105822:	0f 9f c0             	setg   %al
80105825:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105829:	84 c0                	test   %al,%al
8010582b:	74 30                	je     8010585d <strncpy+0x4c>
8010582d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105830:	0f b6 10             	movzbl (%eax),%edx
80105833:	8b 45 08             	mov    0x8(%ebp),%eax
80105836:	88 10                	mov    %dl,(%eax)
80105838:	8b 45 08             	mov    0x8(%ebp),%eax
8010583b:	0f b6 00             	movzbl (%eax),%eax
8010583e:	84 c0                	test   %al,%al
80105840:	0f 95 c0             	setne  %al
80105843:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105847:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010584b:	84 c0                	test   %al,%al
8010584d:	75 cf                	jne    8010581e <strncpy+0xd>
    ;
  while(n-- > 0)
8010584f:	eb 0c                	jmp    8010585d <strncpy+0x4c>
    *s++ = 0;
80105851:	8b 45 08             	mov    0x8(%ebp),%eax
80105854:	c6 00 00             	movb   $0x0,(%eax)
80105857:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010585b:	eb 01                	jmp    8010585e <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010585d:	90                   	nop
8010585e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105862:	0f 9f c0             	setg   %al
80105865:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105869:	84 c0                	test   %al,%al
8010586b:	75 e4                	jne    80105851 <strncpy+0x40>
    *s++ = 0;
  return os;
8010586d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105870:	c9                   	leave  
80105871:	c3                   	ret    

80105872 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105872:	55                   	push   %ebp
80105873:	89 e5                	mov    %esp,%ebp
80105875:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105878:	8b 45 08             	mov    0x8(%ebp),%eax
8010587b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010587e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105882:	7f 05                	jg     80105889 <safestrcpy+0x17>
    return os;
80105884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105887:	eb 35                	jmp    801058be <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105889:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010588d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105891:	7e 22                	jle    801058b5 <safestrcpy+0x43>
80105893:	8b 45 0c             	mov    0xc(%ebp),%eax
80105896:	0f b6 10             	movzbl (%eax),%edx
80105899:	8b 45 08             	mov    0x8(%ebp),%eax
8010589c:	88 10                	mov    %dl,(%eax)
8010589e:	8b 45 08             	mov    0x8(%ebp),%eax
801058a1:	0f b6 00             	movzbl (%eax),%eax
801058a4:	84 c0                	test   %al,%al
801058a6:	0f 95 c0             	setne  %al
801058a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801058ad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801058b1:	84 c0                	test   %al,%al
801058b3:	75 d4                	jne    80105889 <safestrcpy+0x17>
    ;
  *s = 0;
801058b5:	8b 45 08             	mov    0x8(%ebp),%eax
801058b8:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801058bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058be:	c9                   	leave  
801058bf:	c3                   	ret    

801058c0 <strlen>:

int
strlen(const char *s)
{
801058c0:	55                   	push   %ebp
801058c1:	89 e5                	mov    %esp,%ebp
801058c3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801058c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801058cd:	eb 04                	jmp    801058d3 <strlen+0x13>
801058cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d6:	03 45 08             	add    0x8(%ebp),%eax
801058d9:	0f b6 00             	movzbl (%eax),%eax
801058dc:	84 c0                	test   %al,%al
801058de:	75 ef                	jne    801058cf <strlen+0xf>
    ;
  return n;
801058e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058e3:	c9                   	leave  
801058e4:	c3                   	ret    
801058e5:	00 00                	add    %al,(%eax)
	...

801058e8 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801058e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801058ec:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801058f0:	55                   	push   %ebp
  pushl %ebx
801058f1:	53                   	push   %ebx
  pushl %esi
801058f2:	56                   	push   %esi
  pushl %edi
801058f3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801058f4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801058f6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801058f8:	5f                   	pop    %edi
  popl %esi
801058f9:	5e                   	pop    %esi
  popl %ebx
801058fa:	5b                   	pop    %ebx
  popl %ebp
801058fb:	5d                   	pop    %ebp
  ret
801058fc:	c3                   	ret    
801058fd:	00 00                	add    %al,(%eax)
	...

80105900 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
80105903:	8b 45 08             	mov    0x8(%ebp),%eax
80105906:	8b 00                	mov    (%eax),%eax
80105908:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010590b:	76 0f                	jbe    8010591c <fetchint+0x1c>
8010590d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105910:	8d 50 04             	lea    0x4(%eax),%edx
80105913:	8b 45 08             	mov    0x8(%ebp),%eax
80105916:	8b 00                	mov    (%eax),%eax
80105918:	39 c2                	cmp    %eax,%edx
8010591a:	76 07                	jbe    80105923 <fetchint+0x23>
    return -1;
8010591c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105921:	eb 0f                	jmp    80105932 <fetchint+0x32>
  *ip = *(int*)(addr);
80105923:	8b 45 0c             	mov    0xc(%ebp),%eax
80105926:	8b 10                	mov    (%eax),%edx
80105928:	8b 45 10             	mov    0x10(%ebp),%eax
8010592b:	89 10                	mov    %edx,(%eax)
  return 0;
8010592d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105932:	5d                   	pop    %ebp
80105933:	c3                   	ret    

80105934 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80105934:	55                   	push   %ebp
80105935:	89 e5                	mov    %esp,%ebp
80105937:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
8010593a:	8b 45 08             	mov    0x8(%ebp),%eax
8010593d:	8b 00                	mov    (%eax),%eax
8010593f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105942:	77 07                	ja     8010594b <fetchstr+0x17>
    return -1;
80105944:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105949:	eb 45                	jmp    80105990 <fetchstr+0x5c>
  *pp = (char*)addr;
8010594b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010594e:	8b 45 10             	mov    0x10(%ebp),%eax
80105951:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
80105953:	8b 45 08             	mov    0x8(%ebp),%eax
80105956:	8b 00                	mov    (%eax),%eax
80105958:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010595b:	8b 45 10             	mov    0x10(%ebp),%eax
8010595e:	8b 00                	mov    (%eax),%eax
80105960:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105963:	eb 1e                	jmp    80105983 <fetchstr+0x4f>
    if(*s == 0)
80105965:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105968:	0f b6 00             	movzbl (%eax),%eax
8010596b:	84 c0                	test   %al,%al
8010596d:	75 10                	jne    8010597f <fetchstr+0x4b>
      return s - *pp;
8010596f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105972:	8b 45 10             	mov    0x10(%ebp),%eax
80105975:	8b 00                	mov    (%eax),%eax
80105977:	89 d1                	mov    %edx,%ecx
80105979:	29 c1                	sub    %eax,%ecx
8010597b:	89 c8                	mov    %ecx,%eax
8010597d:	eb 11                	jmp    80105990 <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
8010597f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105983:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105986:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105989:	72 da                	jb     80105965 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
8010598b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105990:	c9                   	leave  
80105991:	c3                   	ret    

80105992 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105992:	55                   	push   %ebp
80105993:	89 e5                	mov    %esp,%ebp
80105995:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105998:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010599e:	8b 40 18             	mov    0x18(%eax),%eax
801059a1:	8b 50 44             	mov    0x44(%eax),%edx
801059a4:	8b 45 08             	mov    0x8(%ebp),%eax
801059a7:	c1 e0 02             	shl    $0x2,%eax
801059aa:	01 d0                	add    %edx,%eax
801059ac:	8d 48 04             	lea    0x4(%eax),%ecx
801059af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059b5:	8b 55 0c             	mov    0xc(%ebp),%edx
801059b8:	89 54 24 08          	mov    %edx,0x8(%esp)
801059bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801059c0:	89 04 24             	mov    %eax,(%esp)
801059c3:	e8 38 ff ff ff       	call   80105900 <fetchint>
}
801059c8:	c9                   	leave  
801059c9:	c3                   	ret    

801059ca <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801059ca:	55                   	push   %ebp
801059cb:	89 e5                	mov    %esp,%ebp
801059cd:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801059d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
801059d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801059d7:	8b 45 08             	mov    0x8(%ebp),%eax
801059da:	89 04 24             	mov    %eax,(%esp)
801059dd:	e8 b0 ff ff ff       	call   80105992 <argint>
801059e2:	85 c0                	test   %eax,%eax
801059e4:	79 07                	jns    801059ed <argptr+0x23>
    return -1;
801059e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059eb:	eb 3d                	jmp    80105a2a <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801059ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059f0:	89 c2                	mov    %eax,%edx
801059f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059f8:	8b 00                	mov    (%eax),%eax
801059fa:	39 c2                	cmp    %eax,%edx
801059fc:	73 16                	jae    80105a14 <argptr+0x4a>
801059fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a01:	89 c2                	mov    %eax,%edx
80105a03:	8b 45 10             	mov    0x10(%ebp),%eax
80105a06:	01 c2                	add    %eax,%edx
80105a08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a0e:	8b 00                	mov    (%eax),%eax
80105a10:	39 c2                	cmp    %eax,%edx
80105a12:	76 07                	jbe    80105a1b <argptr+0x51>
    return -1;
80105a14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a19:	eb 0f                	jmp    80105a2a <argptr+0x60>
  *pp = (char*)i;
80105a1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a1e:	89 c2                	mov    %eax,%edx
80105a20:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a23:	89 10                	mov    %edx,(%eax)
  return 0;
80105a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a2a:	c9                   	leave  
80105a2b:	c3                   	ret    

80105a2c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105a2c:	55                   	push   %ebp
80105a2d:	89 e5                	mov    %esp,%ebp
80105a2f:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105a32:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105a35:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a39:	8b 45 08             	mov    0x8(%ebp),%eax
80105a3c:	89 04 24             	mov    %eax,(%esp)
80105a3f:	e8 4e ff ff ff       	call   80105992 <argint>
80105a44:	85 c0                	test   %eax,%eax
80105a46:	79 07                	jns    80105a4f <argstr+0x23>
    return -1;
80105a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4d:	eb 1e                	jmp    80105a6d <argstr+0x41>
  return fetchstr(proc, addr, pp);
80105a4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a52:	89 c2                	mov    %eax,%edx
80105a54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105a5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a61:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a65:	89 04 24             	mov    %eax,(%esp)
80105a68:	e8 c7 fe ff ff       	call   80105934 <fetchstr>
}
80105a6d:	c9                   	leave  
80105a6e:	c3                   	ret    

80105a6f <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105a6f:	55                   	push   %ebp
80105a70:	89 e5                	mov    %esp,%ebp
80105a72:	53                   	push   %ebx
80105a73:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105a76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a7c:	8b 40 18             	mov    0x18(%eax),%eax
80105a7f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105a85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a89:	78 2e                	js     80105ab9 <syscall+0x4a>
80105a8b:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105a8f:	7f 28                	jg     80105ab9 <syscall+0x4a>
80105a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a94:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a9b:	85 c0                	test   %eax,%eax
80105a9d:	74 1a                	je     80105ab9 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105a9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105aa5:	8b 58 18             	mov    0x18(%eax),%ebx
80105aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aab:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105ab2:	ff d0                	call   *%eax
80105ab4:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105ab7:	eb 73                	jmp    80105b2c <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105ab9:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105abd:	7e 30                	jle    80105aef <syscall+0x80>
80105abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac2:	83 f8 17             	cmp    $0x17,%eax
80105ac5:	77 28                	ja     80105aef <syscall+0x80>
80105ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aca:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105ad1:	85 c0                	test   %eax,%eax
80105ad3:	74 1a                	je     80105aef <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105ad5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105adb:	8b 58 18             	mov    0x18(%eax),%ebx
80105ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae1:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105ae8:	ff d0                	call   *%eax
80105aea:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105aed:	eb 3d                	jmp    80105b2c <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105aef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105af5:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105af8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105afe:	8b 40 10             	mov    0x10(%eax),%eax
80105b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b04:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105b08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b10:	c7 04 24 7b 8e 10 80 	movl   $0x80108e7b,(%esp)
80105b17:	e8 85 a8 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105b1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b22:	8b 40 18             	mov    0x18(%eax),%eax
80105b25:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105b2c:	83 c4 24             	add    $0x24,%esp
80105b2f:	5b                   	pop    %ebx
80105b30:	5d                   	pop    %ebp
80105b31:	c3                   	ret    
	...

80105b34 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105b34:	55                   	push   %ebp
80105b35:	89 e5                	mov    %esp,%ebp
80105b37:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105b3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b41:	8b 45 08             	mov    0x8(%ebp),%eax
80105b44:	89 04 24             	mov    %eax,(%esp)
80105b47:	e8 46 fe ff ff       	call   80105992 <argint>
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	79 07                	jns    80105b57 <argfd+0x23>
    return -1;
80105b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b55:	eb 50                	jmp    80105ba7 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5a:	85 c0                	test   %eax,%eax
80105b5c:	78 21                	js     80105b7f <argfd+0x4b>
80105b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b61:	83 f8 0f             	cmp    $0xf,%eax
80105b64:	7f 19                	jg     80105b7f <argfd+0x4b>
80105b66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b6f:	83 c2 08             	add    $0x8,%edx
80105b72:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b7d:	75 07                	jne    80105b86 <argfd+0x52>
    return -1;
80105b7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b84:	eb 21                	jmp    80105ba7 <argfd+0x73>
  if(pfd)
80105b86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b8a:	74 08                	je     80105b94 <argfd+0x60>
    *pfd = fd;
80105b8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b92:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b98:	74 08                	je     80105ba2 <argfd+0x6e>
    *pf = f;
80105b9a:	8b 45 10             	mov    0x10(%ebp),%eax
80105b9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ba0:	89 10                	mov    %edx,(%eax)
  return 0;
80105ba2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba7:	c9                   	leave  
80105ba8:	c3                   	ret    

80105ba9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ba9:	55                   	push   %ebp
80105baa:	89 e5                	mov    %esp,%ebp
80105bac:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105baf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105bb6:	eb 30                	jmp    80105be8 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105bb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bbe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105bc1:	83 c2 08             	add    $0x8,%edx
80105bc4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105bc8:	85 c0                	test   %eax,%eax
80105bca:	75 18                	jne    80105be4 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105bcc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bd2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105bd5:	8d 4a 08             	lea    0x8(%edx),%ecx
80105bd8:	8b 55 08             	mov    0x8(%ebp),%edx
80105bdb:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105bdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105be2:	eb 0f                	jmp    80105bf3 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105be4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105be8:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105bec:	7e ca                	jle    80105bb8 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105bee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bf3:	c9                   	leave  
80105bf4:	c3                   	ret    

80105bf5 <sys_dup>:

int
sys_dup(void)
{
80105bf5:	55                   	push   %ebp
80105bf6:	89 e5                	mov    %esp,%ebp
80105bf8:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105bfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c09:	00 
80105c0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c11:	e8 1e ff ff ff       	call   80105b34 <argfd>
80105c16:	85 c0                	test   %eax,%eax
80105c18:	79 07                	jns    80105c21 <sys_dup+0x2c>
    return -1;
80105c1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1f:	eb 29                	jmp    80105c4a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c24:	89 04 24             	mov    %eax,(%esp)
80105c27:	e8 7d ff ff ff       	call   80105ba9 <fdalloc>
80105c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c33:	79 07                	jns    80105c3c <sys_dup+0x47>
    return -1;
80105c35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3a:	eb 0e                	jmp    80105c4a <sys_dup+0x55>
  filedup(f);
80105c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3f:	89 04 24             	mov    %eax,(%esp)
80105c42:	e8 a5 b6 ff ff       	call   801012ec <filedup>
  return fd;
80105c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c4a:	c9                   	leave  
80105c4b:	c3                   	ret    

80105c4c <sys_read>:

int
sys_read(void)
{
80105c4c:	55                   	push   %ebp
80105c4d:	89 e5                	mov    %esp,%ebp
80105c4f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c55:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c60:	00 
80105c61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c68:	e8 c7 fe ff ff       	call   80105b34 <argfd>
80105c6d:	85 c0                	test   %eax,%eax
80105c6f:	78 35                	js     80105ca6 <sys_read+0x5a>
80105c71:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c74:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c78:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c7f:	e8 0e fd ff ff       	call   80105992 <argint>
80105c84:	85 c0                	test   %eax,%eax
80105c86:	78 1e                	js     80105ca6 <sys_read+0x5a>
80105c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c8f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c92:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c9d:	e8 28 fd ff ff       	call   801059ca <argptr>
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	79 07                	jns    80105cad <sys_read+0x61>
    return -1;
80105ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cab:	eb 19                	jmp    80105cc6 <sys_read+0x7a>
  return fileread(f, p, n);
80105cad:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105cb0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105cba:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cbe:	89 04 24             	mov    %eax,(%esp)
80105cc1:	e8 93 b7 ff ff       	call   80101459 <fileread>
}
80105cc6:	c9                   	leave  
80105cc7:	c3                   	ret    

80105cc8 <sys_write>:

int
sys_write(void)
{
80105cc8:	55                   	push   %ebp
80105cc9:	89 e5                	mov    %esp,%ebp
80105ccb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105cce:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cd1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cdc:	00 
80105cdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ce4:	e8 4b fe ff ff       	call   80105b34 <argfd>
80105ce9:	85 c0                	test   %eax,%eax
80105ceb:	78 35                	js     80105d22 <sys_write+0x5a>
80105ced:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cf4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105cfb:	e8 92 fc ff ff       	call   80105992 <argint>
80105d00:	85 c0                	test   %eax,%eax
80105d02:	78 1e                	js     80105d22 <sys_write+0x5a>
80105d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d07:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d0b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d19:	e8 ac fc ff ff       	call   801059ca <argptr>
80105d1e:	85 c0                	test   %eax,%eax
80105d20:	79 07                	jns    80105d29 <sys_write+0x61>
    return -1;
80105d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d27:	eb 19                	jmp    80105d42 <sys_write+0x7a>
  return filewrite(f, p, n);
80105d29:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d2c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d32:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d36:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d3a:	89 04 24             	mov    %eax,(%esp)
80105d3d:	e8 d3 b7 ff ff       	call   80101515 <filewrite>
}
80105d42:	c9                   	leave  
80105d43:	c3                   	ret    

80105d44 <sys_close>:

int
sys_close(void)
{
80105d44:	55                   	push   %ebp
80105d45:	89 e5                	mov    %esp,%ebp
80105d47:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105d4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d4d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d54:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d5f:	e8 d0 fd ff ff       	call   80105b34 <argfd>
80105d64:	85 c0                	test   %eax,%eax
80105d66:	79 07                	jns    80105d6f <sys_close+0x2b>
    return -1;
80105d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6d:	eb 24                	jmp    80105d93 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105d6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d78:	83 c2 08             	add    $0x8,%edx
80105d7b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d82:	00 
  fileclose(f);
80105d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d86:	89 04 24             	mov    %eax,(%esp)
80105d89:	e8 a6 b5 ff ff       	call   80101334 <fileclose>
  return 0;
80105d8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d93:	c9                   	leave  
80105d94:	c3                   	ret    

80105d95 <sys_fstat>:

int
sys_fstat(void)
{
80105d95:	55                   	push   %ebp
80105d96:	89 e5                	mov    %esp,%ebp
80105d98:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d9e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105da2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105da9:	00 
80105daa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105db1:	e8 7e fd ff ff       	call   80105b34 <argfd>
80105db6:	85 c0                	test   %eax,%eax
80105db8:	78 1f                	js     80105dd9 <sys_fstat+0x44>
80105dba:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105dc1:	00 
80105dc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105dd0:	e8 f5 fb ff ff       	call   801059ca <argptr>
80105dd5:	85 c0                	test   %eax,%eax
80105dd7:	79 07                	jns    80105de0 <sys_fstat+0x4b>
    return -1;
80105dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dde:	eb 12                	jmp    80105df2 <sys_fstat+0x5d>
  return filestat(f, st);
80105de0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105dea:	89 04 24             	mov    %eax,(%esp)
80105ded:	e8 18 b6 ff ff       	call   8010140a <filestat>
}
80105df2:	c9                   	leave  
80105df3:	c3                   	ret    

80105df4 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105df4:	55                   	push   %ebp
80105df5:	89 e5                	mov    %esp,%ebp
80105df7:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105dfa:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e08:	e8 1f fc ff ff       	call   80105a2c <argstr>
80105e0d:	85 c0                	test   %eax,%eax
80105e0f:	78 17                	js     80105e28 <sys_link+0x34>
80105e11:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105e14:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e1f:	e8 08 fc ff ff       	call   80105a2c <argstr>
80105e24:	85 c0                	test   %eax,%eax
80105e26:	79 0a                	jns    80105e32 <sys_link+0x3e>
    return -1;
80105e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2d:	e9 3c 01 00 00       	jmp    80105f6e <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105e32:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105e35:	89 04 24             	mov    %eax,(%esp)
80105e38:	e8 3d c9 ff ff       	call   8010277a <namei>
80105e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e44:	75 0a                	jne    80105e50 <sys_link+0x5c>
    return -1;
80105e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e4b:	e9 1e 01 00 00       	jmp    80105f6e <sys_link+0x17a>

  begin_trans();
80105e50:	e8 38 d7 ff ff       	call   8010358d <begin_trans>

  ilock(ip);
80105e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e58:	89 04 24             	mov    %eax,(%esp)
80105e5b:	e8 78 bd ff ff       	call   80101bd8 <ilock>
  if(ip->type == T_DIR){
80105e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e63:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e67:	66 83 f8 01          	cmp    $0x1,%ax
80105e6b:	75 1a                	jne    80105e87 <sys_link+0x93>
    iunlockput(ip);
80105e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e70:	89 04 24             	mov    %eax,(%esp)
80105e73:	e8 e4 bf ff ff       	call   80101e5c <iunlockput>
    commit_trans();
80105e78:	e8 59 d7 ff ff       	call   801035d6 <commit_trans>
    return -1;
80105e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e82:	e9 e7 00 00 00       	jmp    80105f6e <sys_link+0x17a>
  }

  ip->nlink++;
80105e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e8e:	8d 50 01             	lea    0x1(%eax),%edx
80105e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e94:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9b:	89 04 24             	mov    %eax,(%esp)
80105e9e:	e8 79 bb ff ff       	call   80101a1c <iupdate>
  iunlock(ip);
80105ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea6:	89 04 24             	mov    %eax,(%esp)
80105ea9:	e8 78 be ff ff       	call   80101d26 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105eae:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105eb1:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105eb4:	89 54 24 04          	mov    %edx,0x4(%esp)
80105eb8:	89 04 24             	mov    %eax,(%esp)
80105ebb:	e8 dc c8 ff ff       	call   8010279c <nameiparent>
80105ec0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ec3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ec7:	74 68                	je     80105f31 <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecc:	89 04 24             	mov    %eax,(%esp)
80105ecf:	e8 04 bd ff ff       	call   80101bd8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed7:	8b 10                	mov    (%eax),%edx
80105ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edc:	8b 00                	mov    (%eax),%eax
80105ede:	39 c2                	cmp    %eax,%edx
80105ee0:	75 20                	jne    80105f02 <sys_link+0x10e>
80105ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee5:	8b 40 04             	mov    0x4(%eax),%eax
80105ee8:	89 44 24 08          	mov    %eax,0x8(%esp)
80105eec:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105eef:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef6:	89 04 24             	mov    %eax,(%esp)
80105ef9:	e8 bb c5 ff ff       	call   801024b9 <dirlink>
80105efe:	85 c0                	test   %eax,%eax
80105f00:	79 0d                	jns    80105f0f <sys_link+0x11b>
    iunlockput(dp);
80105f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f05:	89 04 24             	mov    %eax,(%esp)
80105f08:	e8 4f bf ff ff       	call   80101e5c <iunlockput>
    goto bad;
80105f0d:	eb 23                	jmp    80105f32 <sys_link+0x13e>
  }
  iunlockput(dp);
80105f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f12:	89 04 24             	mov    %eax,(%esp)
80105f15:	e8 42 bf ff ff       	call   80101e5c <iunlockput>
  iput(ip);
80105f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1d:	89 04 24             	mov    %eax,(%esp)
80105f20:	e8 66 be ff ff       	call   80101d8b <iput>

  commit_trans();
80105f25:	e8 ac d6 ff ff       	call   801035d6 <commit_trans>

  return 0;
80105f2a:	b8 00 00 00 00       	mov    $0x0,%eax
80105f2f:	eb 3d                	jmp    80105f6e <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105f31:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f35:	89 04 24             	mov    %eax,(%esp)
80105f38:	e8 9b bc ff ff       	call   80101bd8 <ilock>
  ip->nlink--;
80105f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f40:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f44:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f51:	89 04 24             	mov    %eax,(%esp)
80105f54:	e8 c3 ba ff ff       	call   80101a1c <iupdate>
  iunlockput(ip);
80105f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5c:	89 04 24             	mov    %eax,(%esp)
80105f5f:	e8 f8 be ff ff       	call   80101e5c <iunlockput>
  commit_trans();
80105f64:	e8 6d d6 ff ff       	call   801035d6 <commit_trans>
  return -1;
80105f69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f6e:	c9                   	leave  
80105f6f:	c3                   	ret    

80105f70 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105f70:	55                   	push   %ebp
80105f71:	89 e5                	mov    %esp,%ebp
80105f73:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f76:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105f7d:	eb 4b                	jmp    80105fca <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f82:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f89:	00 
80105f8a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f8e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f91:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f95:	8b 45 08             	mov    0x8(%ebp),%eax
80105f98:	89 04 24             	mov    %eax,(%esp)
80105f9b:	e8 2e c1 ff ff       	call   801020ce <readi>
80105fa0:	83 f8 10             	cmp    $0x10,%eax
80105fa3:	74 0c                	je     80105fb1 <isdirempty+0x41>
      panic("isdirempty: readi");
80105fa5:	c7 04 24 97 8e 10 80 	movl   $0x80108e97,(%esp)
80105fac:	e8 8c a5 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105fb1:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105fb5:	66 85 c0             	test   %ax,%ax
80105fb8:	74 07                	je     80105fc1 <isdirempty+0x51>
      return 0;
80105fba:	b8 00 00 00 00       	mov    $0x0,%eax
80105fbf:	eb 1b                	jmp    80105fdc <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc4:	83 c0 10             	add    $0x10,%eax
80105fc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd0:	8b 40 18             	mov    0x18(%eax),%eax
80105fd3:	39 c2                	cmp    %eax,%edx
80105fd5:	72 a8                	jb     80105f7f <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105fd7:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105fdc:	c9                   	leave  
80105fdd:	c3                   	ret    

80105fde <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105fde:	55                   	push   %ebp
80105fdf:	89 e5                	mov    %esp,%ebp
80105fe1:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105fe4:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105feb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ff2:	e8 35 fa ff ff       	call   80105a2c <argstr>
80105ff7:	85 c0                	test   %eax,%eax
80105ff9:	79 0a                	jns    80106005 <sys_unlink+0x27>
    return -1;
80105ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106000:	e9 aa 01 00 00       	jmp    801061af <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80106005:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106008:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010600b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010600f:	89 04 24             	mov    %eax,(%esp)
80106012:	e8 85 c7 ff ff       	call   8010279c <nameiparent>
80106017:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010601a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010601e:	75 0a                	jne    8010602a <sys_unlink+0x4c>
    return -1;
80106020:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106025:	e9 85 01 00 00       	jmp    801061af <sys_unlink+0x1d1>

  begin_trans();
8010602a:	e8 5e d5 ff ff       	call   8010358d <begin_trans>

  ilock(dp);
8010602f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106032:	89 04 24             	mov    %eax,(%esp)
80106035:	e8 9e bb ff ff       	call   80101bd8 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010603a:	c7 44 24 04 a9 8e 10 	movl   $0x80108ea9,0x4(%esp)
80106041:	80 
80106042:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106045:	89 04 24             	mov    %eax,(%esp)
80106048:	e8 82 c3 ff ff       	call   801023cf <namecmp>
8010604d:	85 c0                	test   %eax,%eax
8010604f:	0f 84 45 01 00 00    	je     8010619a <sys_unlink+0x1bc>
80106055:	c7 44 24 04 ab 8e 10 	movl   $0x80108eab,0x4(%esp)
8010605c:	80 
8010605d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106060:	89 04 24             	mov    %eax,(%esp)
80106063:	e8 67 c3 ff ff       	call   801023cf <namecmp>
80106068:	85 c0                	test   %eax,%eax
8010606a:	0f 84 2a 01 00 00    	je     8010619a <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106070:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106073:	89 44 24 08          	mov    %eax,0x8(%esp)
80106077:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010607a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010607e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106081:	89 04 24             	mov    %eax,(%esp)
80106084:	e8 68 c3 ff ff       	call   801023f1 <dirlookup>
80106089:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010608c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106090:	0f 84 03 01 00 00    	je     80106199 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80106096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106099:	89 04 24             	mov    %eax,(%esp)
8010609c:	e8 37 bb ff ff       	call   80101bd8 <ilock>

  if(ip->nlink < 1)
801060a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060a8:	66 85 c0             	test   %ax,%ax
801060ab:	7f 0c                	jg     801060b9 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
801060ad:	c7 04 24 ae 8e 10 80 	movl   $0x80108eae,(%esp)
801060b4:	e8 84 a4 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801060b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060bc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060c0:	66 83 f8 01          	cmp    $0x1,%ax
801060c4:	75 1f                	jne    801060e5 <sys_unlink+0x107>
801060c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c9:	89 04 24             	mov    %eax,(%esp)
801060cc:	e8 9f fe ff ff       	call   80105f70 <isdirempty>
801060d1:	85 c0                	test   %eax,%eax
801060d3:	75 10                	jne    801060e5 <sys_unlink+0x107>
    iunlockput(ip);
801060d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d8:	89 04 24             	mov    %eax,(%esp)
801060db:	e8 7c bd ff ff       	call   80101e5c <iunlockput>
    goto bad;
801060e0:	e9 b5 00 00 00       	jmp    8010619a <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
801060e5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801060ec:	00 
801060ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801060f4:	00 
801060f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801060f8:	89 04 24             	mov    %eax,(%esp)
801060fb:	e8 42 f5 ff ff       	call   80105642 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106100:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106103:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010610a:	00 
8010610b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010610f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106112:	89 44 24 04          	mov    %eax,0x4(%esp)
80106116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106119:	89 04 24             	mov    %eax,(%esp)
8010611c:	e8 18 c1 ff ff       	call   80102239 <writei>
80106121:	83 f8 10             	cmp    $0x10,%eax
80106124:	74 0c                	je     80106132 <sys_unlink+0x154>
    panic("unlink: writei");
80106126:	c7 04 24 c0 8e 10 80 	movl   $0x80108ec0,(%esp)
8010612d:	e8 0b a4 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80106132:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106135:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106139:	66 83 f8 01          	cmp    $0x1,%ax
8010613d:	75 1c                	jne    8010615b <sys_unlink+0x17d>
    dp->nlink--;
8010613f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106142:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106146:	8d 50 ff             	lea    -0x1(%eax),%edx
80106149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614c:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106153:	89 04 24             	mov    %eax,(%esp)
80106156:	e8 c1 b8 ff ff       	call   80101a1c <iupdate>
  }
  iunlockput(dp);
8010615b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010615e:	89 04 24             	mov    %eax,(%esp)
80106161:	e8 f6 bc ff ff       	call   80101e5c <iunlockput>

  ip->nlink--;
80106166:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106169:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010616d:	8d 50 ff             	lea    -0x1(%eax),%edx
80106170:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106173:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617a:	89 04 24             	mov    %eax,(%esp)
8010617d:	e8 9a b8 ff ff       	call   80101a1c <iupdate>
  iunlockput(ip);
80106182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106185:	89 04 24             	mov    %eax,(%esp)
80106188:	e8 cf bc ff ff       	call   80101e5c <iunlockput>

  commit_trans();
8010618d:	e8 44 d4 ff ff       	call   801035d6 <commit_trans>

  return 0;
80106192:	b8 00 00 00 00       	mov    $0x0,%eax
80106197:	eb 16                	jmp    801061af <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106199:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
8010619a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619d:	89 04 24             	mov    %eax,(%esp)
801061a0:	e8 b7 bc ff ff       	call   80101e5c <iunlockput>
  commit_trans();
801061a5:	e8 2c d4 ff ff       	call   801035d6 <commit_trans>
  return -1;
801061aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061af:	c9                   	leave  
801061b0:	c3                   	ret    

801061b1 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801061b1:	55                   	push   %ebp
801061b2:	89 e5                	mov    %esp,%ebp
801061b4:	83 ec 48             	sub    $0x48,%esp
801061b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801061ba:	8b 55 10             	mov    0x10(%ebp),%edx
801061bd:	8b 45 14             	mov    0x14(%ebp),%eax
801061c0:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801061c4:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801061c8:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801061cc:	8d 45 de             	lea    -0x22(%ebp),%eax
801061cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801061d3:	8b 45 08             	mov    0x8(%ebp),%eax
801061d6:	89 04 24             	mov    %eax,(%esp)
801061d9:	e8 be c5 ff ff       	call   8010279c <nameiparent>
801061de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061e5:	75 0a                	jne    801061f1 <create+0x40>
    return 0;
801061e7:	b8 00 00 00 00       	mov    $0x0,%eax
801061ec:	e9 7e 01 00 00       	jmp    8010636f <create+0x1be>
  ilock(dp);
801061f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f4:	89 04 24             	mov    %eax,(%esp)
801061f7:	e8 dc b9 ff ff       	call   80101bd8 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801061fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80106203:	8d 45 de             	lea    -0x22(%ebp),%eax
80106206:	89 44 24 04          	mov    %eax,0x4(%esp)
8010620a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620d:	89 04 24             	mov    %eax,(%esp)
80106210:	e8 dc c1 ff ff       	call   801023f1 <dirlookup>
80106215:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106218:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010621c:	74 47                	je     80106265 <create+0xb4>
    iunlockput(dp);
8010621e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106221:	89 04 24             	mov    %eax,(%esp)
80106224:	e8 33 bc ff ff       	call   80101e5c <iunlockput>
    ilock(ip);
80106229:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622c:	89 04 24             	mov    %eax,(%esp)
8010622f:	e8 a4 b9 ff ff       	call   80101bd8 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106234:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106239:	75 15                	jne    80106250 <create+0x9f>
8010623b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106242:	66 83 f8 02          	cmp    $0x2,%ax
80106246:	75 08                	jne    80106250 <create+0x9f>
      return ip;
80106248:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624b:	e9 1f 01 00 00       	jmp    8010636f <create+0x1be>
    iunlockput(ip);
80106250:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106253:	89 04 24             	mov    %eax,(%esp)
80106256:	e8 01 bc ff ff       	call   80101e5c <iunlockput>
    return 0;
8010625b:	b8 00 00 00 00       	mov    $0x0,%eax
80106260:	e9 0a 01 00 00       	jmp    8010636f <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106265:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626c:	8b 00                	mov    (%eax),%eax
8010626e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106272:	89 04 24             	mov    %eax,(%esp)
80106275:	e8 c5 b6 ff ff       	call   8010193f <ialloc>
8010627a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010627d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106281:	75 0c                	jne    8010628f <create+0xde>
    panic("create: ialloc");
80106283:	c7 04 24 cf 8e 10 80 	movl   $0x80108ecf,(%esp)
8010628a:	e8 ae a2 ff ff       	call   8010053d <panic>

  ilock(ip);
8010628f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106292:	89 04 24             	mov    %eax,(%esp)
80106295:	e8 3e b9 ff ff       	call   80101bd8 <ilock>
  ip->major = major;
8010629a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801062a1:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801062a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801062ac:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801062b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b3:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801062b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bc:	89 04 24             	mov    %eax,(%esp)
801062bf:	e8 58 b7 ff ff       	call   80101a1c <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801062c4:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801062c9:	75 6a                	jne    80106335 <create+0x184>
    dp->nlink++;  // for ".."
801062cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ce:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062d2:	8d 50 01             	lea    0x1(%eax),%edx
801062d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801062dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062df:	89 04 24             	mov    %eax,(%esp)
801062e2:	e8 35 b7 ff ff       	call   80101a1c <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801062e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ea:	8b 40 04             	mov    0x4(%eax),%eax
801062ed:	89 44 24 08          	mov    %eax,0x8(%esp)
801062f1:	c7 44 24 04 a9 8e 10 	movl   $0x80108ea9,0x4(%esp)
801062f8:	80 
801062f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fc:	89 04 24             	mov    %eax,(%esp)
801062ff:	e8 b5 c1 ff ff       	call   801024b9 <dirlink>
80106304:	85 c0                	test   %eax,%eax
80106306:	78 21                	js     80106329 <create+0x178>
80106308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630b:	8b 40 04             	mov    0x4(%eax),%eax
8010630e:	89 44 24 08          	mov    %eax,0x8(%esp)
80106312:	c7 44 24 04 ab 8e 10 	movl   $0x80108eab,0x4(%esp)
80106319:	80 
8010631a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631d:	89 04 24             	mov    %eax,(%esp)
80106320:	e8 94 c1 ff ff       	call   801024b9 <dirlink>
80106325:	85 c0                	test   %eax,%eax
80106327:	79 0c                	jns    80106335 <create+0x184>
      panic("create dots");
80106329:	c7 04 24 de 8e 10 80 	movl   $0x80108ede,(%esp)
80106330:	e8 08 a2 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106338:	8b 40 04             	mov    0x4(%eax),%eax
8010633b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010633f:	8d 45 de             	lea    -0x22(%ebp),%eax
80106342:	89 44 24 04          	mov    %eax,0x4(%esp)
80106346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106349:	89 04 24             	mov    %eax,(%esp)
8010634c:	e8 68 c1 ff ff       	call   801024b9 <dirlink>
80106351:	85 c0                	test   %eax,%eax
80106353:	79 0c                	jns    80106361 <create+0x1b0>
    panic("create: dirlink");
80106355:	c7 04 24 ea 8e 10 80 	movl   $0x80108eea,(%esp)
8010635c:	e8 dc a1 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80106361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106364:	89 04 24             	mov    %eax,(%esp)
80106367:	e8 f0 ba ff ff       	call   80101e5c <iunlockput>

  return ip;
8010636c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010636f:	c9                   	leave  
80106370:	c3                   	ret    

80106371 <sys_open>:

int
sys_open(void)
{
80106371:	55                   	push   %ebp
80106372:	89 e5                	mov    %esp,%ebp
80106374:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106377:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010637a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010637e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106385:	e8 a2 f6 ff ff       	call   80105a2c <argstr>
8010638a:	85 c0                	test   %eax,%eax
8010638c:	78 17                	js     801063a5 <sys_open+0x34>
8010638e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106391:	89 44 24 04          	mov    %eax,0x4(%esp)
80106395:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010639c:	e8 f1 f5 ff ff       	call   80105992 <argint>
801063a1:	85 c0                	test   %eax,%eax
801063a3:	79 0a                	jns    801063af <sys_open+0x3e>
    return -1;
801063a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063aa:	e9 46 01 00 00       	jmp    801064f5 <sys_open+0x184>
  if(omode & O_CREATE){
801063af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063b2:	25 00 02 00 00       	and    $0x200,%eax
801063b7:	85 c0                	test   %eax,%eax
801063b9:	74 40                	je     801063fb <sys_open+0x8a>
    begin_trans();
801063bb:	e8 cd d1 ff ff       	call   8010358d <begin_trans>
    ip = create(path, T_FILE, 0, 0);
801063c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801063ca:	00 
801063cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801063d2:	00 
801063d3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801063da:	00 
801063db:	89 04 24             	mov    %eax,(%esp)
801063de:	e8 ce fd ff ff       	call   801061b1 <create>
801063e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
801063e6:	e8 eb d1 ff ff       	call   801035d6 <commit_trans>
    if(ip == 0)
801063eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063ef:	75 5c                	jne    8010644d <sys_open+0xdc>
      return -1;
801063f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f6:	e9 fa 00 00 00       	jmp    801064f5 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
801063fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063fe:	89 04 24             	mov    %eax,(%esp)
80106401:	e8 74 c3 ff ff       	call   8010277a <namei>
80106406:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106409:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010640d:	75 0a                	jne    80106419 <sys_open+0xa8>
      return -1;
8010640f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106414:	e9 dc 00 00 00       	jmp    801064f5 <sys_open+0x184>
    ilock(ip);
80106419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010641c:	89 04 24             	mov    %eax,(%esp)
8010641f:	e8 b4 b7 ff ff       	call   80101bd8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106427:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010642b:	66 83 f8 01          	cmp    $0x1,%ax
8010642f:	75 1c                	jne    8010644d <sys_open+0xdc>
80106431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106434:	85 c0                	test   %eax,%eax
80106436:	74 15                	je     8010644d <sys_open+0xdc>
      iunlockput(ip);
80106438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643b:	89 04 24             	mov    %eax,(%esp)
8010643e:	e8 19 ba ff ff       	call   80101e5c <iunlockput>
      return -1;
80106443:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106448:	e9 a8 00 00 00       	jmp    801064f5 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010644d:	e8 3a ae ff ff       	call   8010128c <filealloc>
80106452:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106455:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106459:	74 14                	je     8010646f <sys_open+0xfe>
8010645b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645e:	89 04 24             	mov    %eax,(%esp)
80106461:	e8 43 f7 ff ff       	call   80105ba9 <fdalloc>
80106466:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106469:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010646d:	79 23                	jns    80106492 <sys_open+0x121>
    if(f)
8010646f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106473:	74 0b                	je     80106480 <sys_open+0x10f>
      fileclose(f);
80106475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106478:	89 04 24             	mov    %eax,(%esp)
8010647b:	e8 b4 ae ff ff       	call   80101334 <fileclose>
    iunlockput(ip);
80106480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106483:	89 04 24             	mov    %eax,(%esp)
80106486:	e8 d1 b9 ff ff       	call   80101e5c <iunlockput>
    return -1;
8010648b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106490:	eb 63                	jmp    801064f5 <sys_open+0x184>
  }
  iunlock(ip);
80106492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106495:	89 04 24             	mov    %eax,(%esp)
80106498:	e8 89 b8 ff ff       	call   80101d26 <iunlock>

  f->type = FD_INODE;
8010649d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801064a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064ac:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801064af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801064b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064bc:	83 e0 01             	and    $0x1,%eax
801064bf:	85 c0                	test   %eax,%eax
801064c1:	0f 94 c2             	sete   %dl
801064c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c7:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801064ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064cd:	83 e0 01             	and    $0x1,%eax
801064d0:	84 c0                	test   %al,%al
801064d2:	75 0a                	jne    801064de <sys_open+0x16d>
801064d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064d7:	83 e0 02             	and    $0x2,%eax
801064da:	85 c0                	test   %eax,%eax
801064dc:	74 07                	je     801064e5 <sys_open+0x174>
801064de:	b8 01 00 00 00       	mov    $0x1,%eax
801064e3:	eb 05                	jmp    801064ea <sys_open+0x179>
801064e5:	b8 00 00 00 00       	mov    $0x0,%eax
801064ea:	89 c2                	mov    %eax,%edx
801064ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ef:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801064f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801064f5:	c9                   	leave  
801064f6:	c3                   	ret    

801064f7 <sys_mkdir>:

int
sys_mkdir(void)
{
801064f7:	55                   	push   %ebp
801064f8:	89 e5                	mov    %esp,%ebp
801064fa:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801064fd:	e8 8b d0 ff ff       	call   8010358d <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106502:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106505:	89 44 24 04          	mov    %eax,0x4(%esp)
80106509:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106510:	e8 17 f5 ff ff       	call   80105a2c <argstr>
80106515:	85 c0                	test   %eax,%eax
80106517:	78 2c                	js     80106545 <sys_mkdir+0x4e>
80106519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106523:	00 
80106524:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010652b:	00 
8010652c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106533:	00 
80106534:	89 04 24             	mov    %eax,(%esp)
80106537:	e8 75 fc ff ff       	call   801061b1 <create>
8010653c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010653f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106543:	75 0c                	jne    80106551 <sys_mkdir+0x5a>
    commit_trans();
80106545:	e8 8c d0 ff ff       	call   801035d6 <commit_trans>
    return -1;
8010654a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654f:	eb 15                	jmp    80106566 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106554:	89 04 24             	mov    %eax,(%esp)
80106557:	e8 00 b9 ff ff       	call   80101e5c <iunlockput>
  commit_trans();
8010655c:	e8 75 d0 ff ff       	call   801035d6 <commit_trans>
  return 0;
80106561:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106566:	c9                   	leave  
80106567:	c3                   	ret    

80106568 <sys_mknod>:

int
sys_mknod(void)
{
80106568:	55                   	push   %ebp
80106569:	89 e5                	mov    %esp,%ebp
8010656b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
8010656e:	e8 1a d0 ff ff       	call   8010358d <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80106573:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106576:	89 44 24 04          	mov    %eax,0x4(%esp)
8010657a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106581:	e8 a6 f4 ff ff       	call   80105a2c <argstr>
80106586:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106589:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010658d:	78 5e                	js     801065ed <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010658f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106592:	89 44 24 04          	mov    %eax,0x4(%esp)
80106596:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010659d:	e8 f0 f3 ff ff       	call   80105992 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
801065a2:	85 c0                	test   %eax,%eax
801065a4:	78 47                	js     801065ed <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065ad:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801065b4:	e8 d9 f3 ff ff       	call   80105992 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801065b9:	85 c0                	test   %eax,%eax
801065bb:	78 30                	js     801065ed <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801065bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065c0:	0f bf c8             	movswl %ax,%ecx
801065c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065c6:	0f bf d0             	movswl %ax,%edx
801065c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065cc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801065d0:	89 54 24 08          	mov    %edx,0x8(%esp)
801065d4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801065db:	00 
801065dc:	89 04 24             	mov    %eax,(%esp)
801065df:	e8 cd fb ff ff       	call   801061b1 <create>
801065e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065eb:	75 0c                	jne    801065f9 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801065ed:	e8 e4 cf ff ff       	call   801035d6 <commit_trans>
    return -1;
801065f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f7:	eb 15                	jmp    8010660e <sys_mknod+0xa6>
  }
  iunlockput(ip);
801065f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065fc:	89 04 24             	mov    %eax,(%esp)
801065ff:	e8 58 b8 ff ff       	call   80101e5c <iunlockput>
  commit_trans();
80106604:	e8 cd cf ff ff       	call   801035d6 <commit_trans>
  return 0;
80106609:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010660e:	c9                   	leave  
8010660f:	c3                   	ret    

80106610 <sys_chdir>:

int
sys_chdir(void)
{
80106610:	55                   	push   %ebp
80106611:	89 e5                	mov    %esp,%ebp
80106613:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80106616:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106619:	89 44 24 04          	mov    %eax,0x4(%esp)
8010661d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106624:	e8 03 f4 ff ff       	call   80105a2c <argstr>
80106629:	85 c0                	test   %eax,%eax
8010662b:	78 14                	js     80106641 <sys_chdir+0x31>
8010662d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106630:	89 04 24             	mov    %eax,(%esp)
80106633:	e8 42 c1 ff ff       	call   8010277a <namei>
80106638:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010663b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010663f:	75 07                	jne    80106648 <sys_chdir+0x38>
    return -1;
80106641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106646:	eb 57                	jmp    8010669f <sys_chdir+0x8f>
  ilock(ip);
80106648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664b:	89 04 24             	mov    %eax,(%esp)
8010664e:	e8 85 b5 ff ff       	call   80101bd8 <ilock>
  if(ip->type != T_DIR){
80106653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106656:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010665a:	66 83 f8 01          	cmp    $0x1,%ax
8010665e:	74 12                	je     80106672 <sys_chdir+0x62>
    iunlockput(ip);
80106660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106663:	89 04 24             	mov    %eax,(%esp)
80106666:	e8 f1 b7 ff ff       	call   80101e5c <iunlockput>
    return -1;
8010666b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106670:	eb 2d                	jmp    8010669f <sys_chdir+0x8f>
  }
  iunlock(ip);
80106672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106675:	89 04 24             	mov    %eax,(%esp)
80106678:	e8 a9 b6 ff ff       	call   80101d26 <iunlock>
  iput(proc->cwd);
8010667d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106683:	8b 40 68             	mov    0x68(%eax),%eax
80106686:	89 04 24             	mov    %eax,(%esp)
80106689:	e8 fd b6 ff ff       	call   80101d8b <iput>
  proc->cwd = ip;
8010668e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106694:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106697:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010669a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010669f:	c9                   	leave  
801066a0:	c3                   	ret    

801066a1 <sys_exec>:

int
sys_exec(void)
{
801066a1:	55                   	push   %ebp
801066a2:	89 e5                	mov    %esp,%ebp
801066a4:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801066aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801066b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066b8:	e8 6f f3 ff ff       	call   80105a2c <argstr>
801066bd:	85 c0                	test   %eax,%eax
801066bf:	78 1a                	js     801066db <sys_exec+0x3a>
801066c1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801066c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801066cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066d2:	e8 bb f2 ff ff       	call   80105992 <argint>
801066d7:	85 c0                	test   %eax,%eax
801066d9:	79 0a                	jns    801066e5 <sys_exec+0x44>
    return -1;
801066db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e0:	e9 e2 00 00 00       	jmp    801067c7 <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
801066e5:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801066ec:	00 
801066ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801066f4:	00 
801066f5:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066fb:	89 04 24             	mov    %eax,(%esp)
801066fe:	e8 3f ef ff ff       	call   80105642 <memset>
  for(i=0;; i++){
80106703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010670a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670d:	83 f8 1f             	cmp    $0x1f,%eax
80106710:	76 0a                	jbe    8010671c <sys_exec+0x7b>
      return -1;
80106712:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106717:	e9 ab 00 00 00       	jmp    801067c7 <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
8010671c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010671f:	c1 e0 02             	shl    $0x2,%eax
80106722:	89 c2                	mov    %eax,%edx
80106724:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010672a:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010672d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106733:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
80106739:	89 54 24 08          	mov    %edx,0x8(%esp)
8010673d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106741:	89 04 24             	mov    %eax,(%esp)
80106744:	e8 b7 f1 ff ff       	call   80105900 <fetchint>
80106749:	85 c0                	test   %eax,%eax
8010674b:	79 07                	jns    80106754 <sys_exec+0xb3>
      return -1;
8010674d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106752:	eb 73                	jmp    801067c7 <sys_exec+0x126>
    if(uarg == 0){
80106754:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010675a:	85 c0                	test   %eax,%eax
8010675c:	75 26                	jne    80106784 <sys_exec+0xe3>
      argv[i] = 0;
8010675e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106761:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106768:	00 00 00 00 
      break;
8010676c:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010676d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106770:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106776:	89 54 24 04          	mov    %edx,0x4(%esp)
8010677a:	89 04 24             	mov    %eax,(%esp)
8010677d:	e8 ea a6 ff ff       	call   80100e6c <exec>
80106782:	eb 43                	jmp    801067c7 <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106787:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010678e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106794:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106797:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
8010679d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801067a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801067ab:	89 04 24             	mov    %eax,(%esp)
801067ae:	e8 81 f1 ff ff       	call   80105934 <fetchstr>
801067b3:	85 c0                	test   %eax,%eax
801067b5:	79 07                	jns    801067be <sys_exec+0x11d>
      return -1;
801067b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bc:	eb 09                	jmp    801067c7 <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801067be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
801067c2:	e9 43 ff ff ff       	jmp    8010670a <sys_exec+0x69>
  return exec(path, argv);
}
801067c7:	c9                   	leave  
801067c8:	c3                   	ret    

801067c9 <sys_pipe>:

int
sys_pipe(void)
{
801067c9:	55                   	push   %ebp
801067ca:	89 e5                	mov    %esp,%ebp
801067cc:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801067cf:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801067d6:	00 
801067d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801067da:	89 44 24 04          	mov    %eax,0x4(%esp)
801067de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067e5:	e8 e0 f1 ff ff       	call   801059ca <argptr>
801067ea:	85 c0                	test   %eax,%eax
801067ec:	79 0a                	jns    801067f8 <sys_pipe+0x2f>
    return -1;
801067ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f3:	e9 9b 00 00 00       	jmp    80106893 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801067f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801067fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801067ff:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106802:	89 04 24             	mov    %eax,(%esp)
80106805:	e8 9e d7 ff ff       	call   80103fa8 <pipealloc>
8010680a:	85 c0                	test   %eax,%eax
8010680c:	79 07                	jns    80106815 <sys_pipe+0x4c>
    return -1;
8010680e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106813:	eb 7e                	jmp    80106893 <sys_pipe+0xca>
  fd0 = -1;
80106815:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010681c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010681f:	89 04 24             	mov    %eax,(%esp)
80106822:	e8 82 f3 ff ff       	call   80105ba9 <fdalloc>
80106827:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010682a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010682e:	78 14                	js     80106844 <sys_pipe+0x7b>
80106830:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106833:	89 04 24             	mov    %eax,(%esp)
80106836:	e8 6e f3 ff ff       	call   80105ba9 <fdalloc>
8010683b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010683e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106842:	79 37                	jns    8010687b <sys_pipe+0xb2>
    if(fd0 >= 0)
80106844:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106848:	78 14                	js     8010685e <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010684a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106850:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106853:	83 c2 08             	add    $0x8,%edx
80106856:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010685d:	00 
    fileclose(rf);
8010685e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106861:	89 04 24             	mov    %eax,(%esp)
80106864:	e8 cb aa ff ff       	call   80101334 <fileclose>
    fileclose(wf);
80106869:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010686c:	89 04 24             	mov    %eax,(%esp)
8010686f:	e8 c0 aa ff ff       	call   80101334 <fileclose>
    return -1;
80106874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106879:	eb 18                	jmp    80106893 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010687b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010687e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106881:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106883:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106886:	8d 50 04             	lea    0x4(%eax),%edx
80106889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010688c:	89 02                	mov    %eax,(%edx)
  return 0;
8010688e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106893:	c9                   	leave  
80106894:	c3                   	ret    
80106895:	00 00                	add    %al,(%eax)
	...

80106898 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106898:	55                   	push   %ebp
80106899:	89 e5                	mov    %esp,%ebp
8010689b:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010689e:	e8 c2 dd ff ff       	call   80104665 <fork>
}
801068a3:	c9                   	leave  
801068a4:	c3                   	ret    

801068a5 <sys_exit>:

int
sys_exit(void)
{
801068a5:	55                   	push   %ebp
801068a6:	89 e5                	mov    %esp,%ebp
801068a8:	83 ec 08             	sub    $0x8,%esp
  exit();
801068ab:	e8 65 df ff ff       	call   80104815 <exit>
  return 0;  // not reached
801068b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068b5:	c9                   	leave  
801068b6:	c3                   	ret    

801068b7 <sys_wait>:

int
sys_wait(void)
{
801068b7:	55                   	push   %ebp
801068b8:	89 e5                	mov    %esp,%ebp
801068ba:	83 ec 08             	sub    $0x8,%esp
  return wait();
801068bd:	e8 a8 e0 ff ff       	call   8010496a <wait>
}
801068c2:	c9                   	leave  
801068c3:	c3                   	ret    

801068c4 <sys_wait2>:

int
sys_wait2(void)
{
801068c4:	55                   	push   %ebp
801068c5:	89 e5                	mov    %esp,%ebp
801068c7:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
801068ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
801068d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
801068d8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801068df:	00 
801068e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801068e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801068ee:	e8 d7 f0 ff ff       	call   801059ca <argptr>
  argptr(0,&wtime,sizeof(wtime));
801068f3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801068fa:	00 
801068fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106902:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106909:	e8 bc f0 ff ff       	call   801059ca <argptr>
  return wait2((int*)wtime, (int*)rtime);
8010690e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106911:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106914:	89 54 24 04          	mov    %edx,0x4(%esp)
80106918:	89 04 24             	mov    %eax,(%esp)
8010691b:	e8 5c e1 ff ff       	call   80104a7c <wait2>
}
80106920:	c9                   	leave  
80106921:	c3                   	ret    

80106922 <sys_nice>:

int
sys_nice(void)
{
80106922:	55                   	push   %ebp
80106923:	89 e5                	mov    %esp,%ebp
80106925:	83 ec 08             	sub    $0x8,%esp
  return nice();
80106928:	e8 d8 e9 ff ff       	call   80105305 <nice>
}
8010692d:	c9                   	leave  
8010692e:	c3                   	ret    

8010692f <sys_kill>:
int
sys_kill(void)
{
8010692f:	55                   	push   %ebp
80106930:	89 e5                	mov    %esp,%ebp
80106932:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106935:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106938:	89 44 24 04          	mov    %eax,0x4(%esp)
8010693c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106943:	e8 4a f0 ff ff       	call   80105992 <argint>
80106948:	85 c0                	test   %eax,%eax
8010694a:	79 07                	jns    80106953 <sys_kill+0x24>
    return -1;
8010694c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106951:	eb 0b                	jmp    8010695e <sys_kill+0x2f>
  return kill(pid);
80106953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106956:	89 04 24             	mov    %eax,(%esp)
80106959:	e8 30 e8 ff ff       	call   8010518e <kill>
}
8010695e:	c9                   	leave  
8010695f:	c3                   	ret    

80106960 <sys_getpid>:

int
sys_getpid(void)
{
80106960:	55                   	push   %ebp
80106961:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106963:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106969:	8b 40 10             	mov    0x10(%eax),%eax
}
8010696c:	5d                   	pop    %ebp
8010696d:	c3                   	ret    

8010696e <sys_sbrk>:

int
sys_sbrk(void)
{
8010696e:	55                   	push   %ebp
8010696f:	89 e5                	mov    %esp,%ebp
80106971:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106974:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106977:	89 44 24 04          	mov    %eax,0x4(%esp)
8010697b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106982:	e8 0b f0 ff ff       	call   80105992 <argint>
80106987:	85 c0                	test   %eax,%eax
80106989:	79 07                	jns    80106992 <sys_sbrk+0x24>
    return -1;
8010698b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106990:	eb 24                	jmp    801069b6 <sys_sbrk+0x48>
  addr = proc->sz;
80106992:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106998:	8b 00                	mov    (%eax),%eax
8010699a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010699d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a0:	89 04 24             	mov    %eax,(%esp)
801069a3:	e8 18 dc ff ff       	call   801045c0 <growproc>
801069a8:	85 c0                	test   %eax,%eax
801069aa:	79 07                	jns    801069b3 <sys_sbrk+0x45>
    return -1;
801069ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b1:	eb 03                	jmp    801069b6 <sys_sbrk+0x48>
  return addr;
801069b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069b6:	c9                   	leave  
801069b7:	c3                   	ret    

801069b8 <sys_sleep>:

int
sys_sleep(void)
{
801069b8:	55                   	push   %ebp
801069b9:	89 e5                	mov    %esp,%ebp
801069bb:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801069be:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801069c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069cc:	e8 c1 ef ff ff       	call   80105992 <argint>
801069d1:	85 c0                	test   %eax,%eax
801069d3:	79 07                	jns    801069dc <sys_sleep+0x24>
    return -1;
801069d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069da:	eb 6c                	jmp    80106a48 <sys_sleep+0x90>
  acquire(&tickslock);
801069dc:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
801069e3:	e8 0b ea ff ff       	call   801053f3 <acquire>
  ticks0 = ticks;
801069e8:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
801069ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801069f0:	eb 34                	jmp    80106a26 <sys_sleep+0x6e>
    if(proc->killed){
801069f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069f8:	8b 40 24             	mov    0x24(%eax),%eax
801069fb:	85 c0                	test   %eax,%eax
801069fd:	74 13                	je     80106a12 <sys_sleep+0x5a>
      release(&tickslock);
801069ff:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106a06:	e8 4a ea ff ff       	call   80105455 <release>
      return -1;
80106a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a10:	eb 36                	jmp    80106a48 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106a12:	c7 44 24 04 80 34 11 	movl   $0x80113480,0x4(%esp)
80106a19:	80 
80106a1a:	c7 04 24 c0 3c 11 80 	movl   $0x80113cc0,(%esp)
80106a21:	e8 61 e6 ff ff       	call   80105087 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106a26:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
80106a2b:	89 c2                	mov    %eax,%edx
80106a2d:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a33:	39 c2                	cmp    %eax,%edx
80106a35:	72 bb                	jb     801069f2 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106a37:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106a3e:	e8 12 ea ff ff       	call   80105455 <release>
  return 0;
80106a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a48:	c9                   	leave  
80106a49:	c3                   	ret    

80106a4a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106a4a:	55                   	push   %ebp
80106a4b:	89 e5                	mov    %esp,%ebp
80106a4d:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106a50:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106a57:	e8 97 e9 ff ff       	call   801053f3 <acquire>
  xticks = ticks;
80106a5c:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
80106a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106a64:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106a6b:	e8 e5 e9 ff ff       	call   80105455 <release>
  return xticks;
80106a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a73:	c9                   	leave  
80106a74:	c3                   	ret    
80106a75:	00 00                	add    %al,(%eax)
	...

80106a78 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106a78:	55                   	push   %ebp
80106a79:	89 e5                	mov    %esp,%ebp
80106a7b:	83 ec 08             	sub    $0x8,%esp
80106a7e:	8b 55 08             	mov    0x8(%ebp),%edx
80106a81:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a84:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106a88:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a8b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a8f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106a93:	ee                   	out    %al,(%dx)
}
80106a94:	c9                   	leave  
80106a95:	c3                   	ret    

80106a96 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106a96:	55                   	push   %ebp
80106a97:	89 e5                	mov    %esp,%ebp
80106a99:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106a9c:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106aa3:	00 
80106aa4:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106aab:	e8 c8 ff ff ff       	call   80106a78 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106ab0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106ab7:	00 
80106ab8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106abf:	e8 b4 ff ff ff       	call   80106a78 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106ac4:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106acb:	00 
80106acc:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106ad3:	e8 a0 ff ff ff       	call   80106a78 <outb>
  picenable(IRQ_TIMER);
80106ad8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106adf:	e8 4d d3 ff ff       	call   80103e31 <picenable>
}
80106ae4:	c9                   	leave  
80106ae5:	c3                   	ret    
	...

80106ae8 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106ae8:	1e                   	push   %ds
  pushl %es
80106ae9:	06                   	push   %es
  pushl %fs
80106aea:	0f a0                	push   %fs
  pushl %gs
80106aec:	0f a8                	push   %gs
  pushal
80106aee:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106aef:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106af3:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106af5:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106af7:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106afb:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106afd:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106aff:	54                   	push   %esp
  call trap
80106b00:	e8 de 01 00 00       	call   80106ce3 <trap>
  addl $4, %esp
80106b05:	83 c4 04             	add    $0x4,%esp

80106b08 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106b08:	61                   	popa   
  popl %gs
80106b09:	0f a9                	pop    %gs
  popl %fs
80106b0b:	0f a1                	pop    %fs
  popl %es
80106b0d:	07                   	pop    %es
  popl %ds
80106b0e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b0f:	83 c4 08             	add    $0x8,%esp
  iret
80106b12:	cf                   	iret   
	...

80106b14 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106b14:	55                   	push   %ebp
80106b15:	89 e5                	mov    %esp,%ebp
80106b17:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b1d:	83 e8 01             	sub    $0x1,%eax
80106b20:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b24:	8b 45 08             	mov    0x8(%ebp),%eax
80106b27:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106b2e:	c1 e8 10             	shr    $0x10,%eax
80106b31:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106b35:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b38:	0f 01 18             	lidtl  (%eax)
}
80106b3b:	c9                   	leave  
80106b3c:	c3                   	ret    

80106b3d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106b3d:	55                   	push   %ebp
80106b3e:	89 e5                	mov    %esp,%ebp
80106b40:	53                   	push   %ebx
80106b41:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b44:	0f 20 d3             	mov    %cr2,%ebx
80106b47:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106b4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106b4d:	83 c4 10             	add    $0x10,%esp
80106b50:	5b                   	pop    %ebx
80106b51:	5d                   	pop    %ebp
80106b52:	c3                   	ret    

80106b53 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106b53:	55                   	push   %ebp
80106b54:	89 e5                	mov    %esp,%ebp
80106b56:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b60:	e9 c3 00 00 00       	jmp    80106c28 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b68:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106b6f:	89 c2                	mov    %eax,%edx
80106b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b74:	66 89 14 c5 c0 34 11 	mov    %dx,-0x7feecb40(,%eax,8)
80106b7b:	80 
80106b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b7f:	66 c7 04 c5 c2 34 11 	movw   $0x8,-0x7feecb3e(,%eax,8)
80106b86:	80 08 00 
80106b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8c:	0f b6 14 c5 c4 34 11 	movzbl -0x7feecb3c(,%eax,8),%edx
80106b93:	80 
80106b94:	83 e2 e0             	and    $0xffffffe0,%edx
80106b97:	88 14 c5 c4 34 11 80 	mov    %dl,-0x7feecb3c(,%eax,8)
80106b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba1:	0f b6 14 c5 c4 34 11 	movzbl -0x7feecb3c(,%eax,8),%edx
80106ba8:	80 
80106ba9:	83 e2 1f             	and    $0x1f,%edx
80106bac:	88 14 c5 c4 34 11 80 	mov    %dl,-0x7feecb3c(,%eax,8)
80106bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb6:	0f b6 14 c5 c5 34 11 	movzbl -0x7feecb3b(,%eax,8),%edx
80106bbd:	80 
80106bbe:	83 e2 f0             	and    $0xfffffff0,%edx
80106bc1:	83 ca 0e             	or     $0xe,%edx
80106bc4:	88 14 c5 c5 34 11 80 	mov    %dl,-0x7feecb3b(,%eax,8)
80106bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bce:	0f b6 14 c5 c5 34 11 	movzbl -0x7feecb3b(,%eax,8),%edx
80106bd5:	80 
80106bd6:	83 e2 ef             	and    $0xffffffef,%edx
80106bd9:	88 14 c5 c5 34 11 80 	mov    %dl,-0x7feecb3b(,%eax,8)
80106be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be3:	0f b6 14 c5 c5 34 11 	movzbl -0x7feecb3b(,%eax,8),%edx
80106bea:	80 
80106beb:	83 e2 9f             	and    $0xffffff9f,%edx
80106bee:	88 14 c5 c5 34 11 80 	mov    %dl,-0x7feecb3b(,%eax,8)
80106bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf8:	0f b6 14 c5 c5 34 11 	movzbl -0x7feecb3b(,%eax,8),%edx
80106bff:	80 
80106c00:	83 ca 80             	or     $0xffffff80,%edx
80106c03:	88 14 c5 c5 34 11 80 	mov    %dl,-0x7feecb3b(,%eax,8)
80106c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c0d:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106c14:	c1 e8 10             	shr    $0x10,%eax
80106c17:	89 c2                	mov    %eax,%edx
80106c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1c:	66 89 14 c5 c6 34 11 	mov    %dx,-0x7feecb3a(,%eax,8)
80106c23:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106c24:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c28:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106c2f:	0f 8e 30 ff ff ff    	jle    80106b65 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c35:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106c3a:	66 a3 c0 36 11 80    	mov    %ax,0x801136c0
80106c40:	66 c7 05 c2 36 11 80 	movw   $0x8,0x801136c2
80106c47:	08 00 
80106c49:	0f b6 05 c4 36 11 80 	movzbl 0x801136c4,%eax
80106c50:	83 e0 e0             	and    $0xffffffe0,%eax
80106c53:	a2 c4 36 11 80       	mov    %al,0x801136c4
80106c58:	0f b6 05 c4 36 11 80 	movzbl 0x801136c4,%eax
80106c5f:	83 e0 1f             	and    $0x1f,%eax
80106c62:	a2 c4 36 11 80       	mov    %al,0x801136c4
80106c67:	0f b6 05 c5 36 11 80 	movzbl 0x801136c5,%eax
80106c6e:	83 c8 0f             	or     $0xf,%eax
80106c71:	a2 c5 36 11 80       	mov    %al,0x801136c5
80106c76:	0f b6 05 c5 36 11 80 	movzbl 0x801136c5,%eax
80106c7d:	83 e0 ef             	and    $0xffffffef,%eax
80106c80:	a2 c5 36 11 80       	mov    %al,0x801136c5
80106c85:	0f b6 05 c5 36 11 80 	movzbl 0x801136c5,%eax
80106c8c:	83 c8 60             	or     $0x60,%eax
80106c8f:	a2 c5 36 11 80       	mov    %al,0x801136c5
80106c94:	0f b6 05 c5 36 11 80 	movzbl 0x801136c5,%eax
80106c9b:	83 c8 80             	or     $0xffffff80,%eax
80106c9e:	a2 c5 36 11 80       	mov    %al,0x801136c5
80106ca3:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106ca8:	c1 e8 10             	shr    $0x10,%eax
80106cab:	66 a3 c6 36 11 80    	mov    %ax,0x801136c6
  
  initlock(&tickslock, "time");
80106cb1:	c7 44 24 04 fc 8e 10 	movl   $0x80108efc,0x4(%esp)
80106cb8:	80 
80106cb9:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106cc0:	e8 0d e7 ff ff       	call   801053d2 <initlock>
}
80106cc5:	c9                   	leave  
80106cc6:	c3                   	ret    

80106cc7 <idtinit>:

void
idtinit(void)
{
80106cc7:	55                   	push   %ebp
80106cc8:	89 e5                	mov    %esp,%ebp
80106cca:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106ccd:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106cd4:	00 
80106cd5:	c7 04 24 c0 34 11 80 	movl   $0x801134c0,(%esp)
80106cdc:	e8 33 fe ff ff       	call   80106b14 <lidt>
}
80106ce1:	c9                   	leave  
80106ce2:	c3                   	ret    

80106ce3 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106ce3:	55                   	push   %ebp
80106ce4:	89 e5                	mov    %esp,%ebp
80106ce6:	57                   	push   %edi
80106ce7:	56                   	push   %esi
80106ce8:	53                   	push   %ebx
80106ce9:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106cec:	8b 45 08             	mov    0x8(%ebp),%eax
80106cef:	8b 40 30             	mov    0x30(%eax),%eax
80106cf2:	83 f8 40             	cmp    $0x40,%eax
80106cf5:	75 3e                	jne    80106d35 <trap+0x52>
    if(proc->killed)
80106cf7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cfd:	8b 40 24             	mov    0x24(%eax),%eax
80106d00:	85 c0                	test   %eax,%eax
80106d02:	74 05                	je     80106d09 <trap+0x26>
      exit();
80106d04:	e8 0c db ff ff       	call   80104815 <exit>
    proc->tf = tf;
80106d09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0f:	8b 55 08             	mov    0x8(%ebp),%edx
80106d12:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d15:	e8 55 ed ff ff       	call   80105a6f <syscall>
    if(proc->killed)
80106d1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d20:	8b 40 24             	mov    0x24(%eax),%eax
80106d23:	85 c0                	test   %eax,%eax
80106d25:	0f 84 78 02 00 00    	je     80106fa3 <trap+0x2c0>
      exit();
80106d2b:	e8 e5 da ff ff       	call   80104815 <exit>
    return;
80106d30:	e9 6e 02 00 00       	jmp    80106fa3 <trap+0x2c0>
  }

  switch(tf->trapno){
80106d35:	8b 45 08             	mov    0x8(%ebp),%eax
80106d38:	8b 40 30             	mov    0x30(%eax),%eax
80106d3b:	83 e8 20             	sub    $0x20,%eax
80106d3e:	83 f8 1f             	cmp    $0x1f,%eax
80106d41:	0f 87 f0 00 00 00    	ja     80106e37 <trap+0x154>
80106d47:	8b 04 85 a4 8f 10 80 	mov    -0x7fef705c(,%eax,4),%eax
80106d4e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106d50:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d56:	0f b6 00             	movzbl (%eax),%eax
80106d59:	84 c0                	test   %al,%al
80106d5b:	75 65                	jne    80106dc2 <trap+0xdf>
      acquire(&tickslock);
80106d5d:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106d64:	e8 8a e6 ff ff       	call   801053f3 <acquire>
      ticks++;
80106d69:	a1 c0 3c 11 80       	mov    0x80113cc0,%eax
80106d6e:	83 c0 01             	add    $0x1,%eax
80106d71:	a3 c0 3c 11 80       	mov    %eax,0x80113cc0
      if(proc)
80106d76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d7c:	85 c0                	test   %eax,%eax
80106d7e:	74 2a                	je     80106daa <trap+0xc7>
      {
	proc->rtime++;
80106d80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d86:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106d8c:	83 c2 01             	add    $0x1,%edx
80106d8f:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	proc->quanta--;
80106d95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d9b:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106da1:	83 ea 01             	sub    $0x1,%edx
80106da4:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
      wakeup(&ticks);
80106daa:	c7 04 24 c0 3c 11 80 	movl   $0x80113cc0,(%esp)
80106db1:	e8 ad e3 ff ff       	call   80105163 <wakeup>
      release(&tickslock);
80106db6:	c7 04 24 80 34 11 80 	movl   $0x80113480,(%esp)
80106dbd:	e8 93 e6 ff ff       	call   80105455 <release>
    }
    lapiceoi();
80106dc2:	e8 92 c4 ff ff       	call   80103259 <lapiceoi>
    break;
80106dc7:	e9 41 01 00 00       	jmp    80106f0d <trap+0x22a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106dcc:	e8 90 bc ff ff       	call   80102a61 <ideintr>
    lapiceoi();
80106dd1:	e8 83 c4 ff ff       	call   80103259 <lapiceoi>
    break;
80106dd6:	e9 32 01 00 00       	jmp    80106f0d <trap+0x22a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106ddb:	e8 57 c2 ff ff       	call   80103037 <kbdintr>
    lapiceoi();
80106de0:	e8 74 c4 ff ff       	call   80103259 <lapiceoi>
    break;
80106de5:	e9 23 01 00 00       	jmp    80106f0d <trap+0x22a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106dea:	e8 b9 03 00 00       	call   801071a8 <uartintr>
    lapiceoi();
80106def:	e8 65 c4 ff ff       	call   80103259 <lapiceoi>
    break;
80106df4:	e9 14 01 00 00       	jmp    80106f0d <trap+0x22a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106df9:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dfc:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106dff:	8b 45 08             	mov    0x8(%ebp),%eax
80106e02:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e06:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106e09:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e0f:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e12:	0f b6 c0             	movzbl %al,%eax
80106e15:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106e19:	89 54 24 08          	mov    %edx,0x8(%esp)
80106e1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e21:	c7 04 24 04 8f 10 80 	movl   $0x80108f04,(%esp)
80106e28:	e8 74 95 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106e2d:	e8 27 c4 ff ff       	call   80103259 <lapiceoi>
    break;
80106e32:	e9 d6 00 00 00       	jmp    80106f0d <trap+0x22a>
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106e37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e3d:	85 c0                	test   %eax,%eax
80106e3f:	74 11                	je     80106e52 <trap+0x16f>
80106e41:	8b 45 08             	mov    0x8(%ebp),%eax
80106e44:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e48:	0f b7 c0             	movzwl %ax,%eax
80106e4b:	83 e0 03             	and    $0x3,%eax
80106e4e:	85 c0                	test   %eax,%eax
80106e50:	75 46                	jne    80106e98 <trap+0x1b5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e52:	e8 e6 fc ff ff       	call   80106b3d <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e57:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e5a:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e5d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106e64:	0f b6 12             	movzbl (%edx),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e67:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e6a:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e6d:	8b 52 30             	mov    0x30(%edx),%edx
80106e70:	89 44 24 10          	mov    %eax,0x10(%esp)
80106e74:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106e78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106e7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e80:	c7 04 24 28 8f 10 80 	movl   $0x80108f28,(%esp)
80106e87:	e8 15 95 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106e8c:	c7 04 24 5a 8f 10 80 	movl   $0x80108f5a,(%esp)
80106e93:	e8 a5 96 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e98:	e8 a0 fc ff ff       	call   80106b3d <rcr2>
80106e9d:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e9f:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ea2:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ea5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106eab:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106eae:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106eb1:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106eb4:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106eb7:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106eba:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ebd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ec3:	83 c0 6c             	add    $0x6c,%eax
80106ec6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ecf:	8b 40 10             	mov    0x10(%eax),%eax
80106ed2:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106ed6:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106eda:	89 74 24 14          	mov    %esi,0x14(%esp)
80106ede:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106ee2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ee6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106ee9:	89 54 24 08          	mov    %edx,0x8(%esp)
80106eed:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ef1:	c7 04 24 60 8f 10 80 	movl   $0x80108f60,(%esp)
80106ef8:	e8 a4 94 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106efd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f03:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106f0a:	eb 01                	jmp    80106f0d <trap+0x22a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106f0c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106f0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f13:	85 c0                	test   %eax,%eax
80106f15:	74 24                	je     80106f3b <trap+0x258>
80106f17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f1d:	8b 40 24             	mov    0x24(%eax),%eax
80106f20:	85 c0                	test   %eax,%eax
80106f22:	74 17                	je     80106f3b <trap+0x258>
80106f24:	8b 45 08             	mov    0x8(%ebp),%eax
80106f27:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f2b:	0f b7 c0             	movzwl %ax,%eax
80106f2e:	83 e0 03             	and    $0x3,%eax
80106f31:	83 f8 03             	cmp    $0x3,%eax
80106f34:	75 05                	jne    80106f3b <trap+0x258>
    exit();
80106f36:	e8 da d8 ff ff       	call   80104815 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && proc->quanta <= 0)
80106f3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f41:	85 c0                	test   %eax,%eax
80106f43:	74 2e                	je     80106f73 <trap+0x290>
80106f45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f4b:	8b 40 0c             	mov    0xc(%eax),%eax
80106f4e:	83 f8 04             	cmp    $0x4,%eax
80106f51:	75 20                	jne    80106f73 <trap+0x290>
80106f53:	8b 45 08             	mov    0x8(%ebp),%eax
80106f56:	8b 40 30             	mov    0x30(%eax),%eax
80106f59:	83 f8 20             	cmp    $0x20,%eax
80106f5c:	75 15                	jne    80106f73 <trap+0x290>
80106f5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f64:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106f6a:	85 c0                	test   %eax,%eax
80106f6c:	7f 05                	jg     80106f73 <trap+0x290>
    yield();
80106f6e:	e8 7a e0 ff ff       	call   80104fed <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106f73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f79:	85 c0                	test   %eax,%eax
80106f7b:	74 27                	je     80106fa4 <trap+0x2c1>
80106f7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f83:	8b 40 24             	mov    0x24(%eax),%eax
80106f86:	85 c0                	test   %eax,%eax
80106f88:	74 1a                	je     80106fa4 <trap+0x2c1>
80106f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f8d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f91:	0f b7 c0             	movzwl %ax,%eax
80106f94:	83 e0 03             	and    $0x3,%eax
80106f97:	83 f8 03             	cmp    $0x3,%eax
80106f9a:	75 08                	jne    80106fa4 <trap+0x2c1>
    exit();
80106f9c:	e8 74 d8 ff ff       	call   80104815 <exit>
80106fa1:	eb 01                	jmp    80106fa4 <trap+0x2c1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106fa3:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106fa4:	83 c4 3c             	add    $0x3c,%esp
80106fa7:	5b                   	pop    %ebx
80106fa8:	5e                   	pop    %esi
80106fa9:	5f                   	pop    %edi
80106faa:	5d                   	pop    %ebp
80106fab:	c3                   	ret    

80106fac <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106fac:	55                   	push   %ebp
80106fad:	89 e5                	mov    %esp,%ebp
80106faf:	53                   	push   %ebx
80106fb0:	83 ec 14             	sub    $0x14,%esp
80106fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80106fb6:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106fba:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106fbe:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106fc2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106fc6:	ec                   	in     (%dx),%al
80106fc7:	89 c3                	mov    %eax,%ebx
80106fc9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106fcc:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106fd0:	83 c4 14             	add    $0x14,%esp
80106fd3:	5b                   	pop    %ebx
80106fd4:	5d                   	pop    %ebp
80106fd5:	c3                   	ret    

80106fd6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106fd6:	55                   	push   %ebp
80106fd7:	89 e5                	mov    %esp,%ebp
80106fd9:	83 ec 08             	sub    $0x8,%esp
80106fdc:	8b 55 08             	mov    0x8(%ebp),%edx
80106fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fe2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106fe6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106fe9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106fed:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106ff1:	ee                   	out    %al,(%dx)
}
80106ff2:	c9                   	leave  
80106ff3:	c3                   	ret    

80106ff4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ff4:	55                   	push   %ebp
80106ff5:	89 e5                	mov    %esp,%ebp
80106ff7:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ffa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107001:	00 
80107002:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107009:	e8 c8 ff ff ff       	call   80106fd6 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010700e:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107015:	00 
80107016:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010701d:	e8 b4 ff ff ff       	call   80106fd6 <outb>
  outb(COM1+0, 115200/9600);
80107022:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107029:	00 
8010702a:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107031:	e8 a0 ff ff ff       	call   80106fd6 <outb>
  outb(COM1+1, 0);
80107036:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010703d:	00 
8010703e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107045:	e8 8c ff ff ff       	call   80106fd6 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010704a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107051:	00 
80107052:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107059:	e8 78 ff ff ff       	call   80106fd6 <outb>
  outb(COM1+4, 0);
8010705e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107065:	00 
80107066:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
8010706d:	e8 64 ff ff ff       	call   80106fd6 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107072:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107079:	00 
8010707a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107081:	e8 50 ff ff ff       	call   80106fd6 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107086:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010708d:	e8 1a ff ff ff       	call   80106fac <inb>
80107092:	3c ff                	cmp    $0xff,%al
80107094:	74 6c                	je     80107102 <uartinit+0x10e>
    return;
  uart = 1;
80107096:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
8010709d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801070a0:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801070a7:	e8 00 ff ff ff       	call   80106fac <inb>
  inb(COM1+0);
801070ac:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801070b3:	e8 f4 fe ff ff       	call   80106fac <inb>
  picenable(IRQ_COM1);
801070b8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801070bf:	e8 6d cd ff ff       	call   80103e31 <picenable>
  ioapicenable(IRQ_COM1, 0);
801070c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801070cb:	00 
801070cc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801070d3:	e8 0e bc ff ff       	call   80102ce6 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801070d8:	c7 45 f4 24 90 10 80 	movl   $0x80109024,-0xc(%ebp)
801070df:	eb 15                	jmp    801070f6 <uartinit+0x102>
    uartputc(*p);
801070e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e4:	0f b6 00             	movzbl (%eax),%eax
801070e7:	0f be c0             	movsbl %al,%eax
801070ea:	89 04 24             	mov    %eax,(%esp)
801070ed:	e8 13 00 00 00       	call   80107105 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801070f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f9:	0f b6 00             	movzbl (%eax),%eax
801070fc:	84 c0                	test   %al,%al
801070fe:	75 e1                	jne    801070e1 <uartinit+0xed>
80107100:	eb 01                	jmp    80107103 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107102:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107103:	c9                   	leave  
80107104:	c3                   	ret    

80107105 <uartputc>:

void
uartputc(int c)
{
80107105:	55                   	push   %ebp
80107106:	89 e5                	mov    %esp,%ebp
80107108:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010710b:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107110:	85 c0                	test   %eax,%eax
80107112:	74 4d                	je     80107161 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107114:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010711b:	eb 10                	jmp    8010712d <uartputc+0x28>
    microdelay(10);
8010711d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107124:	e8 55 c1 ff ff       	call   8010327e <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107129:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010712d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107131:	7f 16                	jg     80107149 <uartputc+0x44>
80107133:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010713a:	e8 6d fe ff ff       	call   80106fac <inb>
8010713f:	0f b6 c0             	movzbl %al,%eax
80107142:	83 e0 20             	and    $0x20,%eax
80107145:	85 c0                	test   %eax,%eax
80107147:	74 d4                	je     8010711d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107149:	8b 45 08             	mov    0x8(%ebp),%eax
8010714c:	0f b6 c0             	movzbl %al,%eax
8010714f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107153:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010715a:	e8 77 fe ff ff       	call   80106fd6 <outb>
8010715f:	eb 01                	jmp    80107162 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107161:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107162:	c9                   	leave  
80107163:	c3                   	ret    

80107164 <uartgetc>:

static int
uartgetc(void)
{
80107164:	55                   	push   %ebp
80107165:	89 e5                	mov    %esp,%ebp
80107167:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010716a:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
8010716f:	85 c0                	test   %eax,%eax
80107171:	75 07                	jne    8010717a <uartgetc+0x16>
    return -1;
80107173:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107178:	eb 2c                	jmp    801071a6 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010717a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107181:	e8 26 fe ff ff       	call   80106fac <inb>
80107186:	0f b6 c0             	movzbl %al,%eax
80107189:	83 e0 01             	and    $0x1,%eax
8010718c:	85 c0                	test   %eax,%eax
8010718e:	75 07                	jne    80107197 <uartgetc+0x33>
    return -1;
80107190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107195:	eb 0f                	jmp    801071a6 <uartgetc+0x42>
  return inb(COM1+0);
80107197:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010719e:	e8 09 fe ff ff       	call   80106fac <inb>
801071a3:	0f b6 c0             	movzbl %al,%eax
}
801071a6:	c9                   	leave  
801071a7:	c3                   	ret    

801071a8 <uartintr>:

void
uartintr(void)
{
801071a8:	55                   	push   %ebp
801071a9:	89 e5                	mov    %esp,%ebp
801071ab:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801071ae:	c7 04 24 64 71 10 80 	movl   $0x80107164,(%esp)
801071b5:	e8 21 97 ff ff       	call   801008db <consoleintr>
}
801071ba:	c9                   	leave  
801071bb:	c3                   	ret    

801071bc <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $0
801071be:	6a 00                	push   $0x0
  jmp alltraps
801071c0:	e9 23 f9 ff ff       	jmp    80106ae8 <alltraps>

801071c5 <vector1>:
.globl vector1
vector1:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $1
801071c7:	6a 01                	push   $0x1
  jmp alltraps
801071c9:	e9 1a f9 ff ff       	jmp    80106ae8 <alltraps>

801071ce <vector2>:
.globl vector2
vector2:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $2
801071d0:	6a 02                	push   $0x2
  jmp alltraps
801071d2:	e9 11 f9 ff ff       	jmp    80106ae8 <alltraps>

801071d7 <vector3>:
.globl vector3
vector3:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $3
801071d9:	6a 03                	push   $0x3
  jmp alltraps
801071db:	e9 08 f9 ff ff       	jmp    80106ae8 <alltraps>

801071e0 <vector4>:
.globl vector4
vector4:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $4
801071e2:	6a 04                	push   $0x4
  jmp alltraps
801071e4:	e9 ff f8 ff ff       	jmp    80106ae8 <alltraps>

801071e9 <vector5>:
.globl vector5
vector5:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $5
801071eb:	6a 05                	push   $0x5
  jmp alltraps
801071ed:	e9 f6 f8 ff ff       	jmp    80106ae8 <alltraps>

801071f2 <vector6>:
.globl vector6
vector6:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $6
801071f4:	6a 06                	push   $0x6
  jmp alltraps
801071f6:	e9 ed f8 ff ff       	jmp    80106ae8 <alltraps>

801071fb <vector7>:
.globl vector7
vector7:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $7
801071fd:	6a 07                	push   $0x7
  jmp alltraps
801071ff:	e9 e4 f8 ff ff       	jmp    80106ae8 <alltraps>

80107204 <vector8>:
.globl vector8
vector8:
  pushl $8
80107204:	6a 08                	push   $0x8
  jmp alltraps
80107206:	e9 dd f8 ff ff       	jmp    80106ae8 <alltraps>

8010720b <vector9>:
.globl vector9
vector9:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $9
8010720d:	6a 09                	push   $0x9
  jmp alltraps
8010720f:	e9 d4 f8 ff ff       	jmp    80106ae8 <alltraps>

80107214 <vector10>:
.globl vector10
vector10:
  pushl $10
80107214:	6a 0a                	push   $0xa
  jmp alltraps
80107216:	e9 cd f8 ff ff       	jmp    80106ae8 <alltraps>

8010721b <vector11>:
.globl vector11
vector11:
  pushl $11
8010721b:	6a 0b                	push   $0xb
  jmp alltraps
8010721d:	e9 c6 f8 ff ff       	jmp    80106ae8 <alltraps>

80107222 <vector12>:
.globl vector12
vector12:
  pushl $12
80107222:	6a 0c                	push   $0xc
  jmp alltraps
80107224:	e9 bf f8 ff ff       	jmp    80106ae8 <alltraps>

80107229 <vector13>:
.globl vector13
vector13:
  pushl $13
80107229:	6a 0d                	push   $0xd
  jmp alltraps
8010722b:	e9 b8 f8 ff ff       	jmp    80106ae8 <alltraps>

80107230 <vector14>:
.globl vector14
vector14:
  pushl $14
80107230:	6a 0e                	push   $0xe
  jmp alltraps
80107232:	e9 b1 f8 ff ff       	jmp    80106ae8 <alltraps>

80107237 <vector15>:
.globl vector15
vector15:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $15
80107239:	6a 0f                	push   $0xf
  jmp alltraps
8010723b:	e9 a8 f8 ff ff       	jmp    80106ae8 <alltraps>

80107240 <vector16>:
.globl vector16
vector16:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $16
80107242:	6a 10                	push   $0x10
  jmp alltraps
80107244:	e9 9f f8 ff ff       	jmp    80106ae8 <alltraps>

80107249 <vector17>:
.globl vector17
vector17:
  pushl $17
80107249:	6a 11                	push   $0x11
  jmp alltraps
8010724b:	e9 98 f8 ff ff       	jmp    80106ae8 <alltraps>

80107250 <vector18>:
.globl vector18
vector18:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $18
80107252:	6a 12                	push   $0x12
  jmp alltraps
80107254:	e9 8f f8 ff ff       	jmp    80106ae8 <alltraps>

80107259 <vector19>:
.globl vector19
vector19:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $19
8010725b:	6a 13                	push   $0x13
  jmp alltraps
8010725d:	e9 86 f8 ff ff       	jmp    80106ae8 <alltraps>

80107262 <vector20>:
.globl vector20
vector20:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $20
80107264:	6a 14                	push   $0x14
  jmp alltraps
80107266:	e9 7d f8 ff ff       	jmp    80106ae8 <alltraps>

8010726b <vector21>:
.globl vector21
vector21:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $21
8010726d:	6a 15                	push   $0x15
  jmp alltraps
8010726f:	e9 74 f8 ff ff       	jmp    80106ae8 <alltraps>

80107274 <vector22>:
.globl vector22
vector22:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $22
80107276:	6a 16                	push   $0x16
  jmp alltraps
80107278:	e9 6b f8 ff ff       	jmp    80106ae8 <alltraps>

8010727d <vector23>:
.globl vector23
vector23:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $23
8010727f:	6a 17                	push   $0x17
  jmp alltraps
80107281:	e9 62 f8 ff ff       	jmp    80106ae8 <alltraps>

80107286 <vector24>:
.globl vector24
vector24:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $24
80107288:	6a 18                	push   $0x18
  jmp alltraps
8010728a:	e9 59 f8 ff ff       	jmp    80106ae8 <alltraps>

8010728f <vector25>:
.globl vector25
vector25:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $25
80107291:	6a 19                	push   $0x19
  jmp alltraps
80107293:	e9 50 f8 ff ff       	jmp    80106ae8 <alltraps>

80107298 <vector26>:
.globl vector26
vector26:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $26
8010729a:	6a 1a                	push   $0x1a
  jmp alltraps
8010729c:	e9 47 f8 ff ff       	jmp    80106ae8 <alltraps>

801072a1 <vector27>:
.globl vector27
vector27:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $27
801072a3:	6a 1b                	push   $0x1b
  jmp alltraps
801072a5:	e9 3e f8 ff ff       	jmp    80106ae8 <alltraps>

801072aa <vector28>:
.globl vector28
vector28:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $28
801072ac:	6a 1c                	push   $0x1c
  jmp alltraps
801072ae:	e9 35 f8 ff ff       	jmp    80106ae8 <alltraps>

801072b3 <vector29>:
.globl vector29
vector29:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $29
801072b5:	6a 1d                	push   $0x1d
  jmp alltraps
801072b7:	e9 2c f8 ff ff       	jmp    80106ae8 <alltraps>

801072bc <vector30>:
.globl vector30
vector30:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $30
801072be:	6a 1e                	push   $0x1e
  jmp alltraps
801072c0:	e9 23 f8 ff ff       	jmp    80106ae8 <alltraps>

801072c5 <vector31>:
.globl vector31
vector31:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $31
801072c7:	6a 1f                	push   $0x1f
  jmp alltraps
801072c9:	e9 1a f8 ff ff       	jmp    80106ae8 <alltraps>

801072ce <vector32>:
.globl vector32
vector32:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $32
801072d0:	6a 20                	push   $0x20
  jmp alltraps
801072d2:	e9 11 f8 ff ff       	jmp    80106ae8 <alltraps>

801072d7 <vector33>:
.globl vector33
vector33:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $33
801072d9:	6a 21                	push   $0x21
  jmp alltraps
801072db:	e9 08 f8 ff ff       	jmp    80106ae8 <alltraps>

801072e0 <vector34>:
.globl vector34
vector34:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $34
801072e2:	6a 22                	push   $0x22
  jmp alltraps
801072e4:	e9 ff f7 ff ff       	jmp    80106ae8 <alltraps>

801072e9 <vector35>:
.globl vector35
vector35:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $35
801072eb:	6a 23                	push   $0x23
  jmp alltraps
801072ed:	e9 f6 f7 ff ff       	jmp    80106ae8 <alltraps>

801072f2 <vector36>:
.globl vector36
vector36:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $36
801072f4:	6a 24                	push   $0x24
  jmp alltraps
801072f6:	e9 ed f7 ff ff       	jmp    80106ae8 <alltraps>

801072fb <vector37>:
.globl vector37
vector37:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $37
801072fd:	6a 25                	push   $0x25
  jmp alltraps
801072ff:	e9 e4 f7 ff ff       	jmp    80106ae8 <alltraps>

80107304 <vector38>:
.globl vector38
vector38:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $38
80107306:	6a 26                	push   $0x26
  jmp alltraps
80107308:	e9 db f7 ff ff       	jmp    80106ae8 <alltraps>

8010730d <vector39>:
.globl vector39
vector39:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $39
8010730f:	6a 27                	push   $0x27
  jmp alltraps
80107311:	e9 d2 f7 ff ff       	jmp    80106ae8 <alltraps>

80107316 <vector40>:
.globl vector40
vector40:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $40
80107318:	6a 28                	push   $0x28
  jmp alltraps
8010731a:	e9 c9 f7 ff ff       	jmp    80106ae8 <alltraps>

8010731f <vector41>:
.globl vector41
vector41:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $41
80107321:	6a 29                	push   $0x29
  jmp alltraps
80107323:	e9 c0 f7 ff ff       	jmp    80106ae8 <alltraps>

80107328 <vector42>:
.globl vector42
vector42:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $42
8010732a:	6a 2a                	push   $0x2a
  jmp alltraps
8010732c:	e9 b7 f7 ff ff       	jmp    80106ae8 <alltraps>

80107331 <vector43>:
.globl vector43
vector43:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $43
80107333:	6a 2b                	push   $0x2b
  jmp alltraps
80107335:	e9 ae f7 ff ff       	jmp    80106ae8 <alltraps>

8010733a <vector44>:
.globl vector44
vector44:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $44
8010733c:	6a 2c                	push   $0x2c
  jmp alltraps
8010733e:	e9 a5 f7 ff ff       	jmp    80106ae8 <alltraps>

80107343 <vector45>:
.globl vector45
vector45:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $45
80107345:	6a 2d                	push   $0x2d
  jmp alltraps
80107347:	e9 9c f7 ff ff       	jmp    80106ae8 <alltraps>

8010734c <vector46>:
.globl vector46
vector46:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $46
8010734e:	6a 2e                	push   $0x2e
  jmp alltraps
80107350:	e9 93 f7 ff ff       	jmp    80106ae8 <alltraps>

80107355 <vector47>:
.globl vector47
vector47:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $47
80107357:	6a 2f                	push   $0x2f
  jmp alltraps
80107359:	e9 8a f7 ff ff       	jmp    80106ae8 <alltraps>

8010735e <vector48>:
.globl vector48
vector48:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $48
80107360:	6a 30                	push   $0x30
  jmp alltraps
80107362:	e9 81 f7 ff ff       	jmp    80106ae8 <alltraps>

80107367 <vector49>:
.globl vector49
vector49:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $49
80107369:	6a 31                	push   $0x31
  jmp alltraps
8010736b:	e9 78 f7 ff ff       	jmp    80106ae8 <alltraps>

80107370 <vector50>:
.globl vector50
vector50:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $50
80107372:	6a 32                	push   $0x32
  jmp alltraps
80107374:	e9 6f f7 ff ff       	jmp    80106ae8 <alltraps>

80107379 <vector51>:
.globl vector51
vector51:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $51
8010737b:	6a 33                	push   $0x33
  jmp alltraps
8010737d:	e9 66 f7 ff ff       	jmp    80106ae8 <alltraps>

80107382 <vector52>:
.globl vector52
vector52:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $52
80107384:	6a 34                	push   $0x34
  jmp alltraps
80107386:	e9 5d f7 ff ff       	jmp    80106ae8 <alltraps>

8010738b <vector53>:
.globl vector53
vector53:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $53
8010738d:	6a 35                	push   $0x35
  jmp alltraps
8010738f:	e9 54 f7 ff ff       	jmp    80106ae8 <alltraps>

80107394 <vector54>:
.globl vector54
vector54:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $54
80107396:	6a 36                	push   $0x36
  jmp alltraps
80107398:	e9 4b f7 ff ff       	jmp    80106ae8 <alltraps>

8010739d <vector55>:
.globl vector55
vector55:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $55
8010739f:	6a 37                	push   $0x37
  jmp alltraps
801073a1:	e9 42 f7 ff ff       	jmp    80106ae8 <alltraps>

801073a6 <vector56>:
.globl vector56
vector56:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $56
801073a8:	6a 38                	push   $0x38
  jmp alltraps
801073aa:	e9 39 f7 ff ff       	jmp    80106ae8 <alltraps>

801073af <vector57>:
.globl vector57
vector57:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $57
801073b1:	6a 39                	push   $0x39
  jmp alltraps
801073b3:	e9 30 f7 ff ff       	jmp    80106ae8 <alltraps>

801073b8 <vector58>:
.globl vector58
vector58:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $58
801073ba:	6a 3a                	push   $0x3a
  jmp alltraps
801073bc:	e9 27 f7 ff ff       	jmp    80106ae8 <alltraps>

801073c1 <vector59>:
.globl vector59
vector59:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $59
801073c3:	6a 3b                	push   $0x3b
  jmp alltraps
801073c5:	e9 1e f7 ff ff       	jmp    80106ae8 <alltraps>

801073ca <vector60>:
.globl vector60
vector60:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $60
801073cc:	6a 3c                	push   $0x3c
  jmp alltraps
801073ce:	e9 15 f7 ff ff       	jmp    80106ae8 <alltraps>

801073d3 <vector61>:
.globl vector61
vector61:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $61
801073d5:	6a 3d                	push   $0x3d
  jmp alltraps
801073d7:	e9 0c f7 ff ff       	jmp    80106ae8 <alltraps>

801073dc <vector62>:
.globl vector62
vector62:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $62
801073de:	6a 3e                	push   $0x3e
  jmp alltraps
801073e0:	e9 03 f7 ff ff       	jmp    80106ae8 <alltraps>

801073e5 <vector63>:
.globl vector63
vector63:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $63
801073e7:	6a 3f                	push   $0x3f
  jmp alltraps
801073e9:	e9 fa f6 ff ff       	jmp    80106ae8 <alltraps>

801073ee <vector64>:
.globl vector64
vector64:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $64
801073f0:	6a 40                	push   $0x40
  jmp alltraps
801073f2:	e9 f1 f6 ff ff       	jmp    80106ae8 <alltraps>

801073f7 <vector65>:
.globl vector65
vector65:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $65
801073f9:	6a 41                	push   $0x41
  jmp alltraps
801073fb:	e9 e8 f6 ff ff       	jmp    80106ae8 <alltraps>

80107400 <vector66>:
.globl vector66
vector66:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $66
80107402:	6a 42                	push   $0x42
  jmp alltraps
80107404:	e9 df f6 ff ff       	jmp    80106ae8 <alltraps>

80107409 <vector67>:
.globl vector67
vector67:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $67
8010740b:	6a 43                	push   $0x43
  jmp alltraps
8010740d:	e9 d6 f6 ff ff       	jmp    80106ae8 <alltraps>

80107412 <vector68>:
.globl vector68
vector68:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $68
80107414:	6a 44                	push   $0x44
  jmp alltraps
80107416:	e9 cd f6 ff ff       	jmp    80106ae8 <alltraps>

8010741b <vector69>:
.globl vector69
vector69:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $69
8010741d:	6a 45                	push   $0x45
  jmp alltraps
8010741f:	e9 c4 f6 ff ff       	jmp    80106ae8 <alltraps>

80107424 <vector70>:
.globl vector70
vector70:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $70
80107426:	6a 46                	push   $0x46
  jmp alltraps
80107428:	e9 bb f6 ff ff       	jmp    80106ae8 <alltraps>

8010742d <vector71>:
.globl vector71
vector71:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $71
8010742f:	6a 47                	push   $0x47
  jmp alltraps
80107431:	e9 b2 f6 ff ff       	jmp    80106ae8 <alltraps>

80107436 <vector72>:
.globl vector72
vector72:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $72
80107438:	6a 48                	push   $0x48
  jmp alltraps
8010743a:	e9 a9 f6 ff ff       	jmp    80106ae8 <alltraps>

8010743f <vector73>:
.globl vector73
vector73:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $73
80107441:	6a 49                	push   $0x49
  jmp alltraps
80107443:	e9 a0 f6 ff ff       	jmp    80106ae8 <alltraps>

80107448 <vector74>:
.globl vector74
vector74:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $74
8010744a:	6a 4a                	push   $0x4a
  jmp alltraps
8010744c:	e9 97 f6 ff ff       	jmp    80106ae8 <alltraps>

80107451 <vector75>:
.globl vector75
vector75:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $75
80107453:	6a 4b                	push   $0x4b
  jmp alltraps
80107455:	e9 8e f6 ff ff       	jmp    80106ae8 <alltraps>

8010745a <vector76>:
.globl vector76
vector76:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $76
8010745c:	6a 4c                	push   $0x4c
  jmp alltraps
8010745e:	e9 85 f6 ff ff       	jmp    80106ae8 <alltraps>

80107463 <vector77>:
.globl vector77
vector77:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $77
80107465:	6a 4d                	push   $0x4d
  jmp alltraps
80107467:	e9 7c f6 ff ff       	jmp    80106ae8 <alltraps>

8010746c <vector78>:
.globl vector78
vector78:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $78
8010746e:	6a 4e                	push   $0x4e
  jmp alltraps
80107470:	e9 73 f6 ff ff       	jmp    80106ae8 <alltraps>

80107475 <vector79>:
.globl vector79
vector79:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $79
80107477:	6a 4f                	push   $0x4f
  jmp alltraps
80107479:	e9 6a f6 ff ff       	jmp    80106ae8 <alltraps>

8010747e <vector80>:
.globl vector80
vector80:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $80
80107480:	6a 50                	push   $0x50
  jmp alltraps
80107482:	e9 61 f6 ff ff       	jmp    80106ae8 <alltraps>

80107487 <vector81>:
.globl vector81
vector81:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $81
80107489:	6a 51                	push   $0x51
  jmp alltraps
8010748b:	e9 58 f6 ff ff       	jmp    80106ae8 <alltraps>

80107490 <vector82>:
.globl vector82
vector82:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $82
80107492:	6a 52                	push   $0x52
  jmp alltraps
80107494:	e9 4f f6 ff ff       	jmp    80106ae8 <alltraps>

80107499 <vector83>:
.globl vector83
vector83:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $83
8010749b:	6a 53                	push   $0x53
  jmp alltraps
8010749d:	e9 46 f6 ff ff       	jmp    80106ae8 <alltraps>

801074a2 <vector84>:
.globl vector84
vector84:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $84
801074a4:	6a 54                	push   $0x54
  jmp alltraps
801074a6:	e9 3d f6 ff ff       	jmp    80106ae8 <alltraps>

801074ab <vector85>:
.globl vector85
vector85:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $85
801074ad:	6a 55                	push   $0x55
  jmp alltraps
801074af:	e9 34 f6 ff ff       	jmp    80106ae8 <alltraps>

801074b4 <vector86>:
.globl vector86
vector86:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $86
801074b6:	6a 56                	push   $0x56
  jmp alltraps
801074b8:	e9 2b f6 ff ff       	jmp    80106ae8 <alltraps>

801074bd <vector87>:
.globl vector87
vector87:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $87
801074bf:	6a 57                	push   $0x57
  jmp alltraps
801074c1:	e9 22 f6 ff ff       	jmp    80106ae8 <alltraps>

801074c6 <vector88>:
.globl vector88
vector88:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $88
801074c8:	6a 58                	push   $0x58
  jmp alltraps
801074ca:	e9 19 f6 ff ff       	jmp    80106ae8 <alltraps>

801074cf <vector89>:
.globl vector89
vector89:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $89
801074d1:	6a 59                	push   $0x59
  jmp alltraps
801074d3:	e9 10 f6 ff ff       	jmp    80106ae8 <alltraps>

801074d8 <vector90>:
.globl vector90
vector90:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $90
801074da:	6a 5a                	push   $0x5a
  jmp alltraps
801074dc:	e9 07 f6 ff ff       	jmp    80106ae8 <alltraps>

801074e1 <vector91>:
.globl vector91
vector91:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $91
801074e3:	6a 5b                	push   $0x5b
  jmp alltraps
801074e5:	e9 fe f5 ff ff       	jmp    80106ae8 <alltraps>

801074ea <vector92>:
.globl vector92
vector92:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $92
801074ec:	6a 5c                	push   $0x5c
  jmp alltraps
801074ee:	e9 f5 f5 ff ff       	jmp    80106ae8 <alltraps>

801074f3 <vector93>:
.globl vector93
vector93:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $93
801074f5:	6a 5d                	push   $0x5d
  jmp alltraps
801074f7:	e9 ec f5 ff ff       	jmp    80106ae8 <alltraps>

801074fc <vector94>:
.globl vector94
vector94:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $94
801074fe:	6a 5e                	push   $0x5e
  jmp alltraps
80107500:	e9 e3 f5 ff ff       	jmp    80106ae8 <alltraps>

80107505 <vector95>:
.globl vector95
vector95:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $95
80107507:	6a 5f                	push   $0x5f
  jmp alltraps
80107509:	e9 da f5 ff ff       	jmp    80106ae8 <alltraps>

8010750e <vector96>:
.globl vector96
vector96:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $96
80107510:	6a 60                	push   $0x60
  jmp alltraps
80107512:	e9 d1 f5 ff ff       	jmp    80106ae8 <alltraps>

80107517 <vector97>:
.globl vector97
vector97:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $97
80107519:	6a 61                	push   $0x61
  jmp alltraps
8010751b:	e9 c8 f5 ff ff       	jmp    80106ae8 <alltraps>

80107520 <vector98>:
.globl vector98
vector98:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $98
80107522:	6a 62                	push   $0x62
  jmp alltraps
80107524:	e9 bf f5 ff ff       	jmp    80106ae8 <alltraps>

80107529 <vector99>:
.globl vector99
vector99:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $99
8010752b:	6a 63                	push   $0x63
  jmp alltraps
8010752d:	e9 b6 f5 ff ff       	jmp    80106ae8 <alltraps>

80107532 <vector100>:
.globl vector100
vector100:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $100
80107534:	6a 64                	push   $0x64
  jmp alltraps
80107536:	e9 ad f5 ff ff       	jmp    80106ae8 <alltraps>

8010753b <vector101>:
.globl vector101
vector101:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $101
8010753d:	6a 65                	push   $0x65
  jmp alltraps
8010753f:	e9 a4 f5 ff ff       	jmp    80106ae8 <alltraps>

80107544 <vector102>:
.globl vector102
vector102:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $102
80107546:	6a 66                	push   $0x66
  jmp alltraps
80107548:	e9 9b f5 ff ff       	jmp    80106ae8 <alltraps>

8010754d <vector103>:
.globl vector103
vector103:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $103
8010754f:	6a 67                	push   $0x67
  jmp alltraps
80107551:	e9 92 f5 ff ff       	jmp    80106ae8 <alltraps>

80107556 <vector104>:
.globl vector104
vector104:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $104
80107558:	6a 68                	push   $0x68
  jmp alltraps
8010755a:	e9 89 f5 ff ff       	jmp    80106ae8 <alltraps>

8010755f <vector105>:
.globl vector105
vector105:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $105
80107561:	6a 69                	push   $0x69
  jmp alltraps
80107563:	e9 80 f5 ff ff       	jmp    80106ae8 <alltraps>

80107568 <vector106>:
.globl vector106
vector106:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $106
8010756a:	6a 6a                	push   $0x6a
  jmp alltraps
8010756c:	e9 77 f5 ff ff       	jmp    80106ae8 <alltraps>

80107571 <vector107>:
.globl vector107
vector107:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $107
80107573:	6a 6b                	push   $0x6b
  jmp alltraps
80107575:	e9 6e f5 ff ff       	jmp    80106ae8 <alltraps>

8010757a <vector108>:
.globl vector108
vector108:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $108
8010757c:	6a 6c                	push   $0x6c
  jmp alltraps
8010757e:	e9 65 f5 ff ff       	jmp    80106ae8 <alltraps>

80107583 <vector109>:
.globl vector109
vector109:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $109
80107585:	6a 6d                	push   $0x6d
  jmp alltraps
80107587:	e9 5c f5 ff ff       	jmp    80106ae8 <alltraps>

8010758c <vector110>:
.globl vector110
vector110:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $110
8010758e:	6a 6e                	push   $0x6e
  jmp alltraps
80107590:	e9 53 f5 ff ff       	jmp    80106ae8 <alltraps>

80107595 <vector111>:
.globl vector111
vector111:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $111
80107597:	6a 6f                	push   $0x6f
  jmp alltraps
80107599:	e9 4a f5 ff ff       	jmp    80106ae8 <alltraps>

8010759e <vector112>:
.globl vector112
vector112:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $112
801075a0:	6a 70                	push   $0x70
  jmp alltraps
801075a2:	e9 41 f5 ff ff       	jmp    80106ae8 <alltraps>

801075a7 <vector113>:
.globl vector113
vector113:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $113
801075a9:	6a 71                	push   $0x71
  jmp alltraps
801075ab:	e9 38 f5 ff ff       	jmp    80106ae8 <alltraps>

801075b0 <vector114>:
.globl vector114
vector114:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $114
801075b2:	6a 72                	push   $0x72
  jmp alltraps
801075b4:	e9 2f f5 ff ff       	jmp    80106ae8 <alltraps>

801075b9 <vector115>:
.globl vector115
vector115:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $115
801075bb:	6a 73                	push   $0x73
  jmp alltraps
801075bd:	e9 26 f5 ff ff       	jmp    80106ae8 <alltraps>

801075c2 <vector116>:
.globl vector116
vector116:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $116
801075c4:	6a 74                	push   $0x74
  jmp alltraps
801075c6:	e9 1d f5 ff ff       	jmp    80106ae8 <alltraps>

801075cb <vector117>:
.globl vector117
vector117:
  pushl $0
801075cb:	6a 00                	push   $0x0
  pushl $117
801075cd:	6a 75                	push   $0x75
  jmp alltraps
801075cf:	e9 14 f5 ff ff       	jmp    80106ae8 <alltraps>

801075d4 <vector118>:
.globl vector118
vector118:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $118
801075d6:	6a 76                	push   $0x76
  jmp alltraps
801075d8:	e9 0b f5 ff ff       	jmp    80106ae8 <alltraps>

801075dd <vector119>:
.globl vector119
vector119:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $119
801075df:	6a 77                	push   $0x77
  jmp alltraps
801075e1:	e9 02 f5 ff ff       	jmp    80106ae8 <alltraps>

801075e6 <vector120>:
.globl vector120
vector120:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $120
801075e8:	6a 78                	push   $0x78
  jmp alltraps
801075ea:	e9 f9 f4 ff ff       	jmp    80106ae8 <alltraps>

801075ef <vector121>:
.globl vector121
vector121:
  pushl $0
801075ef:	6a 00                	push   $0x0
  pushl $121
801075f1:	6a 79                	push   $0x79
  jmp alltraps
801075f3:	e9 f0 f4 ff ff       	jmp    80106ae8 <alltraps>

801075f8 <vector122>:
.globl vector122
vector122:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $122
801075fa:	6a 7a                	push   $0x7a
  jmp alltraps
801075fc:	e9 e7 f4 ff ff       	jmp    80106ae8 <alltraps>

80107601 <vector123>:
.globl vector123
vector123:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $123
80107603:	6a 7b                	push   $0x7b
  jmp alltraps
80107605:	e9 de f4 ff ff       	jmp    80106ae8 <alltraps>

8010760a <vector124>:
.globl vector124
vector124:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $124
8010760c:	6a 7c                	push   $0x7c
  jmp alltraps
8010760e:	e9 d5 f4 ff ff       	jmp    80106ae8 <alltraps>

80107613 <vector125>:
.globl vector125
vector125:
  pushl $0
80107613:	6a 00                	push   $0x0
  pushl $125
80107615:	6a 7d                	push   $0x7d
  jmp alltraps
80107617:	e9 cc f4 ff ff       	jmp    80106ae8 <alltraps>

8010761c <vector126>:
.globl vector126
vector126:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $126
8010761e:	6a 7e                	push   $0x7e
  jmp alltraps
80107620:	e9 c3 f4 ff ff       	jmp    80106ae8 <alltraps>

80107625 <vector127>:
.globl vector127
vector127:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $127
80107627:	6a 7f                	push   $0x7f
  jmp alltraps
80107629:	e9 ba f4 ff ff       	jmp    80106ae8 <alltraps>

8010762e <vector128>:
.globl vector128
vector128:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $128
80107630:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107635:	e9 ae f4 ff ff       	jmp    80106ae8 <alltraps>

8010763a <vector129>:
.globl vector129
vector129:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $129
8010763c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107641:	e9 a2 f4 ff ff       	jmp    80106ae8 <alltraps>

80107646 <vector130>:
.globl vector130
vector130:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $130
80107648:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010764d:	e9 96 f4 ff ff       	jmp    80106ae8 <alltraps>

80107652 <vector131>:
.globl vector131
vector131:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $131
80107654:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107659:	e9 8a f4 ff ff       	jmp    80106ae8 <alltraps>

8010765e <vector132>:
.globl vector132
vector132:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $132
80107660:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107665:	e9 7e f4 ff ff       	jmp    80106ae8 <alltraps>

8010766a <vector133>:
.globl vector133
vector133:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $133
8010766c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107671:	e9 72 f4 ff ff       	jmp    80106ae8 <alltraps>

80107676 <vector134>:
.globl vector134
vector134:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $134
80107678:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010767d:	e9 66 f4 ff ff       	jmp    80106ae8 <alltraps>

80107682 <vector135>:
.globl vector135
vector135:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $135
80107684:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107689:	e9 5a f4 ff ff       	jmp    80106ae8 <alltraps>

8010768e <vector136>:
.globl vector136
vector136:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $136
80107690:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107695:	e9 4e f4 ff ff       	jmp    80106ae8 <alltraps>

8010769a <vector137>:
.globl vector137
vector137:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $137
8010769c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801076a1:	e9 42 f4 ff ff       	jmp    80106ae8 <alltraps>

801076a6 <vector138>:
.globl vector138
vector138:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $138
801076a8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801076ad:	e9 36 f4 ff ff       	jmp    80106ae8 <alltraps>

801076b2 <vector139>:
.globl vector139
vector139:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $139
801076b4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801076b9:	e9 2a f4 ff ff       	jmp    80106ae8 <alltraps>

801076be <vector140>:
.globl vector140
vector140:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $140
801076c0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801076c5:	e9 1e f4 ff ff       	jmp    80106ae8 <alltraps>

801076ca <vector141>:
.globl vector141
vector141:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $141
801076cc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801076d1:	e9 12 f4 ff ff       	jmp    80106ae8 <alltraps>

801076d6 <vector142>:
.globl vector142
vector142:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $142
801076d8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801076dd:	e9 06 f4 ff ff       	jmp    80106ae8 <alltraps>

801076e2 <vector143>:
.globl vector143
vector143:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $143
801076e4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801076e9:	e9 fa f3 ff ff       	jmp    80106ae8 <alltraps>

801076ee <vector144>:
.globl vector144
vector144:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $144
801076f0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801076f5:	e9 ee f3 ff ff       	jmp    80106ae8 <alltraps>

801076fa <vector145>:
.globl vector145
vector145:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $145
801076fc:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107701:	e9 e2 f3 ff ff       	jmp    80106ae8 <alltraps>

80107706 <vector146>:
.globl vector146
vector146:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $146
80107708:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010770d:	e9 d6 f3 ff ff       	jmp    80106ae8 <alltraps>

80107712 <vector147>:
.globl vector147
vector147:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $147
80107714:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107719:	e9 ca f3 ff ff       	jmp    80106ae8 <alltraps>

8010771e <vector148>:
.globl vector148
vector148:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $148
80107720:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107725:	e9 be f3 ff ff       	jmp    80106ae8 <alltraps>

8010772a <vector149>:
.globl vector149
vector149:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $149
8010772c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107731:	e9 b2 f3 ff ff       	jmp    80106ae8 <alltraps>

80107736 <vector150>:
.globl vector150
vector150:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $150
80107738:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010773d:	e9 a6 f3 ff ff       	jmp    80106ae8 <alltraps>

80107742 <vector151>:
.globl vector151
vector151:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $151
80107744:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107749:	e9 9a f3 ff ff       	jmp    80106ae8 <alltraps>

8010774e <vector152>:
.globl vector152
vector152:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $152
80107750:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107755:	e9 8e f3 ff ff       	jmp    80106ae8 <alltraps>

8010775a <vector153>:
.globl vector153
vector153:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $153
8010775c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107761:	e9 82 f3 ff ff       	jmp    80106ae8 <alltraps>

80107766 <vector154>:
.globl vector154
vector154:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $154
80107768:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010776d:	e9 76 f3 ff ff       	jmp    80106ae8 <alltraps>

80107772 <vector155>:
.globl vector155
vector155:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $155
80107774:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107779:	e9 6a f3 ff ff       	jmp    80106ae8 <alltraps>

8010777e <vector156>:
.globl vector156
vector156:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $156
80107780:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107785:	e9 5e f3 ff ff       	jmp    80106ae8 <alltraps>

8010778a <vector157>:
.globl vector157
vector157:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $157
8010778c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107791:	e9 52 f3 ff ff       	jmp    80106ae8 <alltraps>

80107796 <vector158>:
.globl vector158
vector158:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $158
80107798:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010779d:	e9 46 f3 ff ff       	jmp    80106ae8 <alltraps>

801077a2 <vector159>:
.globl vector159
vector159:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $159
801077a4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801077a9:	e9 3a f3 ff ff       	jmp    80106ae8 <alltraps>

801077ae <vector160>:
.globl vector160
vector160:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $160
801077b0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801077b5:	e9 2e f3 ff ff       	jmp    80106ae8 <alltraps>

801077ba <vector161>:
.globl vector161
vector161:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $161
801077bc:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801077c1:	e9 22 f3 ff ff       	jmp    80106ae8 <alltraps>

801077c6 <vector162>:
.globl vector162
vector162:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $162
801077c8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801077cd:	e9 16 f3 ff ff       	jmp    80106ae8 <alltraps>

801077d2 <vector163>:
.globl vector163
vector163:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $163
801077d4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801077d9:	e9 0a f3 ff ff       	jmp    80106ae8 <alltraps>

801077de <vector164>:
.globl vector164
vector164:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $164
801077e0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801077e5:	e9 fe f2 ff ff       	jmp    80106ae8 <alltraps>

801077ea <vector165>:
.globl vector165
vector165:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $165
801077ec:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801077f1:	e9 f2 f2 ff ff       	jmp    80106ae8 <alltraps>

801077f6 <vector166>:
.globl vector166
vector166:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $166
801077f8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077fd:	e9 e6 f2 ff ff       	jmp    80106ae8 <alltraps>

80107802 <vector167>:
.globl vector167
vector167:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $167
80107804:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107809:	e9 da f2 ff ff       	jmp    80106ae8 <alltraps>

8010780e <vector168>:
.globl vector168
vector168:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $168
80107810:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107815:	e9 ce f2 ff ff       	jmp    80106ae8 <alltraps>

8010781a <vector169>:
.globl vector169
vector169:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $169
8010781c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107821:	e9 c2 f2 ff ff       	jmp    80106ae8 <alltraps>

80107826 <vector170>:
.globl vector170
vector170:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $170
80107828:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010782d:	e9 b6 f2 ff ff       	jmp    80106ae8 <alltraps>

80107832 <vector171>:
.globl vector171
vector171:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $171
80107834:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107839:	e9 aa f2 ff ff       	jmp    80106ae8 <alltraps>

8010783e <vector172>:
.globl vector172
vector172:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $172
80107840:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107845:	e9 9e f2 ff ff       	jmp    80106ae8 <alltraps>

8010784a <vector173>:
.globl vector173
vector173:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $173
8010784c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107851:	e9 92 f2 ff ff       	jmp    80106ae8 <alltraps>

80107856 <vector174>:
.globl vector174
vector174:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $174
80107858:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010785d:	e9 86 f2 ff ff       	jmp    80106ae8 <alltraps>

80107862 <vector175>:
.globl vector175
vector175:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $175
80107864:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107869:	e9 7a f2 ff ff       	jmp    80106ae8 <alltraps>

8010786e <vector176>:
.globl vector176
vector176:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $176
80107870:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107875:	e9 6e f2 ff ff       	jmp    80106ae8 <alltraps>

8010787a <vector177>:
.globl vector177
vector177:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $177
8010787c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107881:	e9 62 f2 ff ff       	jmp    80106ae8 <alltraps>

80107886 <vector178>:
.globl vector178
vector178:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $178
80107888:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010788d:	e9 56 f2 ff ff       	jmp    80106ae8 <alltraps>

80107892 <vector179>:
.globl vector179
vector179:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $179
80107894:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107899:	e9 4a f2 ff ff       	jmp    80106ae8 <alltraps>

8010789e <vector180>:
.globl vector180
vector180:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $180
801078a0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801078a5:	e9 3e f2 ff ff       	jmp    80106ae8 <alltraps>

801078aa <vector181>:
.globl vector181
vector181:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $181
801078ac:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801078b1:	e9 32 f2 ff ff       	jmp    80106ae8 <alltraps>

801078b6 <vector182>:
.globl vector182
vector182:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $182
801078b8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801078bd:	e9 26 f2 ff ff       	jmp    80106ae8 <alltraps>

801078c2 <vector183>:
.globl vector183
vector183:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $183
801078c4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801078c9:	e9 1a f2 ff ff       	jmp    80106ae8 <alltraps>

801078ce <vector184>:
.globl vector184
vector184:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $184
801078d0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801078d5:	e9 0e f2 ff ff       	jmp    80106ae8 <alltraps>

801078da <vector185>:
.globl vector185
vector185:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $185
801078dc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801078e1:	e9 02 f2 ff ff       	jmp    80106ae8 <alltraps>

801078e6 <vector186>:
.globl vector186
vector186:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $186
801078e8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801078ed:	e9 f6 f1 ff ff       	jmp    80106ae8 <alltraps>

801078f2 <vector187>:
.globl vector187
vector187:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $187
801078f4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801078f9:	e9 ea f1 ff ff       	jmp    80106ae8 <alltraps>

801078fe <vector188>:
.globl vector188
vector188:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $188
80107900:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107905:	e9 de f1 ff ff       	jmp    80106ae8 <alltraps>

8010790a <vector189>:
.globl vector189
vector189:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $189
8010790c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107911:	e9 d2 f1 ff ff       	jmp    80106ae8 <alltraps>

80107916 <vector190>:
.globl vector190
vector190:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $190
80107918:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010791d:	e9 c6 f1 ff ff       	jmp    80106ae8 <alltraps>

80107922 <vector191>:
.globl vector191
vector191:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $191
80107924:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107929:	e9 ba f1 ff ff       	jmp    80106ae8 <alltraps>

8010792e <vector192>:
.globl vector192
vector192:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $192
80107930:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107935:	e9 ae f1 ff ff       	jmp    80106ae8 <alltraps>

8010793a <vector193>:
.globl vector193
vector193:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $193
8010793c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107941:	e9 a2 f1 ff ff       	jmp    80106ae8 <alltraps>

80107946 <vector194>:
.globl vector194
vector194:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $194
80107948:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010794d:	e9 96 f1 ff ff       	jmp    80106ae8 <alltraps>

80107952 <vector195>:
.globl vector195
vector195:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $195
80107954:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107959:	e9 8a f1 ff ff       	jmp    80106ae8 <alltraps>

8010795e <vector196>:
.globl vector196
vector196:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $196
80107960:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107965:	e9 7e f1 ff ff       	jmp    80106ae8 <alltraps>

8010796a <vector197>:
.globl vector197
vector197:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $197
8010796c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107971:	e9 72 f1 ff ff       	jmp    80106ae8 <alltraps>

80107976 <vector198>:
.globl vector198
vector198:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $198
80107978:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010797d:	e9 66 f1 ff ff       	jmp    80106ae8 <alltraps>

80107982 <vector199>:
.globl vector199
vector199:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $199
80107984:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107989:	e9 5a f1 ff ff       	jmp    80106ae8 <alltraps>

8010798e <vector200>:
.globl vector200
vector200:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $200
80107990:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107995:	e9 4e f1 ff ff       	jmp    80106ae8 <alltraps>

8010799a <vector201>:
.globl vector201
vector201:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $201
8010799c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801079a1:	e9 42 f1 ff ff       	jmp    80106ae8 <alltraps>

801079a6 <vector202>:
.globl vector202
vector202:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $202
801079a8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801079ad:	e9 36 f1 ff ff       	jmp    80106ae8 <alltraps>

801079b2 <vector203>:
.globl vector203
vector203:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $203
801079b4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801079b9:	e9 2a f1 ff ff       	jmp    80106ae8 <alltraps>

801079be <vector204>:
.globl vector204
vector204:
  pushl $0
801079be:	6a 00                	push   $0x0
  pushl $204
801079c0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801079c5:	e9 1e f1 ff ff       	jmp    80106ae8 <alltraps>

801079ca <vector205>:
.globl vector205
vector205:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $205
801079cc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801079d1:	e9 12 f1 ff ff       	jmp    80106ae8 <alltraps>

801079d6 <vector206>:
.globl vector206
vector206:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $206
801079d8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801079dd:	e9 06 f1 ff ff       	jmp    80106ae8 <alltraps>

801079e2 <vector207>:
.globl vector207
vector207:
  pushl $0
801079e2:	6a 00                	push   $0x0
  pushl $207
801079e4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801079e9:	e9 fa f0 ff ff       	jmp    80106ae8 <alltraps>

801079ee <vector208>:
.globl vector208
vector208:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $208
801079f0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801079f5:	e9 ee f0 ff ff       	jmp    80106ae8 <alltraps>

801079fa <vector209>:
.globl vector209
vector209:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $209
801079fc:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107a01:	e9 e2 f0 ff ff       	jmp    80106ae8 <alltraps>

80107a06 <vector210>:
.globl vector210
vector210:
  pushl $0
80107a06:	6a 00                	push   $0x0
  pushl $210
80107a08:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107a0d:	e9 d6 f0 ff ff       	jmp    80106ae8 <alltraps>

80107a12 <vector211>:
.globl vector211
vector211:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $211
80107a14:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107a19:	e9 ca f0 ff ff       	jmp    80106ae8 <alltraps>

80107a1e <vector212>:
.globl vector212
vector212:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $212
80107a20:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107a25:	e9 be f0 ff ff       	jmp    80106ae8 <alltraps>

80107a2a <vector213>:
.globl vector213
vector213:
  pushl $0
80107a2a:	6a 00                	push   $0x0
  pushl $213
80107a2c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107a31:	e9 b2 f0 ff ff       	jmp    80106ae8 <alltraps>

80107a36 <vector214>:
.globl vector214
vector214:
  pushl $0
80107a36:	6a 00                	push   $0x0
  pushl $214
80107a38:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107a3d:	e9 a6 f0 ff ff       	jmp    80106ae8 <alltraps>

80107a42 <vector215>:
.globl vector215
vector215:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $215
80107a44:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107a49:	e9 9a f0 ff ff       	jmp    80106ae8 <alltraps>

80107a4e <vector216>:
.globl vector216
vector216:
  pushl $0
80107a4e:	6a 00                	push   $0x0
  pushl $216
80107a50:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a55:	e9 8e f0 ff ff       	jmp    80106ae8 <alltraps>

80107a5a <vector217>:
.globl vector217
vector217:
  pushl $0
80107a5a:	6a 00                	push   $0x0
  pushl $217
80107a5c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a61:	e9 82 f0 ff ff       	jmp    80106ae8 <alltraps>

80107a66 <vector218>:
.globl vector218
vector218:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $218
80107a68:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a6d:	e9 76 f0 ff ff       	jmp    80106ae8 <alltraps>

80107a72 <vector219>:
.globl vector219
vector219:
  pushl $0
80107a72:	6a 00                	push   $0x0
  pushl $219
80107a74:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a79:	e9 6a f0 ff ff       	jmp    80106ae8 <alltraps>

80107a7e <vector220>:
.globl vector220
vector220:
  pushl $0
80107a7e:	6a 00                	push   $0x0
  pushl $220
80107a80:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a85:	e9 5e f0 ff ff       	jmp    80106ae8 <alltraps>

80107a8a <vector221>:
.globl vector221
vector221:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $221
80107a8c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a91:	e9 52 f0 ff ff       	jmp    80106ae8 <alltraps>

80107a96 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a96:	6a 00                	push   $0x0
  pushl $222
80107a98:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a9d:	e9 46 f0 ff ff       	jmp    80106ae8 <alltraps>

80107aa2 <vector223>:
.globl vector223
vector223:
  pushl $0
80107aa2:	6a 00                	push   $0x0
  pushl $223
80107aa4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107aa9:	e9 3a f0 ff ff       	jmp    80106ae8 <alltraps>

80107aae <vector224>:
.globl vector224
vector224:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $224
80107ab0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107ab5:	e9 2e f0 ff ff       	jmp    80106ae8 <alltraps>

80107aba <vector225>:
.globl vector225
vector225:
  pushl $0
80107aba:	6a 00                	push   $0x0
  pushl $225
80107abc:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107ac1:	e9 22 f0 ff ff       	jmp    80106ae8 <alltraps>

80107ac6 <vector226>:
.globl vector226
vector226:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $226
80107ac8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107acd:	e9 16 f0 ff ff       	jmp    80106ae8 <alltraps>

80107ad2 <vector227>:
.globl vector227
vector227:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $227
80107ad4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107ad9:	e9 0a f0 ff ff       	jmp    80106ae8 <alltraps>

80107ade <vector228>:
.globl vector228
vector228:
  pushl $0
80107ade:	6a 00                	push   $0x0
  pushl $228
80107ae0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107ae5:	e9 fe ef ff ff       	jmp    80106ae8 <alltraps>

80107aea <vector229>:
.globl vector229
vector229:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $229
80107aec:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107af1:	e9 f2 ef ff ff       	jmp    80106ae8 <alltraps>

80107af6 <vector230>:
.globl vector230
vector230:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $230
80107af8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107afd:	e9 e6 ef ff ff       	jmp    80106ae8 <alltraps>

80107b02 <vector231>:
.globl vector231
vector231:
  pushl $0
80107b02:	6a 00                	push   $0x0
  pushl $231
80107b04:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107b09:	e9 da ef ff ff       	jmp    80106ae8 <alltraps>

80107b0e <vector232>:
.globl vector232
vector232:
  pushl $0
80107b0e:	6a 00                	push   $0x0
  pushl $232
80107b10:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107b15:	e9 ce ef ff ff       	jmp    80106ae8 <alltraps>

80107b1a <vector233>:
.globl vector233
vector233:
  pushl $0
80107b1a:	6a 00                	push   $0x0
  pushl $233
80107b1c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107b21:	e9 c2 ef ff ff       	jmp    80106ae8 <alltraps>

80107b26 <vector234>:
.globl vector234
vector234:
  pushl $0
80107b26:	6a 00                	push   $0x0
  pushl $234
80107b28:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107b2d:	e9 b6 ef ff ff       	jmp    80106ae8 <alltraps>

80107b32 <vector235>:
.globl vector235
vector235:
  pushl $0
80107b32:	6a 00                	push   $0x0
  pushl $235
80107b34:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107b39:	e9 aa ef ff ff       	jmp    80106ae8 <alltraps>

80107b3e <vector236>:
.globl vector236
vector236:
  pushl $0
80107b3e:	6a 00                	push   $0x0
  pushl $236
80107b40:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107b45:	e9 9e ef ff ff       	jmp    80106ae8 <alltraps>

80107b4a <vector237>:
.globl vector237
vector237:
  pushl $0
80107b4a:	6a 00                	push   $0x0
  pushl $237
80107b4c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b51:	e9 92 ef ff ff       	jmp    80106ae8 <alltraps>

80107b56 <vector238>:
.globl vector238
vector238:
  pushl $0
80107b56:	6a 00                	push   $0x0
  pushl $238
80107b58:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b5d:	e9 86 ef ff ff       	jmp    80106ae8 <alltraps>

80107b62 <vector239>:
.globl vector239
vector239:
  pushl $0
80107b62:	6a 00                	push   $0x0
  pushl $239
80107b64:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b69:	e9 7a ef ff ff       	jmp    80106ae8 <alltraps>

80107b6e <vector240>:
.globl vector240
vector240:
  pushl $0
80107b6e:	6a 00                	push   $0x0
  pushl $240
80107b70:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b75:	e9 6e ef ff ff       	jmp    80106ae8 <alltraps>

80107b7a <vector241>:
.globl vector241
vector241:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $241
80107b7c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b81:	e9 62 ef ff ff       	jmp    80106ae8 <alltraps>

80107b86 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b86:	6a 00                	push   $0x0
  pushl $242
80107b88:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b8d:	e9 56 ef ff ff       	jmp    80106ae8 <alltraps>

80107b92 <vector243>:
.globl vector243
vector243:
  pushl $0
80107b92:	6a 00                	push   $0x0
  pushl $243
80107b94:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b99:	e9 4a ef ff ff       	jmp    80106ae8 <alltraps>

80107b9e <vector244>:
.globl vector244
vector244:
  pushl $0
80107b9e:	6a 00                	push   $0x0
  pushl $244
80107ba0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107ba5:	e9 3e ef ff ff       	jmp    80106ae8 <alltraps>

80107baa <vector245>:
.globl vector245
vector245:
  pushl $0
80107baa:	6a 00                	push   $0x0
  pushl $245
80107bac:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107bb1:	e9 32 ef ff ff       	jmp    80106ae8 <alltraps>

80107bb6 <vector246>:
.globl vector246
vector246:
  pushl $0
80107bb6:	6a 00                	push   $0x0
  pushl $246
80107bb8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107bbd:	e9 26 ef ff ff       	jmp    80106ae8 <alltraps>

80107bc2 <vector247>:
.globl vector247
vector247:
  pushl $0
80107bc2:	6a 00                	push   $0x0
  pushl $247
80107bc4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107bc9:	e9 1a ef ff ff       	jmp    80106ae8 <alltraps>

80107bce <vector248>:
.globl vector248
vector248:
  pushl $0
80107bce:	6a 00                	push   $0x0
  pushl $248
80107bd0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107bd5:	e9 0e ef ff ff       	jmp    80106ae8 <alltraps>

80107bda <vector249>:
.globl vector249
vector249:
  pushl $0
80107bda:	6a 00                	push   $0x0
  pushl $249
80107bdc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107be1:	e9 02 ef ff ff       	jmp    80106ae8 <alltraps>

80107be6 <vector250>:
.globl vector250
vector250:
  pushl $0
80107be6:	6a 00                	push   $0x0
  pushl $250
80107be8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107bed:	e9 f6 ee ff ff       	jmp    80106ae8 <alltraps>

80107bf2 <vector251>:
.globl vector251
vector251:
  pushl $0
80107bf2:	6a 00                	push   $0x0
  pushl $251
80107bf4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107bf9:	e9 ea ee ff ff       	jmp    80106ae8 <alltraps>

80107bfe <vector252>:
.globl vector252
vector252:
  pushl $0
80107bfe:	6a 00                	push   $0x0
  pushl $252
80107c00:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107c05:	e9 de ee ff ff       	jmp    80106ae8 <alltraps>

80107c0a <vector253>:
.globl vector253
vector253:
  pushl $0
80107c0a:	6a 00                	push   $0x0
  pushl $253
80107c0c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107c11:	e9 d2 ee ff ff       	jmp    80106ae8 <alltraps>

80107c16 <vector254>:
.globl vector254
vector254:
  pushl $0
80107c16:	6a 00                	push   $0x0
  pushl $254
80107c18:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107c1d:	e9 c6 ee ff ff       	jmp    80106ae8 <alltraps>

80107c22 <vector255>:
.globl vector255
vector255:
  pushl $0
80107c22:	6a 00                	push   $0x0
  pushl $255
80107c24:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107c29:	e9 ba ee ff ff       	jmp    80106ae8 <alltraps>
	...

80107c30 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107c30:	55                   	push   %ebp
80107c31:	89 e5                	mov    %esp,%ebp
80107c33:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107c36:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c39:	83 e8 01             	sub    $0x1,%eax
80107c3c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107c40:	8b 45 08             	mov    0x8(%ebp),%eax
80107c43:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107c47:	8b 45 08             	mov    0x8(%ebp),%eax
80107c4a:	c1 e8 10             	shr    $0x10,%eax
80107c4d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107c51:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107c54:	0f 01 10             	lgdtl  (%eax)
}
80107c57:	c9                   	leave  
80107c58:	c3                   	ret    

80107c59 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107c59:	55                   	push   %ebp
80107c5a:	89 e5                	mov    %esp,%ebp
80107c5c:	83 ec 04             	sub    $0x4,%esp
80107c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80107c62:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c66:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c6a:	0f 00 d8             	ltr    %ax
}
80107c6d:	c9                   	leave  
80107c6e:	c3                   	ret    

80107c6f <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107c6f:	55                   	push   %ebp
80107c70:	89 e5                	mov    %esp,%ebp
80107c72:	83 ec 04             	sub    $0x4,%esp
80107c75:	8b 45 08             	mov    0x8(%ebp),%eax
80107c78:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107c7c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c80:	8e e8                	mov    %eax,%gs
}
80107c82:	c9                   	leave  
80107c83:	c3                   	ret    

80107c84 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107c84:	55                   	push   %ebp
80107c85:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c87:	8b 45 08             	mov    0x8(%ebp),%eax
80107c8a:	0f 22 d8             	mov    %eax,%cr3
}
80107c8d:	5d                   	pop    %ebp
80107c8e:	c3                   	ret    

80107c8f <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107c8f:	55                   	push   %ebp
80107c90:	89 e5                	mov    %esp,%ebp
80107c92:	8b 45 08             	mov    0x8(%ebp),%eax
80107c95:	05 00 00 00 80       	add    $0x80000000,%eax
80107c9a:	5d                   	pop    %ebp
80107c9b:	c3                   	ret    

80107c9c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107c9c:	55                   	push   %ebp
80107c9d:	89 e5                	mov    %esp,%ebp
80107c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca2:	05 00 00 00 80       	add    $0x80000000,%eax
80107ca7:	5d                   	pop    %ebp
80107ca8:	c3                   	ret    

80107ca9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107ca9:	55                   	push   %ebp
80107caa:	89 e5                	mov    %esp,%ebp
80107cac:	53                   	push   %ebx
80107cad:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107cb0:	e8 48 b5 ff ff       	call   801031fd <cpunum>
80107cb5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107cbb:	05 40 09 11 80       	add    $0x80110940,%eax
80107cc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc6:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccf:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd8:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdf:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ce3:	83 e2 f0             	and    $0xfffffff0,%edx
80107ce6:	83 ca 0a             	or     $0xa,%edx
80107ce9:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cf3:	83 ca 10             	or     $0x10,%edx
80107cf6:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d00:	83 e2 9f             	and    $0xffffff9f,%edx
80107d03:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d0d:	83 ca 80             	or     $0xffffff80,%edx
80107d10:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d1a:	83 ca 0f             	or     $0xf,%edx
80107d1d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d23:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d27:	83 e2 ef             	and    $0xffffffef,%edx
80107d2a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d30:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d34:	83 e2 df             	and    $0xffffffdf,%edx
80107d37:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d41:	83 ca 40             	or     $0x40,%edx
80107d44:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d4e:	83 ca 80             	or     $0xffffff80,%edx
80107d51:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d57:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107d65:	ff ff 
80107d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107d71:	00 00 
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d80:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d87:	83 e2 f0             	and    $0xfffffff0,%edx
80107d8a:	83 ca 02             	or     $0x2,%edx
80107d8d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d96:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d9d:	83 ca 10             	or     $0x10,%edx
80107da0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107db0:	83 e2 9f             	and    $0xffffff9f,%edx
80107db3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dc3:	83 ca 80             	or     $0xffffff80,%edx
80107dc6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dd6:	83 ca 0f             	or     $0xf,%edx
80107dd9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107de9:	83 e2 ef             	and    $0xffffffef,%edx
80107dec:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dfc:	83 e2 df             	and    $0xffffffdf,%edx
80107dff:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e08:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e0f:	83 ca 40             	or     $0x40,%edx
80107e12:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e22:	83 ca 80             	or     $0xffffff80,%edx
80107e25:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107e3f:	ff ff 
80107e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e44:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107e4b:	00 00 
80107e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e50:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e61:	83 e2 f0             	and    $0xfffffff0,%edx
80107e64:	83 ca 0a             	or     $0xa,%edx
80107e67:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e77:	83 ca 10             	or     $0x10,%edx
80107e7a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e83:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e8a:	83 ca 60             	or     $0x60,%edx
80107e8d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e96:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e9d:	83 ca 80             	or     $0xffffff80,%edx
80107ea0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107eb0:	83 ca 0f             	or     $0xf,%edx
80107eb3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ec3:	83 e2 ef             	and    $0xffffffef,%edx
80107ec6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ed6:	83 e2 df             	and    $0xffffffdf,%edx
80107ed9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ee9:	83 ca 40             	or     $0x40,%edx
80107eec:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107efc:	83 ca 80             	or     $0xffffff80,%edx
80107eff:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f12:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107f19:	ff ff 
80107f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107f25:	00 00 
80107f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f34:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f3b:	83 e2 f0             	and    $0xfffffff0,%edx
80107f3e:	83 ca 02             	or     $0x2,%edx
80107f41:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f51:	83 ca 10             	or     $0x10,%edx
80107f54:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f64:	83 ca 60             	or     $0x60,%edx
80107f67:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f70:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f77:	83 ca 80             	or     $0xffffff80,%edx
80107f7a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f83:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f8a:	83 ca 0f             	or     $0xf,%edx
80107f8d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f9d:	83 e2 ef             	and    $0xffffffef,%edx
80107fa0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107fb0:	83 e2 df             	and    $0xffffffdf,%edx
80107fb3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbc:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107fc3:	83 ca 40             	or     $0x40,%edx
80107fc6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107fd6:	83 ca 80             	or     $0xffffff80,%edx
80107fd9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe2:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fec:	05 b4 00 00 00       	add    $0xb4,%eax
80107ff1:	89 c3                	mov    %eax,%ebx
80107ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff6:	05 b4 00 00 00       	add    $0xb4,%eax
80107ffb:	c1 e8 10             	shr    $0x10,%eax
80107ffe:	89 c1                	mov    %eax,%ecx
80108000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108003:	05 b4 00 00 00       	add    $0xb4,%eax
80108008:	c1 e8 18             	shr    $0x18,%eax
8010800b:	89 c2                	mov    %eax,%edx
8010800d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108010:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108017:	00 00 
80108019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108026:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
8010802c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108036:	83 e1 f0             	and    $0xfffffff0,%ecx
80108039:	83 c9 02             	or     $0x2,%ecx
8010803c:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108045:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010804c:	83 c9 10             	or     $0x10,%ecx
8010804f:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010805f:	83 e1 9f             	and    $0xffffff9f,%ecx
80108062:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108072:	83 c9 80             	or     $0xffffff80,%ecx
80108075:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010807b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108085:	83 e1 f0             	and    $0xfffffff0,%ecx
80108088:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010808e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108091:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108098:	83 e1 ef             	and    $0xffffffef,%ecx
8010809b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801080a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a4:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801080ab:	83 e1 df             	and    $0xffffffdf,%ecx
801080ae:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801080b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b7:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801080be:	83 c9 40             	or     $0x40,%ecx
801080c1:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801080c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ca:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801080d1:	83 c9 80             	or     $0xffffff80,%ecx
801080d4:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801080da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080dd:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801080e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e6:	83 c0 70             	add    $0x70,%eax
801080e9:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
801080f0:	00 
801080f1:	89 04 24             	mov    %eax,(%esp)
801080f4:	e8 37 fb ff ff       	call   80107c30 <lgdt>
  loadgs(SEG_KCPU << 3);
801080f9:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108100:	e8 6a fb ff ff       	call   80107c6f <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80108105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108108:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010810e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108115:	00 00 00 00 
}
80108119:	83 c4 24             	add    $0x24,%esp
8010811c:	5b                   	pop    %ebx
8010811d:	5d                   	pop    %ebp
8010811e:	c3                   	ret    

8010811f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010811f:	55                   	push   %ebp
80108120:	89 e5                	mov    %esp,%ebp
80108122:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108125:	8b 45 0c             	mov    0xc(%ebp),%eax
80108128:	c1 e8 16             	shr    $0x16,%eax
8010812b:	c1 e0 02             	shl    $0x2,%eax
8010812e:	03 45 08             	add    0x8(%ebp),%eax
80108131:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108137:	8b 00                	mov    (%eax),%eax
80108139:	83 e0 01             	and    $0x1,%eax
8010813c:	84 c0                	test   %al,%al
8010813e:	74 17                	je     80108157 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108143:	8b 00                	mov    (%eax),%eax
80108145:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010814a:	89 04 24             	mov    %eax,(%esp)
8010814d:	e8 4a fb ff ff       	call   80107c9c <p2v>
80108152:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108155:	eb 4b                	jmp    801081a2 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108157:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010815b:	74 0e                	je     8010816b <walkpgdir+0x4c>
8010815d:	e8 0d ad ff ff       	call   80102e6f <kalloc>
80108162:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108165:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108169:	75 07                	jne    80108172 <walkpgdir+0x53>
      return 0;
8010816b:	b8 00 00 00 00       	mov    $0x0,%eax
80108170:	eb 41                	jmp    801081b3 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108172:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108179:	00 
8010817a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108181:	00 
80108182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108185:	89 04 24             	mov    %eax,(%esp)
80108188:	e8 b5 d4 ff ff       	call   80105642 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010818d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108190:	89 04 24             	mov    %eax,(%esp)
80108193:	e8 f7 fa ff ff       	call   80107c8f <v2p>
80108198:	89 c2                	mov    %eax,%edx
8010819a:	83 ca 07             	or     $0x7,%edx
8010819d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081a0:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801081a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801081a5:	c1 e8 0c             	shr    $0xc,%eax
801081a8:	25 ff 03 00 00       	and    $0x3ff,%eax
801081ad:	c1 e0 02             	shl    $0x2,%eax
801081b0:	03 45 f4             	add    -0xc(%ebp),%eax
}
801081b3:	c9                   	leave  
801081b4:	c3                   	ret    

801081b5 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801081b5:	55                   	push   %ebp
801081b6:	89 e5                	mov    %esp,%ebp
801081b8:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
801081bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801081be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801081c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801081c9:	03 45 10             	add    0x10(%ebp),%eax
801081cc:	83 e8 01             	sub    $0x1,%eax
801081cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801081d7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801081de:	00 
801081df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801081e6:	8b 45 08             	mov    0x8(%ebp),%eax
801081e9:	89 04 24             	mov    %eax,(%esp)
801081ec:	e8 2e ff ff ff       	call   8010811f <walkpgdir>
801081f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081f8:	75 07                	jne    80108201 <mappages+0x4c>
      return -1;
801081fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081ff:	eb 46                	jmp    80108247 <mappages+0x92>
    if(*pte & PTE_P)
80108201:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108204:	8b 00                	mov    (%eax),%eax
80108206:	83 e0 01             	and    $0x1,%eax
80108209:	84 c0                	test   %al,%al
8010820b:	74 0c                	je     80108219 <mappages+0x64>
      panic("remap");
8010820d:	c7 04 24 2c 90 10 80 	movl   $0x8010902c,(%esp)
80108214:	e8 24 83 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108219:	8b 45 18             	mov    0x18(%ebp),%eax
8010821c:	0b 45 14             	or     0x14(%ebp),%eax
8010821f:	89 c2                	mov    %eax,%edx
80108221:	83 ca 01             	or     $0x1,%edx
80108224:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108227:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010822f:	74 10                	je     80108241 <mappages+0x8c>
      break;
    a += PGSIZE;
80108231:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108238:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010823f:	eb 96                	jmp    801081d7 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108241:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108242:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108247:	c9                   	leave  
80108248:	c3                   	ret    

80108249 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80108249:	55                   	push   %ebp
8010824a:	89 e5                	mov    %esp,%ebp
8010824c:	53                   	push   %ebx
8010824d:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108250:	e8 1a ac ff ff       	call   80102e6f <kalloc>
80108255:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108258:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010825c:	75 0a                	jne    80108268 <setupkvm+0x1f>
    return 0;
8010825e:	b8 00 00 00 00       	mov    $0x0,%eax
80108263:	e9 98 00 00 00       	jmp    80108300 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108268:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010826f:	00 
80108270:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108277:	00 
80108278:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010827b:	89 04 24             	mov    %eax,(%esp)
8010827e:	e8 bf d3 ff ff       	call   80105642 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108283:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
8010828a:	e8 0d fa ff ff       	call   80107c9c <p2v>
8010828f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108294:	76 0c                	jbe    801082a2 <setupkvm+0x59>
    panic("PHYSTOP too high");
80108296:	c7 04 24 32 90 10 80 	movl   $0x80109032,(%esp)
8010829d:	e8 9b 82 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801082a2:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801082a9:	eb 49                	jmp    801082f4 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801082ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801082ae:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801082b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801082b4:	8b 50 04             	mov    0x4(%eax),%edx
801082b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ba:	8b 58 08             	mov    0x8(%eax),%ebx
801082bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c0:	8b 40 04             	mov    0x4(%eax),%eax
801082c3:	29 c3                	sub    %eax,%ebx
801082c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c8:	8b 00                	mov    (%eax),%eax
801082ca:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801082ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
801082d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801082d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801082da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082dd:	89 04 24             	mov    %eax,(%esp)
801082e0:	e8 d0 fe ff ff       	call   801081b5 <mappages>
801082e5:	85 c0                	test   %eax,%eax
801082e7:	79 07                	jns    801082f0 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801082e9:	b8 00 00 00 00       	mov    $0x0,%eax
801082ee:	eb 10                	jmp    80108300 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801082f0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801082f4:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
801082fb:	72 ae                	jb     801082ab <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801082fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108300:	83 c4 34             	add    $0x34,%esp
80108303:	5b                   	pop    %ebx
80108304:	5d                   	pop    %ebp
80108305:	c3                   	ret    

80108306 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108306:	55                   	push   %ebp
80108307:	89 e5                	mov    %esp,%ebp
80108309:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010830c:	e8 38 ff ff ff       	call   80108249 <setupkvm>
80108311:	a3 18 3d 11 80       	mov    %eax,0x80113d18
  switchkvm();
80108316:	e8 02 00 00 00       	call   8010831d <switchkvm>
}
8010831b:	c9                   	leave  
8010831c:	c3                   	ret    

8010831d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010831d:	55                   	push   %ebp
8010831e:	89 e5                	mov    %esp,%ebp
80108320:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108323:	a1 18 3d 11 80       	mov    0x80113d18,%eax
80108328:	89 04 24             	mov    %eax,(%esp)
8010832b:	e8 5f f9 ff ff       	call   80107c8f <v2p>
80108330:	89 04 24             	mov    %eax,(%esp)
80108333:	e8 4c f9 ff ff       	call   80107c84 <lcr3>
}
80108338:	c9                   	leave  
80108339:	c3                   	ret    

8010833a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010833a:	55                   	push   %ebp
8010833b:	89 e5                	mov    %esp,%ebp
8010833d:	53                   	push   %ebx
8010833e:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108341:	e8 f5 d1 ff ff       	call   8010553b <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108346:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010834c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108353:	83 c2 08             	add    $0x8,%edx
80108356:	89 d3                	mov    %edx,%ebx
80108358:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010835f:	83 c2 08             	add    $0x8,%edx
80108362:	c1 ea 10             	shr    $0x10,%edx
80108365:	89 d1                	mov    %edx,%ecx
80108367:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010836e:	83 c2 08             	add    $0x8,%edx
80108371:	c1 ea 18             	shr    $0x18,%edx
80108374:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010837b:	67 00 
8010837d:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108384:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
8010838a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108391:	83 e1 f0             	and    $0xfffffff0,%ecx
80108394:	83 c9 09             	or     $0x9,%ecx
80108397:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010839d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801083a4:	83 c9 10             	or     $0x10,%ecx
801083a7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801083ad:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801083b4:	83 e1 9f             	and    $0xffffff9f,%ecx
801083b7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801083bd:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801083c4:	83 c9 80             	or     $0xffffff80,%ecx
801083c7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801083cd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083d4:	83 e1 f0             	and    $0xfffffff0,%ecx
801083d7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083dd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083e4:	83 e1 ef             	and    $0xffffffef,%ecx
801083e7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083ed:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801083f4:	83 e1 df             	and    $0xffffffdf,%ecx
801083f7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801083fd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108404:	83 c9 40             	or     $0x40,%ecx
80108407:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010840d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108414:	83 e1 7f             	and    $0x7f,%ecx
80108417:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010841d:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108423:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108429:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108430:	83 e2 ef             	and    $0xffffffef,%edx
80108433:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108439:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010843f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108445:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010844b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108452:	8b 52 08             	mov    0x8(%edx),%edx
80108455:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010845b:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010845e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108465:	e8 ef f7 ff ff       	call   80107c59 <ltr>
  if(p->pgdir == 0)
8010846a:	8b 45 08             	mov    0x8(%ebp),%eax
8010846d:	8b 40 04             	mov    0x4(%eax),%eax
80108470:	85 c0                	test   %eax,%eax
80108472:	75 0c                	jne    80108480 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108474:	c7 04 24 43 90 10 80 	movl   $0x80109043,(%esp)
8010847b:	e8 bd 80 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108480:	8b 45 08             	mov    0x8(%ebp),%eax
80108483:	8b 40 04             	mov    0x4(%eax),%eax
80108486:	89 04 24             	mov    %eax,(%esp)
80108489:	e8 01 f8 ff ff       	call   80107c8f <v2p>
8010848e:	89 04 24             	mov    %eax,(%esp)
80108491:	e8 ee f7 ff ff       	call   80107c84 <lcr3>
  popcli();
80108496:	e8 e8 d0 ff ff       	call   80105583 <popcli>
}
8010849b:	83 c4 14             	add    $0x14,%esp
8010849e:	5b                   	pop    %ebx
8010849f:	5d                   	pop    %ebp
801084a0:	c3                   	ret    

801084a1 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801084a1:	55                   	push   %ebp
801084a2:	89 e5                	mov    %esp,%ebp
801084a4:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801084a7:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801084ae:	76 0c                	jbe    801084bc <inituvm+0x1b>
    panic("inituvm: more than a page");
801084b0:	c7 04 24 57 90 10 80 	movl   $0x80109057,(%esp)
801084b7:	e8 81 80 ff ff       	call   8010053d <panic>
  mem = kalloc();
801084bc:	e8 ae a9 ff ff       	call   80102e6f <kalloc>
801084c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801084c4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084cb:	00 
801084cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084d3:	00 
801084d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d7:	89 04 24             	mov    %eax,(%esp)
801084da:	e8 63 d1 ff ff       	call   80105642 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801084df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e2:	89 04 24             	mov    %eax,(%esp)
801084e5:	e8 a5 f7 ff ff       	call   80107c8f <v2p>
801084ea:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801084f1:	00 
801084f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
801084f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084fd:	00 
801084fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108505:	00 
80108506:	8b 45 08             	mov    0x8(%ebp),%eax
80108509:	89 04 24             	mov    %eax,(%esp)
8010850c:	e8 a4 fc ff ff       	call   801081b5 <mappages>
  memmove(mem, init, sz);
80108511:	8b 45 10             	mov    0x10(%ebp),%eax
80108514:	89 44 24 08          	mov    %eax,0x8(%esp)
80108518:	8b 45 0c             	mov    0xc(%ebp),%eax
8010851b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010851f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108522:	89 04 24             	mov    %eax,(%esp)
80108525:	e8 eb d1 ff ff       	call   80105715 <memmove>
}
8010852a:	c9                   	leave  
8010852b:	c3                   	ret    

8010852c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010852c:	55                   	push   %ebp
8010852d:	89 e5                	mov    %esp,%ebp
8010852f:	53                   	push   %ebx
80108530:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108533:	8b 45 0c             	mov    0xc(%ebp),%eax
80108536:	25 ff 0f 00 00       	and    $0xfff,%eax
8010853b:	85 c0                	test   %eax,%eax
8010853d:	74 0c                	je     8010854b <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010853f:	c7 04 24 74 90 10 80 	movl   $0x80109074,(%esp)
80108546:	e8 f2 7f ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010854b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108552:	e9 ad 00 00 00       	jmp    80108604 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010855d:	01 d0                	add    %edx,%eax
8010855f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108566:	00 
80108567:	89 44 24 04          	mov    %eax,0x4(%esp)
8010856b:	8b 45 08             	mov    0x8(%ebp),%eax
8010856e:	89 04 24             	mov    %eax,(%esp)
80108571:	e8 a9 fb ff ff       	call   8010811f <walkpgdir>
80108576:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108579:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010857d:	75 0c                	jne    8010858b <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010857f:	c7 04 24 97 90 10 80 	movl   $0x80109097,(%esp)
80108586:	e8 b2 7f ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010858b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010858e:	8b 00                	mov    (%eax),%eax
80108590:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108595:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859b:	8b 55 18             	mov    0x18(%ebp),%edx
8010859e:	89 d1                	mov    %edx,%ecx
801085a0:	29 c1                	sub    %eax,%ecx
801085a2:	89 c8                	mov    %ecx,%eax
801085a4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801085a9:	77 11                	ja     801085bc <loaduvm+0x90>
      n = sz - i;
801085ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ae:	8b 55 18             	mov    0x18(%ebp),%edx
801085b1:	89 d1                	mov    %edx,%ecx
801085b3:	29 c1                	sub    %eax,%ecx
801085b5:	89 c8                	mov    %ecx,%eax
801085b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801085ba:	eb 07                	jmp    801085c3 <loaduvm+0x97>
    else
      n = PGSIZE;
801085bc:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801085c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c6:	8b 55 14             	mov    0x14(%ebp),%edx
801085c9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801085cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085cf:	89 04 24             	mov    %eax,(%esp)
801085d2:	e8 c5 f6 ff ff       	call   80107c9c <p2v>
801085d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085da:	89 54 24 0c          	mov    %edx,0xc(%esp)
801085de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801085e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801085e6:	8b 45 10             	mov    0x10(%ebp),%eax
801085e9:	89 04 24             	mov    %eax,(%esp)
801085ec:	e8 dd 9a ff ff       	call   801020ce <readi>
801085f1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801085f4:	74 07                	je     801085fd <loaduvm+0xd1>
      return -1;
801085f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085fb:	eb 18                	jmp    80108615 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801085fd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108607:	3b 45 18             	cmp    0x18(%ebp),%eax
8010860a:	0f 82 47 ff ff ff    	jb     80108557 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108610:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108615:	83 c4 24             	add    $0x24,%esp
80108618:	5b                   	pop    %ebx
80108619:	5d                   	pop    %ebp
8010861a:	c3                   	ret    

8010861b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010861b:	55                   	push   %ebp
8010861c:	89 e5                	mov    %esp,%ebp
8010861e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108621:	8b 45 10             	mov    0x10(%ebp),%eax
80108624:	85 c0                	test   %eax,%eax
80108626:	79 0a                	jns    80108632 <allocuvm+0x17>
    return 0;
80108628:	b8 00 00 00 00       	mov    $0x0,%eax
8010862d:	e9 c1 00 00 00       	jmp    801086f3 <allocuvm+0xd8>
  if(newsz < oldsz)
80108632:	8b 45 10             	mov    0x10(%ebp),%eax
80108635:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108638:	73 08                	jae    80108642 <allocuvm+0x27>
    return oldsz;
8010863a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010863d:	e9 b1 00 00 00       	jmp    801086f3 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108642:	8b 45 0c             	mov    0xc(%ebp),%eax
80108645:	05 ff 0f 00 00       	add    $0xfff,%eax
8010864a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010864f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108652:	e9 8d 00 00 00       	jmp    801086e4 <allocuvm+0xc9>
    mem = kalloc();
80108657:	e8 13 a8 ff ff       	call   80102e6f <kalloc>
8010865c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010865f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108663:	75 2c                	jne    80108691 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108665:	c7 04 24 b5 90 10 80 	movl   $0x801090b5,(%esp)
8010866c:	e8 30 7d ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108671:	8b 45 0c             	mov    0xc(%ebp),%eax
80108674:	89 44 24 08          	mov    %eax,0x8(%esp)
80108678:	8b 45 10             	mov    0x10(%ebp),%eax
8010867b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010867f:	8b 45 08             	mov    0x8(%ebp),%eax
80108682:	89 04 24             	mov    %eax,(%esp)
80108685:	e8 6b 00 00 00       	call   801086f5 <deallocuvm>
      return 0;
8010868a:	b8 00 00 00 00       	mov    $0x0,%eax
8010868f:	eb 62                	jmp    801086f3 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108691:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108698:	00 
80108699:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801086a0:	00 
801086a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a4:	89 04 24             	mov    %eax,(%esp)
801086a7:	e8 96 cf ff ff       	call   80105642 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801086ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086af:	89 04 24             	mov    %eax,(%esp)
801086b2:	e8 d8 f5 ff ff       	call   80107c8f <v2p>
801086b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086ba:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801086c1:	00 
801086c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
801086c6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086cd:	00 
801086ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801086d2:	8b 45 08             	mov    0x8(%ebp),%eax
801086d5:	89 04 24             	mov    %eax,(%esp)
801086d8:	e8 d8 fa ff ff       	call   801081b5 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801086dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e7:	3b 45 10             	cmp    0x10(%ebp),%eax
801086ea:	0f 82 67 ff ff ff    	jb     80108657 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801086f0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801086f3:	c9                   	leave  
801086f4:	c3                   	ret    

801086f5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801086f5:	55                   	push   %ebp
801086f6:	89 e5                	mov    %esp,%ebp
801086f8:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801086fb:	8b 45 10             	mov    0x10(%ebp),%eax
801086fe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108701:	72 08                	jb     8010870b <deallocuvm+0x16>
    return oldsz;
80108703:	8b 45 0c             	mov    0xc(%ebp),%eax
80108706:	e9 a4 00 00 00       	jmp    801087af <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010870b:	8b 45 10             	mov    0x10(%ebp),%eax
8010870e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108713:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108718:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010871b:	e9 80 00 00 00       	jmp    801087a0 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108723:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010872a:	00 
8010872b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010872f:	8b 45 08             	mov    0x8(%ebp),%eax
80108732:	89 04 24             	mov    %eax,(%esp)
80108735:	e8 e5 f9 ff ff       	call   8010811f <walkpgdir>
8010873a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010873d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108741:	75 09                	jne    8010874c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108743:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010874a:	eb 4d                	jmp    80108799 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
8010874c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010874f:	8b 00                	mov    (%eax),%eax
80108751:	83 e0 01             	and    $0x1,%eax
80108754:	84 c0                	test   %al,%al
80108756:	74 41                	je     80108799 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010875b:	8b 00                	mov    (%eax),%eax
8010875d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108762:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108765:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108769:	75 0c                	jne    80108777 <deallocuvm+0x82>
        panic("kfree");
8010876b:	c7 04 24 cd 90 10 80 	movl   $0x801090cd,(%esp)
80108772:	e8 c6 7d ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108777:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877a:	89 04 24             	mov    %eax,(%esp)
8010877d:	e8 1a f5 ff ff       	call   80107c9c <p2v>
80108782:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108785:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108788:	89 04 24             	mov    %eax,(%esp)
8010878b:	e8 46 a6 ff ff       	call   80102dd6 <kfree>
      *pte = 0;
80108790:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108793:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108799:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087a6:	0f 82 74 ff ff ff    	jb     80108720 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801087ac:	8b 45 10             	mov    0x10(%ebp),%eax
}
801087af:	c9                   	leave  
801087b0:	c3                   	ret    

801087b1 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801087b1:	55                   	push   %ebp
801087b2:	89 e5                	mov    %esp,%ebp
801087b4:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801087b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801087bb:	75 0c                	jne    801087c9 <freevm+0x18>
    panic("freevm: no pgdir");
801087bd:	c7 04 24 d3 90 10 80 	movl   $0x801090d3,(%esp)
801087c4:	e8 74 7d ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801087c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087d0:	00 
801087d1:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801087d8:	80 
801087d9:	8b 45 08             	mov    0x8(%ebp),%eax
801087dc:	89 04 24             	mov    %eax,(%esp)
801087df:	e8 11 ff ff ff       	call   801086f5 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801087e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087eb:	eb 3c                	jmp    80108829 <freevm+0x78>
    if(pgdir[i] & PTE_P){
801087ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f0:	c1 e0 02             	shl    $0x2,%eax
801087f3:	03 45 08             	add    0x8(%ebp),%eax
801087f6:	8b 00                	mov    (%eax),%eax
801087f8:	83 e0 01             	and    $0x1,%eax
801087fb:	84 c0                	test   %al,%al
801087fd:	74 26                	je     80108825 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801087ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108802:	c1 e0 02             	shl    $0x2,%eax
80108805:	03 45 08             	add    0x8(%ebp),%eax
80108808:	8b 00                	mov    (%eax),%eax
8010880a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010880f:	89 04 24             	mov    %eax,(%esp)
80108812:	e8 85 f4 ff ff       	call   80107c9c <p2v>
80108817:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010881a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010881d:	89 04 24             	mov    %eax,(%esp)
80108820:	e8 b1 a5 ff ff       	call   80102dd6 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108825:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108829:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108830:	76 bb                	jbe    801087ed <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108832:	8b 45 08             	mov    0x8(%ebp),%eax
80108835:	89 04 24             	mov    %eax,(%esp)
80108838:	e8 99 a5 ff ff       	call   80102dd6 <kfree>
}
8010883d:	c9                   	leave  
8010883e:	c3                   	ret    

8010883f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010883f:	55                   	push   %ebp
80108840:	89 e5                	mov    %esp,%ebp
80108842:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108845:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010884c:	00 
8010884d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108850:	89 44 24 04          	mov    %eax,0x4(%esp)
80108854:	8b 45 08             	mov    0x8(%ebp),%eax
80108857:	89 04 24             	mov    %eax,(%esp)
8010885a:	e8 c0 f8 ff ff       	call   8010811f <walkpgdir>
8010885f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108862:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108866:	75 0c                	jne    80108874 <clearpteu+0x35>
    panic("clearpteu");
80108868:	c7 04 24 e4 90 10 80 	movl   $0x801090e4,(%esp)
8010886f:	e8 c9 7c ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108877:	8b 00                	mov    (%eax),%eax
80108879:	89 c2                	mov    %eax,%edx
8010887b:	83 e2 fb             	and    $0xfffffffb,%edx
8010887e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108881:	89 10                	mov    %edx,(%eax)
}
80108883:	c9                   	leave  
80108884:	c3                   	ret    

80108885 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108885:	55                   	push   %ebp
80108886:	89 e5                	mov    %esp,%ebp
80108888:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
8010888b:	e8 b9 f9 ff ff       	call   80108249 <setupkvm>
80108890:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108893:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108897:	75 0a                	jne    801088a3 <copyuvm+0x1e>
    return 0;
80108899:	b8 00 00 00 00       	mov    $0x0,%eax
8010889e:	e9 f1 00 00 00       	jmp    80108994 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
801088a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088aa:	e9 c0 00 00 00       	jmp    8010896f <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801088af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801088b9:	00 
801088ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801088be:	8b 45 08             	mov    0x8(%ebp),%eax
801088c1:	89 04 24             	mov    %eax,(%esp)
801088c4:	e8 56 f8 ff ff       	call   8010811f <walkpgdir>
801088c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801088cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801088d0:	75 0c                	jne    801088de <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801088d2:	c7 04 24 ee 90 10 80 	movl   $0x801090ee,(%esp)
801088d9:	e8 5f 7c ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801088de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088e1:	8b 00                	mov    (%eax),%eax
801088e3:	83 e0 01             	and    $0x1,%eax
801088e6:	85 c0                	test   %eax,%eax
801088e8:	75 0c                	jne    801088f6 <copyuvm+0x71>
      panic("copyuvm: page not present");
801088ea:	c7 04 24 08 91 10 80 	movl   $0x80109108,(%esp)
801088f1:	e8 47 7c ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801088f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088f9:	8b 00                	mov    (%eax),%eax
801088fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108900:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
80108903:	e8 67 a5 ff ff       	call   80102e6f <kalloc>
80108908:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010890b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010890f:	74 6f                	je     80108980 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108911:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108914:	89 04 24             	mov    %eax,(%esp)
80108917:	e8 80 f3 ff ff       	call   80107c9c <p2v>
8010891c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108923:	00 
80108924:	89 44 24 04          	mov    %eax,0x4(%esp)
80108928:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010892b:	89 04 24             	mov    %eax,(%esp)
8010892e:	e8 e2 cd ff ff       	call   80105715 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108933:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108936:	89 04 24             	mov    %eax,(%esp)
80108939:	e8 51 f3 ff ff       	call   80107c8f <v2p>
8010893e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108941:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108948:	00 
80108949:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010894d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108954:	00 
80108955:	89 54 24 04          	mov    %edx,0x4(%esp)
80108959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010895c:	89 04 24             	mov    %eax,(%esp)
8010895f:	e8 51 f8 ff ff       	call   801081b5 <mappages>
80108964:	85 c0                	test   %eax,%eax
80108966:	78 1b                	js     80108983 <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108968:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010896f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108972:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108975:	0f 82 34 ff ff ff    	jb     801088af <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
8010897b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010897e:	eb 14                	jmp    80108994 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108980:	90                   	nop
80108981:	eb 01                	jmp    80108984 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
80108983:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108984:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108987:	89 04 24             	mov    %eax,(%esp)
8010898a:	e8 22 fe ff ff       	call   801087b1 <freevm>
  return 0;
8010898f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108994:	c9                   	leave  
80108995:	c3                   	ret    

80108996 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108996:	55                   	push   %ebp
80108997:	89 e5                	mov    %esp,%ebp
80108999:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010899c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801089a3:	00 
801089a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801089a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801089ab:	8b 45 08             	mov    0x8(%ebp),%eax
801089ae:	89 04 24             	mov    %eax,(%esp)
801089b1:	e8 69 f7 ff ff       	call   8010811f <walkpgdir>
801089b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801089b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bc:	8b 00                	mov    (%eax),%eax
801089be:	83 e0 01             	and    $0x1,%eax
801089c1:	85 c0                	test   %eax,%eax
801089c3:	75 07                	jne    801089cc <uva2ka+0x36>
    return 0;
801089c5:	b8 00 00 00 00       	mov    $0x0,%eax
801089ca:	eb 25                	jmp    801089f1 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801089cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cf:	8b 00                	mov    (%eax),%eax
801089d1:	83 e0 04             	and    $0x4,%eax
801089d4:	85 c0                	test   %eax,%eax
801089d6:	75 07                	jne    801089df <uva2ka+0x49>
    return 0;
801089d8:	b8 00 00 00 00       	mov    $0x0,%eax
801089dd:	eb 12                	jmp    801089f1 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801089df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e2:	8b 00                	mov    (%eax),%eax
801089e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089e9:	89 04 24             	mov    %eax,(%esp)
801089ec:	e8 ab f2 ff ff       	call   80107c9c <p2v>
}
801089f1:	c9                   	leave  
801089f2:	c3                   	ret    

801089f3 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801089f3:	55                   	push   %ebp
801089f4:	89 e5                	mov    %esp,%ebp
801089f6:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801089f9:	8b 45 10             	mov    0x10(%ebp),%eax
801089fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801089ff:	e9 8b 00 00 00       	jmp    80108a8f <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108a04:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108a0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a16:	8b 45 08             	mov    0x8(%ebp),%eax
80108a19:	89 04 24             	mov    %eax,(%esp)
80108a1c:	e8 75 ff ff ff       	call   80108996 <uva2ka>
80108a21:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108a24:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108a28:	75 07                	jne    80108a31 <copyout+0x3e>
      return -1;
80108a2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a2f:	eb 6d                	jmp    80108a9e <copyout+0xab>
    n = PGSIZE - (va - va0);
80108a31:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a34:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108a37:	89 d1                	mov    %edx,%ecx
80108a39:	29 c1                	sub    %eax,%ecx
80108a3b:	89 c8                	mov    %ecx,%eax
80108a3d:	05 00 10 00 00       	add    $0x1000,%eax
80108a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a48:	3b 45 14             	cmp    0x14(%ebp),%eax
80108a4b:	76 06                	jbe    80108a53 <copyout+0x60>
      n = len;
80108a4d:	8b 45 14             	mov    0x14(%ebp),%eax
80108a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a56:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a59:	89 d1                	mov    %edx,%ecx
80108a5b:	29 c1                	sub    %eax,%ecx
80108a5d:	89 c8                	mov    %ecx,%eax
80108a5f:	03 45 e8             	add    -0x18(%ebp),%eax
80108a62:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a65:	89 54 24 08          	mov    %edx,0x8(%esp)
80108a69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108a6c:	89 54 24 04          	mov    %edx,0x4(%esp)
80108a70:	89 04 24             	mov    %eax,(%esp)
80108a73:	e8 9d cc ff ff       	call   80105715 <memmove>
    len -= n;
80108a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a7b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a81:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a87:	05 00 10 00 00       	add    $0x1000,%eax
80108a8c:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108a8f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a93:	0f 85 6b ff ff ff    	jne    80108a04 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108a99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a9e:	c9                   	leave  
80108a9f:	c3                   	ret    
