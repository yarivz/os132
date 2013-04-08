
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
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
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
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 e3 36 10 80       	mov    $0x801036e3,%eax
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
8010003a:	c7 44 24 04 20 88 10 	movl   $0x80108820,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 04 51 00 00       	call   80105152 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 db 10 80 84 	movl   $0x8010db84,0x8010db90
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 db 10 80 84 	movl   $0x8010db84,0x8010db94
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 db 10 80       	mov    %eax,0x8010db94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
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
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 b1 50 00 00       	call   80105173 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 db 10 80       	mov    0x8010db94,%eax
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
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 cc 50 00 00       	call   801051d5 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 e6 4c 00 00       	call   80104e0a <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 db 10 80       	mov    0x8010db90,%eax
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
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 54 50 00 00       	call   801051d5 <release>
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
8010018f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 27 88 10 80 	movl   $0x80108827,(%esp)
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
801001d3:	e8 b8 28 00 00       	call   80102a90 <iderw>
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
801001ef:	c7 04 24 38 88 10 80 	movl   $0x80108838,(%esp)
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
80100210:	e8 7b 28 00 00       	call   80102a90 <iderw>
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
80100229:	c7 04 24 3f 88 10 80 	movl   $0x8010883f,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 32 4f 00 00       	call   80105173 <acquire>

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
8010025f:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 db 10 80       	mov    0x8010db94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 db 10 80       	mov    %eax,0x8010db94

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
8010029d:	e8 44 4c 00 00       	call   80104ee6 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 27 4f 00 00       	call   801051d5 <release>
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
8010033f:	0f b6 90 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%edx
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
80100390:	e8 7d 04 00 00       	call   80100812 <consputc>
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
801003a7:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bc:	e8 b2 4d 00 00       	call   80105173 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 46 88 10 80 	movl   $0x80108846,(%esp)
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
801003f2:	e8 1b 04 00 00       	call   80100812 <consputc>
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
801004af:	c7 45 ec 4f 88 10 80 	movl   $0x8010884f,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 49 03 00 00       	call   80100812 <consputc>
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
801004e3:	e8 2a 03 00 00       	call   80100812 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 1c 03 00 00       	call   80100812 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 11 03 00 00       	call   80100812 <consputc>
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
8010052f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100536:	e8 9a 4c 00 00       	call   801051d5 <release>
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
80100548:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 56 88 10 80 	movl   $0x80108856,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 65 88 10 80 	movl   $0x80108865,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 8d 4c 00 00       	call   80105224 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 67 88 10 80 	movl   $0x80108867,(%esp)
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
801005c1:	c7 05 a4 b5 10 80 01 	movl   $0x1,0x8010b5a4
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define RIGHTARROW 0xe5
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory
int k=0;					// difference from the end of the buffer
static void
cgaputc(int c)			// OS console
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

  if(c == '\n'){
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
80100656:	e9 02 01 00 00       	jmp    8010075d <cgaputc+0x190>
  }
  else if(c == BACKSPACE){
8010065b:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100662:	75 64                	jne    801006c8 <cgaputc+0xfb>
    if(pos > 0){
80100664:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100668:	0f 8e ef 00 00 00    	jle    8010075d <cgaputc+0x190>
      --pos;     
8010066e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
      int l;
      for(l=pos; l<pos+k; l++){
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100678:	eb 25                	jmp    8010069f <cgaputc+0xd2>
	crt[l] = crt[l+1];
8010067a:	a1 00 90 10 80       	mov    0x80109000,%eax
8010067f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100682:	01 d2                	add    %edx,%edx
80100684:	01 c2                	add    %eax,%edx
80100686:	a1 00 90 10 80       	mov    0x80109000,%eax
8010068b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010068e:	83 c1 01             	add    $0x1,%ecx
80100691:	01 c9                	add    %ecx,%ecx
80100693:	01 c8                	add    %ecx,%eax
80100695:	0f b7 00             	movzwl (%eax),%eax
80100698:	66 89 02             	mov    %ax,(%edx)
  }
  else if(c == BACKSPACE){
    if(pos > 0){
      --pos;     
      int l;
      for(l=pos; l<pos+k; l++){
8010069b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010069f:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
801006a4:	03 45 f4             	add    -0xc(%ebp),%eax
801006a7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801006aa:	7f ce                	jg     8010067a <cgaputc+0xad>
	crt[l] = crt[l+1];
      }
      crt[pos+k] = ' ' | 0x0700;
801006ac:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006b2:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
801006b7:	03 45 f4             	add    -0xc(%ebp),%eax
801006ba:	01 c0                	add    %eax,%eax
801006bc:	01 d0                	add    %edx,%eax
801006be:	66 c7 00 20 07       	movw   $0x720,(%eax)
801006c3:	e9 95 00 00 00       	jmp    8010075d <cgaputc+0x190>
    }
  } 				// of backspace option
  else if(c == LEFTARROW){
801006c8:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
801006cf:	75 19                	jne    801006ea <cgaputc+0x11d>
    if(pos > 0) --pos;
801006d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006d5:	7e 04                	jle    801006db <cgaputc+0x10e>
801006d7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    k++;
801006db:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
801006e0:	83 c0 01             	add    $0x1,%eax
801006e3:	a3 a0 b5 10 80       	mov    %eax,0x8010b5a0
801006e8:	eb 73                	jmp    8010075d <cgaputc+0x190>
  }
  else if(c == RIGHTARROW){
801006ea:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
801006f1:	75 13                	jne    80100706 <cgaputc+0x139>
    ++pos;
801006f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    k--;
801006f7:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
801006fc:	83 e8 01             	sub    $0x1,%eax
801006ff:	a3 a0 b5 10 80       	mov    %eax,0x8010b5a0
80100704:	eb 57                	jmp    8010075d <cgaputc+0x190>
  }
  else{
    int j;
    for(j=pos+k; j>pos; j--)		//print the char at the right place according to where the pointer is
80100706:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010070b:	03 45 f4             	add    -0xc(%ebp),%eax
8010070e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100711:	eb 25                	jmp    80100738 <cgaputc+0x16b>
      crt[j] = crt[j-1]; 
80100713:	a1 00 90 10 80       	mov    0x80109000,%eax
80100718:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010071b:	01 d2                	add    %edx,%edx
8010071d:	01 c2                	add    %eax,%edx
8010071f:	a1 00 90 10 80       	mov    0x80109000,%eax
80100724:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80100727:	83 e9 01             	sub    $0x1,%ecx
8010072a:	01 c9                	add    %ecx,%ecx
8010072c:	01 c8                	add    %ecx,%eax
8010072e:	0f b7 00             	movzwl (%eax),%eax
80100731:	66 89 02             	mov    %ax,(%edx)
    ++pos;
    k--;
  }
  else{
    int j;
    for(j=pos+k; j>pos; j--)		//print the char at the right place according to where the pointer is
80100734:	83 6d ec 01          	subl   $0x1,-0x14(%ebp)
80100738:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010073b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010073e:	7f d3                	jg     80100713 <cgaputc+0x146>
      crt[j] = crt[j-1]; 
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100740:	a1 00 90 10 80       	mov    0x80109000,%eax
80100745:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100748:	01 d2                	add    %edx,%edx
8010074a:	01 c2                	add    %eax,%edx
8010074c:	8b 45 08             	mov    0x8(%ebp),%eax
8010074f:	66 25 ff 00          	and    $0xff,%ax
80100753:	80 cc 07             	or     $0x7,%ah
80100756:	66 89 02             	mov    %ax,(%edx)
80100759:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }
  
  if((pos/80) >= 24){  // Scroll up.
8010075d:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100764:	7e 53                	jle    801007b9 <cgaputc+0x1ec>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100766:	a1 00 90 10 80       	mov    0x80109000,%eax
8010076b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100771:	a1 00 90 10 80       	mov    0x80109000,%eax
80100776:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
8010077d:	00 
8010077e:	89 54 24 04          	mov    %edx,0x4(%esp)
80100782:	89 04 24             	mov    %eax,(%esp)
80100785:	e8 0b 4d 00 00       	call   80105495 <memmove>
    pos -= 80;
8010078a:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8010078e:	b8 80 07 00 00       	mov    $0x780,%eax
80100793:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100796:	01 c0                	add    %eax,%eax
80100798:	8b 15 00 90 10 80    	mov    0x80109000,%edx
8010079e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007a1:	01 c9                	add    %ecx,%ecx
801007a3:	01 ca                	add    %ecx,%edx
801007a5:	89 44 24 08          	mov    %eax,0x8(%esp)
801007a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801007b0:	00 
801007b1:	89 14 24             	mov    %edx,(%esp)
801007b4:	e8 09 4c 00 00       	call   801053c2 <memset>
  }
  
  outb(CRTPORT, 14);
801007b9:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801007c0:	00 
801007c1:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801007c8:	e8 0d fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
801007cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007d0:	c1 f8 08             	sar    $0x8,%eax
801007d3:	0f b6 c0             	movzbl %al,%eax
801007d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801007da:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007e1:	e8 f4 fa ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
801007e6:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801007ed:	00 
801007ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801007f5:	e8 e0 fa ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
801007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fd:	0f b6 c0             	movzbl %al,%eax
80100800:	89 44 24 04          	mov    %eax,0x4(%esp)
80100804:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010080b:	e8 ca fa ff ff       	call   801002da <outb>
}
80100810:	c9                   	leave  
80100811:	c3                   	ret    

80100812 <consputc>:

void
consputc(int c)			// OUR console
{
80100812:	55                   	push   %ebp
80100813:	89 e5                	mov    %esp,%ebp
80100815:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100818:	a1 a4 b5 10 80       	mov    0x8010b5a4,%eax
8010081d:	85 c0                	test   %eax,%eax
8010081f:	74 07                	je     80100828 <consputc+0x16>
    cli();
80100821:	e8 d2 fa ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100826:	eb fe                	jmp    80100826 <consputc+0x14>
  }
  if(c == BACKSPACE){
80100828:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010082f:	75 26                	jne    80100857 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100831:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100838:	e8 48 66 00 00       	call   80106e85 <uartputc>
8010083d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100844:	e8 3c 66 00 00       	call   80106e85 <uartputc>
80100849:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100850:	e8 30 66 00 00       	call   80106e85 <uartputc>
80100855:	eb 0b                	jmp    80100862 <consputc+0x50>
  }
  else
    uartputc(c);
80100857:	8b 45 08             	mov    0x8(%ebp),%eax
8010085a:	89 04 24             	mov    %eax,(%esp)
8010085d:	e8 23 66 00 00       	call   80106e85 <uartputc>
  cgaputc(c);
80100862:	8b 45 08             	mov    0x8(%ebp),%eax
80100865:	89 04 24             	mov    %eax,(%esp)
80100868:	e8 60 fd ff ff       	call   801005cd <cgaputc>
}
8010086d:	c9                   	leave  
8010086e:	c3                   	ret    

8010086f <update_buf>:
  uint r;  // Read index
  uint w;  // Write index
  uint e;  // Edit index
} input;

void update_buf(char c){
8010086f:	55                   	push   %ebp
80100870:	89 e5                	mov    %esp,%ebp
80100872:	83 ec 14             	sub    $0x14,%esp
80100875:	8b 45 08             	mov    0x8(%ebp),%eax
80100878:	88 45 ec             	mov    %al,-0x14(%ebp)
   char temp;
   int i;
   int old_input_e = input.e;
8010087b:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100880:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for( i=0; i< INPUT_BUF; i++) {
80100883:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010088a:	e9 8c 00 00 00       	jmp    8010091b <update_buf+0xac>
      if (i == input.e) { 
8010088f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100892:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100897:	39 c2                	cmp    %eax,%edx
80100899:	75 38                	jne    801008d3 <update_buf+0x64>
	temp = input.buf[input.e++ % INPUT_BUF];
8010089b:	a1 60 de 10 80       	mov    0x8010de60,%eax
801008a0:	89 c2                	mov    %eax,%edx
801008a2:	83 e2 7f             	and    $0x7f,%edx
801008a5:	0f b6 92 d8 dd 10 80 	movzbl -0x7fef2228(%edx),%edx
801008ac:	88 55 f7             	mov    %dl,-0x9(%ebp)
801008af:	83 c0 01             	add    $0x1,%eax
801008b2:	a3 60 de 10 80       	mov    %eax,0x8010de60
	input.buf[input.e++ % INPUT_BUF] = c;
801008b7:	a1 60 de 10 80       	mov    0x8010de60,%eax
801008bc:	89 c1                	mov    %eax,%ecx
801008be:	83 e1 7f             	and    $0x7f,%ecx
801008c1:	0f b6 55 ec          	movzbl -0x14(%ebp),%edx
801008c5:	88 91 d8 dd 10 80    	mov    %dl,-0x7fef2228(%ecx)
801008cb:	83 c0 01             	add    $0x1,%eax
801008ce:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      if (i > input.e){
801008d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801008d6:	a1 60 de 10 80       	mov    0x8010de60,%eax
801008db:	39 c2                	cmp    %eax,%edx
801008dd:	76 38                	jbe    80100917 <update_buf+0xa8>
	temp = input.buf[input.e++ % INPUT_BUF];
801008df:	a1 60 de 10 80       	mov    0x8010de60,%eax
801008e4:	89 c2                	mov    %eax,%edx
801008e6:	83 e2 7f             	and    $0x7f,%edx
801008e9:	0f b6 92 d8 dd 10 80 	movzbl -0x7fef2228(%edx),%edx
801008f0:	88 55 f7             	mov    %dl,-0x9(%ebp)
801008f3:	83 c0 01             	add    $0x1,%eax
801008f6:	a3 60 de 10 80       	mov    %eax,0x8010de60
	input.buf[input.e++ % INPUT_BUF] = temp;	
801008fb:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100900:	89 c1                	mov    %eax,%ecx
80100902:	83 e1 7f             	and    $0x7f,%ecx
80100905:	0f b6 55 f7          	movzbl -0x9(%ebp),%edx
80100909:	88 91 d8 dd 10 80    	mov    %dl,-0x7fef2228(%ecx)
8010090f:	83 c0 01             	add    $0x1,%eax
80100912:	a3 60 de 10 80       	mov    %eax,0x8010de60

void update_buf(char c){
   char temp;
   int i;
   int old_input_e = input.e;
  for( i=0; i< INPUT_BUF; i++) {
80100917:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010091b:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
8010091f:	0f 8e 6a ff ff ff    	jle    8010088f <update_buf+0x20>
      if (i > input.e){
	temp = input.buf[input.e++ % INPUT_BUF];
	input.buf[input.e++ % INPUT_BUF] = temp;	
      }
  }
  input.e = old_input_e;
80100925:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100928:	a3 60 de 10 80       	mov    %eax,0x8010de60
}
8010092d:	c9                   	leave  
8010092e:	c3                   	ret    

8010092f <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010092f:	55                   	push   %ebp
80100930:	89 e5                	mov    %esp,%ebp
80100932:	53                   	push   %ebx
80100933:	83 ec 24             	sub    $0x24,%esp
  int c;
  acquire(&input.lock);
80100936:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
8010093d:	e8 31 48 00 00       	call   80105173 <acquire>
  while((c = getc()) >= 0){
80100942:	e9 94 02 00 00       	jmp    80100bdb <consoleintr+0x2ac>
    
    switch(c){
80100947:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010094a:	83 f8 15             	cmp    $0x15,%eax
8010094d:	74 59                	je     801009a8 <consoleintr+0x79>
8010094f:	83 f8 15             	cmp    $0x15,%eax
80100952:	7f 0f                	jg     80100963 <consoleintr+0x34>
80100954:	83 f8 08             	cmp    $0x8,%eax
80100957:	74 7e                	je     801009d7 <consoleintr+0xa8>
80100959:	83 f8 10             	cmp    $0x10,%eax
8010095c:	74 25                	je     80100983 <consoleintr+0x54>
8010095e:	e9 6a 01 00 00       	jmp    80100acd <consoleintr+0x19e>
80100963:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100968:	0f 84 f1 00 00 00    	je     80100a5f <consoleintr+0x130>
8010096e:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100973:	0f 84 17 01 00 00    	je     80100a90 <consoleintr+0x161>
80100979:	83 f8 7f             	cmp    $0x7f,%eax
8010097c:	74 59                	je     801009d7 <consoleintr+0xa8>
8010097e:	e9 4a 01 00 00       	jmp    80100acd <consoleintr+0x19e>
    case C('P'):  // Process listing.
      procdump();
80100983:	e8 04 46 00 00       	call   80104f8c <procdump>
      break;
80100988:	e9 4e 02 00 00       	jmp    80100bdb <consoleintr+0x2ac>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010098d:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100992:	83 e8 01             	sub    $0x1,%eax
80100995:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(BACKSPACE);
8010099a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801009a1:	e8 6c fe ff ff       	call   80100812 <consputc>
801009a6:	eb 01                	jmp    801009a9 <consoleintr+0x7a>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801009a8:	90                   	nop
801009a9:	8b 15 60 de 10 80    	mov    0x8010de60,%edx
801009af:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009b4:	39 c2                	cmp    %eax,%edx
801009b6:	0f 84 12 02 00 00    	je     80100bce <consoleintr+0x29f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801009bc:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009c1:	83 e8 01             	sub    $0x1,%eax
801009c4:	83 e0 7f             	and    $0x7f,%eax
801009c7:	0f b6 80 d8 dd 10 80 	movzbl -0x7fef2228(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801009ce:	3c 0a                	cmp    $0xa,%al
801009d0:	75 bb                	jne    8010098d <consoleintr+0x5e>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801009d2:	e9 f7 01 00 00       	jmp    80100bce <consoleintr+0x29f>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){	
801009d7:	8b 15 60 de 10 80    	mov    0x8010de60,%edx
801009dd:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009e2:	39 c2                	cmp    %eax,%edx
801009e4:	0f 84 e7 01 00 00    	je     80100bd1 <consoleintr+0x2a2>
        input.e--;	
801009ea:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009ef:	83 e8 01             	sub    $0x1,%eax
801009f2:	a3 60 de 10 80       	mov    %eax,0x8010de60
	int k;
	for(k=input.e;k<(input.size+input.w);k++){
801009f7:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801009ff:	eb 1d                	jmp    80100a1e <consoleintr+0xef>
	  input.buf[k]=input.buf[k+1];
80100a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a04:	83 c0 01             	add    $0x1,%eax
80100a07:	0f b6 80 d8 dd 10 80 	movzbl -0x7fef2228(%eax),%eax
80100a0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a11:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100a17:	88 42 08             	mov    %al,0x8(%edx)
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){	
        input.e--;	
	int k;
	for(k=input.e;k<(input.size+input.w);k++){
80100a1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a21:	8b 15 d4 dd 10 80    	mov    0x8010ddd4,%edx
80100a27:	89 d1                	mov    %edx,%ecx
80100a29:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a2f:	01 ca                	add    %ecx,%edx
80100a31:	39 d0                	cmp    %edx,%eax
80100a33:	72 cc                	jb     80100a01 <consoleintr+0xd2>
	  input.buf[k]=input.buf[k+1];
	}	
	input.buf[--input.size] = 0;	
80100a35:	a1 d4 dd 10 80       	mov    0x8010ddd4,%eax
80100a3a:	83 e8 01             	sub    $0x1,%eax
80100a3d:	a3 d4 dd 10 80       	mov    %eax,0x8010ddd4
80100a42:	a1 d4 dd 10 80       	mov    0x8010ddd4,%eax
80100a47:	c6 80 d8 dd 10 80 00 	movb   $0x0,-0x7fef2228(%eax)
        consputc(BACKSPACE);
80100a4e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a55:	e8 b8 fd ff ff       	call   80100812 <consputc>
      }
      break;
80100a5a:	e9 72 01 00 00       	jmp    80100bd1 <consoleintr+0x2a2>
    case (LEFTARROW):
      if (input.e - input.w > 0){
80100a5f:	8b 15 60 de 10 80    	mov    0x8010de60,%edx
80100a65:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a6a:	39 c2                	cmp    %eax,%edx
80100a6c:	0f 84 62 01 00 00    	je     80100bd4 <consoleintr+0x2a5>
	input.e--;
80100a72:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a77:	83 e8 01             	sub    $0x1,%eax
80100a7a:	a3 60 de 10 80       	mov    %eax,0x8010de60
	consputc(LEFTARROW);
80100a7f:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a86:	e8 87 fd ff ff       	call   80100812 <consputc>
      }
      break;
80100a8b:	e9 44 01 00 00       	jmp    80100bd4 <consoleintr+0x2a5>
    case (RIGHTARROW):
      if (input.size > input.e - input.w){
80100a90:	a1 d4 dd 10 80       	mov    0x8010ddd4,%eax
80100a95:	8b 0d 60 de 10 80    	mov    0x8010de60,%ecx
80100a9b:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100aa1:	89 cb                	mov    %ecx,%ebx
80100aa3:	29 d3                	sub    %edx,%ebx
80100aa5:	89 da                	mov    %ebx,%edx
80100aa7:	39 d0                	cmp    %edx,%eax
80100aa9:	0f 86 28 01 00 00    	jbe    80100bd7 <consoleintr+0x2a8>
	input.e++;
80100aaf:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100ab4:	83 c0 01             	add    $0x1,%eax
80100ab7:	a3 60 de 10 80       	mov    %eax,0x8010de60
	consputc(RIGHTARROW);
80100abc:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100ac3:	e8 4a fd ff ff       	call   80100812 <consputc>
      }
      break;
80100ac8:	e9 0a 01 00 00       	jmp    80100bd7 <consoleintr+0x2a8>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100acd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100ad1:	0f 84 03 01 00 00    	je     80100bda <consoleintr+0x2ab>
80100ad7:	8b 15 60 de 10 80    	mov    0x8010de60,%edx
80100add:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100ae2:	89 d1                	mov    %edx,%ecx
80100ae4:	29 c1                	sub    %eax,%ecx
80100ae6:	89 c8                	mov    %ecx,%eax
80100ae8:	83 f8 7f             	cmp    $0x7f,%eax
80100aeb:	0f 87 e9 00 00 00    	ja     80100bda <consoleintr+0x2ab>
        c = (c == '\r') ? '\n' : c;
80100af1:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100af5:	74 05                	je     80100afc <consoleintr+0x1cd>
80100af7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100afa:	eb 05                	jmp    80100b01 <consoleintr+0x1d2>
80100afc:	b8 0a 00 00 00       	mov    $0xa,%eax
80100b01:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (c=='\n')
80100b04:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100b08:	75 15                	jne    80100b1f <consoleintr+0x1f0>
	  input.e = input.size+input.w;
80100b0a:	a1 d4 dd 10 80       	mov    0x8010ddd4,%eax
80100b0f:	89 c2                	mov    %eax,%edx
80100b11:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b16:	01 d0                	add    %edx,%eax
80100b18:	a3 60 de 10 80       	mov    %eax,0x8010de60
80100b1d:	eb 3c                	jmp    80100b5b <consoleintr+0x22c>
	else{
	  int j;
	  for(j=(input.size+input.w);j>input.e;j--){
80100b1f:	a1 d4 dd 10 80       	mov    0x8010ddd4,%eax
80100b24:	89 c2                	mov    %eax,%edx
80100b26:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b2b:	01 d0                	add    %edx,%eax
80100b2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100b30:	eb 1d                	jmp    80100b4f <consoleintr+0x220>
	    input.buf[j]=input.buf[j-1];
80100b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b35:	83 e8 01             	sub    $0x1,%eax
80100b38:	0f b6 80 d8 dd 10 80 	movzbl -0x7fef2228(%eax),%eax
80100b3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b42:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100b48:	88 42 08             	mov    %al,0x8(%edx)
        c = (c == '\r') ? '\n' : c;
	if (c=='\n')
	  input.e = input.size+input.w;
	else{
	  int j;
	  for(j=(input.size+input.w);j>input.e;j--){
80100b4b:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80100b4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b52:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b57:	39 c2                	cmp    %eax,%edx
80100b59:	77 d7                	ja     80100b32 <consoleintr+0x203>
	    input.buf[j]=input.buf[j-1];
	  }
	}
	input.buf[input.e++ % INPUT_BUF] = c;	
80100b5b:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b60:	89 c1                	mov    %eax,%ecx
80100b62:	83 e1 7f             	and    $0x7f,%ecx
80100b65:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100b68:	88 91 d8 dd 10 80    	mov    %dl,-0x7fef2228(%ecx)
80100b6e:	83 c0 01             	add    $0x1,%eax
80100b71:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(c);
80100b76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b79:	89 04 24             	mov    %eax,(%esp)
80100b7c:	e8 91 fc ff ff       	call   80100812 <consputc>
	input.size++;
80100b81:	a1 d4 dd 10 80       	mov    0x8010ddd4,%eax
80100b86:	83 c0 01             	add    $0x1,%eax
80100b89:	a3 d4 dd 10 80       	mov    %eax,0x8010ddd4
	
        if(c == '\n' || c == C('D') || input.e == input.r + INPUT_BUF){
80100b8e:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100b92:	74 18                	je     80100bac <consoleintr+0x27d>
80100b94:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100b98:	74 12                	je     80100bac <consoleintr+0x27d>
80100b9a:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b9f:	8b 15 58 de 10 80    	mov    0x8010de58,%edx
80100ba5:	83 ea 80             	sub    $0xffffff80,%edx
80100ba8:	39 d0                	cmp    %edx,%eax
80100baa:	75 2e                	jne    80100bda <consoleintr+0x2ab>
	  input.w = input.e;
80100bac:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100bb1:	a3 5c de 10 80       	mov    %eax,0x8010de5c
	  input.size = 0;
80100bb6:	c7 05 d4 dd 10 80 00 	movl   $0x0,0x8010ddd4
80100bbd:	00 00 00 
          wakeup(&input.r);
80100bc0:	c7 04 24 58 de 10 80 	movl   $0x8010de58,(%esp)
80100bc7:	e8 1a 43 00 00       	call   80104ee6 <wakeup>
        }
      }
      break;
80100bcc:	eb 0c                	jmp    80100bda <consoleintr+0x2ab>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100bce:	90                   	nop
80100bcf:	eb 0a                	jmp    80100bdb <consoleintr+0x2ac>
	  input.buf[k]=input.buf[k+1];
	}	
	input.buf[--input.size] = 0;	
        consputc(BACKSPACE);
      }
      break;
80100bd1:	90                   	nop
80100bd2:	eb 07                	jmp    80100bdb <consoleintr+0x2ac>
    case (LEFTARROW):
      if (input.e - input.w > 0){
	input.e--;
	consputc(LEFTARROW);
      }
      break;
80100bd4:	90                   	nop
80100bd5:	eb 04                	jmp    80100bdb <consoleintr+0x2ac>
    case (RIGHTARROW):
      if (input.size > input.e - input.w){
	input.e++;
	consputc(RIGHTARROW);
      }
      break;
80100bd7:	90                   	nop
80100bd8:	eb 01                	jmp    80100bdb <consoleintr+0x2ac>
	  input.w = input.e;
	  input.size = 0;
          wakeup(&input.r);
        }
      }
      break;
80100bda:	90                   	nop
void
consoleintr(int (*getc)(void))
{
  int c;
  acquire(&input.lock);
  while((c = getc()) >= 0){
80100bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80100bde:	ff d0                	call   *%eax
80100be0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100be3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100be7:	0f 89 5a fd ff ff    	jns    80100947 <consoleintr+0x18>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100bed:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100bf4:	e8 dc 45 00 00       	call   801051d5 <release>
}
80100bf9:	83 c4 24             	add    $0x24,%esp
80100bfc:	5b                   	pop    %ebx
80100bfd:	5d                   	pop    %ebp
80100bfe:	c3                   	ret    

80100bff <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100bff:	55                   	push   %ebp
80100c00:	89 e5                	mov    %esp,%ebp
80100c02:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c05:	8b 45 08             	mov    0x8(%ebp),%eax
80100c08:	89 04 24             	mov    %eax,(%esp)
80100c0b:	e8 82 10 00 00       	call   80101c92 <iunlock>
  target = n;
80100c10:	8b 45 10             	mov    0x10(%ebp),%eax
80100c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100c16:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c1d:	e8 51 45 00 00       	call   80105173 <acquire>
  while(n > 0){
80100c22:	e9 a8 00 00 00       	jmp    80100ccf <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100c27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c2d:	8b 40 24             	mov    0x24(%eax),%eax
80100c30:	85 c0                	test   %eax,%eax
80100c32:	74 21                	je     80100c55 <consoleread+0x56>
        release(&input.lock);
80100c34:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c3b:	e8 95 45 00 00       	call   801051d5 <release>
        ilock(ip);
80100c40:	8b 45 08             	mov    0x8(%ebp),%eax
80100c43:	89 04 24             	mov    %eax,(%esp)
80100c46:	e8 f9 0e 00 00       	call   80101b44 <ilock>
        return -1;
80100c4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c50:	e9 a9 00 00 00       	jmp    80100cfe <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100c55:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100c5c:	80 
80100c5d:	c7 04 24 58 de 10 80 	movl   $0x8010de58,(%esp)
80100c64:	e8 a1 41 00 00       	call   80104e0a <sleep>
80100c69:	eb 01                	jmp    80100c6c <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100c6b:	90                   	nop
80100c6c:	8b 15 58 de 10 80    	mov    0x8010de58,%edx
80100c72:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c77:	39 c2                	cmp    %eax,%edx
80100c79:	74 ac                	je     80100c27 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100c7b:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100c80:	89 c2                	mov    %eax,%edx
80100c82:	83 e2 7f             	and    $0x7f,%edx
80100c85:	0f b6 92 d8 dd 10 80 	movzbl -0x7fef2228(%edx),%edx
80100c8c:	0f be d2             	movsbl %dl,%edx
80100c8f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100c92:	83 c0 01             	add    $0x1,%eax
80100c95:	a3 58 de 10 80       	mov    %eax,0x8010de58
    if(c == C('D')){  // EOF
80100c9a:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100c9e:	75 17                	jne    80100cb7 <consoleread+0xb8>
      if(n < target){
80100ca0:	8b 45 10             	mov    0x10(%ebp),%eax
80100ca3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100ca6:	73 2f                	jae    80100cd7 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100ca8:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100cad:	83 e8 01             	sub    $0x1,%eax
80100cb0:	a3 58 de 10 80       	mov    %eax,0x8010de58
      }
      break;
80100cb5:	eb 20                	jmp    80100cd7 <consoleread+0xd8>
    }
    *dst++ = c;
80100cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cba:	89 c2                	mov    %eax,%edx
80100cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cbf:	88 10                	mov    %dl,(%eax)
80100cc1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100cc5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100cc9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ccd:	74 0b                	je     80100cda <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100ccf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100cd3:	7f 96                	jg     80100c6b <consoleread+0x6c>
80100cd5:	eb 04                	jmp    80100cdb <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100cd7:	90                   	nop
80100cd8:	eb 01                	jmp    80100cdb <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100cda:	90                   	nop
  }
  release(&input.lock);
80100cdb:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100ce2:	e8 ee 44 00 00       	call   801051d5 <release>
  ilock(ip);
80100ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80100cea:	89 04 24             	mov    %eax,(%esp)
80100ced:	e8 52 0e 00 00       	call   80101b44 <ilock>

  return target - n;
80100cf2:	8b 45 10             	mov    0x10(%ebp),%eax
80100cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100cf8:	89 d1                	mov    %edx,%ecx
80100cfa:	29 c1                	sub    %eax,%ecx
80100cfc:	89 c8                	mov    %ecx,%eax
}
80100cfe:	c9                   	leave  
80100cff:	c3                   	ret    

80100d00 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d00:	55                   	push   %ebp
80100d01:	89 e5                	mov    %esp,%ebp
80100d03:	83 ec 28             	sub    $0x28,%esp
  int i;
  iunlock(ip);
80100d06:	8b 45 08             	mov    0x8(%ebp),%eax
80100d09:	89 04 24             	mov    %eax,(%esp)
80100d0c:	e8 81 0f 00 00       	call   80101c92 <iunlock>
  acquire(&cons.lock);
80100d11:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d18:	e8 56 44 00 00       	call   80105173 <acquire>
  for(i = 0; i < n; i++)
80100d1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100d24:	eb 1d                	jmp    80100d43 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d29:	03 45 0c             	add    0xc(%ebp),%eax
80100d2c:	0f b6 00             	movzbl (%eax),%eax
80100d2f:	0f be c0             	movsbl %al,%eax
80100d32:	25 ff 00 00 00       	and    $0xff,%eax
80100d37:	89 04 24             	mov    %eax,(%esp)
80100d3a:	e8 d3 fa ff ff       	call   80100812 <consputc>
consolewrite(struct inode *ip, char *buf, int n)
{
  int i;
  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100d3f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d46:	3b 45 10             	cmp    0x10(%ebp),%eax
80100d49:	7c db                	jl     80100d26 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100d4b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d52:	e8 7e 44 00 00       	call   801051d5 <release>
  ilock(ip);
80100d57:	8b 45 08             	mov    0x8(%ebp),%eax
80100d5a:	89 04 24             	mov    %eax,(%esp)
80100d5d:	e8 e2 0d 00 00       	call   80101b44 <ilock>

  return n;
80100d62:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100d65:	c9                   	leave  
80100d66:	c3                   	ret    

80100d67 <consoleinit>:

void
consoleinit(void)
{
80100d67:	55                   	push   %ebp
80100d68:	89 e5                	mov    %esp,%ebp
80100d6a:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100d6d:	c7 44 24 04 6b 88 10 	movl   $0x8010886b,0x4(%esp)
80100d74:	80 
80100d75:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d7c:	e8 d1 43 00 00       	call   80105152 <initlock>
  initlock(&input.lock, "input");
80100d81:	c7 44 24 04 73 88 10 	movl   $0x80108873,0x4(%esp)
80100d88:	80 
80100d89:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d90:	e8 bd 43 00 00       	call   80105152 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100d95:	c7 05 2c e8 10 80 00 	movl   $0x80100d00,0x8010e82c
80100d9c:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100d9f:	c7 05 28 e8 10 80 ff 	movl   $0x80100bff,0x8010e828
80100da6:	0b 10 80 
  cons.locking = 1;
80100da9:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100db0:	00 00 00 

  picenable(IRQ_KBD);
80100db3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100dba:	e8 de 2f 00 00       	call   80103d9d <picenable>
  ioapicenable(IRQ_KBD, 0);
80100dbf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100dc6:	00 
80100dc7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100dce:	e8 7f 1e 00 00       	call   80102c52 <ioapicenable>
}
80100dd3:	c9                   	leave  
80100dd4:	c3                   	ret    
80100dd5:	00 00                	add    %al,(%eax)
	...

80100dd8 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100dd8:	55                   	push   %ebp
80100dd9:	89 e5                	mov    %esp,%ebp
80100ddb:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100de1:	8b 45 08             	mov    0x8(%ebp),%eax
80100de4:	89 04 24             	mov    %eax,(%esp)
80100de7:	e8 fa 18 00 00       	call   801026e6 <namei>
80100dec:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100def:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100df3:	75 0a                	jne    80100dff <exec+0x27>
    return -1;
80100df5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dfa:	e9 da 03 00 00       	jmp    801011d9 <exec+0x401>
  ilock(ip);
80100dff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e02:	89 04 24             	mov    %eax,(%esp)
80100e05:	e8 3a 0d 00 00       	call   80101b44 <ilock>
  pgdir = 0;
80100e0a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e11:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100e18:	00 
80100e19:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100e20:	00 
80100e21:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100e27:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e2e:	89 04 24             	mov    %eax,(%esp)
80100e31:	e8 04 12 00 00       	call   8010203a <readi>
80100e36:	83 f8 33             	cmp    $0x33,%eax
80100e39:	0f 86 54 03 00 00    	jbe    80101193 <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100e3f:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100e45:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100e4a:	0f 85 46 03 00 00    	jne    80101196 <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100e50:	c7 04 24 db 2d 10 80 	movl   $0x80102ddb,(%esp)
80100e57:	e8 6d 71 00 00       	call   80107fc9 <setupkvm>
80100e5c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100e5f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100e63:	0f 84 30 03 00 00    	je     80101199 <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100e69:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e70:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100e77:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100e7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e80:	e9 c5 00 00 00       	jmp    80100f4a <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100e85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e88:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100e8f:	00 
80100e90:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e94:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e9e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ea1:	89 04 24             	mov    %eax,(%esp)
80100ea4:	e8 91 11 00 00       	call   8010203a <readi>
80100ea9:	83 f8 20             	cmp    $0x20,%eax
80100eac:	0f 85 ea 02 00 00    	jne    8010119c <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100eb2:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100eb8:	83 f8 01             	cmp    $0x1,%eax
80100ebb:	75 7f                	jne    80100f3c <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100ebd:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100ec3:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ec9:	39 c2                	cmp    %eax,%edx
80100ecb:	0f 82 ce 02 00 00    	jb     8010119f <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ed1:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100ed7:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100edd:	01 d0                	add    %edx,%eax
80100edf:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ee3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100eea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100eed:	89 04 24             	mov    %eax,(%esp)
80100ef0:	e8 a6 74 00 00       	call   8010839b <allocuvm>
80100ef5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ef8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100efc:	0f 84 a0 02 00 00    	je     801011a2 <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f02:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f08:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f0e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100f14:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100f18:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f1c:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f1f:	89 54 24 08          	mov    %edx,0x8(%esp)
80100f23:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f27:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f2a:	89 04 24             	mov    %eax,(%esp)
80100f2d:	e8 7a 73 00 00       	call   801082ac <loaduvm>
80100f32:	85 c0                	test   %eax,%eax
80100f34:	0f 88 6b 02 00 00    	js     801011a5 <exec+0x3cd>
80100f3a:	eb 01                	jmp    80100f3d <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100f3c:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f3d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100f41:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f44:	83 c0 20             	add    $0x20,%eax
80100f47:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f4a:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100f51:	0f b7 c0             	movzwl %ax,%eax
80100f54:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100f57:	0f 8f 28 ff ff ff    	jg     80100e85 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100f5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f60:	89 04 24             	mov    %eax,(%esp)
80100f63:	e8 60 0e 00 00       	call   80101dc8 <iunlockput>
  ip = 0;
80100f68:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100f6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f72:	05 ff 0f 00 00       	add    $0xfff,%eax
80100f77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100f7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f82:	05 00 20 00 00       	add    $0x2000,%eax
80100f87:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f95:	89 04 24             	mov    %eax,(%esp)
80100f98:	e8 fe 73 00 00       	call   8010839b <allocuvm>
80100f9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100fa0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100fa4:	0f 84 fe 01 00 00    	je     801011a8 <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fad:	2d 00 20 00 00       	sub    $0x2000,%eax
80100fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fb9:	89 04 24             	mov    %eax,(%esp)
80100fbc:	e8 fe 75 00 00       	call   801085bf <clearpteu>
  sp = sz;
80100fc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fc4:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100fc7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100fce:	e9 81 00 00 00       	jmp    80101054 <exec+0x27c>
    if(argc >= MAXARG)
80100fd3:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100fd7:	0f 87 ce 01 00 00    	ja     801011ab <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100fdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fe0:	c1 e0 02             	shl    $0x2,%eax
80100fe3:	03 45 0c             	add    0xc(%ebp),%eax
80100fe6:	8b 00                	mov    (%eax),%eax
80100fe8:	89 04 24             	mov    %eax,(%esp)
80100feb:	e8 50 46 00 00       	call   80105640 <strlen>
80100ff0:	f7 d0                	not    %eax
80100ff2:	03 45 dc             	add    -0x24(%ebp),%eax
80100ff5:	83 e0 fc             	and    $0xfffffffc,%eax
80100ff8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ffe:	c1 e0 02             	shl    $0x2,%eax
80101001:	03 45 0c             	add    0xc(%ebp),%eax
80101004:	8b 00                	mov    (%eax),%eax
80101006:	89 04 24             	mov    %eax,(%esp)
80101009:	e8 32 46 00 00       	call   80105640 <strlen>
8010100e:	83 c0 01             	add    $0x1,%eax
80101011:	89 c2                	mov    %eax,%edx
80101013:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101016:	c1 e0 02             	shl    $0x2,%eax
80101019:	03 45 0c             	add    0xc(%ebp),%eax
8010101c:	8b 00                	mov    (%eax),%eax
8010101e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80101022:	89 44 24 08          	mov    %eax,0x8(%esp)
80101026:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101029:	89 44 24 04          	mov    %eax,0x4(%esp)
8010102d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101030:	89 04 24             	mov    %eax,(%esp)
80101033:	e8 3b 77 00 00       	call   80108773 <copyout>
80101038:	85 c0                	test   %eax,%eax
8010103a:	0f 88 6e 01 00 00    	js     801011ae <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
80101040:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101043:	8d 50 03             	lea    0x3(%eax),%edx
80101046:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101049:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101050:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101057:	c1 e0 02             	shl    $0x2,%eax
8010105a:	03 45 0c             	add    0xc(%ebp),%eax
8010105d:	8b 00                	mov    (%eax),%eax
8010105f:	85 c0                	test   %eax,%eax
80101061:	0f 85 6c ff ff ff    	jne    80100fd3 <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80101067:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010106a:	83 c0 03             	add    $0x3,%eax
8010106d:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80101074:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80101078:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
8010107f:	ff ff ff 
  ustack[1] = argc;
80101082:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101085:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
8010108b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108e:	83 c0 01             	add    $0x1,%eax
80101091:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101098:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010109b:	29 d0                	sub    %edx,%eax
8010109d:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
801010a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010a6:	83 c0 04             	add    $0x4,%eax
801010a9:	c1 e0 02             	shl    $0x2,%eax
801010ac:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
801010af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b2:	83 c0 04             	add    $0x4,%eax
801010b5:	c1 e0 02             	shl    $0x2,%eax
801010b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
801010bc:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
801010c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801010c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801010cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010d0:	89 04 24             	mov    %eax,(%esp)
801010d3:	e8 9b 76 00 00       	call   80108773 <copyout>
801010d8:	85 c0                	test   %eax,%eax
801010da:	0f 88 d1 00 00 00    	js     801011b1 <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
801010e0:	8b 45 08             	mov    0x8(%ebp),%eax
801010e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801010e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801010ec:	eb 17                	jmp    80101105 <exec+0x32d>
    if(*s == '/')
801010ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010f1:	0f b6 00             	movzbl (%eax),%eax
801010f4:	3c 2f                	cmp    $0x2f,%al
801010f6:	75 09                	jne    80101101 <exec+0x329>
      last = s+1;
801010f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010fb:	83 c0 01             	add    $0x1,%eax
801010fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101101:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101108:	0f b6 00             	movzbl (%eax),%eax
8010110b:	84 c0                	test   %al,%al
8010110d:	75 df                	jne    801010ee <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
8010110f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101115:	8d 50 6c             	lea    0x6c(%eax),%edx
80101118:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010111f:	00 
80101120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101123:	89 44 24 04          	mov    %eax,0x4(%esp)
80101127:	89 14 24             	mov    %edx,(%esp)
8010112a:	e8 c3 44 00 00       	call   801055f2 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
8010112f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101135:	8b 40 04             	mov    0x4(%eax),%eax
80101138:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
8010113b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101141:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101144:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80101147:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010114d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101150:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80101152:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101158:	8b 40 18             	mov    0x18(%eax),%eax
8010115b:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80101161:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80101164:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010116a:	8b 40 18             	mov    0x18(%eax),%eax
8010116d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101170:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80101173:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101179:	89 04 24             	mov    %eax,(%esp)
8010117c:	e8 39 6f 00 00       	call   801080ba <switchuvm>
  freevm(oldpgdir);
80101181:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101184:	89 04 24             	mov    %eax,(%esp)
80101187:	e8 a5 73 00 00       	call   80108531 <freevm>
  return 0;
8010118c:	b8 00 00 00 00       	mov    $0x0,%eax
80101191:	eb 46                	jmp    801011d9 <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80101193:	90                   	nop
80101194:	eb 1c                	jmp    801011b2 <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101196:	90                   	nop
80101197:	eb 19                	jmp    801011b2 <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101199:	90                   	nop
8010119a:	eb 16                	jmp    801011b2 <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
8010119c:	90                   	nop
8010119d:	eb 13                	jmp    801011b2 <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010119f:	90                   	nop
801011a0:	eb 10                	jmp    801011b2 <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
801011a2:	90                   	nop
801011a3:	eb 0d                	jmp    801011b2 <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
801011a5:	90                   	nop
801011a6:	eb 0a                	jmp    801011b2 <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
801011a8:	90                   	nop
801011a9:	eb 07                	jmp    801011b2 <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
801011ab:	90                   	nop
801011ac:	eb 04                	jmp    801011b2 <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
801011ae:	90                   	nop
801011af:	eb 01                	jmp    801011b2 <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
801011b1:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
801011b2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801011b6:	74 0b                	je     801011c3 <exec+0x3eb>
    freevm(pgdir);
801011b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801011bb:	89 04 24             	mov    %eax,(%esp)
801011be:	e8 6e 73 00 00       	call   80108531 <freevm>
  if(ip)
801011c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801011c7:	74 0b                	je     801011d4 <exec+0x3fc>
    iunlockput(ip);
801011c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801011cc:	89 04 24             	mov    %eax,(%esp)
801011cf:	e8 f4 0b 00 00       	call   80101dc8 <iunlockput>
  return -1;
801011d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d9:	c9                   	leave  
801011da:	c3                   	ret    
	...

801011dc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801011dc:	55                   	push   %ebp
801011dd:	89 e5                	mov    %esp,%ebp
801011df:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801011e2:	c7 44 24 04 79 88 10 	movl   $0x80108879,0x4(%esp)
801011e9:	80 
801011ea:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801011f1:	e8 5c 3f 00 00       	call   80105152 <initlock>
}
801011f6:	c9                   	leave  
801011f7:	c3                   	ret    

801011f8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801011f8:	55                   	push   %ebp
801011f9:	89 e5                	mov    %esp,%ebp
801011fb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
801011fe:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101205:	e8 69 3f 00 00       	call   80105173 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010120a:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80101211:	eb 29                	jmp    8010123c <filealloc+0x44>
    if(f->ref == 0){
80101213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101216:	8b 40 04             	mov    0x4(%eax),%eax
80101219:	85 c0                	test   %eax,%eax
8010121b:	75 1b                	jne    80101238 <filealloc+0x40>
      f->ref = 1;
8010121d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101220:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101227:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010122e:	e8 a2 3f 00 00       	call   801051d5 <release>
      return f;
80101233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101236:	eb 1e                	jmp    80101256 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101238:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010123c:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
80101243:	72 ce                	jb     80101213 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101245:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010124c:	e8 84 3f 00 00       	call   801051d5 <release>
  return 0;
80101251:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101256:	c9                   	leave  
80101257:	c3                   	ret    

80101258 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101258:	55                   	push   %ebp
80101259:	89 e5                	mov    %esp,%ebp
8010125b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
8010125e:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101265:	e8 09 3f 00 00       	call   80105173 <acquire>
  if(f->ref < 1)
8010126a:	8b 45 08             	mov    0x8(%ebp),%eax
8010126d:	8b 40 04             	mov    0x4(%eax),%eax
80101270:	85 c0                	test   %eax,%eax
80101272:	7f 0c                	jg     80101280 <filedup+0x28>
    panic("filedup");
80101274:	c7 04 24 80 88 10 80 	movl   $0x80108880,(%esp)
8010127b:	e8 bd f2 ff ff       	call   8010053d <panic>
  f->ref++;
80101280:	8b 45 08             	mov    0x8(%ebp),%eax
80101283:	8b 40 04             	mov    0x4(%eax),%eax
80101286:	8d 50 01             	lea    0x1(%eax),%edx
80101289:	8b 45 08             	mov    0x8(%ebp),%eax
8010128c:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010128f:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101296:	e8 3a 3f 00 00       	call   801051d5 <release>
  return f;
8010129b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010129e:	c9                   	leave  
8010129f:	c3                   	ret    

801012a0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801012a0:	55                   	push   %ebp
801012a1:	89 e5                	mov    %esp,%ebp
801012a3:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801012a6:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012ad:	e8 c1 3e 00 00       	call   80105173 <acquire>
  if(f->ref < 1)
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	8b 40 04             	mov    0x4(%eax),%eax
801012b8:	85 c0                	test   %eax,%eax
801012ba:	7f 0c                	jg     801012c8 <fileclose+0x28>
    panic("fileclose");
801012bc:	c7 04 24 88 88 10 80 	movl   $0x80108888,(%esp)
801012c3:	e8 75 f2 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
801012c8:	8b 45 08             	mov    0x8(%ebp),%eax
801012cb:	8b 40 04             	mov    0x4(%eax),%eax
801012ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801012d1:	8b 45 08             	mov    0x8(%ebp),%eax
801012d4:	89 50 04             	mov    %edx,0x4(%eax)
801012d7:	8b 45 08             	mov    0x8(%ebp),%eax
801012da:	8b 40 04             	mov    0x4(%eax),%eax
801012dd:	85 c0                	test   %eax,%eax
801012df:	7e 11                	jle    801012f2 <fileclose+0x52>
    release(&ftable.lock);
801012e1:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012e8:	e8 e8 3e 00 00       	call   801051d5 <release>
    return;
801012ed:	e9 82 00 00 00       	jmp    80101374 <fileclose+0xd4>
  }
  ff = *f;
801012f2:	8b 45 08             	mov    0x8(%ebp),%eax
801012f5:	8b 10                	mov    (%eax),%edx
801012f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
801012fa:	8b 50 04             	mov    0x4(%eax),%edx
801012fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101300:	8b 50 08             	mov    0x8(%eax),%edx
80101303:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101306:	8b 50 0c             	mov    0xc(%eax),%edx
80101309:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010130c:	8b 50 10             	mov    0x10(%eax),%edx
8010130f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101312:	8b 40 14             	mov    0x14(%eax),%eax
80101315:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010132b:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101332:	e8 9e 3e 00 00       	call   801051d5 <release>
  
  if(ff.type == FD_PIPE)
80101337:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010133a:	83 f8 01             	cmp    $0x1,%eax
8010133d:	75 18                	jne    80101357 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010133f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101343:	0f be d0             	movsbl %al,%edx
80101346:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101349:	89 54 24 04          	mov    %edx,0x4(%esp)
8010134d:	89 04 24             	mov    %eax,(%esp)
80101350:	e8 02 2d 00 00       	call   80104057 <pipeclose>
80101355:	eb 1d                	jmp    80101374 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101357:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010135a:	83 f8 02             	cmp    $0x2,%eax
8010135d:	75 15                	jne    80101374 <fileclose+0xd4>
    begin_trans();
8010135f:	e8 95 21 00 00       	call   801034f9 <begin_trans>
    iput(ff.ip);
80101364:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101367:	89 04 24             	mov    %eax,(%esp)
8010136a:	e8 88 09 00 00       	call   80101cf7 <iput>
    commit_trans();
8010136f:	e8 ce 21 00 00       	call   80103542 <commit_trans>
  }
}
80101374:	c9                   	leave  
80101375:	c3                   	ret    

80101376 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101376:	55                   	push   %ebp
80101377:	89 e5                	mov    %esp,%ebp
80101379:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010137c:	8b 45 08             	mov    0x8(%ebp),%eax
8010137f:	8b 00                	mov    (%eax),%eax
80101381:	83 f8 02             	cmp    $0x2,%eax
80101384:	75 38                	jne    801013be <filestat+0x48>
    ilock(f->ip);
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	8b 40 10             	mov    0x10(%eax),%eax
8010138c:	89 04 24             	mov    %eax,(%esp)
8010138f:	e8 b0 07 00 00       	call   80101b44 <ilock>
    stati(f->ip, st);
80101394:	8b 45 08             	mov    0x8(%ebp),%eax
80101397:	8b 40 10             	mov    0x10(%eax),%eax
8010139a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010139d:	89 54 24 04          	mov    %edx,0x4(%esp)
801013a1:	89 04 24             	mov    %eax,(%esp)
801013a4:	e8 4c 0c 00 00       	call   80101ff5 <stati>
    iunlock(f->ip);
801013a9:	8b 45 08             	mov    0x8(%ebp),%eax
801013ac:	8b 40 10             	mov    0x10(%eax),%eax
801013af:	89 04 24             	mov    %eax,(%esp)
801013b2:	e8 db 08 00 00       	call   80101c92 <iunlock>
    return 0;
801013b7:	b8 00 00 00 00       	mov    $0x0,%eax
801013bc:	eb 05                	jmp    801013c3 <filestat+0x4d>
  }
  return -1;
801013be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801013c3:	c9                   	leave  
801013c4:	c3                   	ret    

801013c5 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801013c5:	55                   	push   %ebp
801013c6:	89 e5                	mov    %esp,%ebp
801013c8:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801013cb:	8b 45 08             	mov    0x8(%ebp),%eax
801013ce:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801013d2:	84 c0                	test   %al,%al
801013d4:	75 0a                	jne    801013e0 <fileread+0x1b>
    return -1;
801013d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013db:	e9 9f 00 00 00       	jmp    8010147f <fileread+0xba>
  if(f->type == FD_PIPE)
801013e0:	8b 45 08             	mov    0x8(%ebp),%eax
801013e3:	8b 00                	mov    (%eax),%eax
801013e5:	83 f8 01             	cmp    $0x1,%eax
801013e8:	75 1e                	jne    80101408 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801013ea:	8b 45 08             	mov    0x8(%ebp),%eax
801013ed:	8b 40 0c             	mov    0xc(%eax),%eax
801013f0:	8b 55 10             	mov    0x10(%ebp),%edx
801013f3:	89 54 24 08          	mov    %edx,0x8(%esp)
801013f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801013fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801013fe:	89 04 24             	mov    %eax,(%esp)
80101401:	e8 d3 2d 00 00       	call   801041d9 <piperead>
80101406:	eb 77                	jmp    8010147f <fileread+0xba>
  if(f->type == FD_INODE){
80101408:	8b 45 08             	mov    0x8(%ebp),%eax
8010140b:	8b 00                	mov    (%eax),%eax
8010140d:	83 f8 02             	cmp    $0x2,%eax
80101410:	75 61                	jne    80101473 <fileread+0xae>
    ilock(f->ip);
80101412:	8b 45 08             	mov    0x8(%ebp),%eax
80101415:	8b 40 10             	mov    0x10(%eax),%eax
80101418:	89 04 24             	mov    %eax,(%esp)
8010141b:	e8 24 07 00 00       	call   80101b44 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101420:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	8b 50 14             	mov    0x14(%eax),%edx
80101429:	8b 45 08             	mov    0x8(%ebp),%eax
8010142c:	8b 40 10             	mov    0x10(%eax),%eax
8010142f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101433:	89 54 24 08          	mov    %edx,0x8(%esp)
80101437:	8b 55 0c             	mov    0xc(%ebp),%edx
8010143a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010143e:	89 04 24             	mov    %eax,(%esp)
80101441:	e8 f4 0b 00 00       	call   8010203a <readi>
80101446:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101449:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010144d:	7e 11                	jle    80101460 <fileread+0x9b>
      f->off += r;
8010144f:	8b 45 08             	mov    0x8(%ebp),%eax
80101452:	8b 50 14             	mov    0x14(%eax),%edx
80101455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101458:	01 c2                	add    %eax,%edx
8010145a:	8b 45 08             	mov    0x8(%ebp),%eax
8010145d:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101460:	8b 45 08             	mov    0x8(%ebp),%eax
80101463:	8b 40 10             	mov    0x10(%eax),%eax
80101466:	89 04 24             	mov    %eax,(%esp)
80101469:	e8 24 08 00 00       	call   80101c92 <iunlock>
    return r;
8010146e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101471:	eb 0c                	jmp    8010147f <fileread+0xba>
  }
  panic("fileread");
80101473:	c7 04 24 92 88 10 80 	movl   $0x80108892,(%esp)
8010147a:	e8 be f0 ff ff       	call   8010053d <panic>
}
8010147f:	c9                   	leave  
80101480:	c3                   	ret    

80101481 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101481:	55                   	push   %ebp
80101482:	89 e5                	mov    %esp,%ebp
80101484:	53                   	push   %ebx
80101485:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101488:	8b 45 08             	mov    0x8(%ebp),%eax
8010148b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010148f:	84 c0                	test   %al,%al
80101491:	75 0a                	jne    8010149d <filewrite+0x1c>
    return -1;
80101493:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101498:	e9 23 01 00 00       	jmp    801015c0 <filewrite+0x13f>
  if(f->type == FD_PIPE)
8010149d:	8b 45 08             	mov    0x8(%ebp),%eax
801014a0:	8b 00                	mov    (%eax),%eax
801014a2:	83 f8 01             	cmp    $0x1,%eax
801014a5:	75 21                	jne    801014c8 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801014a7:	8b 45 08             	mov    0x8(%ebp),%eax
801014aa:	8b 40 0c             	mov    0xc(%eax),%eax
801014ad:	8b 55 10             	mov    0x10(%ebp),%edx
801014b0:	89 54 24 08          	mov    %edx,0x8(%esp)
801014b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801014b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801014bb:	89 04 24             	mov    %eax,(%esp)
801014be:	e8 26 2c 00 00       	call   801040e9 <pipewrite>
801014c3:	e9 f8 00 00 00       	jmp    801015c0 <filewrite+0x13f>
  if(f->type == FD_INODE){
801014c8:	8b 45 08             	mov    0x8(%ebp),%eax
801014cb:	8b 00                	mov    (%eax),%eax
801014cd:	83 f8 02             	cmp    $0x2,%eax
801014d0:	0f 85 de 00 00 00    	jne    801015b4 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801014d6:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801014dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801014e4:	e9 a8 00 00 00       	jmp    80101591 <filewrite+0x110>
      int n1 = n - i;
801014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ec:	8b 55 10             	mov    0x10(%ebp),%edx
801014ef:	89 d1                	mov    %edx,%ecx
801014f1:	29 c1                	sub    %eax,%ecx
801014f3:	89 c8                	mov    %ecx,%eax
801014f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801014fe:	7e 06                	jle    80101506 <filewrite+0x85>
        n1 = max;
80101500:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101503:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101506:	e8 ee 1f 00 00       	call   801034f9 <begin_trans>
      ilock(f->ip);
8010150b:	8b 45 08             	mov    0x8(%ebp),%eax
8010150e:	8b 40 10             	mov    0x10(%eax),%eax
80101511:	89 04 24             	mov    %eax,(%esp)
80101514:	e8 2b 06 00 00       	call   80101b44 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101519:	8b 5d f0             	mov    -0x10(%ebp),%ebx
8010151c:	8b 45 08             	mov    0x8(%ebp),%eax
8010151f:	8b 48 14             	mov    0x14(%eax),%ecx
80101522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101525:	89 c2                	mov    %eax,%edx
80101527:	03 55 0c             	add    0xc(%ebp),%edx
8010152a:	8b 45 08             	mov    0x8(%ebp),%eax
8010152d:	8b 40 10             	mov    0x10(%eax),%eax
80101530:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101534:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101538:	89 54 24 04          	mov    %edx,0x4(%esp)
8010153c:	89 04 24             	mov    %eax,(%esp)
8010153f:	e8 61 0c 00 00       	call   801021a5 <writei>
80101544:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101547:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010154b:	7e 11                	jle    8010155e <filewrite+0xdd>
        f->off += r;
8010154d:	8b 45 08             	mov    0x8(%ebp),%eax
80101550:	8b 50 14             	mov    0x14(%eax),%edx
80101553:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101556:	01 c2                	add    %eax,%edx
80101558:	8b 45 08             	mov    0x8(%ebp),%eax
8010155b:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010155e:	8b 45 08             	mov    0x8(%ebp),%eax
80101561:	8b 40 10             	mov    0x10(%eax),%eax
80101564:	89 04 24             	mov    %eax,(%esp)
80101567:	e8 26 07 00 00       	call   80101c92 <iunlock>
      commit_trans();
8010156c:	e8 d1 1f 00 00       	call   80103542 <commit_trans>

      if(r < 0)
80101571:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101575:	78 28                	js     8010159f <filewrite+0x11e>
        break;
      if(r != n1)
80101577:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010157a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010157d:	74 0c                	je     8010158b <filewrite+0x10a>
        panic("short filewrite");
8010157f:	c7 04 24 9b 88 10 80 	movl   $0x8010889b,(%esp)
80101586:	e8 b2 ef ff ff       	call   8010053d <panic>
      i += r;
8010158b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010158e:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101594:	3b 45 10             	cmp    0x10(%ebp),%eax
80101597:	0f 8c 4c ff ff ff    	jl     801014e9 <filewrite+0x68>
8010159d:	eb 01                	jmp    801015a0 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
8010159f:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801015a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a3:	3b 45 10             	cmp    0x10(%ebp),%eax
801015a6:	75 05                	jne    801015ad <filewrite+0x12c>
801015a8:	8b 45 10             	mov    0x10(%ebp),%eax
801015ab:	eb 05                	jmp    801015b2 <filewrite+0x131>
801015ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801015b2:	eb 0c                	jmp    801015c0 <filewrite+0x13f>
  }
  panic("filewrite");
801015b4:	c7 04 24 ab 88 10 80 	movl   $0x801088ab,(%esp)
801015bb:	e8 7d ef ff ff       	call   8010053d <panic>
}
801015c0:	83 c4 24             	add    $0x24,%esp
801015c3:	5b                   	pop    %ebx
801015c4:	5d                   	pop    %ebp
801015c5:	c3                   	ret    
	...

801015c8 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801015c8:	55                   	push   %ebp
801015c9:	89 e5                	mov    %esp,%ebp
801015cb:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801015ce:	8b 45 08             	mov    0x8(%ebp),%eax
801015d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801015d8:	00 
801015d9:	89 04 24             	mov    %eax,(%esp)
801015dc:	e8 c5 eb ff ff       	call   801001a6 <bread>
801015e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801015e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e7:	83 c0 18             	add    $0x18,%eax
801015ea:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801015f1:	00 
801015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801015f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015f9:	89 04 24             	mov    %eax,(%esp)
801015fc:	e8 94 3e 00 00       	call   80105495 <memmove>
  brelse(bp);
80101601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101604:	89 04 24             	mov    %eax,(%esp)
80101607:	e8 0b ec ff ff       	call   80100217 <brelse>
}
8010160c:	c9                   	leave  
8010160d:	c3                   	ret    

8010160e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010160e:	55                   	push   %ebp
8010160f:	89 e5                	mov    %esp,%ebp
80101611:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101614:	8b 55 0c             	mov    0xc(%ebp),%edx
80101617:	8b 45 08             	mov    0x8(%ebp),%eax
8010161a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010161e:	89 04 24             	mov    %eax,(%esp)
80101621:	e8 80 eb ff ff       	call   801001a6 <bread>
80101626:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162c:	83 c0 18             	add    $0x18,%eax
8010162f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101636:	00 
80101637:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010163e:	00 
8010163f:	89 04 24             	mov    %eax,(%esp)
80101642:	e8 7b 3d 00 00       	call   801053c2 <memset>
  log_write(bp);
80101647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010164a:	89 04 24             	mov    %eax,(%esp)
8010164d:	e8 48 1f 00 00       	call   8010359a <log_write>
  brelse(bp);
80101652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101655:	89 04 24             	mov    %eax,(%esp)
80101658:	e8 ba eb ff ff       	call   80100217 <brelse>
}
8010165d:	c9                   	leave  
8010165e:	c3                   	ret    

8010165f <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010165f:	55                   	push   %ebp
80101660:	89 e5                	mov    %esp,%ebp
80101662:	53                   	push   %ebx
80101663:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101666:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010166d:	8b 45 08             	mov    0x8(%ebp),%eax
80101670:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101673:	89 54 24 04          	mov    %edx,0x4(%esp)
80101677:	89 04 24             	mov    %eax,(%esp)
8010167a:	e8 49 ff ff ff       	call   801015c8 <readsb>
  for(b = 0; b < sb.size; b += BPB){
8010167f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101686:	e9 11 01 00 00       	jmp    8010179c <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010168b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010168e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101694:	85 c0                	test   %eax,%eax
80101696:	0f 48 c2             	cmovs  %edx,%eax
80101699:	c1 f8 0c             	sar    $0xc,%eax
8010169c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010169f:	c1 ea 03             	shr    $0x3,%edx
801016a2:	01 d0                	add    %edx,%eax
801016a4:	83 c0 03             	add    $0x3,%eax
801016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801016ab:	8b 45 08             	mov    0x8(%ebp),%eax
801016ae:	89 04 24             	mov    %eax,(%esp)
801016b1:	e8 f0 ea ff ff       	call   801001a6 <bread>
801016b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016b9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801016c0:	e9 a7 00 00 00       	jmp    8010176c <balloc+0x10d>
      m = 1 << (bi % 8);
801016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c8:	89 c2                	mov    %eax,%edx
801016ca:	c1 fa 1f             	sar    $0x1f,%edx
801016cd:	c1 ea 1d             	shr    $0x1d,%edx
801016d0:	01 d0                	add    %edx,%eax
801016d2:	83 e0 07             	and    $0x7,%eax
801016d5:	29 d0                	sub    %edx,%eax
801016d7:	ba 01 00 00 00       	mov    $0x1,%edx
801016dc:	89 d3                	mov    %edx,%ebx
801016de:	89 c1                	mov    %eax,%ecx
801016e0:	d3 e3                	shl    %cl,%ebx
801016e2:	89 d8                	mov    %ebx,%eax
801016e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ea:	8d 50 07             	lea    0x7(%eax),%edx
801016ed:	85 c0                	test   %eax,%eax
801016ef:	0f 48 c2             	cmovs  %edx,%eax
801016f2:	c1 f8 03             	sar    $0x3,%eax
801016f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016f8:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801016fd:	0f b6 c0             	movzbl %al,%eax
80101700:	23 45 e8             	and    -0x18(%ebp),%eax
80101703:	85 c0                	test   %eax,%eax
80101705:	75 61                	jne    80101768 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101707:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170a:	8d 50 07             	lea    0x7(%eax),%edx
8010170d:	85 c0                	test   %eax,%eax
8010170f:	0f 48 c2             	cmovs  %edx,%eax
80101712:	c1 f8 03             	sar    $0x3,%eax
80101715:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101718:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010171d:	89 d1                	mov    %edx,%ecx
8010171f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101722:	09 ca                	or     %ecx,%edx
80101724:	89 d1                	mov    %edx,%ecx
80101726:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101729:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010172d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101730:	89 04 24             	mov    %eax,(%esp)
80101733:	e8 62 1e 00 00       	call   8010359a <log_write>
        brelse(bp);
80101738:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010173b:	89 04 24             	mov    %eax,(%esp)
8010173e:	e8 d4 ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101746:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101749:	01 c2                	add    %eax,%edx
8010174b:	8b 45 08             	mov    0x8(%ebp),%eax
8010174e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101752:	89 04 24             	mov    %eax,(%esp)
80101755:	e8 b4 fe ff ff       	call   8010160e <bzero>
        return b + bi;
8010175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101760:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101762:	83 c4 34             	add    $0x34,%esp
80101765:	5b                   	pop    %ebx
80101766:	5d                   	pop    %ebp
80101767:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101768:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010176c:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101773:	7f 15                	jg     8010178a <balloc+0x12b>
80101775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101778:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010177b:	01 d0                	add    %edx,%eax
8010177d:	89 c2                	mov    %eax,%edx
8010177f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101782:	39 c2                	cmp    %eax,%edx
80101784:	0f 82 3b ff ff ff    	jb     801016c5 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010178a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010178d:	89 04 24             	mov    %eax,(%esp)
80101790:	e8 82 ea ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101795:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010179c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010179f:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017a2:	39 c2                	cmp    %eax,%edx
801017a4:	0f 82 e1 fe ff ff    	jb     8010168b <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801017aa:	c7 04 24 b5 88 10 80 	movl   $0x801088b5,(%esp)
801017b1:	e8 87 ed ff ff       	call   8010053d <panic>

801017b6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801017b6:	55                   	push   %ebp
801017b7:	89 e5                	mov    %esp,%ebp
801017b9:	53                   	push   %ebx
801017ba:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801017bd:	8d 45 dc             	lea    -0x24(%ebp),%eax
801017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801017c4:	8b 45 08             	mov    0x8(%ebp),%eax
801017c7:	89 04 24             	mov    %eax,(%esp)
801017ca:	e8 f9 fd ff ff       	call   801015c8 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801017cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801017d2:	89 c2                	mov    %eax,%edx
801017d4:	c1 ea 0c             	shr    $0xc,%edx
801017d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801017da:	c1 e8 03             	shr    $0x3,%eax
801017dd:	01 d0                	add    %edx,%eax
801017df:	8d 50 03             	lea    0x3(%eax),%edx
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801017e9:	89 04 24             	mov    %eax,(%esp)
801017ec:	e8 b5 e9 ff ff       	call   801001a6 <bread>
801017f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801017f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801017f7:	25 ff 0f 00 00       	and    $0xfff,%eax
801017fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801017ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101802:	89 c2                	mov    %eax,%edx
80101804:	c1 fa 1f             	sar    $0x1f,%edx
80101807:	c1 ea 1d             	shr    $0x1d,%edx
8010180a:	01 d0                	add    %edx,%eax
8010180c:	83 e0 07             	and    $0x7,%eax
8010180f:	29 d0                	sub    %edx,%eax
80101811:	ba 01 00 00 00       	mov    $0x1,%edx
80101816:	89 d3                	mov    %edx,%ebx
80101818:	89 c1                	mov    %eax,%ecx
8010181a:	d3 e3                	shl    %cl,%ebx
8010181c:	89 d8                	mov    %ebx,%eax
8010181e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101824:	8d 50 07             	lea    0x7(%eax),%edx
80101827:	85 c0                	test   %eax,%eax
80101829:	0f 48 c2             	cmovs  %edx,%eax
8010182c:	c1 f8 03             	sar    $0x3,%eax
8010182f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101832:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101837:	0f b6 c0             	movzbl %al,%eax
8010183a:	23 45 ec             	and    -0x14(%ebp),%eax
8010183d:	85 c0                	test   %eax,%eax
8010183f:	75 0c                	jne    8010184d <bfree+0x97>
    panic("freeing free block");
80101841:	c7 04 24 cb 88 10 80 	movl   $0x801088cb,(%esp)
80101848:	e8 f0 ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
8010184d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101850:	8d 50 07             	lea    0x7(%eax),%edx
80101853:	85 c0                	test   %eax,%eax
80101855:	0f 48 c2             	cmovs  %edx,%eax
80101858:	c1 f8 03             	sar    $0x3,%eax
8010185b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010185e:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101863:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101866:	f7 d1                	not    %ecx
80101868:	21 ca                	and    %ecx,%edx
8010186a:	89 d1                	mov    %edx,%ecx
8010186c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010186f:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101876:	89 04 24             	mov    %eax,(%esp)
80101879:	e8 1c 1d 00 00       	call   8010359a <log_write>
  brelse(bp);
8010187e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101881:	89 04 24             	mov    %eax,(%esp)
80101884:	e8 8e e9 ff ff       	call   80100217 <brelse>
}
80101889:	83 c4 34             	add    $0x34,%esp
8010188c:	5b                   	pop    %ebx
8010188d:	5d                   	pop    %ebp
8010188e:	c3                   	ret    

8010188f <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010188f:	55                   	push   %ebp
80101890:	89 e5                	mov    %esp,%ebp
80101892:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101895:	c7 44 24 04 de 88 10 	movl   $0x801088de,0x4(%esp)
8010189c:	80 
8010189d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801018a4:	e8 a9 38 00 00       	call   80105152 <initlock>
}
801018a9:	c9                   	leave  
801018aa:	c3                   	ret    

801018ab <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801018ab:	55                   	push   %ebp
801018ac:	89 e5                	mov    %esp,%ebp
801018ae:	83 ec 48             	sub    $0x48,%esp
801018b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801018b4:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8d 55 dc             	lea    -0x24(%ebp),%edx
801018be:	89 54 24 04          	mov    %edx,0x4(%esp)
801018c2:	89 04 24             	mov    %eax,(%esp)
801018c5:	e8 fe fc ff ff       	call   801015c8 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801018ca:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018d1:	e9 98 00 00 00       	jmp    8010196e <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801018d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d9:	c1 e8 03             	shr    $0x3,%eax
801018dc:	83 c0 02             	add    $0x2,%eax
801018df:	89 44 24 04          	mov    %eax,0x4(%esp)
801018e3:	8b 45 08             	mov    0x8(%ebp),%eax
801018e6:	89 04 24             	mov    %eax,(%esp)
801018e9:	e8 b8 e8 ff ff       	call   801001a6 <bread>
801018ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f4:	8d 50 18             	lea    0x18(%eax),%edx
801018f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fa:	83 e0 07             	and    $0x7,%eax
801018fd:	c1 e0 06             	shl    $0x6,%eax
80101900:	01 d0                	add    %edx,%eax
80101902:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101905:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101908:	0f b7 00             	movzwl (%eax),%eax
8010190b:	66 85 c0             	test   %ax,%ax
8010190e:	75 4f                	jne    8010195f <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101910:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101917:	00 
80101918:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010191f:	00 
80101920:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101923:	89 04 24             	mov    %eax,(%esp)
80101926:	e8 97 3a 00 00       	call   801053c2 <memset>
      dip->type = type;
8010192b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010192e:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101932:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101938:	89 04 24             	mov    %eax,(%esp)
8010193b:	e8 5a 1c 00 00       	call   8010359a <log_write>
      brelse(bp);
80101940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101943:	89 04 24             	mov    %eax,(%esp)
80101946:	e8 cc e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101952:	8b 45 08             	mov    0x8(%ebp),%eax
80101955:	89 04 24             	mov    %eax,(%esp)
80101958:	e8 e3 00 00 00       	call   80101a40 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
8010195d:	c9                   	leave  
8010195e:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
8010195f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101962:	89 04 24             	mov    %eax,(%esp)
80101965:	e8 ad e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010196a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010196e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101974:	39 c2                	cmp    %eax,%edx
80101976:	0f 82 5a ff ff ff    	jb     801018d6 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010197c:	c7 04 24 e5 88 10 80 	movl   $0x801088e5,(%esp)
80101983:	e8 b5 eb ff ff       	call   8010053d <panic>

80101988 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101988:	55                   	push   %ebp
80101989:	89 e5                	mov    %esp,%ebp
8010198b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010198e:	8b 45 08             	mov    0x8(%ebp),%eax
80101991:	8b 40 04             	mov    0x4(%eax),%eax
80101994:	c1 e8 03             	shr    $0x3,%eax
80101997:	8d 50 02             	lea    0x2(%eax),%edx
8010199a:	8b 45 08             	mov    0x8(%ebp),%eax
8010199d:	8b 00                	mov    (%eax),%eax
8010199f:	89 54 24 04          	mov    %edx,0x4(%esp)
801019a3:	89 04 24             	mov    %eax,(%esp)
801019a6:	e8 fb e7 ff ff       	call   801001a6 <bread>
801019ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	8d 50 18             	lea    0x18(%eax),%edx
801019b4:	8b 45 08             	mov    0x8(%ebp),%eax
801019b7:	8b 40 04             	mov    0x4(%eax),%eax
801019ba:	83 e0 07             	and    $0x7,%eax
801019bd:	c1 e0 06             	shl    $0x6,%eax
801019c0:	01 d0                	add    %edx,%eax
801019c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019c5:	8b 45 08             	mov    0x8(%ebp),%eax
801019c8:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801019cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cf:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019d2:	8b 45 08             	mov    0x8(%ebp),%eax
801019d5:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801019d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019dc:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801019e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ea:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019ee:	8b 45 08             	mov    0x8(%ebp),%eax
801019f1:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801019f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f8:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019fc:	8b 45 08             	mov    0x8(%ebp),%eax
801019ff:	8b 50 18             	mov    0x18(%eax),%edx
80101a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a05:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a11:	83 c0 0c             	add    $0xc,%eax
80101a14:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a1b:	00 
80101a1c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a20:	89 04 24             	mov    %eax,(%esp)
80101a23:	e8 6d 3a 00 00       	call   80105495 <memmove>
  log_write(bp);
80101a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2b:	89 04 24             	mov    %eax,(%esp)
80101a2e:	e8 67 1b 00 00       	call   8010359a <log_write>
  brelse(bp);
80101a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a36:	89 04 24             	mov    %eax,(%esp)
80101a39:	e8 d9 e7 ff ff       	call   80100217 <brelse>
}
80101a3e:	c9                   	leave  
80101a3f:	c3                   	ret    

80101a40 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a40:	55                   	push   %ebp
80101a41:	89 e5                	mov    %esp,%ebp
80101a43:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a46:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a4d:	e8 21 37 00 00       	call   80105173 <acquire>

  // Is the inode already cached?
  empty = 0;
80101a52:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a59:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101a60:	eb 59                	jmp    80101abb <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a65:	8b 40 08             	mov    0x8(%eax),%eax
80101a68:	85 c0                	test   %eax,%eax
80101a6a:	7e 35                	jle    80101aa1 <iget+0x61>
80101a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6f:	8b 00                	mov    (%eax),%eax
80101a71:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a74:	75 2b                	jne    80101aa1 <iget+0x61>
80101a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a79:	8b 40 04             	mov    0x4(%eax),%eax
80101a7c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a7f:	75 20                	jne    80101aa1 <iget+0x61>
      ip->ref++;
80101a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a84:	8b 40 08             	mov    0x8(%eax),%eax
80101a87:	8d 50 01             	lea    0x1(%eax),%edx
80101a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a90:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a97:	e8 39 37 00 00       	call   801051d5 <release>
      return ip;
80101a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9f:	eb 6f                	jmp    80101b10 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101aa1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aa5:	75 10                	jne    80101ab7 <iget+0x77>
80101aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aaa:	8b 40 08             	mov    0x8(%eax),%eax
80101aad:	85 c0                	test   %eax,%eax
80101aaf:	75 06                	jne    80101ab7 <iget+0x77>
      empty = ip;
80101ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ab7:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101abb:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101ac2:	72 9e                	jb     80101a62 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101ac4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ac8:	75 0c                	jne    80101ad6 <iget+0x96>
    panic("iget: no inodes");
80101aca:	c7 04 24 f7 88 10 80 	movl   $0x801088f7,(%esp)
80101ad1:	e8 67 ea ff ff       	call   8010053d <panic>

  ip = empty;
80101ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101adf:	8b 55 08             	mov    0x8(%ebp),%edx
80101ae2:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101aea:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afa:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b01:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b08:	e8 c8 36 00 00       	call   801051d5 <release>

  return ip;
80101b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b10:	c9                   	leave  
80101b11:	c3                   	ret    

80101b12 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b12:	55                   	push   %ebp
80101b13:	89 e5                	mov    %esp,%ebp
80101b15:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b18:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b1f:	e8 4f 36 00 00       	call   80105173 <acquire>
  ip->ref++;
80101b24:	8b 45 08             	mov    0x8(%ebp),%eax
80101b27:	8b 40 08             	mov    0x8(%eax),%eax
80101b2a:	8d 50 01             	lea    0x1(%eax),%edx
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b33:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b3a:	e8 96 36 00 00       	call   801051d5 <release>
  return ip;
80101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b42:	c9                   	leave  
80101b43:	c3                   	ret    

80101b44 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b44:	55                   	push   %ebp
80101b45:	89 e5                	mov    %esp,%ebp
80101b47:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b4a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b4e:	74 0a                	je     80101b5a <ilock+0x16>
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 08             	mov    0x8(%eax),%eax
80101b56:	85 c0                	test   %eax,%eax
80101b58:	7f 0c                	jg     80101b66 <ilock+0x22>
    panic("ilock");
80101b5a:	c7 04 24 07 89 10 80 	movl   $0x80108907,(%esp)
80101b61:	e8 d7 e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101b66:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b6d:	e8 01 36 00 00       	call   80105173 <acquire>
  while(ip->flags & I_BUSY)
80101b72:	eb 13                	jmp    80101b87 <ilock+0x43>
    sleep(ip, &icache.lock);
80101b74:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101b7b:	80 
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	89 04 24             	mov    %eax,(%esp)
80101b82:	e8 83 32 00 00       	call   80104e0a <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101b87:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8a:	8b 40 0c             	mov    0xc(%eax),%eax
80101b8d:	83 e0 01             	and    $0x1,%eax
80101b90:	84 c0                	test   %al,%al
80101b92:	75 e0                	jne    80101b74 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	8b 40 0c             	mov    0xc(%eax),%eax
80101b9a:	89 c2                	mov    %eax,%edx
80101b9c:	83 ca 01             	or     $0x1,%edx
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101ba5:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bac:	e8 24 36 00 00       	call   801051d5 <release>

  if(!(ip->flags & I_VALID)){
80101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb4:	8b 40 0c             	mov    0xc(%eax),%eax
80101bb7:	83 e0 02             	and    $0x2,%eax
80101bba:	85 c0                	test   %eax,%eax
80101bbc:	0f 85 ce 00 00 00    	jne    80101c90 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	8b 40 04             	mov    0x4(%eax),%eax
80101bc8:	c1 e8 03             	shr    $0x3,%eax
80101bcb:	8d 50 02             	lea    0x2(%eax),%edx
80101bce:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd1:	8b 00                	mov    (%eax),%eax
80101bd3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bd7:	89 04 24             	mov    %eax,(%esp)
80101bda:	e8 c7 e5 ff ff       	call   801001a6 <bread>
80101bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be5:	8d 50 18             	lea    0x18(%eax),%edx
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	8b 40 04             	mov    0x4(%eax),%eax
80101bee:	83 e0 07             	and    $0x7,%eax
80101bf1:	c1 e0 06             	shl    $0x6,%eax
80101bf4:	01 d0                	add    %edx,%eax
80101bf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bfc:	0f b7 10             	movzwl (%eax),%edx
80101bff:	8b 45 08             	mov    0x8(%ebp),%eax
80101c02:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c09:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c17:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c25:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c33:	8b 50 08             	mov    0x8(%eax),%edx
80101c36:	8b 45 08             	mov    0x8(%ebp),%eax
80101c39:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c3f:	8d 50 0c             	lea    0xc(%eax),%edx
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	83 c0 1c             	add    $0x1c,%eax
80101c48:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101c4f:	00 
80101c50:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c54:	89 04 24             	mov    %eax,(%esp)
80101c57:	e8 39 38 00 00       	call   80105495 <memmove>
    brelse(bp);
80101c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5f:	89 04 24             	mov    %eax,(%esp)
80101c62:	e8 b0 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 40 0c             	mov    0xc(%eax),%eax
80101c6d:	89 c2                	mov    %eax,%edx
80101c6f:	83 ca 02             	or     $0x2,%edx
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101c78:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101c7f:	66 85 c0             	test   %ax,%ax
80101c82:	75 0c                	jne    80101c90 <ilock+0x14c>
      panic("ilock: no type");
80101c84:	c7 04 24 0d 89 10 80 	movl   $0x8010890d,(%esp)
80101c8b:	e8 ad e8 ff ff       	call   8010053d <panic>
  }
}
80101c90:	c9                   	leave  
80101c91:	c3                   	ret    

80101c92 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c92:	55                   	push   %ebp
80101c93:	89 e5                	mov    %esp,%ebp
80101c95:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101c98:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c9c:	74 17                	je     80101cb5 <iunlock+0x23>
80101c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca1:	8b 40 0c             	mov    0xc(%eax),%eax
80101ca4:	83 e0 01             	and    $0x1,%eax
80101ca7:	85 c0                	test   %eax,%eax
80101ca9:	74 0a                	je     80101cb5 <iunlock+0x23>
80101cab:	8b 45 08             	mov    0x8(%ebp),%eax
80101cae:	8b 40 08             	mov    0x8(%eax),%eax
80101cb1:	85 c0                	test   %eax,%eax
80101cb3:	7f 0c                	jg     80101cc1 <iunlock+0x2f>
    panic("iunlock");
80101cb5:	c7 04 24 1c 89 10 80 	movl   $0x8010891c,(%esp)
80101cbc:	e8 7c e8 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101cc1:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101cc8:	e8 a6 34 00 00       	call   80105173 <acquire>
  ip->flags &= ~I_BUSY;
80101ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd0:	8b 40 0c             	mov    0xc(%eax),%eax
80101cd3:	89 c2                	mov    %eax,%edx
80101cd5:	83 e2 fe             	and    $0xfffffffe,%edx
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101cde:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce1:	89 04 24             	mov    %eax,(%esp)
80101ce4:	e8 fd 31 00 00       	call   80104ee6 <wakeup>
  release(&icache.lock);
80101ce9:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101cf0:	e8 e0 34 00 00       	call   801051d5 <release>
}
80101cf5:	c9                   	leave  
80101cf6:	c3                   	ret    

80101cf7 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101cf7:	55                   	push   %ebp
80101cf8:	89 e5                	mov    %esp,%ebp
80101cfa:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101cfd:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d04:	e8 6a 34 00 00       	call   80105173 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d09:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0c:	8b 40 08             	mov    0x8(%eax),%eax
80101d0f:	83 f8 01             	cmp    $0x1,%eax
80101d12:	0f 85 93 00 00 00    	jne    80101dab <iput+0xb4>
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	8b 40 0c             	mov    0xc(%eax),%eax
80101d1e:	83 e0 02             	and    $0x2,%eax
80101d21:	85 c0                	test   %eax,%eax
80101d23:	0f 84 82 00 00 00    	je     80101dab <iput+0xb4>
80101d29:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d30:	66 85 c0             	test   %ax,%ax
80101d33:	75 76                	jne    80101dab <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 40 0c             	mov    0xc(%eax),%eax
80101d3b:	83 e0 01             	and    $0x1,%eax
80101d3e:	84 c0                	test   %al,%al
80101d40:	74 0c                	je     80101d4e <iput+0x57>
      panic("iput busy");
80101d42:	c7 04 24 24 89 10 80 	movl   $0x80108924,(%esp)
80101d49:	e8 ef e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d51:	8b 40 0c             	mov    0xc(%eax),%eax
80101d54:	89 c2                	mov    %eax,%edx
80101d56:	83 ca 01             	or     $0x1,%edx
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101d5f:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d66:	e8 6a 34 00 00       	call   801051d5 <release>
    itrunc(ip);
80101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6e:	89 04 24             	mov    %eax,(%esp)
80101d71:	e8 72 01 00 00       	call   80101ee8 <itrunc>
    ip->type = 0;
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	89 04 24             	mov    %eax,(%esp)
80101d85:	e8 fe fb ff ff       	call   80101988 <iupdate>
    acquire(&icache.lock);
80101d8a:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d91:	e8 dd 33 00 00       	call   80105173 <acquire>
    ip->flags = 0;
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	89 04 24             	mov    %eax,(%esp)
80101da6:	e8 3b 31 00 00       	call   80104ee6 <wakeup>
  }
  ip->ref--;
80101dab:	8b 45 08             	mov    0x8(%ebp),%eax
80101dae:	8b 40 08             	mov    0x8(%eax),%eax
80101db1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101dba:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101dc1:	e8 0f 34 00 00       	call   801051d5 <release>
}
80101dc6:	c9                   	leave  
80101dc7:	c3                   	ret    

80101dc8 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101dc8:	55                   	push   %ebp
80101dc9:	89 e5                	mov    %esp,%ebp
80101dcb:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101dce:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd1:	89 04 24             	mov    %eax,(%esp)
80101dd4:	e8 b9 fe ff ff       	call   80101c92 <iunlock>
  iput(ip);
80101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddc:	89 04 24             	mov    %eax,(%esp)
80101ddf:	e8 13 ff ff ff       	call   80101cf7 <iput>
}
80101de4:	c9                   	leave  
80101de5:	c3                   	ret    

80101de6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101de6:	55                   	push   %ebp
80101de7:	89 e5                	mov    %esp,%ebp
80101de9:	53                   	push   %ebx
80101dea:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101ded:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101df1:	77 3e                	ja     80101e31 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101df3:	8b 45 08             	mov    0x8(%ebp),%eax
80101df6:	8b 55 0c             	mov    0xc(%ebp),%edx
80101df9:	83 c2 04             	add    $0x4,%edx
80101dfc:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e07:	75 20                	jne    80101e29 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e09:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0c:	8b 00                	mov    (%eax),%eax
80101e0e:	89 04 24             	mov    %eax,(%esp)
80101e11:	e8 49 f8 ff ff       	call   8010165f <balloc>
80101e16:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e19:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e1f:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e25:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e2c:	e9 b1 00 00 00       	jmp    80101ee2 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101e31:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e35:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e39:	0f 87 97 00 00 00    	ja     80101ed6 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e42:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e4c:	75 19                	jne    80101e67 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e51:	8b 00                	mov    (%eax),%eax
80101e53:	89 04 24             	mov    %eax,(%esp)
80101e56:	e8 04 f8 ff ff       	call   8010165f <balloc>
80101e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e64:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101e67:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6a:	8b 00                	mov    (%eax),%eax
80101e6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e73:	89 04 24             	mov    %eax,(%esp)
80101e76:	e8 2b e3 ff ff       	call   801001a6 <bread>
80101e7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e81:	83 c0 18             	add    $0x18,%eax
80101e84:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e87:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8a:	c1 e0 02             	shl    $0x2,%eax
80101e8d:	03 45 ec             	add    -0x14(%ebp),%eax
80101e90:	8b 00                	mov    (%eax),%eax
80101e92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e99:	75 2b                	jne    80101ec6 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9e:	c1 e0 02             	shl    $0x2,%eax
80101ea1:	89 c3                	mov    %eax,%ebx
80101ea3:	03 5d ec             	add    -0x14(%ebp),%ebx
80101ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea9:	8b 00                	mov    (%eax),%eax
80101eab:	89 04 24             	mov    %eax,(%esp)
80101eae:	e8 ac f7 ff ff       	call   8010165f <balloc>
80101eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb9:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebe:	89 04 24             	mov    %eax,(%esp)
80101ec1:	e8 d4 16 00 00       	call   8010359a <log_write>
    }
    brelse(bp);
80101ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec9:	89 04 24             	mov    %eax,(%esp)
80101ecc:	e8 46 e3 ff ff       	call   80100217 <brelse>
    return addr;
80101ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed4:	eb 0c                	jmp    80101ee2 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101ed6:	c7 04 24 2e 89 10 80 	movl   $0x8010892e,(%esp)
80101edd:	e8 5b e6 ff ff       	call   8010053d <panic>
}
80101ee2:	83 c4 24             	add    $0x24,%esp
80101ee5:	5b                   	pop    %ebx
80101ee6:	5d                   	pop    %ebp
80101ee7:	c3                   	ret    

80101ee8 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ee8:	55                   	push   %ebp
80101ee9:	89 e5                	mov    %esp,%ebp
80101eeb:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101eee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ef5:	eb 44                	jmp    80101f3b <itrunc+0x53>
    if(ip->addrs[i]){
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101efd:	83 c2 04             	add    $0x4,%edx
80101f00:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f04:	85 c0                	test   %eax,%eax
80101f06:	74 2f                	je     80101f37 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f0e:	83 c2 04             	add    $0x4,%edx
80101f11:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	8b 00                	mov    (%eax),%eax
80101f1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f1e:	89 04 24             	mov    %eax,(%esp)
80101f21:	e8 90 f8 ff ff       	call   801017b6 <bfree>
      ip->addrs[i] = 0;
80101f26:	8b 45 08             	mov    0x8(%ebp),%eax
80101f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f2c:	83 c2 04             	add    $0x4,%edx
80101f2f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f36:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f3b:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f3f:	7e b6                	jle    80101ef7 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f47:	85 c0                	test   %eax,%eax
80101f49:	0f 84 8f 00 00 00    	je     80101fde <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	8b 50 4c             	mov    0x4c(%eax),%edx
80101f55:	8b 45 08             	mov    0x8(%ebp),%eax
80101f58:	8b 00                	mov    (%eax),%eax
80101f5a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f5e:	89 04 24             	mov    %eax,(%esp)
80101f61:	e8 40 e2 ff ff       	call   801001a6 <bread>
80101f66:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f6c:	83 c0 18             	add    $0x18,%eax
80101f6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f72:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f79:	eb 2f                	jmp    80101faa <itrunc+0xc2>
      if(a[j])
80101f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f7e:	c1 e0 02             	shl    $0x2,%eax
80101f81:	03 45 e8             	add    -0x18(%ebp),%eax
80101f84:	8b 00                	mov    (%eax),%eax
80101f86:	85 c0                	test   %eax,%eax
80101f88:	74 1c                	je     80101fa6 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f8d:	c1 e0 02             	shl    $0x2,%eax
80101f90:	03 45 e8             	add    -0x18(%ebp),%eax
80101f93:	8b 10                	mov    (%eax),%edx
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	8b 00                	mov    (%eax),%eax
80101f9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f9e:	89 04 24             	mov    %eax,(%esp)
80101fa1:	e8 10 f8 ff ff       	call   801017b6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101fa6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fad:	83 f8 7f             	cmp    $0x7f,%eax
80101fb0:	76 c9                	jbe    80101f7b <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101fb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fb5:	89 04 24             	mov    %eax,(%esp)
80101fb8:	e8 5a e2 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc0:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc6:	8b 00                	mov    (%eax),%eax
80101fc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fcc:	89 04 24             	mov    %eax,(%esp)
80101fcf:	e8 e2 f7 ff ff       	call   801017b6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101fde:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe1:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80101feb:	89 04 24             	mov    %eax,(%esp)
80101fee:	e8 95 f9 ff ff       	call   80101988 <iupdate>
}
80101ff3:	c9                   	leave  
80101ff4:	c3                   	ret    

80101ff5 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101ff5:	55                   	push   %ebp
80101ff6:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffb:	8b 00                	mov    (%eax),%eax
80101ffd:	89 c2                	mov    %eax,%edx
80101fff:	8b 45 0c             	mov    0xc(%ebp),%eax
80102002:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102005:	8b 45 08             	mov    0x8(%ebp),%eax
80102008:	8b 50 04             	mov    0x4(%eax),%edx
8010200b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010200e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102011:	8b 45 08             	mov    0x8(%ebp),%eax
80102014:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102018:	8b 45 0c             	mov    0xc(%ebp),%eax
8010201b:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010201e:	8b 45 08             	mov    0x8(%ebp),%eax
80102021:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102025:	8b 45 0c             	mov    0xc(%ebp),%eax
80102028:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010202c:	8b 45 08             	mov    0x8(%ebp),%eax
8010202f:	8b 50 18             	mov    0x18(%eax),%edx
80102032:	8b 45 0c             	mov    0xc(%ebp),%eax
80102035:	89 50 10             	mov    %edx,0x10(%eax)
}
80102038:	5d                   	pop    %ebp
80102039:	c3                   	ret    

8010203a <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010203a:	55                   	push   %ebp
8010203b:	89 e5                	mov    %esp,%ebp
8010203d:	53                   	push   %ebx
8010203e:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102041:	8b 45 08             	mov    0x8(%ebp),%eax
80102044:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102048:	66 83 f8 03          	cmp    $0x3,%ax
8010204c:	75 60                	jne    801020ae <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102055:	66 85 c0             	test   %ax,%ax
80102058:	78 20                	js     8010207a <readi+0x40>
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102061:	66 83 f8 09          	cmp    $0x9,%ax
80102065:	7f 13                	jg     8010207a <readi+0x40>
80102067:	8b 45 08             	mov    0x8(%ebp),%eax
8010206a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010206e:	98                   	cwtl   
8010206f:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80102076:	85 c0                	test   %eax,%eax
80102078:	75 0a                	jne    80102084 <readi+0x4a>
      return -1;
8010207a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010207f:	e9 1b 01 00 00       	jmp    8010219f <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010208b:	98                   	cwtl   
8010208c:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
80102093:	8b 45 14             	mov    0x14(%ebp),%eax
80102096:	89 44 24 08          	mov    %eax,0x8(%esp)
8010209a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010209d:	89 44 24 04          	mov    %eax,0x4(%esp)
801020a1:	8b 45 08             	mov    0x8(%ebp),%eax
801020a4:	89 04 24             	mov    %eax,(%esp)
801020a7:	ff d2                	call   *%edx
801020a9:	e9 f1 00 00 00       	jmp    8010219f <readi+0x165>
  }

  if(off > ip->size || off + n < off)
801020ae:	8b 45 08             	mov    0x8(%ebp),%eax
801020b1:	8b 40 18             	mov    0x18(%eax),%eax
801020b4:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b7:	72 0d                	jb     801020c6 <readi+0x8c>
801020b9:	8b 45 14             	mov    0x14(%ebp),%eax
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	01 d0                	add    %edx,%eax
801020c1:	3b 45 10             	cmp    0x10(%ebp),%eax
801020c4:	73 0a                	jae    801020d0 <readi+0x96>
    return -1;
801020c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020cb:	e9 cf 00 00 00       	jmp    8010219f <readi+0x165>
  if(off + n > ip->size)
801020d0:	8b 45 14             	mov    0x14(%ebp),%eax
801020d3:	8b 55 10             	mov    0x10(%ebp),%edx
801020d6:	01 c2                	add    %eax,%edx
801020d8:	8b 45 08             	mov    0x8(%ebp),%eax
801020db:	8b 40 18             	mov    0x18(%eax),%eax
801020de:	39 c2                	cmp    %eax,%edx
801020e0:	76 0c                	jbe    801020ee <readi+0xb4>
    n = ip->size - off;
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	8b 40 18             	mov    0x18(%eax),%eax
801020e8:	2b 45 10             	sub    0x10(%ebp),%eax
801020eb:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f5:	e9 96 00 00 00       	jmp    80102190 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020fa:	8b 45 10             	mov    0x10(%ebp),%eax
801020fd:	c1 e8 09             	shr    $0x9,%eax
80102100:	89 44 24 04          	mov    %eax,0x4(%esp)
80102104:	8b 45 08             	mov    0x8(%ebp),%eax
80102107:	89 04 24             	mov    %eax,(%esp)
8010210a:	e8 d7 fc ff ff       	call   80101de6 <bmap>
8010210f:	8b 55 08             	mov    0x8(%ebp),%edx
80102112:	8b 12                	mov    (%edx),%edx
80102114:	89 44 24 04          	mov    %eax,0x4(%esp)
80102118:	89 14 24             	mov    %edx,(%esp)
8010211b:	e8 86 e0 ff ff       	call   801001a6 <bread>
80102120:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102123:	8b 45 10             	mov    0x10(%ebp),%eax
80102126:	89 c2                	mov    %eax,%edx
80102128:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010212e:	b8 00 02 00 00       	mov    $0x200,%eax
80102133:	89 c1                	mov    %eax,%ecx
80102135:	29 d1                	sub    %edx,%ecx
80102137:	89 ca                	mov    %ecx,%edx
80102139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010213c:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010213f:	89 cb                	mov    %ecx,%ebx
80102141:	29 c3                	sub    %eax,%ebx
80102143:	89 d8                	mov    %ebx,%eax
80102145:	39 c2                	cmp    %eax,%edx
80102147:	0f 46 c2             	cmovbe %edx,%eax
8010214a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010214d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102150:	8d 50 18             	lea    0x18(%eax),%edx
80102153:	8b 45 10             	mov    0x10(%ebp),%eax
80102156:	25 ff 01 00 00       	and    $0x1ff,%eax
8010215b:	01 c2                	add    %eax,%edx
8010215d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102160:	89 44 24 08          	mov    %eax,0x8(%esp)
80102164:	89 54 24 04          	mov    %edx,0x4(%esp)
80102168:	8b 45 0c             	mov    0xc(%ebp),%eax
8010216b:	89 04 24             	mov    %eax,(%esp)
8010216e:	e8 22 33 00 00       	call   80105495 <memmove>
    brelse(bp);
80102173:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102176:	89 04 24             	mov    %eax,(%esp)
80102179:	e8 99 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010217e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102181:	01 45 f4             	add    %eax,-0xc(%ebp)
80102184:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102187:	01 45 10             	add    %eax,0x10(%ebp)
8010218a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218d:	01 45 0c             	add    %eax,0xc(%ebp)
80102190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102193:	3b 45 14             	cmp    0x14(%ebp),%eax
80102196:	0f 82 5e ff ff ff    	jb     801020fa <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010219c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010219f:	83 c4 24             	add    $0x24,%esp
801021a2:	5b                   	pop    %ebx
801021a3:	5d                   	pop    %ebp
801021a4:	c3                   	ret    

801021a5 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021a5:	55                   	push   %ebp
801021a6:	89 e5                	mov    %esp,%ebp
801021a8:	53                   	push   %ebx
801021a9:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021ac:	8b 45 08             	mov    0x8(%ebp),%eax
801021af:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021b3:	66 83 f8 03          	cmp    $0x3,%ax
801021b7:	75 60                	jne    80102219 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021b9:	8b 45 08             	mov    0x8(%ebp),%eax
801021bc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021c0:	66 85 c0             	test   %ax,%ax
801021c3:	78 20                	js     801021e5 <writei+0x40>
801021c5:	8b 45 08             	mov    0x8(%ebp),%eax
801021c8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021cc:	66 83 f8 09          	cmp    $0x9,%ax
801021d0:	7f 13                	jg     801021e5 <writei+0x40>
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021d9:	98                   	cwtl   
801021da:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
801021e1:	85 c0                	test   %eax,%eax
801021e3:	75 0a                	jne    801021ef <writei+0x4a>
      return -1;
801021e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ea:	e9 46 01 00 00       	jmp    80102335 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
801021ef:	8b 45 08             	mov    0x8(%ebp),%eax
801021f2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021f6:	98                   	cwtl   
801021f7:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
801021fe:	8b 45 14             	mov    0x14(%ebp),%eax
80102201:	89 44 24 08          	mov    %eax,0x8(%esp)
80102205:	8b 45 0c             	mov    0xc(%ebp),%eax
80102208:	89 44 24 04          	mov    %eax,0x4(%esp)
8010220c:	8b 45 08             	mov    0x8(%ebp),%eax
8010220f:	89 04 24             	mov    %eax,(%esp)
80102212:	ff d2                	call   *%edx
80102214:	e9 1c 01 00 00       	jmp    80102335 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80102219:	8b 45 08             	mov    0x8(%ebp),%eax
8010221c:	8b 40 18             	mov    0x18(%eax),%eax
8010221f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102222:	72 0d                	jb     80102231 <writei+0x8c>
80102224:	8b 45 14             	mov    0x14(%ebp),%eax
80102227:	8b 55 10             	mov    0x10(%ebp),%edx
8010222a:	01 d0                	add    %edx,%eax
8010222c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010222f:	73 0a                	jae    8010223b <writei+0x96>
    return -1;
80102231:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102236:	e9 fa 00 00 00       	jmp    80102335 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
8010223b:	8b 45 14             	mov    0x14(%ebp),%eax
8010223e:	8b 55 10             	mov    0x10(%ebp),%edx
80102241:	01 d0                	add    %edx,%eax
80102243:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102248:	76 0a                	jbe    80102254 <writei+0xaf>
    return -1;
8010224a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010224f:	e9 e1 00 00 00       	jmp    80102335 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102254:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010225b:	e9 a1 00 00 00       	jmp    80102301 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102260:	8b 45 10             	mov    0x10(%ebp),%eax
80102263:	c1 e8 09             	shr    $0x9,%eax
80102266:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226a:	8b 45 08             	mov    0x8(%ebp),%eax
8010226d:	89 04 24             	mov    %eax,(%esp)
80102270:	e8 71 fb ff ff       	call   80101de6 <bmap>
80102275:	8b 55 08             	mov    0x8(%ebp),%edx
80102278:	8b 12                	mov    (%edx),%edx
8010227a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010227e:	89 14 24             	mov    %edx,(%esp)
80102281:	e8 20 df ff ff       	call   801001a6 <bread>
80102286:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102289:	8b 45 10             	mov    0x10(%ebp),%eax
8010228c:	89 c2                	mov    %eax,%edx
8010228e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102294:	b8 00 02 00 00       	mov    $0x200,%eax
80102299:	89 c1                	mov    %eax,%ecx
8010229b:	29 d1                	sub    %edx,%ecx
8010229d:	89 ca                	mov    %ecx,%edx
8010229f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a2:	8b 4d 14             	mov    0x14(%ebp),%ecx
801022a5:	89 cb                	mov    %ecx,%ebx
801022a7:	29 c3                	sub    %eax,%ebx
801022a9:	89 d8                	mov    %ebx,%eax
801022ab:	39 c2                	cmp    %eax,%edx
801022ad:	0f 46 c2             	cmovbe %edx,%eax
801022b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022b6:	8d 50 18             	lea    0x18(%eax),%edx
801022b9:	8b 45 10             	mov    0x10(%ebp),%eax
801022bc:	25 ff 01 00 00       	and    $0x1ff,%eax
801022c1:	01 c2                	add    %eax,%edx
801022c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022c6:	89 44 24 08          	mov    %eax,0x8(%esp)
801022ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d1:	89 14 24             	mov    %edx,(%esp)
801022d4:	e8 bc 31 00 00       	call   80105495 <memmove>
    log_write(bp);
801022d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022dc:	89 04 24             	mov    %eax,(%esp)
801022df:	e8 b6 12 00 00       	call   8010359a <log_write>
    brelse(bp);
801022e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e7:	89 04 24             	mov    %eax,(%esp)
801022ea:	e8 28 df ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022f2:	01 45 f4             	add    %eax,-0xc(%ebp)
801022f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022f8:	01 45 10             	add    %eax,0x10(%ebp)
801022fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022fe:	01 45 0c             	add    %eax,0xc(%ebp)
80102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102304:	3b 45 14             	cmp    0x14(%ebp),%eax
80102307:	0f 82 53 ff ff ff    	jb     80102260 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010230d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102311:	74 1f                	je     80102332 <writei+0x18d>
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 40 18             	mov    0x18(%eax),%eax
80102319:	3b 45 10             	cmp    0x10(%ebp),%eax
8010231c:	73 14                	jae    80102332 <writei+0x18d>
    ip->size = off;
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8b 55 10             	mov    0x10(%ebp),%edx
80102324:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102327:	8b 45 08             	mov    0x8(%ebp),%eax
8010232a:	89 04 24             	mov    %eax,(%esp)
8010232d:	e8 56 f6 ff ff       	call   80101988 <iupdate>
  }
  return n;
80102332:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102335:	83 c4 24             	add    $0x24,%esp
80102338:	5b                   	pop    %ebx
80102339:	5d                   	pop    %ebp
8010233a:	c3                   	ret    

8010233b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010233b:	55                   	push   %ebp
8010233c:	89 e5                	mov    %esp,%ebp
8010233e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102341:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102348:	00 
80102349:	8b 45 0c             	mov    0xc(%ebp),%eax
8010234c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102350:	8b 45 08             	mov    0x8(%ebp),%eax
80102353:	89 04 24             	mov    %eax,(%esp)
80102356:	e8 de 31 00 00       	call   80105539 <strncmp>
}
8010235b:	c9                   	leave  
8010235c:	c3                   	ret    

8010235d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010235d:	55                   	push   %ebp
8010235e:	89 e5                	mov    %esp,%ebp
80102360:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102363:	8b 45 08             	mov    0x8(%ebp),%eax
80102366:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010236a:	66 83 f8 01          	cmp    $0x1,%ax
8010236e:	74 0c                	je     8010237c <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102370:	c7 04 24 41 89 10 80 	movl   $0x80108941,(%esp)
80102377:	e8 c1 e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010237c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102383:	e9 87 00 00 00       	jmp    8010240f <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102388:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010238f:	00 
80102390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102393:	89 44 24 08          	mov    %eax,0x8(%esp)
80102397:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010239a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010239e:	8b 45 08             	mov    0x8(%ebp),%eax
801023a1:	89 04 24             	mov    %eax,(%esp)
801023a4:	e8 91 fc ff ff       	call   8010203a <readi>
801023a9:	83 f8 10             	cmp    $0x10,%eax
801023ac:	74 0c                	je     801023ba <dirlookup+0x5d>
      panic("dirlink read");
801023ae:	c7 04 24 53 89 10 80 	movl   $0x80108953,(%esp)
801023b5:	e8 83 e1 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801023ba:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023be:	66 85 c0             	test   %ax,%ax
801023c1:	74 47                	je     8010240a <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801023c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c6:	83 c0 02             	add    $0x2,%eax
801023c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801023cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d0:	89 04 24             	mov    %eax,(%esp)
801023d3:	e8 63 ff ff ff       	call   8010233b <namecmp>
801023d8:	85 c0                	test   %eax,%eax
801023da:	75 2f                	jne    8010240b <dirlookup+0xae>
      // entry matches path element
      if(poff)
801023dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023e0:	74 08                	je     801023ea <dirlookup+0x8d>
        *poff = off;
801023e2:	8b 45 10             	mov    0x10(%ebp),%eax
801023e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023e8:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023ea:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ee:	0f b7 c0             	movzwl %ax,%eax
801023f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023f4:	8b 45 08             	mov    0x8(%ebp),%eax
801023f7:	8b 00                	mov    (%eax),%eax
801023f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80102400:	89 04 24             	mov    %eax,(%esp)
80102403:	e8 38 f6 ff ff       	call   80101a40 <iget>
80102408:	eb 19                	jmp    80102423 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010240a:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010240b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010240f:	8b 45 08             	mov    0x8(%ebp),%eax
80102412:	8b 40 18             	mov    0x18(%eax),%eax
80102415:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102418:	0f 87 6a ff ff ff    	ja     80102388 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010241e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102423:	c9                   	leave  
80102424:	c3                   	ret    

80102425 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102425:	55                   	push   %ebp
80102426:	89 e5                	mov    %esp,%ebp
80102428:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010242b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102432:	00 
80102433:	8b 45 0c             	mov    0xc(%ebp),%eax
80102436:	89 44 24 04          	mov    %eax,0x4(%esp)
8010243a:	8b 45 08             	mov    0x8(%ebp),%eax
8010243d:	89 04 24             	mov    %eax,(%esp)
80102440:	e8 18 ff ff ff       	call   8010235d <dirlookup>
80102445:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102448:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010244c:	74 15                	je     80102463 <dirlink+0x3e>
    iput(ip);
8010244e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102451:	89 04 24             	mov    %eax,(%esp)
80102454:	e8 9e f8 ff ff       	call   80101cf7 <iput>
    return -1;
80102459:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010245e:	e9 b8 00 00 00       	jmp    8010251b <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102463:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010246a:	eb 44                	jmp    801024b0 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010246c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102476:	00 
80102477:	89 44 24 08          	mov    %eax,0x8(%esp)
8010247b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010247e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	89 04 24             	mov    %eax,(%esp)
80102488:	e8 ad fb ff ff       	call   8010203a <readi>
8010248d:	83 f8 10             	cmp    $0x10,%eax
80102490:	74 0c                	je     8010249e <dirlink+0x79>
      panic("dirlink read");
80102492:	c7 04 24 53 89 10 80 	movl   $0x80108953,(%esp)
80102499:	e8 9f e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
8010249e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024a2:	66 85 c0             	test   %ax,%ax
801024a5:	74 18                	je     801024bf <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024aa:	83 c0 10             	add    $0x10,%eax
801024ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024b3:	8b 45 08             	mov    0x8(%ebp),%eax
801024b6:	8b 40 18             	mov    0x18(%eax),%eax
801024b9:	39 c2                	cmp    %eax,%edx
801024bb:	72 af                	jb     8010246c <dirlink+0x47>
801024bd:	eb 01                	jmp    801024c0 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801024bf:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024c0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024c7:	00 
801024c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801024cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801024cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024d2:	83 c0 02             	add    $0x2,%eax
801024d5:	89 04 24             	mov    %eax,(%esp)
801024d8:	e8 b4 30 00 00       	call   80105591 <strncpy>
  de.inum = inum;
801024dd:	8b 45 10             	mov    0x10(%ebp),%eax
801024e0:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024ee:	00 
801024ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801024f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801024fa:	8b 45 08             	mov    0x8(%ebp),%eax
801024fd:	89 04 24             	mov    %eax,(%esp)
80102500:	e8 a0 fc ff ff       	call   801021a5 <writei>
80102505:	83 f8 10             	cmp    $0x10,%eax
80102508:	74 0c                	je     80102516 <dirlink+0xf1>
    panic("dirlink");
8010250a:	c7 04 24 60 89 10 80 	movl   $0x80108960,(%esp)
80102511:	e8 27 e0 ff ff       	call   8010053d <panic>
  
  return 0;
80102516:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102523:	eb 04                	jmp    80102529 <skipelem+0xc>
    path++;
80102525:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102529:	8b 45 08             	mov    0x8(%ebp),%eax
8010252c:	0f b6 00             	movzbl (%eax),%eax
8010252f:	3c 2f                	cmp    $0x2f,%al
80102531:	74 f2                	je     80102525 <skipelem+0x8>
    path++;
  if(*path == 0)
80102533:	8b 45 08             	mov    0x8(%ebp),%eax
80102536:	0f b6 00             	movzbl (%eax),%eax
80102539:	84 c0                	test   %al,%al
8010253b:	75 0a                	jne    80102547 <skipelem+0x2a>
    return 0;
8010253d:	b8 00 00 00 00       	mov    $0x0,%eax
80102542:	e9 86 00 00 00       	jmp    801025cd <skipelem+0xb0>
  s = path;
80102547:	8b 45 08             	mov    0x8(%ebp),%eax
8010254a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010254d:	eb 04                	jmp    80102553 <skipelem+0x36>
    path++;
8010254f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102553:	8b 45 08             	mov    0x8(%ebp),%eax
80102556:	0f b6 00             	movzbl (%eax),%eax
80102559:	3c 2f                	cmp    $0x2f,%al
8010255b:	74 0a                	je     80102567 <skipelem+0x4a>
8010255d:	8b 45 08             	mov    0x8(%ebp),%eax
80102560:	0f b6 00             	movzbl (%eax),%eax
80102563:	84 c0                	test   %al,%al
80102565:	75 e8                	jne    8010254f <skipelem+0x32>
    path++;
  len = path - s;
80102567:	8b 55 08             	mov    0x8(%ebp),%edx
8010256a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010256d:	89 d1                	mov    %edx,%ecx
8010256f:	29 c1                	sub    %eax,%ecx
80102571:	89 c8                	mov    %ecx,%eax
80102573:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102576:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010257a:	7e 1c                	jle    80102598 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
8010257c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102583:	00 
80102584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102587:	89 44 24 04          	mov    %eax,0x4(%esp)
8010258b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010258e:	89 04 24             	mov    %eax,(%esp)
80102591:	e8 ff 2e 00 00       	call   80105495 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102596:	eb 28                	jmp    801025c0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010259b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010259f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801025a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801025a9:	89 04 24             	mov    %eax,(%esp)
801025ac:	e8 e4 2e 00 00       	call   80105495 <memmove>
    name[len] = 0;
801025b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025b4:	03 45 0c             	add    0xc(%ebp),%eax
801025b7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025ba:	eb 04                	jmp    801025c0 <skipelem+0xa3>
    path++;
801025bc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025c0:	8b 45 08             	mov    0x8(%ebp),%eax
801025c3:	0f b6 00             	movzbl (%eax),%eax
801025c6:	3c 2f                	cmp    $0x2f,%al
801025c8:	74 f2                	je     801025bc <skipelem+0x9f>
    path++;
  return path;
801025ca:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025cd:	c9                   	leave  
801025ce:	c3                   	ret    

801025cf <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025cf:	55                   	push   %ebp
801025d0:	89 e5                	mov    %esp,%ebp
801025d2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025d5:	8b 45 08             	mov    0x8(%ebp),%eax
801025d8:	0f b6 00             	movzbl (%eax),%eax
801025db:	3c 2f                	cmp    $0x2f,%al
801025dd:	75 1c                	jne    801025fb <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801025df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025e6:	00 
801025e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801025ee:	e8 4d f4 ff ff       	call   80101a40 <iget>
801025f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801025f6:	e9 af 00 00 00       	jmp    801026aa <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
801025fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102601:	8b 40 68             	mov    0x68(%eax),%eax
80102604:	89 04 24             	mov    %eax,(%esp)
80102607:	e8 06 f5 ff ff       	call   80101b12 <idup>
8010260c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010260f:	e9 96 00 00 00       	jmp    801026aa <namex+0xdb>
    ilock(ip);
80102614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102617:	89 04 24             	mov    %eax,(%esp)
8010261a:	e8 25 f5 ff ff       	call   80101b44 <ilock>
    if(ip->type != T_DIR){
8010261f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102622:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102626:	66 83 f8 01          	cmp    $0x1,%ax
8010262a:	74 15                	je     80102641 <namex+0x72>
      iunlockput(ip);
8010262c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262f:	89 04 24             	mov    %eax,(%esp)
80102632:	e8 91 f7 ff ff       	call   80101dc8 <iunlockput>
      return 0;
80102637:	b8 00 00 00 00       	mov    $0x0,%eax
8010263c:	e9 a3 00 00 00       	jmp    801026e4 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102641:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102645:	74 1d                	je     80102664 <namex+0x95>
80102647:	8b 45 08             	mov    0x8(%ebp),%eax
8010264a:	0f b6 00             	movzbl (%eax),%eax
8010264d:	84 c0                	test   %al,%al
8010264f:	75 13                	jne    80102664 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102654:	89 04 24             	mov    %eax,(%esp)
80102657:	e8 36 f6 ff ff       	call   80101c92 <iunlock>
      return ip;
8010265c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010265f:	e9 80 00 00 00       	jmp    801026e4 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102664:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010266b:	00 
8010266c:	8b 45 10             	mov    0x10(%ebp),%eax
8010266f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102676:	89 04 24             	mov    %eax,(%esp)
80102679:	e8 df fc ff ff       	call   8010235d <dirlookup>
8010267e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102681:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102685:	75 12                	jne    80102699 <namex+0xca>
      iunlockput(ip);
80102687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010268a:	89 04 24             	mov    %eax,(%esp)
8010268d:	e8 36 f7 ff ff       	call   80101dc8 <iunlockput>
      return 0;
80102692:	b8 00 00 00 00       	mov    $0x0,%eax
80102697:	eb 4b                	jmp    801026e4 <namex+0x115>
    }
    iunlockput(ip);
80102699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269c:	89 04 24             	mov    %eax,(%esp)
8010269f:	e8 24 f7 ff ff       	call   80101dc8 <iunlockput>
    ip = next;
801026a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801026aa:	8b 45 10             	mov    0x10(%ebp),%eax
801026ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801026b1:	8b 45 08             	mov    0x8(%ebp),%eax
801026b4:	89 04 24             	mov    %eax,(%esp)
801026b7:	e8 61 fe ff ff       	call   8010251d <skipelem>
801026bc:	89 45 08             	mov    %eax,0x8(%ebp)
801026bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c3:	0f 85 4b ff ff ff    	jne    80102614 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801026c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026cd:	74 12                	je     801026e1 <namex+0x112>
    iput(ip);
801026cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d2:	89 04 24             	mov    %eax,(%esp)
801026d5:	e8 1d f6 ff ff       	call   80101cf7 <iput>
    return 0;
801026da:	b8 00 00 00 00       	mov    $0x0,%eax
801026df:	eb 03                	jmp    801026e4 <namex+0x115>
  }
  return ip;
801026e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026e4:	c9                   	leave  
801026e5:	c3                   	ret    

801026e6 <namei>:

struct inode*
namei(char *path)
{
801026e6:	55                   	push   %ebp
801026e7:	89 e5                	mov    %esp,%ebp
801026e9:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026ec:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801026f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026fa:	00 
801026fb:	8b 45 08             	mov    0x8(%ebp),%eax
801026fe:	89 04 24             	mov    %eax,(%esp)
80102701:	e8 c9 fe ff ff       	call   801025cf <namex>
}
80102706:	c9                   	leave  
80102707:	c3                   	ret    

80102708 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102708:	55                   	push   %ebp
80102709:	89 e5                	mov    %esp,%ebp
8010270b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010270e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102711:	89 44 24 08          	mov    %eax,0x8(%esp)
80102715:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010271c:	00 
8010271d:	8b 45 08             	mov    0x8(%ebp),%eax
80102720:	89 04 24             	mov    %eax,(%esp)
80102723:	e8 a7 fe ff ff       	call   801025cf <namex>
}
80102728:	c9                   	leave  
80102729:	c3                   	ret    
	...

8010272c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010272c:	55                   	push   %ebp
8010272d:	89 e5                	mov    %esp,%ebp
8010272f:	53                   	push   %ebx
80102730:	83 ec 14             	sub    $0x14,%esp
80102733:	8b 45 08             	mov    0x8(%ebp),%eax
80102736:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010273a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010273e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102742:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102746:	ec                   	in     (%dx),%al
80102747:	89 c3                	mov    %eax,%ebx
80102749:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010274c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102750:	83 c4 14             	add    $0x14,%esp
80102753:	5b                   	pop    %ebx
80102754:	5d                   	pop    %ebp
80102755:	c3                   	ret    

80102756 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102756:	55                   	push   %ebp
80102757:	89 e5                	mov    %esp,%ebp
80102759:	57                   	push   %edi
8010275a:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010275b:	8b 55 08             	mov    0x8(%ebp),%edx
8010275e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102761:	8b 45 10             	mov    0x10(%ebp),%eax
80102764:	89 cb                	mov    %ecx,%ebx
80102766:	89 df                	mov    %ebx,%edi
80102768:	89 c1                	mov    %eax,%ecx
8010276a:	fc                   	cld    
8010276b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010276d:	89 c8                	mov    %ecx,%eax
8010276f:	89 fb                	mov    %edi,%ebx
80102771:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102774:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102777:	5b                   	pop    %ebx
80102778:	5f                   	pop    %edi
80102779:	5d                   	pop    %ebp
8010277a:	c3                   	ret    

8010277b <outb>:

static inline void
outb(ushort port, uchar data)
{
8010277b:	55                   	push   %ebp
8010277c:	89 e5                	mov    %esp,%ebp
8010277e:	83 ec 08             	sub    $0x8,%esp
80102781:	8b 55 08             	mov    0x8(%ebp),%edx
80102784:	8b 45 0c             	mov    0xc(%ebp),%eax
80102787:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010278b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010278e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102792:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102796:	ee                   	out    %al,(%dx)
}
80102797:	c9                   	leave  
80102798:	c3                   	ret    

80102799 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102799:	55                   	push   %ebp
8010279a:	89 e5                	mov    %esp,%ebp
8010279c:	56                   	push   %esi
8010279d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010279e:	8b 55 08             	mov    0x8(%ebp),%edx
801027a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027a4:	8b 45 10             	mov    0x10(%ebp),%eax
801027a7:	89 cb                	mov    %ecx,%ebx
801027a9:	89 de                	mov    %ebx,%esi
801027ab:	89 c1                	mov    %eax,%ecx
801027ad:	fc                   	cld    
801027ae:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027b0:	89 c8                	mov    %ecx,%eax
801027b2:	89 f3                	mov    %esi,%ebx
801027b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027b7:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801027ba:	5b                   	pop    %ebx
801027bb:	5e                   	pop    %esi
801027bc:	5d                   	pop    %ebp
801027bd:	c3                   	ret    

801027be <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027be:	55                   	push   %ebp
801027bf:	89 e5                	mov    %esp,%ebp
801027c1:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801027c4:	90                   	nop
801027c5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027cc:	e8 5b ff ff ff       	call   8010272c <inb>
801027d1:	0f b6 c0             	movzbl %al,%eax
801027d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027da:	25 c0 00 00 00       	and    $0xc0,%eax
801027df:	83 f8 40             	cmp    $0x40,%eax
801027e2:	75 e1                	jne    801027c5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027e8:	74 11                	je     801027fb <idewait+0x3d>
801027ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027ed:	83 e0 21             	and    $0x21,%eax
801027f0:	85 c0                	test   %eax,%eax
801027f2:	74 07                	je     801027fb <idewait+0x3d>
    return -1;
801027f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027f9:	eb 05                	jmp    80102800 <idewait+0x42>
  return 0;
801027fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102800:	c9                   	leave  
80102801:	c3                   	ret    

80102802 <ideinit>:

void
ideinit(void)
{
80102802:	55                   	push   %ebp
80102803:	89 e5                	mov    %esp,%ebp
80102805:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102808:	c7 44 24 04 68 89 10 	movl   $0x80108968,0x4(%esp)
8010280f:	80 
80102810:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102817:	e8 36 29 00 00       	call   80105152 <initlock>
  picenable(IRQ_IDE);
8010281c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102823:	e8 75 15 00 00       	call   80103d9d <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102828:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
8010282d:	83 e8 01             	sub    $0x1,%eax
80102830:	89 44 24 04          	mov    %eax,0x4(%esp)
80102834:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010283b:	e8 12 04 00 00       	call   80102c52 <ioapicenable>
  idewait(0);
80102840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102847:	e8 72 ff ff ff       	call   801027be <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010284c:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102853:	00 
80102854:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010285b:	e8 1b ff ff ff       	call   8010277b <outb>
  for(i=0; i<1000; i++){
80102860:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102867:	eb 20                	jmp    80102889 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102869:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102870:	e8 b7 fe ff ff       	call   8010272c <inb>
80102875:	84 c0                	test   %al,%al
80102877:	74 0c                	je     80102885 <ideinit+0x83>
      havedisk1 = 1;
80102879:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102880:	00 00 00 
      break;
80102883:	eb 0d                	jmp    80102892 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102885:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102889:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102890:	7e d7                	jle    80102869 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102892:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102899:	00 
8010289a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028a1:	e8 d5 fe ff ff       	call   8010277b <outb>
}
801028a6:	c9                   	leave  
801028a7:	c3                   	ret    

801028a8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028a8:	55                   	push   %ebp
801028a9:	89 e5                	mov    %esp,%ebp
801028ab:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801028ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028b2:	75 0c                	jne    801028c0 <idestart+0x18>
    panic("idestart");
801028b4:	c7 04 24 6c 89 10 80 	movl   $0x8010896c,(%esp)
801028bb:	e8 7d dc ff ff       	call   8010053d <panic>

  idewait(0);
801028c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028c7:	e8 f2 fe ff ff       	call   801027be <idewait>
  outb(0x3f6, 0);  // generate interrupt
801028cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801028d3:	00 
801028d4:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801028db:	e8 9b fe ff ff       	call   8010277b <outb>
  outb(0x1f2, 1);  // number of sectors
801028e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801028e7:	00 
801028e8:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801028ef:	e8 87 fe ff ff       	call   8010277b <outb>
  outb(0x1f3, b->sector & 0xff);
801028f4:	8b 45 08             	mov    0x8(%ebp),%eax
801028f7:	8b 40 08             	mov    0x8(%eax),%eax
801028fa:	0f b6 c0             	movzbl %al,%eax
801028fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102901:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102908:	e8 6e fe ff ff       	call   8010277b <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010290d:	8b 45 08             	mov    0x8(%ebp),%eax
80102910:	8b 40 08             	mov    0x8(%eax),%eax
80102913:	c1 e8 08             	shr    $0x8,%eax
80102916:	0f b6 c0             	movzbl %al,%eax
80102919:	89 44 24 04          	mov    %eax,0x4(%esp)
8010291d:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102924:	e8 52 fe ff ff       	call   8010277b <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102929:	8b 45 08             	mov    0x8(%ebp),%eax
8010292c:	8b 40 08             	mov    0x8(%eax),%eax
8010292f:	c1 e8 10             	shr    $0x10,%eax
80102932:	0f b6 c0             	movzbl %al,%eax
80102935:	89 44 24 04          	mov    %eax,0x4(%esp)
80102939:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102940:	e8 36 fe ff ff       	call   8010277b <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102945:	8b 45 08             	mov    0x8(%ebp),%eax
80102948:	8b 40 04             	mov    0x4(%eax),%eax
8010294b:	83 e0 01             	and    $0x1,%eax
8010294e:	89 c2                	mov    %eax,%edx
80102950:	c1 e2 04             	shl    $0x4,%edx
80102953:	8b 45 08             	mov    0x8(%ebp),%eax
80102956:	8b 40 08             	mov    0x8(%eax),%eax
80102959:	c1 e8 18             	shr    $0x18,%eax
8010295c:	83 e0 0f             	and    $0xf,%eax
8010295f:	09 d0                	or     %edx,%eax
80102961:	83 c8 e0             	or     $0xffffffe0,%eax
80102964:	0f b6 c0             	movzbl %al,%eax
80102967:	89 44 24 04          	mov    %eax,0x4(%esp)
8010296b:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102972:	e8 04 fe ff ff       	call   8010277b <outb>
  if(b->flags & B_DIRTY){
80102977:	8b 45 08             	mov    0x8(%ebp),%eax
8010297a:	8b 00                	mov    (%eax),%eax
8010297c:	83 e0 04             	and    $0x4,%eax
8010297f:	85 c0                	test   %eax,%eax
80102981:	74 34                	je     801029b7 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102983:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010298a:	00 
8010298b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102992:	e8 e4 fd ff ff       	call   8010277b <outb>
    outsl(0x1f0, b->data, 512/4);
80102997:	8b 45 08             	mov    0x8(%ebp),%eax
8010299a:	83 c0 18             	add    $0x18,%eax
8010299d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801029a4:	00 
801029a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029a9:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801029b0:	e8 e4 fd ff ff       	call   80102799 <outsl>
801029b5:	eb 14                	jmp    801029cb <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801029b7:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801029be:	00 
801029bf:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801029c6:	e8 b0 fd ff ff       	call   8010277b <outb>
  }
}
801029cb:	c9                   	leave  
801029cc:	c3                   	ret    

801029cd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029cd:	55                   	push   %ebp
801029ce:	89 e5                	mov    %esp,%ebp
801029d0:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029d3:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801029da:	e8 94 27 00 00       	call   80105173 <acquire>
  if((b = idequeue) == 0){
801029df:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801029e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029eb:	75 11                	jne    801029fe <ideintr+0x31>
    release(&idelock);
801029ed:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801029f4:	e8 dc 27 00 00       	call   801051d5 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801029f9:	e9 90 00 00 00       	jmp    80102a8e <ideintr+0xc1>
  }
  idequeue = b->qnext;
801029fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a01:	8b 40 14             	mov    0x14(%eax),%eax
80102a04:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0c:	8b 00                	mov    (%eax),%eax
80102a0e:	83 e0 04             	and    $0x4,%eax
80102a11:	85 c0                	test   %eax,%eax
80102a13:	75 2e                	jne    80102a43 <ideintr+0x76>
80102a15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a1c:	e8 9d fd ff ff       	call   801027be <idewait>
80102a21:	85 c0                	test   %eax,%eax
80102a23:	78 1e                	js     80102a43 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a28:	83 c0 18             	add    $0x18,%eax
80102a2b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a32:	00 
80102a33:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a37:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a3e:	e8 13 fd ff ff       	call   80102756 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a46:	8b 00                	mov    (%eax),%eax
80102a48:	89 c2                	mov    %eax,%edx
80102a4a:	83 ca 02             	or     $0x2,%edx
80102a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a50:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a55:	8b 00                	mov    (%eax),%eax
80102a57:	89 c2                	mov    %eax,%edx
80102a59:	83 e2 fb             	and    $0xfffffffb,%edx
80102a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a64:	89 04 24             	mov    %eax,(%esp)
80102a67:	e8 7a 24 00 00       	call   80104ee6 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a6c:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a71:	85 c0                	test   %eax,%eax
80102a73:	74 0d                	je     80102a82 <ideintr+0xb5>
    idestart(idequeue);
80102a75:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a7a:	89 04 24             	mov    %eax,(%esp)
80102a7d:	e8 26 fe ff ff       	call   801028a8 <idestart>

  release(&idelock);
80102a82:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a89:	e8 47 27 00 00       	call   801051d5 <release>
}
80102a8e:	c9                   	leave  
80102a8f:	c3                   	ret    

80102a90 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a90:	55                   	push   %ebp
80102a91:	89 e5                	mov    %esp,%ebp
80102a93:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102a96:	8b 45 08             	mov    0x8(%ebp),%eax
80102a99:	8b 00                	mov    (%eax),%eax
80102a9b:	83 e0 01             	and    $0x1,%eax
80102a9e:	85 c0                	test   %eax,%eax
80102aa0:	75 0c                	jne    80102aae <iderw+0x1e>
    panic("iderw: buf not busy");
80102aa2:	c7 04 24 75 89 10 80 	movl   $0x80108975,(%esp)
80102aa9:	e8 8f da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102aae:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab1:	8b 00                	mov    (%eax),%eax
80102ab3:	83 e0 06             	and    $0x6,%eax
80102ab6:	83 f8 02             	cmp    $0x2,%eax
80102ab9:	75 0c                	jne    80102ac7 <iderw+0x37>
    panic("iderw: nothing to do");
80102abb:	c7 04 24 89 89 10 80 	movl   $0x80108989,(%esp)
80102ac2:	e8 76 da ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80102aca:	8b 40 04             	mov    0x4(%eax),%eax
80102acd:	85 c0                	test   %eax,%eax
80102acf:	74 15                	je     80102ae6 <iderw+0x56>
80102ad1:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102ad6:	85 c0                	test   %eax,%eax
80102ad8:	75 0c                	jne    80102ae6 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102ada:	c7 04 24 9e 89 10 80 	movl   $0x8010899e,(%esp)
80102ae1:	e8 57 da ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102ae6:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102aed:	e8 81 26 00 00       	call   80105173 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102af2:	8b 45 08             	mov    0x8(%ebp),%eax
80102af5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102afc:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b03:	eb 0b                	jmp    80102b10 <iderw+0x80>
80102b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b08:	8b 00                	mov    (%eax),%eax
80102b0a:	83 c0 14             	add    $0x14,%eax
80102b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b13:	8b 00                	mov    (%eax),%eax
80102b15:	85 c0                	test   %eax,%eax
80102b17:	75 ec                	jne    80102b05 <iderw+0x75>
    ;
  *pp = b;
80102b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1c:	8b 55 08             	mov    0x8(%ebp),%edx
80102b1f:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b21:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b26:	3b 45 08             	cmp    0x8(%ebp),%eax
80102b29:	75 22                	jne    80102b4d <iderw+0xbd>
    idestart(b);
80102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2e:	89 04 24             	mov    %eax,(%esp)
80102b31:	e8 72 fd ff ff       	call   801028a8 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b36:	eb 15                	jmp    80102b4d <iderw+0xbd>
    sleep(b, &idelock);
80102b38:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102b3f:	80 
80102b40:	8b 45 08             	mov    0x8(%ebp),%eax
80102b43:	89 04 24             	mov    %eax,(%esp)
80102b46:	e8 bf 22 00 00       	call   80104e0a <sleep>
80102b4b:	eb 01                	jmp    80102b4e <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b4d:	90                   	nop
80102b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b51:	8b 00                	mov    (%eax),%eax
80102b53:	83 e0 06             	and    $0x6,%eax
80102b56:	83 f8 02             	cmp    $0x2,%eax
80102b59:	75 dd                	jne    80102b38 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102b5b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b62:	e8 6e 26 00 00       	call   801051d5 <release>
}
80102b67:	c9                   	leave  
80102b68:	c3                   	ret    
80102b69:	00 00                	add    %al,(%eax)
	...

80102b6c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b6c:	55                   	push   %ebp
80102b6d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b6f:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b74:	8b 55 08             	mov    0x8(%ebp),%edx
80102b77:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b79:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b7e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b81:	5d                   	pop    %ebp
80102b82:	c3                   	ret    

80102b83 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b83:	55                   	push   %ebp
80102b84:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b86:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b8b:	8b 55 08             	mov    0x8(%ebp),%edx
80102b8e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b90:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b95:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b98:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b9b:	5d                   	pop    %ebp
80102b9c:	c3                   	ret    

80102b9d <ioapicinit>:

void
ioapicinit(void)
{
80102b9d:	55                   	push   %ebp
80102b9e:	89 e5                	mov    %esp,%ebp
80102ba0:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102ba3:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102ba8:	85 c0                	test   %eax,%eax
80102baa:	0f 84 9f 00 00 00    	je     80102c4f <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bb0:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102bb7:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102bc1:	e8 a6 ff ff ff       	call   80102b6c <ioapicread>
80102bc6:	c1 e8 10             	shr    $0x10,%eax
80102bc9:	25 ff 00 00 00       	and    $0xff,%eax
80102bce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102bd8:	e8 8f ff ff ff       	call   80102b6c <ioapicread>
80102bdd:	c1 e8 18             	shr    $0x18,%eax
80102be0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102be3:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102bea:	0f b6 c0             	movzbl %al,%eax
80102bed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102bf0:	74 0c                	je     80102bfe <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102bf2:	c7 04 24 bc 89 10 80 	movl   $0x801089bc,(%esp)
80102bf9:	e8 a3 d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c05:	eb 3e                	jmp    80102c45 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c0a:	83 c0 20             	add    $0x20,%eax
80102c0d:	0d 00 00 01 00       	or     $0x10000,%eax
80102c12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c15:	83 c2 08             	add    $0x8,%edx
80102c18:	01 d2                	add    %edx,%edx
80102c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c1e:	89 14 24             	mov    %edx,(%esp)
80102c21:	e8 5d ff ff ff       	call   80102b83 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c29:	83 c0 08             	add    $0x8,%eax
80102c2c:	01 c0                	add    %eax,%eax
80102c2e:	83 c0 01             	add    $0x1,%eax
80102c31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102c38:	00 
80102c39:	89 04 24             	mov    %eax,(%esp)
80102c3c:	e8 42 ff ff ff       	call   80102b83 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c48:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c4b:	7e ba                	jle    80102c07 <ioapicinit+0x6a>
80102c4d:	eb 01                	jmp    80102c50 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102c4f:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102c50:	c9                   	leave  
80102c51:	c3                   	ret    

80102c52 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
80102c55:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102c58:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102c5d:	85 c0                	test   %eax,%eax
80102c5f:	74 39                	je     80102c9a <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c61:	8b 45 08             	mov    0x8(%ebp),%eax
80102c64:	83 c0 20             	add    $0x20,%eax
80102c67:	8b 55 08             	mov    0x8(%ebp),%edx
80102c6a:	83 c2 08             	add    $0x8,%edx
80102c6d:	01 d2                	add    %edx,%edx
80102c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c73:	89 14 24             	mov    %edx,(%esp)
80102c76:	e8 08 ff ff ff       	call   80102b83 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c7e:	c1 e0 18             	shl    $0x18,%eax
80102c81:	8b 55 08             	mov    0x8(%ebp),%edx
80102c84:	83 c2 08             	add    $0x8,%edx
80102c87:	01 d2                	add    %edx,%edx
80102c89:	83 c2 01             	add    $0x1,%edx
80102c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c90:	89 14 24             	mov    %edx,(%esp)
80102c93:	e8 eb fe ff ff       	call   80102b83 <ioapicwrite>
80102c98:	eb 01                	jmp    80102c9b <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102c9a:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102c9b:	c9                   	leave  
80102c9c:	c3                   	ret    
80102c9d:	00 00                	add    %al,(%eax)
	...

80102ca0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
80102ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca6:	05 00 00 00 80       	add    $0x80000000,%eax
80102cab:	5d                   	pop    %ebp
80102cac:	c3                   	ret    

80102cad <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cad:	55                   	push   %ebp
80102cae:	89 e5                	mov    %esp,%ebp
80102cb0:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102cb3:	c7 44 24 04 ee 89 10 	movl   $0x801089ee,0x4(%esp)
80102cba:	80 
80102cbb:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102cc2:	e8 8b 24 00 00       	call   80105152 <initlock>
  kmem.use_lock = 0;
80102cc7:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102cce:	00 00 00 
  freerange(vstart, vend);
80102cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80102cdb:	89 04 24             	mov    %eax,(%esp)
80102cde:	e8 26 00 00 00       	call   80102d09 <freerange>
}
80102ce3:	c9                   	leave  
80102ce4:	c3                   	ret    

80102ce5 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ce5:	55                   	push   %ebp
80102ce6:	89 e5                	mov    %esp,%ebp
80102ce8:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cee:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf5:	89 04 24             	mov    %eax,(%esp)
80102cf8:	e8 0c 00 00 00       	call   80102d09 <freerange>
  kmem.use_lock = 1;
80102cfd:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d04:	00 00 00 
}
80102d07:	c9                   	leave  
80102d08:	c3                   	ret    

80102d09 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d09:	55                   	push   %ebp
80102d0a:	89 e5                	mov    %esp,%ebp
80102d0c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d12:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d1f:	eb 12                	jmp    80102d33 <freerange+0x2a>
    kfree(p);
80102d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d24:	89 04 24             	mov    %eax,(%esp)
80102d27:	e8 16 00 00 00       	call   80102d42 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d36:	05 00 10 00 00       	add    $0x1000,%eax
80102d3b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102d3e:	76 e1                	jbe    80102d21 <freerange+0x18>
    kfree(p);
}
80102d40:	c9                   	leave  
80102d41:	c3                   	ret    

80102d42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d42:	55                   	push   %ebp
80102d43:	89 e5                	mov    %esp,%ebp
80102d45:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102d48:	8b 45 08             	mov    0x8(%ebp),%eax
80102d4b:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d50:	85 c0                	test   %eax,%eax
80102d52:	75 1b                	jne    80102d6f <kfree+0x2d>
80102d54:	81 7d 08 1c 2d 11 80 	cmpl   $0x80112d1c,0x8(%ebp)
80102d5b:	72 12                	jb     80102d6f <kfree+0x2d>
80102d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d60:	89 04 24             	mov    %eax,(%esp)
80102d63:	e8 38 ff ff ff       	call   80102ca0 <v2p>
80102d68:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d6d:	76 0c                	jbe    80102d7b <kfree+0x39>
    panic("kfree");
80102d6f:	c7 04 24 f3 89 10 80 	movl   $0x801089f3,(%esp)
80102d76:	e8 c2 d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d7b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102d82:	00 
80102d83:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102d8a:	00 
80102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8e:	89 04 24             	mov    %eax,(%esp)
80102d91:	e8 2c 26 00 00       	call   801053c2 <memset>

  if(kmem.use_lock)
80102d96:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102d9b:	85 c0                	test   %eax,%eax
80102d9d:	74 0c                	je     80102dab <kfree+0x69>
    acquire(&kmem.lock);
80102d9f:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102da6:	e8 c8 23 00 00       	call   80105173 <acquire>
  r = (struct run*)v;
80102dab:	8b 45 08             	mov    0x8(%ebp),%eax
80102dae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102db1:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dba:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dbf:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102dc4:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102dc9:	85 c0                	test   %eax,%eax
80102dcb:	74 0c                	je     80102dd9 <kfree+0x97>
    release(&kmem.lock);
80102dcd:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102dd4:	e8 fc 23 00 00       	call   801051d5 <release>
}
80102dd9:	c9                   	leave  
80102dda:	c3                   	ret    

80102ddb <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ddb:	55                   	push   %ebp
80102ddc:	89 e5                	mov    %esp,%ebp
80102dde:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102de1:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102de6:	85 c0                	test   %eax,%eax
80102de8:	74 0c                	je     80102df6 <kalloc+0x1b>
    acquire(&kmem.lock);
80102dea:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102df1:	e8 7d 23 00 00       	call   80105173 <acquire>
  r = kmem.freelist;
80102df6:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102dfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102dfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e02:	74 0a                	je     80102e0e <kalloc+0x33>
    kmem.freelist = r->next;
80102e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e07:	8b 00                	mov    (%eax),%eax
80102e09:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e0e:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e13:	85 c0                	test   %eax,%eax
80102e15:	74 0c                	je     80102e23 <kalloc+0x48>
    release(&kmem.lock);
80102e17:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e1e:	e8 b2 23 00 00       	call   801051d5 <release>
  return (char*)r;
80102e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e26:	c9                   	leave  
80102e27:	c3                   	ret    

80102e28 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e28:	55                   	push   %ebp
80102e29:	89 e5                	mov    %esp,%ebp
80102e2b:	53                   	push   %ebx
80102e2c:	83 ec 14             	sub    $0x14,%esp
80102e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e32:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e36:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102e3a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102e3e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102e42:	ec                   	in     (%dx),%al
80102e43:	89 c3                	mov    %eax,%ebx
80102e45:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102e48:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102e4c:	83 c4 14             	add    $0x14,%esp
80102e4f:	5b                   	pop    %ebx
80102e50:	5d                   	pop    %ebp
80102e51:	c3                   	ret    

80102e52 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e52:	55                   	push   %ebp
80102e53:	89 e5                	mov    %esp,%ebp
80102e55:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e58:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102e5f:	e8 c4 ff ff ff       	call   80102e28 <inb>
80102e64:	0f b6 c0             	movzbl %al,%eax
80102e67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e6d:	83 e0 01             	and    $0x1,%eax
80102e70:	85 c0                	test   %eax,%eax
80102e72:	75 0a                	jne    80102e7e <kbdgetc+0x2c>
    return -1;
80102e74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e79:	e9 23 01 00 00       	jmp    80102fa1 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102e7e:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102e85:	e8 9e ff ff ff       	call   80102e28 <inb>
80102e8a:	0f b6 c0             	movzbl %al,%eax
80102e8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102e90:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e97:	75 17                	jne    80102eb0 <kbdgetc+0x5e>
    shift |= E0ESC;
80102e99:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e9e:	83 c8 40             	or     $0x40,%eax
80102ea1:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ea6:	b8 00 00 00 00       	mov    $0x0,%eax
80102eab:	e9 f1 00 00 00       	jmp    80102fa1 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102eb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eb3:	25 80 00 00 00       	and    $0x80,%eax
80102eb8:	85 c0                	test   %eax,%eax
80102eba:	74 45                	je     80102f01 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ebc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ec1:	83 e0 40             	and    $0x40,%eax
80102ec4:	85 c0                	test   %eax,%eax
80102ec6:	75 08                	jne    80102ed0 <kbdgetc+0x7e>
80102ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ecb:	83 e0 7f             	and    $0x7f,%eax
80102ece:	eb 03                	jmp    80102ed3 <kbdgetc+0x81>
80102ed0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ed6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed9:	05 20 90 10 80       	add    $0x80109020,%eax
80102ede:	0f b6 00             	movzbl (%eax),%eax
80102ee1:	83 c8 40             	or     $0x40,%eax
80102ee4:	0f b6 c0             	movzbl %al,%eax
80102ee7:	f7 d0                	not    %eax
80102ee9:	89 c2                	mov    %eax,%edx
80102eeb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ef0:	21 d0                	and    %edx,%eax
80102ef2:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ef7:	b8 00 00 00 00       	mov    $0x0,%eax
80102efc:	e9 a0 00 00 00       	jmp    80102fa1 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f01:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f06:	83 e0 40             	and    $0x40,%eax
80102f09:	85 c0                	test   %eax,%eax
80102f0b:	74 14                	je     80102f21 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f0d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f14:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f19:	83 e0 bf             	and    $0xffffffbf,%eax
80102f1c:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f21:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f24:	05 20 90 10 80       	add    $0x80109020,%eax
80102f29:	0f b6 00             	movzbl (%eax),%eax
80102f2c:	0f b6 d0             	movzbl %al,%edx
80102f2f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f34:	09 d0                	or     %edx,%eax
80102f36:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102f3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f3e:	05 20 91 10 80       	add    $0x80109120,%eax
80102f43:	0f b6 00             	movzbl (%eax),%eax
80102f46:	0f b6 d0             	movzbl %al,%edx
80102f49:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f4e:	31 d0                	xor    %edx,%eax
80102f50:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f55:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f5a:	83 e0 03             	and    $0x3,%eax
80102f5d:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102f64:	03 45 fc             	add    -0x4(%ebp),%eax
80102f67:	0f b6 00             	movzbl (%eax),%eax
80102f6a:	0f b6 c0             	movzbl %al,%eax
80102f6d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f70:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f75:	83 e0 08             	and    $0x8,%eax
80102f78:	85 c0                	test   %eax,%eax
80102f7a:	74 22                	je     80102f9e <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102f7c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f80:	76 0c                	jbe    80102f8e <kbdgetc+0x13c>
80102f82:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f86:	77 06                	ja     80102f8e <kbdgetc+0x13c>
      c += 'A' - 'a';
80102f88:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f8c:	eb 10                	jmp    80102f9e <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102f8e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f92:	76 0a                	jbe    80102f9e <kbdgetc+0x14c>
80102f94:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f98:	77 04                	ja     80102f9e <kbdgetc+0x14c>
      c += 'a' - 'A';
80102f9a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fa1:	c9                   	leave  
80102fa2:	c3                   	ret    

80102fa3 <kbdintr>:

void
kbdintr(void)
{
80102fa3:	55                   	push   %ebp
80102fa4:	89 e5                	mov    %esp,%ebp
80102fa6:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102fa9:	c7 04 24 52 2e 10 80 	movl   $0x80102e52,(%esp)
80102fb0:	e8 7a d9 ff ff       	call   8010092f <consoleintr>
}
80102fb5:	c9                   	leave  
80102fb6:	c3                   	ret    
	...

80102fb8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102fb8:	55                   	push   %ebp
80102fb9:	89 e5                	mov    %esp,%ebp
80102fbb:	83 ec 08             	sub    $0x8,%esp
80102fbe:	8b 55 08             	mov    0x8(%ebp),%edx
80102fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102fc8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fcb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102fcf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102fd3:	ee                   	out    %al,(%dx)
}
80102fd4:	c9                   	leave  
80102fd5:	c3                   	ret    

80102fd6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102fd6:	55                   	push   %ebp
80102fd7:	89 e5                	mov    %esp,%ebp
80102fd9:	53                   	push   %ebx
80102fda:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102fdd:	9c                   	pushf  
80102fde:	5b                   	pop    %ebx
80102fdf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102fe2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fe5:	83 c4 10             	add    $0x10,%esp
80102fe8:	5b                   	pop    %ebx
80102fe9:	5d                   	pop    %ebp
80102fea:	c3                   	ret    

80102feb <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102feb:	55                   	push   %ebp
80102fec:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fee:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102ff3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ff6:	c1 e2 02             	shl    $0x2,%edx
80102ff9:	01 c2                	add    %eax,%edx
80102ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ffe:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103000:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103005:	83 c0 20             	add    $0x20,%eax
80103008:	8b 00                	mov    (%eax),%eax
}
8010300a:	5d                   	pop    %ebp
8010300b:	c3                   	ret    

8010300c <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
8010300c:	55                   	push   %ebp
8010300d:	89 e5                	mov    %esp,%ebp
8010300f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103012:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103017:	85 c0                	test   %eax,%eax
80103019:	0f 84 47 01 00 00    	je     80103166 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010301f:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103026:	00 
80103027:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010302e:	e8 b8 ff ff ff       	call   80102feb <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103033:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010303a:	00 
8010303b:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103042:	e8 a4 ff ff ff       	call   80102feb <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103047:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010304e:	00 
8010304f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103056:	e8 90 ff ff ff       	call   80102feb <lapicw>
  lapicw(TICR, 10000000); 
8010305b:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103062:	00 
80103063:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010306a:	e8 7c ff ff ff       	call   80102feb <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010306f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103076:	00 
80103077:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010307e:	e8 68 ff ff ff       	call   80102feb <lapicw>
  lapicw(LINT1, MASKED);
80103083:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010308a:	00 
8010308b:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103092:	e8 54 ff ff ff       	call   80102feb <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103097:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010309c:	83 c0 30             	add    $0x30,%eax
8010309f:	8b 00                	mov    (%eax),%eax
801030a1:	c1 e8 10             	shr    $0x10,%eax
801030a4:	25 ff 00 00 00       	and    $0xff,%eax
801030a9:	83 f8 03             	cmp    $0x3,%eax
801030ac:	76 14                	jbe    801030c2 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801030ae:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030b5:	00 
801030b6:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801030bd:	e8 29 ff ff ff       	call   80102feb <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030c2:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801030c9:	00 
801030ca:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801030d1:	e8 15 ff ff ff       	call   80102feb <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030dd:	00 
801030de:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030e5:	e8 01 ff ff ff       	call   80102feb <lapicw>
  lapicw(ESR, 0);
801030ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030f1:	00 
801030f2:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030f9:	e8 ed fe ff ff       	call   80102feb <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103105:	00 
80103106:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010310d:	e8 d9 fe ff ff       	call   80102feb <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103112:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103119:	00 
8010311a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103121:	e8 c5 fe ff ff       	call   80102feb <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103126:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
8010312d:	00 
8010312e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103135:	e8 b1 fe ff ff       	call   80102feb <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010313a:	90                   	nop
8010313b:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103140:	05 00 03 00 00       	add    $0x300,%eax
80103145:	8b 00                	mov    (%eax),%eax
80103147:	25 00 10 00 00       	and    $0x1000,%eax
8010314c:	85 c0                	test   %eax,%eax
8010314e:	75 eb                	jne    8010313b <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103150:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103157:	00 
80103158:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010315f:	e8 87 fe ff ff       	call   80102feb <lapicw>
80103164:	eb 01                	jmp    80103167 <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
80103166:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80103167:	c9                   	leave  
80103168:	c3                   	ret    

80103169 <cpunum>:

int
cpunum(void)
{
80103169:	55                   	push   %ebp
8010316a:	89 e5                	mov    %esp,%ebp
8010316c:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010316f:	e8 62 fe ff ff       	call   80102fd6 <readeflags>
80103174:	25 00 02 00 00       	and    $0x200,%eax
80103179:	85 c0                	test   %eax,%eax
8010317b:	74 29                	je     801031a6 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
8010317d:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80103182:	85 c0                	test   %eax,%eax
80103184:	0f 94 c2             	sete   %dl
80103187:	83 c0 01             	add    $0x1,%eax
8010318a:	a3 40 b6 10 80       	mov    %eax,0x8010b640
8010318f:	84 d2                	test   %dl,%dl
80103191:	74 13                	je     801031a6 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80103193:	8b 45 04             	mov    0x4(%ebp),%eax
80103196:	89 44 24 04          	mov    %eax,0x4(%esp)
8010319a:	c7 04 24 fc 89 10 80 	movl   $0x801089fc,(%esp)
801031a1:	e8 fb d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801031a6:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031ab:	85 c0                	test   %eax,%eax
801031ad:	74 0f                	je     801031be <cpunum+0x55>
    return lapic[ID]>>24;
801031af:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031b4:	83 c0 20             	add    $0x20,%eax
801031b7:	8b 00                	mov    (%eax),%eax
801031b9:	c1 e8 18             	shr    $0x18,%eax
801031bc:	eb 05                	jmp    801031c3 <cpunum+0x5a>
  return 0;
801031be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801031c3:	c9                   	leave  
801031c4:	c3                   	ret    

801031c5 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031c5:	55                   	push   %ebp
801031c6:	89 e5                	mov    %esp,%ebp
801031c8:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801031cb:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031d0:	85 c0                	test   %eax,%eax
801031d2:	74 14                	je     801031e8 <lapiceoi+0x23>
    lapicw(EOI, 0);
801031d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031db:	00 
801031dc:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801031e3:	e8 03 fe ff ff       	call   80102feb <lapicw>
}
801031e8:	c9                   	leave  
801031e9:	c3                   	ret    

801031ea <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031ea:	55                   	push   %ebp
801031eb:	89 e5                	mov    %esp,%ebp
}
801031ed:	5d                   	pop    %ebp
801031ee:	c3                   	ret    

801031ef <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031ef:	55                   	push   %ebp
801031f0:	89 e5                	mov    %esp,%ebp
801031f2:	83 ec 1c             	sub    $0x1c,%esp
801031f5:	8b 45 08             	mov    0x8(%ebp),%eax
801031f8:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
801031fb:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103202:	00 
80103203:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010320a:	e8 a9 fd ff ff       	call   80102fb8 <outb>
  outb(IO_RTC+1, 0x0A);
8010320f:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103216:	00 
80103217:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010321e:	e8 95 fd ff ff       	call   80102fb8 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103223:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010322a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010322d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103232:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103235:	8d 50 02             	lea    0x2(%eax),%edx
80103238:	8b 45 0c             	mov    0xc(%ebp),%eax
8010323b:	c1 e8 04             	shr    $0x4,%eax
8010323e:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103241:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103245:	c1 e0 18             	shl    $0x18,%eax
80103248:	89 44 24 04          	mov    %eax,0x4(%esp)
8010324c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103253:	e8 93 fd ff ff       	call   80102feb <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103258:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
8010325f:	00 
80103260:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103267:	e8 7f fd ff ff       	call   80102feb <lapicw>
  microdelay(200);
8010326c:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103273:	e8 72 ff ff ff       	call   801031ea <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103278:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010327f:	00 
80103280:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103287:	e8 5f fd ff ff       	call   80102feb <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010328c:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103293:	e8 52 ff ff ff       	call   801031ea <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103298:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010329f:	eb 40                	jmp    801032e1 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801032a1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032a5:	c1 e0 18             	shl    $0x18,%eax
801032a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801032ac:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032b3:	e8 33 fd ff ff       	call   80102feb <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801032b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801032bb:	c1 e8 0c             	shr    $0xc,%eax
801032be:	80 cc 06             	or     $0x6,%ah
801032c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801032c5:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032cc:	e8 1a fd ff ff       	call   80102feb <lapicw>
    microdelay(200);
801032d1:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032d8:	e8 0d ff ff ff       	call   801031ea <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032dd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801032e1:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032e5:	7e ba                	jle    801032a1 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801032e7:	c9                   	leave  
801032e8:	c3                   	ret    
801032e9:	00 00                	add    %al,(%eax)
	...

801032ec <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
801032ec:	55                   	push   %ebp
801032ed:	89 e5                	mov    %esp,%ebp
801032ef:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032f2:	c7 44 24 04 28 8a 10 	movl   $0x80108a28,0x4(%esp)
801032f9:	80 
801032fa:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103301:	e8 4c 1e 00 00       	call   80105152 <initlock>
  readsb(ROOTDEV, &sb);
80103306:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103309:	89 44 24 04          	mov    %eax,0x4(%esp)
8010330d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103314:	e8 af e2 ff ff       	call   801015c8 <readsb>
  log.start = sb.size - sb.nlog;
80103319:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010331c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331f:	89 d1                	mov    %edx,%ecx
80103321:	29 c1                	sub    %eax,%ecx
80103323:	89 c8                	mov    %ecx,%eax
80103325:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
8010332a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010332d:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
80103332:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
80103339:	00 00 00 
  recover_from_log();
8010333c:	e8 97 01 00 00       	call   801034d8 <recover_from_log>
}
80103341:	c9                   	leave  
80103342:	c3                   	ret    

80103343 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103343:	55                   	push   %ebp
80103344:	89 e5                	mov    %esp,%ebp
80103346:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103350:	e9 89 00 00 00       	jmp    801033de <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103355:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010335a:	03 45 f4             	add    -0xc(%ebp),%eax
8010335d:	83 c0 01             	add    $0x1,%eax
80103360:	89 c2                	mov    %eax,%edx
80103362:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103367:	89 54 24 04          	mov    %edx,0x4(%esp)
8010336b:	89 04 24             	mov    %eax,(%esp)
8010336e:	e8 33 ce ff ff       	call   801001a6 <bread>
80103373:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103379:	83 c0 10             	add    $0x10,%eax
8010337c:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
80103383:	89 c2                	mov    %eax,%edx
80103385:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010338a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010338e:	89 04 24             	mov    %eax,(%esp)
80103391:	e8 10 ce ff ff       	call   801001a6 <bread>
80103396:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010339c:	8d 50 18             	lea    0x18(%eax),%edx
8010339f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a2:	83 c0 18             	add    $0x18,%eax
801033a5:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033ac:	00 
801033ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801033b1:	89 04 24             	mov    %eax,(%esp)
801033b4:	e8 dc 20 00 00       	call   80105495 <memmove>
    bwrite(dbuf);  // write dst to disk
801033b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033bc:	89 04 24             	mov    %eax,(%esp)
801033bf:	e8 19 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801033c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033c7:	89 04 24             	mov    %eax,(%esp)
801033ca:	e8 48 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801033cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d2:	89 04 24             	mov    %eax,(%esp)
801033d5:	e8 3d ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033de:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801033e3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033e6:	0f 8f 69 ff ff ff    	jg     80103355 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033ec:	c9                   	leave  
801033ed:	c3                   	ret    

801033ee <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033ee:	55                   	push   %ebp
801033ef:	89 e5                	mov    %esp,%ebp
801033f1:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033f4:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801033f9:	89 c2                	mov    %eax,%edx
801033fb:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103400:	89 54 24 04          	mov    %edx,0x4(%esp)
80103404:	89 04 24             	mov    %eax,(%esp)
80103407:	e8 9a cd ff ff       	call   801001a6 <bread>
8010340c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010340f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103412:	83 c0 18             	add    $0x18,%eax
80103415:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103418:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341b:	8b 00                	mov    (%eax),%eax
8010341d:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
80103422:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103429:	eb 1b                	jmp    80103446 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010342b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103431:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103435:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103438:	83 c2 10             	add    $0x10,%edx
8010343b:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103442:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103446:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010344b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010344e:	7f db                	jg     8010342b <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103453:	89 04 24             	mov    %eax,(%esp)
80103456:	e8 bc cd ff ff       	call   80100217 <brelse>
}
8010345b:	c9                   	leave  
8010345c:	c3                   	ret    

8010345d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010345d:	55                   	push   %ebp
8010345e:	89 e5                	mov    %esp,%ebp
80103460:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103463:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103468:	89 c2                	mov    %eax,%edx
8010346a:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010346f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103473:	89 04 24             	mov    %eax,(%esp)
80103476:	e8 2b cd ff ff       	call   801001a6 <bread>
8010347b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010347e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103481:	83 c0 18             	add    $0x18,%eax
80103484:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103487:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
8010348d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103490:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103492:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103499:	eb 1b                	jmp    801034b6 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
8010349b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010349e:	83 c0 10             	add    $0x10,%eax
801034a1:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
801034a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034ae:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034b6:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034bb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034be:	7f db                	jg     8010349b <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801034c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c3:	89 04 24             	mov    %eax,(%esp)
801034c6:	e8 12 cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801034cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ce:	89 04 24             	mov    %eax,(%esp)
801034d1:	e8 41 cd ff ff       	call   80100217 <brelse>
}
801034d6:	c9                   	leave  
801034d7:	c3                   	ret    

801034d8 <recover_from_log>:

static void
recover_from_log(void)
{
801034d8:	55                   	push   %ebp
801034d9:	89 e5                	mov    %esp,%ebp
801034db:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034de:	e8 0b ff ff ff       	call   801033ee <read_head>
  install_trans(); // if committed, copy from log to disk
801034e3:	e8 5b fe ff ff       	call   80103343 <install_trans>
  log.lh.n = 0;
801034e8:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801034ef:	00 00 00 
  write_head(); // clear the log
801034f2:	e8 66 ff ff ff       	call   8010345d <write_head>
}
801034f7:	c9                   	leave  
801034f8:	c3                   	ret    

801034f9 <begin_trans>:

void
begin_trans(void)
{
801034f9:	55                   	push   %ebp
801034fa:	89 e5                	mov    %esp,%ebp
801034fc:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034ff:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103506:	e8 68 1c 00 00       	call   80105173 <acquire>
  while (log.busy) {
8010350b:	eb 14                	jmp    80103521 <begin_trans+0x28>
    sleep(&log, &log.lock);
8010350d:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
80103514:	80 
80103515:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010351c:	e8 e9 18 00 00       	call   80104e0a <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103521:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103526:	85 c0                	test   %eax,%eax
80103528:	75 e3                	jne    8010350d <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
8010352a:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
80103531:	00 00 00 
  release(&log.lock);
80103534:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010353b:	e8 95 1c 00 00       	call   801051d5 <release>
}
80103540:	c9                   	leave  
80103541:	c3                   	ret    

80103542 <commit_trans>:

void
commit_trans(void)
{
80103542:	55                   	push   %ebp
80103543:	89 e5                	mov    %esp,%ebp
80103545:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103548:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010354d:	85 c0                	test   %eax,%eax
8010354f:	7e 19                	jle    8010356a <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103551:	e8 07 ff ff ff       	call   8010345d <write_head>
    install_trans(); // Now install writes to home locations
80103556:	e8 e8 fd ff ff       	call   80103343 <install_trans>
    log.lh.n = 0; 
8010355b:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103562:	00 00 00 
    write_head();    // Erase the transaction from the log
80103565:	e8 f3 fe ff ff       	call   8010345d <write_head>
  }
  
  acquire(&log.lock);
8010356a:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103571:	e8 fd 1b 00 00       	call   80105173 <acquire>
  log.busy = 0;
80103576:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
8010357d:	00 00 00 
  wakeup(&log);
80103580:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103587:	e8 5a 19 00 00       	call   80104ee6 <wakeup>
  release(&log.lock);
8010358c:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103593:	e8 3d 1c 00 00       	call   801051d5 <release>
}
80103598:	c9                   	leave  
80103599:	c3                   	ret    

8010359a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010359a:	55                   	push   %ebp
8010359b:	89 e5                	mov    %esp,%ebp
8010359d:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801035a0:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035a5:	83 f8 09             	cmp    $0x9,%eax
801035a8:	7f 12                	jg     801035bc <log_write+0x22>
801035aa:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035af:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
801035b5:	83 ea 01             	sub    $0x1,%edx
801035b8:	39 d0                	cmp    %edx,%eax
801035ba:	7c 0c                	jl     801035c8 <log_write+0x2e>
    panic("too big a transaction");
801035bc:	c7 04 24 2c 8a 10 80 	movl   $0x80108a2c,(%esp)
801035c3:	e8 75 cf ff ff       	call   8010053d <panic>
  if (!log.busy)
801035c8:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
801035cd:	85 c0                	test   %eax,%eax
801035cf:	75 0c                	jne    801035dd <log_write+0x43>
    panic("write outside of trans");
801035d1:	c7 04 24 42 8a 10 80 	movl   $0x80108a42,(%esp)
801035d8:	e8 60 cf ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
801035dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035e4:	eb 1d                	jmp    80103603 <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
801035e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035e9:	83 c0 10             	add    $0x10,%eax
801035ec:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801035f3:	89 c2                	mov    %eax,%edx
801035f5:	8b 45 08             	mov    0x8(%ebp),%eax
801035f8:	8b 40 08             	mov    0x8(%eax),%eax
801035fb:	39 c2                	cmp    %eax,%edx
801035fd:	74 10                	je     8010360f <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
801035ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103603:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103608:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010360b:	7f d9                	jg     801035e6 <log_write+0x4c>
8010360d:	eb 01                	jmp    80103610 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
8010360f:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103610:	8b 45 08             	mov    0x8(%ebp),%eax
80103613:	8b 40 08             	mov    0x8(%eax),%eax
80103616:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103619:	83 c2 10             	add    $0x10,%edx
8010361c:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103623:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103628:	03 45 f4             	add    -0xc(%ebp),%eax
8010362b:	83 c0 01             	add    $0x1,%eax
8010362e:	89 c2                	mov    %eax,%edx
80103630:	8b 45 08             	mov    0x8(%ebp),%eax
80103633:	8b 40 04             	mov    0x4(%eax),%eax
80103636:	89 54 24 04          	mov    %edx,0x4(%esp)
8010363a:	89 04 24             	mov    %eax,(%esp)
8010363d:	e8 64 cb ff ff       	call   801001a6 <bread>
80103642:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103645:	8b 45 08             	mov    0x8(%ebp),%eax
80103648:	8d 50 18             	lea    0x18(%eax),%edx
8010364b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010364e:	83 c0 18             	add    $0x18,%eax
80103651:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103658:	00 
80103659:	89 54 24 04          	mov    %edx,0x4(%esp)
8010365d:	89 04 24             	mov    %eax,(%esp)
80103660:	e8 30 1e 00 00       	call   80105495 <memmove>
  bwrite(lbuf);
80103665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103668:	89 04 24             	mov    %eax,(%esp)
8010366b:	e8 6d cb ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103673:	89 04 24             	mov    %eax,(%esp)
80103676:	e8 9c cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
8010367b:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103680:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103683:	75 0d                	jne    80103692 <log_write+0xf8>
    log.lh.n++;
80103685:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010368a:	83 c0 01             	add    $0x1,%eax
8010368d:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
80103692:	8b 45 08             	mov    0x8(%ebp),%eax
80103695:	8b 00                	mov    (%eax),%eax
80103697:	89 c2                	mov    %eax,%edx
80103699:	83 ca 04             	or     $0x4,%edx
8010369c:	8b 45 08             	mov    0x8(%ebp),%eax
8010369f:	89 10                	mov    %edx,(%eax)
}
801036a1:	c9                   	leave  
801036a2:	c3                   	ret    
	...

801036a4 <v2p>:
801036a4:	55                   	push   %ebp
801036a5:	89 e5                	mov    %esp,%ebp
801036a7:	8b 45 08             	mov    0x8(%ebp),%eax
801036aa:	05 00 00 00 80       	add    $0x80000000,%eax
801036af:	5d                   	pop    %ebp
801036b0:	c3                   	ret    

801036b1 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036b1:	55                   	push   %ebp
801036b2:	89 e5                	mov    %esp,%ebp
801036b4:	8b 45 08             	mov    0x8(%ebp),%eax
801036b7:	05 00 00 00 80       	add    $0x80000000,%eax
801036bc:	5d                   	pop    %ebp
801036bd:	c3                   	ret    

801036be <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801036be:	55                   	push   %ebp
801036bf:	89 e5                	mov    %esp,%ebp
801036c1:	53                   	push   %ebx
801036c2:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801036c5:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801036c8:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801036cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801036ce:	89 c3                	mov    %eax,%ebx
801036d0:	89 d8                	mov    %ebx,%eax
801036d2:	f0 87 02             	lock xchg %eax,(%edx)
801036d5:	89 c3                	mov    %eax,%ebx
801036d7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801036da:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801036dd:	83 c4 10             	add    $0x10,%esp
801036e0:	5b                   	pop    %ebx
801036e1:	5d                   	pop    %ebp
801036e2:	c3                   	ret    

801036e3 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801036e3:	55                   	push   %ebp
801036e4:	89 e5                	mov    %esp,%ebp
801036e6:	83 e4 f0             	and    $0xfffffff0,%esp
801036e9:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801036ec:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801036f3:	80 
801036f4:	c7 04 24 1c 2d 11 80 	movl   $0x80112d1c,(%esp)
801036fb:	e8 ad f5 ff ff       	call   80102cad <kinit1>
  kvmalloc();      // kernel page table
80103700:	e8 81 49 00 00       	call   80108086 <kvmalloc>
  mpinit();        // collect info about this machine
80103705:	e8 63 04 00 00       	call   80103b6d <mpinit>
  lapicinit(mpbcpu());
8010370a:	e8 2e 02 00 00       	call   8010393d <mpbcpu>
8010370f:	89 04 24             	mov    %eax,(%esp)
80103712:	e8 f5 f8 ff ff       	call   8010300c <lapicinit>
  seginit();       // set up segments
80103717:	e8 0d 43 00 00       	call   80107a29 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010371c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103722:	0f b6 00             	movzbl (%eax),%eax
80103725:	0f b6 c0             	movzbl %al,%eax
80103728:	89 44 24 04          	mov    %eax,0x4(%esp)
8010372c:	c7 04 24 59 8a 10 80 	movl   $0x80108a59,(%esp)
80103733:	e8 69 cc ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
80103738:	e8 95 06 00 00       	call   80103dd2 <picinit>
  ioapicinit();    // another interrupt controller
8010373d:	e8 5b f4 ff ff       	call   80102b9d <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103742:	e8 20 d6 ff ff       	call   80100d67 <consoleinit>
  uartinit();      // serial port
80103747:	e8 28 36 00 00       	call   80106d74 <uartinit>
  pinit();         // process table
8010374c:	e8 96 0b 00 00       	call   801042e7 <pinit>
  tvinit();        // trap vectors
80103751:	e8 7d 31 00 00       	call   801068d3 <tvinit>
  binit();         // buffer cache
80103756:	e8 d9 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010375b:	e8 7c da ff ff       	call   801011dc <fileinit>
  iinit();         // inode cache
80103760:	e8 2a e1 ff ff       	call   8010188f <iinit>
  ideinit();       // disk
80103765:	e8 98 f0 ff ff       	call   80102802 <ideinit>
  if(!ismp)
8010376a:	a1 24 f9 10 80       	mov    0x8010f924,%eax
8010376f:	85 c0                	test   %eax,%eax
80103771:	75 05                	jne    80103778 <main+0x95>
    timerinit();   // uniprocessor timer
80103773:	e8 9e 30 00 00       	call   80106816 <timerinit>
  startothers();   // start other processors
80103778:	e8 87 00 00 00       	call   80103804 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010377d:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103784:	8e 
80103785:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010378c:	e8 54 f5 ff ff       	call   80102ce5 <kinit2>
  userinit();      // first user process
80103791:	e8 6f 0c 00 00       	call   80104405 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103796:	e8 22 00 00 00       	call   801037bd <mpmain>

8010379b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010379b:	55                   	push   %ebp
8010379c:	89 e5                	mov    %esp,%ebp
8010379e:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801037a1:	e8 f7 48 00 00       	call   8010809d <switchkvm>
  seginit();
801037a6:	e8 7e 42 00 00       	call   80107a29 <seginit>
  lapicinit(cpunum());
801037ab:	e8 b9 f9 ff ff       	call   80103169 <cpunum>
801037b0:	89 04 24             	mov    %eax,(%esp)
801037b3:	e8 54 f8 ff ff       	call   8010300c <lapicinit>
  mpmain();
801037b8:	e8 00 00 00 00       	call   801037bd <mpmain>

801037bd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037bd:	55                   	push   %ebp
801037be:	89 e5                	mov    %esp,%ebp
801037c0:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801037c3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037c9:	0f b6 00             	movzbl (%eax),%eax
801037cc:	0f b6 c0             	movzbl %al,%eax
801037cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801037d3:	c7 04 24 70 8a 10 80 	movl   $0x80108a70,(%esp)
801037da:	e8 c2 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
801037df:	e8 63 32 00 00       	call   80106a47 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801037e4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037ea:	05 a8 00 00 00       	add    $0xa8,%eax
801037ef:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801037f6:	00 
801037f7:	89 04 24             	mov    %eax,(%esp)
801037fa:	e8 bf fe ff ff       	call   801036be <xchg>
  scheduler();     // start running processes
801037ff:	e8 ae 13 00 00       	call   80104bb2 <scheduler>

80103804 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103804:	55                   	push   %ebp
80103805:	89 e5                	mov    %esp,%ebp
80103807:	53                   	push   %ebx
80103808:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010380b:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103812:	e8 9a fe ff ff       	call   801036b1 <p2v>
80103817:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010381a:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010381f:	89 44 24 08          	mov    %eax,0x8(%esp)
80103823:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010382a:	80 
8010382b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010382e:	89 04 24             	mov    %eax,(%esp)
80103831:	e8 5f 1c 00 00       	call   80105495 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103836:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
8010383d:	e9 86 00 00 00       	jmp    801038c8 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80103842:	e8 22 f9 ff ff       	call   80103169 <cpunum>
80103847:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010384d:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103852:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103855:	74 69                	je     801038c0 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103857:	e8 7f f5 ff ff       	call   80102ddb <kalloc>
8010385c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010385f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103862:	83 e8 04             	sub    $0x4,%eax
80103865:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103868:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010386e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103873:	83 e8 08             	sub    $0x8,%eax
80103876:	c7 00 9b 37 10 80    	movl   $0x8010379b,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010387c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010387f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103882:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103889:	e8 16 fe ff ff       	call   801036a4 <v2p>
8010388e:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103893:	89 04 24             	mov    %eax,(%esp)
80103896:	e8 09 fe ff ff       	call   801036a4 <v2p>
8010389b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010389e:	0f b6 12             	movzbl (%edx),%edx
801038a1:	0f b6 d2             	movzbl %dl,%edx
801038a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801038a8:	89 14 24             	mov    %edx,(%esp)
801038ab:	e8 3f f9 ff ff       	call   801031ef <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038b0:	90                   	nop
801038b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801038ba:	85 c0                	test   %eax,%eax
801038bc:	74 f3                	je     801038b1 <startothers+0xad>
801038be:	eb 01                	jmp    801038c1 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801038c0:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038c1:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801038c8:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801038cd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038d3:	05 40 f9 10 80       	add    $0x8010f940,%eax
801038d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038db:	0f 87 61 ff ff ff    	ja     80103842 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801038e1:	83 c4 24             	add    $0x24,%esp
801038e4:	5b                   	pop    %ebx
801038e5:	5d                   	pop    %ebp
801038e6:	c3                   	ret    
	...

801038e8 <p2v>:
801038e8:	55                   	push   %ebp
801038e9:	89 e5                	mov    %esp,%ebp
801038eb:	8b 45 08             	mov    0x8(%ebp),%eax
801038ee:	05 00 00 00 80       	add    $0x80000000,%eax
801038f3:	5d                   	pop    %ebp
801038f4:	c3                   	ret    

801038f5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801038f5:	55                   	push   %ebp
801038f6:	89 e5                	mov    %esp,%ebp
801038f8:	53                   	push   %ebx
801038f9:	83 ec 14             	sub    $0x14,%esp
801038fc:	8b 45 08             	mov    0x8(%ebp),%eax
801038ff:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103903:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103907:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010390b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010390f:	ec                   	in     (%dx),%al
80103910:	89 c3                	mov    %eax,%ebx
80103912:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103915:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103919:	83 c4 14             	add    $0x14,%esp
8010391c:	5b                   	pop    %ebx
8010391d:	5d                   	pop    %ebp
8010391e:	c3                   	ret    

8010391f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010391f:	55                   	push   %ebp
80103920:	89 e5                	mov    %esp,%ebp
80103922:	83 ec 08             	sub    $0x8,%esp
80103925:	8b 55 08             	mov    0x8(%ebp),%edx
80103928:	8b 45 0c             	mov    0xc(%ebp),%eax
8010392b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010392f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103932:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103936:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010393a:	ee                   	out    %al,(%dx)
}
8010393b:	c9                   	leave  
8010393c:	c3                   	ret    

8010393d <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010393d:	55                   	push   %ebp
8010393e:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103940:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103945:	89 c2                	mov    %eax,%edx
80103947:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
8010394c:	89 d1                	mov    %edx,%ecx
8010394e:	29 c1                	sub    %eax,%ecx
80103950:	89 c8                	mov    %ecx,%eax
80103952:	c1 f8 02             	sar    $0x2,%eax
80103955:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010395b:	5d                   	pop    %ebp
8010395c:	c3                   	ret    

8010395d <sum>:

static uchar
sum(uchar *addr, int len)
{
8010395d:	55                   	push   %ebp
8010395e:	89 e5                	mov    %esp,%ebp
80103960:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103963:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010396a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103971:	eb 13                	jmp    80103986 <sum+0x29>
    sum += addr[i];
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103976:	03 45 08             	add    0x8(%ebp),%eax
80103979:	0f b6 00             	movzbl (%eax),%eax
8010397c:	0f b6 c0             	movzbl %al,%eax
8010397f:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103982:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103986:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103989:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010398c:	7c e5                	jl     80103973 <sum+0x16>
    sum += addr[i];
  return sum;
8010398e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103991:	c9                   	leave  
80103992:	c3                   	ret    

80103993 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103993:	55                   	push   %ebp
80103994:	89 e5                	mov    %esp,%ebp
80103996:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103999:	8b 45 08             	mov    0x8(%ebp),%eax
8010399c:	89 04 24             	mov    %eax,(%esp)
8010399f:	e8 44 ff ff ff       	call   801038e8 <p2v>
801039a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801039aa:	03 45 f0             	add    -0x10(%ebp),%eax
801039ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039b6:	eb 3f                	jmp    801039f7 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039b8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039bf:	00 
801039c0:	c7 44 24 04 84 8a 10 	movl   $0x80108a84,0x4(%esp)
801039c7:	80 
801039c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039cb:	89 04 24             	mov    %eax,(%esp)
801039ce:	e8 66 1a 00 00       	call   80105439 <memcmp>
801039d3:	85 c0                	test   %eax,%eax
801039d5:	75 1c                	jne    801039f3 <mpsearch1+0x60>
801039d7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801039de:	00 
801039df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e2:	89 04 24             	mov    %eax,(%esp)
801039e5:	e8 73 ff ff ff       	call   8010395d <sum>
801039ea:	84 c0                	test   %al,%al
801039ec:	75 05                	jne    801039f3 <mpsearch1+0x60>
      return (struct mp*)p;
801039ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f1:	eb 11                	jmp    80103a04 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801039f3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801039f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039fd:	72 b9                	jb     801039b8 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801039ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a04:	c9                   	leave  
80103a05:	c3                   	ret    

80103a06 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a06:	55                   	push   %ebp
80103a07:	89 e5                	mov    %esp,%ebp
80103a09:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a0c:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a16:	83 c0 0f             	add    $0xf,%eax
80103a19:	0f b6 00             	movzbl (%eax),%eax
80103a1c:	0f b6 c0             	movzbl %al,%eax
80103a1f:	89 c2                	mov    %eax,%edx
80103a21:	c1 e2 08             	shl    $0x8,%edx
80103a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a27:	83 c0 0e             	add    $0xe,%eax
80103a2a:	0f b6 00             	movzbl (%eax),%eax
80103a2d:	0f b6 c0             	movzbl %al,%eax
80103a30:	09 d0                	or     %edx,%eax
80103a32:	c1 e0 04             	shl    $0x4,%eax
80103a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a3c:	74 21                	je     80103a5f <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a3e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a45:	00 
80103a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a49:	89 04 24             	mov    %eax,(%esp)
80103a4c:	e8 42 ff ff ff       	call   80103993 <mpsearch1>
80103a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a54:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a58:	74 50                	je     80103aaa <mpsearch+0xa4>
      return mp;
80103a5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a5d:	eb 5f                	jmp    80103abe <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a62:	83 c0 14             	add    $0x14,%eax
80103a65:	0f b6 00             	movzbl (%eax),%eax
80103a68:	0f b6 c0             	movzbl %al,%eax
80103a6b:	89 c2                	mov    %eax,%edx
80103a6d:	c1 e2 08             	shl    $0x8,%edx
80103a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a73:	83 c0 13             	add    $0x13,%eax
80103a76:	0f b6 00             	movzbl (%eax),%eax
80103a79:	0f b6 c0             	movzbl %al,%eax
80103a7c:	09 d0                	or     %edx,%eax
80103a7e:	c1 e0 0a             	shl    $0xa,%eax
80103a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a87:	2d 00 04 00 00       	sub    $0x400,%eax
80103a8c:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a93:	00 
80103a94:	89 04 24             	mov    %eax,(%esp)
80103a97:	e8 f7 fe ff ff       	call   80103993 <mpsearch1>
80103a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a9f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aa3:	74 05                	je     80103aaa <mpsearch+0xa4>
      return mp;
80103aa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103aa8:	eb 14                	jmp    80103abe <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103aaa:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ab1:	00 
80103ab2:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ab9:	e8 d5 fe ff ff       	call   80103993 <mpsearch1>
}
80103abe:	c9                   	leave  
80103abf:	c3                   	ret    

80103ac0 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ac0:	55                   	push   %ebp
80103ac1:	89 e5                	mov    %esp,%ebp
80103ac3:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ac6:	e8 3b ff ff ff       	call   80103a06 <mpsearch>
80103acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ace:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ad2:	74 0a                	je     80103ade <mpconfig+0x1e>
80103ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad7:	8b 40 04             	mov    0x4(%eax),%eax
80103ada:	85 c0                	test   %eax,%eax
80103adc:	75 0a                	jne    80103ae8 <mpconfig+0x28>
    return 0;
80103ade:	b8 00 00 00 00       	mov    $0x0,%eax
80103ae3:	e9 83 00 00 00       	jmp    80103b6b <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aeb:	8b 40 04             	mov    0x4(%eax),%eax
80103aee:	89 04 24             	mov    %eax,(%esp)
80103af1:	e8 f2 fd ff ff       	call   801038e8 <p2v>
80103af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103af9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b00:	00 
80103b01:	c7 44 24 04 89 8a 10 	movl   $0x80108a89,0x4(%esp)
80103b08:	80 
80103b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0c:	89 04 24             	mov    %eax,(%esp)
80103b0f:	e8 25 19 00 00       	call   80105439 <memcmp>
80103b14:	85 c0                	test   %eax,%eax
80103b16:	74 07                	je     80103b1f <mpconfig+0x5f>
    return 0;
80103b18:	b8 00 00 00 00       	mov    $0x0,%eax
80103b1d:	eb 4c                	jmp    80103b6b <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b22:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b26:	3c 01                	cmp    $0x1,%al
80103b28:	74 12                	je     80103b3c <mpconfig+0x7c>
80103b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2d:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b31:	3c 04                	cmp    $0x4,%al
80103b33:	74 07                	je     80103b3c <mpconfig+0x7c>
    return 0;
80103b35:	b8 00 00 00 00       	mov    $0x0,%eax
80103b3a:	eb 2f                	jmp    80103b6b <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b3f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b43:	0f b7 c0             	movzwl %ax,%eax
80103b46:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b4d:	89 04 24             	mov    %eax,(%esp)
80103b50:	e8 08 fe ff ff       	call   8010395d <sum>
80103b55:	84 c0                	test   %al,%al
80103b57:	74 07                	je     80103b60 <mpconfig+0xa0>
    return 0;
80103b59:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5e:	eb 0b                	jmp    80103b6b <mpconfig+0xab>
  *pmp = mp;
80103b60:	8b 45 08             	mov    0x8(%ebp),%eax
80103b63:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b66:	89 10                	mov    %edx,(%eax)
  return conf;
80103b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b6b:	c9                   	leave  
80103b6c:	c3                   	ret    

80103b6d <mpinit>:

void
mpinit(void)
{
80103b6d:	55                   	push   %ebp
80103b6e:	89 e5                	mov    %esp,%ebp
80103b70:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103b73:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103b7a:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103b7d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103b80:	89 04 24             	mov    %eax,(%esp)
80103b83:	e8 38 ff ff ff       	call   80103ac0 <mpconfig>
80103b88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b8f:	0f 84 9c 01 00 00    	je     80103d31 <mpinit+0x1c4>
    return;
  ismp = 1;
80103b95:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103b9c:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba2:	8b 40 24             	mov    0x24(%eax),%eax
80103ba5:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bad:	83 c0 2c             	add    $0x2c,%eax
80103bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bba:	0f b7 c0             	movzwl %ax,%eax
80103bbd:	03 45 f0             	add    -0x10(%ebp),%eax
80103bc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bc3:	e9 f4 00 00 00       	jmp    80103cbc <mpinit+0x14f>
    switch(*p){
80103bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcb:	0f b6 00             	movzbl (%eax),%eax
80103bce:	0f b6 c0             	movzbl %al,%eax
80103bd1:	83 f8 04             	cmp    $0x4,%eax
80103bd4:	0f 87 bf 00 00 00    	ja     80103c99 <mpinit+0x12c>
80103bda:	8b 04 85 cc 8a 10 80 	mov    -0x7fef7534(,%eax,4),%eax
80103be1:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103be9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bec:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103bf0:	0f b6 d0             	movzbl %al,%edx
80103bf3:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103bf8:	39 c2                	cmp    %eax,%edx
80103bfa:	74 2d                	je     80103c29 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103bfc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bff:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c03:	0f b6 d0             	movzbl %al,%edx
80103c06:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c0b:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c13:	c7 04 24 8e 8a 10 80 	movl   $0x80108a8e,(%esp)
80103c1a:	e8 82 c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c1f:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103c26:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c2c:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c30:	0f b6 c0             	movzbl %al,%eax
80103c33:	83 e0 02             	and    $0x2,%eax
80103c36:	85 c0                	test   %eax,%eax
80103c38:	74 15                	je     80103c4f <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103c3a:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c3f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c45:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103c4a:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103c4f:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103c55:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c5a:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c60:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103c66:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c68:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c6d:	83 c0 01             	add    $0x1,%eax
80103c70:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103c75:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c79:	eb 41                	jmp    80103cbc <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103c81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c84:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c88:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103c8d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c91:	eb 29                	jmp    80103cbc <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c93:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c97:	eb 23                	jmp    80103cbc <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9c:	0f b6 00             	movzbl (%eax),%eax
80103c9f:	0f b6 c0             	movzbl %al,%eax
80103ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ca6:	c7 04 24 ac 8a 10 80 	movl   $0x80108aac,(%esp)
80103cad:	e8 ef c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103cb2:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103cb9:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cc2:	0f 82 00 ff ff ff    	jb     80103bc8 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103cc8:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103ccd:	85 c0                	test   %eax,%eax
80103ccf:	75 1d                	jne    80103cee <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cd1:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103cd8:	00 00 00 
    lapic = 0;
80103cdb:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103ce2:	00 00 00 
    ioapicid = 0;
80103ce5:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103cec:	eb 44                	jmp    80103d32 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103cf1:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103cf5:	84 c0                	test   %al,%al
80103cf7:	74 39                	je     80103d32 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103cf9:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d00:	00 
80103d01:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d08:	e8 12 fc ff ff       	call   8010391f <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d0d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d14:	e8 dc fb ff ff       	call   801038f5 <inb>
80103d19:	83 c8 01             	or     $0x1,%eax
80103d1c:	0f b6 c0             	movzbl %al,%eax
80103d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d23:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d2a:	e8 f0 fb ff ff       	call   8010391f <outb>
80103d2f:	eb 01                	jmp    80103d32 <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103d31:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103d32:	c9                   	leave  
80103d33:	c3                   	ret    

80103d34 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d34:	55                   	push   %ebp
80103d35:	89 e5                	mov    %esp,%ebp
80103d37:	83 ec 08             	sub    $0x8,%esp
80103d3a:	8b 55 08             	mov    0x8(%ebp),%edx
80103d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d40:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d44:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d47:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d4b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d4f:	ee                   	out    %al,(%dx)
}
80103d50:	c9                   	leave  
80103d51:	c3                   	ret    

80103d52 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d52:	55                   	push   %ebp
80103d53:	89 e5                	mov    %esp,%ebp
80103d55:	83 ec 0c             	sub    $0xc,%esp
80103d58:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d5f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d63:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d69:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d6d:	0f b6 c0             	movzbl %al,%eax
80103d70:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d74:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d7b:	e8 b4 ff ff ff       	call   80103d34 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103d80:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d84:	66 c1 e8 08          	shr    $0x8,%ax
80103d88:	0f b6 c0             	movzbl %al,%eax
80103d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d8f:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d96:	e8 99 ff ff ff       	call   80103d34 <outb>
}
80103d9b:	c9                   	leave  
80103d9c:	c3                   	ret    

80103d9d <picenable>:

void
picenable(int irq)
{
80103d9d:	55                   	push   %ebp
80103d9e:	89 e5                	mov    %esp,%ebp
80103da0:	53                   	push   %ebx
80103da1:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103da4:	8b 45 08             	mov    0x8(%ebp),%eax
80103da7:	ba 01 00 00 00       	mov    $0x1,%edx
80103dac:	89 d3                	mov    %edx,%ebx
80103dae:	89 c1                	mov    %eax,%ecx
80103db0:	d3 e3                	shl    %cl,%ebx
80103db2:	89 d8                	mov    %ebx,%eax
80103db4:	89 c2                	mov    %eax,%edx
80103db6:	f7 d2                	not    %edx
80103db8:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103dbf:	21 d0                	and    %edx,%eax
80103dc1:	0f b7 c0             	movzwl %ax,%eax
80103dc4:	89 04 24             	mov    %eax,(%esp)
80103dc7:	e8 86 ff ff ff       	call   80103d52 <picsetmask>
}
80103dcc:	83 c4 04             	add    $0x4,%esp
80103dcf:	5b                   	pop    %ebx
80103dd0:	5d                   	pop    %ebp
80103dd1:	c3                   	ret    

80103dd2 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103dd2:	55                   	push   %ebp
80103dd3:	89 e5                	mov    %esp,%ebp
80103dd5:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103dd8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ddf:	00 
80103de0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103de7:	e8 48 ff ff ff       	call   80103d34 <outb>
  outb(IO_PIC2+1, 0xFF);
80103dec:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103df3:	00 
80103df4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dfb:	e8 34 ff ff ff       	call   80103d34 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e00:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e07:	00 
80103e08:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e0f:	e8 20 ff ff ff       	call   80103d34 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e14:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e1b:	00 
80103e1c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e23:	e8 0c ff ff ff       	call   80103d34 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e28:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e2f:	00 
80103e30:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e37:	e8 f8 fe ff ff       	call   80103d34 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e3c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e43:	00 
80103e44:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e4b:	e8 e4 fe ff ff       	call   80103d34 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e50:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e57:	00 
80103e58:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e5f:	e8 d0 fe ff ff       	call   80103d34 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e64:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e6b:	00 
80103e6c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e73:	e8 bc fe ff ff       	call   80103d34 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e78:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103e7f:	00 
80103e80:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e87:	e8 a8 fe ff ff       	call   80103d34 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103e8c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e93:	00 
80103e94:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e9b:	e8 94 fe ff ff       	call   80103d34 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103ea0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ea7:	00 
80103ea8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103eaf:	e8 80 fe ff ff       	call   80103d34 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103eb4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ebb:	00 
80103ebc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ec3:	e8 6c fe ff ff       	call   80103d34 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ec8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ecf:	00 
80103ed0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ed7:	e8 58 fe ff ff       	call   80103d34 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103edc:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ee3:	00 
80103ee4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eeb:	e8 44 fe ff ff       	call   80103d34 <outb>

  if(irqmask != 0xFFFF)
80103ef0:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103ef7:	66 83 f8 ff          	cmp    $0xffff,%ax
80103efb:	74 12                	je     80103f0f <picinit+0x13d>
    picsetmask(irqmask);
80103efd:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f04:	0f b7 c0             	movzwl %ax,%eax
80103f07:	89 04 24             	mov    %eax,(%esp)
80103f0a:	e8 43 fe ff ff       	call   80103d52 <picsetmask>
}
80103f0f:	c9                   	leave  
80103f10:	c3                   	ret    
80103f11:	00 00                	add    %al,(%eax)
	...

80103f14 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f14:	55                   	push   %ebp
80103f15:	89 e5                	mov    %esp,%ebp
80103f17:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f2d:	8b 10                	mov    (%eax),%edx
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f34:	e8 bf d2 ff ff       	call   801011f8 <filealloc>
80103f39:	8b 55 08             	mov    0x8(%ebp),%edx
80103f3c:	89 02                	mov    %eax,(%edx)
80103f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f41:	8b 00                	mov    (%eax),%eax
80103f43:	85 c0                	test   %eax,%eax
80103f45:	0f 84 c8 00 00 00    	je     80104013 <pipealloc+0xff>
80103f4b:	e8 a8 d2 ff ff       	call   801011f8 <filealloc>
80103f50:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f53:	89 02                	mov    %eax,(%edx)
80103f55:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f58:	8b 00                	mov    (%eax),%eax
80103f5a:	85 c0                	test   %eax,%eax
80103f5c:	0f 84 b1 00 00 00    	je     80104013 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f62:	e8 74 ee ff ff       	call   80102ddb <kalloc>
80103f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f6e:	0f 84 9e 00 00 00    	je     80104012 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f77:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f7e:	00 00 00 
  p->writeopen = 1;
80103f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f84:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f8b:	00 00 00 
  p->nwrite = 0;
80103f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f91:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f98:	00 00 00 
  p->nread = 0;
80103f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fa5:	00 00 00 
  initlock(&p->lock, "pipe");
80103fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fab:	c7 44 24 04 e0 8a 10 	movl   $0x80108ae0,0x4(%esp)
80103fb2:	80 
80103fb3:	89 04 24             	mov    %eax,(%esp)
80103fb6:	e8 97 11 00 00       	call   80105152 <initlock>
  (*f0)->type = FD_PIPE;
80103fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbe:	8b 00                	mov    (%eax),%eax
80103fc0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc9:	8b 00                	mov    (%eax),%eax
80103fcb:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd2:	8b 00                	mov    (%eax),%eax
80103fd4:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdb:	8b 00                	mov    (%eax),%eax
80103fdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fe0:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe6:	8b 00                	mov    (%eax),%eax
80103fe8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff1:	8b 00                	mov    (%eax),%eax
80103ff3:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffa:	8b 00                	mov    (%eax),%eax
80103ffc:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104000:	8b 45 0c             	mov    0xc(%ebp),%eax
80104003:	8b 00                	mov    (%eax),%eax
80104005:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104008:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010400b:	b8 00 00 00 00       	mov    $0x0,%eax
80104010:	eb 43                	jmp    80104055 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104012:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104013:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104017:	74 0b                	je     80104024 <pipealloc+0x110>
    kfree((char*)p);
80104019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401c:	89 04 24             	mov    %eax,(%esp)
8010401f:	e8 1e ed ff ff       	call   80102d42 <kfree>
  if(*f0)
80104024:	8b 45 08             	mov    0x8(%ebp),%eax
80104027:	8b 00                	mov    (%eax),%eax
80104029:	85 c0                	test   %eax,%eax
8010402b:	74 0d                	je     8010403a <pipealloc+0x126>
    fileclose(*f0);
8010402d:	8b 45 08             	mov    0x8(%ebp),%eax
80104030:	8b 00                	mov    (%eax),%eax
80104032:	89 04 24             	mov    %eax,(%esp)
80104035:	e8 66 d2 ff ff       	call   801012a0 <fileclose>
  if(*f1)
8010403a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403d:	8b 00                	mov    (%eax),%eax
8010403f:	85 c0                	test   %eax,%eax
80104041:	74 0d                	je     80104050 <pipealloc+0x13c>
    fileclose(*f1);
80104043:	8b 45 0c             	mov    0xc(%ebp),%eax
80104046:	8b 00                	mov    (%eax),%eax
80104048:	89 04 24             	mov    %eax,(%esp)
8010404b:	e8 50 d2 ff ff       	call   801012a0 <fileclose>
  return -1;
80104050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104055:	c9                   	leave  
80104056:	c3                   	ret    

80104057 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104057:	55                   	push   %ebp
80104058:	89 e5                	mov    %esp,%ebp
8010405a:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
8010405d:	8b 45 08             	mov    0x8(%ebp),%eax
80104060:	89 04 24             	mov    %eax,(%esp)
80104063:	e8 0b 11 00 00       	call   80105173 <acquire>
  if(writable){
80104068:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010406c:	74 1f                	je     8010408d <pipeclose+0x36>
    p->writeopen = 0;
8010406e:	8b 45 08             	mov    0x8(%ebp),%eax
80104071:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104078:	00 00 00 
    wakeup(&p->nread);
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	05 34 02 00 00       	add    $0x234,%eax
80104083:	89 04 24             	mov    %eax,(%esp)
80104086:	e8 5b 0e 00 00       	call   80104ee6 <wakeup>
8010408b:	eb 1d                	jmp    801040aa <pipeclose+0x53>
  } else {
    p->readopen = 0;
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104097:	00 00 00 
    wakeup(&p->nwrite);
8010409a:	8b 45 08             	mov    0x8(%ebp),%eax
8010409d:	05 38 02 00 00       	add    $0x238,%eax
801040a2:	89 04 24             	mov    %eax,(%esp)
801040a5:	e8 3c 0e 00 00       	call   80104ee6 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040b3:	85 c0                	test   %eax,%eax
801040b5:	75 25                	jne    801040dc <pipeclose+0x85>
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040c0:	85 c0                	test   %eax,%eax
801040c2:	75 18                	jne    801040dc <pipeclose+0x85>
    release(&p->lock);
801040c4:	8b 45 08             	mov    0x8(%ebp),%eax
801040c7:	89 04 24             	mov    %eax,(%esp)
801040ca:	e8 06 11 00 00       	call   801051d5 <release>
    kfree((char*)p);
801040cf:	8b 45 08             	mov    0x8(%ebp),%eax
801040d2:	89 04 24             	mov    %eax,(%esp)
801040d5:	e8 68 ec ff ff       	call   80102d42 <kfree>
801040da:	eb 0b                	jmp    801040e7 <pipeclose+0x90>
  } else
    release(&p->lock);
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	89 04 24             	mov    %eax,(%esp)
801040e2:	e8 ee 10 00 00       	call   801051d5 <release>
}
801040e7:	c9                   	leave  
801040e8:	c3                   	ret    

801040e9 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040e9:	55                   	push   %ebp
801040ea:	89 e5                	mov    %esp,%ebp
801040ec:	53                   	push   %ebx
801040ed:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801040f0:	8b 45 08             	mov    0x8(%ebp),%eax
801040f3:	89 04 24             	mov    %eax,(%esp)
801040f6:	e8 78 10 00 00       	call   80105173 <acquire>
  for(i = 0; i < n; i++){
801040fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104102:	e9 a6 00 00 00       	jmp    801041ad <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104107:	8b 45 08             	mov    0x8(%ebp),%eax
8010410a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104110:	85 c0                	test   %eax,%eax
80104112:	74 0d                	je     80104121 <pipewrite+0x38>
80104114:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010411a:	8b 40 24             	mov    0x24(%eax),%eax
8010411d:	85 c0                	test   %eax,%eax
8010411f:	74 15                	je     80104136 <pipewrite+0x4d>
        release(&p->lock);
80104121:	8b 45 08             	mov    0x8(%ebp),%eax
80104124:	89 04 24             	mov    %eax,(%esp)
80104127:	e8 a9 10 00 00       	call   801051d5 <release>
        return -1;
8010412c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104131:	e9 9d 00 00 00       	jmp    801041d3 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	05 34 02 00 00       	add    $0x234,%eax
8010413e:	89 04 24             	mov    %eax,(%esp)
80104141:	e8 a0 0d 00 00       	call   80104ee6 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104146:	8b 45 08             	mov    0x8(%ebp),%eax
80104149:	8b 55 08             	mov    0x8(%ebp),%edx
8010414c:	81 c2 38 02 00 00    	add    $0x238,%edx
80104152:	89 44 24 04          	mov    %eax,0x4(%esp)
80104156:	89 14 24             	mov    %edx,(%esp)
80104159:	e8 ac 0c 00 00       	call   80104e0a <sleep>
8010415e:	eb 01                	jmp    80104161 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104160:	90                   	nop
80104161:	8b 45 08             	mov    0x8(%ebp),%eax
80104164:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010416a:	8b 45 08             	mov    0x8(%ebp),%eax
8010416d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104173:	05 00 02 00 00       	add    $0x200,%eax
80104178:	39 c2                	cmp    %eax,%edx
8010417a:	74 8b                	je     80104107 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104185:	89 c3                	mov    %eax,%ebx
80104187:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010418d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104190:	03 55 0c             	add    0xc(%ebp),%edx
80104193:	0f b6 0a             	movzbl (%edx),%ecx
80104196:	8b 55 08             	mov    0x8(%ebp),%edx
80104199:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
8010419d:	8d 50 01             	lea    0x1(%eax),%edx
801041a0:	8b 45 08             	mov    0x8(%ebp),%eax
801041a3:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b0:	3b 45 10             	cmp    0x10(%ebp),%eax
801041b3:	7c ab                	jl     80104160 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	05 34 02 00 00       	add    $0x234,%eax
801041bd:	89 04 24             	mov    %eax,(%esp)
801041c0:	e8 21 0d 00 00       	call   80104ee6 <wakeup>
  release(&p->lock);
801041c5:	8b 45 08             	mov    0x8(%ebp),%eax
801041c8:	89 04 24             	mov    %eax,(%esp)
801041cb:	e8 05 10 00 00       	call   801051d5 <release>
  return n;
801041d0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041d3:	83 c4 24             	add    $0x24,%esp
801041d6:	5b                   	pop    %ebx
801041d7:	5d                   	pop    %ebp
801041d8:	c3                   	ret    

801041d9 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041d9:	55                   	push   %ebp
801041da:	89 e5                	mov    %esp,%ebp
801041dc:	53                   	push   %ebx
801041dd:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041e0:	8b 45 08             	mov    0x8(%ebp),%eax
801041e3:	89 04 24             	mov    %eax,(%esp)
801041e6:	e8 88 0f 00 00       	call   80105173 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041eb:	eb 3a                	jmp    80104227 <piperead+0x4e>
    if(proc->killed){
801041ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041f3:	8b 40 24             	mov    0x24(%eax),%eax
801041f6:	85 c0                	test   %eax,%eax
801041f8:	74 15                	je     8010420f <piperead+0x36>
      release(&p->lock);
801041fa:	8b 45 08             	mov    0x8(%ebp),%eax
801041fd:	89 04 24             	mov    %eax,(%esp)
80104200:	e8 d0 0f 00 00       	call   801051d5 <release>
      return -1;
80104205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010420a:	e9 b6 00 00 00       	jmp    801042c5 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010420f:	8b 45 08             	mov    0x8(%ebp),%eax
80104212:	8b 55 08             	mov    0x8(%ebp),%edx
80104215:	81 c2 34 02 00 00    	add    $0x234,%edx
8010421b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010421f:	89 14 24             	mov    %edx,(%esp)
80104222:	e8 e3 0b 00 00       	call   80104e0a <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104227:	8b 45 08             	mov    0x8(%ebp),%eax
8010422a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104230:	8b 45 08             	mov    0x8(%ebp),%eax
80104233:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104239:	39 c2                	cmp    %eax,%edx
8010423b:	75 0d                	jne    8010424a <piperead+0x71>
8010423d:	8b 45 08             	mov    0x8(%ebp),%eax
80104240:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104246:	85 c0                	test   %eax,%eax
80104248:	75 a3                	jne    801041ed <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010424a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104251:	eb 49                	jmp    8010429c <piperead+0xc3>
    if(p->nread == p->nwrite)
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010425c:	8b 45 08             	mov    0x8(%ebp),%eax
8010425f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104265:	39 c2                	cmp    %eax,%edx
80104267:	74 3d                	je     801042a6 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426c:	89 c2                	mov    %eax,%edx
8010426e:	03 55 0c             	add    0xc(%ebp),%edx
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010427a:	89 c3                	mov    %eax,%ebx
8010427c:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104282:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104285:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
8010428a:	88 0a                	mov    %cl,(%edx)
8010428c:	8d 50 01             	lea    0x1(%eax),%edx
8010428f:	8b 45 08             	mov    0x8(%ebp),%eax
80104292:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104298:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010429c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429f:	3b 45 10             	cmp    0x10(%ebp),%eax
801042a2:	7c af                	jl     80104253 <piperead+0x7a>
801042a4:	eb 01                	jmp    801042a7 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
801042a6:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042a7:	8b 45 08             	mov    0x8(%ebp),%eax
801042aa:	05 38 02 00 00       	add    $0x238,%eax
801042af:	89 04 24             	mov    %eax,(%esp)
801042b2:	e8 2f 0c 00 00       	call   80104ee6 <wakeup>
  release(&p->lock);
801042b7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ba:	89 04 24             	mov    %eax,(%esp)
801042bd:	e8 13 0f 00 00       	call   801051d5 <release>
  return i;
801042c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042c5:	83 c4 24             	add    $0x24,%esp
801042c8:	5b                   	pop    %ebx
801042c9:	5d                   	pop    %ebp
801042ca:	c3                   	ret    
	...

801042cc <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042cc:	55                   	push   %ebp
801042cd:	89 e5                	mov    %esp,%ebp
801042cf:	53                   	push   %ebx
801042d0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042d3:	9c                   	pushf  
801042d4:	5b                   	pop    %ebx
801042d5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
801042d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801042db:	83 c4 10             	add    $0x10,%esp
801042de:	5b                   	pop    %ebx
801042df:	5d                   	pop    %ebp
801042e0:	c3                   	ret    

801042e1 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042e1:	55                   	push   %ebp
801042e2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042e4:	fb                   	sti    
}
801042e5:	5d                   	pop    %ebp
801042e6:	c3                   	ret    

801042e7 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);
void
pinit(void)
{
801042e7:	55                   	push   %ebp
801042e8:	89 e5                	mov    %esp,%ebp
801042ea:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801042ed:	c7 44 24 04 e5 8a 10 	movl   $0x80108ae5,0x4(%esp)
801042f4:	80 
801042f5:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801042fc:	e8 51 0e 00 00       	call   80105152 <initlock>
}
80104301:	c9                   	leave  
80104302:	c3                   	ret    

80104303 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104303:	55                   	push   %ebp
80104304:	89 e5                	mov    %esp,%ebp
80104306:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104309:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104310:	e8 5e 0e 00 00       	call   80105173 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104315:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010431c:	eb 11                	jmp    8010432f <allocproc+0x2c>
    if(p->state == UNUSED)
8010431e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104321:	8b 40 0c             	mov    0xc(%eax),%eax
80104324:	85 c0                	test   %eax,%eax
80104326:	74 26                	je     8010434e <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104328:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
8010432f:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104336:	72 e6                	jb     8010431e <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104338:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010433f:	e8 91 0e 00 00       	call   801051d5 <release>
  return 0;
80104344:	b8 00 00 00 00       	mov    $0x0,%eax
80104349:	e9 b5 00 00 00       	jmp    80104403 <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010434e:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010434f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104352:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104359:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010435e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104361:	89 42 10             	mov    %eax,0x10(%edx)
80104364:	83 c0 01             	add    $0x1,%eax
80104367:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
8010436c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104373:	e8 5d 0e 00 00       	call   801051d5 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104378:	e8 5e ea ff ff       	call   80102ddb <kalloc>
8010437d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104380:	89 42 08             	mov    %eax,0x8(%edx)
80104383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104386:	8b 40 08             	mov    0x8(%eax),%eax
80104389:	85 c0                	test   %eax,%eax
8010438b:	75 11                	jne    8010439e <allocproc+0x9b>
    p->state = UNUSED;
8010438d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104390:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104397:	b8 00 00 00 00       	mov    $0x0,%eax
8010439c:	eb 65                	jmp    80104403 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
8010439e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a1:	8b 40 08             	mov    0x8(%eax),%eax
801043a4:	05 00 10 00 00       	add    $0x1000,%eax
801043a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043ac:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043b6:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043b9:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043bd:	ba 88 68 10 80       	mov    $0x80106888,%edx
801043c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c5:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043c7:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043d1:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d7:	8b 40 1c             	mov    0x1c(%eax),%eax
801043da:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801043e1:	00 
801043e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043e9:	00 
801043ea:	89 04 24             	mov    %eax,(%esp)
801043ed:	e8 d0 0f 00 00       	call   801053c2 <memset>
  p->context->eip = (uint)forkret;
801043f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f5:	8b 40 1c             	mov    0x1c(%eax),%eax
801043f8:	ba de 4d 10 80       	mov    $0x80104dde,%edx
801043fd:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104400:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104403:	c9                   	leave  
80104404:	c3                   	ret    

80104405 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104405:	55                   	push   %ebp
80104406:	89 e5                	mov    %esp,%ebp
80104408:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010440b:	e8 f3 fe ff ff       	call   80104303 <allocproc>
80104410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104416:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
8010441b:	c7 04 24 db 2d 10 80 	movl   $0x80102ddb,(%esp)
80104422:	e8 a2 3b 00 00       	call   80107fc9 <setupkvm>
80104427:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010442a:	89 42 04             	mov    %eax,0x4(%edx)
8010442d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104430:	8b 40 04             	mov    0x4(%eax),%eax
80104433:	85 c0                	test   %eax,%eax
80104435:	75 0c                	jne    80104443 <userinit+0x3e>
    panic("userinit: out of memory?");
80104437:	c7 04 24 ec 8a 10 80 	movl   $0x80108aec,(%esp)
8010443e:	e8 fa c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104443:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444b:	8b 40 04             	mov    0x4(%eax),%eax
8010444e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104452:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
80104459:	80 
8010445a:	89 04 24             	mov    %eax,(%esp)
8010445d:	e8 bf 3d 00 00       	call   80108221 <inituvm>
  p->sz = PGSIZE;
80104462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104465:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	8b 40 18             	mov    0x18(%eax),%eax
80104471:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104478:	00 
80104479:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104480:	00 
80104481:	89 04 24             	mov    %eax,(%esp)
80104484:	e8 39 0f 00 00       	call   801053c2 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448c:	8b 40 18             	mov    0x18(%eax),%eax
8010448f:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104498:	8b 40 18             	mov    0x18(%eax),%eax
8010449b:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a4:	8b 40 18             	mov    0x18(%eax),%eax
801044a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044aa:	8b 52 18             	mov    0x18(%edx),%edx
801044ad:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044b1:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b8:	8b 40 18             	mov    0x18(%eax),%eax
801044bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044be:	8b 52 18             	mov    0x18(%edx),%edx
801044c1:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044c5:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801044c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cc:	8b 40 18             	mov    0x18(%eax),%eax
801044cf:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801044d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d9:	8b 40 18             	mov    0x18(%eax),%eax
801044dc:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e6:	8b 40 18             	mov    0x18(%eax),%eax
801044e9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f3:	83 c0 6c             	add    $0x6c,%eax
801044f6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801044fd:	00 
801044fe:	c7 44 24 04 05 8b 10 	movl   $0x80108b05,0x4(%esp)
80104505:	80 
80104506:	89 04 24             	mov    %eax,(%esp)
80104509:	e8 e4 10 00 00       	call   801055f2 <safestrcpy>
  p->cwd = namei("/");
8010450e:	c7 04 24 0e 8b 10 80 	movl   $0x80108b0e,(%esp)
80104515:	e8 cc e1 ff ff       	call   801026e6 <namei>
8010451a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010451d:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010452a:	c9                   	leave  
8010452b:	c3                   	ret    

8010452c <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010452c:	55                   	push   %ebp
8010452d:	89 e5                	mov    %esp,%ebp
8010452f:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104532:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104538:	8b 00                	mov    (%eax),%eax
8010453a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010453d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104541:	7e 34                	jle    80104577 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104543:	8b 45 08             	mov    0x8(%ebp),%eax
80104546:	89 c2                	mov    %eax,%edx
80104548:	03 55 f4             	add    -0xc(%ebp),%edx
8010454b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104551:	8b 40 04             	mov    0x4(%eax),%eax
80104554:	89 54 24 08          	mov    %edx,0x8(%esp)
80104558:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010455b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010455f:	89 04 24             	mov    %eax,(%esp)
80104562:	e8 34 3e 00 00       	call   8010839b <allocuvm>
80104567:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010456a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010456e:	75 41                	jne    801045b1 <growproc+0x85>
      return -1;
80104570:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104575:	eb 58                	jmp    801045cf <growproc+0xa3>
  } else if(n < 0){
80104577:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010457b:	79 34                	jns    801045b1 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010457d:	8b 45 08             	mov    0x8(%ebp),%eax
80104580:	89 c2                	mov    %eax,%edx
80104582:	03 55 f4             	add    -0xc(%ebp),%edx
80104585:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010458b:	8b 40 04             	mov    0x4(%eax),%eax
8010458e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104592:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104595:	89 54 24 04          	mov    %edx,0x4(%esp)
80104599:	89 04 24             	mov    %eax,(%esp)
8010459c:	e8 d4 3e 00 00       	call   80108475 <deallocuvm>
801045a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045a8:	75 07                	jne    801045b1 <growproc+0x85>
      return -1;
801045aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045af:	eb 1e                	jmp    801045cf <growproc+0xa3>
  }
  proc->sz = sz;
801045b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ba:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801045bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c2:	89 04 24             	mov    %eax,(%esp)
801045c5:	e8 f0 3a 00 00       	call   801080ba <switchuvm>
  return 0;
801045ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045cf:	c9                   	leave  
801045d0:	c3                   	ret    

801045d1 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045d1:	55                   	push   %ebp
801045d2:	89 e5                	mov    %esp,%ebp
801045d4:	57                   	push   %edi
801045d5:	56                   	push   %esi
801045d6:	53                   	push   %ebx
801045d7:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801045da:	e8 24 fd ff ff       	call   80104303 <allocproc>
801045df:	89 45 e0             	mov    %eax,-0x20(%ebp)
801045e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801045e6:	75 0a                	jne    801045f2 <fork+0x21>
    return -1;
801045e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ed:	e9 6c 01 00 00       	jmp    8010475e <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801045f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f8:	8b 10                	mov    (%eax),%edx
801045fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104600:	8b 40 04             	mov    0x4(%eax),%eax
80104603:	89 54 24 04          	mov    %edx,0x4(%esp)
80104607:	89 04 24             	mov    %eax,(%esp)
8010460a:	e8 f6 3f 00 00       	call   80108605 <copyuvm>
8010460f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104612:	89 42 04             	mov    %eax,0x4(%edx)
80104615:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104618:	8b 40 04             	mov    0x4(%eax),%eax
8010461b:	85 c0                	test   %eax,%eax
8010461d:	75 2c                	jne    8010464b <fork+0x7a>
    kfree(np->kstack);
8010461f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104622:	8b 40 08             	mov    0x8(%eax),%eax
80104625:	89 04 24             	mov    %eax,(%esp)
80104628:	e8 15 e7 ff ff       	call   80102d42 <kfree>
    np->kstack = 0;
8010462d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104630:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104637:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010463a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104646:	e9 13 01 00 00       	jmp    8010475e <fork+0x18d>
  }
  np->sz = proc->sz;
8010464b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104651:	8b 10                	mov    (%eax),%edx
80104653:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104656:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104658:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010465f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104662:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104665:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104668:	8b 50 18             	mov    0x18(%eax),%edx
8010466b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104671:	8b 40 18             	mov    0x18(%eax),%eax
80104674:	89 c3                	mov    %eax,%ebx
80104676:	b8 13 00 00 00       	mov    $0x13,%eax
8010467b:	89 d7                	mov    %edx,%edi
8010467d:	89 de                	mov    %ebx,%esi
8010467f:	89 c1                	mov    %eax,%ecx
80104681:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104683:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104686:	8b 40 18             	mov    0x18(%eax),%eax
80104689:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104690:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104697:	eb 3d                	jmp    801046d6 <fork+0x105>
    if(proc->ofile[i])
80104699:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010469f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046a2:	83 c2 08             	add    $0x8,%edx
801046a5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046a9:	85 c0                	test   %eax,%eax
801046ab:	74 25                	je     801046d2 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801046ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046b6:	83 c2 08             	add    $0x8,%edx
801046b9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046bd:	89 04 24             	mov    %eax,(%esp)
801046c0:	e8 93 cb ff ff       	call   80101258 <filedup>
801046c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046c8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046cb:	83 c1 08             	add    $0x8,%ecx
801046ce:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801046d2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801046d6:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046da:	7e bd                	jle    80104699 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801046dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e2:	8b 40 68             	mov    0x68(%eax),%eax
801046e5:	89 04 24             	mov    %eax,(%esp)
801046e8:	e8 25 d4 ff ff       	call   80101b12 <idup>
801046ed:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046f0:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
801046f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f6:	8b 40 10             	mov    0x10(%eax),%eax
801046f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
801046fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ff:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104706:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010470f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104712:	83 c0 6c             	add    $0x6c,%eax
80104715:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010471c:	00 
8010471d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104721:	89 04 24             	mov    %eax,(%esp)
80104724:	e8 c9 0e 00 00       	call   801055f2 <safestrcpy>
  acquire(&tickslock);
80104729:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104730:	e8 3e 0a 00 00       	call   80105173 <acquire>
  np->ctime = ticks;
80104735:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
8010473a:	89 c2                	mov    %eax,%edx
8010473c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473f:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
80104742:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104749:	e8 87 0a 00 00       	call   801051d5 <release>
  np->rtime = 0;
8010474e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104751:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104758:	00 00 00 
    case _3Q:
      np->priority = HIGH;
      np->qvalue = 0;
      break;
  }
  return pid;
8010475b:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010475e:	83 c4 2c             	add    $0x2c,%esp
80104761:	5b                   	pop    %ebx
80104762:	5e                   	pop    %esi
80104763:	5f                   	pop    %edi
80104764:	5d                   	pop    %ebp
80104765:	c3                   	ret    

80104766 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104766:	55                   	push   %ebp
80104767:	89 e5                	mov    %esp,%ebp
80104769:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  
  if(proc == initproc)
8010476c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104773:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104778:	39 c2                	cmp    %eax,%edx
8010477a:	75 0c                	jne    80104788 <exit+0x22>
    panic("init exiting");
8010477c:	c7 04 24 10 8b 10 80 	movl   $0x80108b10,(%esp)
80104783:	e8 b5 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104788:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010478f:	eb 44                	jmp    801047d5 <exit+0x6f>
    if(proc->ofile[fd]){
80104791:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104797:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010479a:	83 c2 08             	add    $0x8,%edx
8010479d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047a1:	85 c0                	test   %eax,%eax
801047a3:	74 2c                	je     801047d1 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047ae:	83 c2 08             	add    $0x8,%edx
801047b1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047b5:	89 04 24             	mov    %eax,(%esp)
801047b8:	e8 e3 ca ff ff       	call   801012a0 <fileclose>
      proc->ofile[fd] = 0;
801047bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047c6:	83 c2 08             	add    $0x8,%edx
801047c9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047d0:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801047d5:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801047d9:	7e b6                	jle    80104791 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
801047db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e1:	8b 40 68             	mov    0x68(%eax),%eax
801047e4:	89 04 24             	mov    %eax,(%esp)
801047e7:	e8 0b d5 ff ff       	call   80101cf7 <iput>
  proc->cwd = 0;
801047ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f2:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801047f9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104800:	e8 6e 09 00 00       	call   80105173 <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104805:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480b:	8b 40 14             	mov    0x14(%eax),%eax
8010480e:	89 04 24             	mov    %eax,(%esp)
80104811:	e8 8f 06 00 00       	call   80104ea5 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104816:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010481d:	eb 3b                	jmp    8010485a <exit+0xf4>
    if(p->parent == proc){
8010481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104822:	8b 50 14             	mov    0x14(%eax),%edx
80104825:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010482b:	39 c2                	cmp    %eax,%edx
8010482d:	75 24                	jne    80104853 <exit+0xed>
      p->parent = initproc;
8010482f:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104838:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010483b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483e:	8b 40 0c             	mov    0xc(%eax),%eax
80104841:	83 f8 05             	cmp    $0x5,%eax
80104844:	75 0d                	jne    80104853 <exit+0xed>
        wakeup1(initproc);
80104846:	a1 48 b6 10 80       	mov    0x8010b648,%eax
8010484b:	89 04 24             	mov    %eax,(%esp)
8010484e:	e8 52 06 00 00       	call   80104ea5 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104853:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
8010485a:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104861:	72 bc                	jb     8010481f <exit+0xb9>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->priority = -1;
80104863:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104869:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
80104870:	ff ff ff 
  acquire(&tickslock);
80104873:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
8010487a:	e8 f4 08 00 00       	call   80105173 <acquire>
  proc->etime = ticks;
8010487f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104885:	8b 15 c0 2c 11 80    	mov    0x80112cc0,%edx
8010488b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
80104891:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104898:	e8 38 09 00 00       	call   801051d5 <release>
  proc->state = ZOMBIE;
8010489d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048aa:	e8 4b 04 00 00       	call   80104cfa <sched>
  panic("zombie exit");
801048af:	c7 04 24 1d 8b 10 80 	movl   $0x80108b1d,(%esp)
801048b6:	e8 82 bc ff ff       	call   8010053d <panic>

801048bb <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048bb:	55                   	push   %ebp
801048bc:	89 e5                	mov    %esp,%ebp
801048be:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801048c1:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801048c8:	e8 a6 08 00 00       	call   80105173 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801048cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d4:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801048db:	e9 9d 00 00 00       	jmp    8010497d <wait+0xc2>
      if(p->parent != proc)
801048e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e3:	8b 50 14             	mov    0x14(%eax),%edx
801048e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ec:	39 c2                	cmp    %eax,%edx
801048ee:	0f 85 81 00 00 00    	jne    80104975 <wait+0xba>
        continue;
      havekids = 1;
801048f4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fe:	8b 40 0c             	mov    0xc(%eax),%eax
80104901:	83 f8 05             	cmp    $0x5,%eax
80104904:	75 70                	jne    80104976 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104909:	8b 40 10             	mov    0x10(%eax),%eax
8010490c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010490f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104912:	8b 40 08             	mov    0x8(%eax),%eax
80104915:	89 04 24             	mov    %eax,(%esp)
80104918:	e8 25 e4 ff ff       	call   80102d42 <kfree>
        p->kstack = 0;
8010491d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104920:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492a:	8b 40 04             	mov    0x4(%eax),%eax
8010492d:	89 04 24             	mov    %eax,(%esp)
80104930:	e8 fc 3b 00 00       	call   80108531 <freevm>
        p->state = UNUSED;
80104935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104938:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104942:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104956:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104964:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010496b:	e8 65 08 00 00       	call   801051d5 <release>
        return pid;
80104970:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104973:	eb 56                	jmp    801049cb <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104975:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104976:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
8010497d:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104984:	0f 82 56 ff ff ff    	jb     801048e0 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010498a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010498e:	74 0d                	je     8010499d <wait+0xe2>
80104990:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104996:	8b 40 24             	mov    0x24(%eax),%eax
80104999:	85 c0                	test   %eax,%eax
8010499b:	74 13                	je     801049b0 <wait+0xf5>
      release(&ptable.lock);
8010499d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049a4:	e8 2c 08 00 00       	call   801051d5 <release>
      return -1;
801049a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049ae:	eb 1b                	jmp    801049cb <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801049b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b6:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
801049bd:	80 
801049be:	89 04 24             	mov    %eax,(%esp)
801049c1:	e8 44 04 00 00       	call   80104e0a <sleep>
  }
801049c6:	e9 02 ff ff ff       	jmp    801048cd <wait+0x12>
}
801049cb:	c9                   	leave  
801049cc:	c3                   	ret    

801049cd <wait2>:

int
wait2(int *wtime, int *rtime)
{
801049cd:	55                   	push   %ebp
801049ce:	89 e5                	mov    %esp,%ebp
801049d0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801049d3:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049da:	e8 94 07 00 00       	call   80105173 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801049df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e6:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801049ed:	e9 d0 00 00 00       	jmp    80104ac2 <wait2+0xf5>
      if(p->parent != proc)
801049f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f5:	8b 50 14             	mov    0x14(%eax),%edx
801049f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fe:	39 c2                	cmp    %eax,%edx
80104a00:	0f 85 b4 00 00 00    	jne    80104aba <wait2+0xed>
        continue;
      havekids = 1;
80104a06:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a10:	8b 40 0c             	mov    0xc(%eax),%eax
80104a13:	83 f8 05             	cmp    $0x5,%eax
80104a16:	0f 85 9f 00 00 00    	jne    80104abb <wait2+0xee>
	*rtime = p->rtime;
80104a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1f:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a25:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a28:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2d:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a36:	8b 40 7c             	mov    0x7c(%eax),%eax
80104a39:	29 c2                	sub    %eax,%edx
80104a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3e:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104a44:	29 c2                	sub    %eax,%edx
80104a46:	8b 45 08             	mov    0x8(%ebp),%eax
80104a49:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4e:	8b 40 10             	mov    0x10(%eax),%eax
80104a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a57:	8b 40 08             	mov    0x8(%eax),%eax
80104a5a:	89 04 24             	mov    %eax,(%esp)
80104a5d:	e8 e0 e2 ff ff       	call   80102d42 <kfree>
        p->kstack = 0;
80104a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6f:	8b 40 04             	mov    0x4(%eax),%eax
80104a72:	89 04 24             	mov    %eax,(%esp)
80104a75:	e8 b7 3a 00 00       	call   80108531 <freevm>
        p->state = UNUSED;
80104a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a87:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a91:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa2:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104aa9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ab0:	e8 20 07 00 00       	call   801051d5 <release>
        return pid;
80104ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab8:	eb 56                	jmp    80104b10 <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104aba:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104abb:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104ac2:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104ac9:	0f 82 23 ff ff ff    	jb     801049f2 <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104acf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ad3:	74 0d                	je     80104ae2 <wait2+0x115>
80104ad5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104adb:	8b 40 24             	mov    0x24(%eax),%eax
80104ade:	85 c0                	test   %eax,%eax
80104ae0:	74 13                	je     80104af5 <wait2+0x128>
      release(&ptable.lock);
80104ae2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ae9:	e8 e7 06 00 00       	call   801051d5 <release>
      return -1;
80104aee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104af3:	eb 1b                	jmp    80104b10 <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104af5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104afb:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b02:	80 
80104b03:	89 04 24             	mov    %eax,(%esp)
80104b06:	e8 ff 02 00 00       	call   80104e0a <sleep>
  }
80104b0b:	e9 cf fe ff ff       	jmp    801049df <wait2+0x12>
  
  
  return proc->pid;
}
80104b10:	c9                   	leave  
80104b11:	c3                   	ret    

80104b12 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b12:	55                   	push   %ebp
80104b13:	89 e5                	mov    %esp,%ebp
80104b15:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1e:	8b 40 18             	mov    0x18(%eax),%eax
80104b21:	8b 40 44             	mov    0x44(%eax),%eax
80104b24:	89 c2                	mov    %eax,%edx
80104b26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2c:	8b 40 04             	mov    0x4(%eax),%eax
80104b2f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b33:	89 04 24             	mov    %eax,(%esp)
80104b36:	e8 db 3b 00 00       	call   80108716 <uva2ka>
80104b3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104b3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b44:	8b 40 18             	mov    0x18(%eax),%eax
80104b47:	8b 40 44             	mov    0x44(%eax),%eax
80104b4a:	25 ff 0f 00 00       	and    $0xfff,%eax
80104b4f:	85 c0                	test   %eax,%eax
80104b51:	75 0c                	jne    80104b5f <register_handler+0x4d>
    panic("esp_offset == 0");
80104b53:	c7 04 24 29 8b 10 80 	movl   $0x80108b29,(%esp)
80104b5a:	e8 de b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104b5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b65:	8b 40 18             	mov    0x18(%eax),%eax
80104b68:	8b 40 44             	mov    0x44(%eax),%eax
80104b6b:	83 e8 04             	sub    $0x4,%eax
80104b6e:	25 ff 0f 00 00       	and    $0xfff,%eax
80104b73:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104b76:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b7d:	8b 52 18             	mov    0x18(%edx),%edx
80104b80:	8b 52 38             	mov    0x38(%edx),%edx
80104b83:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104b85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b8b:	8b 40 18             	mov    0x18(%eax),%eax
80104b8e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b95:	8b 52 18             	mov    0x18(%edx),%edx
80104b98:	8b 52 44             	mov    0x44(%edx),%edx
80104b9b:	83 ea 04             	sub    $0x4,%edx
80104b9e:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104ba1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba7:	8b 40 18             	mov    0x18(%eax),%eax
80104baa:	8b 55 08             	mov    0x8(%ebp),%edx
80104bad:	89 50 38             	mov    %edx,0x38(%eax)
}
80104bb0:	c9                   	leave  
80104bb1:	c3                   	ret    

80104bb2 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104bb2:	55                   	push   %ebp
80104bb3:	89 e5                	mov    %esp,%ebp
80104bb5:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct proc *medium;
  struct proc *high;
  struct proc *head = 0;
80104bb8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  struct proc *t = ptable.proc;
80104bbf:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
  uint grt_min;
  
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104bc6:	e8 16 f7 ff ff       	call   801042e1 <sti>
    highflag = 0;
80104bcb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    mediumflag = 0;
80104bd2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    lowflag = 0;
80104bd9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    frr_min = 0;
80104be0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    grt_min = 0;
80104be7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    
    if(head && p==head)
80104bee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bf2:	74 17                	je     80104c0b <scheduler+0x59>
80104bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104bfa:	75 0f                	jne    80104c0b <scheduler+0x59>
      t = ++head;
80104bfc:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
80104c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c06:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c09:	eb 0c                	jmp    80104c17 <scheduler+0x65>
    else if(head)
80104c0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c0f:	74 06                	je     80104c17 <scheduler+0x65>
      t = head;
80104c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c14:	89 45 ec             	mov    %eax,-0x14(%ebp)
    
    acquire(&tickslock);
80104c17:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104c1e:	e8 50 05 00 00       	call   80105173 <acquire>
    currentime = ticks;
80104c23:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80104c28:	89 45 d0             	mov    %eax,-0x30(%ebp)
    release(&tickslock);  
80104c2b:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104c32:	e8 9e 05 00 00       	call   801051d5 <release>
    int i=0;
80104c37:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    acquire(&ptable.lock); 
80104c3e:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104c45:	e8 29 05 00 00       	call   80105173 <acquire>
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104c4a:	e9 90 00 00 00       	jmp    80104cdf <scheduler+0x12d>
    {
      if(t >= &ptable.proc[NPROC])
80104c4f:	81 7d ec 74 24 11 80 	cmpl   $0x80112474,-0x14(%ebp)
80104c56:	72 07                	jb     80104c5f <scheduler+0xad>
	t = ptable.proc;
80104c58:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
      if(t->state != RUNNABLE)
80104c5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c62:	8b 40 0c             	mov    0xc(%eax),%eax
80104c65:	83 f8 03             	cmp    $0x3,%eax
80104c68:	74 09                	je     80104c73 <scheduler+0xc1>
      {
	t++;
80104c6a:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
	continue;
80104c71:	eb 68                	jmp    80104cdb <scheduler+0x129>
      }
      switch(SCHEDFLAG)
      {
	default:
	  p = t;
80104c73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c76:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  proc = p;
80104c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7c:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
80104c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c85:	89 04 24             	mov    %eax,(%esp)
80104c88:	e8 2d 34 00 00       	call   801080ba <switchuvm>
	  p->state = RUNNING;
80104c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c90:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  p->quanta = QUANTA;
80104c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9a:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104ca1:	00 00 00 
	  swtch(&cpu->scheduler, proc->context);
80104ca4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104caa:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cad:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104cb4:	83 c2 04             	add    $0x4,%edx
80104cb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cbb:	89 14 24             	mov    %edx,(%esp)
80104cbe:	e8 a5 09 00 00       	call   80105668 <swtch>
	  switchkvm();
80104cc3:	e8 d5 33 00 00       	call   8010809d <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
80104cc8:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104ccf:	00 00 00 00 
	  break;
80104cd3:	90                   	nop
	    lowflag = 1;
	    t->quanta = QUANTA;
	  }
	  break;
      }
      t++;
80104cd4:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
    acquire(&tickslock);
    currentime = ticks;
    release(&tickslock);  
    int i=0;
    acquire(&ptable.lock); 
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104cdb:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104cdf:	83 7d e8 3f          	cmpl   $0x3f,-0x18(%ebp)
80104ce3:	0f 8e 66 ff ff ff    	jle    80104c4f <scheduler+0x9d>
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
      }
    }
    release(&ptable.lock);
80104ce9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104cf0:	e8 e0 04 00 00       	call   801051d5 <release>
    }
80104cf5:	e9 cc fe ff ff       	jmp    80104bc6 <scheduler+0x14>

80104cfa <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104cfa:	55                   	push   %ebp
80104cfb:	89 e5                	mov    %esp,%ebp
80104cfd:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d00:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d07:	e8 85 05 00 00       	call   80105291 <holding>
80104d0c:	85 c0                	test   %eax,%eax
80104d0e:	75 0c                	jne    80104d1c <sched+0x22>
    panic("sched ptable.lock");
80104d10:	c7 04 24 39 8b 10 80 	movl   $0x80108b39,(%esp)
80104d17:	e8 21 b8 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104d1c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d22:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d28:	83 f8 01             	cmp    $0x1,%eax
80104d2b:	74 0c                	je     80104d39 <sched+0x3f>
    panic("sched locks");
80104d2d:	c7 04 24 4b 8b 10 80 	movl   $0x80108b4b,(%esp)
80104d34:	e8 04 b8 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104d39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d3f:	8b 40 0c             	mov    0xc(%eax),%eax
80104d42:	83 f8 04             	cmp    $0x4,%eax
80104d45:	75 0c                	jne    80104d53 <sched+0x59>
    panic("sched running");
80104d47:	c7 04 24 57 8b 10 80 	movl   $0x80108b57,(%esp)
80104d4e:	e8 ea b7 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104d53:	e8 74 f5 ff ff       	call   801042cc <readeflags>
80104d58:	25 00 02 00 00       	and    $0x200,%eax
80104d5d:	85 c0                	test   %eax,%eax
80104d5f:	74 0c                	je     80104d6d <sched+0x73>
    panic("sched interruptible");
80104d61:	c7 04 24 65 8b 10 80 	movl   $0x80108b65,(%esp)
80104d68:	e8 d0 b7 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104d6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d73:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104d7c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d82:	8b 40 04             	mov    0x4(%eax),%eax
80104d85:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d8c:	83 c2 1c             	add    $0x1c,%edx
80104d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d93:	89 14 24             	mov    %edx,(%esp)
80104d96:	e8 cd 08 00 00       	call   80105668 <swtch>
  cpu->intena = intena;
80104d9b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104da1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104da4:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104daa:	c9                   	leave  
80104dab:	c3                   	ret    

80104dac <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104dac:	55                   	push   %ebp
80104dad:	89 e5                	mov    %esp,%ebp
80104daf:	83 ec 18             	sub    $0x18,%esp
	proc->qvalue = ticks;
	release(&tickslock);
      }
      break;
  }
  acquire(&ptable.lock);  //DOC: yieldlock
80104db2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104db9:	e8 b5 03 00 00       	call   80105173 <acquire>
  proc->state = RUNNABLE;
80104dbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104dcb:	e8 2a ff ff ff       	call   80104cfa <sched>
  release(&ptable.lock);
80104dd0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104dd7:	e8 f9 03 00 00       	call   801051d5 <release>
  
}
80104ddc:	c9                   	leave  
80104ddd:	c3                   	ret    

80104dde <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104dde:	55                   	push   %ebp
80104ddf:	89 e5                	mov    %esp,%ebp
80104de1:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104de4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104deb:	e8 e5 03 00 00       	call   801051d5 <release>

  if (first) {
80104df0:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104df5:	85 c0                	test   %eax,%eax
80104df7:	74 0f                	je     80104e08 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104df9:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104e00:	00 00 00 
    initlog();
80104e03:	e8 e4 e4 ff ff       	call   801032ec <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104e08:	c9                   	leave  
80104e09:	c3                   	ret    

80104e0a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e0a:	55                   	push   %ebp
80104e0b:	89 e5                	mov    %esp,%ebp
80104e0d:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104e10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e16:	85 c0                	test   %eax,%eax
80104e18:	75 0c                	jne    80104e26 <sleep+0x1c>
    panic("sleep");
80104e1a:	c7 04 24 79 8b 10 80 	movl   $0x80108b79,(%esp)
80104e21:	e8 17 b7 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104e26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e2a:	75 0c                	jne    80104e38 <sleep+0x2e>
    panic("sleep without lk");
80104e2c:	c7 04 24 7f 8b 10 80 	movl   $0x80108b7f,(%esp)
80104e33:	e8 05 b7 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e38:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e3f:	74 17                	je     80104e58 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e41:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e48:	e8 26 03 00 00       	call   80105173 <acquire>
    release(lk);
80104e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e50:	89 04 24             	mov    %eax,(%esp)
80104e53:	e8 7d 03 00 00       	call   801051d5 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104e58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80104e61:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104e64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e6a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104e71:	e8 84 fe ff ff       	call   80104cfa <sched>

  // Tidy up.
  proc->chan = 0;
80104e76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e7c:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e83:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e8a:	74 17                	je     80104ea3 <sleep+0x99>
    release(&ptable.lock);
80104e8c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e93:	e8 3d 03 00 00       	call   801051d5 <release>
    acquire(lk);
80104e98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e9b:	89 04 24             	mov    %eax,(%esp)
80104e9e:	e8 d0 02 00 00       	call   80105173 <acquire>
  }
}
80104ea3:	c9                   	leave  
80104ea4:	c3                   	ret    

80104ea5 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ea5:	55                   	push   %ebp
80104ea6:	89 e5                	mov    %esp,%ebp
80104ea8:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104eab:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104eb2:	eb 27                	jmp    80104edb <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104eb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb7:	8b 40 0c             	mov    0xc(%eax),%eax
80104eba:	83 f8 02             	cmp    $0x2,%eax
80104ebd:	75 15                	jne    80104ed4 <wakeup1+0x2f>
80104ebf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ec2:	8b 40 20             	mov    0x20(%eax),%eax
80104ec5:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ec8:	75 0a                	jne    80104ed4 <wakeup1+0x2f>
    {
      p->state = RUNNABLE;
80104eca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ecd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ed4:	81 45 fc 94 00 00 00 	addl   $0x94,-0x4(%ebp)
80104edb:	81 7d fc 74 24 11 80 	cmpl   $0x80112474,-0x4(%ebp)
80104ee2:	72 d0                	jb     80104eb4 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
    }
}
80104ee4:	c9                   	leave  
80104ee5:	c3                   	ret    

80104ee6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
80104ee9:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104eec:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ef3:	e8 7b 02 00 00       	call   80105173 <acquire>
  wakeup1(chan);
80104ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80104efb:	89 04 24             	mov    %eax,(%esp)
80104efe:	e8 a2 ff ff ff       	call   80104ea5 <wakeup1>
  release(&ptable.lock);
80104f03:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f0a:	e8 c6 02 00 00       	call   801051d5 <release>
}
80104f0f:	c9                   	leave  
80104f10:	c3                   	ret    

80104f11 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f11:	55                   	push   %ebp
80104f12:	89 e5                	mov    %esp,%ebp
80104f14:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f17:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f1e:	e8 50 02 00 00       	call   80105173 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f23:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104f2a:	eb 44                	jmp    80104f70 <kill+0x5f>
    if(p->pid == pid){
80104f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2f:	8b 40 10             	mov    0x10(%eax),%eax
80104f32:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f35:	75 32                	jne    80104f69 <kill+0x58>
      p->killed = 1;
80104f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f44:	8b 40 0c             	mov    0xc(%eax),%eax
80104f47:	83 f8 02             	cmp    $0x2,%eax
80104f4a:	75 0a                	jne    80104f56 <kill+0x45>
        p->state = RUNNABLE;
80104f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f56:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f5d:	e8 73 02 00 00       	call   801051d5 <release>
      return 0;
80104f62:	b8 00 00 00 00       	mov    $0x0,%eax
80104f67:	eb 21                	jmp    80104f8a <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f69:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104f70:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104f77:	72 b3                	jb     80104f2c <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f79:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f80:	e8 50 02 00 00       	call   801051d5 <release>
  return -1;
80104f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f8a:	c9                   	leave  
80104f8b:	c3                   	ret    

80104f8c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f8c:	55                   	push   %ebp
80104f8d:	89 e5                	mov    %esp,%ebp
80104f8f:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f92:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104f99:	e9 db 00 00 00       	jmp    80105079 <procdump+0xed>
    if(p->state == UNUSED)
80104f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa1:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa4:	85 c0                	test   %eax,%eax
80104fa6:	0f 84 c5 00 00 00    	je     80105071 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104faf:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb2:	83 f8 05             	cmp    $0x5,%eax
80104fb5:	77 23                	ja     80104fda <procdump+0x4e>
80104fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fba:	8b 40 0c             	mov    0xc(%eax),%eax
80104fbd:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104fc4:	85 c0                	test   %eax,%eax
80104fc6:	74 12                	je     80104fda <procdump+0x4e>
      state = states[p->state];
80104fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fcb:	8b 40 0c             	mov    0xc(%eax),%eax
80104fce:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fd8:	eb 07                	jmp    80104fe1 <procdump+0x55>
    else
      state = "???";
80104fda:	c7 45 ec 90 8b 10 80 	movl   $0x80108b90,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe4:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fea:	8b 40 10             	mov    0x10(%eax),%eax
80104fed:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104ff1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104ff4:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ffc:	c7 04 24 94 8b 10 80 	movl   $0x80108b94,(%esp)
80105003:	e8 99 b3 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80105008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500b:	8b 40 0c             	mov    0xc(%eax),%eax
8010500e:	83 f8 02             	cmp    $0x2,%eax
80105011:	75 50                	jne    80105063 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105016:	8b 40 1c             	mov    0x1c(%eax),%eax
80105019:	8b 40 0c             	mov    0xc(%eax),%eax
8010501c:	83 c0 08             	add    $0x8,%eax
8010501f:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105022:	89 54 24 04          	mov    %edx,0x4(%esp)
80105026:	89 04 24             	mov    %eax,(%esp)
80105029:	e8 f6 01 00 00       	call   80105224 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010502e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105035:	eb 1b                	jmp    80105052 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80105037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010503e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105042:	c7 04 24 9d 8b 10 80 	movl   $0x80108b9d,(%esp)
80105049:	e8 53 b3 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010504e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105052:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105056:	7f 0b                	jg     80105063 <procdump+0xd7>
80105058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010505f:	85 c0                	test   %eax,%eax
80105061:	75 d4                	jne    80105037 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105063:	c7 04 24 a1 8b 10 80 	movl   $0x80108ba1,(%esp)
8010506a:	e8 32 b3 ff ff       	call   801003a1 <cprintf>
8010506f:	eb 01                	jmp    80105072 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105071:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105072:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
80105079:	81 7d f0 74 24 11 80 	cmpl   $0x80112474,-0x10(%ebp)
80105080:	0f 82 18 ff ff ff    	jb     80104f9e <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105086:	c9                   	leave  
80105087:	c3                   	ret    

80105088 <nice>:

int
nice(void)
{
80105088:	55                   	push   %ebp
80105089:	89 e5                	mov    %esp,%ebp
  if(proc)
8010508b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105091:	85 c0                	test   %eax,%eax
80105093:	74 70                	je     80105105 <nice+0x7d>
  {
    if(proc->priority == HIGH)
80105095:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010509b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801050a1:	83 f8 03             	cmp    $0x3,%eax
801050a4:	75 32                	jne    801050d8 <nice+0x50>
    {
      proc->priority--;
801050a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ac:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801050b2:	83 ea 01             	sub    $0x1,%edx
801050b5:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      proc->qvalue = proc->ctime;
801050bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050c8:	8b 52 7c             	mov    0x7c(%edx),%edx
801050cb:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
      return 0;
801050d1:	b8 00 00 00 00       	mov    $0x0,%eax
801050d6:	eb 32                	jmp    8010510a <nice+0x82>
    }
    else if(proc->priority == MEDIUM)
801050d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050de:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801050e4:	83 f8 02             	cmp    $0x2,%eax
801050e7:	75 1c                	jne    80105105 <nice+0x7d>
    {
      proc->priority--;
801050e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ef:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801050f5:	83 ea 01             	sub    $0x1,%edx
801050f8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      return 0;
801050fe:	b8 00 00 00 00       	mov    $0x0,%eax
80105103:	eb 05                	jmp    8010510a <nice+0x82>
    }
    
  }
  return -1;
80105105:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010510a:	5d                   	pop    %ebp
8010510b:	c3                   	ret    

8010510c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010510c:	55                   	push   %ebp
8010510d:	89 e5                	mov    %esp,%ebp
8010510f:	53                   	push   %ebx
80105110:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105113:	9c                   	pushf  
80105114:	5b                   	pop    %ebx
80105115:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105118:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010511b:	83 c4 10             	add    $0x10,%esp
8010511e:	5b                   	pop    %ebx
8010511f:	5d                   	pop    %ebp
80105120:	c3                   	ret    

80105121 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105121:	55                   	push   %ebp
80105122:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105124:	fa                   	cli    
}
80105125:	5d                   	pop    %ebp
80105126:	c3                   	ret    

80105127 <sti>:

static inline void
sti(void)
{
80105127:	55                   	push   %ebp
80105128:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010512a:	fb                   	sti    
}
8010512b:	5d                   	pop    %ebp
8010512c:	c3                   	ret    

8010512d <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010512d:	55                   	push   %ebp
8010512e:	89 e5                	mov    %esp,%ebp
80105130:	53                   	push   %ebx
80105131:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105134:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105137:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010513a:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010513d:	89 c3                	mov    %eax,%ebx
8010513f:	89 d8                	mov    %ebx,%eax
80105141:	f0 87 02             	lock xchg %eax,(%edx)
80105144:	89 c3                	mov    %eax,%ebx
80105146:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105149:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010514c:	83 c4 10             	add    $0x10,%esp
8010514f:	5b                   	pop    %ebx
80105150:	5d                   	pop    %ebp
80105151:	c3                   	ret    

80105152 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105152:	55                   	push   %ebp
80105153:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105155:	8b 45 08             	mov    0x8(%ebp),%eax
80105158:	8b 55 0c             	mov    0xc(%ebp),%edx
8010515b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010515e:	8b 45 08             	mov    0x8(%ebp),%eax
80105161:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105167:	8b 45 08             	mov    0x8(%ebp),%eax
8010516a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105171:	5d                   	pop    %ebp
80105172:	c3                   	ret    

80105173 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105173:	55                   	push   %ebp
80105174:	89 e5                	mov    %esp,%ebp
80105176:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105179:	e8 3d 01 00 00       	call   801052bb <pushcli>
  if(holding(lk))
8010517e:	8b 45 08             	mov    0x8(%ebp),%eax
80105181:	89 04 24             	mov    %eax,(%esp)
80105184:	e8 08 01 00 00       	call   80105291 <holding>
80105189:	85 c0                	test   %eax,%eax
8010518b:	74 0c                	je     80105199 <acquire+0x26>
    panic("acquire");
8010518d:	c7 04 24 cd 8b 10 80 	movl   $0x80108bcd,(%esp)
80105194:	e8 a4 b3 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105199:	90                   	nop
8010519a:	8b 45 08             	mov    0x8(%ebp),%eax
8010519d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801051a4:	00 
801051a5:	89 04 24             	mov    %eax,(%esp)
801051a8:	e8 80 ff ff ff       	call   8010512d <xchg>
801051ad:	85 c0                	test   %eax,%eax
801051af:	75 e9                	jne    8010519a <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
801051b4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051bb:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801051be:	8b 45 08             	mov    0x8(%ebp),%eax
801051c1:	83 c0 0c             	add    $0xc,%eax
801051c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801051c8:	8d 45 08             	lea    0x8(%ebp),%eax
801051cb:	89 04 24             	mov    %eax,(%esp)
801051ce:	e8 51 00 00 00       	call   80105224 <getcallerpcs>
}
801051d3:	c9                   	leave  
801051d4:	c3                   	ret    

801051d5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801051d5:	55                   	push   %ebp
801051d6:	89 e5                	mov    %esp,%ebp
801051d8:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801051db:	8b 45 08             	mov    0x8(%ebp),%eax
801051de:	89 04 24             	mov    %eax,(%esp)
801051e1:	e8 ab 00 00 00       	call   80105291 <holding>
801051e6:	85 c0                	test   %eax,%eax
801051e8:	75 0c                	jne    801051f6 <release+0x21>
    panic("release");
801051ea:	c7 04 24 d5 8b 10 80 	movl   $0x80108bd5,(%esp)
801051f1:	e8 47 b3 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
801051f6:	8b 45 08             	mov    0x8(%ebp),%eax
801051f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105200:	8b 45 08             	mov    0x8(%ebp),%eax
80105203:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010520a:	8b 45 08             	mov    0x8(%ebp),%eax
8010520d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105214:	00 
80105215:	89 04 24             	mov    %eax,(%esp)
80105218:	e8 10 ff ff ff       	call   8010512d <xchg>

  popcli();
8010521d:	e8 e1 00 00 00       	call   80105303 <popcli>
}
80105222:	c9                   	leave  
80105223:	c3                   	ret    

80105224 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105224:	55                   	push   %ebp
80105225:	89 e5                	mov    %esp,%ebp
80105227:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010522a:	8b 45 08             	mov    0x8(%ebp),%eax
8010522d:	83 e8 08             	sub    $0x8,%eax
80105230:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105233:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010523a:	eb 32                	jmp    8010526e <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010523c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105240:	74 47                	je     80105289 <getcallerpcs+0x65>
80105242:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105249:	76 3e                	jbe    80105289 <getcallerpcs+0x65>
8010524b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010524f:	74 38                	je     80105289 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105251:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105254:	c1 e0 02             	shl    $0x2,%eax
80105257:	03 45 0c             	add    0xc(%ebp),%eax
8010525a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010525d:	8b 52 04             	mov    0x4(%edx),%edx
80105260:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80105262:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105265:	8b 00                	mov    (%eax),%eax
80105267:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010526a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010526e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105272:	7e c8                	jle    8010523c <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105274:	eb 13                	jmp    80105289 <getcallerpcs+0x65>
    pcs[i] = 0;
80105276:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105279:	c1 e0 02             	shl    $0x2,%eax
8010527c:	03 45 0c             	add    0xc(%ebp),%eax
8010527f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105285:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105289:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010528d:	7e e7                	jle    80105276 <getcallerpcs+0x52>
    pcs[i] = 0;
}
8010528f:	c9                   	leave  
80105290:	c3                   	ret    

80105291 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105291:	55                   	push   %ebp
80105292:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105294:	8b 45 08             	mov    0x8(%ebp),%eax
80105297:	8b 00                	mov    (%eax),%eax
80105299:	85 c0                	test   %eax,%eax
8010529b:	74 17                	je     801052b4 <holding+0x23>
8010529d:	8b 45 08             	mov    0x8(%ebp),%eax
801052a0:	8b 50 08             	mov    0x8(%eax),%edx
801052a3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052a9:	39 c2                	cmp    %eax,%edx
801052ab:	75 07                	jne    801052b4 <holding+0x23>
801052ad:	b8 01 00 00 00       	mov    $0x1,%eax
801052b2:	eb 05                	jmp    801052b9 <holding+0x28>
801052b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052b9:	5d                   	pop    %ebp
801052ba:	c3                   	ret    

801052bb <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801052bb:	55                   	push   %ebp
801052bc:	89 e5                	mov    %esp,%ebp
801052be:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801052c1:	e8 46 fe ff ff       	call   8010510c <readeflags>
801052c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801052c9:	e8 53 fe ff ff       	call   80105121 <cli>
  if(cpu->ncli++ == 0)
801052ce:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052d4:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801052da:	85 d2                	test   %edx,%edx
801052dc:	0f 94 c1             	sete   %cl
801052df:	83 c2 01             	add    $0x1,%edx
801052e2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801052e8:	84 c9                	test   %cl,%cl
801052ea:	74 15                	je     80105301 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
801052ec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052f5:	81 e2 00 02 00 00    	and    $0x200,%edx
801052fb:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105301:	c9                   	leave  
80105302:	c3                   	ret    

80105303 <popcli>:

void
popcli(void)
{
80105303:	55                   	push   %ebp
80105304:	89 e5                	mov    %esp,%ebp
80105306:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105309:	e8 fe fd ff ff       	call   8010510c <readeflags>
8010530e:	25 00 02 00 00       	and    $0x200,%eax
80105313:	85 c0                	test   %eax,%eax
80105315:	74 0c                	je     80105323 <popcli+0x20>
    panic("popcli - interruptible");
80105317:	c7 04 24 dd 8b 10 80 	movl   $0x80108bdd,(%esp)
8010531e:	e8 1a b2 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105323:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105329:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010532f:	83 ea 01             	sub    $0x1,%edx
80105332:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105338:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010533e:	85 c0                	test   %eax,%eax
80105340:	79 0c                	jns    8010534e <popcli+0x4b>
    panic("popcli");
80105342:	c7 04 24 f4 8b 10 80 	movl   $0x80108bf4,(%esp)
80105349:	e8 ef b1 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010534e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105354:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010535a:	85 c0                	test   %eax,%eax
8010535c:	75 15                	jne    80105373 <popcli+0x70>
8010535e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105364:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010536a:	85 c0                	test   %eax,%eax
8010536c:	74 05                	je     80105373 <popcli+0x70>
    sti();
8010536e:	e8 b4 fd ff ff       	call   80105127 <sti>
}
80105373:	c9                   	leave  
80105374:	c3                   	ret    
80105375:	00 00                	add    %al,(%eax)
	...

80105378 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105378:	55                   	push   %ebp
80105379:	89 e5                	mov    %esp,%ebp
8010537b:	57                   	push   %edi
8010537c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010537d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105380:	8b 55 10             	mov    0x10(%ebp),%edx
80105383:	8b 45 0c             	mov    0xc(%ebp),%eax
80105386:	89 cb                	mov    %ecx,%ebx
80105388:	89 df                	mov    %ebx,%edi
8010538a:	89 d1                	mov    %edx,%ecx
8010538c:	fc                   	cld    
8010538d:	f3 aa                	rep stos %al,%es:(%edi)
8010538f:	89 ca                	mov    %ecx,%edx
80105391:	89 fb                	mov    %edi,%ebx
80105393:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105396:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105399:	5b                   	pop    %ebx
8010539a:	5f                   	pop    %edi
8010539b:	5d                   	pop    %ebp
8010539c:	c3                   	ret    

8010539d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010539d:	55                   	push   %ebp
8010539e:	89 e5                	mov    %esp,%ebp
801053a0:	57                   	push   %edi
801053a1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053a5:	8b 55 10             	mov    0x10(%ebp),%edx
801053a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ab:	89 cb                	mov    %ecx,%ebx
801053ad:	89 df                	mov    %ebx,%edi
801053af:	89 d1                	mov    %edx,%ecx
801053b1:	fc                   	cld    
801053b2:	f3 ab                	rep stos %eax,%es:(%edi)
801053b4:	89 ca                	mov    %ecx,%edx
801053b6:	89 fb                	mov    %edi,%ebx
801053b8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053bb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053be:	5b                   	pop    %ebx
801053bf:	5f                   	pop    %edi
801053c0:	5d                   	pop    %ebp
801053c1:	c3                   	ret    

801053c2 <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
801053c2:	55                   	push   %ebp
801053c3:	89 e5                	mov    %esp,%ebp
801053c5:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801053c8:	8b 45 08             	mov    0x8(%ebp),%eax
801053cb:	83 e0 03             	and    $0x3,%eax
801053ce:	85 c0                	test   %eax,%eax
801053d0:	75 49                	jne    8010541b <memset+0x59>
801053d2:	8b 45 10             	mov    0x10(%ebp),%eax
801053d5:	83 e0 03             	and    $0x3,%eax
801053d8:	85 c0                	test   %eax,%eax
801053da:	75 3f                	jne    8010541b <memset+0x59>
    c &= 0xFF;
801053dc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801053e3:	8b 45 10             	mov    0x10(%ebp),%eax
801053e6:	c1 e8 02             	shr    $0x2,%eax
801053e9:	89 c2                	mov    %eax,%edx
801053eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ee:	89 c1                	mov    %eax,%ecx
801053f0:	c1 e1 18             	shl    $0x18,%ecx
801053f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f6:	c1 e0 10             	shl    $0x10,%eax
801053f9:	09 c1                	or     %eax,%ecx
801053fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801053fe:	c1 e0 08             	shl    $0x8,%eax
80105401:	09 c8                	or     %ecx,%eax
80105403:	0b 45 0c             	or     0xc(%ebp),%eax
80105406:	89 54 24 08          	mov    %edx,0x8(%esp)
8010540a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010540e:	8b 45 08             	mov    0x8(%ebp),%eax
80105411:	89 04 24             	mov    %eax,(%esp)
80105414:	e8 84 ff ff ff       	call   8010539d <stosl>
80105419:	eb 19                	jmp    80105434 <memset+0x72>
  } else
    stosb(dst, c, n);
8010541b:	8b 45 10             	mov    0x10(%ebp),%eax
8010541e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105422:	8b 45 0c             	mov    0xc(%ebp),%eax
80105425:	89 44 24 04          	mov    %eax,0x4(%esp)
80105429:	8b 45 08             	mov    0x8(%ebp),%eax
8010542c:	89 04 24             	mov    %eax,(%esp)
8010542f:	e8 44 ff ff ff       	call   80105378 <stosb>
  return dst;
80105434:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105437:	c9                   	leave  
80105438:	c3                   	ret    

80105439 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105439:	55                   	push   %ebp
8010543a:	89 e5                	mov    %esp,%ebp
8010543c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010543f:	8b 45 08             	mov    0x8(%ebp),%eax
80105442:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105445:	8b 45 0c             	mov    0xc(%ebp),%eax
80105448:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010544b:	eb 32                	jmp    8010547f <memcmp+0x46>
    if(*s1 != *s2)
8010544d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105450:	0f b6 10             	movzbl (%eax),%edx
80105453:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105456:	0f b6 00             	movzbl (%eax),%eax
80105459:	38 c2                	cmp    %al,%dl
8010545b:	74 1a                	je     80105477 <memcmp+0x3e>
      return *s1 - *s2;
8010545d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105460:	0f b6 00             	movzbl (%eax),%eax
80105463:	0f b6 d0             	movzbl %al,%edx
80105466:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105469:	0f b6 00             	movzbl (%eax),%eax
8010546c:	0f b6 c0             	movzbl %al,%eax
8010546f:	89 d1                	mov    %edx,%ecx
80105471:	29 c1                	sub    %eax,%ecx
80105473:	89 c8                	mov    %ecx,%eax
80105475:	eb 1c                	jmp    80105493 <memcmp+0x5a>
    s1++, s2++;
80105477:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010547b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010547f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105483:	0f 95 c0             	setne  %al
80105486:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010548a:	84 c0                	test   %al,%al
8010548c:	75 bf                	jne    8010544d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010548e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105493:	c9                   	leave  
80105494:	c3                   	ret    

80105495 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105495:	55                   	push   %ebp
80105496:	89 e5                	mov    %esp,%ebp
80105498:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010549b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054a1:	8b 45 08             	mov    0x8(%ebp),%eax
801054a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054ad:	73 54                	jae    80105503 <memmove+0x6e>
801054af:	8b 45 10             	mov    0x10(%ebp),%eax
801054b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054b5:	01 d0                	add    %edx,%eax
801054b7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054ba:	76 47                	jbe    80105503 <memmove+0x6e>
    s += n;
801054bc:	8b 45 10             	mov    0x10(%ebp),%eax
801054bf:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054c2:	8b 45 10             	mov    0x10(%ebp),%eax
801054c5:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801054c8:	eb 13                	jmp    801054dd <memmove+0x48>
      *--d = *--s;
801054ca:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801054ce:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801054d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d5:	0f b6 10             	movzbl (%eax),%edx
801054d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054db:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801054dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054e1:	0f 95 c0             	setne  %al
801054e4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054e8:	84 c0                	test   %al,%al
801054ea:	75 de                	jne    801054ca <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801054ec:	eb 25                	jmp    80105513 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801054ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054f1:	0f b6 10             	movzbl (%eax),%edx
801054f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054f7:	88 10                	mov    %dl,(%eax)
801054f9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105501:	eb 01                	jmp    80105504 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105503:	90                   	nop
80105504:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105508:	0f 95 c0             	setne  %al
8010550b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010550f:	84 c0                	test   %al,%al
80105511:	75 db                	jne    801054ee <memmove+0x59>
      *d++ = *s++;

  return dst;
80105513:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105516:	c9                   	leave  
80105517:	c3                   	ret    

80105518 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105518:	55                   	push   %ebp
80105519:	89 e5                	mov    %esp,%ebp
8010551b:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010551e:	8b 45 10             	mov    0x10(%ebp),%eax
80105521:	89 44 24 08          	mov    %eax,0x8(%esp)
80105525:	8b 45 0c             	mov    0xc(%ebp),%eax
80105528:	89 44 24 04          	mov    %eax,0x4(%esp)
8010552c:	8b 45 08             	mov    0x8(%ebp),%eax
8010552f:	89 04 24             	mov    %eax,(%esp)
80105532:	e8 5e ff ff ff       	call   80105495 <memmove>
}
80105537:	c9                   	leave  
80105538:	c3                   	ret    

80105539 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105539:	55                   	push   %ebp
8010553a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010553c:	eb 0c                	jmp    8010554a <strncmp+0x11>
    n--, p++, q++;
8010553e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105542:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105546:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010554a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010554e:	74 1a                	je     8010556a <strncmp+0x31>
80105550:	8b 45 08             	mov    0x8(%ebp),%eax
80105553:	0f b6 00             	movzbl (%eax),%eax
80105556:	84 c0                	test   %al,%al
80105558:	74 10                	je     8010556a <strncmp+0x31>
8010555a:	8b 45 08             	mov    0x8(%ebp),%eax
8010555d:	0f b6 10             	movzbl (%eax),%edx
80105560:	8b 45 0c             	mov    0xc(%ebp),%eax
80105563:	0f b6 00             	movzbl (%eax),%eax
80105566:	38 c2                	cmp    %al,%dl
80105568:	74 d4                	je     8010553e <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010556a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010556e:	75 07                	jne    80105577 <strncmp+0x3e>
    return 0;
80105570:	b8 00 00 00 00       	mov    $0x0,%eax
80105575:	eb 18                	jmp    8010558f <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80105577:	8b 45 08             	mov    0x8(%ebp),%eax
8010557a:	0f b6 00             	movzbl (%eax),%eax
8010557d:	0f b6 d0             	movzbl %al,%edx
80105580:	8b 45 0c             	mov    0xc(%ebp),%eax
80105583:	0f b6 00             	movzbl (%eax),%eax
80105586:	0f b6 c0             	movzbl %al,%eax
80105589:	89 d1                	mov    %edx,%ecx
8010558b:	29 c1                	sub    %eax,%ecx
8010558d:	89 c8                	mov    %ecx,%eax
}
8010558f:	5d                   	pop    %ebp
80105590:	c3                   	ret    

80105591 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105591:	55                   	push   %ebp
80105592:	89 e5                	mov    %esp,%ebp
80105594:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105597:	8b 45 08             	mov    0x8(%ebp),%eax
8010559a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010559d:	90                   	nop
8010559e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055a2:	0f 9f c0             	setg   %al
801055a5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055a9:	84 c0                	test   %al,%al
801055ab:	74 30                	je     801055dd <strncpy+0x4c>
801055ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b0:	0f b6 10             	movzbl (%eax),%edx
801055b3:	8b 45 08             	mov    0x8(%ebp),%eax
801055b6:	88 10                	mov    %dl,(%eax)
801055b8:	8b 45 08             	mov    0x8(%ebp),%eax
801055bb:	0f b6 00             	movzbl (%eax),%eax
801055be:	84 c0                	test   %al,%al
801055c0:	0f 95 c0             	setne  %al
801055c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055c7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801055cb:	84 c0                	test   %al,%al
801055cd:	75 cf                	jne    8010559e <strncpy+0xd>
    ;
  while(n-- > 0)
801055cf:	eb 0c                	jmp    801055dd <strncpy+0x4c>
    *s++ = 0;
801055d1:	8b 45 08             	mov    0x8(%ebp),%eax
801055d4:	c6 00 00             	movb   $0x0,(%eax)
801055d7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055db:	eb 01                	jmp    801055de <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801055dd:	90                   	nop
801055de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055e2:	0f 9f c0             	setg   %al
801055e5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055e9:	84 c0                	test   %al,%al
801055eb:	75 e4                	jne    801055d1 <strncpy+0x40>
    *s++ = 0;
  return os;
801055ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055f0:	c9                   	leave  
801055f1:	c3                   	ret    

801055f2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801055f2:	55                   	push   %ebp
801055f3:	89 e5                	mov    %esp,%ebp
801055f5:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055f8:	8b 45 08             	mov    0x8(%ebp),%eax
801055fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801055fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105602:	7f 05                	jg     80105609 <safestrcpy+0x17>
    return os;
80105604:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105607:	eb 35                	jmp    8010563e <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105609:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010560d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105611:	7e 22                	jle    80105635 <safestrcpy+0x43>
80105613:	8b 45 0c             	mov    0xc(%ebp),%eax
80105616:	0f b6 10             	movzbl (%eax),%edx
80105619:	8b 45 08             	mov    0x8(%ebp),%eax
8010561c:	88 10                	mov    %dl,(%eax)
8010561e:	8b 45 08             	mov    0x8(%ebp),%eax
80105621:	0f b6 00             	movzbl (%eax),%eax
80105624:	84 c0                	test   %al,%al
80105626:	0f 95 c0             	setne  %al
80105629:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010562d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105631:	84 c0                	test   %al,%al
80105633:	75 d4                	jne    80105609 <safestrcpy+0x17>
    ;
  *s = 0;
80105635:	8b 45 08             	mov    0x8(%ebp),%eax
80105638:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010563b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010563e:	c9                   	leave  
8010563f:	c3                   	ret    

80105640 <strlen>:

int
strlen(const char *s)
{
80105640:	55                   	push   %ebp
80105641:	89 e5                	mov    %esp,%ebp
80105643:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105646:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010564d:	eb 04                	jmp    80105653 <strlen+0x13>
8010564f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105653:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105656:	03 45 08             	add    0x8(%ebp),%eax
80105659:	0f b6 00             	movzbl (%eax),%eax
8010565c:	84 c0                	test   %al,%al
8010565e:	75 ef                	jne    8010564f <strlen+0xf>
    ;
  return n;
80105660:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105663:	c9                   	leave  
80105664:	c3                   	ret    
80105665:	00 00                	add    %al,(%eax)
	...

80105668 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105668:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010566c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105670:	55                   	push   %ebp
  pushl %ebx
80105671:	53                   	push   %ebx
  pushl %esi
80105672:	56                   	push   %esi
  pushl %edi
80105673:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105674:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105676:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105678:	5f                   	pop    %edi
  popl %esi
80105679:	5e                   	pop    %esi
  popl %ebx
8010567a:	5b                   	pop    %ebx
  popl %ebp
8010567b:	5d                   	pop    %ebp
  ret
8010567c:	c3                   	ret    
8010567d:	00 00                	add    %al,(%eax)
	...

80105680 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
80105680:	55                   	push   %ebp
80105681:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
80105683:	8b 45 08             	mov    0x8(%ebp),%eax
80105686:	8b 00                	mov    (%eax),%eax
80105688:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010568b:	76 0f                	jbe    8010569c <fetchint+0x1c>
8010568d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105690:	8d 50 04             	lea    0x4(%eax),%edx
80105693:	8b 45 08             	mov    0x8(%ebp),%eax
80105696:	8b 00                	mov    (%eax),%eax
80105698:	39 c2                	cmp    %eax,%edx
8010569a:	76 07                	jbe    801056a3 <fetchint+0x23>
    return -1;
8010569c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056a1:	eb 0f                	jmp    801056b2 <fetchint+0x32>
  *ip = *(int*)(addr);
801056a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801056a6:	8b 10                	mov    (%eax),%edx
801056a8:	8b 45 10             	mov    0x10(%ebp),%eax
801056ab:	89 10                	mov    %edx,(%eax)
  return 0;
801056ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056b2:	5d                   	pop    %ebp
801056b3:	c3                   	ret    

801056b4 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
801056b4:	55                   	push   %ebp
801056b5:	89 e5                	mov    %esp,%ebp
801056b7:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
801056ba:	8b 45 08             	mov    0x8(%ebp),%eax
801056bd:	8b 00                	mov    (%eax),%eax
801056bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
801056c2:	77 07                	ja     801056cb <fetchstr+0x17>
    return -1;
801056c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c9:	eb 45                	jmp    80105710 <fetchstr+0x5c>
  *pp = (char*)addr;
801056cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801056ce:	8b 45 10             	mov    0x10(%ebp),%eax
801056d1:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
801056d3:	8b 45 08             	mov    0x8(%ebp),%eax
801056d6:	8b 00                	mov    (%eax),%eax
801056d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801056db:	8b 45 10             	mov    0x10(%ebp),%eax
801056de:	8b 00                	mov    (%eax),%eax
801056e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
801056e3:	eb 1e                	jmp    80105703 <fetchstr+0x4f>
    if(*s == 0)
801056e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056e8:	0f b6 00             	movzbl (%eax),%eax
801056eb:	84 c0                	test   %al,%al
801056ed:	75 10                	jne    801056ff <fetchstr+0x4b>
      return s - *pp;
801056ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056f2:	8b 45 10             	mov    0x10(%ebp),%eax
801056f5:	8b 00                	mov    (%eax),%eax
801056f7:	89 d1                	mov    %edx,%ecx
801056f9:	29 c1                	sub    %eax,%ecx
801056fb:	89 c8                	mov    %ecx,%eax
801056fd:	eb 11                	jmp    80105710 <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
801056ff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105703:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105706:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105709:	72 da                	jb     801056e5 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
8010570b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105710:	c9                   	leave  
80105711:	c3                   	ret    

80105712 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105712:	55                   	push   %ebp
80105713:	89 e5                	mov    %esp,%ebp
80105715:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105718:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010571e:	8b 40 18             	mov    0x18(%eax),%eax
80105721:	8b 50 44             	mov    0x44(%eax),%edx
80105724:	8b 45 08             	mov    0x8(%ebp),%eax
80105727:	c1 e0 02             	shl    $0x2,%eax
8010572a:	01 d0                	add    %edx,%eax
8010572c:	8d 48 04             	lea    0x4(%eax),%ecx
8010572f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105735:	8b 55 0c             	mov    0xc(%ebp),%edx
80105738:	89 54 24 08          	mov    %edx,0x8(%esp)
8010573c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105740:	89 04 24             	mov    %eax,(%esp)
80105743:	e8 38 ff ff ff       	call   80105680 <fetchint>
}
80105748:	c9                   	leave  
80105749:	c3                   	ret    

8010574a <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010574a:	55                   	push   %ebp
8010574b:	89 e5                	mov    %esp,%ebp
8010574d:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105750:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105753:	89 44 24 04          	mov    %eax,0x4(%esp)
80105757:	8b 45 08             	mov    0x8(%ebp),%eax
8010575a:	89 04 24             	mov    %eax,(%esp)
8010575d:	e8 b0 ff ff ff       	call   80105712 <argint>
80105762:	85 c0                	test   %eax,%eax
80105764:	79 07                	jns    8010576d <argptr+0x23>
    return -1;
80105766:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576b:	eb 3d                	jmp    801057aa <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010576d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105770:	89 c2                	mov    %eax,%edx
80105772:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105778:	8b 00                	mov    (%eax),%eax
8010577a:	39 c2                	cmp    %eax,%edx
8010577c:	73 16                	jae    80105794 <argptr+0x4a>
8010577e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105781:	89 c2                	mov    %eax,%edx
80105783:	8b 45 10             	mov    0x10(%ebp),%eax
80105786:	01 c2                	add    %eax,%edx
80105788:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010578e:	8b 00                	mov    (%eax),%eax
80105790:	39 c2                	cmp    %eax,%edx
80105792:	76 07                	jbe    8010579b <argptr+0x51>
    return -1;
80105794:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105799:	eb 0f                	jmp    801057aa <argptr+0x60>
  *pp = (char*)i;
8010579b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010579e:	89 c2                	mov    %eax,%edx
801057a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a3:	89 10                	mov    %edx,(%eax)
  return 0;
801057a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057aa:	c9                   	leave  
801057ab:	c3                   	ret    

801057ac <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057ac:	55                   	push   %ebp
801057ad:	89 e5                	mov    %esp,%ebp
801057af:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057b2:	8d 45 fc             	lea    -0x4(%ebp),%eax
801057b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801057b9:	8b 45 08             	mov    0x8(%ebp),%eax
801057bc:	89 04 24             	mov    %eax,(%esp)
801057bf:	e8 4e ff ff ff       	call   80105712 <argint>
801057c4:	85 c0                	test   %eax,%eax
801057c6:	79 07                	jns    801057cf <argstr+0x23>
    return -1;
801057c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057cd:	eb 1e                	jmp    801057ed <argstr+0x41>
  return fetchstr(proc, addr, pp);
801057cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d2:	89 c2                	mov    %eax,%edx
801057d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801057dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801057e5:	89 04 24             	mov    %eax,(%esp)
801057e8:	e8 c7 fe ff ff       	call   801056b4 <fetchstr>
}
801057ed:	c9                   	leave  
801057ee:	c3                   	ret    

801057ef <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801057ef:	55                   	push   %ebp
801057f0:	89 e5                	mov    %esp,%ebp
801057f2:	53                   	push   %ebx
801057f3:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801057f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057fc:	8b 40 18             	mov    0x18(%eax),%eax
801057ff:	8b 40 1c             	mov    0x1c(%eax),%eax
80105802:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105805:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105809:	78 2e                	js     80105839 <syscall+0x4a>
8010580b:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010580f:	7f 28                	jg     80105839 <syscall+0x4a>
80105811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105814:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010581b:	85 c0                	test   %eax,%eax
8010581d:	74 1a                	je     80105839 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
8010581f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105825:	8b 58 18             	mov    0x18(%eax),%ebx
80105828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582b:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105832:	ff d0                	call   *%eax
80105834:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105837:	eb 73                	jmp    801058ac <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105839:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010583d:	7e 30                	jle    8010586f <syscall+0x80>
8010583f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105842:	83 f8 17             	cmp    $0x17,%eax
80105845:	77 28                	ja     8010586f <syscall+0x80>
80105847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584a:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105851:	85 c0                	test   %eax,%eax
80105853:	74 1a                	je     8010586f <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105855:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010585b:	8b 58 18             	mov    0x18(%eax),%ebx
8010585e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105861:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105868:	ff d0                	call   *%eax
8010586a:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010586d:	eb 3d                	jmp    801058ac <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010586f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105875:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105878:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010587e:	8b 40 10             	mov    0x10(%eax),%eax
80105881:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105884:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105888:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010588c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105890:	c7 04 24 fb 8b 10 80 	movl   $0x80108bfb,(%esp)
80105897:	e8 05 ab ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010589c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a2:	8b 40 18             	mov    0x18(%eax),%eax
801058a5:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801058ac:	83 c4 24             	add    $0x24,%esp
801058af:	5b                   	pop    %ebx
801058b0:	5d                   	pop    %ebp
801058b1:	c3                   	ret    
	...

801058b4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801058b4:	55                   	push   %ebp
801058b5:	89 e5                	mov    %esp,%ebp
801058b7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801058ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801058c1:	8b 45 08             	mov    0x8(%ebp),%eax
801058c4:	89 04 24             	mov    %eax,(%esp)
801058c7:	e8 46 fe ff ff       	call   80105712 <argint>
801058cc:	85 c0                	test   %eax,%eax
801058ce:	79 07                	jns    801058d7 <argfd+0x23>
    return -1;
801058d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d5:	eb 50                	jmp    80105927 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801058d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058da:	85 c0                	test   %eax,%eax
801058dc:	78 21                	js     801058ff <argfd+0x4b>
801058de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e1:	83 f8 0f             	cmp    $0xf,%eax
801058e4:	7f 19                	jg     801058ff <argfd+0x4b>
801058e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058ef:	83 c2 08             	add    $0x8,%edx
801058f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058fd:	75 07                	jne    80105906 <argfd+0x52>
    return -1;
801058ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105904:	eb 21                	jmp    80105927 <argfd+0x73>
  if(pfd)
80105906:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010590a:	74 08                	je     80105914 <argfd+0x60>
    *pfd = fd;
8010590c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010590f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105912:	89 10                	mov    %edx,(%eax)
  if(pf)
80105914:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105918:	74 08                	je     80105922 <argfd+0x6e>
    *pf = f;
8010591a:	8b 45 10             	mov    0x10(%ebp),%eax
8010591d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105920:	89 10                	mov    %edx,(%eax)
  return 0;
80105922:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105927:	c9                   	leave  
80105928:	c3                   	ret    

80105929 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105929:	55                   	push   %ebp
8010592a:	89 e5                	mov    %esp,%ebp
8010592c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010592f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105936:	eb 30                	jmp    80105968 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105938:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010593e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105941:	83 c2 08             	add    $0x8,%edx
80105944:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105948:	85 c0                	test   %eax,%eax
8010594a:	75 18                	jne    80105964 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010594c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105952:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105955:	8d 4a 08             	lea    0x8(%edx),%ecx
80105958:	8b 55 08             	mov    0x8(%ebp),%edx
8010595b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010595f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105962:	eb 0f                	jmp    80105973 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105964:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105968:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010596c:	7e ca                	jle    80105938 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010596e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105973:	c9                   	leave  
80105974:	c3                   	ret    

80105975 <sys_dup>:

int
sys_dup(void)
{
80105975:	55                   	push   %ebp
80105976:	89 e5                	mov    %esp,%ebp
80105978:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010597b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010597e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105982:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105989:	00 
8010598a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105991:	e8 1e ff ff ff       	call   801058b4 <argfd>
80105996:	85 c0                	test   %eax,%eax
80105998:	79 07                	jns    801059a1 <sys_dup+0x2c>
    return -1;
8010599a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599f:	eb 29                	jmp    801059ca <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801059a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a4:	89 04 24             	mov    %eax,(%esp)
801059a7:	e8 7d ff ff ff       	call   80105929 <fdalloc>
801059ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059b3:	79 07                	jns    801059bc <sys_dup+0x47>
    return -1;
801059b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ba:	eb 0e                	jmp    801059ca <sys_dup+0x55>
  filedup(f);
801059bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bf:	89 04 24             	mov    %eax,(%esp)
801059c2:	e8 91 b8 ff ff       	call   80101258 <filedup>
  return fd;
801059c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801059ca:	c9                   	leave  
801059cb:	c3                   	ret    

801059cc <sys_read>:

int
sys_read(void)
{
801059cc:	55                   	push   %ebp
801059cd:	89 e5                	mov    %esp,%ebp
801059cf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059d5:	89 44 24 08          	mov    %eax,0x8(%esp)
801059d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059e0:	00 
801059e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059e8:	e8 c7 fe ff ff       	call   801058b4 <argfd>
801059ed:	85 c0                	test   %eax,%eax
801059ef:	78 35                	js     80105a26 <sys_read+0x5a>
801059f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801059f8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059ff:	e8 0e fd ff ff       	call   80105712 <argint>
80105a04:	85 c0                	test   %eax,%eax
80105a06:	78 1e                	js     80105a26 <sys_read+0x5a>
80105a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a1d:	e8 28 fd ff ff       	call   8010574a <argptr>
80105a22:	85 c0                	test   %eax,%eax
80105a24:	79 07                	jns    80105a2d <sys_read+0x61>
    return -1;
80105a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2b:	eb 19                	jmp    80105a46 <sys_read+0x7a>
  return fileread(f, p, n);
80105a2d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a30:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a36:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a3a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a3e:	89 04 24             	mov    %eax,(%esp)
80105a41:	e8 7f b9 ff ff       	call   801013c5 <fileread>
}
80105a46:	c9                   	leave  
80105a47:	c3                   	ret    

80105a48 <sys_write>:

int
sys_write(void)
{
80105a48:	55                   	push   %ebp
80105a49:	89 e5                	mov    %esp,%ebp
80105a4b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a51:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a5c:	00 
80105a5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a64:	e8 4b fe ff ff       	call   801058b4 <argfd>
80105a69:	85 c0                	test   %eax,%eax
80105a6b:	78 35                	js     80105aa2 <sys_write+0x5a>
80105a6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a70:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a74:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a7b:	e8 92 fc ff ff       	call   80105712 <argint>
80105a80:	85 c0                	test   %eax,%eax
80105a82:	78 1e                	js     80105aa2 <sys_write+0x5a>
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a99:	e8 ac fc ff ff       	call   8010574a <argptr>
80105a9e:	85 c0                	test   %eax,%eax
80105aa0:	79 07                	jns    80105aa9 <sys_write+0x61>
    return -1;
80105aa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa7:	eb 19                	jmp    80105ac2 <sys_write+0x7a>
  return filewrite(f, p, n);
80105aa9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105aac:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ab6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aba:	89 04 24             	mov    %eax,(%esp)
80105abd:	e8 bf b9 ff ff       	call   80101481 <filewrite>
}
80105ac2:	c9                   	leave  
80105ac3:	c3                   	ret    

80105ac4 <sys_close>:

int
sys_close(void)
{
80105ac4:	55                   	push   %ebp
80105ac5:	89 e5                	mov    %esp,%ebp
80105ac7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105aca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105acd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105adf:	e8 d0 fd ff ff       	call   801058b4 <argfd>
80105ae4:	85 c0                	test   %eax,%eax
80105ae6:	79 07                	jns    80105aef <sys_close+0x2b>
    return -1;
80105ae8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aed:	eb 24                	jmp    80105b13 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105aef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105af5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105af8:	83 c2 08             	add    $0x8,%edx
80105afb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b02:	00 
  fileclose(f);
80105b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b06:	89 04 24             	mov    %eax,(%esp)
80105b09:	e8 92 b7 ff ff       	call   801012a0 <fileclose>
  return 0;
80105b0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b13:	c9                   	leave  
80105b14:	c3                   	ret    

80105b15 <sys_fstat>:

int
sys_fstat(void)
{
80105b15:	55                   	push   %ebp
80105b16:	89 e5                	mov    %esp,%ebp
80105b18:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b1e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b29:	00 
80105b2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b31:	e8 7e fd ff ff       	call   801058b4 <argfd>
80105b36:	85 c0                	test   %eax,%eax
80105b38:	78 1f                	js     80105b59 <sys_fstat+0x44>
80105b3a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105b41:	00 
80105b42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b45:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b50:	e8 f5 fb ff ff       	call   8010574a <argptr>
80105b55:	85 c0                	test   %eax,%eax
80105b57:	79 07                	jns    80105b60 <sys_fstat+0x4b>
    return -1;
80105b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5e:	eb 12                	jmp    80105b72 <sys_fstat+0x5d>
  return filestat(f, st);
80105b60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b66:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b6a:	89 04 24             	mov    %eax,(%esp)
80105b6d:	e8 04 b8 ff ff       	call   80101376 <filestat>
}
80105b72:	c9                   	leave  
80105b73:	c3                   	ret    

80105b74 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105b74:	55                   	push   %ebp
80105b75:	89 e5                	mov    %esp,%ebp
80105b77:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105b7a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b88:	e8 1f fc ff ff       	call   801057ac <argstr>
80105b8d:	85 c0                	test   %eax,%eax
80105b8f:	78 17                	js     80105ba8 <sys_link+0x34>
80105b91:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b94:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b9f:	e8 08 fc ff ff       	call   801057ac <argstr>
80105ba4:	85 c0                	test   %eax,%eax
80105ba6:	79 0a                	jns    80105bb2 <sys_link+0x3e>
    return -1;
80105ba8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bad:	e9 3c 01 00 00       	jmp    80105cee <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105bb2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105bb5:	89 04 24             	mov    %eax,(%esp)
80105bb8:	e8 29 cb ff ff       	call   801026e6 <namei>
80105bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bc4:	75 0a                	jne    80105bd0 <sys_link+0x5c>
    return -1;
80105bc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bcb:	e9 1e 01 00 00       	jmp    80105cee <sys_link+0x17a>

  begin_trans();
80105bd0:	e8 24 d9 ff ff       	call   801034f9 <begin_trans>

  ilock(ip);
80105bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd8:	89 04 24             	mov    %eax,(%esp)
80105bdb:	e8 64 bf ff ff       	call   80101b44 <ilock>
  if(ip->type == T_DIR){
80105be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105be7:	66 83 f8 01          	cmp    $0x1,%ax
80105beb:	75 1a                	jne    80105c07 <sys_link+0x93>
    iunlockput(ip);
80105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf0:	89 04 24             	mov    %eax,(%esp)
80105bf3:	e8 d0 c1 ff ff       	call   80101dc8 <iunlockput>
    commit_trans();
80105bf8:	e8 45 d9 ff ff       	call   80103542 <commit_trans>
    return -1;
80105bfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c02:	e9 e7 00 00 00       	jmp    80105cee <sys_link+0x17a>
  }

  ip->nlink++;
80105c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c0e:	8d 50 01             	lea    0x1(%eax),%edx
80105c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c14:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1b:	89 04 24             	mov    %eax,(%esp)
80105c1e:	e8 65 bd ff ff       	call   80101988 <iupdate>
  iunlock(ip);
80105c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c26:	89 04 24             	mov    %eax,(%esp)
80105c29:	e8 64 c0 ff ff       	call   80101c92 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105c2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c31:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c34:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c38:	89 04 24             	mov    %eax,(%esp)
80105c3b:	e8 c8 ca ff ff       	call   80102708 <nameiparent>
80105c40:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c47:	74 68                	je     80105cb1 <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4c:	89 04 24             	mov    %eax,(%esp)
80105c4f:	e8 f0 be ff ff       	call   80101b44 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c57:	8b 10                	mov    (%eax),%edx
80105c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5c:	8b 00                	mov    (%eax),%eax
80105c5e:	39 c2                	cmp    %eax,%edx
80105c60:	75 20                	jne    80105c82 <sys_link+0x10e>
80105c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c65:	8b 40 04             	mov    0x4(%eax),%eax
80105c68:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c6c:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c76:	89 04 24             	mov    %eax,(%esp)
80105c79:	e8 a7 c7 ff ff       	call   80102425 <dirlink>
80105c7e:	85 c0                	test   %eax,%eax
80105c80:	79 0d                	jns    80105c8f <sys_link+0x11b>
    iunlockput(dp);
80105c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c85:	89 04 24             	mov    %eax,(%esp)
80105c88:	e8 3b c1 ff ff       	call   80101dc8 <iunlockput>
    goto bad;
80105c8d:	eb 23                	jmp    80105cb2 <sys_link+0x13e>
  }
  iunlockput(dp);
80105c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c92:	89 04 24             	mov    %eax,(%esp)
80105c95:	e8 2e c1 ff ff       	call   80101dc8 <iunlockput>
  iput(ip);
80105c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9d:	89 04 24             	mov    %eax,(%esp)
80105ca0:	e8 52 c0 ff ff       	call   80101cf7 <iput>

  commit_trans();
80105ca5:	e8 98 d8 ff ff       	call   80103542 <commit_trans>

  return 0;
80105caa:	b8 00 00 00 00       	mov    $0x0,%eax
80105caf:	eb 3d                	jmp    80105cee <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105cb1:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb5:	89 04 24             	mov    %eax,(%esp)
80105cb8:	e8 87 be ff ff       	call   80101b44 <ilock>
  ip->nlink--;
80105cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cc4:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cca:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd1:	89 04 24             	mov    %eax,(%esp)
80105cd4:	e8 af bc ff ff       	call   80101988 <iupdate>
  iunlockput(ip);
80105cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cdc:	89 04 24             	mov    %eax,(%esp)
80105cdf:	e8 e4 c0 ff ff       	call   80101dc8 <iunlockput>
  commit_trans();
80105ce4:	e8 59 d8 ff ff       	call   80103542 <commit_trans>
  return -1;
80105ce9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cee:	c9                   	leave  
80105cef:	c3                   	ret    

80105cf0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105cf0:	55                   	push   %ebp
80105cf1:	89 e5                	mov    %esp,%ebp
80105cf3:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105cf6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105cfd:	eb 4b                	jmp    80105d4a <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d02:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d09:	00 
80105d0a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d0e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d11:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d15:	8b 45 08             	mov    0x8(%ebp),%eax
80105d18:	89 04 24             	mov    %eax,(%esp)
80105d1b:	e8 1a c3 ff ff       	call   8010203a <readi>
80105d20:	83 f8 10             	cmp    $0x10,%eax
80105d23:	74 0c                	je     80105d31 <isdirempty+0x41>
      panic("isdirempty: readi");
80105d25:	c7 04 24 17 8c 10 80 	movl   $0x80108c17,(%esp)
80105d2c:	e8 0c a8 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105d31:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d35:	66 85 c0             	test   %ax,%ax
80105d38:	74 07                	je     80105d41 <isdirempty+0x51>
      return 0;
80105d3a:	b8 00 00 00 00       	mov    $0x0,%eax
80105d3f:	eb 1b                	jmp    80105d5c <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d44:	83 c0 10             	add    $0x10,%eax
80105d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80105d50:	8b 40 18             	mov    0x18(%eax),%eax
80105d53:	39 c2                	cmp    %eax,%edx
80105d55:	72 a8                	jb     80105cff <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105d57:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d5c:	c9                   	leave  
80105d5d:	c3                   	ret    

80105d5e <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d5e:	55                   	push   %ebp
80105d5f:	89 e5                	mov    %esp,%ebp
80105d61:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d64:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d67:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d72:	e8 35 fa ff ff       	call   801057ac <argstr>
80105d77:	85 c0                	test   %eax,%eax
80105d79:	79 0a                	jns    80105d85 <sys_unlink+0x27>
    return -1;
80105d7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d80:	e9 aa 01 00 00       	jmp    80105f2f <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105d85:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d88:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d8b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d8f:	89 04 24             	mov    %eax,(%esp)
80105d92:	e8 71 c9 ff ff       	call   80102708 <nameiparent>
80105d97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d9e:	75 0a                	jne    80105daa <sys_unlink+0x4c>
    return -1;
80105da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da5:	e9 85 01 00 00       	jmp    80105f2f <sys_unlink+0x1d1>

  begin_trans();
80105daa:	e8 4a d7 ff ff       	call   801034f9 <begin_trans>

  ilock(dp);
80105daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db2:	89 04 24             	mov    %eax,(%esp)
80105db5:	e8 8a bd ff ff       	call   80101b44 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105dba:	c7 44 24 04 29 8c 10 	movl   $0x80108c29,0x4(%esp)
80105dc1:	80 
80105dc2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105dc5:	89 04 24             	mov    %eax,(%esp)
80105dc8:	e8 6e c5 ff ff       	call   8010233b <namecmp>
80105dcd:	85 c0                	test   %eax,%eax
80105dcf:	0f 84 45 01 00 00    	je     80105f1a <sys_unlink+0x1bc>
80105dd5:	c7 44 24 04 2b 8c 10 	movl   $0x80108c2b,0x4(%esp)
80105ddc:	80 
80105ddd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105de0:	89 04 24             	mov    %eax,(%esp)
80105de3:	e8 53 c5 ff ff       	call   8010233b <namecmp>
80105de8:	85 c0                	test   %eax,%eax
80105dea:	0f 84 2a 01 00 00    	je     80105f1a <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105df0:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105df3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105df7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e01:	89 04 24             	mov    %eax,(%esp)
80105e04:	e8 54 c5 ff ff       	call   8010235d <dirlookup>
80105e09:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e10:	0f 84 03 01 00 00    	je     80105f19 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e19:	89 04 24             	mov    %eax,(%esp)
80105e1c:	e8 23 bd ff ff       	call   80101b44 <ilock>

  if(ip->nlink < 1)
80105e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e24:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e28:	66 85 c0             	test   %ax,%ax
80105e2b:	7f 0c                	jg     80105e39 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105e2d:	c7 04 24 2e 8c 10 80 	movl   $0x80108c2e,(%esp)
80105e34:	e8 04 a7 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e40:	66 83 f8 01          	cmp    $0x1,%ax
80105e44:	75 1f                	jne    80105e65 <sys_unlink+0x107>
80105e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e49:	89 04 24             	mov    %eax,(%esp)
80105e4c:	e8 9f fe ff ff       	call   80105cf0 <isdirempty>
80105e51:	85 c0                	test   %eax,%eax
80105e53:	75 10                	jne    80105e65 <sys_unlink+0x107>
    iunlockput(ip);
80105e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e58:	89 04 24             	mov    %eax,(%esp)
80105e5b:	e8 68 bf ff ff       	call   80101dc8 <iunlockput>
    goto bad;
80105e60:	e9 b5 00 00 00       	jmp    80105f1a <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105e65:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105e6c:	00 
80105e6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e74:	00 
80105e75:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e78:	89 04 24             	mov    %eax,(%esp)
80105e7b:	e8 42 f5 ff ff       	call   801053c2 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e80:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e83:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e8a:	00 
80105e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e8f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e92:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e99:	89 04 24             	mov    %eax,(%esp)
80105e9c:	e8 04 c3 ff ff       	call   801021a5 <writei>
80105ea1:	83 f8 10             	cmp    $0x10,%eax
80105ea4:	74 0c                	je     80105eb2 <sys_unlink+0x154>
    panic("unlink: writei");
80105ea6:	c7 04 24 40 8c 10 80 	movl   $0x80108c40,(%esp)
80105ead:	e8 8b a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105eb9:	66 83 f8 01          	cmp    $0x1,%ax
80105ebd:	75 1c                	jne    80105edb <sys_unlink+0x17d>
    dp->nlink--;
80105ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ec6:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecc:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed3:	89 04 24             	mov    %eax,(%esp)
80105ed6:	e8 ad ba ff ff       	call   80101988 <iupdate>
  }
  iunlockput(dp);
80105edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ede:	89 04 24             	mov    %eax,(%esp)
80105ee1:	e8 e2 be ff ff       	call   80101dc8 <iunlockput>

  ip->nlink--;
80105ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105eed:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efa:	89 04 24             	mov    %eax,(%esp)
80105efd:	e8 86 ba ff ff       	call   80101988 <iupdate>
  iunlockput(ip);
80105f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f05:	89 04 24             	mov    %eax,(%esp)
80105f08:	e8 bb be ff ff       	call   80101dc8 <iunlockput>

  commit_trans();
80105f0d:	e8 30 d6 ff ff       	call   80103542 <commit_trans>

  return 0;
80105f12:	b8 00 00 00 00       	mov    $0x0,%eax
80105f17:	eb 16                	jmp    80105f2f <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105f19:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1d:	89 04 24             	mov    %eax,(%esp)
80105f20:	e8 a3 be ff ff       	call   80101dc8 <iunlockput>
  commit_trans();
80105f25:	e8 18 d6 ff ff       	call   80103542 <commit_trans>
  return -1;
80105f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f2f:	c9                   	leave  
80105f30:	c3                   	ret    

80105f31 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f31:	55                   	push   %ebp
80105f32:	89 e5                	mov    %esp,%ebp
80105f34:	83 ec 48             	sub    $0x48,%esp
80105f37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105f3a:	8b 55 10             	mov    0x10(%ebp),%edx
80105f3d:	8b 45 14             	mov    0x14(%ebp),%eax
80105f40:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f44:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f48:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f4c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f53:	8b 45 08             	mov    0x8(%ebp),%eax
80105f56:	89 04 24             	mov    %eax,(%esp)
80105f59:	e8 aa c7 ff ff       	call   80102708 <nameiparent>
80105f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f65:	75 0a                	jne    80105f71 <create+0x40>
    return 0;
80105f67:	b8 00 00 00 00       	mov    $0x0,%eax
80105f6c:	e9 7e 01 00 00       	jmp    801060ef <create+0x1be>
  ilock(dp);
80105f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f74:	89 04 24             	mov    %eax,(%esp)
80105f77:	e8 c8 bb ff ff       	call   80101b44 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f7c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f7f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f83:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f86:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8d:	89 04 24             	mov    %eax,(%esp)
80105f90:	e8 c8 c3 ff ff       	call   8010235d <dirlookup>
80105f95:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f9c:	74 47                	je     80105fe5 <create+0xb4>
    iunlockput(dp);
80105f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa1:	89 04 24             	mov    %eax,(%esp)
80105fa4:	e8 1f be ff ff       	call   80101dc8 <iunlockput>
    ilock(ip);
80105fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fac:	89 04 24             	mov    %eax,(%esp)
80105faf:	e8 90 bb ff ff       	call   80101b44 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105fb4:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105fb9:	75 15                	jne    80105fd0 <create+0x9f>
80105fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fbe:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fc2:	66 83 f8 02          	cmp    $0x2,%ax
80105fc6:	75 08                	jne    80105fd0 <create+0x9f>
      return ip;
80105fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fcb:	e9 1f 01 00 00       	jmp    801060ef <create+0x1be>
    iunlockput(ip);
80105fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd3:	89 04 24             	mov    %eax,(%esp)
80105fd6:	e8 ed bd ff ff       	call   80101dc8 <iunlockput>
    return 0;
80105fdb:	b8 00 00 00 00       	mov    $0x0,%eax
80105fe0:	e9 0a 01 00 00       	jmp    801060ef <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105fe5:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fec:	8b 00                	mov    (%eax),%eax
80105fee:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ff2:	89 04 24             	mov    %eax,(%esp)
80105ff5:	e8 b1 b8 ff ff       	call   801018ab <ialloc>
80105ffa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ffd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106001:	75 0c                	jne    8010600f <create+0xde>
    panic("create: ialloc");
80106003:	c7 04 24 4f 8c 10 80 	movl   $0x80108c4f,(%esp)
8010600a:	e8 2e a5 ff ff       	call   8010053d <panic>

  ilock(ip);
8010600f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106012:	89 04 24             	mov    %eax,(%esp)
80106015:	e8 2a bb ff ff       	call   80101b44 <ilock>
  ip->major = major;
8010601a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106021:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106028:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010602c:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106033:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106039:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603c:	89 04 24             	mov    %eax,(%esp)
8010603f:	e8 44 b9 ff ff       	call   80101988 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106044:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106049:	75 6a                	jne    801060b5 <create+0x184>
    dp->nlink++;  // for ".."
8010604b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106052:	8d 50 01             	lea    0x1(%eax),%edx
80106055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106058:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010605c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605f:	89 04 24             	mov    %eax,(%esp)
80106062:	e8 21 b9 ff ff       	call   80101988 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106067:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606a:	8b 40 04             	mov    0x4(%eax),%eax
8010606d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106071:	c7 44 24 04 29 8c 10 	movl   $0x80108c29,0x4(%esp)
80106078:	80 
80106079:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607c:	89 04 24             	mov    %eax,(%esp)
8010607f:	e8 a1 c3 ff ff       	call   80102425 <dirlink>
80106084:	85 c0                	test   %eax,%eax
80106086:	78 21                	js     801060a9 <create+0x178>
80106088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608b:	8b 40 04             	mov    0x4(%eax),%eax
8010608e:	89 44 24 08          	mov    %eax,0x8(%esp)
80106092:	c7 44 24 04 2b 8c 10 	movl   $0x80108c2b,0x4(%esp)
80106099:	80 
8010609a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609d:	89 04 24             	mov    %eax,(%esp)
801060a0:	e8 80 c3 ff ff       	call   80102425 <dirlink>
801060a5:	85 c0                	test   %eax,%eax
801060a7:	79 0c                	jns    801060b5 <create+0x184>
      panic("create dots");
801060a9:	c7 04 24 5e 8c 10 80 	movl   $0x80108c5e,(%esp)
801060b0:	e8 88 a4 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801060b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b8:	8b 40 04             	mov    0x4(%eax),%eax
801060bb:	89 44 24 08          	mov    %eax,0x8(%esp)
801060bf:	8d 45 de             	lea    -0x22(%ebp),%eax
801060c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801060c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c9:	89 04 24             	mov    %eax,(%esp)
801060cc:	e8 54 c3 ff ff       	call   80102425 <dirlink>
801060d1:	85 c0                	test   %eax,%eax
801060d3:	79 0c                	jns    801060e1 <create+0x1b0>
    panic("create: dirlink");
801060d5:	c7 04 24 6a 8c 10 80 	movl   $0x80108c6a,(%esp)
801060dc:	e8 5c a4 ff ff       	call   8010053d <panic>

  iunlockput(dp);
801060e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e4:	89 04 24             	mov    %eax,(%esp)
801060e7:	e8 dc bc ff ff       	call   80101dc8 <iunlockput>

  return ip;
801060ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801060ef:	c9                   	leave  
801060f0:	c3                   	ret    

801060f1 <sys_open>:

int
sys_open(void)
{
801060f1:	55                   	push   %ebp
801060f2:	89 e5                	mov    %esp,%ebp
801060f4:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801060f7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801060fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106105:	e8 a2 f6 ff ff       	call   801057ac <argstr>
8010610a:	85 c0                	test   %eax,%eax
8010610c:	78 17                	js     80106125 <sys_open+0x34>
8010610e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106111:	89 44 24 04          	mov    %eax,0x4(%esp)
80106115:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010611c:	e8 f1 f5 ff ff       	call   80105712 <argint>
80106121:	85 c0                	test   %eax,%eax
80106123:	79 0a                	jns    8010612f <sys_open+0x3e>
    return -1;
80106125:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612a:	e9 46 01 00 00       	jmp    80106275 <sys_open+0x184>
  if(omode & O_CREATE){
8010612f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106132:	25 00 02 00 00       	and    $0x200,%eax
80106137:	85 c0                	test   %eax,%eax
80106139:	74 40                	je     8010617b <sys_open+0x8a>
    begin_trans();
8010613b:	e8 b9 d3 ff ff       	call   801034f9 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80106140:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106143:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010614a:	00 
8010614b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106152:	00 
80106153:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010615a:	00 
8010615b:	89 04 24             	mov    %eax,(%esp)
8010615e:	e8 ce fd ff ff       	call   80105f31 <create>
80106163:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80106166:	e8 d7 d3 ff ff       	call   80103542 <commit_trans>
    if(ip == 0)
8010616b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010616f:	75 5c                	jne    801061cd <sys_open+0xdc>
      return -1;
80106171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106176:	e9 fa 00 00 00       	jmp    80106275 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
8010617b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010617e:	89 04 24             	mov    %eax,(%esp)
80106181:	e8 60 c5 ff ff       	call   801026e6 <namei>
80106186:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106189:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010618d:	75 0a                	jne    80106199 <sys_open+0xa8>
      return -1;
8010618f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106194:	e9 dc 00 00 00       	jmp    80106275 <sys_open+0x184>
    ilock(ip);
80106199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619c:	89 04 24             	mov    %eax,(%esp)
8010619f:	e8 a0 b9 ff ff       	call   80101b44 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801061a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061ab:	66 83 f8 01          	cmp    $0x1,%ax
801061af:	75 1c                	jne    801061cd <sys_open+0xdc>
801061b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061b4:	85 c0                	test   %eax,%eax
801061b6:	74 15                	je     801061cd <sys_open+0xdc>
      iunlockput(ip);
801061b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061bb:	89 04 24             	mov    %eax,(%esp)
801061be:	e8 05 bc ff ff       	call   80101dc8 <iunlockput>
      return -1;
801061c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c8:	e9 a8 00 00 00       	jmp    80106275 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801061cd:	e8 26 b0 ff ff       	call   801011f8 <filealloc>
801061d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061d9:	74 14                	je     801061ef <sys_open+0xfe>
801061db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061de:	89 04 24             	mov    %eax,(%esp)
801061e1:	e8 43 f7 ff ff       	call   80105929 <fdalloc>
801061e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801061e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801061ed:	79 23                	jns    80106212 <sys_open+0x121>
    if(f)
801061ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061f3:	74 0b                	je     80106200 <sys_open+0x10f>
      fileclose(f);
801061f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f8:	89 04 24             	mov    %eax,(%esp)
801061fb:	e8 a0 b0 ff ff       	call   801012a0 <fileclose>
    iunlockput(ip);
80106200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106203:	89 04 24             	mov    %eax,(%esp)
80106206:	e8 bd bb ff ff       	call   80101dc8 <iunlockput>
    return -1;
8010620b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106210:	eb 63                	jmp    80106275 <sys_open+0x184>
  }
  iunlock(ip);
80106212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106215:	89 04 24             	mov    %eax,(%esp)
80106218:	e8 75 ba ff ff       	call   80101c92 <iunlock>

  f->type = FD_INODE;
8010621d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106220:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106226:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106229:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010622c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010622f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106232:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010623c:	83 e0 01             	and    $0x1,%eax
8010623f:	85 c0                	test   %eax,%eax
80106241:	0f 94 c2             	sete   %dl
80106244:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106247:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010624a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010624d:	83 e0 01             	and    $0x1,%eax
80106250:	84 c0                	test   %al,%al
80106252:	75 0a                	jne    8010625e <sys_open+0x16d>
80106254:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106257:	83 e0 02             	and    $0x2,%eax
8010625a:	85 c0                	test   %eax,%eax
8010625c:	74 07                	je     80106265 <sys_open+0x174>
8010625e:	b8 01 00 00 00       	mov    $0x1,%eax
80106263:	eb 05                	jmp    8010626a <sys_open+0x179>
80106265:	b8 00 00 00 00       	mov    $0x0,%eax
8010626a:	89 c2                	mov    %eax,%edx
8010626c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106272:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106275:	c9                   	leave  
80106276:	c3                   	ret    

80106277 <sys_mkdir>:

int
sys_mkdir(void)
{
80106277:	55                   	push   %ebp
80106278:	89 e5                	mov    %esp,%ebp
8010627a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
8010627d:	e8 77 d2 ff ff       	call   801034f9 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106282:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106285:	89 44 24 04          	mov    %eax,0x4(%esp)
80106289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106290:	e8 17 f5 ff ff       	call   801057ac <argstr>
80106295:	85 c0                	test   %eax,%eax
80106297:	78 2c                	js     801062c5 <sys_mkdir+0x4e>
80106299:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801062a3:	00 
801062a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062ab:	00 
801062ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801062b3:	00 
801062b4:	89 04 24             	mov    %eax,(%esp)
801062b7:	e8 75 fc ff ff       	call   80105f31 <create>
801062bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062c3:	75 0c                	jne    801062d1 <sys_mkdir+0x5a>
    commit_trans();
801062c5:	e8 78 d2 ff ff       	call   80103542 <commit_trans>
    return -1;
801062ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062cf:	eb 15                	jmp    801062e6 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801062d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d4:	89 04 24             	mov    %eax,(%esp)
801062d7:	e8 ec ba ff ff       	call   80101dc8 <iunlockput>
  commit_trans();
801062dc:	e8 61 d2 ff ff       	call   80103542 <commit_trans>
  return 0;
801062e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062e6:	c9                   	leave  
801062e7:	c3                   	ret    

801062e8 <sys_mknod>:

int
sys_mknod(void)
{
801062e8:	55                   	push   %ebp
801062e9:	89 e5                	mov    %esp,%ebp
801062eb:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
801062ee:	e8 06 d2 ff ff       	call   801034f9 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
801062f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801062fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106301:	e8 a6 f4 ff ff       	call   801057ac <argstr>
80106306:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106309:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630d:	78 5e                	js     8010636d <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010630f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106312:	89 44 24 04          	mov    %eax,0x4(%esp)
80106316:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010631d:	e8 f0 f3 ff ff       	call   80105712 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80106322:	85 c0                	test   %eax,%eax
80106324:	78 47                	js     8010636d <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106326:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106329:	89 44 24 04          	mov    %eax,0x4(%esp)
8010632d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106334:	e8 d9 f3 ff ff       	call   80105712 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106339:	85 c0                	test   %eax,%eax
8010633b:	78 30                	js     8010636d <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010633d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106340:	0f bf c8             	movswl %ax,%ecx
80106343:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106346:	0f bf d0             	movswl %ax,%edx
80106349:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010634c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106350:	89 54 24 08          	mov    %edx,0x8(%esp)
80106354:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010635b:	00 
8010635c:	89 04 24             	mov    %eax,(%esp)
8010635f:	e8 cd fb ff ff       	call   80105f31 <create>
80106364:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106367:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010636b:	75 0c                	jne    80106379 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
8010636d:	e8 d0 d1 ff ff       	call   80103542 <commit_trans>
    return -1;
80106372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106377:	eb 15                	jmp    8010638e <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010637c:	89 04 24             	mov    %eax,(%esp)
8010637f:	e8 44 ba ff ff       	call   80101dc8 <iunlockput>
  commit_trans();
80106384:	e8 b9 d1 ff ff       	call   80103542 <commit_trans>
  return 0;
80106389:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010638e:	c9                   	leave  
8010638f:	c3                   	ret    

80106390 <sys_chdir>:

int
sys_chdir(void)
{
80106390:	55                   	push   %ebp
80106391:	89 e5                	mov    %esp,%ebp
80106393:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80106396:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106399:	89 44 24 04          	mov    %eax,0x4(%esp)
8010639d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063a4:	e8 03 f4 ff ff       	call   801057ac <argstr>
801063a9:	85 c0                	test   %eax,%eax
801063ab:	78 14                	js     801063c1 <sys_chdir+0x31>
801063ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b0:	89 04 24             	mov    %eax,(%esp)
801063b3:	e8 2e c3 ff ff       	call   801026e6 <namei>
801063b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063bf:	75 07                	jne    801063c8 <sys_chdir+0x38>
    return -1;
801063c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c6:	eb 57                	jmp    8010641f <sys_chdir+0x8f>
  ilock(ip);
801063c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063cb:	89 04 24             	mov    %eax,(%esp)
801063ce:	e8 71 b7 ff ff       	call   80101b44 <ilock>
  if(ip->type != T_DIR){
801063d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063da:	66 83 f8 01          	cmp    $0x1,%ax
801063de:	74 12                	je     801063f2 <sys_chdir+0x62>
    iunlockput(ip);
801063e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e3:	89 04 24             	mov    %eax,(%esp)
801063e6:	e8 dd b9 ff ff       	call   80101dc8 <iunlockput>
    return -1;
801063eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f0:	eb 2d                	jmp    8010641f <sys_chdir+0x8f>
  }
  iunlock(ip);
801063f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f5:	89 04 24             	mov    %eax,(%esp)
801063f8:	e8 95 b8 ff ff       	call   80101c92 <iunlock>
  iput(proc->cwd);
801063fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106403:	8b 40 68             	mov    0x68(%eax),%eax
80106406:	89 04 24             	mov    %eax,(%esp)
80106409:	e8 e9 b8 ff ff       	call   80101cf7 <iput>
  proc->cwd = ip;
8010640e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106414:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106417:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010641a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010641f:	c9                   	leave  
80106420:	c3                   	ret    

80106421 <sys_exec>:

int
sys_exec(void)
{
80106421:	55                   	push   %ebp
80106422:	89 e5                	mov    %esp,%ebp
80106424:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010642a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010642d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106438:	e8 6f f3 ff ff       	call   801057ac <argstr>
8010643d:	85 c0                	test   %eax,%eax
8010643f:	78 1a                	js     8010645b <sys_exec+0x3a>
80106441:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106447:	89 44 24 04          	mov    %eax,0x4(%esp)
8010644b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106452:	e8 bb f2 ff ff       	call   80105712 <argint>
80106457:	85 c0                	test   %eax,%eax
80106459:	79 0a                	jns    80106465 <sys_exec+0x44>
    return -1;
8010645b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106460:	e9 e2 00 00 00       	jmp    80106547 <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
80106465:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010646c:	00 
8010646d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106474:	00 
80106475:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010647b:	89 04 24             	mov    %eax,(%esp)
8010647e:	e8 3f ef ff ff       	call   801053c2 <memset>
  for(i=0;; i++){
80106483:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010648a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010648d:	83 f8 1f             	cmp    $0x1f,%eax
80106490:	76 0a                	jbe    8010649c <sys_exec+0x7b>
      return -1;
80106492:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106497:	e9 ab 00 00 00       	jmp    80106547 <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
8010649c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649f:	c1 e0 02             	shl    $0x2,%eax
801064a2:	89 c2                	mov    %eax,%edx
801064a4:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801064aa:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801064ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064b3:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
801064b9:	89 54 24 08          	mov    %edx,0x8(%esp)
801064bd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801064c1:	89 04 24             	mov    %eax,(%esp)
801064c4:	e8 b7 f1 ff ff       	call   80105680 <fetchint>
801064c9:	85 c0                	test   %eax,%eax
801064cb:	79 07                	jns    801064d4 <sys_exec+0xb3>
      return -1;
801064cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d2:	eb 73                	jmp    80106547 <sys_exec+0x126>
    if(uarg == 0){
801064d4:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064da:	85 c0                	test   %eax,%eax
801064dc:	75 26                	jne    80106504 <sys_exec+0xe3>
      argv[i] = 0;
801064de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e1:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801064e8:	00 00 00 00 
      break;
801064ec:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801064ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f0:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801064f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801064fa:	89 04 24             	mov    %eax,(%esp)
801064fd:	e8 d6 a8 ff ff       	call   80100dd8 <exec>
80106502:	eb 43                	jmp    80106547 <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106507:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010650e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106514:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106517:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
8010651d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106523:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106527:	89 54 24 04          	mov    %edx,0x4(%esp)
8010652b:	89 04 24             	mov    %eax,(%esp)
8010652e:	e8 81 f1 ff ff       	call   801056b4 <fetchstr>
80106533:	85 c0                	test   %eax,%eax
80106535:	79 07                	jns    8010653e <sys_exec+0x11d>
      return -1;
80106537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653c:	eb 09                	jmp    80106547 <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010653e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
80106542:	e9 43 ff ff ff       	jmp    8010648a <sys_exec+0x69>
  return exec(path, argv);
}
80106547:	c9                   	leave  
80106548:	c3                   	ret    

80106549 <sys_pipe>:

int
sys_pipe(void)
{
80106549:	55                   	push   %ebp
8010654a:	89 e5                	mov    %esp,%ebp
8010654c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010654f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106556:	00 
80106557:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010655a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010655e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106565:	e8 e0 f1 ff ff       	call   8010574a <argptr>
8010656a:	85 c0                	test   %eax,%eax
8010656c:	79 0a                	jns    80106578 <sys_pipe+0x2f>
    return -1;
8010656e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106573:	e9 9b 00 00 00       	jmp    80106613 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106578:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010657b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010657f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106582:	89 04 24             	mov    %eax,(%esp)
80106585:	e8 8a d9 ff ff       	call   80103f14 <pipealloc>
8010658a:	85 c0                	test   %eax,%eax
8010658c:	79 07                	jns    80106595 <sys_pipe+0x4c>
    return -1;
8010658e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106593:	eb 7e                	jmp    80106613 <sys_pipe+0xca>
  fd0 = -1;
80106595:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010659c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010659f:	89 04 24             	mov    %eax,(%esp)
801065a2:	e8 82 f3 ff ff       	call   80105929 <fdalloc>
801065a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065ae:	78 14                	js     801065c4 <sys_pipe+0x7b>
801065b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065b3:	89 04 24             	mov    %eax,(%esp)
801065b6:	e8 6e f3 ff ff       	call   80105929 <fdalloc>
801065bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065c2:	79 37                	jns    801065fb <sys_pipe+0xb2>
    if(fd0 >= 0)
801065c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065c8:	78 14                	js     801065de <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801065ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065d3:	83 c2 08             	add    $0x8,%edx
801065d6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801065dd:	00 
    fileclose(rf);
801065de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065e1:	89 04 24             	mov    %eax,(%esp)
801065e4:	e8 b7 ac ff ff       	call   801012a0 <fileclose>
    fileclose(wf);
801065e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ec:	89 04 24             	mov    %eax,(%esp)
801065ef:	e8 ac ac ff ff       	call   801012a0 <fileclose>
    return -1;
801065f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065f9:	eb 18                	jmp    80106613 <sys_pipe+0xca>
  }
  fd[0] = fd0;
801065fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106601:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106603:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106606:	8d 50 04             	lea    0x4(%eax),%edx
80106609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010660c:	89 02                	mov    %eax,(%edx)
  return 0;
8010660e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106613:	c9                   	leave  
80106614:	c3                   	ret    
80106615:	00 00                	add    %al,(%eax)
	...

80106618 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106618:	55                   	push   %ebp
80106619:	89 e5                	mov    %esp,%ebp
8010661b:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010661e:	e8 ae df ff ff       	call   801045d1 <fork>
}
80106623:	c9                   	leave  
80106624:	c3                   	ret    

80106625 <sys_exit>:

int
sys_exit(void)
{
80106625:	55                   	push   %ebp
80106626:	89 e5                	mov    %esp,%ebp
80106628:	83 ec 08             	sub    $0x8,%esp
  exit();
8010662b:	e8 36 e1 ff ff       	call   80104766 <exit>
  return 0;  // not reached
80106630:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106635:	c9                   	leave  
80106636:	c3                   	ret    

80106637 <sys_wait>:

int
sys_wait(void)
{
80106637:	55                   	push   %ebp
80106638:	89 e5                	mov    %esp,%ebp
8010663a:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010663d:	e8 79 e2 ff ff       	call   801048bb <wait>
}
80106642:	c9                   	leave  
80106643:	c3                   	ret    

80106644 <sys_wait2>:

int
sys_wait2(void)
{
80106644:	55                   	push   %ebp
80106645:	89 e5                	mov    %esp,%ebp
80106647:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
8010664a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
80106651:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
80106658:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010665f:	00 
80106660:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106663:	89 44 24 04          	mov    %eax,0x4(%esp)
80106667:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010666e:	e8 d7 f0 ff ff       	call   8010574a <argptr>
  argptr(0,&wtime,sizeof(wtime));
80106673:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010667a:	00 
8010667b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010667e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106682:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106689:	e8 bc f0 ff ff       	call   8010574a <argptr>
  return wait2((int*)wtime, (int*)rtime);
8010668e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106691:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106694:	89 54 24 04          	mov    %edx,0x4(%esp)
80106698:	89 04 24             	mov    %eax,(%esp)
8010669b:	e8 2d e3 ff ff       	call   801049cd <wait2>
}
801066a0:	c9                   	leave  
801066a1:	c3                   	ret    

801066a2 <sys_nice>:

int
sys_nice(void)
{
801066a2:	55                   	push   %ebp
801066a3:	89 e5                	mov    %esp,%ebp
801066a5:	83 ec 08             	sub    $0x8,%esp
  return nice();
801066a8:	e8 db e9 ff ff       	call   80105088 <nice>
}
801066ad:	c9                   	leave  
801066ae:	c3                   	ret    

801066af <sys_kill>:
int
sys_kill(void)
{
801066af:	55                   	push   %ebp
801066b0:	89 e5                	mov    %esp,%ebp
801066b2:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801066b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801066bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066c3:	e8 4a f0 ff ff       	call   80105712 <argint>
801066c8:	85 c0                	test   %eax,%eax
801066ca:	79 07                	jns    801066d3 <sys_kill+0x24>
    return -1;
801066cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d1:	eb 0b                	jmp    801066de <sys_kill+0x2f>
  return kill(pid);
801066d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d6:	89 04 24             	mov    %eax,(%esp)
801066d9:	e8 33 e8 ff ff       	call   80104f11 <kill>
}
801066de:	c9                   	leave  
801066df:	c3                   	ret    

801066e0 <sys_getpid>:

int
sys_getpid(void)
{
801066e0:	55                   	push   %ebp
801066e1:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801066e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066e9:	8b 40 10             	mov    0x10(%eax),%eax
}
801066ec:	5d                   	pop    %ebp
801066ed:	c3                   	ret    

801066ee <sys_sbrk>:

int
sys_sbrk(void)
{
801066ee:	55                   	push   %ebp
801066ef:	89 e5                	mov    %esp,%ebp
801066f1:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801066f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801066fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106702:	e8 0b f0 ff ff       	call   80105712 <argint>
80106707:	85 c0                	test   %eax,%eax
80106709:	79 07                	jns    80106712 <sys_sbrk+0x24>
    return -1;
8010670b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106710:	eb 24                	jmp    80106736 <sys_sbrk+0x48>
  addr = proc->sz;
80106712:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106718:	8b 00                	mov    (%eax),%eax
8010671a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010671d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106720:	89 04 24             	mov    %eax,(%esp)
80106723:	e8 04 de ff ff       	call   8010452c <growproc>
80106728:	85 c0                	test   %eax,%eax
8010672a:	79 07                	jns    80106733 <sys_sbrk+0x45>
    return -1;
8010672c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106731:	eb 03                	jmp    80106736 <sys_sbrk+0x48>
  return addr;
80106733:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106736:	c9                   	leave  
80106737:	c3                   	ret    

80106738 <sys_sleep>:

int
sys_sleep(void)
{
80106738:	55                   	push   %ebp
80106739:	89 e5                	mov    %esp,%ebp
8010673b:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010673e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106741:	89 44 24 04          	mov    %eax,0x4(%esp)
80106745:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010674c:	e8 c1 ef ff ff       	call   80105712 <argint>
80106751:	85 c0                	test   %eax,%eax
80106753:	79 07                	jns    8010675c <sys_sleep+0x24>
    return -1;
80106755:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010675a:	eb 6c                	jmp    801067c8 <sys_sleep+0x90>
  acquire(&tickslock);
8010675c:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106763:	e8 0b ea ff ff       	call   80105173 <acquire>
  ticks0 = ticks;
80106768:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
8010676d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106770:	eb 34                	jmp    801067a6 <sys_sleep+0x6e>
    if(proc->killed){
80106772:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106778:	8b 40 24             	mov    0x24(%eax),%eax
8010677b:	85 c0                	test   %eax,%eax
8010677d:	74 13                	je     80106792 <sys_sleep+0x5a>
      release(&tickslock);
8010677f:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106786:	e8 4a ea ff ff       	call   801051d5 <release>
      return -1;
8010678b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106790:	eb 36                	jmp    801067c8 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106792:	c7 44 24 04 80 24 11 	movl   $0x80112480,0x4(%esp)
80106799:	80 
8010679a:	c7 04 24 c0 2c 11 80 	movl   $0x80112cc0,(%esp)
801067a1:	e8 64 e6 ff ff       	call   80104e0a <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801067a6:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
801067ab:	89 c2                	mov    %eax,%edx
801067ad:	2b 55 f4             	sub    -0xc(%ebp),%edx
801067b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b3:	39 c2                	cmp    %eax,%edx
801067b5:	72 bb                	jb     80106772 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801067b7:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801067be:	e8 12 ea ff ff       	call   801051d5 <release>
  return 0;
801067c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067c8:	c9                   	leave  
801067c9:	c3                   	ret    

801067ca <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801067ca:	55                   	push   %ebp
801067cb:	89 e5                	mov    %esp,%ebp
801067cd:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801067d0:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801067d7:	e8 97 e9 ff ff       	call   80105173 <acquire>
  xticks = ticks;
801067dc:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
801067e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801067e4:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801067eb:	e8 e5 e9 ff ff       	call   801051d5 <release>
  return xticks;
801067f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067f3:	c9                   	leave  
801067f4:	c3                   	ret    
801067f5:	00 00                	add    %al,(%eax)
	...

801067f8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801067f8:	55                   	push   %ebp
801067f9:	89 e5                	mov    %esp,%ebp
801067fb:	83 ec 08             	sub    $0x8,%esp
801067fe:	8b 55 08             	mov    0x8(%ebp),%edx
80106801:	8b 45 0c             	mov    0xc(%ebp),%eax
80106804:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106808:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010680b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010680f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106813:	ee                   	out    %al,(%dx)
}
80106814:	c9                   	leave  
80106815:	c3                   	ret    

80106816 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106816:	55                   	push   %ebp
80106817:	89 e5                	mov    %esp,%ebp
80106819:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010681c:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106823:	00 
80106824:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010682b:	e8 c8 ff ff ff       	call   801067f8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106830:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106837:	00 
80106838:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010683f:	e8 b4 ff ff ff       	call   801067f8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106844:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010684b:	00 
8010684c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106853:	e8 a0 ff ff ff       	call   801067f8 <outb>
  picenable(IRQ_TIMER);
80106858:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010685f:	e8 39 d5 ff ff       	call   80103d9d <picenable>
}
80106864:	c9                   	leave  
80106865:	c3                   	ret    
	...

80106868 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106868:	1e                   	push   %ds
  pushl %es
80106869:	06                   	push   %es
  pushl %fs
8010686a:	0f a0                	push   %fs
  pushl %gs
8010686c:	0f a8                	push   %gs
  pushal
8010686e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010686f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106873:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106875:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106877:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010687b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010687d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010687f:	54                   	push   %esp
  call trap
80106880:	e8 de 01 00 00       	call   80106a63 <trap>
  addl $4, %esp
80106885:	83 c4 04             	add    $0x4,%esp

80106888 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106888:	61                   	popa   
  popl %gs
80106889:	0f a9                	pop    %gs
  popl %fs
8010688b:	0f a1                	pop    %fs
  popl %es
8010688d:	07                   	pop    %es
  popl %ds
8010688e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010688f:	83 c4 08             	add    $0x8,%esp
  iret
80106892:	cf                   	iret   
	...

80106894 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106894:	55                   	push   %ebp
80106895:	89 e5                	mov    %esp,%ebp
80106897:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010689a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010689d:	83 e8 01             	sub    $0x1,%eax
801068a0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801068a4:	8b 45 08             	mov    0x8(%ebp),%eax
801068a7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801068ab:	8b 45 08             	mov    0x8(%ebp),%eax
801068ae:	c1 e8 10             	shr    $0x10,%eax
801068b1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801068b5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801068b8:	0f 01 18             	lidtl  (%eax)
}
801068bb:	c9                   	leave  
801068bc:	c3                   	ret    

801068bd <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801068bd:	55                   	push   %ebp
801068be:	89 e5                	mov    %esp,%ebp
801068c0:	53                   	push   %ebx
801068c1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801068c4:	0f 20 d3             	mov    %cr2,%ebx
801068c7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801068ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801068cd:	83 c4 10             	add    $0x10,%esp
801068d0:	5b                   	pop    %ebx
801068d1:	5d                   	pop    %ebp
801068d2:	c3                   	ret    

801068d3 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801068d3:	55                   	push   %ebp
801068d4:	89 e5                	mov    %esp,%ebp
801068d6:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801068d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801068e0:	e9 c3 00 00 00       	jmp    801069a8 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801068e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e8:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801068ef:	89 c2                	mov    %eax,%edx
801068f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f4:	66 89 14 c5 c0 24 11 	mov    %dx,-0x7feedb40(,%eax,8)
801068fb:	80 
801068fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ff:	66 c7 04 c5 c2 24 11 	movw   $0x8,-0x7feedb3e(,%eax,8)
80106906:	80 08 00 
80106909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010690c:	0f b6 14 c5 c4 24 11 	movzbl -0x7feedb3c(,%eax,8),%edx
80106913:	80 
80106914:	83 e2 e0             	and    $0xffffffe0,%edx
80106917:	88 14 c5 c4 24 11 80 	mov    %dl,-0x7feedb3c(,%eax,8)
8010691e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106921:	0f b6 14 c5 c4 24 11 	movzbl -0x7feedb3c(,%eax,8),%edx
80106928:	80 
80106929:	83 e2 1f             	and    $0x1f,%edx
8010692c:	88 14 c5 c4 24 11 80 	mov    %dl,-0x7feedb3c(,%eax,8)
80106933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106936:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
8010693d:	80 
8010693e:	83 e2 f0             	and    $0xfffffff0,%edx
80106941:	83 ca 0e             	or     $0xe,%edx
80106944:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
8010694b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694e:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
80106955:	80 
80106956:	83 e2 ef             	and    $0xffffffef,%edx
80106959:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
80106960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106963:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
8010696a:	80 
8010696b:	83 e2 9f             	and    $0xffffff9f,%edx
8010696e:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
80106975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106978:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
8010697f:	80 
80106980:	83 ca 80             	or     $0xffffff80,%edx
80106983:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
8010698a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698d:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106994:	c1 e8 10             	shr    $0x10,%eax
80106997:	89 c2                	mov    %eax,%edx
80106999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699c:	66 89 14 c5 c6 24 11 	mov    %dx,-0x7feedb3a(,%eax,8)
801069a3:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801069a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069a8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801069af:	0f 8e 30 ff ff ff    	jle    801068e5 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801069b5:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801069ba:	66 a3 c0 26 11 80    	mov    %ax,0x801126c0
801069c0:	66 c7 05 c2 26 11 80 	movw   $0x8,0x801126c2
801069c7:	08 00 
801069c9:	0f b6 05 c4 26 11 80 	movzbl 0x801126c4,%eax
801069d0:	83 e0 e0             	and    $0xffffffe0,%eax
801069d3:	a2 c4 26 11 80       	mov    %al,0x801126c4
801069d8:	0f b6 05 c4 26 11 80 	movzbl 0x801126c4,%eax
801069df:	83 e0 1f             	and    $0x1f,%eax
801069e2:	a2 c4 26 11 80       	mov    %al,0x801126c4
801069e7:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
801069ee:	83 c8 0f             	or     $0xf,%eax
801069f1:	a2 c5 26 11 80       	mov    %al,0x801126c5
801069f6:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
801069fd:	83 e0 ef             	and    $0xffffffef,%eax
80106a00:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a05:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a0c:	83 c8 60             	or     $0x60,%eax
80106a0f:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a14:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a1b:	83 c8 80             	or     $0xffffff80,%eax
80106a1e:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a23:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a28:	c1 e8 10             	shr    $0x10,%eax
80106a2b:	66 a3 c6 26 11 80    	mov    %ax,0x801126c6
  
  initlock(&tickslock, "time");
80106a31:	c7 44 24 04 7c 8c 10 	movl   $0x80108c7c,0x4(%esp)
80106a38:	80 
80106a39:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106a40:	e8 0d e7 ff ff       	call   80105152 <initlock>
}
80106a45:	c9                   	leave  
80106a46:	c3                   	ret    

80106a47 <idtinit>:

void
idtinit(void)
{
80106a47:	55                   	push   %ebp
80106a48:	89 e5                	mov    %esp,%ebp
80106a4a:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106a4d:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106a54:	00 
80106a55:	c7 04 24 c0 24 11 80 	movl   $0x801124c0,(%esp)
80106a5c:	e8 33 fe ff ff       	call   80106894 <lidt>
}
80106a61:	c9                   	leave  
80106a62:	c3                   	ret    

80106a63 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106a63:	55                   	push   %ebp
80106a64:	89 e5                	mov    %esp,%ebp
80106a66:	57                   	push   %edi
80106a67:	56                   	push   %esi
80106a68:	53                   	push   %ebx
80106a69:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6f:	8b 40 30             	mov    0x30(%eax),%eax
80106a72:	83 f8 40             	cmp    $0x40,%eax
80106a75:	75 3e                	jne    80106ab5 <trap+0x52>
    if(proc->killed)
80106a77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a7d:	8b 40 24             	mov    0x24(%eax),%eax
80106a80:	85 c0                	test   %eax,%eax
80106a82:	74 05                	je     80106a89 <trap+0x26>
      exit();
80106a84:	e8 dd dc ff ff       	call   80104766 <exit>
    proc->tf = tf;
80106a89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a8f:	8b 55 08             	mov    0x8(%ebp),%edx
80106a92:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106a95:	e8 55 ed ff ff       	call   801057ef <syscall>
    if(proc->killed)
80106a9a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aa0:	8b 40 24             	mov    0x24(%eax),%eax
80106aa3:	85 c0                	test   %eax,%eax
80106aa5:	0f 84 78 02 00 00    	je     80106d23 <trap+0x2c0>
      exit();
80106aab:	e8 b6 dc ff ff       	call   80104766 <exit>
    return;
80106ab0:	e9 6e 02 00 00       	jmp    80106d23 <trap+0x2c0>
  }

  switch(tf->trapno){
80106ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab8:	8b 40 30             	mov    0x30(%eax),%eax
80106abb:	83 e8 20             	sub    $0x20,%eax
80106abe:	83 f8 1f             	cmp    $0x1f,%eax
80106ac1:	0f 87 f0 00 00 00    	ja     80106bb7 <trap+0x154>
80106ac7:	8b 04 85 24 8d 10 80 	mov    -0x7fef72dc(,%eax,4),%eax
80106ace:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106ad0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ad6:	0f b6 00             	movzbl (%eax),%eax
80106ad9:	84 c0                	test   %al,%al
80106adb:	75 65                	jne    80106b42 <trap+0xdf>
      acquire(&tickslock);
80106add:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106ae4:	e8 8a e6 ff ff       	call   80105173 <acquire>
      ticks++;
80106ae9:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80106aee:	83 c0 01             	add    $0x1,%eax
80106af1:	a3 c0 2c 11 80       	mov    %eax,0x80112cc0
      if(proc)
80106af6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106afc:	85 c0                	test   %eax,%eax
80106afe:	74 2a                	je     80106b2a <trap+0xc7>
      {
	proc->rtime++;
80106b00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b06:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106b0c:	83 c2 01             	add    $0x1,%edx
80106b0f:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	proc->quanta--;
80106b15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b1b:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106b21:	83 ea 01             	sub    $0x1,%edx
80106b24:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
      wakeup(&ticks);
80106b2a:	c7 04 24 c0 2c 11 80 	movl   $0x80112cc0,(%esp)
80106b31:	e8 b0 e3 ff ff       	call   80104ee6 <wakeup>
      release(&tickslock);
80106b36:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106b3d:	e8 93 e6 ff ff       	call   801051d5 <release>
    }
    lapiceoi();
80106b42:	e8 7e c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106b47:	e9 41 01 00 00       	jmp    80106c8d <trap+0x22a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b4c:	e8 7c be ff ff       	call   801029cd <ideintr>
    lapiceoi();
80106b51:	e8 6f c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106b56:	e9 32 01 00 00       	jmp    80106c8d <trap+0x22a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b5b:	e8 43 c4 ff ff       	call   80102fa3 <kbdintr>
    lapiceoi();
80106b60:	e8 60 c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106b65:	e9 23 01 00 00       	jmp    80106c8d <trap+0x22a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b6a:	e8 b9 03 00 00       	call   80106f28 <uartintr>
    lapiceoi();
80106b6f:	e8 51 c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106b74:	e9 14 01 00 00       	jmp    80106c8d <trap+0x22a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106b79:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b7c:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106b82:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b86:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106b89:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b8f:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b92:	0f b6 c0             	movzbl %al,%eax
80106b95:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b99:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ba1:	c7 04 24 84 8c 10 80 	movl   $0x80108c84,(%esp)
80106ba8:	e8 f4 97 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106bad:	e8 13 c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106bb2:	e9 d6 00 00 00       	jmp    80106c8d <trap+0x22a>
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106bb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bbd:	85 c0                	test   %eax,%eax
80106bbf:	74 11                	je     80106bd2 <trap+0x16f>
80106bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80106bc4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bc8:	0f b7 c0             	movzwl %ax,%eax
80106bcb:	83 e0 03             	and    $0x3,%eax
80106bce:	85 c0                	test   %eax,%eax
80106bd0:	75 46                	jne    80106c18 <trap+0x1b5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106bd2:	e8 e6 fc ff ff       	call   801068bd <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106bd7:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106bda:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106bdd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106be4:	0f b6 12             	movzbl (%edx),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106be7:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106bea:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106bed:	8b 52 30             	mov    0x30(%edx),%edx
80106bf0:	89 44 24 10          	mov    %eax,0x10(%esp)
80106bf4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106bf8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106bfc:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c00:	c7 04 24 a8 8c 10 80 	movl   $0x80108ca8,(%esp)
80106c07:	e8 95 97 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c0c:	c7 04 24 da 8c 10 80 	movl   $0x80108cda,(%esp)
80106c13:	e8 25 99 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c18:	e8 a0 fc ff ff       	call   801068bd <rcr2>
80106c1d:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c1f:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c22:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c25:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c2b:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c2e:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c31:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c34:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c37:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c3a:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c43:	83 c0 6c             	add    $0x6c,%eax
80106c46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c4f:	8b 40 10             	mov    0x10(%eax),%eax
80106c52:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106c56:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106c5a:	89 74 24 14          	mov    %esi,0x14(%esp)
80106c5e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106c62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106c69:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c71:	c7 04 24 e0 8c 10 80 	movl   $0x80108ce0,(%esp)
80106c78:	e8 24 97 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106c7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c83:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106c8a:	eb 01                	jmp    80106c8d <trap+0x22a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106c8c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c93:	85 c0                	test   %eax,%eax
80106c95:	74 24                	je     80106cbb <trap+0x258>
80106c97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c9d:	8b 40 24             	mov    0x24(%eax),%eax
80106ca0:	85 c0                	test   %eax,%eax
80106ca2:	74 17                	je     80106cbb <trap+0x258>
80106ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cab:	0f b7 c0             	movzwl %ax,%eax
80106cae:	83 e0 03             	and    $0x3,%eax
80106cb1:	83 f8 03             	cmp    $0x3,%eax
80106cb4:	75 05                	jne    80106cbb <trap+0x258>
    exit();
80106cb6:	e8 ab da ff ff       	call   80104766 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && proc->quanta <= 0)
80106cbb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cc1:	85 c0                	test   %eax,%eax
80106cc3:	74 2e                	je     80106cf3 <trap+0x290>
80106cc5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ccb:	8b 40 0c             	mov    0xc(%eax),%eax
80106cce:	83 f8 04             	cmp    $0x4,%eax
80106cd1:	75 20                	jne    80106cf3 <trap+0x290>
80106cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd6:	8b 40 30             	mov    0x30(%eax),%eax
80106cd9:	83 f8 20             	cmp    $0x20,%eax
80106cdc:	75 15                	jne    80106cf3 <trap+0x290>
80106cde:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ce4:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106cea:	85 c0                	test   %eax,%eax
80106cec:	7f 05                	jg     80106cf3 <trap+0x290>
    yield();
80106cee:	e8 b9 e0 ff ff       	call   80104dac <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cf3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cf9:	85 c0                	test   %eax,%eax
80106cfb:	74 27                	je     80106d24 <trap+0x2c1>
80106cfd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d03:	8b 40 24             	mov    0x24(%eax),%eax
80106d06:	85 c0                	test   %eax,%eax
80106d08:	74 1a                	je     80106d24 <trap+0x2c1>
80106d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d11:	0f b7 c0             	movzwl %ax,%eax
80106d14:	83 e0 03             	and    $0x3,%eax
80106d17:	83 f8 03             	cmp    $0x3,%eax
80106d1a:	75 08                	jne    80106d24 <trap+0x2c1>
    exit();
80106d1c:	e8 45 da ff ff       	call   80104766 <exit>
80106d21:	eb 01                	jmp    80106d24 <trap+0x2c1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106d23:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106d24:	83 c4 3c             	add    $0x3c,%esp
80106d27:	5b                   	pop    %ebx
80106d28:	5e                   	pop    %esi
80106d29:	5f                   	pop    %edi
80106d2a:	5d                   	pop    %ebp
80106d2b:	c3                   	ret    

80106d2c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d2c:	55                   	push   %ebp
80106d2d:	89 e5                	mov    %esp,%ebp
80106d2f:	53                   	push   %ebx
80106d30:	83 ec 14             	sub    $0x14,%esp
80106d33:	8b 45 08             	mov    0x8(%ebp),%eax
80106d36:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d3a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106d3e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106d42:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106d46:	ec                   	in     (%dx),%al
80106d47:	89 c3                	mov    %eax,%ebx
80106d49:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106d4c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106d50:	83 c4 14             	add    $0x14,%esp
80106d53:	5b                   	pop    %ebx
80106d54:	5d                   	pop    %ebp
80106d55:	c3                   	ret    

80106d56 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106d56:	55                   	push   %ebp
80106d57:	89 e5                	mov    %esp,%ebp
80106d59:	83 ec 08             	sub    $0x8,%esp
80106d5c:	8b 55 08             	mov    0x8(%ebp),%edx
80106d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d62:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d66:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d69:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d6d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d71:	ee                   	out    %al,(%dx)
}
80106d72:	c9                   	leave  
80106d73:	c3                   	ret    

80106d74 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d74:	55                   	push   %ebp
80106d75:	89 e5                	mov    %esp,%ebp
80106d77:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d81:	00 
80106d82:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106d89:	e8 c8 ff ff ff       	call   80106d56 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106d8e:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106d95:	00 
80106d96:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106d9d:	e8 b4 ff ff ff       	call   80106d56 <outb>
  outb(COM1+0, 115200/9600);
80106da2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106da9:	00 
80106daa:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106db1:	e8 a0 ff ff ff       	call   80106d56 <outb>
  outb(COM1+1, 0);
80106db6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106dbd:	00 
80106dbe:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106dc5:	e8 8c ff ff ff       	call   80106d56 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106dca:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106dd1:	00 
80106dd2:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106dd9:	e8 78 ff ff ff       	call   80106d56 <outb>
  outb(COM1+4, 0);
80106dde:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106de5:	00 
80106de6:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106ded:	e8 64 ff ff ff       	call   80106d56 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106df2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106df9:	00 
80106dfa:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e01:	e8 50 ff ff ff       	call   80106d56 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e06:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e0d:	e8 1a ff ff ff       	call   80106d2c <inb>
80106e12:	3c ff                	cmp    $0xff,%al
80106e14:	74 6c                	je     80106e82 <uartinit+0x10e>
    return;
  uart = 1;
80106e16:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106e1d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e20:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e27:	e8 00 ff ff ff       	call   80106d2c <inb>
  inb(COM1+0);
80106e2c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e33:	e8 f4 fe ff ff       	call   80106d2c <inb>
  picenable(IRQ_COM1);
80106e38:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e3f:	e8 59 cf ff ff       	call   80103d9d <picenable>
  ioapicenable(IRQ_COM1, 0);
80106e44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e4b:	00 
80106e4c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e53:	e8 fa bd ff ff       	call   80102c52 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e58:	c7 45 f4 a4 8d 10 80 	movl   $0x80108da4,-0xc(%ebp)
80106e5f:	eb 15                	jmp    80106e76 <uartinit+0x102>
    uartputc(*p);
80106e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e64:	0f b6 00             	movzbl (%eax),%eax
80106e67:	0f be c0             	movsbl %al,%eax
80106e6a:	89 04 24             	mov    %eax,(%esp)
80106e6d:	e8 13 00 00 00       	call   80106e85 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e79:	0f b6 00             	movzbl (%eax),%eax
80106e7c:	84 c0                	test   %al,%al
80106e7e:	75 e1                	jne    80106e61 <uartinit+0xed>
80106e80:	eb 01                	jmp    80106e83 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106e82:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106e83:	c9                   	leave  
80106e84:	c3                   	ret    

80106e85 <uartputc>:

void
uartputc(int c)
{
80106e85:	55                   	push   %ebp
80106e86:	89 e5                	mov    %esp,%ebp
80106e88:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106e8b:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106e90:	85 c0                	test   %eax,%eax
80106e92:	74 4d                	je     80106ee1 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106e9b:	eb 10                	jmp    80106ead <uartputc+0x28>
    microdelay(10);
80106e9d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106ea4:	e8 41 c3 ff ff       	call   801031ea <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ea9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ead:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106eb1:	7f 16                	jg     80106ec9 <uartputc+0x44>
80106eb3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106eba:	e8 6d fe ff ff       	call   80106d2c <inb>
80106ebf:	0f b6 c0             	movzbl %al,%eax
80106ec2:	83 e0 20             	and    $0x20,%eax
80106ec5:	85 c0                	test   %eax,%eax
80106ec7:	74 d4                	je     80106e9d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80106ecc:	0f b6 c0             	movzbl %al,%eax
80106ecf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ed3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106eda:	e8 77 fe ff ff       	call   80106d56 <outb>
80106edf:	eb 01                	jmp    80106ee2 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106ee1:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106ee2:	c9                   	leave  
80106ee3:	c3                   	ret    

80106ee4 <uartgetc>:

static int
uartgetc(void)
{
80106ee4:	55                   	push   %ebp
80106ee5:	89 e5                	mov    %esp,%ebp
80106ee7:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106eea:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106eef:	85 c0                	test   %eax,%eax
80106ef1:	75 07                	jne    80106efa <uartgetc+0x16>
    return -1;
80106ef3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ef8:	eb 2c                	jmp    80106f26 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106efa:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f01:	e8 26 fe ff ff       	call   80106d2c <inb>
80106f06:	0f b6 c0             	movzbl %al,%eax
80106f09:	83 e0 01             	and    $0x1,%eax
80106f0c:	85 c0                	test   %eax,%eax
80106f0e:	75 07                	jne    80106f17 <uartgetc+0x33>
    return -1;
80106f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f15:	eb 0f                	jmp    80106f26 <uartgetc+0x42>
  return inb(COM1+0);
80106f17:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f1e:	e8 09 fe ff ff       	call   80106d2c <inb>
80106f23:	0f b6 c0             	movzbl %al,%eax
}
80106f26:	c9                   	leave  
80106f27:	c3                   	ret    

80106f28 <uartintr>:

void
uartintr(void)
{
80106f28:	55                   	push   %ebp
80106f29:	89 e5                	mov    %esp,%ebp
80106f2b:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106f2e:	c7 04 24 e4 6e 10 80 	movl   $0x80106ee4,(%esp)
80106f35:	e8 f5 99 ff ff       	call   8010092f <consoleintr>
}
80106f3a:	c9                   	leave  
80106f3b:	c3                   	ret    

80106f3c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $0
80106f3e:	6a 00                	push   $0x0
  jmp alltraps
80106f40:	e9 23 f9 ff ff       	jmp    80106868 <alltraps>

80106f45 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $1
80106f47:	6a 01                	push   $0x1
  jmp alltraps
80106f49:	e9 1a f9 ff ff       	jmp    80106868 <alltraps>

80106f4e <vector2>:
.globl vector2
vector2:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $2
80106f50:	6a 02                	push   $0x2
  jmp alltraps
80106f52:	e9 11 f9 ff ff       	jmp    80106868 <alltraps>

80106f57 <vector3>:
.globl vector3
vector3:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $3
80106f59:	6a 03                	push   $0x3
  jmp alltraps
80106f5b:	e9 08 f9 ff ff       	jmp    80106868 <alltraps>

80106f60 <vector4>:
.globl vector4
vector4:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $4
80106f62:	6a 04                	push   $0x4
  jmp alltraps
80106f64:	e9 ff f8 ff ff       	jmp    80106868 <alltraps>

80106f69 <vector5>:
.globl vector5
vector5:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $5
80106f6b:	6a 05                	push   $0x5
  jmp alltraps
80106f6d:	e9 f6 f8 ff ff       	jmp    80106868 <alltraps>

80106f72 <vector6>:
.globl vector6
vector6:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $6
80106f74:	6a 06                	push   $0x6
  jmp alltraps
80106f76:	e9 ed f8 ff ff       	jmp    80106868 <alltraps>

80106f7b <vector7>:
.globl vector7
vector7:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $7
80106f7d:	6a 07                	push   $0x7
  jmp alltraps
80106f7f:	e9 e4 f8 ff ff       	jmp    80106868 <alltraps>

80106f84 <vector8>:
.globl vector8
vector8:
  pushl $8
80106f84:	6a 08                	push   $0x8
  jmp alltraps
80106f86:	e9 dd f8 ff ff       	jmp    80106868 <alltraps>

80106f8b <vector9>:
.globl vector9
vector9:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $9
80106f8d:	6a 09                	push   $0x9
  jmp alltraps
80106f8f:	e9 d4 f8 ff ff       	jmp    80106868 <alltraps>

80106f94 <vector10>:
.globl vector10
vector10:
  pushl $10
80106f94:	6a 0a                	push   $0xa
  jmp alltraps
80106f96:	e9 cd f8 ff ff       	jmp    80106868 <alltraps>

80106f9b <vector11>:
.globl vector11
vector11:
  pushl $11
80106f9b:	6a 0b                	push   $0xb
  jmp alltraps
80106f9d:	e9 c6 f8 ff ff       	jmp    80106868 <alltraps>

80106fa2 <vector12>:
.globl vector12
vector12:
  pushl $12
80106fa2:	6a 0c                	push   $0xc
  jmp alltraps
80106fa4:	e9 bf f8 ff ff       	jmp    80106868 <alltraps>

80106fa9 <vector13>:
.globl vector13
vector13:
  pushl $13
80106fa9:	6a 0d                	push   $0xd
  jmp alltraps
80106fab:	e9 b8 f8 ff ff       	jmp    80106868 <alltraps>

80106fb0 <vector14>:
.globl vector14
vector14:
  pushl $14
80106fb0:	6a 0e                	push   $0xe
  jmp alltraps
80106fb2:	e9 b1 f8 ff ff       	jmp    80106868 <alltraps>

80106fb7 <vector15>:
.globl vector15
vector15:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $15
80106fb9:	6a 0f                	push   $0xf
  jmp alltraps
80106fbb:	e9 a8 f8 ff ff       	jmp    80106868 <alltraps>

80106fc0 <vector16>:
.globl vector16
vector16:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $16
80106fc2:	6a 10                	push   $0x10
  jmp alltraps
80106fc4:	e9 9f f8 ff ff       	jmp    80106868 <alltraps>

80106fc9 <vector17>:
.globl vector17
vector17:
  pushl $17
80106fc9:	6a 11                	push   $0x11
  jmp alltraps
80106fcb:	e9 98 f8 ff ff       	jmp    80106868 <alltraps>

80106fd0 <vector18>:
.globl vector18
vector18:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $18
80106fd2:	6a 12                	push   $0x12
  jmp alltraps
80106fd4:	e9 8f f8 ff ff       	jmp    80106868 <alltraps>

80106fd9 <vector19>:
.globl vector19
vector19:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $19
80106fdb:	6a 13                	push   $0x13
  jmp alltraps
80106fdd:	e9 86 f8 ff ff       	jmp    80106868 <alltraps>

80106fe2 <vector20>:
.globl vector20
vector20:
  pushl $0
80106fe2:	6a 00                	push   $0x0
  pushl $20
80106fe4:	6a 14                	push   $0x14
  jmp alltraps
80106fe6:	e9 7d f8 ff ff       	jmp    80106868 <alltraps>

80106feb <vector21>:
.globl vector21
vector21:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $21
80106fed:	6a 15                	push   $0x15
  jmp alltraps
80106fef:	e9 74 f8 ff ff       	jmp    80106868 <alltraps>

80106ff4 <vector22>:
.globl vector22
vector22:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $22
80106ff6:	6a 16                	push   $0x16
  jmp alltraps
80106ff8:	e9 6b f8 ff ff       	jmp    80106868 <alltraps>

80106ffd <vector23>:
.globl vector23
vector23:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $23
80106fff:	6a 17                	push   $0x17
  jmp alltraps
80107001:	e9 62 f8 ff ff       	jmp    80106868 <alltraps>

80107006 <vector24>:
.globl vector24
vector24:
  pushl $0
80107006:	6a 00                	push   $0x0
  pushl $24
80107008:	6a 18                	push   $0x18
  jmp alltraps
8010700a:	e9 59 f8 ff ff       	jmp    80106868 <alltraps>

8010700f <vector25>:
.globl vector25
vector25:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $25
80107011:	6a 19                	push   $0x19
  jmp alltraps
80107013:	e9 50 f8 ff ff       	jmp    80106868 <alltraps>

80107018 <vector26>:
.globl vector26
vector26:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $26
8010701a:	6a 1a                	push   $0x1a
  jmp alltraps
8010701c:	e9 47 f8 ff ff       	jmp    80106868 <alltraps>

80107021 <vector27>:
.globl vector27
vector27:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $27
80107023:	6a 1b                	push   $0x1b
  jmp alltraps
80107025:	e9 3e f8 ff ff       	jmp    80106868 <alltraps>

8010702a <vector28>:
.globl vector28
vector28:
  pushl $0
8010702a:	6a 00                	push   $0x0
  pushl $28
8010702c:	6a 1c                	push   $0x1c
  jmp alltraps
8010702e:	e9 35 f8 ff ff       	jmp    80106868 <alltraps>

80107033 <vector29>:
.globl vector29
vector29:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $29
80107035:	6a 1d                	push   $0x1d
  jmp alltraps
80107037:	e9 2c f8 ff ff       	jmp    80106868 <alltraps>

8010703c <vector30>:
.globl vector30
vector30:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $30
8010703e:	6a 1e                	push   $0x1e
  jmp alltraps
80107040:	e9 23 f8 ff ff       	jmp    80106868 <alltraps>

80107045 <vector31>:
.globl vector31
vector31:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $31
80107047:	6a 1f                	push   $0x1f
  jmp alltraps
80107049:	e9 1a f8 ff ff       	jmp    80106868 <alltraps>

8010704e <vector32>:
.globl vector32
vector32:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $32
80107050:	6a 20                	push   $0x20
  jmp alltraps
80107052:	e9 11 f8 ff ff       	jmp    80106868 <alltraps>

80107057 <vector33>:
.globl vector33
vector33:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $33
80107059:	6a 21                	push   $0x21
  jmp alltraps
8010705b:	e9 08 f8 ff ff       	jmp    80106868 <alltraps>

80107060 <vector34>:
.globl vector34
vector34:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $34
80107062:	6a 22                	push   $0x22
  jmp alltraps
80107064:	e9 ff f7 ff ff       	jmp    80106868 <alltraps>

80107069 <vector35>:
.globl vector35
vector35:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $35
8010706b:	6a 23                	push   $0x23
  jmp alltraps
8010706d:	e9 f6 f7 ff ff       	jmp    80106868 <alltraps>

80107072 <vector36>:
.globl vector36
vector36:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $36
80107074:	6a 24                	push   $0x24
  jmp alltraps
80107076:	e9 ed f7 ff ff       	jmp    80106868 <alltraps>

8010707b <vector37>:
.globl vector37
vector37:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $37
8010707d:	6a 25                	push   $0x25
  jmp alltraps
8010707f:	e9 e4 f7 ff ff       	jmp    80106868 <alltraps>

80107084 <vector38>:
.globl vector38
vector38:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $38
80107086:	6a 26                	push   $0x26
  jmp alltraps
80107088:	e9 db f7 ff ff       	jmp    80106868 <alltraps>

8010708d <vector39>:
.globl vector39
vector39:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $39
8010708f:	6a 27                	push   $0x27
  jmp alltraps
80107091:	e9 d2 f7 ff ff       	jmp    80106868 <alltraps>

80107096 <vector40>:
.globl vector40
vector40:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $40
80107098:	6a 28                	push   $0x28
  jmp alltraps
8010709a:	e9 c9 f7 ff ff       	jmp    80106868 <alltraps>

8010709f <vector41>:
.globl vector41
vector41:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $41
801070a1:	6a 29                	push   $0x29
  jmp alltraps
801070a3:	e9 c0 f7 ff ff       	jmp    80106868 <alltraps>

801070a8 <vector42>:
.globl vector42
vector42:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $42
801070aa:	6a 2a                	push   $0x2a
  jmp alltraps
801070ac:	e9 b7 f7 ff ff       	jmp    80106868 <alltraps>

801070b1 <vector43>:
.globl vector43
vector43:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $43
801070b3:	6a 2b                	push   $0x2b
  jmp alltraps
801070b5:	e9 ae f7 ff ff       	jmp    80106868 <alltraps>

801070ba <vector44>:
.globl vector44
vector44:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $44
801070bc:	6a 2c                	push   $0x2c
  jmp alltraps
801070be:	e9 a5 f7 ff ff       	jmp    80106868 <alltraps>

801070c3 <vector45>:
.globl vector45
vector45:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $45
801070c5:	6a 2d                	push   $0x2d
  jmp alltraps
801070c7:	e9 9c f7 ff ff       	jmp    80106868 <alltraps>

801070cc <vector46>:
.globl vector46
vector46:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $46
801070ce:	6a 2e                	push   $0x2e
  jmp alltraps
801070d0:	e9 93 f7 ff ff       	jmp    80106868 <alltraps>

801070d5 <vector47>:
.globl vector47
vector47:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $47
801070d7:	6a 2f                	push   $0x2f
  jmp alltraps
801070d9:	e9 8a f7 ff ff       	jmp    80106868 <alltraps>

801070de <vector48>:
.globl vector48
vector48:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $48
801070e0:	6a 30                	push   $0x30
  jmp alltraps
801070e2:	e9 81 f7 ff ff       	jmp    80106868 <alltraps>

801070e7 <vector49>:
.globl vector49
vector49:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $49
801070e9:	6a 31                	push   $0x31
  jmp alltraps
801070eb:	e9 78 f7 ff ff       	jmp    80106868 <alltraps>

801070f0 <vector50>:
.globl vector50
vector50:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $50
801070f2:	6a 32                	push   $0x32
  jmp alltraps
801070f4:	e9 6f f7 ff ff       	jmp    80106868 <alltraps>

801070f9 <vector51>:
.globl vector51
vector51:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $51
801070fb:	6a 33                	push   $0x33
  jmp alltraps
801070fd:	e9 66 f7 ff ff       	jmp    80106868 <alltraps>

80107102 <vector52>:
.globl vector52
vector52:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $52
80107104:	6a 34                	push   $0x34
  jmp alltraps
80107106:	e9 5d f7 ff ff       	jmp    80106868 <alltraps>

8010710b <vector53>:
.globl vector53
vector53:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $53
8010710d:	6a 35                	push   $0x35
  jmp alltraps
8010710f:	e9 54 f7 ff ff       	jmp    80106868 <alltraps>

80107114 <vector54>:
.globl vector54
vector54:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $54
80107116:	6a 36                	push   $0x36
  jmp alltraps
80107118:	e9 4b f7 ff ff       	jmp    80106868 <alltraps>

8010711d <vector55>:
.globl vector55
vector55:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $55
8010711f:	6a 37                	push   $0x37
  jmp alltraps
80107121:	e9 42 f7 ff ff       	jmp    80106868 <alltraps>

80107126 <vector56>:
.globl vector56
vector56:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $56
80107128:	6a 38                	push   $0x38
  jmp alltraps
8010712a:	e9 39 f7 ff ff       	jmp    80106868 <alltraps>

8010712f <vector57>:
.globl vector57
vector57:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $57
80107131:	6a 39                	push   $0x39
  jmp alltraps
80107133:	e9 30 f7 ff ff       	jmp    80106868 <alltraps>

80107138 <vector58>:
.globl vector58
vector58:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $58
8010713a:	6a 3a                	push   $0x3a
  jmp alltraps
8010713c:	e9 27 f7 ff ff       	jmp    80106868 <alltraps>

80107141 <vector59>:
.globl vector59
vector59:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $59
80107143:	6a 3b                	push   $0x3b
  jmp alltraps
80107145:	e9 1e f7 ff ff       	jmp    80106868 <alltraps>

8010714a <vector60>:
.globl vector60
vector60:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $60
8010714c:	6a 3c                	push   $0x3c
  jmp alltraps
8010714e:	e9 15 f7 ff ff       	jmp    80106868 <alltraps>

80107153 <vector61>:
.globl vector61
vector61:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $61
80107155:	6a 3d                	push   $0x3d
  jmp alltraps
80107157:	e9 0c f7 ff ff       	jmp    80106868 <alltraps>

8010715c <vector62>:
.globl vector62
vector62:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $62
8010715e:	6a 3e                	push   $0x3e
  jmp alltraps
80107160:	e9 03 f7 ff ff       	jmp    80106868 <alltraps>

80107165 <vector63>:
.globl vector63
vector63:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $63
80107167:	6a 3f                	push   $0x3f
  jmp alltraps
80107169:	e9 fa f6 ff ff       	jmp    80106868 <alltraps>

8010716e <vector64>:
.globl vector64
vector64:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $64
80107170:	6a 40                	push   $0x40
  jmp alltraps
80107172:	e9 f1 f6 ff ff       	jmp    80106868 <alltraps>

80107177 <vector65>:
.globl vector65
vector65:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $65
80107179:	6a 41                	push   $0x41
  jmp alltraps
8010717b:	e9 e8 f6 ff ff       	jmp    80106868 <alltraps>

80107180 <vector66>:
.globl vector66
vector66:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $66
80107182:	6a 42                	push   $0x42
  jmp alltraps
80107184:	e9 df f6 ff ff       	jmp    80106868 <alltraps>

80107189 <vector67>:
.globl vector67
vector67:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $67
8010718b:	6a 43                	push   $0x43
  jmp alltraps
8010718d:	e9 d6 f6 ff ff       	jmp    80106868 <alltraps>

80107192 <vector68>:
.globl vector68
vector68:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $68
80107194:	6a 44                	push   $0x44
  jmp alltraps
80107196:	e9 cd f6 ff ff       	jmp    80106868 <alltraps>

8010719b <vector69>:
.globl vector69
vector69:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $69
8010719d:	6a 45                	push   $0x45
  jmp alltraps
8010719f:	e9 c4 f6 ff ff       	jmp    80106868 <alltraps>

801071a4 <vector70>:
.globl vector70
vector70:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $70
801071a6:	6a 46                	push   $0x46
  jmp alltraps
801071a8:	e9 bb f6 ff ff       	jmp    80106868 <alltraps>

801071ad <vector71>:
.globl vector71
vector71:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $71
801071af:	6a 47                	push   $0x47
  jmp alltraps
801071b1:	e9 b2 f6 ff ff       	jmp    80106868 <alltraps>

801071b6 <vector72>:
.globl vector72
vector72:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $72
801071b8:	6a 48                	push   $0x48
  jmp alltraps
801071ba:	e9 a9 f6 ff ff       	jmp    80106868 <alltraps>

801071bf <vector73>:
.globl vector73
vector73:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $73
801071c1:	6a 49                	push   $0x49
  jmp alltraps
801071c3:	e9 a0 f6 ff ff       	jmp    80106868 <alltraps>

801071c8 <vector74>:
.globl vector74
vector74:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $74
801071ca:	6a 4a                	push   $0x4a
  jmp alltraps
801071cc:	e9 97 f6 ff ff       	jmp    80106868 <alltraps>

801071d1 <vector75>:
.globl vector75
vector75:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $75
801071d3:	6a 4b                	push   $0x4b
  jmp alltraps
801071d5:	e9 8e f6 ff ff       	jmp    80106868 <alltraps>

801071da <vector76>:
.globl vector76
vector76:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $76
801071dc:	6a 4c                	push   $0x4c
  jmp alltraps
801071de:	e9 85 f6 ff ff       	jmp    80106868 <alltraps>

801071e3 <vector77>:
.globl vector77
vector77:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $77
801071e5:	6a 4d                	push   $0x4d
  jmp alltraps
801071e7:	e9 7c f6 ff ff       	jmp    80106868 <alltraps>

801071ec <vector78>:
.globl vector78
vector78:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $78
801071ee:	6a 4e                	push   $0x4e
  jmp alltraps
801071f0:	e9 73 f6 ff ff       	jmp    80106868 <alltraps>

801071f5 <vector79>:
.globl vector79
vector79:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $79
801071f7:	6a 4f                	push   $0x4f
  jmp alltraps
801071f9:	e9 6a f6 ff ff       	jmp    80106868 <alltraps>

801071fe <vector80>:
.globl vector80
vector80:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $80
80107200:	6a 50                	push   $0x50
  jmp alltraps
80107202:	e9 61 f6 ff ff       	jmp    80106868 <alltraps>

80107207 <vector81>:
.globl vector81
vector81:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $81
80107209:	6a 51                	push   $0x51
  jmp alltraps
8010720b:	e9 58 f6 ff ff       	jmp    80106868 <alltraps>

80107210 <vector82>:
.globl vector82
vector82:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $82
80107212:	6a 52                	push   $0x52
  jmp alltraps
80107214:	e9 4f f6 ff ff       	jmp    80106868 <alltraps>

80107219 <vector83>:
.globl vector83
vector83:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $83
8010721b:	6a 53                	push   $0x53
  jmp alltraps
8010721d:	e9 46 f6 ff ff       	jmp    80106868 <alltraps>

80107222 <vector84>:
.globl vector84
vector84:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $84
80107224:	6a 54                	push   $0x54
  jmp alltraps
80107226:	e9 3d f6 ff ff       	jmp    80106868 <alltraps>

8010722b <vector85>:
.globl vector85
vector85:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $85
8010722d:	6a 55                	push   $0x55
  jmp alltraps
8010722f:	e9 34 f6 ff ff       	jmp    80106868 <alltraps>

80107234 <vector86>:
.globl vector86
vector86:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $86
80107236:	6a 56                	push   $0x56
  jmp alltraps
80107238:	e9 2b f6 ff ff       	jmp    80106868 <alltraps>

8010723d <vector87>:
.globl vector87
vector87:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $87
8010723f:	6a 57                	push   $0x57
  jmp alltraps
80107241:	e9 22 f6 ff ff       	jmp    80106868 <alltraps>

80107246 <vector88>:
.globl vector88
vector88:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $88
80107248:	6a 58                	push   $0x58
  jmp alltraps
8010724a:	e9 19 f6 ff ff       	jmp    80106868 <alltraps>

8010724f <vector89>:
.globl vector89
vector89:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $89
80107251:	6a 59                	push   $0x59
  jmp alltraps
80107253:	e9 10 f6 ff ff       	jmp    80106868 <alltraps>

80107258 <vector90>:
.globl vector90
vector90:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $90
8010725a:	6a 5a                	push   $0x5a
  jmp alltraps
8010725c:	e9 07 f6 ff ff       	jmp    80106868 <alltraps>

80107261 <vector91>:
.globl vector91
vector91:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $91
80107263:	6a 5b                	push   $0x5b
  jmp alltraps
80107265:	e9 fe f5 ff ff       	jmp    80106868 <alltraps>

8010726a <vector92>:
.globl vector92
vector92:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $92
8010726c:	6a 5c                	push   $0x5c
  jmp alltraps
8010726e:	e9 f5 f5 ff ff       	jmp    80106868 <alltraps>

80107273 <vector93>:
.globl vector93
vector93:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $93
80107275:	6a 5d                	push   $0x5d
  jmp alltraps
80107277:	e9 ec f5 ff ff       	jmp    80106868 <alltraps>

8010727c <vector94>:
.globl vector94
vector94:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $94
8010727e:	6a 5e                	push   $0x5e
  jmp alltraps
80107280:	e9 e3 f5 ff ff       	jmp    80106868 <alltraps>

80107285 <vector95>:
.globl vector95
vector95:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $95
80107287:	6a 5f                	push   $0x5f
  jmp alltraps
80107289:	e9 da f5 ff ff       	jmp    80106868 <alltraps>

8010728e <vector96>:
.globl vector96
vector96:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $96
80107290:	6a 60                	push   $0x60
  jmp alltraps
80107292:	e9 d1 f5 ff ff       	jmp    80106868 <alltraps>

80107297 <vector97>:
.globl vector97
vector97:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $97
80107299:	6a 61                	push   $0x61
  jmp alltraps
8010729b:	e9 c8 f5 ff ff       	jmp    80106868 <alltraps>

801072a0 <vector98>:
.globl vector98
vector98:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $98
801072a2:	6a 62                	push   $0x62
  jmp alltraps
801072a4:	e9 bf f5 ff ff       	jmp    80106868 <alltraps>

801072a9 <vector99>:
.globl vector99
vector99:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $99
801072ab:	6a 63                	push   $0x63
  jmp alltraps
801072ad:	e9 b6 f5 ff ff       	jmp    80106868 <alltraps>

801072b2 <vector100>:
.globl vector100
vector100:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $100
801072b4:	6a 64                	push   $0x64
  jmp alltraps
801072b6:	e9 ad f5 ff ff       	jmp    80106868 <alltraps>

801072bb <vector101>:
.globl vector101
vector101:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $101
801072bd:	6a 65                	push   $0x65
  jmp alltraps
801072bf:	e9 a4 f5 ff ff       	jmp    80106868 <alltraps>

801072c4 <vector102>:
.globl vector102
vector102:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $102
801072c6:	6a 66                	push   $0x66
  jmp alltraps
801072c8:	e9 9b f5 ff ff       	jmp    80106868 <alltraps>

801072cd <vector103>:
.globl vector103
vector103:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $103
801072cf:	6a 67                	push   $0x67
  jmp alltraps
801072d1:	e9 92 f5 ff ff       	jmp    80106868 <alltraps>

801072d6 <vector104>:
.globl vector104
vector104:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $104
801072d8:	6a 68                	push   $0x68
  jmp alltraps
801072da:	e9 89 f5 ff ff       	jmp    80106868 <alltraps>

801072df <vector105>:
.globl vector105
vector105:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $105
801072e1:	6a 69                	push   $0x69
  jmp alltraps
801072e3:	e9 80 f5 ff ff       	jmp    80106868 <alltraps>

801072e8 <vector106>:
.globl vector106
vector106:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $106
801072ea:	6a 6a                	push   $0x6a
  jmp alltraps
801072ec:	e9 77 f5 ff ff       	jmp    80106868 <alltraps>

801072f1 <vector107>:
.globl vector107
vector107:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $107
801072f3:	6a 6b                	push   $0x6b
  jmp alltraps
801072f5:	e9 6e f5 ff ff       	jmp    80106868 <alltraps>

801072fa <vector108>:
.globl vector108
vector108:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $108
801072fc:	6a 6c                	push   $0x6c
  jmp alltraps
801072fe:	e9 65 f5 ff ff       	jmp    80106868 <alltraps>

80107303 <vector109>:
.globl vector109
vector109:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $109
80107305:	6a 6d                	push   $0x6d
  jmp alltraps
80107307:	e9 5c f5 ff ff       	jmp    80106868 <alltraps>

8010730c <vector110>:
.globl vector110
vector110:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $110
8010730e:	6a 6e                	push   $0x6e
  jmp alltraps
80107310:	e9 53 f5 ff ff       	jmp    80106868 <alltraps>

80107315 <vector111>:
.globl vector111
vector111:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $111
80107317:	6a 6f                	push   $0x6f
  jmp alltraps
80107319:	e9 4a f5 ff ff       	jmp    80106868 <alltraps>

8010731e <vector112>:
.globl vector112
vector112:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $112
80107320:	6a 70                	push   $0x70
  jmp alltraps
80107322:	e9 41 f5 ff ff       	jmp    80106868 <alltraps>

80107327 <vector113>:
.globl vector113
vector113:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $113
80107329:	6a 71                	push   $0x71
  jmp alltraps
8010732b:	e9 38 f5 ff ff       	jmp    80106868 <alltraps>

80107330 <vector114>:
.globl vector114
vector114:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $114
80107332:	6a 72                	push   $0x72
  jmp alltraps
80107334:	e9 2f f5 ff ff       	jmp    80106868 <alltraps>

80107339 <vector115>:
.globl vector115
vector115:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $115
8010733b:	6a 73                	push   $0x73
  jmp alltraps
8010733d:	e9 26 f5 ff ff       	jmp    80106868 <alltraps>

80107342 <vector116>:
.globl vector116
vector116:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $116
80107344:	6a 74                	push   $0x74
  jmp alltraps
80107346:	e9 1d f5 ff ff       	jmp    80106868 <alltraps>

8010734b <vector117>:
.globl vector117
vector117:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $117
8010734d:	6a 75                	push   $0x75
  jmp alltraps
8010734f:	e9 14 f5 ff ff       	jmp    80106868 <alltraps>

80107354 <vector118>:
.globl vector118
vector118:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $118
80107356:	6a 76                	push   $0x76
  jmp alltraps
80107358:	e9 0b f5 ff ff       	jmp    80106868 <alltraps>

8010735d <vector119>:
.globl vector119
vector119:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $119
8010735f:	6a 77                	push   $0x77
  jmp alltraps
80107361:	e9 02 f5 ff ff       	jmp    80106868 <alltraps>

80107366 <vector120>:
.globl vector120
vector120:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $120
80107368:	6a 78                	push   $0x78
  jmp alltraps
8010736a:	e9 f9 f4 ff ff       	jmp    80106868 <alltraps>

8010736f <vector121>:
.globl vector121
vector121:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $121
80107371:	6a 79                	push   $0x79
  jmp alltraps
80107373:	e9 f0 f4 ff ff       	jmp    80106868 <alltraps>

80107378 <vector122>:
.globl vector122
vector122:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $122
8010737a:	6a 7a                	push   $0x7a
  jmp alltraps
8010737c:	e9 e7 f4 ff ff       	jmp    80106868 <alltraps>

80107381 <vector123>:
.globl vector123
vector123:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $123
80107383:	6a 7b                	push   $0x7b
  jmp alltraps
80107385:	e9 de f4 ff ff       	jmp    80106868 <alltraps>

8010738a <vector124>:
.globl vector124
vector124:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $124
8010738c:	6a 7c                	push   $0x7c
  jmp alltraps
8010738e:	e9 d5 f4 ff ff       	jmp    80106868 <alltraps>

80107393 <vector125>:
.globl vector125
vector125:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $125
80107395:	6a 7d                	push   $0x7d
  jmp alltraps
80107397:	e9 cc f4 ff ff       	jmp    80106868 <alltraps>

8010739c <vector126>:
.globl vector126
vector126:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $126
8010739e:	6a 7e                	push   $0x7e
  jmp alltraps
801073a0:	e9 c3 f4 ff ff       	jmp    80106868 <alltraps>

801073a5 <vector127>:
.globl vector127
vector127:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $127
801073a7:	6a 7f                	push   $0x7f
  jmp alltraps
801073a9:	e9 ba f4 ff ff       	jmp    80106868 <alltraps>

801073ae <vector128>:
.globl vector128
vector128:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $128
801073b0:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073b5:	e9 ae f4 ff ff       	jmp    80106868 <alltraps>

801073ba <vector129>:
.globl vector129
vector129:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $129
801073bc:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073c1:	e9 a2 f4 ff ff       	jmp    80106868 <alltraps>

801073c6 <vector130>:
.globl vector130
vector130:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $130
801073c8:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073cd:	e9 96 f4 ff ff       	jmp    80106868 <alltraps>

801073d2 <vector131>:
.globl vector131
vector131:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $131
801073d4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073d9:	e9 8a f4 ff ff       	jmp    80106868 <alltraps>

801073de <vector132>:
.globl vector132
vector132:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $132
801073e0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801073e5:	e9 7e f4 ff ff       	jmp    80106868 <alltraps>

801073ea <vector133>:
.globl vector133
vector133:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $133
801073ec:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801073f1:	e9 72 f4 ff ff       	jmp    80106868 <alltraps>

801073f6 <vector134>:
.globl vector134
vector134:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $134
801073f8:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801073fd:	e9 66 f4 ff ff       	jmp    80106868 <alltraps>

80107402 <vector135>:
.globl vector135
vector135:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $135
80107404:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107409:	e9 5a f4 ff ff       	jmp    80106868 <alltraps>

8010740e <vector136>:
.globl vector136
vector136:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $136
80107410:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107415:	e9 4e f4 ff ff       	jmp    80106868 <alltraps>

8010741a <vector137>:
.globl vector137
vector137:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $137
8010741c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107421:	e9 42 f4 ff ff       	jmp    80106868 <alltraps>

80107426 <vector138>:
.globl vector138
vector138:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $138
80107428:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010742d:	e9 36 f4 ff ff       	jmp    80106868 <alltraps>

80107432 <vector139>:
.globl vector139
vector139:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $139
80107434:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107439:	e9 2a f4 ff ff       	jmp    80106868 <alltraps>

8010743e <vector140>:
.globl vector140
vector140:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $140
80107440:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107445:	e9 1e f4 ff ff       	jmp    80106868 <alltraps>

8010744a <vector141>:
.globl vector141
vector141:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $141
8010744c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107451:	e9 12 f4 ff ff       	jmp    80106868 <alltraps>

80107456 <vector142>:
.globl vector142
vector142:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $142
80107458:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010745d:	e9 06 f4 ff ff       	jmp    80106868 <alltraps>

80107462 <vector143>:
.globl vector143
vector143:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $143
80107464:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107469:	e9 fa f3 ff ff       	jmp    80106868 <alltraps>

8010746e <vector144>:
.globl vector144
vector144:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $144
80107470:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107475:	e9 ee f3 ff ff       	jmp    80106868 <alltraps>

8010747a <vector145>:
.globl vector145
vector145:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $145
8010747c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107481:	e9 e2 f3 ff ff       	jmp    80106868 <alltraps>

80107486 <vector146>:
.globl vector146
vector146:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $146
80107488:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010748d:	e9 d6 f3 ff ff       	jmp    80106868 <alltraps>

80107492 <vector147>:
.globl vector147
vector147:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $147
80107494:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107499:	e9 ca f3 ff ff       	jmp    80106868 <alltraps>

8010749e <vector148>:
.globl vector148
vector148:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $148
801074a0:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074a5:	e9 be f3 ff ff       	jmp    80106868 <alltraps>

801074aa <vector149>:
.globl vector149
vector149:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $149
801074ac:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074b1:	e9 b2 f3 ff ff       	jmp    80106868 <alltraps>

801074b6 <vector150>:
.globl vector150
vector150:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $150
801074b8:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074bd:	e9 a6 f3 ff ff       	jmp    80106868 <alltraps>

801074c2 <vector151>:
.globl vector151
vector151:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $151
801074c4:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074c9:	e9 9a f3 ff ff       	jmp    80106868 <alltraps>

801074ce <vector152>:
.globl vector152
vector152:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $152
801074d0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074d5:	e9 8e f3 ff ff       	jmp    80106868 <alltraps>

801074da <vector153>:
.globl vector153
vector153:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $153
801074dc:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801074e1:	e9 82 f3 ff ff       	jmp    80106868 <alltraps>

801074e6 <vector154>:
.globl vector154
vector154:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $154
801074e8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801074ed:	e9 76 f3 ff ff       	jmp    80106868 <alltraps>

801074f2 <vector155>:
.globl vector155
vector155:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $155
801074f4:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801074f9:	e9 6a f3 ff ff       	jmp    80106868 <alltraps>

801074fe <vector156>:
.globl vector156
vector156:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $156
80107500:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107505:	e9 5e f3 ff ff       	jmp    80106868 <alltraps>

8010750a <vector157>:
.globl vector157
vector157:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $157
8010750c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107511:	e9 52 f3 ff ff       	jmp    80106868 <alltraps>

80107516 <vector158>:
.globl vector158
vector158:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $158
80107518:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010751d:	e9 46 f3 ff ff       	jmp    80106868 <alltraps>

80107522 <vector159>:
.globl vector159
vector159:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $159
80107524:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107529:	e9 3a f3 ff ff       	jmp    80106868 <alltraps>

8010752e <vector160>:
.globl vector160
vector160:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $160
80107530:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107535:	e9 2e f3 ff ff       	jmp    80106868 <alltraps>

8010753a <vector161>:
.globl vector161
vector161:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $161
8010753c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107541:	e9 22 f3 ff ff       	jmp    80106868 <alltraps>

80107546 <vector162>:
.globl vector162
vector162:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $162
80107548:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010754d:	e9 16 f3 ff ff       	jmp    80106868 <alltraps>

80107552 <vector163>:
.globl vector163
vector163:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $163
80107554:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107559:	e9 0a f3 ff ff       	jmp    80106868 <alltraps>

8010755e <vector164>:
.globl vector164
vector164:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $164
80107560:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107565:	e9 fe f2 ff ff       	jmp    80106868 <alltraps>

8010756a <vector165>:
.globl vector165
vector165:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $165
8010756c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107571:	e9 f2 f2 ff ff       	jmp    80106868 <alltraps>

80107576 <vector166>:
.globl vector166
vector166:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $166
80107578:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010757d:	e9 e6 f2 ff ff       	jmp    80106868 <alltraps>

80107582 <vector167>:
.globl vector167
vector167:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $167
80107584:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107589:	e9 da f2 ff ff       	jmp    80106868 <alltraps>

8010758e <vector168>:
.globl vector168
vector168:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $168
80107590:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107595:	e9 ce f2 ff ff       	jmp    80106868 <alltraps>

8010759a <vector169>:
.globl vector169
vector169:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $169
8010759c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075a1:	e9 c2 f2 ff ff       	jmp    80106868 <alltraps>

801075a6 <vector170>:
.globl vector170
vector170:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $170
801075a8:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075ad:	e9 b6 f2 ff ff       	jmp    80106868 <alltraps>

801075b2 <vector171>:
.globl vector171
vector171:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $171
801075b4:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075b9:	e9 aa f2 ff ff       	jmp    80106868 <alltraps>

801075be <vector172>:
.globl vector172
vector172:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $172
801075c0:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075c5:	e9 9e f2 ff ff       	jmp    80106868 <alltraps>

801075ca <vector173>:
.globl vector173
vector173:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $173
801075cc:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075d1:	e9 92 f2 ff ff       	jmp    80106868 <alltraps>

801075d6 <vector174>:
.globl vector174
vector174:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $174
801075d8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075dd:	e9 86 f2 ff ff       	jmp    80106868 <alltraps>

801075e2 <vector175>:
.globl vector175
vector175:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $175
801075e4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801075e9:	e9 7a f2 ff ff       	jmp    80106868 <alltraps>

801075ee <vector176>:
.globl vector176
vector176:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $176
801075f0:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801075f5:	e9 6e f2 ff ff       	jmp    80106868 <alltraps>

801075fa <vector177>:
.globl vector177
vector177:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $177
801075fc:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107601:	e9 62 f2 ff ff       	jmp    80106868 <alltraps>

80107606 <vector178>:
.globl vector178
vector178:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $178
80107608:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010760d:	e9 56 f2 ff ff       	jmp    80106868 <alltraps>

80107612 <vector179>:
.globl vector179
vector179:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $179
80107614:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107619:	e9 4a f2 ff ff       	jmp    80106868 <alltraps>

8010761e <vector180>:
.globl vector180
vector180:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $180
80107620:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107625:	e9 3e f2 ff ff       	jmp    80106868 <alltraps>

8010762a <vector181>:
.globl vector181
vector181:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $181
8010762c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107631:	e9 32 f2 ff ff       	jmp    80106868 <alltraps>

80107636 <vector182>:
.globl vector182
vector182:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $182
80107638:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010763d:	e9 26 f2 ff ff       	jmp    80106868 <alltraps>

80107642 <vector183>:
.globl vector183
vector183:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $183
80107644:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107649:	e9 1a f2 ff ff       	jmp    80106868 <alltraps>

8010764e <vector184>:
.globl vector184
vector184:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $184
80107650:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107655:	e9 0e f2 ff ff       	jmp    80106868 <alltraps>

8010765a <vector185>:
.globl vector185
vector185:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $185
8010765c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107661:	e9 02 f2 ff ff       	jmp    80106868 <alltraps>

80107666 <vector186>:
.globl vector186
vector186:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $186
80107668:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010766d:	e9 f6 f1 ff ff       	jmp    80106868 <alltraps>

80107672 <vector187>:
.globl vector187
vector187:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $187
80107674:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107679:	e9 ea f1 ff ff       	jmp    80106868 <alltraps>

8010767e <vector188>:
.globl vector188
vector188:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $188
80107680:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107685:	e9 de f1 ff ff       	jmp    80106868 <alltraps>

8010768a <vector189>:
.globl vector189
vector189:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $189
8010768c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107691:	e9 d2 f1 ff ff       	jmp    80106868 <alltraps>

80107696 <vector190>:
.globl vector190
vector190:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $190
80107698:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010769d:	e9 c6 f1 ff ff       	jmp    80106868 <alltraps>

801076a2 <vector191>:
.globl vector191
vector191:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $191
801076a4:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076a9:	e9 ba f1 ff ff       	jmp    80106868 <alltraps>

801076ae <vector192>:
.globl vector192
vector192:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $192
801076b0:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076b5:	e9 ae f1 ff ff       	jmp    80106868 <alltraps>

801076ba <vector193>:
.globl vector193
vector193:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $193
801076bc:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076c1:	e9 a2 f1 ff ff       	jmp    80106868 <alltraps>

801076c6 <vector194>:
.globl vector194
vector194:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $194
801076c8:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076cd:	e9 96 f1 ff ff       	jmp    80106868 <alltraps>

801076d2 <vector195>:
.globl vector195
vector195:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $195
801076d4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076d9:	e9 8a f1 ff ff       	jmp    80106868 <alltraps>

801076de <vector196>:
.globl vector196
vector196:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $196
801076e0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801076e5:	e9 7e f1 ff ff       	jmp    80106868 <alltraps>

801076ea <vector197>:
.globl vector197
vector197:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $197
801076ec:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801076f1:	e9 72 f1 ff ff       	jmp    80106868 <alltraps>

801076f6 <vector198>:
.globl vector198
vector198:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $198
801076f8:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801076fd:	e9 66 f1 ff ff       	jmp    80106868 <alltraps>

80107702 <vector199>:
.globl vector199
vector199:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $199
80107704:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107709:	e9 5a f1 ff ff       	jmp    80106868 <alltraps>

8010770e <vector200>:
.globl vector200
vector200:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $200
80107710:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107715:	e9 4e f1 ff ff       	jmp    80106868 <alltraps>

8010771a <vector201>:
.globl vector201
vector201:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $201
8010771c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107721:	e9 42 f1 ff ff       	jmp    80106868 <alltraps>

80107726 <vector202>:
.globl vector202
vector202:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $202
80107728:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010772d:	e9 36 f1 ff ff       	jmp    80106868 <alltraps>

80107732 <vector203>:
.globl vector203
vector203:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $203
80107734:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107739:	e9 2a f1 ff ff       	jmp    80106868 <alltraps>

8010773e <vector204>:
.globl vector204
vector204:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $204
80107740:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107745:	e9 1e f1 ff ff       	jmp    80106868 <alltraps>

8010774a <vector205>:
.globl vector205
vector205:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $205
8010774c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107751:	e9 12 f1 ff ff       	jmp    80106868 <alltraps>

80107756 <vector206>:
.globl vector206
vector206:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $206
80107758:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010775d:	e9 06 f1 ff ff       	jmp    80106868 <alltraps>

80107762 <vector207>:
.globl vector207
vector207:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $207
80107764:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107769:	e9 fa f0 ff ff       	jmp    80106868 <alltraps>

8010776e <vector208>:
.globl vector208
vector208:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $208
80107770:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107775:	e9 ee f0 ff ff       	jmp    80106868 <alltraps>

8010777a <vector209>:
.globl vector209
vector209:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $209
8010777c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107781:	e9 e2 f0 ff ff       	jmp    80106868 <alltraps>

80107786 <vector210>:
.globl vector210
vector210:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $210
80107788:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010778d:	e9 d6 f0 ff ff       	jmp    80106868 <alltraps>

80107792 <vector211>:
.globl vector211
vector211:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $211
80107794:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107799:	e9 ca f0 ff ff       	jmp    80106868 <alltraps>

8010779e <vector212>:
.globl vector212
vector212:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $212
801077a0:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077a5:	e9 be f0 ff ff       	jmp    80106868 <alltraps>

801077aa <vector213>:
.globl vector213
vector213:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $213
801077ac:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077b1:	e9 b2 f0 ff ff       	jmp    80106868 <alltraps>

801077b6 <vector214>:
.globl vector214
vector214:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $214
801077b8:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077bd:	e9 a6 f0 ff ff       	jmp    80106868 <alltraps>

801077c2 <vector215>:
.globl vector215
vector215:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $215
801077c4:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077c9:	e9 9a f0 ff ff       	jmp    80106868 <alltraps>

801077ce <vector216>:
.globl vector216
vector216:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $216
801077d0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077d5:	e9 8e f0 ff ff       	jmp    80106868 <alltraps>

801077da <vector217>:
.globl vector217
vector217:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $217
801077dc:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801077e1:	e9 82 f0 ff ff       	jmp    80106868 <alltraps>

801077e6 <vector218>:
.globl vector218
vector218:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $218
801077e8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801077ed:	e9 76 f0 ff ff       	jmp    80106868 <alltraps>

801077f2 <vector219>:
.globl vector219
vector219:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $219
801077f4:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801077f9:	e9 6a f0 ff ff       	jmp    80106868 <alltraps>

801077fe <vector220>:
.globl vector220
vector220:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $220
80107800:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107805:	e9 5e f0 ff ff       	jmp    80106868 <alltraps>

8010780a <vector221>:
.globl vector221
vector221:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $221
8010780c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107811:	e9 52 f0 ff ff       	jmp    80106868 <alltraps>

80107816 <vector222>:
.globl vector222
vector222:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $222
80107818:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010781d:	e9 46 f0 ff ff       	jmp    80106868 <alltraps>

80107822 <vector223>:
.globl vector223
vector223:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $223
80107824:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107829:	e9 3a f0 ff ff       	jmp    80106868 <alltraps>

8010782e <vector224>:
.globl vector224
vector224:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $224
80107830:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107835:	e9 2e f0 ff ff       	jmp    80106868 <alltraps>

8010783a <vector225>:
.globl vector225
vector225:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $225
8010783c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107841:	e9 22 f0 ff ff       	jmp    80106868 <alltraps>

80107846 <vector226>:
.globl vector226
vector226:
  pushl $0
80107846:	6a 00                	push   $0x0
  pushl $226
80107848:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010784d:	e9 16 f0 ff ff       	jmp    80106868 <alltraps>

80107852 <vector227>:
.globl vector227
vector227:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $227
80107854:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107859:	e9 0a f0 ff ff       	jmp    80106868 <alltraps>

8010785e <vector228>:
.globl vector228
vector228:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $228
80107860:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107865:	e9 fe ef ff ff       	jmp    80106868 <alltraps>

8010786a <vector229>:
.globl vector229
vector229:
  pushl $0
8010786a:	6a 00                	push   $0x0
  pushl $229
8010786c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107871:	e9 f2 ef ff ff       	jmp    80106868 <alltraps>

80107876 <vector230>:
.globl vector230
vector230:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $230
80107878:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010787d:	e9 e6 ef ff ff       	jmp    80106868 <alltraps>

80107882 <vector231>:
.globl vector231
vector231:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $231
80107884:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107889:	e9 da ef ff ff       	jmp    80106868 <alltraps>

8010788e <vector232>:
.globl vector232
vector232:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $232
80107890:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107895:	e9 ce ef ff ff       	jmp    80106868 <alltraps>

8010789a <vector233>:
.globl vector233
vector233:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $233
8010789c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078a1:	e9 c2 ef ff ff       	jmp    80106868 <alltraps>

801078a6 <vector234>:
.globl vector234
vector234:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $234
801078a8:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078ad:	e9 b6 ef ff ff       	jmp    80106868 <alltraps>

801078b2 <vector235>:
.globl vector235
vector235:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $235
801078b4:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078b9:	e9 aa ef ff ff       	jmp    80106868 <alltraps>

801078be <vector236>:
.globl vector236
vector236:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $236
801078c0:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078c5:	e9 9e ef ff ff       	jmp    80106868 <alltraps>

801078ca <vector237>:
.globl vector237
vector237:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $237
801078cc:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078d1:	e9 92 ef ff ff       	jmp    80106868 <alltraps>

801078d6 <vector238>:
.globl vector238
vector238:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $238
801078d8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078dd:	e9 86 ef ff ff       	jmp    80106868 <alltraps>

801078e2 <vector239>:
.globl vector239
vector239:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $239
801078e4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801078e9:	e9 7a ef ff ff       	jmp    80106868 <alltraps>

801078ee <vector240>:
.globl vector240
vector240:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $240
801078f0:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801078f5:	e9 6e ef ff ff       	jmp    80106868 <alltraps>

801078fa <vector241>:
.globl vector241
vector241:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $241
801078fc:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107901:	e9 62 ef ff ff       	jmp    80106868 <alltraps>

80107906 <vector242>:
.globl vector242
vector242:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $242
80107908:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010790d:	e9 56 ef ff ff       	jmp    80106868 <alltraps>

80107912 <vector243>:
.globl vector243
vector243:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $243
80107914:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107919:	e9 4a ef ff ff       	jmp    80106868 <alltraps>

8010791e <vector244>:
.globl vector244
vector244:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $244
80107920:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107925:	e9 3e ef ff ff       	jmp    80106868 <alltraps>

8010792a <vector245>:
.globl vector245
vector245:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $245
8010792c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107931:	e9 32 ef ff ff       	jmp    80106868 <alltraps>

80107936 <vector246>:
.globl vector246
vector246:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $246
80107938:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010793d:	e9 26 ef ff ff       	jmp    80106868 <alltraps>

80107942 <vector247>:
.globl vector247
vector247:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $247
80107944:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107949:	e9 1a ef ff ff       	jmp    80106868 <alltraps>

8010794e <vector248>:
.globl vector248
vector248:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $248
80107950:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107955:	e9 0e ef ff ff       	jmp    80106868 <alltraps>

8010795a <vector249>:
.globl vector249
vector249:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $249
8010795c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107961:	e9 02 ef ff ff       	jmp    80106868 <alltraps>

80107966 <vector250>:
.globl vector250
vector250:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $250
80107968:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010796d:	e9 f6 ee ff ff       	jmp    80106868 <alltraps>

80107972 <vector251>:
.globl vector251
vector251:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $251
80107974:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107979:	e9 ea ee ff ff       	jmp    80106868 <alltraps>

8010797e <vector252>:
.globl vector252
vector252:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $252
80107980:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107985:	e9 de ee ff ff       	jmp    80106868 <alltraps>

8010798a <vector253>:
.globl vector253
vector253:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $253
8010798c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107991:	e9 d2 ee ff ff       	jmp    80106868 <alltraps>

80107996 <vector254>:
.globl vector254
vector254:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $254
80107998:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010799d:	e9 c6 ee ff ff       	jmp    80106868 <alltraps>

801079a2 <vector255>:
.globl vector255
vector255:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $255
801079a4:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079a9:	e9 ba ee ff ff       	jmp    80106868 <alltraps>
	...

801079b0 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079b0:	55                   	push   %ebp
801079b1:	89 e5                	mov    %esp,%ebp
801079b3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801079b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801079b9:	83 e8 01             	sub    $0x1,%eax
801079bc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079c0:	8b 45 08             	mov    0x8(%ebp),%eax
801079c3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079c7:	8b 45 08             	mov    0x8(%ebp),%eax
801079ca:	c1 e8 10             	shr    $0x10,%eax
801079cd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801079d1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079d4:	0f 01 10             	lgdtl  (%eax)
}
801079d7:	c9                   	leave  
801079d8:	c3                   	ret    

801079d9 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801079d9:	55                   	push   %ebp
801079da:	89 e5                	mov    %esp,%ebp
801079dc:	83 ec 04             	sub    $0x4,%esp
801079df:	8b 45 08             	mov    0x8(%ebp),%eax
801079e2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801079e6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801079ea:	0f 00 d8             	ltr    %ax
}
801079ed:	c9                   	leave  
801079ee:	c3                   	ret    

801079ef <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801079ef:	55                   	push   %ebp
801079f0:	89 e5                	mov    %esp,%ebp
801079f2:	83 ec 04             	sub    $0x4,%esp
801079f5:	8b 45 08             	mov    0x8(%ebp),%eax
801079f8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801079fc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a00:	8e e8                	mov    %eax,%gs
}
80107a02:	c9                   	leave  
80107a03:	c3                   	ret    

80107a04 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a04:	55                   	push   %ebp
80107a05:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a07:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0a:	0f 22 d8             	mov    %eax,%cr3
}
80107a0d:	5d                   	pop    %ebp
80107a0e:	c3                   	ret    

80107a0f <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a0f:	55                   	push   %ebp
80107a10:	89 e5                	mov    %esp,%ebp
80107a12:	8b 45 08             	mov    0x8(%ebp),%eax
80107a15:	05 00 00 00 80       	add    $0x80000000,%eax
80107a1a:	5d                   	pop    %ebp
80107a1b:	c3                   	ret    

80107a1c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a1c:	55                   	push   %ebp
80107a1d:	89 e5                	mov    %esp,%ebp
80107a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a22:	05 00 00 00 80       	add    $0x80000000,%eax
80107a27:	5d                   	pop    %ebp
80107a28:	c3                   	ret    

80107a29 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a29:	55                   	push   %ebp
80107a2a:	89 e5                	mov    %esp,%ebp
80107a2c:	53                   	push   %ebx
80107a2d:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a30:	e8 34 b7 ff ff       	call   80103169 <cpunum>
80107a35:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a3b:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a58:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a63:	83 e2 f0             	and    $0xfffffff0,%edx
80107a66:	83 ca 0a             	or     $0xa,%edx
80107a69:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a73:	83 ca 10             	or     $0x10,%edx
80107a76:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a80:	83 e2 9f             	and    $0xffffff9f,%edx
80107a83:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a89:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a8d:	83 ca 80             	or     $0xffffff80,%edx
80107a90:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a96:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a9a:	83 ca 0f             	or     $0xf,%edx
80107a9d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107aa7:	83 e2 ef             	and    $0xffffffef,%edx
80107aaa:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ab4:	83 e2 df             	and    $0xffffffdf,%edx
80107ab7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ac1:	83 ca 40             	or     $0x40,%edx
80107ac4:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aca:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ace:	83 ca 80             	or     $0xffffff80,%edx
80107ad1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ade:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107ae5:	ff ff 
80107ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aea:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107af1:	00 00 
80107af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b07:	83 e2 f0             	and    $0xfffffff0,%edx
80107b0a:	83 ca 02             	or     $0x2,%edx
80107b0d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b16:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b1d:	83 ca 10             	or     $0x10,%edx
80107b20:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b29:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b30:	83 e2 9f             	and    $0xffffff9f,%edx
80107b33:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b43:	83 ca 80             	or     $0xffffff80,%edx
80107b46:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b56:	83 ca 0f             	or     $0xf,%edx
80107b59:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b69:	83 e2 ef             	and    $0xffffffef,%edx
80107b6c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b7c:	83 e2 df             	and    $0xffffffdf,%edx
80107b7f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b88:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b8f:	83 ca 40             	or     $0x40,%edx
80107b92:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ba2:	83 ca 80             	or     $0xffffff80,%edx
80107ba5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bae:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107bbf:	ff ff 
80107bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc4:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bcb:	00 00 
80107bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107be1:	83 e2 f0             	and    $0xfffffff0,%edx
80107be4:	83 ca 0a             	or     $0xa,%edx
80107be7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bf7:	83 ca 10             	or     $0x10,%edx
80107bfa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c03:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c0a:	83 ca 60             	or     $0x60,%edx
80107c0d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c16:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c1d:	83 ca 80             	or     $0xffffff80,%edx
80107c20:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c29:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c30:	83 ca 0f             	or     $0xf,%edx
80107c33:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c43:	83 e2 ef             	and    $0xffffffef,%edx
80107c46:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c56:	83 e2 df             	and    $0xffffffdf,%edx
80107c59:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c69:	83 ca 40             	or     $0x40,%edx
80107c6c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c7c:	83 ca 80             	or     $0xffffff80,%edx
80107c7f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c88:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107c99:	ff ff 
80107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107ca5:	00 00 
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cbb:	83 e2 f0             	and    $0xfffffff0,%edx
80107cbe:	83 ca 02             	or     $0x2,%edx
80107cc1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cca:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cd1:	83 ca 10             	or     $0x10,%edx
80107cd4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ce4:	83 ca 60             	or     $0x60,%edx
80107ce7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cf7:	83 ca 80             	or     $0xffffff80,%edx
80107cfa:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d0a:	83 ca 0f             	or     $0xf,%edx
80107d0d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d1d:	83 e2 ef             	and    $0xffffffef,%edx
80107d20:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d30:	83 e2 df             	and    $0xffffffdf,%edx
80107d33:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d43:	83 ca 40             	or     $0x40,%edx
80107d46:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d56:	83 ca 80             	or     $0xffffff80,%edx
80107d59:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6c:	05 b4 00 00 00       	add    $0xb4,%eax
80107d71:	89 c3                	mov    %eax,%ebx
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	05 b4 00 00 00       	add    $0xb4,%eax
80107d7b:	c1 e8 10             	shr    $0x10,%eax
80107d7e:	89 c1                	mov    %eax,%ecx
80107d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d83:	05 b4 00 00 00       	add    $0xb4,%eax
80107d88:	c1 e8 18             	shr    $0x18,%eax
80107d8b:	89 c2                	mov    %eax,%edx
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107d97:	00 00 
80107d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daf:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107db6:	83 e1 f0             	and    $0xfffffff0,%ecx
80107db9:	83 c9 02             	or     $0x2,%ecx
80107dbc:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc5:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107dcc:	83 c9 10             	or     $0x10,%ecx
80107dcf:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd8:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ddf:	83 e1 9f             	and    $0xffffff9f,%ecx
80107de2:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107deb:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107df2:	83 c9 80             	or     $0xffffff80,%ecx
80107df5:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfe:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e05:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e08:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e11:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e18:	83 e1 ef             	and    $0xffffffef,%ecx
80107e1b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e24:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e2b:	83 e1 df             	and    $0xffffffdf,%ecx
80107e2e:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e37:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e3e:	83 c9 40             	or     $0x40,%ecx
80107e41:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e51:	83 c9 80             	or     $0xffffff80,%ecx
80107e54:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5d:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e66:	83 c0 70             	add    $0x70,%eax
80107e69:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107e70:	00 
80107e71:	89 04 24             	mov    %eax,(%esp)
80107e74:	e8 37 fb ff ff       	call   801079b0 <lgdt>
  loadgs(SEG_KCPU << 3);
80107e79:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107e80:	e8 6a fb ff ff       	call   801079ef <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e88:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107e8e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107e95:	00 00 00 00 
}
80107e99:	83 c4 24             	add    $0x24,%esp
80107e9c:	5b                   	pop    %ebx
80107e9d:	5d                   	pop    %ebp
80107e9e:	c3                   	ret    

80107e9f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107e9f:	55                   	push   %ebp
80107ea0:	89 e5                	mov    %esp,%ebp
80107ea2:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ea8:	c1 e8 16             	shr    $0x16,%eax
80107eab:	c1 e0 02             	shl    $0x2,%eax
80107eae:	03 45 08             	add    0x8(%ebp),%eax
80107eb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eb7:	8b 00                	mov    (%eax),%eax
80107eb9:	83 e0 01             	and    $0x1,%eax
80107ebc:	84 c0                	test   %al,%al
80107ebe:	74 17                	je     80107ed7 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ec3:	8b 00                	mov    (%eax),%eax
80107ec5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eca:	89 04 24             	mov    %eax,(%esp)
80107ecd:	e8 4a fb ff ff       	call   80107a1c <p2v>
80107ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ed5:	eb 4b                	jmp    80107f22 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ed7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107edb:	74 0e                	je     80107eeb <walkpgdir+0x4c>
80107edd:	e8 f9 ae ff ff       	call   80102ddb <kalloc>
80107ee2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ee5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ee9:	75 07                	jne    80107ef2 <walkpgdir+0x53>
      return 0;
80107eeb:	b8 00 00 00 00       	mov    $0x0,%eax
80107ef0:	eb 41                	jmp    80107f33 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ef2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ef9:	00 
80107efa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f01:	00 
80107f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f05:	89 04 24             	mov    %eax,(%esp)
80107f08:	e8 b5 d4 ff ff       	call   801053c2 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f10:	89 04 24             	mov    %eax,(%esp)
80107f13:	e8 f7 fa ff ff       	call   80107a0f <v2p>
80107f18:	89 c2                	mov    %eax,%edx
80107f1a:	83 ca 07             	or     $0x7,%edx
80107f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f20:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f22:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f25:	c1 e8 0c             	shr    $0xc,%eax
80107f28:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f2d:	c1 e0 02             	shl    $0x2,%eax
80107f30:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107f33:	c9                   	leave  
80107f34:	c3                   	ret    

80107f35 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f35:	55                   	push   %ebp
80107f36:	89 e5                	mov    %esp,%ebp
80107f38:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f49:	03 45 10             	add    0x10(%ebp),%eax
80107f4c:	83 e8 01             	sub    $0x1,%eax
80107f4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f57:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107f5e:	00 
80107f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f62:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f66:	8b 45 08             	mov    0x8(%ebp),%eax
80107f69:	89 04 24             	mov    %eax,(%esp)
80107f6c:	e8 2e ff ff ff       	call   80107e9f <walkpgdir>
80107f71:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f74:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f78:	75 07                	jne    80107f81 <mappages+0x4c>
      return -1;
80107f7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f7f:	eb 46                	jmp    80107fc7 <mappages+0x92>
    if(*pte & PTE_P)
80107f81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f84:	8b 00                	mov    (%eax),%eax
80107f86:	83 e0 01             	and    $0x1,%eax
80107f89:	84 c0                	test   %al,%al
80107f8b:	74 0c                	je     80107f99 <mappages+0x64>
      panic("remap");
80107f8d:	c7 04 24 ac 8d 10 80 	movl   $0x80108dac,(%esp)
80107f94:	e8 a4 85 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107f99:	8b 45 18             	mov    0x18(%ebp),%eax
80107f9c:	0b 45 14             	or     0x14(%ebp),%eax
80107f9f:	89 c2                	mov    %eax,%edx
80107fa1:	83 ca 01             	or     $0x1,%edx
80107fa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fa7:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fac:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107faf:	74 10                	je     80107fc1 <mappages+0x8c>
      break;
    a += PGSIZE;
80107fb1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107fb8:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107fbf:	eb 96                	jmp    80107f57 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107fc1:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107fc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fc7:	c9                   	leave  
80107fc8:	c3                   	ret    

80107fc9 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107fc9:	55                   	push   %ebp
80107fca:	89 e5                	mov    %esp,%ebp
80107fcc:	53                   	push   %ebx
80107fcd:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107fd0:	e8 06 ae ff ff       	call   80102ddb <kalloc>
80107fd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fd8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fdc:	75 0a                	jne    80107fe8 <setupkvm+0x1f>
    return 0;
80107fde:	b8 00 00 00 00       	mov    $0x0,%eax
80107fe3:	e9 98 00 00 00       	jmp    80108080 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107fe8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fef:	00 
80107ff0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ff7:	00 
80107ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ffb:	89 04 24             	mov    %eax,(%esp)
80107ffe:	e8 bf d3 ff ff       	call   801053c2 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108003:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
8010800a:	e8 0d fa ff ff       	call   80107a1c <p2v>
8010800f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108014:	76 0c                	jbe    80108022 <setupkvm+0x59>
    panic("PHYSTOP too high");
80108016:	c7 04 24 b2 8d 10 80 	movl   $0x80108db2,(%esp)
8010801d:	e8 1b 85 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108022:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80108029:	eb 49                	jmp    80108074 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
8010802b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010802e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108031:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108034:	8b 50 04             	mov    0x4(%eax),%edx
80108037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803a:	8b 58 08             	mov    0x8(%eax),%ebx
8010803d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108040:	8b 40 04             	mov    0x4(%eax),%eax
80108043:	29 c3                	sub    %eax,%ebx
80108045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108048:	8b 00                	mov    (%eax),%eax
8010804a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010804e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108052:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108056:	89 44 24 04          	mov    %eax,0x4(%esp)
8010805a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805d:	89 04 24             	mov    %eax,(%esp)
80108060:	e8 d0 fe ff ff       	call   80107f35 <mappages>
80108065:	85 c0                	test   %eax,%eax
80108067:	79 07                	jns    80108070 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108069:	b8 00 00 00 00       	mov    $0x0,%eax
8010806e:	eb 10                	jmp    80108080 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108070:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108074:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
8010807b:	72 ae                	jb     8010802b <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010807d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108080:	83 c4 34             	add    $0x34,%esp
80108083:	5b                   	pop    %ebx
80108084:	5d                   	pop    %ebp
80108085:	c3                   	ret    

80108086 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108086:	55                   	push   %ebp
80108087:	89 e5                	mov    %esp,%ebp
80108089:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010808c:	e8 38 ff ff ff       	call   80107fc9 <setupkvm>
80108091:	a3 18 2d 11 80       	mov    %eax,0x80112d18
  switchkvm();
80108096:	e8 02 00 00 00       	call   8010809d <switchkvm>
}
8010809b:	c9                   	leave  
8010809c:	c3                   	ret    

8010809d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010809d:	55                   	push   %ebp
8010809e:	89 e5                	mov    %esp,%ebp
801080a0:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801080a3:	a1 18 2d 11 80       	mov    0x80112d18,%eax
801080a8:	89 04 24             	mov    %eax,(%esp)
801080ab:	e8 5f f9 ff ff       	call   80107a0f <v2p>
801080b0:	89 04 24             	mov    %eax,(%esp)
801080b3:	e8 4c f9 ff ff       	call   80107a04 <lcr3>
}
801080b8:	c9                   	leave  
801080b9:	c3                   	ret    

801080ba <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080ba:	55                   	push   %ebp
801080bb:	89 e5                	mov    %esp,%ebp
801080bd:	53                   	push   %ebx
801080be:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801080c1:	e8 f5 d1 ff ff       	call   801052bb <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801080c6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080cc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080d3:	83 c2 08             	add    $0x8,%edx
801080d6:	89 d3                	mov    %edx,%ebx
801080d8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080df:	83 c2 08             	add    $0x8,%edx
801080e2:	c1 ea 10             	shr    $0x10,%edx
801080e5:	89 d1                	mov    %edx,%ecx
801080e7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080ee:	83 c2 08             	add    $0x8,%edx
801080f1:	c1 ea 18             	shr    $0x18,%edx
801080f4:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801080fb:	67 00 
801080fd:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108104:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
8010810a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108111:	83 e1 f0             	and    $0xfffffff0,%ecx
80108114:	83 c9 09             	or     $0x9,%ecx
80108117:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010811d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108124:	83 c9 10             	or     $0x10,%ecx
80108127:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010812d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108134:	83 e1 9f             	and    $0xffffff9f,%ecx
80108137:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010813d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108144:	83 c9 80             	or     $0xffffff80,%ecx
80108147:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010814d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108154:	83 e1 f0             	and    $0xfffffff0,%ecx
80108157:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010815d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108164:	83 e1 ef             	and    $0xffffffef,%ecx
80108167:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010816d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108174:	83 e1 df             	and    $0xffffffdf,%ecx
80108177:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010817d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108184:	83 c9 40             	or     $0x40,%ecx
80108187:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010818d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108194:	83 e1 7f             	and    $0x7f,%ecx
80108197:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010819d:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801081a3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081a9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801081b0:	83 e2 ef             	and    $0xffffffef,%edx
801081b3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801081b9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081bf:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801081c5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081cb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801081d2:	8b 52 08             	mov    0x8(%edx),%edx
801081d5:	81 c2 00 10 00 00    	add    $0x1000,%edx
801081db:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801081de:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801081e5:	e8 ef f7 ff ff       	call   801079d9 <ltr>
  if(p->pgdir == 0)
801081ea:	8b 45 08             	mov    0x8(%ebp),%eax
801081ed:	8b 40 04             	mov    0x4(%eax),%eax
801081f0:	85 c0                	test   %eax,%eax
801081f2:	75 0c                	jne    80108200 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801081f4:	c7 04 24 c3 8d 10 80 	movl   $0x80108dc3,(%esp)
801081fb:	e8 3d 83 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108200:	8b 45 08             	mov    0x8(%ebp),%eax
80108203:	8b 40 04             	mov    0x4(%eax),%eax
80108206:	89 04 24             	mov    %eax,(%esp)
80108209:	e8 01 f8 ff ff       	call   80107a0f <v2p>
8010820e:	89 04 24             	mov    %eax,(%esp)
80108211:	e8 ee f7 ff ff       	call   80107a04 <lcr3>
  popcli();
80108216:	e8 e8 d0 ff ff       	call   80105303 <popcli>
}
8010821b:	83 c4 14             	add    $0x14,%esp
8010821e:	5b                   	pop    %ebx
8010821f:	5d                   	pop    %ebp
80108220:	c3                   	ret    

80108221 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108221:	55                   	push   %ebp
80108222:	89 e5                	mov    %esp,%ebp
80108224:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108227:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010822e:	76 0c                	jbe    8010823c <inituvm+0x1b>
    panic("inituvm: more than a page");
80108230:	c7 04 24 d7 8d 10 80 	movl   $0x80108dd7,(%esp)
80108237:	e8 01 83 ff ff       	call   8010053d <panic>
  mem = kalloc();
8010823c:	e8 9a ab ff ff       	call   80102ddb <kalloc>
80108241:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108244:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010824b:	00 
8010824c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108253:	00 
80108254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108257:	89 04 24             	mov    %eax,(%esp)
8010825a:	e8 63 d1 ff ff       	call   801053c2 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010825f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108262:	89 04 24             	mov    %eax,(%esp)
80108265:	e8 a5 f7 ff ff       	call   80107a0f <v2p>
8010826a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108271:	00 
80108272:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108276:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010827d:	00 
8010827e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108285:	00 
80108286:	8b 45 08             	mov    0x8(%ebp),%eax
80108289:	89 04 24             	mov    %eax,(%esp)
8010828c:	e8 a4 fc ff ff       	call   80107f35 <mappages>
  memmove(mem, init, sz);
80108291:	8b 45 10             	mov    0x10(%ebp),%eax
80108294:	89 44 24 08          	mov    %eax,0x8(%esp)
80108298:	8b 45 0c             	mov    0xc(%ebp),%eax
8010829b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010829f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a2:	89 04 24             	mov    %eax,(%esp)
801082a5:	e8 eb d1 ff ff       	call   80105495 <memmove>
}
801082aa:	c9                   	leave  
801082ab:	c3                   	ret    

801082ac <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082ac:	55                   	push   %ebp
801082ad:	89 e5                	mov    %esp,%ebp
801082af:	53                   	push   %ebx
801082b0:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801082b6:	25 ff 0f 00 00       	and    $0xfff,%eax
801082bb:	85 c0                	test   %eax,%eax
801082bd:	74 0c                	je     801082cb <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801082bf:	c7 04 24 f4 8d 10 80 	movl   $0x80108df4,(%esp)
801082c6:	e8 72 82 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082d2:	e9 ad 00 00 00       	jmp    80108384 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801082d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082da:	8b 55 0c             	mov    0xc(%ebp),%edx
801082dd:	01 d0                	add    %edx,%eax
801082df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082e6:	00 
801082e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801082eb:	8b 45 08             	mov    0x8(%ebp),%eax
801082ee:	89 04 24             	mov    %eax,(%esp)
801082f1:	e8 a9 fb ff ff       	call   80107e9f <walkpgdir>
801082f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082fd:	75 0c                	jne    8010830b <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801082ff:	c7 04 24 17 8e 10 80 	movl   $0x80108e17,(%esp)
80108306:	e8 32 82 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010830b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010830e:	8b 00                	mov    (%eax),%eax
80108310:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108315:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831b:	8b 55 18             	mov    0x18(%ebp),%edx
8010831e:	89 d1                	mov    %edx,%ecx
80108320:	29 c1                	sub    %eax,%ecx
80108322:	89 c8                	mov    %ecx,%eax
80108324:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108329:	77 11                	ja     8010833c <loaduvm+0x90>
      n = sz - i;
8010832b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832e:	8b 55 18             	mov    0x18(%ebp),%edx
80108331:	89 d1                	mov    %edx,%ecx
80108333:	29 c1                	sub    %eax,%ecx
80108335:	89 c8                	mov    %ecx,%eax
80108337:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010833a:	eb 07                	jmp    80108343 <loaduvm+0x97>
    else
      n = PGSIZE;
8010833c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108346:	8b 55 14             	mov    0x14(%ebp),%edx
80108349:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010834c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010834f:	89 04 24             	mov    %eax,(%esp)
80108352:	e8 c5 f6 ff ff       	call   80107a1c <p2v>
80108357:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010835a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010835e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108362:	89 44 24 04          	mov    %eax,0x4(%esp)
80108366:	8b 45 10             	mov    0x10(%ebp),%eax
80108369:	89 04 24             	mov    %eax,(%esp)
8010836c:	e8 c9 9c ff ff       	call   8010203a <readi>
80108371:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108374:	74 07                	je     8010837d <loaduvm+0xd1>
      return -1;
80108376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010837b:	eb 18                	jmp    80108395 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010837d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108387:	3b 45 18             	cmp    0x18(%ebp),%eax
8010838a:	0f 82 47 ff ff ff    	jb     801082d7 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108390:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108395:	83 c4 24             	add    $0x24,%esp
80108398:	5b                   	pop    %ebx
80108399:	5d                   	pop    %ebp
8010839a:	c3                   	ret    

8010839b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010839b:	55                   	push   %ebp
8010839c:	89 e5                	mov    %esp,%ebp
8010839e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083a1:	8b 45 10             	mov    0x10(%ebp),%eax
801083a4:	85 c0                	test   %eax,%eax
801083a6:	79 0a                	jns    801083b2 <allocuvm+0x17>
    return 0;
801083a8:	b8 00 00 00 00       	mov    $0x0,%eax
801083ad:	e9 c1 00 00 00       	jmp    80108473 <allocuvm+0xd8>
  if(newsz < oldsz)
801083b2:	8b 45 10             	mov    0x10(%ebp),%eax
801083b5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083b8:	73 08                	jae    801083c2 <allocuvm+0x27>
    return oldsz;
801083ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801083bd:	e9 b1 00 00 00       	jmp    80108473 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801083c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c5:	05 ff 0f 00 00       	add    $0xfff,%eax
801083ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801083d2:	e9 8d 00 00 00       	jmp    80108464 <allocuvm+0xc9>
    mem = kalloc();
801083d7:	e8 ff a9 ff ff       	call   80102ddb <kalloc>
801083dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801083df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083e3:	75 2c                	jne    80108411 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801083e5:	c7 04 24 35 8e 10 80 	movl   $0x80108e35,(%esp)
801083ec:	e8 b0 7f ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801083f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f4:	89 44 24 08          	mov    %eax,0x8(%esp)
801083f8:	8b 45 10             	mov    0x10(%ebp),%eax
801083fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801083ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108402:	89 04 24             	mov    %eax,(%esp)
80108405:	e8 6b 00 00 00       	call   80108475 <deallocuvm>
      return 0;
8010840a:	b8 00 00 00 00       	mov    $0x0,%eax
8010840f:	eb 62                	jmp    80108473 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108411:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108418:	00 
80108419:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108420:	00 
80108421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108424:	89 04 24             	mov    %eax,(%esp)
80108427:	e8 96 cf ff ff       	call   801053c2 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010842c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842f:	89 04 24             	mov    %eax,(%esp)
80108432:	e8 d8 f5 ff ff       	call   80107a0f <v2p>
80108437:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010843a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108441:	00 
80108442:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108446:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010844d:	00 
8010844e:	89 54 24 04          	mov    %edx,0x4(%esp)
80108452:	8b 45 08             	mov    0x8(%ebp),%eax
80108455:	89 04 24             	mov    %eax,(%esp)
80108458:	e8 d8 fa ff ff       	call   80107f35 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010845d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108467:	3b 45 10             	cmp    0x10(%ebp),%eax
8010846a:	0f 82 67 ff ff ff    	jb     801083d7 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108470:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108473:	c9                   	leave  
80108474:	c3                   	ret    

80108475 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108475:	55                   	push   %ebp
80108476:	89 e5                	mov    %esp,%ebp
80108478:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010847b:	8b 45 10             	mov    0x10(%ebp),%eax
8010847e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108481:	72 08                	jb     8010848b <deallocuvm+0x16>
    return oldsz;
80108483:	8b 45 0c             	mov    0xc(%ebp),%eax
80108486:	e9 a4 00 00 00       	jmp    8010852f <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010848b:	8b 45 10             	mov    0x10(%ebp),%eax
8010848e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108493:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108498:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010849b:	e9 80 00 00 00       	jmp    80108520 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084aa:	00 
801084ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801084af:	8b 45 08             	mov    0x8(%ebp),%eax
801084b2:	89 04 24             	mov    %eax,(%esp)
801084b5:	e8 e5 f9 ff ff       	call   80107e9f <walkpgdir>
801084ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801084bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084c1:	75 09                	jne    801084cc <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801084c3:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801084ca:	eb 4d                	jmp    80108519 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801084cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084cf:	8b 00                	mov    (%eax),%eax
801084d1:	83 e0 01             	and    $0x1,%eax
801084d4:	84 c0                	test   %al,%al
801084d6:	74 41                	je     80108519 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801084d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084db:	8b 00                	mov    (%eax),%eax
801084dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801084e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084e9:	75 0c                	jne    801084f7 <deallocuvm+0x82>
        panic("kfree");
801084eb:	c7 04 24 4d 8e 10 80 	movl   $0x80108e4d,(%esp)
801084f2:	e8 46 80 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801084f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084fa:	89 04 24             	mov    %eax,(%esp)
801084fd:	e8 1a f5 ff ff       	call   80107a1c <p2v>
80108502:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108505:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108508:	89 04 24             	mov    %eax,(%esp)
8010850b:	e8 32 a8 ff ff       	call   80102d42 <kfree>
      *pte = 0;
80108510:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108513:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108519:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108523:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108526:	0f 82 74 ff ff ff    	jb     801084a0 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010852c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010852f:	c9                   	leave  
80108530:	c3                   	ret    

80108531 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108531:	55                   	push   %ebp
80108532:	89 e5                	mov    %esp,%ebp
80108534:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108537:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010853b:	75 0c                	jne    80108549 <freevm+0x18>
    panic("freevm: no pgdir");
8010853d:	c7 04 24 53 8e 10 80 	movl   $0x80108e53,(%esp)
80108544:	e8 f4 7f ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108549:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108550:	00 
80108551:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108558:	80 
80108559:	8b 45 08             	mov    0x8(%ebp),%eax
8010855c:	89 04 24             	mov    %eax,(%esp)
8010855f:	e8 11 ff ff ff       	call   80108475 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010856b:	eb 3c                	jmp    801085a9 <freevm+0x78>
    if(pgdir[i] & PTE_P){
8010856d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108570:	c1 e0 02             	shl    $0x2,%eax
80108573:	03 45 08             	add    0x8(%ebp),%eax
80108576:	8b 00                	mov    (%eax),%eax
80108578:	83 e0 01             	and    $0x1,%eax
8010857b:	84 c0                	test   %al,%al
8010857d:	74 26                	je     801085a5 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010857f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108582:	c1 e0 02             	shl    $0x2,%eax
80108585:	03 45 08             	add    0x8(%ebp),%eax
80108588:	8b 00                	mov    (%eax),%eax
8010858a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010858f:	89 04 24             	mov    %eax,(%esp)
80108592:	e8 85 f4 ff ff       	call   80107a1c <p2v>
80108597:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010859a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010859d:	89 04 24             	mov    %eax,(%esp)
801085a0:	e8 9d a7 ff ff       	call   80102d42 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801085a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085a9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085b0:	76 bb                	jbe    8010856d <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801085b2:	8b 45 08             	mov    0x8(%ebp),%eax
801085b5:	89 04 24             	mov    %eax,(%esp)
801085b8:	e8 85 a7 ff ff       	call   80102d42 <kfree>
}
801085bd:	c9                   	leave  
801085be:	c3                   	ret    

801085bf <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801085bf:	55                   	push   %ebp
801085c0:	89 e5                	mov    %esp,%ebp
801085c2:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085cc:	00 
801085cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801085d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801085d4:	8b 45 08             	mov    0x8(%ebp),%eax
801085d7:	89 04 24             	mov    %eax,(%esp)
801085da:	e8 c0 f8 ff ff       	call   80107e9f <walkpgdir>
801085df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801085e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801085e6:	75 0c                	jne    801085f4 <clearpteu+0x35>
    panic("clearpteu");
801085e8:	c7 04 24 64 8e 10 80 	movl   $0x80108e64,(%esp)
801085ef:	e8 49 7f ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801085f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f7:	8b 00                	mov    (%eax),%eax
801085f9:	89 c2                	mov    %eax,%edx
801085fb:	83 e2 fb             	and    $0xfffffffb,%edx
801085fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108601:	89 10                	mov    %edx,(%eax)
}
80108603:	c9                   	leave  
80108604:	c3                   	ret    

80108605 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108605:	55                   	push   %ebp
80108606:	89 e5                	mov    %esp,%ebp
80108608:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
8010860b:	e8 b9 f9 ff ff       	call   80107fc9 <setupkvm>
80108610:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108613:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108617:	75 0a                	jne    80108623 <copyuvm+0x1e>
    return 0;
80108619:	b8 00 00 00 00       	mov    $0x0,%eax
8010861e:	e9 f1 00 00 00       	jmp    80108714 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
80108623:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010862a:	e9 c0 00 00 00       	jmp    801086ef <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010862f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108632:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108639:	00 
8010863a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010863e:	8b 45 08             	mov    0x8(%ebp),%eax
80108641:	89 04 24             	mov    %eax,(%esp)
80108644:	e8 56 f8 ff ff       	call   80107e9f <walkpgdir>
80108649:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010864c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108650:	75 0c                	jne    8010865e <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108652:	c7 04 24 6e 8e 10 80 	movl   $0x80108e6e,(%esp)
80108659:	e8 df 7e ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
8010865e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108661:	8b 00                	mov    (%eax),%eax
80108663:	83 e0 01             	and    $0x1,%eax
80108666:	85 c0                	test   %eax,%eax
80108668:	75 0c                	jne    80108676 <copyuvm+0x71>
      panic("copyuvm: page not present");
8010866a:	c7 04 24 88 8e 10 80 	movl   $0x80108e88,(%esp)
80108671:	e8 c7 7e ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108676:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108679:	8b 00                	mov    (%eax),%eax
8010867b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108680:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
80108683:	e8 53 a7 ff ff       	call   80102ddb <kalloc>
80108688:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010868b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010868f:	74 6f                	je     80108700 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108691:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108694:	89 04 24             	mov    %eax,(%esp)
80108697:	e8 80 f3 ff ff       	call   80107a1c <p2v>
8010869c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086a3:	00 
801086a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801086a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086ab:	89 04 24             	mov    %eax,(%esp)
801086ae:	e8 e2 cd ff ff       	call   80105495 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801086b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086b6:	89 04 24             	mov    %eax,(%esp)
801086b9:	e8 51 f3 ff ff       	call   80107a0f <v2p>
801086be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086c1:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801086c8:	00 
801086c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
801086cd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086d4:	00 
801086d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801086d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086dc:	89 04 24             	mov    %eax,(%esp)
801086df:	e8 51 f8 ff ff       	call   80107f35 <mappages>
801086e4:	85 c0                	test   %eax,%eax
801086e6:	78 1b                	js     80108703 <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801086e8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086f5:	0f 82 34 ff ff ff    	jb     8010862f <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
801086fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086fe:	eb 14                	jmp    80108714 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108700:	90                   	nop
80108701:	eb 01                	jmp    80108704 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
80108703:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108704:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108707:	89 04 24             	mov    %eax,(%esp)
8010870a:	e8 22 fe ff ff       	call   80108531 <freevm>
  return 0;
8010870f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108714:	c9                   	leave  
80108715:	c3                   	ret    

80108716 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108716:	55                   	push   %ebp
80108717:	89 e5                	mov    %esp,%ebp
80108719:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010871c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108723:	00 
80108724:	8b 45 0c             	mov    0xc(%ebp),%eax
80108727:	89 44 24 04          	mov    %eax,0x4(%esp)
8010872b:	8b 45 08             	mov    0x8(%ebp),%eax
8010872e:	89 04 24             	mov    %eax,(%esp)
80108731:	e8 69 f7 ff ff       	call   80107e9f <walkpgdir>
80108736:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873c:	8b 00                	mov    (%eax),%eax
8010873e:	83 e0 01             	and    $0x1,%eax
80108741:	85 c0                	test   %eax,%eax
80108743:	75 07                	jne    8010874c <uva2ka+0x36>
    return 0;
80108745:	b8 00 00 00 00       	mov    $0x0,%eax
8010874a:	eb 25                	jmp    80108771 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
8010874c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874f:	8b 00                	mov    (%eax),%eax
80108751:	83 e0 04             	and    $0x4,%eax
80108754:	85 c0                	test   %eax,%eax
80108756:	75 07                	jne    8010875f <uva2ka+0x49>
    return 0;
80108758:	b8 00 00 00 00       	mov    $0x0,%eax
8010875d:	eb 12                	jmp    80108771 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
8010875f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108762:	8b 00                	mov    (%eax),%eax
80108764:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108769:	89 04 24             	mov    %eax,(%esp)
8010876c:	e8 ab f2 ff ff       	call   80107a1c <p2v>
}
80108771:	c9                   	leave  
80108772:	c3                   	ret    

80108773 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108773:	55                   	push   %ebp
80108774:	89 e5                	mov    %esp,%ebp
80108776:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108779:	8b 45 10             	mov    0x10(%ebp),%eax
8010877c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010877f:	e9 8b 00 00 00       	jmp    8010880f <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108784:	8b 45 0c             	mov    0xc(%ebp),%eax
80108787:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010878c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010878f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108792:	89 44 24 04          	mov    %eax,0x4(%esp)
80108796:	8b 45 08             	mov    0x8(%ebp),%eax
80108799:	89 04 24             	mov    %eax,(%esp)
8010879c:	e8 75 ff ff ff       	call   80108716 <uva2ka>
801087a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801087a4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087a8:	75 07                	jne    801087b1 <copyout+0x3e>
      return -1;
801087aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087af:	eb 6d                	jmp    8010881e <copyout+0xab>
    n = PGSIZE - (va - va0);
801087b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801087b4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801087b7:	89 d1                	mov    %edx,%ecx
801087b9:	29 c1                	sub    %eax,%ecx
801087bb:	89 c8                	mov    %ecx,%eax
801087bd:	05 00 10 00 00       	add    $0x1000,%eax
801087c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801087c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087c8:	3b 45 14             	cmp    0x14(%ebp),%eax
801087cb:	76 06                	jbe    801087d3 <copyout+0x60>
      n = len;
801087cd:	8b 45 14             	mov    0x14(%ebp),%eax
801087d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801087d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087d6:	8b 55 0c             	mov    0xc(%ebp),%edx
801087d9:	89 d1                	mov    %edx,%ecx
801087db:	29 c1                	sub    %eax,%ecx
801087dd:	89 c8                	mov    %ecx,%eax
801087df:	03 45 e8             	add    -0x18(%ebp),%eax
801087e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087e5:	89 54 24 08          	mov    %edx,0x8(%esp)
801087e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087ec:	89 54 24 04          	mov    %edx,0x4(%esp)
801087f0:	89 04 24             	mov    %eax,(%esp)
801087f3:	e8 9d cc ff ff       	call   80105495 <memmove>
    len -= n;
801087f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087fb:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801087fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108801:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108804:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108807:	05 00 10 00 00       	add    $0x1000,%eax
8010880c:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010880f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108813:	0f 85 6b ff ff ff    	jne    80108784 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108819:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010881e:	c9                   	leave  
8010881f:	c3                   	ret    
