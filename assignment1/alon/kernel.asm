
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
8010002d:	b8 3b 37 10 80       	mov    $0x8010373b,%eax
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
8010003a:	c7 44 24 04 b0 88 10 	movl   $0x801088b0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 74 51 00 00       	call   801051c2 <initlock>

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
801000bd:	e8 21 51 00 00       	call   801051e3 <acquire>

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
80100104:	e8 3c 51 00 00       	call   80105245 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 4a 4d 00 00       	call   80104e6e <sleep>
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
8010017c:	e8 c4 50 00 00       	call   80105245 <release>
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
80100198:	c7 04 24 b7 88 10 80 	movl   $0x801088b7,(%esp)
8010019f:	e8 a2 03 00 00       	call   80100546 <panic>
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
801001d3:	e8 04 29 00 00       	call   80102adc <iderw>
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
801001ef:	c7 04 24 c8 88 10 80 	movl   $0x801088c8,(%esp)
801001f6:	e8 4b 03 00 00       	call   80100546 <panic>
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
80100210:	e8 c7 28 00 00       	call   80102adc <iderw>
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
80100229:	c7 04 24 cf 88 10 80 	movl   $0x801088cf,(%esp)
80100230:	e8 11 03 00 00       	call   80100546 <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 a2 4f 00 00       	call   801051e3 <acquire>

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
8010029d:	e8 a8 4c 00 00       	call   80104f4a <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 97 4f 00 00       	call   80105245 <release>
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
80100308:	74 1c                	je     80100326 <printint+0x28>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	0f b6 c0             	movzbl %al,%eax
80100313:	89 45 10             	mov    %eax,0x10(%ebp)
80100316:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010031a:	74 0a                	je     80100326 <printint+0x28>
    x = -xx;
8010031c:	8b 45 08             	mov    0x8(%ebp),%eax
8010031f:	f7 d8                	neg    %eax
80100321:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100324:	eb 06                	jmp    8010032c <printint+0x2e>
  else
    x = xx;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010032c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100336:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100339:	ba 00 00 00 00       	mov    $0x0,%edx
8010033e:	f7 f1                	div    %ecx
80100340:	89 d0                	mov    %edx,%eax
80100342:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100349:	8d 4d e0             	lea    -0x20(%ebp),%ecx
8010034c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010034f:	01 ca                	add    %ecx,%edx
80100351:	88 02                	mov    %al,(%edx)
80100353:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100357:	8b 55 0c             	mov    0xc(%ebp),%edx
8010035a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010035d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100360:	ba 00 00 00 00       	mov    $0x0,%edx
80100365:	f7 75 d4             	divl   -0x2c(%ebp)
80100368:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036f:	75 c2                	jne    80100333 <printint+0x35>

  if(sign)
80100371:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100375:	74 27                	je     8010039e <printint+0xa0>
    buf[i++] = '-';
80100377:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037d:	01 d0                	add    %edx,%eax
8010037f:	c6 00 2d             	movb   $0x2d,(%eax)
80100382:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
80100386:	eb 16                	jmp    8010039e <printint+0xa0>
    consputc(buf[i]);
80100388:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010038b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038e:	01 d0                	add    %edx,%eax
80100390:	0f b6 00             	movzbl (%eax),%eax
80100393:	0f be c0             	movsbl %al,%eax
80100396:	89 04 24             	mov    %eax,(%esp)
80100399:	e8 f1 03 00 00       	call   8010078f <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010039e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003a6:	79 e0                	jns    80100388 <printint+0x8a>
    consputc(buf[i]);
}
801003a8:	c9                   	leave  
801003a9:	c3                   	ret    

801003aa <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003aa:	55                   	push   %ebp
801003ab:	89 e5                	mov    %esp,%ebp
801003ad:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003b0:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003bc:	74 0c                	je     801003ca <cprintf+0x20>
    acquire(&cons.lock);
801003be:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003c5:	e8 19 4e 00 00       	call   801051e3 <acquire>

  if (fmt == 0)
801003ca:	8b 45 08             	mov    0x8(%ebp),%eax
801003cd:	85 c0                	test   %eax,%eax
801003cf:	75 0c                	jne    801003dd <cprintf+0x33>
    panic("null fmt");
801003d1:	c7 04 24 d6 88 10 80 	movl   $0x801088d6,(%esp)
801003d8:	e8 69 01 00 00       	call   80100546 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003dd:	8d 45 0c             	lea    0xc(%ebp),%eax
801003e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003ea:	e9 20 01 00 00       	jmp    8010050f <cprintf+0x165>
    if(c != '%'){
801003ef:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003f3:	74 10                	je     80100405 <cprintf+0x5b>
      consputc(c);
801003f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003f8:	89 04 24             	mov    %eax,(%esp)
801003fb:	e8 8f 03 00 00       	call   8010078f <consputc>
      continue;
80100400:	e9 06 01 00 00       	jmp    8010050b <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
80100405:	8b 55 08             	mov    0x8(%ebp),%edx
80100408:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010040c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010040f:	01 d0                	add    %edx,%eax
80100411:	0f b6 00             	movzbl (%eax),%eax
80100414:	0f be c0             	movsbl %al,%eax
80100417:	25 ff 00 00 00       	and    $0xff,%eax
8010041c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010041f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100423:	0f 84 08 01 00 00    	je     80100531 <cprintf+0x187>
      break;
    switch(c){
80100429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010042c:	83 f8 70             	cmp    $0x70,%eax
8010042f:	74 4d                	je     8010047e <cprintf+0xd4>
80100431:	83 f8 70             	cmp    $0x70,%eax
80100434:	7f 13                	jg     80100449 <cprintf+0x9f>
80100436:	83 f8 25             	cmp    $0x25,%eax
80100439:	0f 84 a6 00 00 00    	je     801004e5 <cprintf+0x13b>
8010043f:	83 f8 64             	cmp    $0x64,%eax
80100442:	74 14                	je     80100458 <cprintf+0xae>
80100444:	e9 aa 00 00 00       	jmp    801004f3 <cprintf+0x149>
80100449:	83 f8 73             	cmp    $0x73,%eax
8010044c:	74 53                	je     801004a1 <cprintf+0xf7>
8010044e:	83 f8 78             	cmp    $0x78,%eax
80100451:	74 2b                	je     8010047e <cprintf+0xd4>
80100453:	e9 9b 00 00 00       	jmp    801004f3 <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
80100458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010045b:	8b 00                	mov    (%eax),%eax
8010045d:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100461:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100468:	00 
80100469:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100470:	00 
80100471:	89 04 24             	mov    %eax,(%esp)
80100474:	e8 85 fe ff ff       	call   801002fe <printint>
      break;
80100479:	e9 8d 00 00 00       	jmp    8010050b <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010047e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100481:	8b 00                	mov    (%eax),%eax
80100483:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100487:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010048e:	00 
8010048f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100496:	00 
80100497:	89 04 24             	mov    %eax,(%esp)
8010049a:	e8 5f fe ff ff       	call   801002fe <printint>
      break;
8010049f:	eb 6a                	jmp    8010050b <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
801004a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004a4:	8b 00                	mov    (%eax),%eax
801004a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ad:	0f 94 c0             	sete   %al
801004b0:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004b4:	84 c0                	test   %al,%al
801004b6:	74 20                	je     801004d8 <cprintf+0x12e>
        s = "(null)";
801004b8:	c7 45 ec df 88 10 80 	movl   $0x801088df,-0x14(%ebp)
      for(; *s; s++)
801004bf:	eb 17                	jmp    801004d8 <cprintf+0x12e>
        consputc(*s);
801004c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004c4:	0f b6 00             	movzbl (%eax),%eax
801004c7:	0f be c0             	movsbl %al,%eax
801004ca:	89 04 24             	mov    %eax,(%esp)
801004cd:	e8 bd 02 00 00       	call   8010078f <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004d2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d6:	eb 01                	jmp    801004d9 <cprintf+0x12f>
801004d8:	90                   	nop
801004d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dc:	0f b6 00             	movzbl (%eax),%eax
801004df:	84 c0                	test   %al,%al
801004e1:	75 de                	jne    801004c1 <cprintf+0x117>
        consputc(*s);
      break;
801004e3:	eb 26                	jmp    8010050b <cprintf+0x161>
    case '%':
      consputc('%');
801004e5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ec:	e8 9e 02 00 00       	call   8010078f <consputc>
      break;
801004f1:	eb 18                	jmp    8010050b <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004f3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004fa:	e8 90 02 00 00       	call   8010078f <consputc>
      consputc(c);
801004ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100502:	89 04 24             	mov    %eax,(%esp)
80100505:	e8 85 02 00 00       	call   8010078f <consputc>
      break;
8010050a:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010050b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010050f:	8b 55 08             	mov    0x8(%ebp),%edx
80100512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100515:	01 d0                	add    %edx,%eax
80100517:	0f b6 00             	movzbl (%eax),%eax
8010051a:	0f be c0             	movsbl %al,%eax
8010051d:	25 ff 00 00 00       	and    $0xff,%eax
80100522:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100525:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100529:	0f 85 c0 fe ff ff    	jne    801003ef <cprintf+0x45>
8010052f:	eb 01                	jmp    80100532 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100531:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100532:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100536:	74 0c                	je     80100544 <cprintf+0x19a>
    release(&cons.lock);
80100538:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010053f:	e8 01 4d 00 00       	call   80105245 <release>
}
80100544:	c9                   	leave  
80100545:	c3                   	ret    

80100546 <panic>:

void
panic(char *s)
{
80100546:	55                   	push   %ebp
80100547:	89 e5                	mov    %esp,%ebp
80100549:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
8010054c:	e8 a7 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100551:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100558:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010055b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100561:	0f b6 00             	movzbl (%eax),%eax
80100564:	0f b6 c0             	movzbl %al,%eax
80100567:	89 44 24 04          	mov    %eax,0x4(%esp)
8010056b:	c7 04 24 e6 88 10 80 	movl   $0x801088e6,(%esp)
80100572:	e8 33 fe ff ff       	call   801003aa <cprintf>
  cprintf(s);
80100577:	8b 45 08             	mov    0x8(%ebp),%eax
8010057a:	89 04 24             	mov    %eax,(%esp)
8010057d:	e8 28 fe ff ff       	call   801003aa <cprintf>
  cprintf("\n");
80100582:	c7 04 24 f5 88 10 80 	movl   $0x801088f5,(%esp)
80100589:	e8 1c fe ff ff       	call   801003aa <cprintf>
  getcallerpcs(&s, pcs);
8010058e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100591:	89 44 24 04          	mov    %eax,0x4(%esp)
80100595:	8d 45 08             	lea    0x8(%ebp),%eax
80100598:	89 04 24             	mov    %eax,(%esp)
8010059b:	e8 f4 4c 00 00       	call   80105294 <getcallerpcs>
  for(i=0; i<10; i++)
801005a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005a7:	eb 1b                	jmp    801005c4 <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005ac:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801005b4:	c7 04 24 f7 88 10 80 	movl   $0x801088f7,(%esp)
801005bb:	e8 ea fd ff ff       	call   801003aa <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005c4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005c8:	7e df                	jle    801005a9 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005ca:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005d1:	00 00 00 
  for(;;)
    ;
801005d4:	eb fe                	jmp    801005d4 <panic+0x8e>

801005d6 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005d6:	55                   	push   %ebp
801005d7:	89 e5                	mov    %esp,%ebp
801005d9:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005dc:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e3:	00 
801005e4:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005eb:	e8 ea fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005f0:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005f7:	e8 b4 fc ff ff       	call   801002b0 <inb>
801005fc:	0f b6 c0             	movzbl %al,%eax
801005ff:	c1 e0 08             	shl    $0x8,%eax
80100602:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100605:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010060c:	00 
8010060d:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100614:	e8 c1 fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100619:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100620:	e8 8b fc ff ff       	call   801002b0 <inb>
80100625:	0f b6 c0             	movzbl %al,%eax
80100628:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010062b:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010062f:	75 30                	jne    80100661 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100631:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100634:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100639:	89 c8                	mov    %ecx,%eax
8010063b:	f7 ea                	imul   %edx
8010063d:	c1 fa 05             	sar    $0x5,%edx
80100640:	89 c8                	mov    %ecx,%eax
80100642:	c1 f8 1f             	sar    $0x1f,%eax
80100645:	29 c2                	sub    %eax,%edx
80100647:	89 d0                	mov    %edx,%eax
80100649:	c1 e0 02             	shl    $0x2,%eax
8010064c:	01 d0                	add    %edx,%eax
8010064e:	c1 e0 04             	shl    $0x4,%eax
80100651:	89 ca                	mov    %ecx,%edx
80100653:	29 c2                	sub    %eax,%edx
80100655:	b8 50 00 00 00       	mov    $0x50,%eax
8010065a:	29 d0                	sub    %edx,%eax
8010065c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010065f:	eb 56                	jmp    801006b7 <cgaputc+0xe1>
  else if(c == BACKSPACE){
80100661:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100668:	75 0c                	jne    80100676 <cgaputc+0xa0>
    if(pos > 0) --pos;
8010066a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010066e:	7e 47                	jle    801006b7 <cgaputc+0xe1>
80100670:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100674:	eb 41                	jmp    801006b7 <cgaputc+0xe1>
  }
  else if(c == KEY_LF){		// decreasing pos in a left key is pressed
80100676:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
8010067d:	75 0c                	jne    8010068b <cgaputc+0xb5>
    if(pos > 0)
8010067f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100683:	7e 32                	jle    801006b7 <cgaputc+0xe1>
      --pos;
80100685:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100689:	eb 2c                	jmp    801006b7 <cgaputc+0xe1>
  }
  else if(c == KEY_RT){		// decreasing pos in a right key is pressed
8010068b:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
80100692:	75 06                	jne    8010069a <cgaputc+0xc4>
    ++pos;
80100694:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100698:	eb 1d                	jmp    801006b7 <cgaputc+0xe1>
  }
  else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010069a:	a1 00 90 10 80       	mov    0x80109000,%eax
8010069f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006a2:	01 d2                	add    %edx,%edx
801006a4:	01 c2                	add    %eax,%edx
801006a6:	8b 45 08             	mov    0x8(%ebp),%eax
801006a9:	66 25 ff 00          	and    $0xff,%ax
801006ad:	80 cc 07             	or     $0x7,%ah
801006b0:	66 89 02             	mov    %ax,(%edx)
801006b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
801006b7:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006be:	7e 53                	jle    80100713 <cgaputc+0x13d>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c0:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cb:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d0:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006d7:	00 
801006d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801006dc:	89 04 24             	mov    %eax,(%esp)
801006df:	e8 2d 4e 00 00       	call   80105511 <memmove>
    pos -= 80;
801006e4:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e8:	b8 80 07 00 00       	mov    $0x780,%eax
801006ed:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006f0:	01 c0                	add    %eax,%eax
801006f2:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fb:	01 c9                	add    %ecx,%ecx
801006fd:	01 ca                	add    %ecx,%edx
801006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80100703:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010070a:	00 
8010070b:	89 14 24             	mov    %edx,(%esp)
8010070e:	e8 2b 4d 00 00       	call   8010543e <memset>
  }
  
  outb(CRTPORT, 14);
80100713:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 b3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	c1 f8 08             	sar    $0x8,%eax
8010072d:	0f b6 c0             	movzbl %al,%eax
80100730:	89 44 24 04          	mov    %eax,0x4(%esp)
80100734:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010073b:	e8 9a fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100740:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100747:	00 
80100748:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010074f:	e8 86 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100757:	0f b6 c0             	movzbl %al,%eax
8010075a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010075e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100765:	e8 70 fb ff ff       	call   801002da <outb>
  if(c != KEY_LF && c != KEY_RT)
8010076a:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
80100771:	74 1a                	je     8010078d <cgaputc+0x1b7>
80100773:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
8010077a:	74 11                	je     8010078d <cgaputc+0x1b7>
    crt[pos] = ' ' | 0x0700;
8010077c:	a1 00 90 10 80       	mov    0x80109000,%eax
80100781:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100784:	01 d2                	add    %edx,%edx
80100786:	01 d0                	add    %edx,%eax
80100788:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078d:	c9                   	leave  
8010078e:	c3                   	ret    

8010078f <consputc>:

void
consputc(int c)
{
8010078f:	55                   	push   %ebp
80100790:	89 e5                	mov    %esp,%ebp
80100792:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100795:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010079a:	85 c0                	test   %eax,%eax
8010079c:	74 07                	je     801007a5 <consputc+0x16>
    cli();
8010079e:	e8 55 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
801007a3:	eb fe                	jmp    801007a3 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a5:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007ac:	75 26                	jne    801007d4 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007ae:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007b5:	e8 43 67 00 00       	call   80106efd <uartputc>
801007ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007c1:	e8 37 67 00 00       	call   80106efd <uartputc>
801007c6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007cd:	e8 2b 67 00 00       	call   80106efd <uartputc>
801007d2:	eb 0b                	jmp    801007df <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
801007d4:	8b 45 08             	mov    0x8(%ebp),%eax
801007d7:	89 04 24             	mov    %eax,(%esp)
801007da:	e8 1e 67 00 00       	call   80106efd <uartputc>
  cgaputc(c);
801007df:	8b 45 08             	mov    0x8(%ebp),%eax
801007e2:	89 04 24             	mov    %eax,(%esp)
801007e5:	e8 ec fd ff ff       	call   801005d6 <cgaputc>
}
801007ea:	c9                   	leave  
801007eb:	c3                   	ret    

801007ec <shiftRightBuf>:

#define C(x)  ((x)-'@')  // Control-x

void
shiftRightBuf(uint e, uint k)			// a function for shifting our buffer one step to the right from the place we're not inserting
{						// k is our left we are in our line and e hold the end of line
801007ec:	55                   	push   %ebp
801007ed:	89 e5                	mov    %esp,%ebp
801007ef:	83 ec 10             	sub    $0x10,%esp
  uint j=0;
801007f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(;j < k;e--,j++){
801007f9:	eb 21                	jmp    8010081c <shiftRightBuf+0x30>
    input.buf[e] = input.buf[e-1];
801007fb:	8b 45 08             	mov    0x8(%ebp),%eax
801007fe:	83 e8 01             	sub    $0x1,%eax
80100801:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100808:	8b 55 08             	mov    0x8(%ebp),%edx
8010080b:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100811:	88 42 04             	mov    %al,0x4(%edx)

void
shiftRightBuf(uint e, uint k)			// a function for shifting our buffer one step to the right from the place we're not inserting
{						// k is our left we are in our line and e hold the end of line
  uint j=0;
  for(;j < k;e--,j++){
80100814:	83 6d 08 01          	subl   $0x1,0x8(%ebp)
80100818:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010081c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010081f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100822:	72 d7                	jb     801007fb <shiftRightBuf+0xf>
    input.buf[e] = input.buf[e-1];
  }
}
80100824:	c9                   	leave  
80100825:	c3                   	ret    

80100826 <shiftLeftBuf>:

void
shiftLeftBuf(uint e, uint k)			// a function for shifting our buffer one step to the left from the place we're not backspacing
{						// k is our left we are in our line and e hold the end of line
80100826:	55                   	push   %ebp
80100827:	89 e5                	mov    %esp,%ebp
80100829:	83 ec 10             	sub    $0x10,%esp
  uint i = e-k;
8010082c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010082f:	8b 55 08             	mov    0x8(%ebp),%edx
80100832:	89 d1                	mov    %edx,%ecx
80100834:	29 c1                	sub    %eax,%ecx
80100836:	89 c8                	mov    %ecx,%eax
80100838:	89 45 fc             	mov    %eax,-0x4(%ebp)
  uint j=0;
8010083b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < k ;i++,j++){
80100842:	eb 21                	jmp    80100865 <shiftLeftBuf+0x3f>
    input.buf[i] = input.buf[i+1];
80100844:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100847:	83 c0 01             	add    $0x1,%eax
8010084a:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100851:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100854:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
8010085a:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(uint e, uint k)			// a function for shifting our buffer one step to the left from the place we're not backspacing
{						// k is our left we are in our line and e hold the end of line
  uint i = e-k;
  uint j=0;
  for(;j < k ;i++,j++){
8010085d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80100861:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80100865:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100868:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010086b:	72 d7                	jb     80100844 <shiftLeftBuf+0x1e>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
8010086d:	8b 45 08             	mov    0x8(%ebp),%eax
80100870:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
80100875:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
80100879:	c9                   	leave  
8010087a:	c3                   	ret    

8010087b <consoleintr>:

void
consoleintr(int (*getc)(void))
{
8010087b:	55                   	push   %ebp
8010087c:	89 e5                	mov    %esp,%ebp
8010087e:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
80100881:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100888:	e8 56 49 00 00       	call   801051e3 <acquire>
  while((c = getc()) >= 0){
8010088d:	e9 57 03 00 00       	jmp    80100be9 <consoleintr+0x36e>
    switch(c){
80100892:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100895:	83 f8 15             	cmp    $0x15,%eax
80100898:	74 59                	je     801008f3 <consoleintr+0x78>
8010089a:	83 f8 15             	cmp    $0x15,%eax
8010089d:	7f 0f                	jg     801008ae <consoleintr+0x33>
8010089f:	83 f8 08             	cmp    $0x8,%eax
801008a2:	74 7e                	je     80100922 <consoleintr+0xa7>
801008a4:	83 f8 10             	cmp    $0x10,%eax
801008a7:	74 25                	je     801008ce <consoleintr+0x53>
801008a9:	e9 d7 01 00 00       	jmp    80100a85 <consoleintr+0x20a>
801008ae:	3d e4 00 00 00       	cmp    $0xe4,%eax
801008b3:	0f 84 44 01 00 00    	je     801009fd <consoleintr+0x182>
801008b9:	3d e5 00 00 00       	cmp    $0xe5,%eax
801008be:	0f 84 7b 01 00 00    	je     80100a3f <consoleintr+0x1c4>
801008c4:	83 f8 7f             	cmp    $0x7f,%eax
801008c7:	74 59                	je     80100922 <consoleintr+0xa7>
801008c9:	e9 b7 01 00 00       	jmp    80100a85 <consoleintr+0x20a>
    case C('P'):  // Process listing.
      procdump();
801008ce:	e8 1d 47 00 00       	call   80104ff0 <procdump>
      break;
801008d3:	e9 11 03 00 00       	jmp    80100be9 <consoleintr+0x36e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008d8:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008dd:	83 e8 01             	sub    $0x1,%eax
801008e0:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
801008e5:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008ec:	e8 9e fe ff ff       	call   8010078f <consputc>
801008f1:	eb 01                	jmp    801008f4 <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008f3:	90                   	nop
801008f4:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801008fa:	a1 58 de 10 80       	mov    0x8010de58,%eax
801008ff:	39 c2                	cmp    %eax,%edx
80100901:	0f 84 d5 02 00 00    	je     80100bdc <consoleintr+0x361>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100907:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010090c:	83 e8 01             	sub    $0x1,%eax
8010090f:	83 e0 7f             	and    $0x7f,%eax
80100912:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100919:	3c 0a                	cmp    $0xa,%al
8010091b:	75 bb                	jne    801008d8 <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010091d:	e9 ba 02 00 00       	jmp    80100bdc <consoleintr+0x361>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100922:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100928:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	0f 84 aa 02 00 00    	je     80100bdf <consoleintr+0x364>
	if(input.a > 0)			// Checking if backspace was pressed not at the end marker
80100935:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010093a:	85 c0                	test   %eax,%eax
8010093c:	0f 84 9d 00 00 00    	je     801009df <consoleintr+0x164>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);	// shift our buffer one step to the left and print backspace
80100942:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100947:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010094d:	83 ea 01             	sub    $0x1,%edx
80100950:	83 e2 7f             	and    $0x7f,%edx
80100953:	89 44 24 04          	mov    %eax,0x4(%esp)
80100957:	89 14 24             	mov    %edx,(%esp)
8010095a:	e8 c7 fe ff ff       	call   80100826 <shiftLeftBuf>
	    uint i = input.e-input.a-1;
8010095f:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100965:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010096a:	89 d1                	mov    %edx,%ecx
8010096c:	29 c1                	sub    %eax,%ecx
8010096e:	89 c8                	mov    %ecx,%eax
80100970:	83 e8 01             	sub    $0x1,%eax
80100973:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);					// move the screen marker one step to the left
80100976:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
8010097d:	e8 0d fe ff ff       	call   8010078f <consputc>
	    for(;i<input.e;i++){ 
80100982:	eb 1c                	jmp    801009a0 <consoleintr+0x125>
	      consputc(input.buf[i%INPUT_BUF]);		// print to the screen all the characters that were on the right hand side of where we
80100984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100987:	83 e0 7f             	and    $0x7f,%eax
8010098a:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100991:	0f be c0             	movsbl %al,%eax
80100994:	89 04 24             	mov    %eax,(%esp)
80100997:	e8 f3 fd ff ff       	call   8010078f <consputc>
	if(input.a > 0)			// Checking if backspace was pressed not at the end marker
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);	// shift our buffer one step to the left and print backspace
	    uint i = input.e-input.a-1;
	    consputc(KEY_LF);					// move the screen marker one step to the left
	    for(;i<input.e;i++){ 
8010099c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009a0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009a5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009a8:	77 da                	ja     80100984 <consoleintr+0x109>
	      consputc(input.buf[i%INPUT_BUF]);		// print to the screen all the characters that were on the right hand side of where we
	    }							// we entred backspace
	    i = input.e-input.a;
801009aa:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009b0:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009b5:	89 d1                	mov    %edx,%ecx
801009b7:	29 c1                	sub    %eax,%ecx
801009b9:	89 c8                	mov    %ecx,%eax
801009bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){				// move the line marker back to were it was before pressing backspace
801009be:	eb 10                	jmp    801009d0 <consoleintr+0x155>
	      consputc(KEY_LF);
801009c0:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009c7:	e8 c3 fd ff ff       	call   8010078f <consputc>
	    consputc(KEY_LF);					// move the screen marker one step to the left
	    for(;i<input.e;i++){ 
	      consputc(input.buf[i%INPUT_BUF]);		// print to the screen all the characters that were on the right hand side of where we
	    }							// we entred backspace
	    i = input.e-input.a;
	    for(;i<input.e+1;i++){				// move the line marker back to were it was before pressing backspace
801009cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009d0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009d5:	83 c0 01             	add    $0x1,%eax
801009d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009db:	77 e3                	ja     801009c0 <consoleintr+0x145>
801009dd:	eb 0c                	jmp    801009eb <consoleintr+0x170>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);		// if not, we'll pring backspace to the screen
801009df:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801009e6:	e8 a4 fd ff ff       	call   8010078f <consputc>
	}
	input.e--;
801009eb:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009f0:	83 e8 01             	sub    $0x1,%eax
801009f3:	a3 5c de 10 80       	mov    %eax,0x8010de5c
      }
      break;
801009f8:	e9 e2 01 00 00       	jmp    80100bdf <consoleintr+0x364>
    case KEY_LF: //LEFT KEY
     if(c != 0 && input.e - input.a > input.w)		// if there is still room to move left
801009fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a01:	0f 84 db 01 00 00    	je     80100be2 <consoleintr+0x367>
80100a07:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a0d:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a12:	29 c2                	sub    %eax,%edx
80100a14:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100a19:	39 c2                	cmp    %eax,%edx
80100a1b:	0f 86 c1 01 00 00    	jbe    80100be2 <consoleintr+0x367>
      {
        consputc(KEY_LF);				// move our marker one step to the left
80100a21:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a28:	e8 62 fd ff ff       	call   8010078f <consputc>
	input.a++;					// increament our left steps counter
80100a2d:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a32:	83 c0 01             	add    $0x1,%eax
80100a35:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      break;
80100a3a:	e9 a3 01 00 00       	jmp    80100be2 <consoleintr+0x367>
    case KEY_RT: //RIGHT KEY
      if(c != 0 && input.a > 0 && input.e % INPUT_BUF < INPUT_BUF-1) // if we're not at the end of the line and we've moved to the left before
80100a3f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a43:	0f 84 9c 01 00 00    	je     80100be5 <consoleintr+0x36a>
80100a49:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a4e:	85 c0                	test   %eax,%eax
80100a50:	0f 84 8f 01 00 00    	je     80100be5 <consoleintr+0x36a>
80100a56:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a5b:	83 e0 7f             	and    $0x7f,%eax
80100a5e:	83 f8 7e             	cmp    $0x7e,%eax
80100a61:	0f 87 7e 01 00 00    	ja     80100be5 <consoleintr+0x36a>
      {	
        consputc(KEY_RT);				// move our marker one step to the right
80100a67:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100a6e:	e8 1c fd ff ff       	call   8010078f <consputc>
	input.a--;					// decreament our left steps counter				
80100a73:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a78:	83 e8 01             	sub    $0x1,%eax
80100a7b:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      break;
80100a80:	e9 60 01 00 00       	jmp    80100be5 <consoleintr+0x36a>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100a85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a89:	0f 84 59 01 00 00    	je     80100be8 <consoleintr+0x36d>
80100a8f:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a95:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100a9a:	89 d1                	mov    %edx,%ecx
80100a9c:	29 c1                	sub    %eax,%ecx
80100a9e:	89 c8                	mov    %ecx,%eax
80100aa0:	83 f8 7f             	cmp    $0x7f,%eax
80100aa3:	0f 87 3f 01 00 00    	ja     80100be8 <consoleintr+0x36d>
      {
	c = (c == '\r') ? '\n' : c;
80100aa9:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100aad:	74 05                	je     80100ab4 <consoleintr+0x239>
80100aaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100ab2:	eb 05                	jmp    80100ab9 <consoleintr+0x23e>
80100ab4:	b8 0a 00 00 00       	mov    $0xa,%eax
80100ab9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a > 0)			// checking if we have moved left from the end of the line
80100abc:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100ac0:	0f 84 b0 00 00 00    	je     80100b76 <consoleintr+0x2fb>
80100ac6:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100acb:	85 c0                	test   %eax,%eax
80100acd:	0f 84 a3 00 00 00    	je     80100b76 <consoleintr+0x2fb>
	{
	    uint k = input.a;
80100ad3:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100ad8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    shiftRightBuf((input.e) % INPUT_BUF,k);	// shift our buffer one step to the write
80100adb:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100ae0:	89 c2                	mov    %eax,%edx
80100ae2:	83 e2 7f             	and    $0x7f,%edx
80100ae5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
80100aec:	89 14 24             	mov    %edx,(%esp)
80100aef:	e8 f8 fc ff ff       	call   801007ec <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;	// write to the buffer the inserted letter
80100af4:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100af9:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100afc:	89 c2                	mov    %eax,%edx
80100afe:	83 e2 7f             	and    $0x7f,%edx
80100b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b04:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
	    
	    uint i = input.e-k;
80100b0a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b0f:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100b12:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e+1;i++)			// print to the screen all the characters on the right hand side of the inserted character
80100b15:	eb 1c                	jmp    80100b33 <consoleintr+0x2b8>
	      consputc(input.buf[i%INPUT_BUF]);
80100b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b1a:	83 e0 7f             	and    $0x7f,%eax
80100b1d:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100b24:	0f be c0             	movsbl %al,%eax
80100b27:	89 04 24             	mov    %eax,(%esp)
80100b2a:	e8 60 fc ff ff       	call   8010078f <consputc>
	    uint k = input.a;
	    shiftRightBuf((input.e) % INPUT_BUF,k);	// shift our buffer one step to the write
	    input.buf[(input.e-k) % INPUT_BUF] = c;	// write to the buffer the inserted letter
	    
	    uint i = input.e-k;
	    for(;i<input.e+1;i++)			// print to the screen all the characters on the right hand side of the inserted character
80100b2f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b33:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b38:	83 c0 01             	add    $0x1,%eax
80100b3b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100b3e:	77 d7                	ja     80100b17 <consoleintr+0x29c>
	      consputc(input.buf[i%INPUT_BUF]);
	    
	    i = input.e-k;				// move our line marker to where it was before inserting a character
80100b40:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b45:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100b48:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++)
80100b4b:	eb 10                	jmp    80100b5d <consoleintr+0x2e2>
	      consputc(KEY_LF);
80100b4d:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100b54:	e8 36 fc ff ff       	call   8010078f <consputc>
	    uint i = input.e-k;
	    for(;i<input.e+1;i++)			// print to the screen all the characters on the right hand side of the inserted character
	      consputc(input.buf[i%INPUT_BUF]);
	    
	    i = input.e-k;				// move our line marker to where it was before inserting a character
	    for(;i<input.e;i++)
80100b59:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b5d:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b62:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100b65:	77 e6                	ja     80100b4d <consoleintr+0x2d2>
	      consputc(KEY_LF);
	
	    input.e++;
80100b67:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b6c:	83 c0 01             	add    $0x1,%eax
80100b6f:	a3 5c de 10 80       	mov    %eax,0x8010de5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a > 0)			// checking if we have moved left from the end of the line
	{
80100b74:	eb 26                	jmp    80100b9c <consoleintr+0x321>
	      consputc(KEY_LF);
	
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100b76:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b7b:	89 c1                	mov    %eax,%ecx
80100b7d:	83 e1 7f             	and    $0x7f,%ecx
80100b80:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100b83:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
80100b89:	83 c0 01             	add    $0x1,%eax
80100b8c:	a3 5c de 10 80       	mov    %eax,0x8010de5c
          consputc(c);
80100b91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b94:	89 04 24             	mov    %eax,(%esp)
80100b97:	e8 f3 fb ff ff       	call   8010078f <consputc>
	}
	
	if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF)
80100b9c:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100ba0:	74 18                	je     80100bba <consoleintr+0x33f>
80100ba2:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100ba6:	74 12                	je     80100bba <consoleintr+0x33f>
80100ba8:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bad:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100bb3:	83 ea 80             	sub    $0xffffff80,%edx
80100bb6:	39 d0                	cmp    %edx,%eax
80100bb8:	75 2e                	jne    80100be8 <consoleintr+0x36d>
	{
	  input.w = input.e;
80100bba:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bbf:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100bc4:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100bcb:	e8 7a 43 00 00       	call   80104f4a <wakeup>
	  input.a = 0;					// after exec we'll init our left steps counter
80100bd0:	c7 05 60 de 10 80 00 	movl   $0x0,0x8010de60
80100bd7:	00 00 00 
        }
      }
      break;
80100bda:	eb 0c                	jmp    80100be8 <consoleintr+0x36d>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100bdc:	90                   	nop
80100bdd:	eb 0a                	jmp    80100be9 <consoleintr+0x36e>
	{
	  consputc(BACKSPACE);		// if not, we'll pring backspace to the screen
	}
	input.e--;
      }
      break;
80100bdf:	90                   	nop
80100be0:	eb 07                	jmp    80100be9 <consoleintr+0x36e>
     if(c != 0 && input.e - input.a > input.w)		// if there is still room to move left
      {
        consputc(KEY_LF);				// move our marker one step to the left
	input.a++;					// increament our left steps counter
      }
      break;
80100be2:	90                   	nop
80100be3:	eb 04                	jmp    80100be9 <consoleintr+0x36e>
      if(c != 0 && input.a > 0 && input.e % INPUT_BUF < INPUT_BUF-1) // if we're not at the end of the line and we've moved to the left before
      {	
        consputc(KEY_RT);				// move our marker one step to the right
	input.a--;					// decreament our left steps counter				
      }
      break;
80100be5:	90                   	nop
80100be6:	eb 01                	jmp    80100be9 <consoleintr+0x36e>
	  input.w = input.e;
          wakeup(&input.r);
	  input.a = 0;					// after exec we'll init our left steps counter
        }
      }
      break;
80100be8:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100be9:	8b 45 08             	mov    0x8(%ebp),%eax
80100bec:	ff d0                	call   *%eax
80100bee:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100bf1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100bf5:	0f 89 97 fc ff ff    	jns    80100892 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100bfb:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c02:	e8 3e 46 00 00       	call   80105245 <release>
}
80100c07:	c9                   	leave  
80100c08:	c3                   	ret    

80100c09 <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c09:	55                   	push   %ebp
80100c0a:	89 e5                	mov    %esp,%ebp
80100c0c:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80100c12:	89 04 24             	mov    %eax,(%esp)
80100c15:	e8 a4 10 00 00       	call   80101cbe <iunlock>
  target = n;
80100c1a:	8b 45 10             	mov    0x10(%ebp),%eax
80100c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100c20:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c27:	e8 b7 45 00 00       	call   801051e3 <acquire>
  while(n > 0){
80100c2c:	e9 a8 00 00 00       	jmp    80100cd9 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100c31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c37:	8b 40 24             	mov    0x24(%eax),%eax
80100c3a:	85 c0                	test   %eax,%eax
80100c3c:	74 21                	je     80100c5f <consoleread+0x56>
        release(&input.lock);
80100c3e:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c45:	e8 fb 45 00 00       	call   80105245 <release>
        ilock(ip);
80100c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80100c4d:	89 04 24             	mov    %eax,(%esp)
80100c50:	e8 1b 0f 00 00       	call   80101b70 <ilock>
        return -1;
80100c55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c5a:	e9 a9 00 00 00       	jmp    80100d08 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100c5f:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100c66:	80 
80100c67:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c6e:	e8 fb 41 00 00       	call   80104e6e <sleep>
80100c73:	eb 01                	jmp    80100c76 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100c75:	90                   	nop
80100c76:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100c7c:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100c81:	39 c2                	cmp    %eax,%edx
80100c83:	74 ac                	je     80100c31 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100c85:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100c8a:	89 c2                	mov    %eax,%edx
80100c8c:	83 e2 7f             	and    $0x7f,%edx
80100c8f:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
80100c96:	0f be d2             	movsbl %dl,%edx
80100c99:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100c9c:	83 c0 01             	add    $0x1,%eax
80100c9f:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
80100ca4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100ca8:	75 17                	jne    80100cc1 <consoleread+0xb8>
      if(n < target){
80100caa:	8b 45 10             	mov    0x10(%ebp),%eax
80100cad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100cb0:	73 2f                	jae    80100ce1 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100cb2:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100cb7:	83 e8 01             	sub    $0x1,%eax
80100cba:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100cbf:	eb 20                	jmp    80100ce1 <consoleread+0xd8>
    }
    *dst++ = c;
80100cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cc4:	89 c2                	mov    %eax,%edx
80100cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cc9:	88 10                	mov    %dl,(%eax)
80100ccb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100ccf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100cd3:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100cd7:	74 0b                	je     80100ce4 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100cd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100cdd:	7f 96                	jg     80100c75 <consoleread+0x6c>
80100cdf:	eb 04                	jmp    80100ce5 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100ce1:	90                   	nop
80100ce2:	eb 01                	jmp    80100ce5 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100ce4:	90                   	nop
  }
  release(&input.lock);
80100ce5:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100cec:	e8 54 45 00 00       	call   80105245 <release>
  ilock(ip);
80100cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80100cf4:	89 04 24             	mov    %eax,(%esp)
80100cf7:	e8 74 0e 00 00       	call   80101b70 <ilock>

  return target - n;
80100cfc:	8b 45 10             	mov    0x10(%ebp),%eax
80100cff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d02:	89 d1                	mov    %edx,%ecx
80100d04:	29 c1                	sub    %eax,%ecx
80100d06:	89 c8                	mov    %ecx,%eax
}
80100d08:	c9                   	leave  
80100d09:	c3                   	ret    

80100d0a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d0a:	55                   	push   %ebp
80100d0b:	89 e5                	mov    %esp,%ebp
80100d0d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d10:	8b 45 08             	mov    0x8(%ebp),%eax
80100d13:	89 04 24             	mov    %eax,(%esp)
80100d16:	e8 a3 0f 00 00       	call   80101cbe <iunlock>
  acquire(&cons.lock);
80100d1b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d22:	e8 bc 44 00 00       	call   801051e3 <acquire>
  for(i = 0; i < n; i++)
80100d27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100d2e:	eb 1f                	jmp    80100d4f <consolewrite+0x45>
    consputc(buf[i] & 0xff);
80100d30:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d33:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d36:	01 d0                	add    %edx,%eax
80100d38:	0f b6 00             	movzbl (%eax),%eax
80100d3b:	0f be c0             	movsbl %al,%eax
80100d3e:	25 ff 00 00 00       	and    $0xff,%eax
80100d43:	89 04 24             	mov    %eax,(%esp)
80100d46:	e8 44 fa ff ff       	call   8010078f <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100d4b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d52:	3b 45 10             	cmp    0x10(%ebp),%eax
80100d55:	7c d9                	jl     80100d30 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100d57:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d5e:	e8 e2 44 00 00       	call   80105245 <release>
  ilock(ip);
80100d63:	8b 45 08             	mov    0x8(%ebp),%eax
80100d66:	89 04 24             	mov    %eax,(%esp)
80100d69:	e8 02 0e 00 00       	call   80101b70 <ilock>

  return n;
80100d6e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100d71:	c9                   	leave  
80100d72:	c3                   	ret    

80100d73 <consoleinit>:

void
consoleinit(void)
{
80100d73:	55                   	push   %ebp
80100d74:	89 e5                	mov    %esp,%ebp
80100d76:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100d79:	c7 44 24 04 fb 88 10 	movl   $0x801088fb,0x4(%esp)
80100d80:	80 
80100d81:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d88:	e8 35 44 00 00       	call   801051c2 <initlock>
  initlock(&input.lock, "input");
80100d8d:	c7 44 24 04 03 89 10 	movl   $0x80108903,0x4(%esp)
80100d94:	80 
80100d95:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d9c:	e8 21 44 00 00       	call   801051c2 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100da1:	c7 05 2c e8 10 80 0a 	movl   $0x80100d0a,0x8010e82c
80100da8:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100dab:	c7 05 28 e8 10 80 09 	movl   $0x80100c09,0x8010e828
80100db2:	0c 10 80 
  cons.locking = 1;
80100db5:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100dbc:	00 00 00 

  picenable(IRQ_KBD);
80100dbf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100dc6:	e8 2e 30 00 00       	call   80103df9 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100dcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100dd2:	00 
80100dd3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100dda:	e8 bf 1e 00 00       	call   80102c9e <ioapicenable>
}
80100ddf:	c9                   	leave  
80100de0:	c3                   	ret    
80100de1:	66 90                	xchg   %ax,%ax
80100de3:	90                   	nop

80100de4 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100de4:	55                   	push   %ebp
80100de5:	89 e5                	mov    %esp,%ebp
80100de7:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100ded:	8b 45 08             	mov    0x8(%ebp),%eax
80100df0:	89 04 24             	mov    %eax,(%esp)
80100df3:	e8 39 19 00 00       	call   80102731 <namei>
80100df8:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100dfb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100dff:	75 0a                	jne    80100e0b <exec+0x27>
    return -1;
80100e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e06:	e9 f6 03 00 00       	jmp    80101201 <exec+0x41d>
  ilock(ip);
80100e0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e0e:	89 04 24             	mov    %eax,(%esp)
80100e11:	e8 5a 0d 00 00       	call   80101b70 <ilock>
  pgdir = 0;
80100e16:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e1d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100e24:	00 
80100e25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100e2c:	00 
80100e2d:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100e33:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e37:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e3a:	89 04 24             	mov    %eax,(%esp)
80100e3d:	e8 3b 12 00 00       	call   8010207d <readi>
80100e42:	83 f8 33             	cmp    $0x33,%eax
80100e45:	0f 86 70 03 00 00    	jbe    801011bb <exec+0x3d7>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100e4b:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100e51:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100e56:	0f 85 62 03 00 00    	jne    801011be <exec+0x3da>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100e5c:	c7 04 24 27 2e 10 80 	movl   $0x80102e27,(%esp)
80100e63:	e8 e7 71 00 00       	call   8010804f <setupkvm>
80100e68:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100e6b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100e6f:	0f 84 4c 03 00 00    	je     801011c1 <exec+0x3dd>
    goto bad;

  // Load program into memory.
  sz = 0;
80100e75:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e7c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100e83:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100e89:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e8c:	e9 c5 00 00 00       	jmp    80100f56 <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100e91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e94:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100e9b:	00 
80100e9c:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ea0:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100eaa:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ead:	89 04 24             	mov    %eax,(%esp)
80100eb0:	e8 c8 11 00 00       	call   8010207d <readi>
80100eb5:	83 f8 20             	cmp    $0x20,%eax
80100eb8:	0f 85 06 03 00 00    	jne    801011c4 <exec+0x3e0>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ebe:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ec4:	83 f8 01             	cmp    $0x1,%eax
80100ec7:	75 7f                	jne    80100f48 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100ec9:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100ecf:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ed5:	39 c2                	cmp    %eax,%edx
80100ed7:	0f 82 ea 02 00 00    	jb     801011c7 <exec+0x3e3>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100edd:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100ee3:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100ee9:	01 d0                	add    %edx,%eax
80100eeb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100eef:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ef6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ef9:	89 04 24             	mov    %eax,(%esp)
80100efc:	e8 20 75 00 00       	call   80108421 <allocuvm>
80100f01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f08:	0f 84 bc 02 00 00    	je     801011ca <exec+0x3e6>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f0e:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f14:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f1a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100f20:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100f24:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f28:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f2b:	89 54 24 08          	mov    %edx,0x8(%esp)
80100f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f36:	89 04 24             	mov    %eax,(%esp)
80100f39:	e8 f4 73 00 00       	call   80108332 <loaduvm>
80100f3e:	85 c0                	test   %eax,%eax
80100f40:	0f 88 87 02 00 00    	js     801011cd <exec+0x3e9>
80100f46:	eb 01                	jmp    80100f49 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100f48:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f49:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100f4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f50:	83 c0 20             	add    $0x20,%eax
80100f53:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f56:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100f5d:	0f b7 c0             	movzwl %ax,%eax
80100f60:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100f63:	0f 8f 28 ff ff ff    	jg     80100e91 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100f69:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f6c:	89 04 24             	mov    %eax,(%esp)
80100f6f:	e8 80 0e 00 00       	call   80101df4 <iunlockput>
  ip = 0;
80100f74:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100f7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f7e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100f83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100f88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100f8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f8e:	05 00 20 00 00       	add    $0x2000,%eax
80100f93:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fa1:	89 04 24             	mov    %eax,(%esp)
80100fa4:	e8 78 74 00 00       	call   80108421 <allocuvm>
80100fa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100fac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100fb0:	0f 84 1a 02 00 00    	je     801011d0 <exec+0x3ec>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100fb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fb9:	2d 00 20 00 00       	sub    $0x2000,%eax
80100fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fc2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fc5:	89 04 24             	mov    %eax,(%esp)
80100fc8:	e8 84 76 00 00       	call   80108651 <clearpteu>
  sp = sz;
80100fcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fd0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100fd3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100fda:	e9 97 00 00 00       	jmp    80101076 <exec+0x292>
    if(argc >= MAXARG)
80100fdf:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100fe3:	0f 87 ea 01 00 00    	ja     801011d3 <exec+0x3ef>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ff6:	01 d0                	add    %edx,%eax
80100ff8:	8b 00                	mov    (%eax),%eax
80100ffa:	89 04 24             	mov    %eax,(%esp)
80100ffd:	e8 ba 46 00 00       	call   801056bc <strlen>
80101002:	f7 d0                	not    %eax
80101004:	89 c2                	mov    %eax,%edx
80101006:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101009:	01 d0                	add    %edx,%eax
8010100b:	83 e0 fc             	and    $0xfffffffc,%eax
8010100e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101014:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010101b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010101e:	01 d0                	add    %edx,%eax
80101020:	8b 00                	mov    (%eax),%eax
80101022:	89 04 24             	mov    %eax,(%esp)
80101025:	e8 92 46 00 00       	call   801056bc <strlen>
8010102a:	83 c0 01             	add    $0x1,%eax
8010102d:	89 c2                	mov    %eax,%edx
8010102f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101032:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80101039:	8b 45 0c             	mov    0xc(%ebp),%eax
8010103c:	01 c8                	add    %ecx,%eax
8010103e:	8b 00                	mov    (%eax),%eax
80101040:	89 54 24 0c          	mov    %edx,0xc(%esp)
80101044:	89 44 24 08          	mov    %eax,0x8(%esp)
80101048:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010104b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010104f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101052:	89 04 24             	mov    %eax,(%esp)
80101055:	e8 ab 77 00 00       	call   80108805 <copyout>
8010105a:	85 c0                	test   %eax,%eax
8010105c:	0f 88 74 01 00 00    	js     801011d6 <exec+0x3f2>
      goto bad;
    ustack[3+argc] = sp;
80101062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101065:	8d 50 03             	lea    0x3(%eax),%edx
80101068:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010106b:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101072:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101076:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101079:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101080:	8b 45 0c             	mov    0xc(%ebp),%eax
80101083:	01 d0                	add    %edx,%eax
80101085:	8b 00                	mov    (%eax),%eax
80101087:	85 c0                	test   %eax,%eax
80101089:	0f 85 50 ff ff ff    	jne    80100fdf <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
8010108f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101092:	83 c0 03             	add    $0x3,%eax
80101095:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
8010109c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801010a0:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
801010a7:	ff ff ff 
  ustack[1] = argc;
801010aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010ad:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
801010b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b6:	83 c0 01             	add    $0x1,%eax
801010b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801010c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010c3:	29 d0                	sub    %edx,%eax
801010c5:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
801010cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010ce:	83 c0 04             	add    $0x4,%eax
801010d1:	c1 e0 02             	shl    $0x2,%eax
801010d4:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
801010d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010da:	83 c0 04             	add    $0x4,%eax
801010dd:	c1 e0 02             	shl    $0x2,%eax
801010e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
801010e4:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
801010ea:	89 44 24 08          	mov    %eax,0x8(%esp)
801010ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801010f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010f8:	89 04 24             	mov    %eax,(%esp)
801010fb:	e8 05 77 00 00       	call   80108805 <copyout>
80101100:	85 c0                	test   %eax,%eax
80101102:	0f 88 d1 00 00 00    	js     801011d9 <exec+0x3f5>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101108:	8b 45 08             	mov    0x8(%ebp),%eax
8010110b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010110e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101111:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101114:	eb 17                	jmp    8010112d <exec+0x349>
    if(*s == '/')
80101116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101119:	0f b6 00             	movzbl (%eax),%eax
8010111c:	3c 2f                	cmp    $0x2f,%al
8010111e:	75 09                	jne    80101129 <exec+0x345>
      last = s+1;
80101120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101123:	83 c0 01             	add    $0x1,%eax
80101126:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101129:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010112d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101130:	0f b6 00             	movzbl (%eax),%eax
80101133:	84 c0                	test   %al,%al
80101135:	75 df                	jne    80101116 <exec+0x332>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101137:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010113d:	8d 50 6c             	lea    0x6c(%eax),%edx
80101140:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101147:	00 
80101148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010114b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010114f:	89 14 24             	mov    %edx,(%esp)
80101152:	e8 17 45 00 00       	call   8010566e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80101157:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010115d:	8b 40 04             	mov    0x4(%eax),%eax
80101160:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80101163:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101169:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010116c:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
8010116f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101175:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101178:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
8010117a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101180:	8b 40 18             	mov    0x18(%eax),%eax
80101183:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80101189:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
8010118c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101192:	8b 40 18             	mov    0x18(%eax),%eax
80101195:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101198:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
8010119b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011a1:	89 04 24             	mov    %eax,(%esp)
801011a4:	e8 97 6f 00 00       	call   80108140 <switchuvm>
  freevm(oldpgdir);
801011a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011ac:	89 04 24             	mov    %eax,(%esp)
801011af:	e8 03 74 00 00       	call   801085b7 <freevm>
  return 0;
801011b4:	b8 00 00 00 00       	mov    $0x0,%eax
801011b9:	eb 46                	jmp    80101201 <exec+0x41d>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
801011bb:	90                   	nop
801011bc:	eb 1c                	jmp    801011da <exec+0x3f6>
  if(elf.magic != ELF_MAGIC)
    goto bad;
801011be:	90                   	nop
801011bf:	eb 19                	jmp    801011da <exec+0x3f6>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
801011c1:	90                   	nop
801011c2:	eb 16                	jmp    801011da <exec+0x3f6>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
801011c4:	90                   	nop
801011c5:	eb 13                	jmp    801011da <exec+0x3f6>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
801011c7:	90                   	nop
801011c8:	eb 10                	jmp    801011da <exec+0x3f6>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
801011ca:	90                   	nop
801011cb:	eb 0d                	jmp    801011da <exec+0x3f6>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
801011cd:	90                   	nop
801011ce:	eb 0a                	jmp    801011da <exec+0x3f6>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
801011d0:	90                   	nop
801011d1:	eb 07                	jmp    801011da <exec+0x3f6>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
801011d3:	90                   	nop
801011d4:	eb 04                	jmp    801011da <exec+0x3f6>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
801011d6:	90                   	nop
801011d7:	eb 01                	jmp    801011da <exec+0x3f6>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
801011d9:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
801011da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801011de:	74 0b                	je     801011eb <exec+0x407>
    freevm(pgdir);
801011e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801011e3:	89 04 24             	mov    %eax,(%esp)
801011e6:	e8 cc 73 00 00       	call   801085b7 <freevm>
  if(ip)
801011eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801011ef:	74 0b                	je     801011fc <exec+0x418>
    iunlockput(ip);
801011f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801011f4:	89 04 24             	mov    %eax,(%esp)
801011f7:	e8 f8 0b 00 00       	call   80101df4 <iunlockput>
  return -1;
801011fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101201:	c9                   	leave  
80101202:	c3                   	ret    
80101203:	90                   	nop

80101204 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101204:	55                   	push   %ebp
80101205:	89 e5                	mov    %esp,%ebp
80101207:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010120a:	c7 44 24 04 09 89 10 	movl   $0x80108909,0x4(%esp)
80101211:	80 
80101212:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101219:	e8 a4 3f 00 00       	call   801051c2 <initlock>
}
8010121e:	c9                   	leave  
8010121f:	c3                   	ret    

80101220 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101220:	55                   	push   %ebp
80101221:	89 e5                	mov    %esp,%ebp
80101223:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101226:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010122d:	e8 b1 3f 00 00       	call   801051e3 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101232:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80101239:	eb 29                	jmp    80101264 <filealloc+0x44>
    if(f->ref == 0){
8010123b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010123e:	8b 40 04             	mov    0x4(%eax),%eax
80101241:	85 c0                	test   %eax,%eax
80101243:	75 1b                	jne    80101260 <filealloc+0x40>
      f->ref = 1;
80101245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101248:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010124f:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101256:	e8 ea 3f 00 00       	call   80105245 <release>
      return f;
8010125b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010125e:	eb 1e                	jmp    8010127e <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101260:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101264:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
8010126b:	72 ce                	jb     8010123b <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010126d:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101274:	e8 cc 3f 00 00       	call   80105245 <release>
  return 0;
80101279:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010127e:	c9                   	leave  
8010127f:	c3                   	ret    

80101280 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101280:	55                   	push   %ebp
80101281:	89 e5                	mov    %esp,%ebp
80101283:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101286:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010128d:	e8 51 3f 00 00       	call   801051e3 <acquire>
  if(f->ref < 1)
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 04             	mov    0x4(%eax),%eax
80101298:	85 c0                	test   %eax,%eax
8010129a:	7f 0c                	jg     801012a8 <filedup+0x28>
    panic("filedup");
8010129c:	c7 04 24 10 89 10 80 	movl   $0x80108910,(%esp)
801012a3:	e8 9e f2 ff ff       	call   80100546 <panic>
  f->ref++;
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	8b 40 04             	mov    0x4(%eax),%eax
801012ae:	8d 50 01             	lea    0x1(%eax),%edx
801012b1:	8b 45 08             	mov    0x8(%ebp),%eax
801012b4:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801012b7:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012be:	e8 82 3f 00 00       	call   80105245 <release>
  return f;
801012c3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801012c6:	c9                   	leave  
801012c7:	c3                   	ret    

801012c8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801012c8:	55                   	push   %ebp
801012c9:	89 e5                	mov    %esp,%ebp
801012cb:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801012ce:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012d5:	e8 09 3f 00 00       	call   801051e3 <acquire>
  if(f->ref < 1)
801012da:	8b 45 08             	mov    0x8(%ebp),%eax
801012dd:	8b 40 04             	mov    0x4(%eax),%eax
801012e0:	85 c0                	test   %eax,%eax
801012e2:	7f 0c                	jg     801012f0 <fileclose+0x28>
    panic("fileclose");
801012e4:	c7 04 24 18 89 10 80 	movl   $0x80108918,(%esp)
801012eb:	e8 56 f2 ff ff       	call   80100546 <panic>
  if(--f->ref > 0){
801012f0:	8b 45 08             	mov    0x8(%ebp),%eax
801012f3:	8b 40 04             	mov    0x4(%eax),%eax
801012f6:	8d 50 ff             	lea    -0x1(%eax),%edx
801012f9:	8b 45 08             	mov    0x8(%ebp),%eax
801012fc:	89 50 04             	mov    %edx,0x4(%eax)
801012ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101302:	8b 40 04             	mov    0x4(%eax),%eax
80101305:	85 c0                	test   %eax,%eax
80101307:	7e 11                	jle    8010131a <fileclose+0x52>
    release(&ftable.lock);
80101309:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101310:	e8 30 3f 00 00       	call   80105245 <release>
80101315:	e9 82 00 00 00       	jmp    8010139c <fileclose+0xd4>
    return;
  }
  ff = *f;
8010131a:	8b 45 08             	mov    0x8(%ebp),%eax
8010131d:	8b 10                	mov    (%eax),%edx
8010131f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101322:	8b 50 04             	mov    0x4(%eax),%edx
80101325:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101328:	8b 50 08             	mov    0x8(%eax),%edx
8010132b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010132e:	8b 50 0c             	mov    0xc(%eax),%edx
80101331:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101334:	8b 50 10             	mov    0x10(%eax),%edx
80101337:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010133a:	8b 40 14             	mov    0x14(%eax),%eax
8010133d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010134a:	8b 45 08             	mov    0x8(%ebp),%eax
8010134d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101353:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010135a:	e8 e6 3e 00 00       	call   80105245 <release>
  
  if(ff.type == FD_PIPE)
8010135f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101362:	83 f8 01             	cmp    $0x1,%eax
80101365:	75 18                	jne    8010137f <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101367:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010136b:	0f be d0             	movsbl %al,%edx
8010136e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101371:	89 54 24 04          	mov    %edx,0x4(%esp)
80101375:	89 04 24             	mov    %eax,(%esp)
80101378:	e8 36 2d 00 00       	call   801040b3 <pipeclose>
8010137d:	eb 1d                	jmp    8010139c <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010137f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101382:	83 f8 02             	cmp    $0x2,%eax
80101385:	75 15                	jne    8010139c <fileclose+0xd4>
    begin_trans();
80101387:	e8 c0 21 00 00       	call   8010354c <begin_trans>
    iput(ff.ip);
8010138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010138f:	89 04 24             	mov    %eax,(%esp)
80101392:	e8 8c 09 00 00       	call   80101d23 <iput>
    commit_trans();
80101397:	e8 f9 21 00 00       	call   80103595 <commit_trans>
  }
}
8010139c:	c9                   	leave  
8010139d:	c3                   	ret    

8010139e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010139e:	55                   	push   %ebp
8010139f:	89 e5                	mov    %esp,%ebp
801013a1:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	8b 00                	mov    (%eax),%eax
801013a9:	83 f8 02             	cmp    $0x2,%eax
801013ac:	75 38                	jne    801013e6 <filestat+0x48>
    ilock(f->ip);
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 40 10             	mov    0x10(%eax),%eax
801013b4:	89 04 24             	mov    %eax,(%esp)
801013b7:	e8 b4 07 00 00       	call   80101b70 <ilock>
    stati(f->ip, st);
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	8b 40 10             	mov    0x10(%eax),%eax
801013c2:	8b 55 0c             	mov    0xc(%ebp),%edx
801013c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801013c9:	89 04 24             	mov    %eax,(%esp)
801013cc:	e8 67 0c 00 00       	call   80102038 <stati>
    iunlock(f->ip);
801013d1:	8b 45 08             	mov    0x8(%ebp),%eax
801013d4:	8b 40 10             	mov    0x10(%eax),%eax
801013d7:	89 04 24             	mov    %eax,(%esp)
801013da:	e8 df 08 00 00       	call   80101cbe <iunlock>
    return 0;
801013df:	b8 00 00 00 00       	mov    $0x0,%eax
801013e4:	eb 05                	jmp    801013eb <filestat+0x4d>
  }
  return -1;
801013e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801013eb:	c9                   	leave  
801013ec:	c3                   	ret    

801013ed <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801013ed:	55                   	push   %ebp
801013ee:	89 e5                	mov    %esp,%ebp
801013f0:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801013f3:	8b 45 08             	mov    0x8(%ebp),%eax
801013f6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801013fa:	84 c0                	test   %al,%al
801013fc:	75 0a                	jne    80101408 <fileread+0x1b>
    return -1;
801013fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101403:	e9 9f 00 00 00       	jmp    801014a7 <fileread+0xba>
  if(f->type == FD_PIPE)
80101408:	8b 45 08             	mov    0x8(%ebp),%eax
8010140b:	8b 00                	mov    (%eax),%eax
8010140d:	83 f8 01             	cmp    $0x1,%eax
80101410:	75 1e                	jne    80101430 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101412:	8b 45 08             	mov    0x8(%ebp),%eax
80101415:	8b 40 0c             	mov    0xc(%eax),%eax
80101418:	8b 55 10             	mov    0x10(%ebp),%edx
8010141b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010141f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101422:	89 54 24 04          	mov    %edx,0x4(%esp)
80101426:	89 04 24             	mov    %eax,(%esp)
80101429:	e8 09 2e 00 00       	call   80104237 <piperead>
8010142e:	eb 77                	jmp    801014a7 <fileread+0xba>
  if(f->type == FD_INODE){
80101430:	8b 45 08             	mov    0x8(%ebp),%eax
80101433:	8b 00                	mov    (%eax),%eax
80101435:	83 f8 02             	cmp    $0x2,%eax
80101438:	75 61                	jne    8010149b <fileread+0xae>
    ilock(f->ip);
8010143a:	8b 45 08             	mov    0x8(%ebp),%eax
8010143d:	8b 40 10             	mov    0x10(%eax),%eax
80101440:	89 04 24             	mov    %eax,(%esp)
80101443:	e8 28 07 00 00       	call   80101b70 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101448:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010144b:	8b 45 08             	mov    0x8(%ebp),%eax
8010144e:	8b 50 14             	mov    0x14(%eax),%edx
80101451:	8b 45 08             	mov    0x8(%ebp),%eax
80101454:	8b 40 10             	mov    0x10(%eax),%eax
80101457:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010145b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010145f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101462:	89 54 24 04          	mov    %edx,0x4(%esp)
80101466:	89 04 24             	mov    %eax,(%esp)
80101469:	e8 0f 0c 00 00       	call   8010207d <readi>
8010146e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101471:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101475:	7e 11                	jle    80101488 <fileread+0x9b>
      f->off += r;
80101477:	8b 45 08             	mov    0x8(%ebp),%eax
8010147a:	8b 50 14             	mov    0x14(%eax),%edx
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	01 c2                	add    %eax,%edx
80101482:	8b 45 08             	mov    0x8(%ebp),%eax
80101485:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101488:	8b 45 08             	mov    0x8(%ebp),%eax
8010148b:	8b 40 10             	mov    0x10(%eax),%eax
8010148e:	89 04 24             	mov    %eax,(%esp)
80101491:	e8 28 08 00 00       	call   80101cbe <iunlock>
    return r;
80101496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101499:	eb 0c                	jmp    801014a7 <fileread+0xba>
  }
  panic("fileread");
8010149b:	c7 04 24 22 89 10 80 	movl   $0x80108922,(%esp)
801014a2:	e8 9f f0 ff ff       	call   80100546 <panic>
}
801014a7:	c9                   	leave  
801014a8:	c3                   	ret    

801014a9 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801014a9:	55                   	push   %ebp
801014aa:	89 e5                	mov    %esp,%ebp
801014ac:	53                   	push   %ebx
801014ad:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801014b0:	8b 45 08             	mov    0x8(%ebp),%eax
801014b3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801014b7:	84 c0                	test   %al,%al
801014b9:	75 0a                	jne    801014c5 <filewrite+0x1c>
    return -1;
801014bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014c0:	e9 23 01 00 00       	jmp    801015e8 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801014c5:	8b 45 08             	mov    0x8(%ebp),%eax
801014c8:	8b 00                	mov    (%eax),%eax
801014ca:	83 f8 01             	cmp    $0x1,%eax
801014cd:	75 21                	jne    801014f0 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801014cf:	8b 45 08             	mov    0x8(%ebp),%eax
801014d2:	8b 40 0c             	mov    0xc(%eax),%eax
801014d5:	8b 55 10             	mov    0x10(%ebp),%edx
801014d8:	89 54 24 08          	mov    %edx,0x8(%esp)
801014dc:	8b 55 0c             	mov    0xc(%ebp),%edx
801014df:	89 54 24 04          	mov    %edx,0x4(%esp)
801014e3:	89 04 24             	mov    %eax,(%esp)
801014e6:	e8 5a 2c 00 00       	call   80104145 <pipewrite>
801014eb:	e9 f8 00 00 00       	jmp    801015e8 <filewrite+0x13f>
  if(f->type == FD_INODE){
801014f0:	8b 45 08             	mov    0x8(%ebp),%eax
801014f3:	8b 00                	mov    (%eax),%eax
801014f5:	83 f8 02             	cmp    $0x2,%eax
801014f8:	0f 85 de 00 00 00    	jne    801015dc <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801014fe:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101505:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010150c:	e9 a8 00 00 00       	jmp    801015b9 <filewrite+0x110>
      int n1 = n - i;
80101511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101514:	8b 55 10             	mov    0x10(%ebp),%edx
80101517:	89 d1                	mov    %edx,%ecx
80101519:	29 c1                	sub    %eax,%ecx
8010151b:	89 c8                	mov    %ecx,%eax
8010151d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101523:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101526:	7e 06                	jle    8010152e <filewrite+0x85>
        n1 = max;
80101528:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010152b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010152e:	e8 19 20 00 00       	call   8010354c <begin_trans>
      ilock(f->ip);
80101533:	8b 45 08             	mov    0x8(%ebp),%eax
80101536:	8b 40 10             	mov    0x10(%eax),%eax
80101539:	89 04 24             	mov    %eax,(%esp)
8010153c:	e8 2f 06 00 00       	call   80101b70 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101541:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101544:	8b 45 08             	mov    0x8(%ebp),%eax
80101547:	8b 50 14             	mov    0x14(%eax),%edx
8010154a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010154d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101550:	01 c3                	add    %eax,%ebx
80101552:	8b 45 08             	mov    0x8(%ebp),%eax
80101555:	8b 40 10             	mov    0x10(%eax),%eax
80101558:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010155c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101564:	89 04 24             	mov    %eax,(%esp)
80101567:	e8 7f 0c 00 00       	call   801021eb <writei>
8010156c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010156f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101573:	7e 11                	jle    80101586 <filewrite+0xdd>
        f->off += r;
80101575:	8b 45 08             	mov    0x8(%ebp),%eax
80101578:	8b 50 14             	mov    0x14(%eax),%edx
8010157b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010157e:	01 c2                	add    %eax,%edx
80101580:	8b 45 08             	mov    0x8(%ebp),%eax
80101583:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101586:	8b 45 08             	mov    0x8(%ebp),%eax
80101589:	8b 40 10             	mov    0x10(%eax),%eax
8010158c:	89 04 24             	mov    %eax,(%esp)
8010158f:	e8 2a 07 00 00       	call   80101cbe <iunlock>
      commit_trans();
80101594:	e8 fc 1f 00 00       	call   80103595 <commit_trans>

      if(r < 0)
80101599:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010159d:	78 28                	js     801015c7 <filewrite+0x11e>
        break;
      if(r != n1)
8010159f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015a2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801015a5:	74 0c                	je     801015b3 <filewrite+0x10a>
        panic("short filewrite");
801015a7:	c7 04 24 2b 89 10 80 	movl   $0x8010892b,(%esp)
801015ae:	e8 93 ef ff ff       	call   80100546 <panic>
      i += r;
801015b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015b6:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801015b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801015bf:	0f 8c 4c ff ff ff    	jl     80101511 <filewrite+0x68>
801015c5:	eb 01                	jmp    801015c8 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801015c7:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801015c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015cb:	3b 45 10             	cmp    0x10(%ebp),%eax
801015ce:	75 05                	jne    801015d5 <filewrite+0x12c>
801015d0:	8b 45 10             	mov    0x10(%ebp),%eax
801015d3:	eb 05                	jmp    801015da <filewrite+0x131>
801015d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801015da:	eb 0c                	jmp    801015e8 <filewrite+0x13f>
  }
  panic("filewrite");
801015dc:	c7 04 24 3b 89 10 80 	movl   $0x8010893b,(%esp)
801015e3:	e8 5e ef ff ff       	call   80100546 <panic>
}
801015e8:	83 c4 24             	add    $0x24,%esp
801015eb:	5b                   	pop    %ebx
801015ec:	5d                   	pop    %ebp
801015ed:	c3                   	ret    
801015ee:	66 90                	xchg   %ax,%ax

801015f0 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801015f0:	55                   	push   %ebp
801015f1:	89 e5                	mov    %esp,%ebp
801015f3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801015f6:	8b 45 08             	mov    0x8(%ebp),%eax
801015f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101600:	00 
80101601:	89 04 24             	mov    %eax,(%esp)
80101604:	e8 9d eb ff ff       	call   801001a6 <bread>
80101609:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160f:	83 c0 18             	add    $0x18,%eax
80101612:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101619:	00 
8010161a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010161e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101621:	89 04 24             	mov    %eax,(%esp)
80101624:	e8 e8 3e 00 00       	call   80105511 <memmove>
  brelse(bp);
80101629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162c:	89 04 24             	mov    %eax,(%esp)
8010162f:	e8 e3 eb ff ff       	call   80100217 <brelse>
}
80101634:	c9                   	leave  
80101635:	c3                   	ret    

80101636 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101636:	55                   	push   %ebp
80101637:	89 e5                	mov    %esp,%ebp
80101639:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010163c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010163f:	8b 45 08             	mov    0x8(%ebp),%eax
80101642:	89 54 24 04          	mov    %edx,0x4(%esp)
80101646:	89 04 24             	mov    %eax,(%esp)
80101649:	e8 58 eb ff ff       	call   801001a6 <bread>
8010164e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101654:	83 c0 18             	add    $0x18,%eax
80101657:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010165e:	00 
8010165f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101666:	00 
80101667:	89 04 24             	mov    %eax,(%esp)
8010166a:	e8 cf 3d 00 00       	call   8010543e <memset>
  log_write(bp);
8010166f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101672:	89 04 24             	mov    %eax,(%esp)
80101675:	e8 73 1f 00 00       	call   801035ed <log_write>
  brelse(bp);
8010167a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167d:	89 04 24             	mov    %eax,(%esp)
80101680:	e8 92 eb ff ff       	call   80100217 <brelse>
}
80101685:	c9                   	leave  
80101686:	c3                   	ret    

80101687 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101687:	55                   	push   %ebp
80101688:	89 e5                	mov    %esp,%ebp
8010168a:	53                   	push   %ebx
8010168b:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010168e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101695:	8b 45 08             	mov    0x8(%ebp),%eax
80101698:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010169b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010169f:	89 04 24             	mov    %eax,(%esp)
801016a2:	e8 49 ff ff ff       	call   801015f0 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801016a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801016ae:	e9 0d 01 00 00       	jmp    801017c0 <balloc+0x139>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801016b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801016bc:	85 c0                	test   %eax,%eax
801016be:	0f 48 c2             	cmovs  %edx,%eax
801016c1:	c1 f8 0c             	sar    $0xc,%eax
801016c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801016c7:	c1 ea 03             	shr    $0x3,%edx
801016ca:	01 d0                	add    %edx,%eax
801016cc:	83 c0 03             	add    $0x3,%eax
801016cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801016d3:	8b 45 08             	mov    0x8(%ebp),%eax
801016d6:	89 04 24             	mov    %eax,(%esp)
801016d9:	e8 c8 ea ff ff       	call   801001a6 <bread>
801016de:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801016e8:	e9 a3 00 00 00       	jmp    80101790 <balloc+0x109>
      m = 1 << (bi % 8);
801016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f0:	89 c2                	mov    %eax,%edx
801016f2:	c1 fa 1f             	sar    $0x1f,%edx
801016f5:	c1 ea 1d             	shr    $0x1d,%edx
801016f8:	01 d0                	add    %edx,%eax
801016fa:	83 e0 07             	and    $0x7,%eax
801016fd:	29 d0                	sub    %edx,%eax
801016ff:	ba 01 00 00 00       	mov    $0x1,%edx
80101704:	89 d3                	mov    %edx,%ebx
80101706:	89 c1                	mov    %eax,%ecx
80101708:	d3 e3                	shl    %cl,%ebx
8010170a:	89 d8                	mov    %ebx,%eax
8010170c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010170f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101712:	8d 50 07             	lea    0x7(%eax),%edx
80101715:	85 c0                	test   %eax,%eax
80101717:	0f 48 c2             	cmovs  %edx,%eax
8010171a:	c1 f8 03             	sar    $0x3,%eax
8010171d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101720:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101725:	0f b6 c0             	movzbl %al,%eax
80101728:	23 45 e8             	and    -0x18(%ebp),%eax
8010172b:	85 c0                	test   %eax,%eax
8010172d:	75 5d                	jne    8010178c <balloc+0x105>
        bp->data[bi/8] |= m;  // Mark block in use.
8010172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101732:	8d 50 07             	lea    0x7(%eax),%edx
80101735:	85 c0                	test   %eax,%eax
80101737:	0f 48 c2             	cmovs  %edx,%eax
8010173a:	c1 f8 03             	sar    $0x3,%eax
8010173d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101740:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101745:	89 d1                	mov    %edx,%ecx
80101747:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010174a:	09 ca                	or     %ecx,%edx
8010174c:	89 d1                	mov    %edx,%ecx
8010174e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101751:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101755:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101758:	89 04 24             	mov    %eax,(%esp)
8010175b:	e8 8d 1e 00 00       	call   801035ed <log_write>
        brelse(bp);
80101760:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101763:	89 04 24             	mov    %eax,(%esp)
80101766:	e8 ac ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
8010176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101771:	01 c2                	add    %eax,%edx
80101773:	8b 45 08             	mov    0x8(%ebp),%eax
80101776:	89 54 24 04          	mov    %edx,0x4(%esp)
8010177a:	89 04 24             	mov    %eax,(%esp)
8010177d:	e8 b4 fe ff ff       	call   80101636 <bzero>
        return b + bi;
80101782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101785:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101788:	01 d0                	add    %edx,%eax
8010178a:	eb 4e                	jmp    801017da <balloc+0x153>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010178c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101790:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101797:	7f 15                	jg     801017ae <balloc+0x127>
80101799:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010179c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010179f:	01 d0                	add    %edx,%eax
801017a1:	89 c2                	mov    %eax,%edx
801017a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017a6:	39 c2                	cmp    %eax,%edx
801017a8:	0f 82 3f ff ff ff    	jb     801016ed <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801017ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b1:	89 04 24             	mov    %eax,(%esp)
801017b4:	e8 5e ea ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801017b9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801017c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017c6:	39 c2                	cmp    %eax,%edx
801017c8:	0f 82 e5 fe ff ff    	jb     801016b3 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801017ce:	c7 04 24 45 89 10 80 	movl   $0x80108945,(%esp)
801017d5:	e8 6c ed ff ff       	call   80100546 <panic>
}
801017da:	83 c4 34             	add    $0x34,%esp
801017dd:	5b                   	pop    %ebx
801017de:	5d                   	pop    %ebp
801017df:	c3                   	ret    

801017e0 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801017e0:	55                   	push   %ebp
801017e1:	89 e5                	mov    %esp,%ebp
801017e3:	53                   	push   %ebx
801017e4:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801017e7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801017ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801017ee:	8b 45 08             	mov    0x8(%ebp),%eax
801017f1:	89 04 24             	mov    %eax,(%esp)
801017f4:	e8 f7 fd ff ff       	call   801015f0 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801017f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801017fc:	89 c2                	mov    %eax,%edx
801017fe:	c1 ea 0c             	shr    $0xc,%edx
80101801:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101804:	c1 e8 03             	shr    $0x3,%eax
80101807:	01 d0                	add    %edx,%eax
80101809:	8d 50 03             	lea    0x3(%eax),%edx
8010180c:	8b 45 08             	mov    0x8(%ebp),%eax
8010180f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101813:	89 04 24             	mov    %eax,(%esp)
80101816:	e8 8b e9 ff ff       	call   801001a6 <bread>
8010181b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010181e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101821:	25 ff 0f 00 00       	and    $0xfff,%eax
80101826:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101829:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010182c:	89 c2                	mov    %eax,%edx
8010182e:	c1 fa 1f             	sar    $0x1f,%edx
80101831:	c1 ea 1d             	shr    $0x1d,%edx
80101834:	01 d0                	add    %edx,%eax
80101836:	83 e0 07             	and    $0x7,%eax
80101839:	29 d0                	sub    %edx,%eax
8010183b:	ba 01 00 00 00       	mov    $0x1,%edx
80101840:	89 d3                	mov    %edx,%ebx
80101842:	89 c1                	mov    %eax,%ecx
80101844:	d3 e3                	shl    %cl,%ebx
80101846:	89 d8                	mov    %ebx,%eax
80101848:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010184e:	8d 50 07             	lea    0x7(%eax),%edx
80101851:	85 c0                	test   %eax,%eax
80101853:	0f 48 c2             	cmovs  %edx,%eax
80101856:	c1 f8 03             	sar    $0x3,%eax
80101859:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010185c:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101861:	0f b6 c0             	movzbl %al,%eax
80101864:	23 45 ec             	and    -0x14(%ebp),%eax
80101867:	85 c0                	test   %eax,%eax
80101869:	75 0c                	jne    80101877 <bfree+0x97>
    panic("freeing free block");
8010186b:	c7 04 24 5b 89 10 80 	movl   $0x8010895b,(%esp)
80101872:	e8 cf ec ff ff       	call   80100546 <panic>
  bp->data[bi/8] &= ~m;
80101877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187a:	8d 50 07             	lea    0x7(%eax),%edx
8010187d:	85 c0                	test   %eax,%eax
8010187f:	0f 48 c2             	cmovs  %edx,%eax
80101882:	c1 f8 03             	sar    $0x3,%eax
80101885:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101888:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010188d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101890:	f7 d1                	not    %ecx
80101892:	21 ca                	and    %ecx,%edx
80101894:	89 d1                	mov    %edx,%ecx
80101896:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101899:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a0:	89 04 24             	mov    %eax,(%esp)
801018a3:	e8 45 1d 00 00       	call   801035ed <log_write>
  brelse(bp);
801018a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ab:	89 04 24             	mov    %eax,(%esp)
801018ae:	e8 64 e9 ff ff       	call   80100217 <brelse>
}
801018b3:	83 c4 34             	add    $0x34,%esp
801018b6:	5b                   	pop    %ebx
801018b7:	5d                   	pop    %ebp
801018b8:	c3                   	ret    

801018b9 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801018b9:	55                   	push   %ebp
801018ba:	89 e5                	mov    %esp,%ebp
801018bc:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801018bf:	c7 44 24 04 6e 89 10 	movl   $0x8010896e,0x4(%esp)
801018c6:	80 
801018c7:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801018ce:	e8 ef 38 00 00       	call   801051c2 <initlock>
}
801018d3:	c9                   	leave  
801018d4:	c3                   	ret    

801018d5 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801018d5:	55                   	push   %ebp
801018d6:	89 e5                	mov    %esp,%ebp
801018d8:	83 ec 48             	sub    $0x48,%esp
801018db:	8b 45 0c             	mov    0xc(%ebp),%eax
801018de:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801018e2:	8b 45 08             	mov    0x8(%ebp),%eax
801018e5:	8d 55 dc             	lea    -0x24(%ebp),%edx
801018e8:	89 54 24 04          	mov    %edx,0x4(%esp)
801018ec:	89 04 24             	mov    %eax,(%esp)
801018ef:	e8 fc fc ff ff       	call   801015f0 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801018f4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018fb:	e9 98 00 00 00       	jmp    80101998 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101903:	c1 e8 03             	shr    $0x3,%eax
80101906:	83 c0 02             	add    $0x2,%eax
80101909:	89 44 24 04          	mov    %eax,0x4(%esp)
8010190d:	8b 45 08             	mov    0x8(%ebp),%eax
80101910:	89 04 24             	mov    %eax,(%esp)
80101913:	e8 8e e8 ff ff       	call   801001a6 <bread>
80101918:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010191b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191e:	8d 50 18             	lea    0x18(%eax),%edx
80101921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101924:	83 e0 07             	and    $0x7,%eax
80101927:	c1 e0 06             	shl    $0x6,%eax
8010192a:	01 d0                	add    %edx,%eax
8010192c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010192f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101932:	0f b7 00             	movzwl (%eax),%eax
80101935:	66 85 c0             	test   %ax,%ax
80101938:	75 4f                	jne    80101989 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010193a:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101941:	00 
80101942:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101949:	00 
8010194a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010194d:	89 04 24             	mov    %eax,(%esp)
80101950:	e8 e9 3a 00 00       	call   8010543e <memset>
      dip->type = type;
80101955:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101958:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
8010195c:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010195f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101962:	89 04 24             	mov    %eax,(%esp)
80101965:	e8 83 1c 00 00       	call   801035ed <log_write>
      brelse(bp);
8010196a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196d:	89 04 24             	mov    %eax,(%esp)
80101970:	e8 a2 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101978:	89 44 24 04          	mov    %eax,0x4(%esp)
8010197c:	8b 45 08             	mov    0x8(%ebp),%eax
8010197f:	89 04 24             	mov    %eax,(%esp)
80101982:	e8 e5 00 00 00       	call   80101a6c <iget>
80101987:	eb 29                	jmp    801019b2 <ialloc+0xdd>
    }
    brelse(bp);
80101989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198c:	89 04 24             	mov    %eax,(%esp)
8010198f:	e8 83 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101994:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101998:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010199b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010199e:	39 c2                	cmp    %eax,%edx
801019a0:	0f 82 5a ff ff ff    	jb     80101900 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801019a6:	c7 04 24 75 89 10 80 	movl   $0x80108975,(%esp)
801019ad:	e8 94 eb ff ff       	call   80100546 <panic>
}
801019b2:	c9                   	leave  
801019b3:	c3                   	ret    

801019b4 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801019b4:	55                   	push   %ebp
801019b5:	89 e5                	mov    %esp,%ebp
801019b7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	8b 40 04             	mov    0x4(%eax),%eax
801019c0:	c1 e8 03             	shr    $0x3,%eax
801019c3:	8d 50 02             	lea    0x2(%eax),%edx
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 00                	mov    (%eax),%eax
801019cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801019cf:	89 04 24             	mov    %eax,(%esp)
801019d2:	e8 cf e7 ff ff       	call   801001a6 <bread>
801019d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019dd:	8d 50 18             	lea    0x18(%eax),%edx
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	8b 40 04             	mov    0x4(%eax),%eax
801019e6:	83 e0 07             	and    $0x7,%eax
801019e9:	c1 e0 06             	shl    $0x6,%eax
801019ec:	01 d0                	add    %edx,%eax
801019ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801019f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019fb:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a08:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a16:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a24:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a28:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2b:	8b 50 18             	mov    0x18(%eax),%edx
80101a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a31:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3d:	83 c0 0c             	add    $0xc,%eax
80101a40:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a47:	00 
80101a48:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a4c:	89 04 24             	mov    %eax,(%esp)
80101a4f:	e8 bd 3a 00 00       	call   80105511 <memmove>
  log_write(bp);
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	89 04 24             	mov    %eax,(%esp)
80101a5a:	e8 8e 1b 00 00       	call   801035ed <log_write>
  brelse(bp);
80101a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a62:	89 04 24             	mov    %eax,(%esp)
80101a65:	e8 ad e7 ff ff       	call   80100217 <brelse>
}
80101a6a:	c9                   	leave  
80101a6b:	c3                   	ret    

80101a6c <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a6c:	55                   	push   %ebp
80101a6d:	89 e5                	mov    %esp,%ebp
80101a6f:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a72:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a79:	e8 65 37 00 00       	call   801051e3 <acquire>

  // Is the inode already cached?
  empty = 0;
80101a7e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a85:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101a8c:	eb 59                	jmp    80101ae7 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a91:	8b 40 08             	mov    0x8(%eax),%eax
80101a94:	85 c0                	test   %eax,%eax
80101a96:	7e 35                	jle    80101acd <iget+0x61>
80101a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9b:	8b 00                	mov    (%eax),%eax
80101a9d:	3b 45 08             	cmp    0x8(%ebp),%eax
80101aa0:	75 2b                	jne    80101acd <iget+0x61>
80101aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa5:	8b 40 04             	mov    0x4(%eax),%eax
80101aa8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101aab:	75 20                	jne    80101acd <iget+0x61>
      ip->ref++;
80101aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab0:	8b 40 08             	mov    0x8(%eax),%eax
80101ab3:	8d 50 01             	lea    0x1(%eax),%edx
80101ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab9:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101abc:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ac3:	e8 7d 37 00 00       	call   80105245 <release>
      return ip;
80101ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101acb:	eb 6f                	jmp    80101b3c <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101acd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ad1:	75 10                	jne    80101ae3 <iget+0x77>
80101ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad6:	8b 40 08             	mov    0x8(%eax),%eax
80101ad9:	85 c0                	test   %eax,%eax
80101adb:	75 06                	jne    80101ae3 <iget+0x77>
      empty = ip;
80101add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ae3:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101ae7:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101aee:	72 9e                	jb     80101a8e <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101af0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101af4:	75 0c                	jne    80101b02 <iget+0x96>
    panic("iget: no inodes");
80101af6:	c7 04 24 87 89 10 80 	movl   $0x80108987,(%esp)
80101afd:	e8 44 ea ff ff       	call   80100546 <panic>

  ip = empty;
80101b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b0b:	8b 55 08             	mov    0x8(%ebp),%edx
80101b0e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b13:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b16:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b1c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b26:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b2d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b34:	e8 0c 37 00 00       	call   80105245 <release>

  return ip;
80101b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b3c:	c9                   	leave  
80101b3d:	c3                   	ret    

80101b3e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b3e:	55                   	push   %ebp
80101b3f:	89 e5                	mov    %esp,%ebp
80101b41:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b44:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b4b:	e8 93 36 00 00       	call   801051e3 <acquire>
  ip->ref++;
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 08             	mov    0x8(%eax),%eax
80101b56:	8d 50 01             	lea    0x1(%eax),%edx
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b5f:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b66:	e8 da 36 00 00       	call   80105245 <release>
  return ip;
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b6e:	c9                   	leave  
80101b6f:	c3                   	ret    

80101b70 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b70:	55                   	push   %ebp
80101b71:	89 e5                	mov    %esp,%ebp
80101b73:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b76:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b7a:	74 0a                	je     80101b86 <ilock+0x16>
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	8b 40 08             	mov    0x8(%eax),%eax
80101b82:	85 c0                	test   %eax,%eax
80101b84:	7f 0c                	jg     80101b92 <ilock+0x22>
    panic("ilock");
80101b86:	c7 04 24 97 89 10 80 	movl   $0x80108997,(%esp)
80101b8d:	e8 b4 e9 ff ff       	call   80100546 <panic>

  acquire(&icache.lock);
80101b92:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b99:	e8 45 36 00 00       	call   801051e3 <acquire>
  while(ip->flags & I_BUSY)
80101b9e:	eb 13                	jmp    80101bb3 <ilock+0x43>
    sleep(ip, &icache.lock);
80101ba0:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101ba7:	80 
80101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bab:	89 04 24             	mov    %eax,(%esp)
80101bae:	e8 bb 32 00 00       	call   80104e6e <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb6:	8b 40 0c             	mov    0xc(%eax),%eax
80101bb9:	83 e0 01             	and    $0x1,%eax
80101bbc:	85 c0                	test   %eax,%eax
80101bbe:	75 e0                	jne    80101ba0 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc3:	8b 40 0c             	mov    0xc(%eax),%eax
80101bc6:	89 c2                	mov    %eax,%edx
80101bc8:	83 ca 01             	or     $0x1,%edx
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bce:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101bd1:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bd8:	e8 68 36 00 00       	call   80105245 <release>

  if(!(ip->flags & I_VALID)){
80101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101be0:	8b 40 0c             	mov    0xc(%eax),%eax
80101be3:	83 e0 02             	and    $0x2,%eax
80101be6:	85 c0                	test   %eax,%eax
80101be8:	0f 85 ce 00 00 00    	jne    80101cbc <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	8b 40 04             	mov    0x4(%eax),%eax
80101bf4:	c1 e8 03             	shr    $0x3,%eax
80101bf7:	8d 50 02             	lea    0x2(%eax),%edx
80101bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfd:	8b 00                	mov    (%eax),%eax
80101bff:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c03:	89 04 24             	mov    %eax,(%esp)
80101c06:	e8 9b e5 ff ff       	call   801001a6 <bread>
80101c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c11:	8d 50 18             	lea    0x18(%eax),%edx
80101c14:	8b 45 08             	mov    0x8(%ebp),%eax
80101c17:	8b 40 04             	mov    0x4(%eax),%eax
80101c1a:	83 e0 07             	and    $0x7,%eax
80101c1d:	c1 e0 06             	shl    $0x6,%eax
80101c20:	01 d0                	add    %edx,%eax
80101c22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c28:	0f b7 10             	movzwl (%eax),%edx
80101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2e:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c35:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c39:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c43:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c51:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c55:	8b 45 08             	mov    0x8(%ebp),%eax
80101c58:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5f:	8b 50 08             	mov    0x8(%eax),%edx
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6b:	8d 50 0c             	lea    0xc(%eax),%edx
80101c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c71:	83 c0 1c             	add    $0x1c,%eax
80101c74:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101c7b:	00 
80101c7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c80:	89 04 24             	mov    %eax,(%esp)
80101c83:	e8 89 38 00 00       	call   80105511 <memmove>
    brelse(bp);
80101c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c8b:	89 04 24             	mov    %eax,(%esp)
80101c8e:	e8 84 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	8b 40 0c             	mov    0xc(%eax),%eax
80101c99:	89 c2                	mov    %eax,%edx
80101c9b:	83 ca 02             	or     $0x2,%edx
80101c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca1:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101cab:	66 85 c0             	test   %ax,%ax
80101cae:	75 0c                	jne    80101cbc <ilock+0x14c>
      panic("ilock: no type");
80101cb0:	c7 04 24 9d 89 10 80 	movl   $0x8010899d,(%esp)
80101cb7:	e8 8a e8 ff ff       	call   80100546 <panic>
  }
}
80101cbc:	c9                   	leave  
80101cbd:	c3                   	ret    

80101cbe <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101cbe:	55                   	push   %ebp
80101cbf:	89 e5                	mov    %esp,%ebp
80101cc1:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101cc4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101cc8:	74 17                	je     80101ce1 <iunlock+0x23>
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 40 0c             	mov    0xc(%eax),%eax
80101cd0:	83 e0 01             	and    $0x1,%eax
80101cd3:	85 c0                	test   %eax,%eax
80101cd5:	74 0a                	je     80101ce1 <iunlock+0x23>
80101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cda:	8b 40 08             	mov    0x8(%eax),%eax
80101cdd:	85 c0                	test   %eax,%eax
80101cdf:	7f 0c                	jg     80101ced <iunlock+0x2f>
    panic("iunlock");
80101ce1:	c7 04 24 ac 89 10 80 	movl   $0x801089ac,(%esp)
80101ce8:	e8 59 e8 ff ff       	call   80100546 <panic>

  acquire(&icache.lock);
80101ced:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101cf4:	e8 ea 34 00 00       	call   801051e3 <acquire>
  ip->flags &= ~I_BUSY;
80101cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfc:	8b 40 0c             	mov    0xc(%eax),%eax
80101cff:	89 c2                	mov    %eax,%edx
80101d01:	83 e2 fe             	and    $0xfffffffe,%edx
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	89 04 24             	mov    %eax,(%esp)
80101d10:	e8 35 32 00 00       	call   80104f4a <wakeup>
  release(&icache.lock);
80101d15:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d1c:	e8 24 35 00 00       	call   80105245 <release>
}
80101d21:	c9                   	leave  
80101d22:	c3                   	ret    

80101d23 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d23:	55                   	push   %ebp
80101d24:	89 e5                	mov    %esp,%ebp
80101d26:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d29:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d30:	e8 ae 34 00 00       	call   801051e3 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 40 08             	mov    0x8(%eax),%eax
80101d3b:	83 f8 01             	cmp    $0x1,%eax
80101d3e:	0f 85 93 00 00 00    	jne    80101dd7 <iput+0xb4>
80101d44:	8b 45 08             	mov    0x8(%ebp),%eax
80101d47:	8b 40 0c             	mov    0xc(%eax),%eax
80101d4a:	83 e0 02             	and    $0x2,%eax
80101d4d:	85 c0                	test   %eax,%eax
80101d4f:	0f 84 82 00 00 00    	je     80101dd7 <iput+0xb4>
80101d55:	8b 45 08             	mov    0x8(%ebp),%eax
80101d58:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d5c:	66 85 c0             	test   %ax,%ax
80101d5f:	75 76                	jne    80101dd7 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101d61:	8b 45 08             	mov    0x8(%ebp),%eax
80101d64:	8b 40 0c             	mov    0xc(%eax),%eax
80101d67:	83 e0 01             	and    $0x1,%eax
80101d6a:	85 c0                	test   %eax,%eax
80101d6c:	74 0c                	je     80101d7a <iput+0x57>
      panic("iput busy");
80101d6e:	c7 04 24 b4 89 10 80 	movl   $0x801089b4,(%esp)
80101d75:	e8 cc e7 ff ff       	call   80100546 <panic>
    ip->flags |= I_BUSY;
80101d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7d:	8b 40 0c             	mov    0xc(%eax),%eax
80101d80:	89 c2                	mov    %eax,%edx
80101d82:	83 ca 01             	or     $0x1,%edx
80101d85:	8b 45 08             	mov    0x8(%ebp),%eax
80101d88:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101d8b:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d92:	e8 ae 34 00 00       	call   80105245 <release>
    itrunc(ip);
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	89 04 24             	mov    %eax,(%esp)
80101d9d:	e8 7d 01 00 00       	call   80101f1f <itrunc>
    ip->type = 0;
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101dab:	8b 45 08             	mov    0x8(%ebp),%eax
80101dae:	89 04 24             	mov    %eax,(%esp)
80101db1:	e8 fe fb ff ff       	call   801019b4 <iupdate>
    acquire(&icache.lock);
80101db6:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101dbd:	e8 21 34 00 00       	call   801051e3 <acquire>
    ip->flags = 0;
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcf:	89 04 24             	mov    %eax,(%esp)
80101dd2:	e8 73 31 00 00       	call   80104f4a <wakeup>
  }
  ip->ref--;
80101dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dda:	8b 40 08             	mov    0x8(%eax),%eax
80101ddd:	8d 50 ff             	lea    -0x1(%eax),%edx
80101de0:	8b 45 08             	mov    0x8(%ebp),%eax
80101de3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101de6:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ded:	e8 53 34 00 00       	call   80105245 <release>
}
80101df2:	c9                   	leave  
80101df3:	c3                   	ret    

80101df4 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101df4:	55                   	push   %ebp
80101df5:	89 e5                	mov    %esp,%ebp
80101df7:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfd:	89 04 24             	mov    %eax,(%esp)
80101e00:	e8 b9 fe ff ff       	call   80101cbe <iunlock>
  iput(ip);
80101e05:	8b 45 08             	mov    0x8(%ebp),%eax
80101e08:	89 04 24             	mov    %eax,(%esp)
80101e0b:	e8 13 ff ff ff       	call   80101d23 <iput>
}
80101e10:	c9                   	leave  
80101e11:	c3                   	ret    

80101e12 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e12:	55                   	push   %ebp
80101e13:	89 e5                	mov    %esp,%ebp
80101e15:	53                   	push   %ebx
80101e16:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e19:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e1d:	77 3e                	ja     80101e5d <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e22:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e25:	83 c2 04             	add    $0x4,%edx
80101e28:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e33:	75 20                	jne    80101e55 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e35:	8b 45 08             	mov    0x8(%ebp),%eax
80101e38:	8b 00                	mov    (%eax),%eax
80101e3a:	89 04 24             	mov    %eax,(%esp)
80101e3d:	e8 45 f8 ff ff       	call   80101687 <balloc>
80101e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e45:	8b 45 08             	mov    0x8(%ebp),%eax
80101e48:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e4b:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e51:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e58:	e9 bc 00 00 00       	jmp    80101f19 <bmap+0x107>
  }
  bn -= NDIRECT;
80101e5d:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e61:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e65:	0f 87 a2 00 00 00    	ja     80101f0d <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e78:	75 19                	jne    80101e93 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7d:	8b 00                	mov    (%eax),%eax
80101e7f:	89 04 24             	mov    %eax,(%esp)
80101e82:	e8 00 f8 ff ff       	call   80101687 <balloc>
80101e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e90:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e9f:	89 04 24             	mov    %eax,(%esp)
80101ea2:	e8 ff e2 ff ff       	call   801001a6 <bread>
80101ea7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ead:	83 c0 18             	add    $0x18,%eax
80101eb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ebd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec0:	01 d0                	add    %edx,%eax
80101ec2:	8b 00                	mov    (%eax),%eax
80101ec4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ec7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ecb:	75 30                	jne    80101efd <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ed7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eda:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	8b 00                	mov    (%eax),%eax
80101ee2:	89 04 24             	mov    %eax,(%esp)
80101ee5:	e8 9d f7 ff ff       	call   80101687 <balloc>
80101eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef0:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef5:	89 04 24             	mov    %eax,(%esp)
80101ef8:	e8 f0 16 00 00       	call   801035ed <log_write>
    }
    brelse(bp);
80101efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f00:	89 04 24             	mov    %eax,(%esp)
80101f03:	e8 0f e3 ff ff       	call   80100217 <brelse>
    return addr;
80101f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f0b:	eb 0c                	jmp    80101f19 <bmap+0x107>
  }

  panic("bmap: out of range");
80101f0d:	c7 04 24 be 89 10 80 	movl   $0x801089be,(%esp)
80101f14:	e8 2d e6 ff ff       	call   80100546 <panic>
}
80101f19:	83 c4 24             	add    $0x24,%esp
80101f1c:	5b                   	pop    %ebx
80101f1d:	5d                   	pop    %ebp
80101f1e:	c3                   	ret    

80101f1f <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f1f:	55                   	push   %ebp
80101f20:	89 e5                	mov    %esp,%ebp
80101f22:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f2c:	eb 44                	jmp    80101f72 <itrunc+0x53>
    if(ip->addrs[i]){
80101f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f31:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f34:	83 c2 04             	add    $0x4,%edx
80101f37:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f3b:	85 c0                	test   %eax,%eax
80101f3d:	74 2f                	je     80101f6e <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f45:	83 c2 04             	add    $0x4,%edx
80101f48:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4f:	8b 00                	mov    (%eax),%eax
80101f51:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f55:	89 04 24             	mov    %eax,(%esp)
80101f58:	e8 83 f8 ff ff       	call   801017e0 <bfree>
      ip->addrs[i] = 0;
80101f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f63:	83 c2 04             	add    $0x4,%edx
80101f66:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f6d:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f72:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f76:	7e b6                	jle    80101f2e <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f78:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7b:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f7e:	85 c0                	test   %eax,%eax
80101f80:	0f 84 9b 00 00 00    	je     80102021 <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f86:	8b 45 08             	mov    0x8(%ebp),%eax
80101f89:	8b 50 4c             	mov    0x4c(%eax),%edx
80101f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8f:	8b 00                	mov    (%eax),%eax
80101f91:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f95:	89 04 24             	mov    %eax,(%esp)
80101f98:	e8 09 e2 ff ff       	call   801001a6 <bread>
80101f9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fa3:	83 c0 18             	add    $0x18,%eax
80101fa6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101fa9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101fb0:	eb 3b                	jmp    80101fed <itrunc+0xce>
      if(a[j])
80101fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fb5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fbf:	01 d0                	add    %edx,%eax
80101fc1:	8b 00                	mov    (%eax),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	74 22                	je     80101fe9 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fd4:	01 d0                	add    %edx,%eax
80101fd6:	8b 10                	mov    (%eax),%edx
80101fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdb:	8b 00                	mov    (%eax),%eax
80101fdd:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fe1:	89 04 24             	mov    %eax,(%esp)
80101fe4:	e8 f7 f7 ff ff       	call   801017e0 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101fe9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff0:	83 f8 7f             	cmp    $0x7f,%eax
80101ff3:	76 bd                	jbe    80101fb2 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ff5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff8:	89 04 24             	mov    %eax,(%esp)
80101ffb:	e8 17 e2 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102000:	8b 45 08             	mov    0x8(%ebp),%eax
80102003:	8b 50 4c             	mov    0x4c(%eax),%edx
80102006:	8b 45 08             	mov    0x8(%ebp),%eax
80102009:	8b 00                	mov    (%eax),%eax
8010200b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010200f:	89 04 24             	mov    %eax,(%esp)
80102012:	e8 c9 f7 ff ff       	call   801017e0 <bfree>
    ip->addrs[NDIRECT] = 0;
80102017:	8b 45 08             	mov    0x8(%ebp),%eax
8010201a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	89 04 24             	mov    %eax,(%esp)
80102031:	e8 7e f9 ff ff       	call   801019b4 <iupdate>
}
80102036:	c9                   	leave  
80102037:	c3                   	ret    

80102038 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102038:	55                   	push   %ebp
80102039:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	8b 00                	mov    (%eax),%eax
80102040:	89 c2                	mov    %eax,%edx
80102042:	8b 45 0c             	mov    0xc(%ebp),%eax
80102045:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102048:	8b 45 08             	mov    0x8(%ebp),%eax
8010204b:	8b 50 04             	mov    0x4(%eax),%edx
8010204e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102051:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102054:	8b 45 08             	mov    0x8(%ebp),%eax
80102057:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010205b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205e:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102068:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206b:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010206f:	8b 45 08             	mov    0x8(%ebp),%eax
80102072:	8b 50 18             	mov    0x18(%eax),%edx
80102075:	8b 45 0c             	mov    0xc(%ebp),%eax
80102078:	89 50 10             	mov    %edx,0x10(%eax)
}
8010207b:	5d                   	pop    %ebp
8010207c:	c3                   	ret    

8010207d <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010207d:	55                   	push   %ebp
8010207e:	89 e5                	mov    %esp,%ebp
80102080:	53                   	push   %ebx
80102081:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010208b:	66 83 f8 03          	cmp    $0x3,%ax
8010208f:	75 60                	jne    801020f1 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102091:	8b 45 08             	mov    0x8(%ebp),%eax
80102094:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102098:	66 85 c0             	test   %ax,%ax
8010209b:	78 20                	js     801020bd <readi+0x40>
8010209d:	8b 45 08             	mov    0x8(%ebp),%eax
801020a0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020a4:	66 83 f8 09          	cmp    $0x9,%ax
801020a8:	7f 13                	jg     801020bd <readi+0x40>
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020b1:	98                   	cwtl   
801020b2:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020b9:	85 c0                	test   %eax,%eax
801020bb:	75 0a                	jne    801020c7 <readi+0x4a>
      return -1;
801020bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c2:	e9 1e 01 00 00       	jmp    801021e5 <readi+0x168>
    return devsw[ip->major].read(ip, dst, n);
801020c7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ca:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ce:	98                   	cwtl   
801020cf:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020d6:	8b 55 14             	mov    0x14(%ebp),%edx
801020d9:	89 54 24 08          	mov    %edx,0x8(%esp)
801020dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801020e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801020e4:	8b 55 08             	mov    0x8(%ebp),%edx
801020e7:	89 14 24             	mov    %edx,(%esp)
801020ea:	ff d0                	call   *%eax
801020ec:	e9 f4 00 00 00       	jmp    801021e5 <readi+0x168>
  }

  if(off > ip->size || off + n < off)
801020f1:	8b 45 08             	mov    0x8(%ebp),%eax
801020f4:	8b 40 18             	mov    0x18(%eax),%eax
801020f7:	3b 45 10             	cmp    0x10(%ebp),%eax
801020fa:	72 0d                	jb     80102109 <readi+0x8c>
801020fc:	8b 45 14             	mov    0x14(%ebp),%eax
801020ff:	8b 55 10             	mov    0x10(%ebp),%edx
80102102:	01 d0                	add    %edx,%eax
80102104:	3b 45 10             	cmp    0x10(%ebp),%eax
80102107:	73 0a                	jae    80102113 <readi+0x96>
    return -1;
80102109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010210e:	e9 d2 00 00 00       	jmp    801021e5 <readi+0x168>
  if(off + n > ip->size)
80102113:	8b 45 14             	mov    0x14(%ebp),%eax
80102116:	8b 55 10             	mov    0x10(%ebp),%edx
80102119:	01 c2                	add    %eax,%edx
8010211b:	8b 45 08             	mov    0x8(%ebp),%eax
8010211e:	8b 40 18             	mov    0x18(%eax),%eax
80102121:	39 c2                	cmp    %eax,%edx
80102123:	76 0c                	jbe    80102131 <readi+0xb4>
    n = ip->size - off;
80102125:	8b 45 08             	mov    0x8(%ebp),%eax
80102128:	8b 40 18             	mov    0x18(%eax),%eax
8010212b:	2b 45 10             	sub    0x10(%ebp),%eax
8010212e:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102131:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102138:	e9 99 00 00 00       	jmp    801021d6 <readi+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010213d:	8b 45 10             	mov    0x10(%ebp),%eax
80102140:	c1 e8 09             	shr    $0x9,%eax
80102143:	89 44 24 04          	mov    %eax,0x4(%esp)
80102147:	8b 45 08             	mov    0x8(%ebp),%eax
8010214a:	89 04 24             	mov    %eax,(%esp)
8010214d:	e8 c0 fc ff ff       	call   80101e12 <bmap>
80102152:	8b 55 08             	mov    0x8(%ebp),%edx
80102155:	8b 12                	mov    (%edx),%edx
80102157:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215b:	89 14 24             	mov    %edx,(%esp)
8010215e:	e8 43 e0 ff ff       	call   801001a6 <bread>
80102163:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102166:	8b 45 10             	mov    0x10(%ebp),%eax
80102169:	89 c2                	mov    %eax,%edx
8010216b:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102171:	b8 00 02 00 00       	mov    $0x200,%eax
80102176:	89 c1                	mov    %eax,%ecx
80102178:	29 d1                	sub    %edx,%ecx
8010217a:	89 ca                	mov    %ecx,%edx
8010217c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217f:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102182:	89 cb                	mov    %ecx,%ebx
80102184:	29 c3                	sub    %eax,%ebx
80102186:	89 d8                	mov    %ebx,%eax
80102188:	39 c2                	cmp    %eax,%edx
8010218a:	0f 46 c2             	cmovbe %edx,%eax
8010218d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102190:	8b 45 10             	mov    0x10(%ebp),%eax
80102193:	25 ff 01 00 00       	and    $0x1ff,%eax
80102198:	8d 50 10             	lea    0x10(%eax),%edx
8010219b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010219e:	01 d0                	add    %edx,%eax
801021a0:	8d 50 08             	lea    0x8(%eax),%edx
801021a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021a6:	89 44 24 08          	mov    %eax,0x8(%esp)
801021aa:	89 54 24 04          	mov    %edx,0x4(%esp)
801021ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801021b1:	89 04 24             	mov    %eax,(%esp)
801021b4:	e8 58 33 00 00       	call   80105511 <memmove>
    brelse(bp);
801021b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021bc:	89 04 24             	mov    %eax,(%esp)
801021bf:	e8 53 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021c7:	01 45 f4             	add    %eax,-0xc(%ebp)
801021ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021cd:	01 45 10             	add    %eax,0x10(%ebp)
801021d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d3:	01 45 0c             	add    %eax,0xc(%ebp)
801021d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021d9:	3b 45 14             	cmp    0x14(%ebp),%eax
801021dc:	0f 82 5b ff ff ff    	jb     8010213d <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801021e2:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021e5:	83 c4 24             	add    $0x24,%esp
801021e8:	5b                   	pop    %ebx
801021e9:	5d                   	pop    %ebp
801021ea:	c3                   	ret    

801021eb <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021eb:	55                   	push   %ebp
801021ec:	89 e5                	mov    %esp,%ebp
801021ee:	53                   	push   %ebx
801021ef:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021f2:	8b 45 08             	mov    0x8(%ebp),%eax
801021f5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021f9:	66 83 f8 03          	cmp    $0x3,%ax
801021fd:	75 60                	jne    8010225f <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102202:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102206:	66 85 c0             	test   %ax,%ax
80102209:	78 20                	js     8010222b <writei+0x40>
8010220b:	8b 45 08             	mov    0x8(%ebp),%eax
8010220e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102212:	66 83 f8 09          	cmp    $0x9,%ax
80102216:	7f 13                	jg     8010222b <writei+0x40>
80102218:	8b 45 08             	mov    0x8(%ebp),%eax
8010221b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010221f:	98                   	cwtl   
80102220:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80102227:	85 c0                	test   %eax,%eax
80102229:	75 0a                	jne    80102235 <writei+0x4a>
      return -1;
8010222b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102230:	e9 49 01 00 00       	jmp    8010237e <writei+0x193>
    return devsw[ip->major].write(ip, src, n);
80102235:	8b 45 08             	mov    0x8(%ebp),%eax
80102238:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010223c:	98                   	cwtl   
8010223d:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80102244:	8b 55 14             	mov    0x14(%ebp),%edx
80102247:	89 54 24 08          	mov    %edx,0x8(%esp)
8010224b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010224e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102252:	8b 55 08             	mov    0x8(%ebp),%edx
80102255:	89 14 24             	mov    %edx,(%esp)
80102258:	ff d0                	call   *%eax
8010225a:	e9 1f 01 00 00       	jmp    8010237e <writei+0x193>
  }

  if(off > ip->size || off + n < off)
8010225f:	8b 45 08             	mov    0x8(%ebp),%eax
80102262:	8b 40 18             	mov    0x18(%eax),%eax
80102265:	3b 45 10             	cmp    0x10(%ebp),%eax
80102268:	72 0d                	jb     80102277 <writei+0x8c>
8010226a:	8b 45 14             	mov    0x14(%ebp),%eax
8010226d:	8b 55 10             	mov    0x10(%ebp),%edx
80102270:	01 d0                	add    %edx,%eax
80102272:	3b 45 10             	cmp    0x10(%ebp),%eax
80102275:	73 0a                	jae    80102281 <writei+0x96>
    return -1;
80102277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010227c:	e9 fd 00 00 00       	jmp    8010237e <writei+0x193>
  if(off + n > MAXFILE*BSIZE)
80102281:	8b 45 14             	mov    0x14(%ebp),%eax
80102284:	8b 55 10             	mov    0x10(%ebp),%edx
80102287:	01 d0                	add    %edx,%eax
80102289:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010228e:	76 0a                	jbe    8010229a <writei+0xaf>
    return -1;
80102290:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102295:	e9 e4 00 00 00       	jmp    8010237e <writei+0x193>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010229a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a1:	e9 a4 00 00 00       	jmp    8010234a <writei+0x15f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022a6:	8b 45 10             	mov    0x10(%ebp),%eax
801022a9:	c1 e8 09             	shr    $0x9,%eax
801022ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801022b0:	8b 45 08             	mov    0x8(%ebp),%eax
801022b3:	89 04 24             	mov    %eax,(%esp)
801022b6:	e8 57 fb ff ff       	call   80101e12 <bmap>
801022bb:	8b 55 08             	mov    0x8(%ebp),%edx
801022be:	8b 12                	mov    (%edx),%edx
801022c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801022c4:	89 14 24             	mov    %edx,(%esp)
801022c7:	e8 da de ff ff       	call   801001a6 <bread>
801022cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022cf:	8b 45 10             	mov    0x10(%ebp),%eax
801022d2:	89 c2                	mov    %eax,%edx
801022d4:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801022da:	b8 00 02 00 00       	mov    $0x200,%eax
801022df:	89 c1                	mov    %eax,%ecx
801022e1:	29 d1                	sub    %edx,%ecx
801022e3:	89 ca                	mov    %ecx,%edx
801022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e8:	8b 4d 14             	mov    0x14(%ebp),%ecx
801022eb:	89 cb                	mov    %ecx,%ebx
801022ed:	29 c3                	sub    %eax,%ebx
801022ef:	89 d8                	mov    %ebx,%eax
801022f1:	39 c2                	cmp    %eax,%edx
801022f3:	0f 46 c2             	cmovbe %edx,%eax
801022f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022f9:	8b 45 10             	mov    0x10(%ebp),%eax
801022fc:	25 ff 01 00 00       	and    $0x1ff,%eax
80102301:	8d 50 10             	lea    0x10(%eax),%edx
80102304:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102307:	01 d0                	add    %edx,%eax
80102309:	8d 50 08             	lea    0x8(%eax),%edx
8010230c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010230f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102313:	8b 45 0c             	mov    0xc(%ebp),%eax
80102316:	89 44 24 04          	mov    %eax,0x4(%esp)
8010231a:	89 14 24             	mov    %edx,(%esp)
8010231d:	e8 ef 31 00 00       	call   80105511 <memmove>
    log_write(bp);
80102322:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102325:	89 04 24             	mov    %eax,(%esp)
80102328:	e8 c0 12 00 00       	call   801035ed <log_write>
    brelse(bp);
8010232d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102330:	89 04 24             	mov    %eax,(%esp)
80102333:	e8 df de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102338:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010233b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010233e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102341:	01 45 10             	add    %eax,0x10(%ebp)
80102344:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102347:	01 45 0c             	add    %eax,0xc(%ebp)
8010234a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102350:	0f 82 50 ff ff ff    	jb     801022a6 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102356:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010235a:	74 1f                	je     8010237b <writei+0x190>
8010235c:	8b 45 08             	mov    0x8(%ebp),%eax
8010235f:	8b 40 18             	mov    0x18(%eax),%eax
80102362:	3b 45 10             	cmp    0x10(%ebp),%eax
80102365:	73 14                	jae    8010237b <writei+0x190>
    ip->size = off;
80102367:	8b 45 08             	mov    0x8(%ebp),%eax
8010236a:	8b 55 10             	mov    0x10(%ebp),%edx
8010236d:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	89 04 24             	mov    %eax,(%esp)
80102376:	e8 39 f6 ff ff       	call   801019b4 <iupdate>
  }
  return n;
8010237b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010237e:	83 c4 24             	add    $0x24,%esp
80102381:	5b                   	pop    %ebx
80102382:	5d                   	pop    %ebp
80102383:	c3                   	ret    

80102384 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102384:	55                   	push   %ebp
80102385:	89 e5                	mov    %esp,%ebp
80102387:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010238a:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102391:	00 
80102392:	8b 45 0c             	mov    0xc(%ebp),%eax
80102395:	89 44 24 04          	mov    %eax,0x4(%esp)
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	89 04 24             	mov    %eax,(%esp)
8010239f:	e8 11 32 00 00       	call   801055b5 <strncmp>
}
801023a4:	c9                   	leave  
801023a5:	c3                   	ret    

801023a6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023a6:	55                   	push   %ebp
801023a7:	89 e5                	mov    %esp,%ebp
801023a9:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023ac:	8b 45 08             	mov    0x8(%ebp),%eax
801023af:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023b3:	66 83 f8 01          	cmp    $0x1,%ax
801023b7:	74 0c                	je     801023c5 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801023b9:	c7 04 24 d1 89 10 80 	movl   $0x801089d1,(%esp)
801023c0:	e8 81 e1 ff ff       	call   80100546 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023cc:	e9 87 00 00 00       	jmp    80102458 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023d1:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023d8:	00 
801023d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023dc:	89 44 24 08          	mov    %eax,0x8(%esp)
801023e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ea:	89 04 24             	mov    %eax,(%esp)
801023ed:	e8 8b fc ff ff       	call   8010207d <readi>
801023f2:	83 f8 10             	cmp    $0x10,%eax
801023f5:	74 0c                	je     80102403 <dirlookup+0x5d>
      panic("dirlink read");
801023f7:	c7 04 24 e3 89 10 80 	movl   $0x801089e3,(%esp)
801023fe:	e8 43 e1 ff ff       	call   80100546 <panic>
    if(de.inum == 0)
80102403:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102407:	66 85 c0             	test   %ax,%ax
8010240a:	74 47                	je     80102453 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010240c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010240f:	83 c0 02             	add    $0x2,%eax
80102412:	89 44 24 04          	mov    %eax,0x4(%esp)
80102416:	8b 45 0c             	mov    0xc(%ebp),%eax
80102419:	89 04 24             	mov    %eax,(%esp)
8010241c:	e8 63 ff ff ff       	call   80102384 <namecmp>
80102421:	85 c0                	test   %eax,%eax
80102423:	75 2f                	jne    80102454 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102425:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102429:	74 08                	je     80102433 <dirlookup+0x8d>
        *poff = off;
8010242b:	8b 45 10             	mov    0x10(%ebp),%eax
8010242e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102431:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102433:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102437:	0f b7 c0             	movzwl %ax,%eax
8010243a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	8b 00                	mov    (%eax),%eax
80102442:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102445:	89 54 24 04          	mov    %edx,0x4(%esp)
80102449:	89 04 24             	mov    %eax,(%esp)
8010244c:	e8 1b f6 ff ff       	call   80101a6c <iget>
80102451:	eb 19                	jmp    8010246c <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102453:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102454:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102458:	8b 45 08             	mov    0x8(%ebp),%eax
8010245b:	8b 40 18             	mov    0x18(%eax),%eax
8010245e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102461:	0f 87 6a ff ff ff    	ja     801023d1 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102467:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010246c:	c9                   	leave  
8010246d:	c3                   	ret    

8010246e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010246e:	55                   	push   %ebp
8010246f:	89 e5                	mov    %esp,%ebp
80102471:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102474:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010247b:	00 
8010247c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010247f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102483:	8b 45 08             	mov    0x8(%ebp),%eax
80102486:	89 04 24             	mov    %eax,(%esp)
80102489:	e8 18 ff ff ff       	call   801023a6 <dirlookup>
8010248e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102491:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102495:	74 15                	je     801024ac <dirlink+0x3e>
    iput(ip);
80102497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010249a:	89 04 24             	mov    %eax,(%esp)
8010249d:	e8 81 f8 ff ff       	call   80101d23 <iput>
    return -1;
801024a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024a7:	e9 b8 00 00 00       	jmp    80102564 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024b3:	eb 44                	jmp    801024f9 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024bf:	00 
801024c0:	89 44 24 08          	mov    %eax,0x8(%esp)
801024c4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801024cb:	8b 45 08             	mov    0x8(%ebp),%eax
801024ce:	89 04 24             	mov    %eax,(%esp)
801024d1:	e8 a7 fb ff ff       	call   8010207d <readi>
801024d6:	83 f8 10             	cmp    $0x10,%eax
801024d9:	74 0c                	je     801024e7 <dirlink+0x79>
      panic("dirlink read");
801024db:	c7 04 24 e3 89 10 80 	movl   $0x801089e3,(%esp)
801024e2:	e8 5f e0 ff ff       	call   80100546 <panic>
    if(de.inum == 0)
801024e7:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024eb:	66 85 c0             	test   %ax,%ax
801024ee:	74 18                	je     80102508 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f3:	83 c0 10             	add    $0x10,%eax
801024f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024fc:	8b 45 08             	mov    0x8(%ebp),%eax
801024ff:	8b 40 18             	mov    0x18(%eax),%eax
80102502:	39 c2                	cmp    %eax,%edx
80102504:	72 af                	jb     801024b5 <dirlink+0x47>
80102506:	eb 01                	jmp    80102509 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102508:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102509:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102510:	00 
80102511:	8b 45 0c             	mov    0xc(%ebp),%eax
80102514:	89 44 24 04          	mov    %eax,0x4(%esp)
80102518:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010251b:	83 c0 02             	add    $0x2,%eax
8010251e:	89 04 24             	mov    %eax,(%esp)
80102521:	e8 e7 30 00 00       	call   8010560d <strncpy>
  de.inum = inum;
80102526:	8b 45 10             	mov    0x10(%ebp),%eax
80102529:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010252d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102530:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102537:	00 
80102538:	89 44 24 08          	mov    %eax,0x8(%esp)
8010253c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010253f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102543:	8b 45 08             	mov    0x8(%ebp),%eax
80102546:	89 04 24             	mov    %eax,(%esp)
80102549:	e8 9d fc ff ff       	call   801021eb <writei>
8010254e:	83 f8 10             	cmp    $0x10,%eax
80102551:	74 0c                	je     8010255f <dirlink+0xf1>
    panic("dirlink");
80102553:	c7 04 24 f0 89 10 80 	movl   $0x801089f0,(%esp)
8010255a:	e8 e7 df ff ff       	call   80100546 <panic>
  
  return 0;
8010255f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102564:	c9                   	leave  
80102565:	c3                   	ret    

80102566 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102566:	55                   	push   %ebp
80102567:	89 e5                	mov    %esp,%ebp
80102569:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010256c:	eb 04                	jmp    80102572 <skipelem+0xc>
    path++;
8010256e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102572:	8b 45 08             	mov    0x8(%ebp),%eax
80102575:	0f b6 00             	movzbl (%eax),%eax
80102578:	3c 2f                	cmp    $0x2f,%al
8010257a:	74 f2                	je     8010256e <skipelem+0x8>
    path++;
  if(*path == 0)
8010257c:	8b 45 08             	mov    0x8(%ebp),%eax
8010257f:	0f b6 00             	movzbl (%eax),%eax
80102582:	84 c0                	test   %al,%al
80102584:	75 0a                	jne    80102590 <skipelem+0x2a>
    return 0;
80102586:	b8 00 00 00 00       	mov    $0x0,%eax
8010258b:	e9 88 00 00 00       	jmp    80102618 <skipelem+0xb2>
  s = path;
80102590:	8b 45 08             	mov    0x8(%ebp),%eax
80102593:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102596:	eb 04                	jmp    8010259c <skipelem+0x36>
    path++;
80102598:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010259c:	8b 45 08             	mov    0x8(%ebp),%eax
8010259f:	0f b6 00             	movzbl (%eax),%eax
801025a2:	3c 2f                	cmp    $0x2f,%al
801025a4:	74 0a                	je     801025b0 <skipelem+0x4a>
801025a6:	8b 45 08             	mov    0x8(%ebp),%eax
801025a9:	0f b6 00             	movzbl (%eax),%eax
801025ac:	84 c0                	test   %al,%al
801025ae:	75 e8                	jne    80102598 <skipelem+0x32>
    path++;
  len = path - s;
801025b0:	8b 55 08             	mov    0x8(%ebp),%edx
801025b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025b6:	89 d1                	mov    %edx,%ecx
801025b8:	29 c1                	sub    %eax,%ecx
801025ba:	89 c8                	mov    %ecx,%eax
801025bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801025bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801025c3:	7e 1c                	jle    801025e1 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801025c5:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801025cc:	00 
801025cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801025d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801025d7:	89 04 24             	mov    %eax,(%esp)
801025da:	e8 32 2f 00 00       	call   80105511 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025df:	eb 2a                	jmp    8010260b <skipelem+0xa5>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801025e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025e4:	89 44 24 08          	mov    %eax,0x8(%esp)
801025e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801025ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801025f2:	89 04 24             	mov    %eax,(%esp)
801025f5:	e8 17 2f 00 00       	call   80105511 <memmove>
    name[len] = 0;
801025fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801025fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102600:	01 d0                	add    %edx,%eax
80102602:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102605:	eb 04                	jmp    8010260b <skipelem+0xa5>
    path++;
80102607:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010260b:	8b 45 08             	mov    0x8(%ebp),%eax
8010260e:	0f b6 00             	movzbl (%eax),%eax
80102611:	3c 2f                	cmp    $0x2f,%al
80102613:	74 f2                	je     80102607 <skipelem+0xa1>
    path++;
  return path;
80102615:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102618:	c9                   	leave  
80102619:	c3                   	ret    

8010261a <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010261a:	55                   	push   %ebp
8010261b:	89 e5                	mov    %esp,%ebp
8010261d:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102620:	8b 45 08             	mov    0x8(%ebp),%eax
80102623:	0f b6 00             	movzbl (%eax),%eax
80102626:	3c 2f                	cmp    $0x2f,%al
80102628:	75 1c                	jne    80102646 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010262a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102631:	00 
80102632:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102639:	e8 2e f4 ff ff       	call   80101a6c <iget>
8010263e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102641:	e9 af 00 00 00       	jmp    801026f5 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010264c:	8b 40 68             	mov    0x68(%eax),%eax
8010264f:	89 04 24             	mov    %eax,(%esp)
80102652:	e8 e7 f4 ff ff       	call   80101b3e <idup>
80102657:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010265a:	e9 96 00 00 00       	jmp    801026f5 <namex+0xdb>
    ilock(ip);
8010265f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102662:	89 04 24             	mov    %eax,(%esp)
80102665:	e8 06 f5 ff ff       	call   80101b70 <ilock>
    if(ip->type != T_DIR){
8010266a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010266d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102671:	66 83 f8 01          	cmp    $0x1,%ax
80102675:	74 15                	je     8010268c <namex+0x72>
      iunlockput(ip);
80102677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010267a:	89 04 24             	mov    %eax,(%esp)
8010267d:	e8 72 f7 ff ff       	call   80101df4 <iunlockput>
      return 0;
80102682:	b8 00 00 00 00       	mov    $0x0,%eax
80102687:	e9 a3 00 00 00       	jmp    8010272f <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010268c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102690:	74 1d                	je     801026af <namex+0x95>
80102692:	8b 45 08             	mov    0x8(%ebp),%eax
80102695:	0f b6 00             	movzbl (%eax),%eax
80102698:	84 c0                	test   %al,%al
8010269a:	75 13                	jne    801026af <namex+0x95>
      // Stop one level early.
      iunlock(ip);
8010269c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269f:	89 04 24             	mov    %eax,(%esp)
801026a2:	e8 17 f6 ff ff       	call   80101cbe <iunlock>
      return ip;
801026a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026aa:	e9 80 00 00 00       	jmp    8010272f <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026b6:	00 
801026b7:	8b 45 10             	mov    0x10(%ebp),%eax
801026ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801026be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c1:	89 04 24             	mov    %eax,(%esp)
801026c4:	e8 dd fc ff ff       	call   801023a6 <dirlookup>
801026c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801026cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026d0:	75 12                	jne    801026e4 <namex+0xca>
      iunlockput(ip);
801026d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d5:	89 04 24             	mov    %eax,(%esp)
801026d8:	e8 17 f7 ff ff       	call   80101df4 <iunlockput>
      return 0;
801026dd:	b8 00 00 00 00       	mov    $0x0,%eax
801026e2:	eb 4b                	jmp    8010272f <namex+0x115>
    }
    iunlockput(ip);
801026e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e7:	89 04 24             	mov    %eax,(%esp)
801026ea:	e8 05 f7 ff ff       	call   80101df4 <iunlockput>
    ip = next;
801026ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801026f5:	8b 45 10             	mov    0x10(%ebp),%eax
801026f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801026fc:	8b 45 08             	mov    0x8(%ebp),%eax
801026ff:	89 04 24             	mov    %eax,(%esp)
80102702:	e8 5f fe ff ff       	call   80102566 <skipelem>
80102707:	89 45 08             	mov    %eax,0x8(%ebp)
8010270a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010270e:	0f 85 4b ff ff ff    	jne    8010265f <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102714:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102718:	74 12                	je     8010272c <namex+0x112>
    iput(ip);
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	89 04 24             	mov    %eax,(%esp)
80102720:	e8 fe f5 ff ff       	call   80101d23 <iput>
    return 0;
80102725:	b8 00 00 00 00       	mov    $0x0,%eax
8010272a:	eb 03                	jmp    8010272f <namex+0x115>
  }
  return ip;
8010272c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010272f:	c9                   	leave  
80102730:	c3                   	ret    

80102731 <namei>:

struct inode*
namei(char *path)
{
80102731:	55                   	push   %ebp
80102732:	89 e5                	mov    %esp,%ebp
80102734:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102737:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010273a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010273e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102745:	00 
80102746:	8b 45 08             	mov    0x8(%ebp),%eax
80102749:	89 04 24             	mov    %eax,(%esp)
8010274c:	e8 c9 fe ff ff       	call   8010261a <namex>
}
80102751:	c9                   	leave  
80102752:	c3                   	ret    

80102753 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102753:	55                   	push   %ebp
80102754:	89 e5                	mov    %esp,%ebp
80102756:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102759:	8b 45 0c             	mov    0xc(%ebp),%eax
8010275c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102760:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102767:	00 
80102768:	8b 45 08             	mov    0x8(%ebp),%eax
8010276b:	89 04 24             	mov    %eax,(%esp)
8010276e:	e8 a7 fe ff ff       	call   8010261a <namex>
}
80102773:	c9                   	leave  
80102774:	c3                   	ret    
80102775:	66 90                	xchg   %ax,%ax
80102777:	90                   	nop

80102778 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102778:	55                   	push   %ebp
80102779:	89 e5                	mov    %esp,%ebp
8010277b:	53                   	push   %ebx
8010277c:	83 ec 14             	sub    $0x14,%esp
8010277f:	8b 45 08             	mov    0x8(%ebp),%eax
80102782:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102786:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010278a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010278e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102792:	ec                   	in     (%dx),%al
80102793:	89 c3                	mov    %eax,%ebx
80102795:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102798:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010279c:	83 c4 14             	add    $0x14,%esp
8010279f:	5b                   	pop    %ebx
801027a0:	5d                   	pop    %ebp
801027a1:	c3                   	ret    

801027a2 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027a2:	55                   	push   %ebp
801027a3:	89 e5                	mov    %esp,%ebp
801027a5:	57                   	push   %edi
801027a6:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027a7:	8b 55 08             	mov    0x8(%ebp),%edx
801027aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027ad:	8b 45 10             	mov    0x10(%ebp),%eax
801027b0:	89 cb                	mov    %ecx,%ebx
801027b2:	89 df                	mov    %ebx,%edi
801027b4:	89 c1                	mov    %eax,%ecx
801027b6:	fc                   	cld    
801027b7:	f3 6d                	rep insl (%dx),%es:(%edi)
801027b9:	89 c8                	mov    %ecx,%eax
801027bb:	89 fb                	mov    %edi,%ebx
801027bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027c0:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027c3:	5b                   	pop    %ebx
801027c4:	5f                   	pop    %edi
801027c5:	5d                   	pop    %ebp
801027c6:	c3                   	ret    

801027c7 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027c7:	55                   	push   %ebp
801027c8:	89 e5                	mov    %esp,%ebp
801027ca:	83 ec 08             	sub    $0x8,%esp
801027cd:	8b 55 08             	mov    0x8(%ebp),%edx
801027d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801027d3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801027d7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801027da:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801027de:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801027e2:	ee                   	out    %al,(%dx)
}
801027e3:	c9                   	leave  
801027e4:	c3                   	ret    

801027e5 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801027e5:	55                   	push   %ebp
801027e6:	89 e5                	mov    %esp,%ebp
801027e8:	56                   	push   %esi
801027e9:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801027ea:	8b 55 08             	mov    0x8(%ebp),%edx
801027ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027f0:	8b 45 10             	mov    0x10(%ebp),%eax
801027f3:	89 cb                	mov    %ecx,%ebx
801027f5:	89 de                	mov    %ebx,%esi
801027f7:	89 c1                	mov    %eax,%ecx
801027f9:	fc                   	cld    
801027fa:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027fc:	89 c8                	mov    %ecx,%eax
801027fe:	89 f3                	mov    %esi,%ebx
80102800:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102803:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102806:	5b                   	pop    %ebx
80102807:	5e                   	pop    %esi
80102808:	5d                   	pop    %ebp
80102809:	c3                   	ret    

8010280a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010280a:	55                   	push   %ebp
8010280b:	89 e5                	mov    %esp,%ebp
8010280d:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102810:	90                   	nop
80102811:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102818:	e8 5b ff ff ff       	call   80102778 <inb>
8010281d:	0f b6 c0             	movzbl %al,%eax
80102820:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102823:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102826:	25 c0 00 00 00       	and    $0xc0,%eax
8010282b:	83 f8 40             	cmp    $0x40,%eax
8010282e:	75 e1                	jne    80102811 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102830:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102834:	74 11                	je     80102847 <idewait+0x3d>
80102836:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102839:	83 e0 21             	and    $0x21,%eax
8010283c:	85 c0                	test   %eax,%eax
8010283e:	74 07                	je     80102847 <idewait+0x3d>
    return -1;
80102840:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102845:	eb 05                	jmp    8010284c <idewait+0x42>
  return 0;
80102847:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010284c:	c9                   	leave  
8010284d:	c3                   	ret    

8010284e <ideinit>:

void
ideinit(void)
{
8010284e:	55                   	push   %ebp
8010284f:	89 e5                	mov    %esp,%ebp
80102851:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102854:	c7 44 24 04 f8 89 10 	movl   $0x801089f8,0x4(%esp)
8010285b:	80 
8010285c:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102863:	e8 5a 29 00 00       	call   801051c2 <initlock>
  picenable(IRQ_IDE);
80102868:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010286f:	e8 85 15 00 00       	call   80103df9 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102874:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80102879:	83 e8 01             	sub    $0x1,%eax
8010287c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102880:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102887:	e8 12 04 00 00       	call   80102c9e <ioapicenable>
  idewait(0);
8010288c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102893:	e8 72 ff ff ff       	call   8010280a <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102898:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010289f:	00 
801028a0:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028a7:	e8 1b ff ff ff       	call   801027c7 <outb>
  for(i=0; i<1000; i++){
801028ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028b3:	eb 20                	jmp    801028d5 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028b5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028bc:	e8 b7 fe ff ff       	call   80102778 <inb>
801028c1:	84 c0                	test   %al,%al
801028c3:	74 0c                	je     801028d1 <ideinit+0x83>
      havedisk1 = 1;
801028c5:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801028cc:	00 00 00 
      break;
801028cf:	eb 0d                	jmp    801028de <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801028d5:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801028dc:	7e d7                	jle    801028b5 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801028de:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801028e5:	00 
801028e6:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028ed:	e8 d5 fe ff ff       	call   801027c7 <outb>
}
801028f2:	c9                   	leave  
801028f3:	c3                   	ret    

801028f4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028f4:	55                   	push   %ebp
801028f5:	89 e5                	mov    %esp,%ebp
801028f7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801028fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028fe:	75 0c                	jne    8010290c <idestart+0x18>
    panic("idestart");
80102900:	c7 04 24 fc 89 10 80 	movl   $0x801089fc,(%esp)
80102907:	e8 3a dc ff ff       	call   80100546 <panic>

  idewait(0);
8010290c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102913:	e8 f2 fe ff ff       	call   8010280a <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102918:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010291f:	00 
80102920:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102927:	e8 9b fe ff ff       	call   801027c7 <outb>
  outb(0x1f2, 1);  // number of sectors
8010292c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102933:	00 
80102934:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010293b:	e8 87 fe ff ff       	call   801027c7 <outb>
  outb(0x1f3, b->sector & 0xff);
80102940:	8b 45 08             	mov    0x8(%ebp),%eax
80102943:	8b 40 08             	mov    0x8(%eax),%eax
80102946:	0f b6 c0             	movzbl %al,%eax
80102949:	89 44 24 04          	mov    %eax,0x4(%esp)
8010294d:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102954:	e8 6e fe ff ff       	call   801027c7 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102959:	8b 45 08             	mov    0x8(%ebp),%eax
8010295c:	8b 40 08             	mov    0x8(%eax),%eax
8010295f:	c1 e8 08             	shr    $0x8,%eax
80102962:	0f b6 c0             	movzbl %al,%eax
80102965:	89 44 24 04          	mov    %eax,0x4(%esp)
80102969:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102970:	e8 52 fe ff ff       	call   801027c7 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102975:	8b 45 08             	mov    0x8(%ebp),%eax
80102978:	8b 40 08             	mov    0x8(%eax),%eax
8010297b:	c1 e8 10             	shr    $0x10,%eax
8010297e:	0f b6 c0             	movzbl %al,%eax
80102981:	89 44 24 04          	mov    %eax,0x4(%esp)
80102985:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010298c:	e8 36 fe ff ff       	call   801027c7 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102991:	8b 45 08             	mov    0x8(%ebp),%eax
80102994:	8b 40 04             	mov    0x4(%eax),%eax
80102997:	83 e0 01             	and    $0x1,%eax
8010299a:	89 c2                	mov    %eax,%edx
8010299c:	c1 e2 04             	shl    $0x4,%edx
8010299f:	8b 45 08             	mov    0x8(%ebp),%eax
801029a2:	8b 40 08             	mov    0x8(%eax),%eax
801029a5:	c1 e8 18             	shr    $0x18,%eax
801029a8:	83 e0 0f             	and    $0xf,%eax
801029ab:	09 d0                	or     %edx,%eax
801029ad:	83 c8 e0             	or     $0xffffffe0,%eax
801029b0:	0f b6 c0             	movzbl %al,%eax
801029b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029be:	e8 04 fe ff ff       	call   801027c7 <outb>
  if(b->flags & B_DIRTY){
801029c3:	8b 45 08             	mov    0x8(%ebp),%eax
801029c6:	8b 00                	mov    (%eax),%eax
801029c8:	83 e0 04             	and    $0x4,%eax
801029cb:	85 c0                	test   %eax,%eax
801029cd:	74 34                	je     80102a03 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801029cf:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801029d6:	00 
801029d7:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801029de:	e8 e4 fd ff ff       	call   801027c7 <outb>
    outsl(0x1f0, b->data, 512/4);
801029e3:	8b 45 08             	mov    0x8(%ebp),%eax
801029e6:	83 c0 18             	add    $0x18,%eax
801029e9:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801029f0:	00 
801029f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f5:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801029fc:	e8 e4 fd ff ff       	call   801027e5 <outsl>
80102a01:	eb 14                	jmp    80102a17 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a03:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a0a:	00 
80102a0b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a12:	e8 b0 fd ff ff       	call   801027c7 <outb>
  }
}
80102a17:	c9                   	leave  
80102a18:	c3                   	ret    

80102a19 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a19:	55                   	push   %ebp
80102a1a:	89 e5                	mov    %esp,%ebp
80102a1c:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a1f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a26:	e8 b8 27 00 00       	call   801051e3 <acquire>
  if((b = idequeue) == 0){
80102a2b:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a37:	75 11                	jne    80102a4a <ideintr+0x31>
    release(&idelock);
80102a39:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a40:	e8 00 28 00 00       	call   80105245 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a45:	e9 90 00 00 00       	jmp    80102ada <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4d:	8b 40 14             	mov    0x14(%eax),%eax
80102a50:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a58:	8b 00                	mov    (%eax),%eax
80102a5a:	83 e0 04             	and    $0x4,%eax
80102a5d:	85 c0                	test   %eax,%eax
80102a5f:	75 2e                	jne    80102a8f <ideintr+0x76>
80102a61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a68:	e8 9d fd ff ff       	call   8010280a <idewait>
80102a6d:	85 c0                	test   %eax,%eax
80102a6f:	78 1e                	js     80102a8f <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a74:	83 c0 18             	add    $0x18,%eax
80102a77:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a7e:	00 
80102a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a83:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a8a:	e8 13 fd ff ff       	call   801027a2 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a92:	8b 00                	mov    (%eax),%eax
80102a94:	89 c2                	mov    %eax,%edx
80102a96:	83 ca 02             	or     $0x2,%edx
80102a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9c:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa1:	8b 00                	mov    (%eax),%eax
80102aa3:	89 c2                	mov    %eax,%edx
80102aa5:	83 e2 fb             	and    $0xfffffffb,%edx
80102aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aab:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab0:	89 04 24             	mov    %eax,(%esp)
80102ab3:	e8 92 24 00 00       	call   80104f4a <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ab8:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102abd:	85 c0                	test   %eax,%eax
80102abf:	74 0d                	je     80102ace <ideintr+0xb5>
    idestart(idequeue);
80102ac1:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102ac6:	89 04 24             	mov    %eax,(%esp)
80102ac9:	e8 26 fe ff ff       	call   801028f4 <idestart>

  release(&idelock);
80102ace:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102ad5:	e8 6b 27 00 00       	call   80105245 <release>
}
80102ada:	c9                   	leave  
80102adb:	c3                   	ret    

80102adc <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102adc:	55                   	push   %ebp
80102add:	89 e5                	mov    %esp,%ebp
80102adf:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae5:	8b 00                	mov    (%eax),%eax
80102ae7:	83 e0 01             	and    $0x1,%eax
80102aea:	85 c0                	test   %eax,%eax
80102aec:	75 0c                	jne    80102afa <iderw+0x1e>
    panic("iderw: buf not busy");
80102aee:	c7 04 24 05 8a 10 80 	movl   $0x80108a05,(%esp)
80102af5:	e8 4c da ff ff       	call   80100546 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102afa:	8b 45 08             	mov    0x8(%ebp),%eax
80102afd:	8b 00                	mov    (%eax),%eax
80102aff:	83 e0 06             	and    $0x6,%eax
80102b02:	83 f8 02             	cmp    $0x2,%eax
80102b05:	75 0c                	jne    80102b13 <iderw+0x37>
    panic("iderw: nothing to do");
80102b07:	c7 04 24 19 8a 10 80 	movl   $0x80108a19,(%esp)
80102b0e:	e8 33 da ff ff       	call   80100546 <panic>
  if(b->dev != 0 && !havedisk1)
80102b13:	8b 45 08             	mov    0x8(%ebp),%eax
80102b16:	8b 40 04             	mov    0x4(%eax),%eax
80102b19:	85 c0                	test   %eax,%eax
80102b1b:	74 15                	je     80102b32 <iderw+0x56>
80102b1d:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102b22:	85 c0                	test   %eax,%eax
80102b24:	75 0c                	jne    80102b32 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b26:	c7 04 24 2e 8a 10 80 	movl   $0x80108a2e,(%esp)
80102b2d:	e8 14 da ff ff       	call   80100546 <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b32:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b39:	e8 a5 26 00 00       	call   801051e3 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b41:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b48:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b4f:	eb 0b                	jmp    80102b5c <iderw+0x80>
80102b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b54:	8b 00                	mov    (%eax),%eax
80102b56:	83 c0 14             	add    $0x14,%eax
80102b59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b5f:	8b 00                	mov    (%eax),%eax
80102b61:	85 c0                	test   %eax,%eax
80102b63:	75 ec                	jne    80102b51 <iderw+0x75>
    ;
  *pp = b;
80102b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b68:	8b 55 08             	mov    0x8(%ebp),%edx
80102b6b:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b6d:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b72:	3b 45 08             	cmp    0x8(%ebp),%eax
80102b75:	75 22                	jne    80102b99 <iderw+0xbd>
    idestart(b);
80102b77:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7a:	89 04 24             	mov    %eax,(%esp)
80102b7d:	e8 72 fd ff ff       	call   801028f4 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b82:	eb 15                	jmp    80102b99 <iderw+0xbd>
    sleep(b, &idelock);
80102b84:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102b8b:	80 
80102b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b8f:	89 04 24             	mov    %eax,(%esp)
80102b92:	e8 d7 22 00 00       	call   80104e6e <sleep>
80102b97:	eb 01                	jmp    80102b9a <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b99:	90                   	nop
80102b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9d:	8b 00                	mov    (%eax),%eax
80102b9f:	83 e0 06             	and    $0x6,%eax
80102ba2:	83 f8 02             	cmp    $0x2,%eax
80102ba5:	75 dd                	jne    80102b84 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102ba7:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102bae:	e8 92 26 00 00       	call   80105245 <release>
}
80102bb3:	c9                   	leave  
80102bb4:	c3                   	ret    
80102bb5:	66 90                	xchg   %ax,%ax
80102bb7:	90                   	nop

80102bb8 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bb8:	55                   	push   %ebp
80102bb9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bbb:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bc0:	8b 55 08             	mov    0x8(%ebp),%edx
80102bc3:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bc5:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bca:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bcd:	5d                   	pop    %ebp
80102bce:	c3                   	ret    

80102bcf <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bcf:	55                   	push   %ebp
80102bd0:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bd2:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bd7:	8b 55 08             	mov    0x8(%ebp),%edx
80102bda:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bdc:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102be1:	8b 55 0c             	mov    0xc(%ebp),%edx
80102be4:	89 50 10             	mov    %edx,0x10(%eax)
}
80102be7:	5d                   	pop    %ebp
80102be8:	c3                   	ret    

80102be9 <ioapicinit>:

void
ioapicinit(void)
{
80102be9:	55                   	push   %ebp
80102bea:	89 e5                	mov    %esp,%ebp
80102bec:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102bef:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102bf4:	85 c0                	test   %eax,%eax
80102bf6:	0f 84 9f 00 00 00    	je     80102c9b <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bfc:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102c03:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c0d:	e8 a6 ff ff ff       	call   80102bb8 <ioapicread>
80102c12:	c1 e8 10             	shr    $0x10,%eax
80102c15:	25 ff 00 00 00       	and    $0xff,%eax
80102c1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c24:	e8 8f ff ff ff       	call   80102bb8 <ioapicread>
80102c29:	c1 e8 18             	shr    $0x18,%eax
80102c2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c2f:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102c36:	0f b6 c0             	movzbl %al,%eax
80102c39:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c3c:	74 0c                	je     80102c4a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c3e:	c7 04 24 4c 8a 10 80 	movl   $0x80108a4c,(%esp)
80102c45:	e8 60 d7 ff ff       	call   801003aa <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c51:	eb 3e                	jmp    80102c91 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c56:	83 c0 20             	add    $0x20,%eax
80102c59:	0d 00 00 01 00       	or     $0x10000,%eax
80102c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c61:	83 c2 08             	add    $0x8,%edx
80102c64:	01 d2                	add    %edx,%edx
80102c66:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c6a:	89 14 24             	mov    %edx,(%esp)
80102c6d:	e8 5d ff ff ff       	call   80102bcf <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c75:	83 c0 08             	add    $0x8,%eax
80102c78:	01 c0                	add    %eax,%eax
80102c7a:	83 c0 01             	add    $0x1,%eax
80102c7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102c84:	00 
80102c85:	89 04 24             	mov    %eax,(%esp)
80102c88:	e8 42 ff ff ff       	call   80102bcf <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c8d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c94:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c97:	7e ba                	jle    80102c53 <ioapicinit+0x6a>
80102c99:	eb 01                	jmp    80102c9c <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102c9b:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102c9c:	c9                   	leave  
80102c9d:	c3                   	ret    

80102c9e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c9e:	55                   	push   %ebp
80102c9f:	89 e5                	mov    %esp,%ebp
80102ca1:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102ca4:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102ca9:	85 c0                	test   %eax,%eax
80102cab:	74 39                	je     80102ce6 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cad:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb0:	83 c0 20             	add    $0x20,%eax
80102cb3:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb6:	83 c2 08             	add    $0x8,%edx
80102cb9:	01 d2                	add    %edx,%edx
80102cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cbf:	89 14 24             	mov    %edx,(%esp)
80102cc2:	e8 08 ff ff ff       	call   80102bcf <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cca:	c1 e0 18             	shl    $0x18,%eax
80102ccd:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd0:	83 c2 08             	add    $0x8,%edx
80102cd3:	01 d2                	add    %edx,%edx
80102cd5:	83 c2 01             	add    $0x1,%edx
80102cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cdc:	89 14 24             	mov    %edx,(%esp)
80102cdf:	e8 eb fe ff ff       	call   80102bcf <ioapicwrite>
80102ce4:	eb 01                	jmp    80102ce7 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102ce6:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102ce7:	c9                   	leave  
80102ce8:	c3                   	ret    
80102ce9:	66 90                	xchg   %ax,%ax
80102ceb:	90                   	nop

80102cec <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102cec:	55                   	push   %ebp
80102ced:	89 e5                	mov    %esp,%ebp
80102cef:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf2:	05 00 00 00 80       	add    $0x80000000,%eax
80102cf7:	5d                   	pop    %ebp
80102cf8:	c3                   	ret    

80102cf9 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cf9:	55                   	push   %ebp
80102cfa:	89 e5                	mov    %esp,%ebp
80102cfc:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102cff:	c7 44 24 04 7e 8a 10 	movl   $0x80108a7e,0x4(%esp)
80102d06:	80 
80102d07:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102d0e:	e8 af 24 00 00       	call   801051c2 <initlock>
  kmem.use_lock = 0;
80102d13:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102d1a:	00 00 00 
  freerange(vstart, vend);
80102d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d20:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d24:	8b 45 08             	mov    0x8(%ebp),%eax
80102d27:	89 04 24             	mov    %eax,(%esp)
80102d2a:	e8 26 00 00 00       	call   80102d55 <freerange>
}
80102d2f:	c9                   	leave  
80102d30:	c3                   	ret    

80102d31 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d31:	55                   	push   %ebp
80102d32:	89 e5                	mov    %esp,%ebp
80102d34:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d37:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d41:	89 04 24             	mov    %eax,(%esp)
80102d44:	e8 0c 00 00 00       	call   80102d55 <freerange>
  kmem.use_lock = 1;
80102d49:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d50:	00 00 00 
}
80102d53:	c9                   	leave  
80102d54:	c3                   	ret    

80102d55 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d55:	55                   	push   %ebp
80102d56:	89 e5                	mov    %esp,%ebp
80102d58:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d5e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d6b:	eb 12                	jmp    80102d7f <freerange+0x2a>
    kfree(p);
80102d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d70:	89 04 24             	mov    %eax,(%esp)
80102d73:	e8 16 00 00 00       	call   80102d8e <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d78:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d82:	05 00 10 00 00       	add    $0x1000,%eax
80102d87:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102d8a:	76 e1                	jbe    80102d6d <freerange+0x18>
    kfree(p);
}
80102d8c:	c9                   	leave  
80102d8d:	c3                   	ret    

80102d8e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d8e:	55                   	push   %ebp
80102d8f:	89 e5                	mov    %esp,%ebp
80102d91:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102d94:	8b 45 08             	mov    0x8(%ebp),%eax
80102d97:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d9c:	85 c0                	test   %eax,%eax
80102d9e:	75 1b                	jne    80102dbb <kfree+0x2d>
80102da0:	81 7d 08 1c 2e 11 80 	cmpl   $0x80112e1c,0x8(%ebp)
80102da7:	72 12                	jb     80102dbb <kfree+0x2d>
80102da9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dac:	89 04 24             	mov    %eax,(%esp)
80102daf:	e8 38 ff ff ff       	call   80102cec <v2p>
80102db4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102db9:	76 0c                	jbe    80102dc7 <kfree+0x39>
    panic("kfree");
80102dbb:	c7 04 24 83 8a 10 80 	movl   $0x80108a83,(%esp)
80102dc2:	e8 7f d7 ff ff       	call   80100546 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102dc7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102dce:	00 
80102dcf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102dd6:	00 
80102dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dda:	89 04 24             	mov    %eax,(%esp)
80102ddd:	e8 5c 26 00 00       	call   8010543e <memset>

  if(kmem.use_lock)
80102de2:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102de7:	85 c0                	test   %eax,%eax
80102de9:	74 0c                	je     80102df7 <kfree+0x69>
    acquire(&kmem.lock);
80102deb:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102df2:	e8 ec 23 00 00       	call   801051e3 <acquire>
  r = (struct run*)v;
80102df7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102dfd:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e06:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e0b:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e10:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e15:	85 c0                	test   %eax,%eax
80102e17:	74 0c                	je     80102e25 <kfree+0x97>
    release(&kmem.lock);
80102e19:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e20:	e8 20 24 00 00       	call   80105245 <release>
}
80102e25:	c9                   	leave  
80102e26:	c3                   	ret    

80102e27 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e27:	55                   	push   %ebp
80102e28:	89 e5                	mov    %esp,%ebp
80102e2a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e2d:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e32:	85 c0                	test   %eax,%eax
80102e34:	74 0c                	je     80102e42 <kalloc+0x1b>
    acquire(&kmem.lock);
80102e36:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e3d:	e8 a1 23 00 00       	call   801051e3 <acquire>
  r = kmem.freelist;
80102e42:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e4e:	74 0a                	je     80102e5a <kalloc+0x33>
    kmem.freelist = r->next;
80102e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e53:	8b 00                	mov    (%eax),%eax
80102e55:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e5a:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e5f:	85 c0                	test   %eax,%eax
80102e61:	74 0c                	je     80102e6f <kalloc+0x48>
    release(&kmem.lock);
80102e63:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e6a:	e8 d6 23 00 00       	call   80105245 <release>
  return (char*)r;
80102e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e72:	c9                   	leave  
80102e73:	c3                   	ret    

80102e74 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e74:	55                   	push   %ebp
80102e75:	89 e5                	mov    %esp,%ebp
80102e77:	53                   	push   %ebx
80102e78:	83 ec 14             	sub    $0x14,%esp
80102e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e7e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e82:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102e86:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102e8a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102e8e:	ec                   	in     (%dx),%al
80102e8f:	89 c3                	mov    %eax,%ebx
80102e91:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102e94:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102e98:	83 c4 14             	add    $0x14,%esp
80102e9b:	5b                   	pop    %ebx
80102e9c:	5d                   	pop    %ebp
80102e9d:	c3                   	ret    

80102e9e <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e9e:	55                   	push   %ebp
80102e9f:	89 e5                	mov    %esp,%ebp
80102ea1:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ea4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102eab:	e8 c4 ff ff ff       	call   80102e74 <inb>
80102eb0:	0f b6 c0             	movzbl %al,%eax
80102eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb9:	83 e0 01             	and    $0x1,%eax
80102ebc:	85 c0                	test   %eax,%eax
80102ebe:	75 0a                	jne    80102eca <kbdgetc+0x2c>
    return -1;
80102ec0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ec5:	e9 25 01 00 00       	jmp    80102fef <kbdgetc+0x151>
  data = inb(KBDATAP);
80102eca:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102ed1:	e8 9e ff ff ff       	call   80102e74 <inb>
80102ed6:	0f b6 c0             	movzbl %al,%eax
80102ed9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102edc:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ee3:	75 17                	jne    80102efc <kbdgetc+0x5e>
    shift |= E0ESC;
80102ee5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102eea:	83 c8 40             	or     $0x40,%eax
80102eed:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80102ef7:	e9 f3 00 00 00       	jmp    80102fef <kbdgetc+0x151>
  } else if(data & 0x80){
80102efc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eff:	25 80 00 00 00       	and    $0x80,%eax
80102f04:	85 c0                	test   %eax,%eax
80102f06:	74 45                	je     80102f4d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f08:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f0d:	83 e0 40             	and    $0x40,%eax
80102f10:	85 c0                	test   %eax,%eax
80102f12:	75 08                	jne    80102f1c <kbdgetc+0x7e>
80102f14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f17:	83 e0 7f             	and    $0x7f,%eax
80102f1a:	eb 03                	jmp    80102f1f <kbdgetc+0x81>
80102f1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f25:	05 20 90 10 80       	add    $0x80109020,%eax
80102f2a:	0f b6 00             	movzbl (%eax),%eax
80102f2d:	83 c8 40             	or     $0x40,%eax
80102f30:	0f b6 c0             	movzbl %al,%eax
80102f33:	f7 d0                	not    %eax
80102f35:	89 c2                	mov    %eax,%edx
80102f37:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f3c:	21 d0                	and    %edx,%eax
80102f3e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f43:	b8 00 00 00 00       	mov    $0x0,%eax
80102f48:	e9 a2 00 00 00       	jmp    80102fef <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102f4d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f52:	83 e0 40             	and    $0x40,%eax
80102f55:	85 c0                	test   %eax,%eax
80102f57:	74 14                	je     80102f6d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f59:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f60:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f65:	83 e0 bf             	and    $0xffffffbf,%eax
80102f68:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f70:	05 20 90 10 80       	add    $0x80109020,%eax
80102f75:	0f b6 00             	movzbl (%eax),%eax
80102f78:	0f b6 d0             	movzbl %al,%edx
80102f7b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f80:	09 d0                	or     %edx,%eax
80102f82:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102f87:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f8a:	05 20 91 10 80       	add    $0x80109120,%eax
80102f8f:	0f b6 00             	movzbl (%eax),%eax
80102f92:	0f b6 d0             	movzbl %al,%edx
80102f95:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f9a:	31 d0                	xor    %edx,%eax
80102f9c:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fa1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fa6:	83 e0 03             	and    $0x3,%eax
80102fa9:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102fb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb3:	01 d0                	add    %edx,%eax
80102fb5:	0f b6 00             	movzbl (%eax),%eax
80102fb8:	0f b6 c0             	movzbl %al,%eax
80102fbb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fbe:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fc3:	83 e0 08             	and    $0x8,%eax
80102fc6:	85 c0                	test   %eax,%eax
80102fc8:	74 22                	je     80102fec <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102fca:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fce:	76 0c                	jbe    80102fdc <kbdgetc+0x13e>
80102fd0:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fd4:	77 06                	ja     80102fdc <kbdgetc+0x13e>
      c += 'A' - 'a';
80102fd6:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fda:	eb 10                	jmp    80102fec <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102fdc:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fe0:	76 0a                	jbe    80102fec <kbdgetc+0x14e>
80102fe2:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fe6:	77 04                	ja     80102fec <kbdgetc+0x14e>
      c += 'a' - 'A';
80102fe8:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fec:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fef:	c9                   	leave  
80102ff0:	c3                   	ret    

80102ff1 <kbdintr>:

void
kbdintr(void)
{
80102ff1:	55                   	push   %ebp
80102ff2:	89 e5                	mov    %esp,%ebp
80102ff4:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102ff7:	c7 04 24 9e 2e 10 80 	movl   $0x80102e9e,(%esp)
80102ffe:	e8 78 d8 ff ff       	call   8010087b <consoleintr>
}
80103003:	c9                   	leave  
80103004:	c3                   	ret    
80103005:	66 90                	xchg   %ax,%ax
80103007:	90                   	nop

80103008 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103008:	55                   	push   %ebp
80103009:	89 e5                	mov    %esp,%ebp
8010300b:	83 ec 08             	sub    $0x8,%esp
8010300e:	8b 55 08             	mov    0x8(%ebp),%edx
80103011:	8b 45 0c             	mov    0xc(%ebp),%eax
80103014:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103018:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010301b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010301f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103023:	ee                   	out    %al,(%dx)
}
80103024:	c9                   	leave  
80103025:	c3                   	ret    

80103026 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103026:	55                   	push   %ebp
80103027:	89 e5                	mov    %esp,%ebp
80103029:	53                   	push   %ebx
8010302a:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010302d:	9c                   	pushf  
8010302e:	5b                   	pop    %ebx
8010302f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80103032:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103035:	83 c4 10             	add    $0x10,%esp
80103038:	5b                   	pop    %ebx
80103039:	5d                   	pop    %ebp
8010303a:	c3                   	ret    

8010303b <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010303b:	55                   	push   %ebp
8010303c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010303e:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103043:	8b 55 08             	mov    0x8(%ebp),%edx
80103046:	c1 e2 02             	shl    $0x2,%edx
80103049:	01 c2                	add    %eax,%edx
8010304b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010304e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103050:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103055:	83 c0 20             	add    $0x20,%eax
80103058:	8b 00                	mov    (%eax),%eax
}
8010305a:	5d                   	pop    %ebp
8010305b:	c3                   	ret    

8010305c <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
8010305c:	55                   	push   %ebp
8010305d:	89 e5                	mov    %esp,%ebp
8010305f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103062:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103067:	85 c0                	test   %eax,%eax
80103069:	0f 84 47 01 00 00    	je     801031b6 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010306f:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103076:	00 
80103077:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010307e:	e8 b8 ff ff ff       	call   8010303b <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103083:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010308a:	00 
8010308b:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103092:	e8 a4 ff ff ff       	call   8010303b <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103097:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010309e:	00 
8010309f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030a6:	e8 90 ff ff ff       	call   8010303b <lapicw>
  lapicw(TICR, 10000000); 
801030ab:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030b2:	00 
801030b3:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030ba:	e8 7c ff ff ff       	call   8010303b <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030bf:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030c6:	00 
801030c7:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801030ce:	e8 68 ff ff ff       	call   8010303b <lapicw>
  lapicw(LINT1, MASKED);
801030d3:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030da:	00 
801030db:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801030e2:	e8 54 ff ff ff       	call   8010303b <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030e7:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801030ec:	83 c0 30             	add    $0x30,%eax
801030ef:	8b 00                	mov    (%eax),%eax
801030f1:	c1 e8 10             	shr    $0x10,%eax
801030f4:	25 ff 00 00 00       	and    $0xff,%eax
801030f9:	83 f8 03             	cmp    $0x3,%eax
801030fc:	76 14                	jbe    80103112 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801030fe:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103105:	00 
80103106:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
8010310d:	e8 29 ff ff ff       	call   8010303b <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103112:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103119:	00 
8010311a:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103121:	e8 15 ff ff ff       	call   8010303b <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103126:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010312d:	00 
8010312e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103135:	e8 01 ff ff ff       	call   8010303b <lapicw>
  lapicw(ESR, 0);
8010313a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103141:	00 
80103142:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103149:	e8 ed fe ff ff       	call   8010303b <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010314e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103155:	00 
80103156:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010315d:	e8 d9 fe ff ff       	call   8010303b <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103169:	00 
8010316a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103171:	e8 c5 fe ff ff       	call   8010303b <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103176:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
8010317d:	00 
8010317e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103185:	e8 b1 fe ff ff       	call   8010303b <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010318a:	90                   	nop
8010318b:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103190:	05 00 03 00 00       	add    $0x300,%eax
80103195:	8b 00                	mov    (%eax),%eax
80103197:	25 00 10 00 00       	and    $0x1000,%eax
8010319c:	85 c0                	test   %eax,%eax
8010319e:	75 eb                	jne    8010318b <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031a7:	00 
801031a8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031af:	e8 87 fe ff ff       	call   8010303b <lapicw>
801031b4:	eb 01                	jmp    801031b7 <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801031b6:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801031b7:	c9                   	leave  
801031b8:	c3                   	ret    

801031b9 <cpunum>:

int
cpunum(void)
{
801031b9:	55                   	push   %ebp
801031ba:	89 e5                	mov    %esp,%ebp
801031bc:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031bf:	e8 62 fe ff ff       	call   80103026 <readeflags>
801031c4:	25 00 02 00 00       	and    $0x200,%eax
801031c9:	85 c0                	test   %eax,%eax
801031cb:	74 29                	je     801031f6 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801031cd:	a1 40 b6 10 80       	mov    0x8010b640,%eax
801031d2:	85 c0                	test   %eax,%eax
801031d4:	0f 94 c2             	sete   %dl
801031d7:	83 c0 01             	add    $0x1,%eax
801031da:	a3 40 b6 10 80       	mov    %eax,0x8010b640
801031df:	84 d2                	test   %dl,%dl
801031e1:	74 13                	je     801031f6 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
801031e3:	8b 45 04             	mov    0x4(%ebp),%eax
801031e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801031ea:	c7 04 24 8c 8a 10 80 	movl   $0x80108a8c,(%esp)
801031f1:	e8 b4 d1 ff ff       	call   801003aa <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801031f6:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031fb:	85 c0                	test   %eax,%eax
801031fd:	74 0f                	je     8010320e <cpunum+0x55>
    return lapic[ID]>>24;
801031ff:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103204:	83 c0 20             	add    $0x20,%eax
80103207:	8b 00                	mov    (%eax),%eax
80103209:	c1 e8 18             	shr    $0x18,%eax
8010320c:	eb 05                	jmp    80103213 <cpunum+0x5a>
  return 0;
8010320e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103213:	c9                   	leave  
80103214:	c3                   	ret    

80103215 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103215:	55                   	push   %ebp
80103216:	89 e5                	mov    %esp,%ebp
80103218:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
8010321b:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103220:	85 c0                	test   %eax,%eax
80103222:	74 14                	je     80103238 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103224:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010322b:	00 
8010322c:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103233:	e8 03 fe ff ff       	call   8010303b <lapicw>
}
80103238:	c9                   	leave  
80103239:	c3                   	ret    

8010323a <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010323a:	55                   	push   %ebp
8010323b:	89 e5                	mov    %esp,%ebp
}
8010323d:	5d                   	pop    %ebp
8010323e:	c3                   	ret    

8010323f <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010323f:	55                   	push   %ebp
80103240:	89 e5                	mov    %esp,%ebp
80103242:	83 ec 1c             	sub    $0x1c,%esp
80103245:	8b 45 08             	mov    0x8(%ebp),%eax
80103248:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
8010324b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103252:	00 
80103253:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010325a:	e8 a9 fd ff ff       	call   80103008 <outb>
  outb(IO_RTC+1, 0x0A);
8010325f:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103266:	00 
80103267:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010326e:	e8 95 fd ff ff       	call   80103008 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103273:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010327a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010327d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103282:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103285:	8d 50 02             	lea    0x2(%eax),%edx
80103288:	8b 45 0c             	mov    0xc(%ebp),%eax
8010328b:	c1 e8 04             	shr    $0x4,%eax
8010328e:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103291:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103295:	c1 e0 18             	shl    $0x18,%eax
80103298:	89 44 24 04          	mov    %eax,0x4(%esp)
8010329c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032a3:	e8 93 fd ff ff       	call   8010303b <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032a8:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032af:	00 
801032b0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032b7:	e8 7f fd ff ff       	call   8010303b <lapicw>
  microdelay(200);
801032bc:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032c3:	e8 72 ff ff ff       	call   8010323a <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801032c8:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801032cf:	00 
801032d0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032d7:	e8 5f fd ff ff       	call   8010303b <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032dc:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801032e3:	e8 52 ff ff ff       	call   8010323a <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032ef:	eb 40                	jmp    80103331 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801032f1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032f5:	c1 e0 18             	shl    $0x18,%eax
801032f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801032fc:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103303:	e8 33 fd ff ff       	call   8010303b <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103308:	8b 45 0c             	mov    0xc(%ebp),%eax
8010330b:	c1 e8 0c             	shr    $0xc,%eax
8010330e:	80 cc 06             	or     $0x6,%ah
80103311:	89 44 24 04          	mov    %eax,0x4(%esp)
80103315:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010331c:	e8 1a fd ff ff       	call   8010303b <lapicw>
    microdelay(200);
80103321:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103328:	e8 0d ff ff ff       	call   8010323a <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010332d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103331:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103335:	7e ba                	jle    801032f1 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103337:	c9                   	leave  
80103338:	c3                   	ret    
80103339:	66 90                	xchg   %ax,%ax
8010333b:	90                   	nop

8010333c <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
8010333c:	55                   	push   %ebp
8010333d:	89 e5                	mov    %esp,%ebp
8010333f:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103342:	c7 44 24 04 b8 8a 10 	movl   $0x80108ab8,0x4(%esp)
80103349:	80 
8010334a:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103351:	e8 6c 1e 00 00       	call   801051c2 <initlock>
  readsb(ROOTDEV, &sb);
80103356:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103359:	89 44 24 04          	mov    %eax,0x4(%esp)
8010335d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103364:	e8 87 e2 ff ff       	call   801015f0 <readsb>
  log.start = sb.size - sb.nlog;
80103369:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010336c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010336f:	89 d1                	mov    %edx,%ecx
80103371:	29 c1                	sub    %eax,%ecx
80103373:	89 c8                	mov    %ecx,%eax
80103375:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
8010337a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010337d:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
80103382:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
80103389:	00 00 00 
  recover_from_log();
8010338c:	e8 9a 01 00 00       	call   8010352b <recover_from_log>
}
80103391:	c9                   	leave  
80103392:	c3                   	ret    

80103393 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103393:	55                   	push   %ebp
80103394:	89 e5                	mov    %esp,%ebp
80103396:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103399:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033a0:	e9 8c 00 00 00       	jmp    80103431 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033a5:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
801033ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ae:	01 d0                	add    %edx,%eax
801033b0:	83 c0 01             	add    $0x1,%eax
801033b3:	89 c2                	mov    %eax,%edx
801033b5:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801033be:	89 04 24             	mov    %eax,(%esp)
801033c1:	e8 e0 cd ff ff       	call   801001a6 <bread>
801033c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033cc:	83 c0 10             	add    $0x10,%eax
801033cf:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801033d6:	89 c2                	mov    %eax,%edx
801033d8:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801033e1:	89 04 24             	mov    %eax,(%esp)
801033e4:	e8 bd cd ff ff       	call   801001a6 <bread>
801033e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ef:	8d 50 18             	lea    0x18(%eax),%edx
801033f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f5:	83 c0 18             	add    $0x18,%eax
801033f8:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033ff:	00 
80103400:	89 54 24 04          	mov    %edx,0x4(%esp)
80103404:	89 04 24             	mov    %eax,(%esp)
80103407:	e8 05 21 00 00       	call   80105511 <memmove>
    bwrite(dbuf);  // write dst to disk
8010340c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010340f:	89 04 24             	mov    %eax,(%esp)
80103412:	e8 c6 cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010341a:	89 04 24             	mov    %eax,(%esp)
8010341d:	e8 f5 cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103422:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103425:	89 04 24             	mov    %eax,(%esp)
80103428:	e8 ea cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010342d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103431:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103436:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103439:	0f 8f 66 ff ff ff    	jg     801033a5 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010343f:	c9                   	leave  
80103440:	c3                   	ret    

80103441 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103441:	55                   	push   %ebp
80103442:	89 e5                	mov    %esp,%ebp
80103444:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103447:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010344c:	89 c2                	mov    %eax,%edx
8010344e:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103453:	89 54 24 04          	mov    %edx,0x4(%esp)
80103457:	89 04 24             	mov    %eax,(%esp)
8010345a:	e8 47 cd ff ff       	call   801001a6 <bread>
8010345f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103462:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103465:	83 c0 18             	add    $0x18,%eax
80103468:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010346b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346e:	8b 00                	mov    (%eax),%eax
80103470:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
80103475:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010347c:	eb 1b                	jmp    80103499 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010347e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103481:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103484:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103488:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010348b:	83 c2 10             	add    $0x10,%edx
8010348e:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103495:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103499:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010349e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034a1:	7f db                	jg     8010347e <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a6:	89 04 24             	mov    %eax,(%esp)
801034a9:	e8 69 cd ff ff       	call   80100217 <brelse>
}
801034ae:	c9                   	leave  
801034af:	c3                   	ret    

801034b0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034b0:	55                   	push   %ebp
801034b1:	89 e5                	mov    %esp,%ebp
801034b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034b6:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801034bb:	89 c2                	mov    %eax,%edx
801034bd:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801034c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801034c6:	89 04 24             	mov    %eax,(%esp)
801034c9:	e8 d8 cc ff ff       	call   801001a6 <bread>
801034ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	83 c0 18             	add    $0x18,%eax
801034d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034da:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
801034e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e3:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ec:	eb 1b                	jmp    80103509 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801034ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f1:	83 c0 10             	add    $0x10,%eax
801034f4:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
801034fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103501:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103505:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103509:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010350e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103511:	7f db                	jg     801034ee <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103513:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103516:	89 04 24             	mov    %eax,(%esp)
80103519:	e8 bf cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010351e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103521:	89 04 24             	mov    %eax,(%esp)
80103524:	e8 ee cc ff ff       	call   80100217 <brelse>
}
80103529:	c9                   	leave  
8010352a:	c3                   	ret    

8010352b <recover_from_log>:

static void
recover_from_log(void)
{
8010352b:	55                   	push   %ebp
8010352c:	89 e5                	mov    %esp,%ebp
8010352e:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103531:	e8 0b ff ff ff       	call   80103441 <read_head>
  install_trans(); // if committed, copy from log to disk
80103536:	e8 58 fe ff ff       	call   80103393 <install_trans>
  log.lh.n = 0;
8010353b:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103542:	00 00 00 
  write_head(); // clear the log
80103545:	e8 66 ff ff ff       	call   801034b0 <write_head>
}
8010354a:	c9                   	leave  
8010354b:	c3                   	ret    

8010354c <begin_trans>:

void
begin_trans(void)
{
8010354c:	55                   	push   %ebp
8010354d:	89 e5                	mov    %esp,%ebp
8010354f:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103552:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103559:	e8 85 1c 00 00       	call   801051e3 <acquire>
  while (log.busy) {
8010355e:	eb 14                	jmp    80103574 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103560:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
80103567:	80 
80103568:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010356f:	e8 fa 18 00 00       	call   80104e6e <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103574:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103579:	85 c0                	test   %eax,%eax
8010357b:	75 e3                	jne    80103560 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
8010357d:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
80103584:	00 00 00 
  release(&log.lock);
80103587:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010358e:	e8 b2 1c 00 00       	call   80105245 <release>
}
80103593:	c9                   	leave  
80103594:	c3                   	ret    

80103595 <commit_trans>:

void
commit_trans(void)
{
80103595:	55                   	push   %ebp
80103596:	89 e5                	mov    %esp,%ebp
80103598:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
8010359b:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035a0:	85 c0                	test   %eax,%eax
801035a2:	7e 19                	jle    801035bd <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801035a4:	e8 07 ff ff ff       	call   801034b0 <write_head>
    install_trans(); // Now install writes to home locations
801035a9:	e8 e5 fd ff ff       	call   80103393 <install_trans>
    log.lh.n = 0; 
801035ae:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801035b5:	00 00 00 
    write_head();    // Erase the transaction from the log
801035b8:	e8 f3 fe ff ff       	call   801034b0 <write_head>
  }
  
  acquire(&log.lock);
801035bd:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035c4:	e8 1a 1c 00 00       	call   801051e3 <acquire>
  log.busy = 0;
801035c9:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
801035d0:	00 00 00 
  wakeup(&log);
801035d3:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035da:	e8 6b 19 00 00       	call   80104f4a <wakeup>
  release(&log.lock);
801035df:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035e6:	e8 5a 1c 00 00       	call   80105245 <release>
}
801035eb:	c9                   	leave  
801035ec:	c3                   	ret    

801035ed <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801035ed:	55                   	push   %ebp
801035ee:	89 e5                	mov    %esp,%ebp
801035f0:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801035f3:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035f8:	83 f8 09             	cmp    $0x9,%eax
801035fb:	7f 12                	jg     8010360f <log_write+0x22>
801035fd:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103602:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
80103608:	83 ea 01             	sub    $0x1,%edx
8010360b:	39 d0                	cmp    %edx,%eax
8010360d:	7c 0c                	jl     8010361b <log_write+0x2e>
    panic("too big a transaction");
8010360f:	c7 04 24 bc 8a 10 80 	movl   $0x80108abc,(%esp)
80103616:	e8 2b cf ff ff       	call   80100546 <panic>
  if (!log.busy)
8010361b:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103620:	85 c0                	test   %eax,%eax
80103622:	75 0c                	jne    80103630 <log_write+0x43>
    panic("write outside of trans");
80103624:	c7 04 24 d2 8a 10 80 	movl   $0x80108ad2,(%esp)
8010362b:	e8 16 cf ff ff       	call   80100546 <panic>

  for (i = 0; i < log.lh.n; i++) {
80103630:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103637:	eb 1d                	jmp    80103656 <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010363c:	83 c0 10             	add    $0x10,%eax
8010363f:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
80103646:	89 c2                	mov    %eax,%edx
80103648:	8b 45 08             	mov    0x8(%ebp),%eax
8010364b:	8b 40 08             	mov    0x8(%eax),%eax
8010364e:	39 c2                	cmp    %eax,%edx
80103650:	74 10                	je     80103662 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103652:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103656:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010365b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010365e:	7f d9                	jg     80103639 <log_write+0x4c>
80103660:	eb 01                	jmp    80103663 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103662:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103663:	8b 45 08             	mov    0x8(%ebp),%eax
80103666:	8b 40 08             	mov    0x8(%eax),%eax
80103669:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010366c:	83 c2 10             	add    $0x10,%edx
8010366f:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103676:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
8010367c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010367f:	01 d0                	add    %edx,%eax
80103681:	83 c0 01             	add    $0x1,%eax
80103684:	89 c2                	mov    %eax,%edx
80103686:	8b 45 08             	mov    0x8(%ebp),%eax
80103689:	8b 40 04             	mov    0x4(%eax),%eax
8010368c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103690:	89 04 24             	mov    %eax,(%esp)
80103693:	e8 0e cb ff ff       	call   801001a6 <bread>
80103698:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
8010369b:	8b 45 08             	mov    0x8(%ebp),%eax
8010369e:	8d 50 18             	lea    0x18(%eax),%edx
801036a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036a4:	83 c0 18             	add    $0x18,%eax
801036a7:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036ae:	00 
801036af:	89 54 24 04          	mov    %edx,0x4(%esp)
801036b3:	89 04 24             	mov    %eax,(%esp)
801036b6:	e8 56 1e 00 00       	call   80105511 <memmove>
  bwrite(lbuf);
801036bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036be:	89 04 24             	mov    %eax,(%esp)
801036c1:	e8 17 cb ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036c9:	89 04 24             	mov    %eax,(%esp)
801036cc:	e8 46 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801036d1:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036d6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036d9:	75 0d                	jne    801036e8 <log_write+0xfb>
    log.lh.n++;
801036db:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036e0:	83 c0 01             	add    $0x1,%eax
801036e3:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
801036e8:	8b 45 08             	mov    0x8(%ebp),%eax
801036eb:	8b 00                	mov    (%eax),%eax
801036ed:	89 c2                	mov    %eax,%edx
801036ef:	83 ca 04             	or     $0x4,%edx
801036f2:	8b 45 08             	mov    0x8(%ebp),%eax
801036f5:	89 10                	mov    %edx,(%eax)
}
801036f7:	c9                   	leave  
801036f8:	c3                   	ret    
801036f9:	66 90                	xchg   %ax,%ax
801036fb:	90                   	nop

801036fc <v2p>:
801036fc:	55                   	push   %ebp
801036fd:	89 e5                	mov    %esp,%ebp
801036ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103702:	05 00 00 00 80       	add    $0x80000000,%eax
80103707:	5d                   	pop    %ebp
80103708:	c3                   	ret    

80103709 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103709:	55                   	push   %ebp
8010370a:	89 e5                	mov    %esp,%ebp
8010370c:	8b 45 08             	mov    0x8(%ebp),%eax
8010370f:	05 00 00 00 80       	add    $0x80000000,%eax
80103714:	5d                   	pop    %ebp
80103715:	c3                   	ret    

80103716 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103716:	55                   	push   %ebp
80103717:	89 e5                	mov    %esp,%ebp
80103719:	53                   	push   %ebx
8010371a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
8010371d:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103720:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103723:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103726:	89 c3                	mov    %eax,%ebx
80103728:	89 d8                	mov    %ebx,%eax
8010372a:	f0 87 02             	lock xchg %eax,(%edx)
8010372d:	89 c3                	mov    %eax,%ebx
8010372f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103732:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103735:	83 c4 10             	add    $0x10,%esp
80103738:	5b                   	pop    %ebx
80103739:	5d                   	pop    %ebp
8010373a:	c3                   	ret    

8010373b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010373b:	55                   	push   %ebp
8010373c:	89 e5                	mov    %esp,%ebp
8010373e:	83 e4 f0             	and    $0xfffffff0,%esp
80103741:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103744:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010374b:	80 
8010374c:	c7 04 24 1c 2e 11 80 	movl   $0x80112e1c,(%esp)
80103753:	e8 a1 f5 ff ff       	call   80102cf9 <kinit1>
  kvmalloc();      // kernel page table
80103758:	e8 af 49 00 00       	call   8010810c <kvmalloc>
  mpinit();        // collect info about this machine
8010375d:	e8 67 04 00 00       	call   80103bc9 <mpinit>
  lapicinit(mpbcpu());
80103762:	e8 2e 02 00 00       	call   80103995 <mpbcpu>
80103767:	89 04 24             	mov    %eax,(%esp)
8010376a:	e8 ed f8 ff ff       	call   8010305c <lapicinit>
  seginit();       // set up segments
8010376f:	e8 2d 43 00 00       	call   80107aa1 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103774:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010377a:	0f b6 00             	movzbl (%eax),%eax
8010377d:	0f b6 c0             	movzbl %al,%eax
80103780:	89 44 24 04          	mov    %eax,0x4(%esp)
80103784:	c7 04 24 e9 8a 10 80 	movl   $0x80108ae9,(%esp)
8010378b:	e8 1a cc ff ff       	call   801003aa <cprintf>
  picinit();       // interrupt controller
80103790:	e8 99 06 00 00       	call   80103e2e <picinit>
  ioapicinit();    // another interrupt controller
80103795:	e8 4f f4 ff ff       	call   80102be9 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010379a:	e8 d4 d5 ff ff       	call   80100d73 <consoleinit>
  uartinit();      // serial port
8010379f:	e8 48 36 00 00       	call   80106dec <uartinit>
  pinit();         // process table
801037a4:	e8 9e 0b 00 00       	call   80104347 <pinit>
  tvinit();        // trap vectors
801037a9:	e8 9d 31 00 00       	call   8010694b <tvinit>
  binit();         // buffer cache
801037ae:	e8 81 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037b3:	e8 4c da ff ff       	call   80101204 <fileinit>
  iinit();         // inode cache
801037b8:	e8 fc e0 ff ff       	call   801018b9 <iinit>
  ideinit();       // disk
801037bd:	e8 8c f0 ff ff       	call   8010284e <ideinit>
  if(!ismp)
801037c2:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801037c7:	85 c0                	test   %eax,%eax
801037c9:	75 05                	jne    801037d0 <main+0x95>
    timerinit();   // uniprocessor timer
801037cb:	e8 be 30 00 00       	call   8010688e <timerinit>
  startothers();   // start other processors
801037d0:	e8 87 00 00 00       	call   8010385c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037d5:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037dc:	8e 
801037dd:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037e4:	e8 48 f5 ff ff       	call   80102d31 <kinit2>
  userinit();      // first user process
801037e9:	e8 77 0c 00 00       	call   80104465 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037ee:	e8 22 00 00 00       	call   80103815 <mpmain>

801037f3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037f3:	55                   	push   %ebp
801037f4:	89 e5                	mov    %esp,%ebp
801037f6:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801037f9:	e8 25 49 00 00       	call   80108123 <switchkvm>
  seginit();
801037fe:	e8 9e 42 00 00       	call   80107aa1 <seginit>
  lapicinit(cpunum());
80103803:	e8 b1 f9 ff ff       	call   801031b9 <cpunum>
80103808:	89 04 24             	mov    %eax,(%esp)
8010380b:	e8 4c f8 ff ff       	call   8010305c <lapicinit>
  mpmain();
80103810:	e8 00 00 00 00       	call   80103815 <mpmain>

80103815 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103815:	55                   	push   %ebp
80103816:	89 e5                	mov    %esp,%ebp
80103818:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010381b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103821:	0f b6 00             	movzbl (%eax),%eax
80103824:	0f b6 c0             	movzbl %al,%eax
80103827:	89 44 24 04          	mov    %eax,0x4(%esp)
8010382b:	c7 04 24 00 8b 10 80 	movl   $0x80108b00,(%esp)
80103832:	e8 73 cb ff ff       	call   801003aa <cprintf>
  idtinit();       // load idt register
80103837:	e8 83 32 00 00       	call   80106abf <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010383c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103842:	05 a8 00 00 00       	add    $0xa8,%eax
80103847:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010384e:	00 
8010384f:	89 04 24             	mov    %eax,(%esp)
80103852:	e8 bf fe ff ff       	call   80103716 <xchg>
  scheduler();     // start running processes
80103857:	e8 ba 13 00 00       	call   80104c16 <scheduler>

8010385c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010385c:	55                   	push   %ebp
8010385d:	89 e5                	mov    %esp,%ebp
8010385f:	53                   	push   %ebx
80103860:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103863:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010386a:	e8 9a fe ff ff       	call   80103709 <p2v>
8010386f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103872:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103877:	89 44 24 08          	mov    %eax,0x8(%esp)
8010387b:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
80103882:	80 
80103883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103886:	89 04 24             	mov    %eax,(%esp)
80103889:	e8 83 1c 00 00       	call   80105511 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010388e:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
80103895:	e9 86 00 00 00       	jmp    80103920 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
8010389a:	e8 1a f9 ff ff       	call   801031b9 <cpunum>
8010389f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038a5:	05 40 f9 10 80       	add    $0x8010f940,%eax
801038aa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038ad:	74 69                	je     80103918 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038af:	e8 73 f5 ff ff       	call   80102e27 <kalloc>
801038b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ba:	83 e8 04             	sub    $0x4,%eax
801038bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038c0:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038c6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038cb:	83 e8 08             	sub    $0x8,%eax
801038ce:	c7 00 f3 37 10 80    	movl   $0x801037f3,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038d7:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038da:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801038e1:	e8 16 fe ff ff       	call   801036fc <v2p>
801038e6:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038eb:	89 04 24             	mov    %eax,(%esp)
801038ee:	e8 09 fe ff ff       	call   801036fc <v2p>
801038f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038f6:	0f b6 12             	movzbl (%edx),%edx
801038f9:	0f b6 d2             	movzbl %dl,%edx
801038fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103900:	89 14 24             	mov    %edx,(%esp)
80103903:	e8 37 f9 ff ff       	call   8010323f <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103908:	90                   	nop
80103909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010390c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103912:	85 c0                	test   %eax,%eax
80103914:	74 f3                	je     80103909 <startothers+0xad>
80103916:	eb 01                	jmp    80103919 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103918:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103919:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103920:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103925:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010392b:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103930:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103933:	0f 87 61 ff ff ff    	ja     8010389a <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103939:	83 c4 24             	add    $0x24,%esp
8010393c:	5b                   	pop    %ebx
8010393d:	5d                   	pop    %ebp
8010393e:	c3                   	ret    
8010393f:	90                   	nop

80103940 <p2v>:
80103940:	55                   	push   %ebp
80103941:	89 e5                	mov    %esp,%ebp
80103943:	8b 45 08             	mov    0x8(%ebp),%eax
80103946:	05 00 00 00 80       	add    $0x80000000,%eax
8010394b:	5d                   	pop    %ebp
8010394c:	c3                   	ret    

8010394d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010394d:	55                   	push   %ebp
8010394e:	89 e5                	mov    %esp,%ebp
80103950:	53                   	push   %ebx
80103951:	83 ec 14             	sub    $0x14,%esp
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010395b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010395f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103963:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103967:	ec                   	in     (%dx),%al
80103968:	89 c3                	mov    %eax,%ebx
8010396a:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010396d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103971:	83 c4 14             	add    $0x14,%esp
80103974:	5b                   	pop    %ebx
80103975:	5d                   	pop    %ebp
80103976:	c3                   	ret    

80103977 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103977:	55                   	push   %ebp
80103978:	89 e5                	mov    %esp,%ebp
8010397a:	83 ec 08             	sub    $0x8,%esp
8010397d:	8b 55 08             	mov    0x8(%ebp),%edx
80103980:	8b 45 0c             	mov    0xc(%ebp),%eax
80103983:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103987:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010398a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010398e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103992:	ee                   	out    %al,(%dx)
}
80103993:	c9                   	leave  
80103994:	c3                   	ret    

80103995 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103995:	55                   	push   %ebp
80103996:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103998:	a1 44 b6 10 80       	mov    0x8010b644,%eax
8010399d:	89 c2                	mov    %eax,%edx
8010399f:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
801039a4:	89 d1                	mov    %edx,%ecx
801039a6:	29 c1                	sub    %eax,%ecx
801039a8:	89 c8                	mov    %ecx,%eax
801039aa:	c1 f8 02             	sar    $0x2,%eax
801039ad:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039b3:	5d                   	pop    %ebp
801039b4:	c3                   	ret    

801039b5 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039b5:	55                   	push   %ebp
801039b6:	89 e5                	mov    %esp,%ebp
801039b8:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039bb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039c2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039c9:	eb 15                	jmp    801039e0 <sum+0x2b>
    sum += addr[i];
801039cb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039ce:	8b 45 08             	mov    0x8(%ebp),%eax
801039d1:	01 d0                	add    %edx,%eax
801039d3:	0f b6 00             	movzbl (%eax),%eax
801039d6:	0f b6 c0             	movzbl %al,%eax
801039d9:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039e3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039e6:	7c e3                	jl     801039cb <sum+0x16>
    sum += addr[i];
  return sum;
801039e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039eb:	c9                   	leave  
801039ec:	c3                   	ret    

801039ed <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039ed:	55                   	push   %ebp
801039ee:	89 e5                	mov    %esp,%ebp
801039f0:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039f3:	8b 45 08             	mov    0x8(%ebp),%eax
801039f6:	89 04 24             	mov    %eax,(%esp)
801039f9:	e8 42 ff ff ff       	call   80103940 <p2v>
801039fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a01:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a07:	01 d0                	add    %edx,%eax
80103a09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a12:	eb 3f                	jmp    80103a53 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a14:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a1b:	00 
80103a1c:	c7 44 24 04 14 8b 10 	movl   $0x80108b14,0x4(%esp)
80103a23:	80 
80103a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a27:	89 04 24             	mov    %eax,(%esp)
80103a2a:	e8 86 1a 00 00       	call   801054b5 <memcmp>
80103a2f:	85 c0                	test   %eax,%eax
80103a31:	75 1c                	jne    80103a4f <mpsearch1+0x62>
80103a33:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a3a:	00 
80103a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3e:	89 04 24             	mov    %eax,(%esp)
80103a41:	e8 6f ff ff ff       	call   801039b5 <sum>
80103a46:	84 c0                	test   %al,%al
80103a48:	75 05                	jne    80103a4f <mpsearch1+0x62>
      return (struct mp*)p;
80103a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4d:	eb 11                	jmp    80103a60 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a4f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a56:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a59:	72 b9                	jb     80103a14 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a60:	c9                   	leave  
80103a61:	c3                   	ret    

80103a62 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a62:	55                   	push   %ebp
80103a63:	89 e5                	mov    %esp,%ebp
80103a65:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a68:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a72:	83 c0 0f             	add    $0xf,%eax
80103a75:	0f b6 00             	movzbl (%eax),%eax
80103a78:	0f b6 c0             	movzbl %al,%eax
80103a7b:	89 c2                	mov    %eax,%edx
80103a7d:	c1 e2 08             	shl    $0x8,%edx
80103a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a83:	83 c0 0e             	add    $0xe,%eax
80103a86:	0f b6 00             	movzbl (%eax),%eax
80103a89:	0f b6 c0             	movzbl %al,%eax
80103a8c:	09 d0                	or     %edx,%eax
80103a8e:	c1 e0 04             	shl    $0x4,%eax
80103a91:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a94:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a98:	74 21                	je     80103abb <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a9a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103aa1:	00 
80103aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa5:	89 04 24             	mov    %eax,(%esp)
80103aa8:	e8 40 ff ff ff       	call   801039ed <mpsearch1>
80103aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ab0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ab4:	74 50                	je     80103b06 <mpsearch+0xa4>
      return mp;
80103ab6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ab9:	eb 5f                	jmp    80103b1a <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abe:	83 c0 14             	add    $0x14,%eax
80103ac1:	0f b6 00             	movzbl (%eax),%eax
80103ac4:	0f b6 c0             	movzbl %al,%eax
80103ac7:	89 c2                	mov    %eax,%edx
80103ac9:	c1 e2 08             	shl    $0x8,%edx
80103acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acf:	83 c0 13             	add    $0x13,%eax
80103ad2:	0f b6 00             	movzbl (%eax),%eax
80103ad5:	0f b6 c0             	movzbl %al,%eax
80103ad8:	09 d0                	or     %edx,%eax
80103ada:	c1 e0 0a             	shl    $0xa,%eax
80103add:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae3:	2d 00 04 00 00       	sub    $0x400,%eax
80103ae8:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103aef:	00 
80103af0:	89 04 24             	mov    %eax,(%esp)
80103af3:	e8 f5 fe ff ff       	call   801039ed <mpsearch1>
80103af8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103afb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aff:	74 05                	je     80103b06 <mpsearch+0xa4>
      return mp;
80103b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b04:	eb 14                	jmp    80103b1a <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b06:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b0d:	00 
80103b0e:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b15:	e8 d3 fe ff ff       	call   801039ed <mpsearch1>
}
80103b1a:	c9                   	leave  
80103b1b:	c3                   	ret    

80103b1c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b1c:	55                   	push   %ebp
80103b1d:	89 e5                	mov    %esp,%ebp
80103b1f:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b22:	e8 3b ff ff ff       	call   80103a62 <mpsearch>
80103b27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b2e:	74 0a                	je     80103b3a <mpconfig+0x1e>
80103b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b33:	8b 40 04             	mov    0x4(%eax),%eax
80103b36:	85 c0                	test   %eax,%eax
80103b38:	75 0a                	jne    80103b44 <mpconfig+0x28>
    return 0;
80103b3a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b3f:	e9 83 00 00 00       	jmp    80103bc7 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b47:	8b 40 04             	mov    0x4(%eax),%eax
80103b4a:	89 04 24             	mov    %eax,(%esp)
80103b4d:	e8 ee fd ff ff       	call   80103940 <p2v>
80103b52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b55:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b5c:	00 
80103b5d:	c7 44 24 04 19 8b 10 	movl   $0x80108b19,0x4(%esp)
80103b64:	80 
80103b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b68:	89 04 24             	mov    %eax,(%esp)
80103b6b:	e8 45 19 00 00       	call   801054b5 <memcmp>
80103b70:	85 c0                	test   %eax,%eax
80103b72:	74 07                	je     80103b7b <mpconfig+0x5f>
    return 0;
80103b74:	b8 00 00 00 00       	mov    $0x0,%eax
80103b79:	eb 4c                	jmp    80103bc7 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b7e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b82:	3c 01                	cmp    $0x1,%al
80103b84:	74 12                	je     80103b98 <mpconfig+0x7c>
80103b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b89:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b8d:	3c 04                	cmp    $0x4,%al
80103b8f:	74 07                	je     80103b98 <mpconfig+0x7c>
    return 0;
80103b91:	b8 00 00 00 00       	mov    $0x0,%eax
80103b96:	eb 2f                	jmp    80103bc7 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b9f:	0f b7 c0             	movzwl %ax,%eax
80103ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba9:	89 04 24             	mov    %eax,(%esp)
80103bac:	e8 04 fe ff ff       	call   801039b5 <sum>
80103bb1:	84 c0                	test   %al,%al
80103bb3:	74 07                	je     80103bbc <mpconfig+0xa0>
    return 0;
80103bb5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bba:	eb 0b                	jmp    80103bc7 <mpconfig+0xab>
  *pmp = mp;
80103bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bc2:	89 10                	mov    %edx,(%eax)
  return conf;
80103bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bc7:	c9                   	leave  
80103bc8:	c3                   	ret    

80103bc9 <mpinit>:

void
mpinit(void)
{
80103bc9:	55                   	push   %ebp
80103bca:	89 e5                	mov    %esp,%ebp
80103bcc:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103bcf:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103bd6:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103bd9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bdc:	89 04 24             	mov    %eax,(%esp)
80103bdf:	e8 38 ff ff ff       	call   80103b1c <mpconfig>
80103be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103be7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103beb:	0f 84 9c 01 00 00    	je     80103d8d <mpinit+0x1c4>
    return;
  ismp = 1;
80103bf1:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103bf8:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfe:	8b 40 24             	mov    0x24(%eax),%eax
80103c01:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c09:	83 c0 2c             	add    $0x2c,%eax
80103c0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c12:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c16:	0f b7 d0             	movzwl %ax,%edx
80103c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1c:	01 d0                	add    %edx,%eax
80103c1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c21:	e9 f4 00 00 00       	jmp    80103d1a <mpinit+0x151>
    switch(*p){
80103c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c29:	0f b6 00             	movzbl (%eax),%eax
80103c2c:	0f b6 c0             	movzbl %al,%eax
80103c2f:	83 f8 04             	cmp    $0x4,%eax
80103c32:	0f 87 bf 00 00 00    	ja     80103cf7 <mpinit+0x12e>
80103c38:	8b 04 85 5c 8b 10 80 	mov    -0x7fef74a4(,%eax,4),%eax
80103c3f:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c44:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c4a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c4e:	0f b6 d0             	movzbl %al,%edx
80103c51:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c56:	39 c2                	cmp    %eax,%edx
80103c58:	74 2d                	je     80103c87 <mpinit+0xbe>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c5d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c61:	0f b6 d0             	movzbl %al,%edx
80103c64:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c69:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c71:	c7 04 24 1e 8b 10 80 	movl   $0x80108b1e,(%esp)
80103c78:	e8 2d c7 ff ff       	call   801003aa <cprintf>
        ismp = 0;
80103c7d:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103c84:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c8a:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c8e:	0f b6 c0             	movzbl %al,%eax
80103c91:	83 e0 02             	and    $0x2,%eax
80103c94:	85 c0                	test   %eax,%eax
80103c96:	74 15                	je     80103cad <mpinit+0xe4>
        bcpu = &cpus[ncpu];
80103c98:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c9d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103ca3:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103ca8:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103cad:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103cb3:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cb8:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cbe:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103cc4:	88 02                	mov    %al,(%edx)
      ncpu++;
80103cc6:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ccb:	83 c0 01             	add    $0x1,%eax
80103cce:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103cd3:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cd7:	eb 41                	jmp    80103d1a <mpinit+0x151>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ce2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ce6:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103ceb:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cef:	eb 29                	jmp    80103d1a <mpinit+0x151>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cf1:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cf5:	eb 23                	jmp    80103d1a <mpinit+0x151>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfa:	0f b6 00             	movzbl (%eax),%eax
80103cfd:	0f b6 c0             	movzbl %al,%eax
80103d00:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d04:	c7 04 24 3c 8b 10 80 	movl   $0x80108b3c,(%esp)
80103d0b:	e8 9a c6 ff ff       	call   801003aa <cprintf>
      ismp = 0;
80103d10:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103d17:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d20:	0f 82 00 ff ff ff    	jb     80103c26 <mpinit+0x5d>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d26:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103d2b:	85 c0                	test   %eax,%eax
80103d2d:	75 1d                	jne    80103d4c <mpinit+0x183>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d2f:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103d36:	00 00 00 
    lapic = 0;
80103d39:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103d40:	00 00 00 
    ioapicid = 0;
80103d43:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
80103d4a:	eb 41                	jmp    80103d8d <mpinit+0x1c4>
    return;
  }

  if(mp->imcrp){
80103d4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d4f:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d53:	84 c0                	test   %al,%al
80103d55:	74 36                	je     80103d8d <mpinit+0x1c4>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d57:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d5e:	00 
80103d5f:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d66:	e8 0c fc ff ff       	call   80103977 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d6b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d72:	e8 d6 fb ff ff       	call   8010394d <inb>
80103d77:	83 c8 01             	or     $0x1,%eax
80103d7a:	0f b6 c0             	movzbl %al,%eax
80103d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d81:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d88:	e8 ea fb ff ff       	call   80103977 <outb>
  }
}
80103d8d:	c9                   	leave  
80103d8e:	c3                   	ret    
80103d8f:	90                   	nop

80103d90 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d90:	55                   	push   %ebp
80103d91:	89 e5                	mov    %esp,%ebp
80103d93:	83 ec 08             	sub    $0x8,%esp
80103d96:	8b 55 08             	mov    0x8(%ebp),%edx
80103d99:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d9c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103da0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103da3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103da7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dab:	ee                   	out    %al,(%dx)
}
80103dac:	c9                   	leave  
80103dad:	c3                   	ret    

80103dae <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103dae:	55                   	push   %ebp
80103daf:	89 e5                	mov    %esp,%ebp
80103db1:	83 ec 0c             	sub    $0xc,%esp
80103db4:	8b 45 08             	mov    0x8(%ebp),%eax
80103db7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103dbb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dbf:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103dc5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dc9:	0f b6 c0             	movzbl %al,%eax
80103dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dd0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103dd7:	e8 b4 ff ff ff       	call   80103d90 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103ddc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103de0:	66 c1 e8 08          	shr    $0x8,%ax
80103de4:	0f b6 c0             	movzbl %al,%eax
80103de7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103deb:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103df2:	e8 99 ff ff ff       	call   80103d90 <outb>
}
80103df7:	c9                   	leave  
80103df8:	c3                   	ret    

80103df9 <picenable>:

void
picenable(int irq)
{
80103df9:	55                   	push   %ebp
80103dfa:	89 e5                	mov    %esp,%ebp
80103dfc:	53                   	push   %ebx
80103dfd:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e00:	8b 45 08             	mov    0x8(%ebp),%eax
80103e03:	ba 01 00 00 00       	mov    $0x1,%edx
80103e08:	89 d3                	mov    %edx,%ebx
80103e0a:	89 c1                	mov    %eax,%ecx
80103e0c:	d3 e3                	shl    %cl,%ebx
80103e0e:	89 d8                	mov    %ebx,%eax
80103e10:	89 c2                	mov    %eax,%edx
80103e12:	f7 d2                	not    %edx
80103e14:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e1b:	21 d0                	and    %edx,%eax
80103e1d:	0f b7 c0             	movzwl %ax,%eax
80103e20:	89 04 24             	mov    %eax,(%esp)
80103e23:	e8 86 ff ff ff       	call   80103dae <picsetmask>
}
80103e28:	83 c4 04             	add    $0x4,%esp
80103e2b:	5b                   	pop    %ebx
80103e2c:	5d                   	pop    %ebp
80103e2d:	c3                   	ret    

80103e2e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e2e:	55                   	push   %ebp
80103e2f:	89 e5                	mov    %esp,%ebp
80103e31:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e34:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e3b:	00 
80103e3c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e43:	e8 48 ff ff ff       	call   80103d90 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e48:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e4f:	00 
80103e50:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e57:	e8 34 ff ff ff       	call   80103d90 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e5c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e63:	00 
80103e64:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e6b:	e8 20 ff ff ff       	call   80103d90 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e70:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e77:	00 
80103e78:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e7f:	e8 0c ff ff ff       	call   80103d90 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e84:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e8b:	00 
80103e8c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e93:	e8 f8 fe ff ff       	call   80103d90 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e98:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e9f:	00 
80103ea0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ea7:	e8 e4 fe ff ff       	call   80103d90 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103eac:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103eb3:	00 
80103eb4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ebb:	e8 d0 fe ff ff       	call   80103d90 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ec0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103ec7:	00 
80103ec8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ecf:	e8 bc fe ff ff       	call   80103d90 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ed4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103edb:	00 
80103edc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ee3:	e8 a8 fe ff ff       	call   80103d90 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ee8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103eef:	00 
80103ef0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ef7:	e8 94 fe ff ff       	call   80103d90 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103efc:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f03:	00 
80103f04:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f0b:	e8 80 fe ff ff       	call   80103d90 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f10:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f17:	00 
80103f18:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f1f:	e8 6c fe ff ff       	call   80103d90 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f24:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f2b:	00 
80103f2c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f33:	e8 58 fe ff ff       	call   80103d90 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f38:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f3f:	00 
80103f40:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f47:	e8 44 fe ff ff       	call   80103d90 <outb>

  if(irqmask != 0xFFFF)
80103f4c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f53:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f57:	74 12                	je     80103f6b <picinit+0x13d>
    picsetmask(irqmask);
80103f59:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f60:	0f b7 c0             	movzwl %ax,%eax
80103f63:	89 04 24             	mov    %eax,(%esp)
80103f66:	e8 43 fe ff ff       	call   80103dae <picsetmask>
}
80103f6b:	c9                   	leave  
80103f6c:	c3                   	ret    
80103f6d:	66 90                	xchg   %ax,%ax
80103f6f:	90                   	nop

80103f70 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f70:	55                   	push   %ebp
80103f71:	89 e5                	mov    %esp,%ebp
80103f73:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f86:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f89:	8b 10                	mov    (%eax),%edx
80103f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f90:	e8 8b d2 ff ff       	call   80101220 <filealloc>
80103f95:	8b 55 08             	mov    0x8(%ebp),%edx
80103f98:	89 02                	mov    %eax,(%edx)
80103f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9d:	8b 00                	mov    (%eax),%eax
80103f9f:	85 c0                	test   %eax,%eax
80103fa1:	0f 84 c8 00 00 00    	je     8010406f <pipealloc+0xff>
80103fa7:	e8 74 d2 ff ff       	call   80101220 <filealloc>
80103fac:	8b 55 0c             	mov    0xc(%ebp),%edx
80103faf:	89 02                	mov    %eax,(%edx)
80103fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb4:	8b 00                	mov    (%eax),%eax
80103fb6:	85 c0                	test   %eax,%eax
80103fb8:	0f 84 b1 00 00 00    	je     8010406f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fbe:	e8 64 ee ff ff       	call   80102e27 <kalloc>
80103fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fca:	0f 84 9e 00 00 00    	je     8010406e <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103fda:	00 00 00 
  p->writeopen = 1;
80103fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fe7:	00 00 00 
  p->nwrite = 0;
80103fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fed:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ff4:	00 00 00 
  p->nread = 0;
80103ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffa:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104001:	00 00 00 
  initlock(&p->lock, "pipe");
80104004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104007:	c7 44 24 04 70 8b 10 	movl   $0x80108b70,0x4(%esp)
8010400e:	80 
8010400f:	89 04 24             	mov    %eax,(%esp)
80104012:	e8 ab 11 00 00       	call   801051c2 <initlock>
  (*f0)->type = FD_PIPE;
80104017:	8b 45 08             	mov    0x8(%ebp),%eax
8010401a:	8b 00                	mov    (%eax),%eax
8010401c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104022:	8b 45 08             	mov    0x8(%ebp),%eax
80104025:	8b 00                	mov    (%eax),%eax
80104027:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010402b:	8b 45 08             	mov    0x8(%ebp),%eax
8010402e:	8b 00                	mov    (%eax),%eax
80104030:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104034:	8b 45 08             	mov    0x8(%ebp),%eax
80104037:	8b 00                	mov    (%eax),%eax
80104039:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010403c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010403f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104042:	8b 00                	mov    (%eax),%eax
80104044:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010404a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404d:	8b 00                	mov    (%eax),%eax
8010404f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104053:	8b 45 0c             	mov    0xc(%ebp),%eax
80104056:	8b 00                	mov    (%eax),%eax
80104058:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010405c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405f:	8b 00                	mov    (%eax),%eax
80104061:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104064:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104067:	b8 00 00 00 00       	mov    $0x0,%eax
8010406c:	eb 43                	jmp    801040b1 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010406e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010406f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104073:	74 0b                	je     80104080 <pipealloc+0x110>
    kfree((char*)p);
80104075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104078:	89 04 24             	mov    %eax,(%esp)
8010407b:	e8 0e ed ff ff       	call   80102d8e <kfree>
  if(*f0)
80104080:	8b 45 08             	mov    0x8(%ebp),%eax
80104083:	8b 00                	mov    (%eax),%eax
80104085:	85 c0                	test   %eax,%eax
80104087:	74 0d                	je     80104096 <pipealloc+0x126>
    fileclose(*f0);
80104089:	8b 45 08             	mov    0x8(%ebp),%eax
8010408c:	8b 00                	mov    (%eax),%eax
8010408e:	89 04 24             	mov    %eax,(%esp)
80104091:	e8 32 d2 ff ff       	call   801012c8 <fileclose>
  if(*f1)
80104096:	8b 45 0c             	mov    0xc(%ebp),%eax
80104099:	8b 00                	mov    (%eax),%eax
8010409b:	85 c0                	test   %eax,%eax
8010409d:	74 0d                	je     801040ac <pipealloc+0x13c>
    fileclose(*f1);
8010409f:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a2:	8b 00                	mov    (%eax),%eax
801040a4:	89 04 24             	mov    %eax,(%esp)
801040a7:	e8 1c d2 ff ff       	call   801012c8 <fileclose>
  return -1;
801040ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040b1:	c9                   	leave  
801040b2:	c3                   	ret    

801040b3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040b3:	55                   	push   %ebp
801040b4:	89 e5                	mov    %esp,%ebp
801040b6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040b9:	8b 45 08             	mov    0x8(%ebp),%eax
801040bc:	89 04 24             	mov    %eax,(%esp)
801040bf:	e8 1f 11 00 00       	call   801051e3 <acquire>
  if(writable){
801040c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040c8:	74 1f                	je     801040e9 <pipeclose+0x36>
    p->writeopen = 0;
801040ca:	8b 45 08             	mov    0x8(%ebp),%eax
801040cd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040d4:	00 00 00 
    wakeup(&p->nread);
801040d7:	8b 45 08             	mov    0x8(%ebp),%eax
801040da:	05 34 02 00 00       	add    $0x234,%eax
801040df:	89 04 24             	mov    %eax,(%esp)
801040e2:	e8 63 0e 00 00       	call   80104f4a <wakeup>
801040e7:	eb 1d                	jmp    80104106 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040f3:	00 00 00 
    wakeup(&p->nwrite);
801040f6:	8b 45 08             	mov    0x8(%ebp),%eax
801040f9:	05 38 02 00 00       	add    $0x238,%eax
801040fe:	89 04 24             	mov    %eax,(%esp)
80104101:	e8 44 0e 00 00       	call   80104f4a <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104106:	8b 45 08             	mov    0x8(%ebp),%eax
80104109:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010410f:	85 c0                	test   %eax,%eax
80104111:	75 25                	jne    80104138 <pipeclose+0x85>
80104113:	8b 45 08             	mov    0x8(%ebp),%eax
80104116:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010411c:	85 c0                	test   %eax,%eax
8010411e:	75 18                	jne    80104138 <pipeclose+0x85>
    release(&p->lock);
80104120:	8b 45 08             	mov    0x8(%ebp),%eax
80104123:	89 04 24             	mov    %eax,(%esp)
80104126:	e8 1a 11 00 00       	call   80105245 <release>
    kfree((char*)p);
8010412b:	8b 45 08             	mov    0x8(%ebp),%eax
8010412e:	89 04 24             	mov    %eax,(%esp)
80104131:	e8 58 ec ff ff       	call   80102d8e <kfree>
80104136:	eb 0b                	jmp    80104143 <pipeclose+0x90>
  } else
    release(&p->lock);
80104138:	8b 45 08             	mov    0x8(%ebp),%eax
8010413b:	89 04 24             	mov    %eax,(%esp)
8010413e:	e8 02 11 00 00       	call   80105245 <release>
}
80104143:	c9                   	leave  
80104144:	c3                   	ret    

80104145 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104145:	55                   	push   %ebp
80104146:	89 e5                	mov    %esp,%ebp
80104148:	53                   	push   %ebx
80104149:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010414c:	8b 45 08             	mov    0x8(%ebp),%eax
8010414f:	89 04 24             	mov    %eax,(%esp)
80104152:	e8 8c 10 00 00       	call   801051e3 <acquire>
  for(i = 0; i < n; i++){
80104157:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010415e:	e9 a8 00 00 00       	jmp    8010420b <pipewrite+0xc6>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104163:	8b 45 08             	mov    0x8(%ebp),%eax
80104166:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010416c:	85 c0                	test   %eax,%eax
8010416e:	74 0d                	je     8010417d <pipewrite+0x38>
80104170:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104176:	8b 40 24             	mov    0x24(%eax),%eax
80104179:	85 c0                	test   %eax,%eax
8010417b:	74 15                	je     80104192 <pipewrite+0x4d>
        release(&p->lock);
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	89 04 24             	mov    %eax,(%esp)
80104183:	e8 bd 10 00 00       	call   80105245 <release>
        return -1;
80104188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010418d:	e9 9f 00 00 00       	jmp    80104231 <pipewrite+0xec>
      }
      wakeup(&p->nread);
80104192:	8b 45 08             	mov    0x8(%ebp),%eax
80104195:	05 34 02 00 00       	add    $0x234,%eax
8010419a:	89 04 24             	mov    %eax,(%esp)
8010419d:	e8 a8 0d 00 00       	call   80104f4a <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041a2:	8b 45 08             	mov    0x8(%ebp),%eax
801041a5:	8b 55 08             	mov    0x8(%ebp),%edx
801041a8:	81 c2 38 02 00 00    	add    $0x238,%edx
801041ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801041b2:	89 14 24             	mov    %edx,(%esp)
801041b5:	e8 b4 0c 00 00       	call   80104e6e <sleep>
801041ba:	eb 01                	jmp    801041bd <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041bc:	90                   	nop
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041c6:	8b 45 08             	mov    0x8(%ebp),%eax
801041c9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041cf:	05 00 02 00 00       	add    $0x200,%eax
801041d4:	39 c2                	cmp    %eax,%edx
801041d6:	74 8b                	je     80104163 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041d8:	8b 45 08             	mov    0x8(%ebp),%eax
801041db:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041e1:	89 c3                	mov    %eax,%ebx
801041e3:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801041e9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801041ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801041ef:	01 ca                	add    %ecx,%edx
801041f1:	0f b6 0a             	movzbl (%edx),%ecx
801041f4:	8b 55 08             	mov    0x8(%ebp),%edx
801041f7:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
801041fb:	8d 50 01             	lea    0x1(%eax),%edx
801041fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104201:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104207:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010420b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104211:	7c a9                	jl     801041bc <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	05 34 02 00 00       	add    $0x234,%eax
8010421b:	89 04 24             	mov    %eax,(%esp)
8010421e:	e8 27 0d 00 00       	call   80104f4a <wakeup>
  release(&p->lock);
80104223:	8b 45 08             	mov    0x8(%ebp),%eax
80104226:	89 04 24             	mov    %eax,(%esp)
80104229:	e8 17 10 00 00       	call   80105245 <release>
  return n;
8010422e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104231:	83 c4 24             	add    $0x24,%esp
80104234:	5b                   	pop    %ebx
80104235:	5d                   	pop    %ebp
80104236:	c3                   	ret    

80104237 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104237:	55                   	push   %ebp
80104238:	89 e5                	mov    %esp,%ebp
8010423a:	53                   	push   %ebx
8010423b:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010423e:	8b 45 08             	mov    0x8(%ebp),%eax
80104241:	89 04 24             	mov    %eax,(%esp)
80104244:	e8 9a 0f 00 00       	call   801051e3 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104249:	eb 3a                	jmp    80104285 <piperead+0x4e>
    if(proc->killed){
8010424b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104251:	8b 40 24             	mov    0x24(%eax),%eax
80104254:	85 c0                	test   %eax,%eax
80104256:	74 15                	je     8010426d <piperead+0x36>
      release(&p->lock);
80104258:	8b 45 08             	mov    0x8(%ebp),%eax
8010425b:	89 04 24             	mov    %eax,(%esp)
8010425e:	e8 e2 0f 00 00       	call   80105245 <release>
      return -1;
80104263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104268:	e9 b7 00 00 00       	jmp    80104324 <piperead+0xed>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010426d:	8b 45 08             	mov    0x8(%ebp),%eax
80104270:	8b 55 08             	mov    0x8(%ebp),%edx
80104273:	81 c2 34 02 00 00    	add    $0x234,%edx
80104279:	89 44 24 04          	mov    %eax,0x4(%esp)
8010427d:	89 14 24             	mov    %edx,(%esp)
80104280:	e8 e9 0b 00 00       	call   80104e6e <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104285:	8b 45 08             	mov    0x8(%ebp),%eax
80104288:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010428e:	8b 45 08             	mov    0x8(%ebp),%eax
80104291:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104297:	39 c2                	cmp    %eax,%edx
80104299:	75 0d                	jne    801042a8 <piperead+0x71>
8010429b:	8b 45 08             	mov    0x8(%ebp),%eax
8010429e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042a4:	85 c0                	test   %eax,%eax
801042a6:	75 a3                	jne    8010424b <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042af:	eb 4a                	jmp    801042fb <piperead+0xc4>
    if(p->nread == p->nwrite)
801042b1:	8b 45 08             	mov    0x8(%ebp),%eax
801042b4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042ba:	8b 45 08             	mov    0x8(%ebp),%eax
801042bd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c3:	39 c2                	cmp    %eax,%edx
801042c5:	74 3e                	je     80104305 <piperead+0xce>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801042cd:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801042d0:	8b 45 08             	mov    0x8(%ebp),%eax
801042d3:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042d9:	89 c3                	mov    %eax,%ebx
801042db:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801042e1:	8b 55 08             	mov    0x8(%ebp),%edx
801042e4:	0f b6 54 1a 34       	movzbl 0x34(%edx,%ebx,1),%edx
801042e9:	88 11                	mov    %dl,(%ecx)
801042eb:	8d 50 01             	lea    0x1(%eax),%edx
801042ee:	8b 45 08             	mov    0x8(%ebp),%eax
801042f1:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fe:	3b 45 10             	cmp    0x10(%ebp),%eax
80104301:	7c ae                	jl     801042b1 <piperead+0x7a>
80104303:	eb 01                	jmp    80104306 <piperead+0xcf>
    if(p->nread == p->nwrite)
      break;
80104305:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104306:	8b 45 08             	mov    0x8(%ebp),%eax
80104309:	05 38 02 00 00       	add    $0x238,%eax
8010430e:	89 04 24             	mov    %eax,(%esp)
80104311:	e8 34 0c 00 00       	call   80104f4a <wakeup>
  release(&p->lock);
80104316:	8b 45 08             	mov    0x8(%ebp),%eax
80104319:	89 04 24             	mov    %eax,(%esp)
8010431c:	e8 24 0f 00 00       	call   80105245 <release>
  return i;
80104321:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104324:	83 c4 24             	add    $0x24,%esp
80104327:	5b                   	pop    %ebx
80104328:	5d                   	pop    %ebp
80104329:	c3                   	ret    
8010432a:	66 90                	xchg   %ax,%ax

8010432c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010432c:	55                   	push   %ebp
8010432d:	89 e5                	mov    %esp,%ebp
8010432f:	53                   	push   %ebx
80104330:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104333:	9c                   	pushf  
80104334:	5b                   	pop    %ebx
80104335:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104338:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010433b:	83 c4 10             	add    $0x10,%esp
8010433e:	5b                   	pop    %ebx
8010433f:	5d                   	pop    %ebp
80104340:	c3                   	ret    

80104341 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104341:	55                   	push   %ebp
80104342:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104344:	fb                   	sti    
}
80104345:	5d                   	pop    %ebp
80104346:	c3                   	ret    

80104347 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);
void
pinit(void)
{
80104347:	55                   	push   %ebp
80104348:	89 e5                	mov    %esp,%ebp
8010434a:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
8010434d:	c7 44 24 04 75 8b 10 	movl   $0x80108b75,0x4(%esp)
80104354:	80 
80104355:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010435c:	e8 61 0e 00 00       	call   801051c2 <initlock>
}
80104361:	c9                   	leave  
80104362:	c3                   	ret    

80104363 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104363:	55                   	push   %ebp
80104364:	89 e5                	mov    %esp,%ebp
80104366:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104369:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104370:	e8 6e 0e 00 00       	call   801051e3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104375:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010437c:	eb 11                	jmp    8010438f <allocproc+0x2c>
    if(p->state == UNUSED)
8010437e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104381:	8b 40 0c             	mov    0xc(%eax),%eax
80104384:	85 c0                	test   %eax,%eax
80104386:	74 26                	je     801043ae <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104388:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
8010438f:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
80104396:	72 e6                	jb     8010437e <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104398:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010439f:	e8 a1 0e 00 00       	call   80105245 <release>
  return 0;
801043a4:	b8 00 00 00 00       	mov    $0x0,%eax
801043a9:	e9 b5 00 00 00       	jmp    80104463 <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043ae:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b2:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043b9:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043c1:	89 42 10             	mov    %eax,0x10(%edx)
801043c4:	83 c0 01             	add    $0x1,%eax
801043c7:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043cc:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043d3:	e8 6d 0e 00 00       	call   80105245 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043d8:	e8 4a ea ff ff       	call   80102e27 <kalloc>
801043dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e0:	89 42 08             	mov    %eax,0x8(%edx)
801043e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e6:	8b 40 08             	mov    0x8(%eax),%eax
801043e9:	85 c0                	test   %eax,%eax
801043eb:	75 11                	jne    801043fe <allocproc+0x9b>
    p->state = UNUSED;
801043ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043f7:	b8 00 00 00 00       	mov    $0x0,%eax
801043fc:	eb 65                	jmp    80104463 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
801043fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104401:	8b 40 08             	mov    0x8(%eax),%eax
80104404:	05 00 10 00 00       	add    $0x1000,%eax
80104409:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010440c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104413:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104416:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104419:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010441d:	ba 00 69 10 80       	mov    $0x80106900,%edx
80104422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104425:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104427:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010442b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104431:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104437:	8b 40 1c             	mov    0x1c(%eax),%eax
8010443a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104441:	00 
80104442:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104449:	00 
8010444a:	89 04 24             	mov    %eax,(%esp)
8010444d:	e8 ec 0f 00 00       	call   8010543e <memset>
  p->context->eip = (uint)forkret;
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	8b 40 1c             	mov    0x1c(%eax),%eax
80104458:	ba 42 4e 10 80       	mov    $0x80104e42,%edx
8010445d:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104460:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104463:	c9                   	leave  
80104464:	c3                   	ret    

80104465 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104465:	55                   	push   %ebp
80104466:	89 e5                	mov    %esp,%ebp
80104468:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010446b:	e8 f3 fe ff ff       	call   80104363 <allocproc>
80104470:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104476:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
8010447b:	c7 04 24 27 2e 10 80 	movl   $0x80102e27,(%esp)
80104482:	e8 c8 3b 00 00       	call   8010804f <setupkvm>
80104487:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010448a:	89 42 04             	mov    %eax,0x4(%edx)
8010448d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104490:	8b 40 04             	mov    0x4(%eax),%eax
80104493:	85 c0                	test   %eax,%eax
80104495:	75 0c                	jne    801044a3 <userinit+0x3e>
    panic("userinit: out of memory?");
80104497:	c7 04 24 7c 8b 10 80 	movl   $0x80108b7c,(%esp)
8010449e:	e8 a3 c0 ff ff       	call   80100546 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044a3:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ab:	8b 40 04             	mov    0x4(%eax),%eax
801044ae:	89 54 24 08          	mov    %edx,0x8(%esp)
801044b2:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044b9:	80 
801044ba:	89 04 24             	mov    %eax,(%esp)
801044bd:	e8 e5 3d 00 00       	call   801082a7 <inituvm>
  p->sz = PGSIZE;
801044c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ce:	8b 40 18             	mov    0x18(%eax),%eax
801044d1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044d8:	00 
801044d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044e0:	00 
801044e1:	89 04 24             	mov    %eax,(%esp)
801044e4:	e8 55 0f 00 00       	call   8010543e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ec:	8b 40 18             	mov    0x18(%eax),%eax
801044ef:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f8:	8b 40 18             	mov    0x18(%eax),%eax
801044fb:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 18             	mov    0x18(%eax),%eax
80104507:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450a:	8b 52 18             	mov    0x18(%edx),%edx
8010450d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104511:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 18             	mov    0x18(%eax),%eax
8010451b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010451e:	8b 52 18             	mov    0x18(%edx),%edx
80104521:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104525:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	8b 40 18             	mov    0x18(%eax),%eax
8010452f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104539:	8b 40 18             	mov    0x18(%eax),%eax
8010453c:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104546:	8b 40 18             	mov    0x18(%eax),%eax
80104549:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104553:	83 c0 6c             	add    $0x6c,%eax
80104556:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010455d:	00 
8010455e:	c7 44 24 04 95 8b 10 	movl   $0x80108b95,0x4(%esp)
80104565:	80 
80104566:	89 04 24             	mov    %eax,(%esp)
80104569:	e8 00 11 00 00       	call   8010566e <safestrcpy>
  p->cwd = namei("/");
8010456e:	c7 04 24 9e 8b 10 80 	movl   $0x80108b9e,(%esp)
80104575:	e8 b7 e1 ff ff       	call   80102731 <namei>
8010457a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010457d:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
80104580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104583:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010458a:	c9                   	leave  
8010458b:	c3                   	ret    

8010458c <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010458c:	55                   	push   %ebp
8010458d:	89 e5                	mov    %esp,%ebp
8010458f:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104592:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104598:	8b 00                	mov    (%eax),%eax
8010459a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010459d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045a1:	7e 34                	jle    801045d7 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045a3:	8b 55 08             	mov    0x8(%ebp),%edx
801045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a9:	01 c2                	add    %eax,%edx
801045ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045b1:	8b 40 04             	mov    0x4(%eax),%eax
801045b4:	89 54 24 08          	mov    %edx,0x8(%esp)
801045b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801045bf:	89 04 24             	mov    %eax,(%esp)
801045c2:	e8 5a 3e 00 00       	call   80108421 <allocuvm>
801045c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045ce:	75 41                	jne    80104611 <growproc+0x85>
      return -1;
801045d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d5:	eb 58                	jmp    8010462f <growproc+0xa3>
  } else if(n < 0){
801045d7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045db:	79 34                	jns    80104611 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045dd:	8b 55 08             	mov    0x8(%ebp),%edx
801045e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e3:	01 c2                	add    %eax,%edx
801045e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045eb:	8b 40 04             	mov    0x4(%eax),%eax
801045ee:	89 54 24 08          	mov    %edx,0x8(%esp)
801045f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f5:	89 54 24 04          	mov    %edx,0x4(%esp)
801045f9:	89 04 24             	mov    %eax,(%esp)
801045fc:	e8 fa 3e 00 00       	call   801084fb <deallocuvm>
80104601:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104604:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104608:	75 07                	jne    80104611 <growproc+0x85>
      return -1;
8010460a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010460f:	eb 1e                	jmp    8010462f <growproc+0xa3>
  }
  proc->sz = sz;
80104611:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104617:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010461a:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010461c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104622:	89 04 24             	mov    %eax,(%esp)
80104625:	e8 16 3b 00 00       	call   80108140 <switchuvm>
  return 0;
8010462a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010462f:	c9                   	leave  
80104630:	c3                   	ret    

80104631 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104631:	55                   	push   %ebp
80104632:	89 e5                	mov    %esp,%ebp
80104634:	57                   	push   %edi
80104635:	56                   	push   %esi
80104636:	53                   	push   %ebx
80104637:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010463a:	e8 24 fd ff ff       	call   80104363 <allocproc>
8010463f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104642:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104646:	75 0a                	jne    80104652 <fork+0x21>
    return -1;
80104648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464d:	e9 6c 01 00 00       	jmp    801047be <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104652:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104658:	8b 10                	mov    (%eax),%edx
8010465a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104660:	8b 40 04             	mov    0x4(%eax),%eax
80104663:	89 54 24 04          	mov    %edx,0x4(%esp)
80104667:	89 04 24             	mov    %eax,(%esp)
8010466a:	e8 28 40 00 00       	call   80108697 <copyuvm>
8010466f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104672:	89 42 04             	mov    %eax,0x4(%edx)
80104675:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104678:	8b 40 04             	mov    0x4(%eax),%eax
8010467b:	85 c0                	test   %eax,%eax
8010467d:	75 2c                	jne    801046ab <fork+0x7a>
    kfree(np->kstack);
8010467f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104682:	8b 40 08             	mov    0x8(%eax),%eax
80104685:	89 04 24             	mov    %eax,(%esp)
80104688:	e8 01 e7 ff ff       	call   80102d8e <kfree>
    np->kstack = 0;
8010468d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104690:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104697:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a6:	e9 13 01 00 00       	jmp    801047be <fork+0x18d>
  }
  np->sz = proc->sz;
801046ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b1:	8b 10                	mov    (%eax),%edx
801046b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b6:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046b8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c2:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c8:	8b 50 18             	mov    0x18(%eax),%edx
801046cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d1:	8b 40 18             	mov    0x18(%eax),%eax
801046d4:	89 c3                	mov    %eax,%ebx
801046d6:	b8 13 00 00 00       	mov    $0x13,%eax
801046db:	89 d7                	mov    %edx,%edi
801046dd:	89 de                	mov    %ebx,%esi
801046df:	89 c1                	mov    %eax,%ecx
801046e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e6:	8b 40 18             	mov    0x18(%eax),%eax
801046e9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046f7:	eb 3d                	jmp    80104736 <fork+0x105>
    if(proc->ofile[i])
801046f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104702:	83 c2 08             	add    $0x8,%edx
80104705:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104709:	85 c0                	test   %eax,%eax
8010470b:	74 25                	je     80104732 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010470d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104713:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104716:	83 c2 08             	add    $0x8,%edx
80104719:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010471d:	89 04 24             	mov    %eax,(%esp)
80104720:	e8 5b cb ff ff       	call   80101280 <filedup>
80104725:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104728:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010472b:	83 c1 08             	add    $0x8,%ecx
8010472e:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104732:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104736:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010473a:	7e bd                	jle    801046f9 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010473c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104742:	8b 40 68             	mov    0x68(%eax),%eax
80104745:	89 04 24             	mov    %eax,(%esp)
80104748:	e8 f1 d3 ff ff       	call   80101b3e <idup>
8010474d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104750:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104753:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104756:	8b 40 10             	mov    0x10(%eax),%eax
80104759:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
8010475c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104766:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010476f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104772:	83 c0 6c             	add    $0x6c,%eax
80104775:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010477c:	00 
8010477d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104781:	89 04 24             	mov    %eax,(%esp)
80104784:	e8 e5 0e 00 00       	call   8010566e <safestrcpy>
  acquire(&tickslock);
80104789:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80104790:	e8 4e 0a 00 00       	call   801051e3 <acquire>
  np->ctime = ticks;			// set creation time 
80104795:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
8010479a:	89 c2                	mov    %eax,%edx
8010479c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479f:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
801047a2:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801047a9:	e8 97 0a 00 00       	call   80105245 <release>
  np->rtime = 0;			// init running time
801047ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b1:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047b8:	00 00 00 
    case _3Q:
      np->priority = HIGH;		// upon creation, process's priority is HIGH
      np->qvalue = 0;
      break;
  }
  return pid;
801047bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047be:	83 c4 2c             	add    $0x2c,%esp
801047c1:	5b                   	pop    %ebx
801047c2:	5e                   	pop    %esi
801047c3:	5f                   	pop    %edi
801047c4:	5d                   	pop    %ebp
801047c5:	c3                   	ret    

801047c6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047c6:	55                   	push   %ebp
801047c7:	89 e5                	mov    %esp,%ebp
801047c9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  
  if(proc == initproc)
801047cc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047d3:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047d8:	39 c2                	cmp    %eax,%edx
801047da:	75 0c                	jne    801047e8 <exit+0x22>
    panic("init exiting");
801047dc:	c7 04 24 a0 8b 10 80 	movl   $0x80108ba0,(%esp)
801047e3:	e8 5e bd ff ff       	call   80100546 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047ef:	eb 44                	jmp    80104835 <exit+0x6f>
    if(proc->ofile[fd]){
801047f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047fa:	83 c2 08             	add    $0x8,%edx
801047fd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104801:	85 c0                	test   %eax,%eax
80104803:	74 2c                	je     80104831 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104805:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010480e:	83 c2 08             	add    $0x8,%edx
80104811:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104815:	89 04 24             	mov    %eax,(%esp)
80104818:	e8 ab ca ff ff       	call   801012c8 <fileclose>
      proc->ofile[fd] = 0;
8010481d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104823:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104826:	83 c2 08             	add    $0x8,%edx
80104829:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104830:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104831:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104835:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104839:	7e b6                	jle    801047f1 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
8010483b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104841:	8b 40 68             	mov    0x68(%eax),%eax
80104844:	89 04 24             	mov    %eax,(%esp)
80104847:	e8 d7 d4 ff ff       	call   80101d23 <iput>
  proc->cwd = 0;
8010484c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104852:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104859:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104860:	e8 7e 09 00 00       	call   801051e3 <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104865:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486b:	8b 40 14             	mov    0x14(%eax),%eax
8010486e:	89 04 24             	mov    %eax,(%esp)
80104871:	e8 93 06 00 00       	call   80104f09 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104876:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010487d:	eb 3b                	jmp    801048ba <exit+0xf4>
    if(p->parent == proc){
8010487f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104882:	8b 50 14             	mov    0x14(%eax),%edx
80104885:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488b:	39 c2                	cmp    %eax,%edx
8010488d:	75 24                	jne    801048b3 <exit+0xed>
      p->parent = initproc;
8010488f:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104898:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010489b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489e:	8b 40 0c             	mov    0xc(%eax),%eax
801048a1:	83 f8 05             	cmp    $0x5,%eax
801048a4:	75 0d                	jne    801048b3 <exit+0xed>
        wakeup1(initproc);
801048a6:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048ab:	89 04 24             	mov    %eax,(%esp)
801048ae:	e8 56 06 00 00       	call   80104f09 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048b3:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
801048ba:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
801048c1:	72 bc                	jb     8010487f <exit+0xb9>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->priority = -1;				// clean process priority
801048c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c9:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
801048d0:	ff ff ff 
  acquire(&tickslock);
801048d3:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801048da:	e8 04 09 00 00       	call   801051e3 <acquire>
  proc->etime = ticks;				// set the current ticks as the process end time
801048df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048e5:	8b 15 c0 2d 11 80    	mov    0x80112dc0,%edx
801048eb:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
801048f1:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801048f8:	e8 48 09 00 00       	call   80105245 <release>
  proc->state = ZOMBIE;
801048fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104903:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010490a:	e8 4f 04 00 00       	call   80104d5e <sched>
  panic("zombie exit");
8010490f:	c7 04 24 ad 8b 10 80 	movl   $0x80108bad,(%esp)
80104916:	e8 2b bc ff ff       	call   80100546 <panic>

8010491b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010491b:	55                   	push   %ebp
8010491c:	89 e5                	mov    %esp,%ebp
8010491e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104921:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104928:	e8 b6 08 00 00       	call   801051e3 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010492d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104934:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010493b:	e9 9d 00 00 00       	jmp    801049dd <wait+0xc2>
      if(p->parent != proc)
80104940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104943:	8b 50 14             	mov    0x14(%eax),%edx
80104946:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494c:	39 c2                	cmp    %eax,%edx
8010494e:	0f 85 81 00 00 00    	jne    801049d5 <wait+0xba>
        continue;
      havekids = 1;
80104954:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495e:	8b 40 0c             	mov    0xc(%eax),%eax
80104961:	83 f8 05             	cmp    $0x5,%eax
80104964:	75 70                	jne    801049d6 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104969:	8b 40 10             	mov    0x10(%eax),%eax
8010496c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010496f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104972:	8b 40 08             	mov    0x8(%eax),%eax
80104975:	89 04 24             	mov    %eax,(%esp)
80104978:	e8 11 e4 ff ff       	call   80102d8e <kfree>
        p->kstack = 0;
8010497d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104980:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498a:	8b 40 04             	mov    0x4(%eax),%eax
8010498d:	89 04 24             	mov    %eax,(%esp)
80104990:	e8 22 3c 00 00       	call   801085b7 <freevm>
        p->state = UNUSED;
80104995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104998:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010499f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ac:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bd:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049c4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049cb:	e8 75 08 00 00       	call   80105245 <release>
        return pid;
801049d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049d3:	eb 56                	jmp    80104a2b <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049d5:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d6:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
801049dd:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
801049e4:	0f 82 56 ff ff ff    	jb     80104940 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049ee:	74 0d                	je     801049fd <wait+0xe2>
801049f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f6:	8b 40 24             	mov    0x24(%eax),%eax
801049f9:	85 c0                	test   %eax,%eax
801049fb:	74 13                	je     80104a10 <wait+0xf5>
      release(&ptable.lock);
801049fd:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a04:	e8 3c 08 00 00       	call   80105245 <release>
      return -1;
80104a09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a0e:	eb 1b                	jmp    80104a2b <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a16:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104a1d:	80 
80104a1e:	89 04 24             	mov    %eax,(%esp)
80104a21:	e8 48 04 00 00       	call   80104e6e <sleep>
  }
80104a26:	e9 02 ff ff ff       	jmp    8010492d <wait+0x12>
}
80104a2b:	c9                   	leave  
80104a2c:	c3                   	ret    

80104a2d <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a2d:	55                   	push   %ebp
80104a2e:	89 e5                	mov    %esp,%ebp
80104a30:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a33:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a3a:	e8 a4 07 00 00       	call   801051e3 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a3f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a46:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104a4d:	e9 d0 00 00 00       	jmp    80104b22 <wait2+0xf5>
      if(p->parent != proc)
80104a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a55:	8b 50 14             	mov    0x14(%eax),%edx
80104a58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a5e:	39 c2                	cmp    %eax,%edx
80104a60:	0f 85 b4 00 00 00    	jne    80104b1a <wait2+0xed>
        continue;
      havekids = 1;
80104a66:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a70:	8b 40 0c             	mov    0xc(%eax),%eax
80104a73:	83 f8 05             	cmp    $0x5,%eax
80104a76:	0f 85 9f 00 00 00    	jne    80104b1b <wait2+0xee>
	*rtime = p->rtime;				// sets rtime & wtime, the running and waiting pointers
80104a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7f:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a85:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a88:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;	// rtime is the current process runtime and etime is the time the process waited since his 								// creation
80104a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8d:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a96:	8b 40 7c             	mov    0x7c(%eax),%eax
80104a99:	29 c2                	sub    %eax,%edx
80104a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9e:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104aa4:	29 c2                	sub    %eax,%edx
80104aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa9:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aae:	8b 40 10             	mov    0x10(%eax),%eax
80104ab1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab7:	8b 40 08             	mov    0x8(%eax),%eax
80104aba:	89 04 24             	mov    %eax,(%esp)
80104abd:	e8 cc e2 ff ff       	call   80102d8e <kfree>
        p->kstack = 0;
80104ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acf:	8b 40 04             	mov    0x4(%eax),%eax
80104ad2:	89 04 24             	mov    %eax,(%esp)
80104ad5:	e8 dd 3a 00 00       	call   801085b7 <freevm>
        p->state = UNUSED;
80104ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104add:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afb:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b02:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b09:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b10:	e8 30 07 00 00       	call   80105245 <release>
        return pid;
80104b15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b18:	eb 56                	jmp    80104b70 <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b1a:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b1b:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104b22:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
80104b29:	0f 82 23 ff ff ff    	jb     80104a52 <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b2f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b33:	74 0d                	je     80104b42 <wait2+0x115>
80104b35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b3b:	8b 40 24             	mov    0x24(%eax),%eax
80104b3e:	85 c0                	test   %eax,%eax
80104b40:	74 13                	je     80104b55 <wait2+0x128>
      release(&ptable.lock);
80104b42:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b49:	e8 f7 06 00 00       	call   80105245 <release>
      return -1;
80104b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b53:	eb 1b                	jmp    80104b70 <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5b:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b62:	80 
80104b63:	89 04 24             	mov    %eax,(%esp)
80104b66:	e8 03 03 00 00       	call   80104e6e <sleep>
  }
80104b6b:	e9 cf fe ff ff       	jmp    80104a3f <wait2+0x12>
  
  
  return proc->pid;
}
80104b70:	c9                   	leave  
80104b71:	c3                   	ret    

80104b72 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b72:	55                   	push   %ebp
80104b73:	89 e5                	mov    %esp,%ebp
80104b75:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b7e:	8b 40 18             	mov    0x18(%eax),%eax
80104b81:	8b 40 44             	mov    0x44(%eax),%eax
80104b84:	89 c2                	mov    %eax,%edx
80104b86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b8c:	8b 40 04             	mov    0x4(%eax),%eax
80104b8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b93:	89 04 24             	mov    %eax,(%esp)
80104b96:	e8 0d 3c 00 00       	call   801087a8 <uva2ka>
80104b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104b9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba4:	8b 40 18             	mov    0x18(%eax),%eax
80104ba7:	8b 40 44             	mov    0x44(%eax),%eax
80104baa:	25 ff 0f 00 00       	and    $0xfff,%eax
80104baf:	85 c0                	test   %eax,%eax
80104bb1:	75 0c                	jne    80104bbf <register_handler+0x4d>
    panic("esp_offset == 0");
80104bb3:	c7 04 24 b9 8b 10 80 	movl   $0x80108bb9,(%esp)
80104bba:	e8 87 b9 ff ff       	call   80100546 <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104bbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc5:	8b 40 18             	mov    0x18(%eax),%eax
80104bc8:	8b 40 44             	mov    0x44(%eax),%eax
80104bcb:	83 e8 04             	sub    $0x4,%eax
80104bce:	89 c2                	mov    %eax,%edx
80104bd0:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
80104bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd9:	01 c2                	add    %eax,%edx
          = proc->tf->eip;
80104bdb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be1:	8b 40 18             	mov    0x18(%eax),%eax
80104be4:	8b 40 38             	mov    0x38(%eax),%eax
80104be7:	89 02                	mov    %eax,(%edx)
  proc->tf->esp -= 4;
80104be9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bef:	8b 40 18             	mov    0x18(%eax),%eax
80104bf2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bf9:	8b 52 18             	mov    0x18(%edx),%edx
80104bfc:	8b 52 44             	mov    0x44(%edx),%edx
80104bff:	83 ea 04             	sub    $0x4,%edx
80104c02:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104c05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c0b:	8b 40 18             	mov    0x18(%eax),%eax
80104c0e:	8b 55 08             	mov    0x8(%ebp),%edx
80104c11:	89 50 38             	mov    %edx,0x38(%eax)
}
80104c14:	c9                   	leave  
80104c15:	c3                   	ret    

80104c16 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c16:	55                   	push   %ebp
80104c17:	89 e5                	mov    %esp,%ebp
80104c19:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct proc *medium;
  struct proc *high;
  struct proc *head = 0;		// a pointer for the last low priority that was found.
80104c1c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  struct proc *t = ptable.proc;
80104c23:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
  uint grt_min;
  
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c2a:	e8 12 f7 ff ff       	call   80104341 <sti>
    highflag = 0;			// Indicates wheater a high priority process was found
80104c2f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    mediumflag = 0;			// Indicates wheater a medium priority process was found
80104c36:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    lowflag = 0;			// Indicates wheater a low priority process was found
80104c3d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    frr_min = 0;			
80104c44:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    grt_min = 0;
80104c4b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    
    if(head && p==head)			// if the process that was ran in the last iteration was a low priority process we're gonna 		
80104c52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c56:	74 17                	je     80104c6f <scheduler+0x59>
80104c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104c5e:	75 0f                	jne    80104c6f <scheduler+0x59>
      t = ++head;			// start our next iteration from the process after it the ptable
80104c60:	81 45 f0 98 00 00 00 	addl   $0x98,-0x10(%ebp)
80104c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c6d:	eb 0c                	jmp    80104c7b <scheduler+0x65>
    else if(head)			// for the init case where head = null
80104c6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c73:	74 06                	je     80104c7b <scheduler+0x65>
      t = head;				// head will now point for the ptable first process
80104c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c78:	89 45 ec             	mov    %eax,-0x14(%ebp)
    
    acquire(&tickslock);
80104c7b:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80104c82:	e8 5c 05 00 00       	call   801051e3 <acquire>
    currentime = ticks;			// get ticks before each iteration so that every process in the grt case we'll be calculated 
80104c87:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
80104c8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    release(&tickslock);  		// according to the same tick count
80104c8f:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80104c96:	e8 aa 05 00 00       	call   80105245 <release>
    int i=0;
80104c9b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    acquire(&ptable.lock); 
80104ca2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ca9:	e8 35 05 00 00       	call   801051e3 <acquire>
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104cae:	e9 90 00 00 00       	jmp    80104d43 <scheduler+0x12d>
    {
      if(t >= &ptable.proc[NPROC])	// if our t iteator pointer passed the last process address in the ptable we'll
80104cb3:	81 7d ec 74 25 11 80 	cmpl   $0x80112574,-0x14(%ebp)
80104cba:	72 07                	jb     80104cc3 <scheduler+0xad>
	t = ptable.proc;		// reset t to point to the first process
80104cbc:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
      if(t->state != RUNNABLE)
80104cc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cc6:	8b 40 0c             	mov    0xc(%eax),%eax
80104cc9:	83 f8 03             	cmp    $0x3,%eax
80104ccc:	74 09                	je     80104cd7 <scheduler+0xc1>
      {
	t++;
80104cce:	81 45 ec 98 00 00 00 	addl   $0x98,-0x14(%ebp)
	continue;
80104cd5:	eb 68                	jmp    80104d3f <scheduler+0x129>
      }
      switch(SCHEDFLAG)
      {
	default:			// the deafult RR case stayed as it was
	  p = t;
80104cd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cda:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  proc = p;
80104cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce0:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
80104ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce9:	89 04 24             	mov    %eax,(%esp)
80104cec:	e8 4f 34 00 00       	call   80108140 <switchuvm>
	  p->state = RUNNING;
80104cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  p->quanta = QUANTA;
80104cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cfe:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104d05:	00 00 00 
	  swtch(&cpu->scheduler, proc->context);
80104d08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d0e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d11:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d18:	83 c2 04             	add    $0x4,%edx
80104d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d1f:	89 14 24             	mov    %edx,(%esp)
80104d22:	e8 bd 09 00 00       	call   801056e4 <swtch>
	  switchkvm();
80104d27:	e8 f7 33 00 00       	call   80108123 <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
80104d2c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104d33:	00 00 00 00 
	  break;
80104d37:	90                   	nop
	    lowflag = 1;
	    t->quanta = QUANTA;					// give the process quanta for his executing
	  }
	  break;
      }
      t++;
80104d38:	81 45 ec 98 00 00 00 	addl   $0x98,-0x14(%ebp)
    acquire(&tickslock);
    currentime = ticks;			// get ticks before each iteration so that every process in the grt case we'll be calculated 
    release(&tickslock);  		// according to the same tick count
    int i=0;
    acquire(&ptable.lock); 
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104d3f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104d43:	83 7d e8 3f          	cmpl   $0x3f,-0x18(%ebp)
80104d47:	0f 8e 66 ff ff ff    	jle    80104cb3 <scheduler+0x9d>
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
      }
    }
    release(&ptable.lock);
80104d4d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d54:	e8 ec 04 00 00       	call   80105245 <release>
    }
80104d59:	e9 cc fe ff ff       	jmp    80104c2a <scheduler+0x14>

80104d5e <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d5e:	55                   	push   %ebp
80104d5f:	89 e5                	mov    %esp,%ebp
80104d61:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d64:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d6b:	e8 9d 05 00 00       	call   8010530d <holding>
80104d70:	85 c0                	test   %eax,%eax
80104d72:	75 0c                	jne    80104d80 <sched+0x22>
    panic("sched ptable.lock");
80104d74:	c7 04 24 c9 8b 10 80 	movl   $0x80108bc9,(%esp)
80104d7b:	e8 c6 b7 ff ff       	call   80100546 <panic>
  if(cpu->ncli != 1)
80104d80:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d86:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d8c:	83 f8 01             	cmp    $0x1,%eax
80104d8f:	74 0c                	je     80104d9d <sched+0x3f>
    panic("sched locks");
80104d91:	c7 04 24 db 8b 10 80 	movl   $0x80108bdb,(%esp)
80104d98:	e8 a9 b7 ff ff       	call   80100546 <panic>
  if(proc->state == RUNNING)
80104d9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da3:	8b 40 0c             	mov    0xc(%eax),%eax
80104da6:	83 f8 04             	cmp    $0x4,%eax
80104da9:	75 0c                	jne    80104db7 <sched+0x59>
    panic("sched running");
80104dab:	c7 04 24 e7 8b 10 80 	movl   $0x80108be7,(%esp)
80104db2:	e8 8f b7 ff ff       	call   80100546 <panic>
  if(readeflags()&FL_IF)
80104db7:	e8 70 f5 ff ff       	call   8010432c <readeflags>
80104dbc:	25 00 02 00 00       	and    $0x200,%eax
80104dc1:	85 c0                	test   %eax,%eax
80104dc3:	74 0c                	je     80104dd1 <sched+0x73>
    panic("sched interruptible");
80104dc5:	c7 04 24 f5 8b 10 80 	movl   $0x80108bf5,(%esp)
80104dcc:	e8 75 b7 ff ff       	call   80100546 <panic>
  intena = cpu->intena;
80104dd1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dd7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104ddd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104de0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104de6:	8b 40 04             	mov    0x4(%eax),%eax
80104de9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104df0:	83 c2 1c             	add    $0x1c,%edx
80104df3:	89 44 24 04          	mov    %eax,0x4(%esp)
80104df7:	89 14 24             	mov    %edx,(%esp)
80104dfa:	e8 e5 08 00 00       	call   801056e4 <swtch>
  cpu->intena = intena;
80104dff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e05:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e08:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104e0e:	c9                   	leave  
80104e0f:	c3                   	ret    

80104e10 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	83 ec 18             	sub    $0x18,%esp
	proc->qvalue = ticks;
	release(&tickslock);
      }
      break;
  }
  acquire(&ptable.lock);  //DOC: yieldlock
80104e16:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e1d:	e8 c1 03 00 00       	call   801051e3 <acquire>
  proc->state = RUNNABLE;
80104e22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e28:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e2f:	e8 2a ff ff ff       	call   80104d5e <sched>
  release(&ptable.lock);
80104e34:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e3b:	e8 05 04 00 00       	call   80105245 <release>
  
}
80104e40:	c9                   	leave  
80104e41:	c3                   	ret    

80104e42 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e42:	55                   	push   %ebp
80104e43:	89 e5                	mov    %esp,%ebp
80104e45:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e48:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e4f:	e8 f1 03 00 00       	call   80105245 <release>

  if (first) {
80104e54:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104e59:	85 c0                	test   %eax,%eax
80104e5b:	74 0f                	je     80104e6c <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104e5d:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104e64:	00 00 00 
    initlog();
80104e67:	e8 d0 e4 ff ff       	call   8010333c <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104e6c:	c9                   	leave  
80104e6d:	c3                   	ret    

80104e6e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e6e:	55                   	push   %ebp
80104e6f:	89 e5                	mov    %esp,%ebp
80104e71:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104e74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e7a:	85 c0                	test   %eax,%eax
80104e7c:	75 0c                	jne    80104e8a <sleep+0x1c>
    panic("sleep");
80104e7e:	c7 04 24 09 8c 10 80 	movl   $0x80108c09,(%esp)
80104e85:	e8 bc b6 ff ff       	call   80100546 <panic>

  if(lk == 0)
80104e8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e8e:	75 0c                	jne    80104e9c <sleep+0x2e>
    panic("sleep without lk");
80104e90:	c7 04 24 0f 8c 10 80 	movl   $0x80108c0f,(%esp)
80104e97:	e8 aa b6 ff ff       	call   80100546 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e9c:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104ea3:	74 17                	je     80104ebc <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ea5:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104eac:	e8 32 03 00 00       	call   801051e3 <acquire>
    release(lk);
80104eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eb4:	89 04 24             	mov    %eax,(%esp)
80104eb7:	e8 89 03 00 00       	call   80105245 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104ebc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ec2:	8b 55 08             	mov    0x8(%ebp),%edx
80104ec5:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104ec8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ece:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104ed5:	e8 84 fe ff ff       	call   80104d5e <sched>

  // Tidy up.
  proc->chan = 0;
80104eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee0:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ee7:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104eee:	74 17                	je     80104f07 <sleep+0x99>
    release(&ptable.lock);
80104ef0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ef7:	e8 49 03 00 00       	call   80105245 <release>
    acquire(lk);
80104efc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eff:	89 04 24             	mov    %eax,(%esp)
80104f02:	e8 dc 02 00 00       	call   801051e3 <acquire>
  }
}
80104f07:	c9                   	leave  
80104f08:	c3                   	ret    

80104f09 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f09:	55                   	push   %ebp
80104f0a:	89 e5                	mov    %esp,%ebp
80104f0c:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f0f:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104f16:	eb 27                	jmp    80104f3f <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104f18:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f1b:	8b 40 0c             	mov    0xc(%eax),%eax
80104f1e:	83 f8 02             	cmp    $0x2,%eax
80104f21:	75 15                	jne    80104f38 <wakeup1+0x2f>
80104f23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f26:	8b 40 20             	mov    0x20(%eax),%eax
80104f29:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f2c:	75 0a                	jne    80104f38 <wakeup1+0x2f>
    {
      p->state = RUNNABLE;
80104f2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f31:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f38:	81 45 fc 98 00 00 00 	addl   $0x98,-0x4(%ebp)
80104f3f:	81 7d fc 74 25 11 80 	cmpl   $0x80112574,-0x4(%ebp)
80104f46:	72 d0                	jb     80104f18 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
    }
}
80104f48:	c9                   	leave  
80104f49:	c3                   	ret    

80104f4a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f4a:	55                   	push   %ebp
80104f4b:	89 e5                	mov    %esp,%ebp
80104f4d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104f50:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f57:	e8 87 02 00 00       	call   801051e3 <acquire>
  wakeup1(chan);
80104f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5f:	89 04 24             	mov    %eax,(%esp)
80104f62:	e8 a2 ff ff ff       	call   80104f09 <wakeup1>
  release(&ptable.lock);
80104f67:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f6e:	e8 d2 02 00 00       	call   80105245 <release>
}
80104f73:	c9                   	leave  
80104f74:	c3                   	ret    

80104f75 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f75:	55                   	push   %ebp
80104f76:	89 e5                	mov    %esp,%ebp
80104f78:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f7b:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f82:	e8 5c 02 00 00       	call   801051e3 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f87:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104f8e:	eb 44                	jmp    80104fd4 <kill+0x5f>
    if(p->pid == pid){
80104f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f93:	8b 40 10             	mov    0x10(%eax),%eax
80104f96:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f99:	75 32                	jne    80104fcd <kill+0x58>
      p->killed = 1;
80104f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa8:	8b 40 0c             	mov    0xc(%eax),%eax
80104fab:	83 f8 02             	cmp    $0x2,%eax
80104fae:	75 0a                	jne    80104fba <kill+0x45>
        p->state = RUNNABLE;
80104fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104fba:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104fc1:	e8 7f 02 00 00       	call   80105245 <release>
      return 0;
80104fc6:	b8 00 00 00 00       	mov    $0x0,%eax
80104fcb:	eb 21                	jmp    80104fee <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fcd:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104fd4:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
80104fdb:	72 b3                	jb     80104f90 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104fdd:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104fe4:	e8 5c 02 00 00       	call   80105245 <release>
  return -1;
80104fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fee:	c9                   	leave  
80104fef:	c3                   	ret    

80104ff0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ff0:	55                   	push   %ebp
80104ff1:	89 e5                	mov    %esp,%ebp
80104ff3:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff6:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104ffd:	e9 db 00 00 00       	jmp    801050dd <procdump+0xed>
    if(p->state == UNUSED)
80105002:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105005:	8b 40 0c             	mov    0xc(%eax),%eax
80105008:	85 c0                	test   %eax,%eax
8010500a:	0f 84 c5 00 00 00    	je     801050d5 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105010:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105013:	8b 40 0c             	mov    0xc(%eax),%eax
80105016:	83 f8 05             	cmp    $0x5,%eax
80105019:	77 23                	ja     8010503e <procdump+0x4e>
8010501b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501e:	8b 40 0c             	mov    0xc(%eax),%eax
80105021:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80105028:	85 c0                	test   %eax,%eax
8010502a:	74 12                	je     8010503e <procdump+0x4e>
      state = states[p->state];
8010502c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502f:	8b 40 0c             	mov    0xc(%eax),%eax
80105032:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80105039:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010503c:	eb 07                	jmp    80105045 <procdump+0x55>
    else
      state = "???";
8010503e:	c7 45 ec 20 8c 10 80 	movl   $0x80108c20,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105048:	8d 50 6c             	lea    0x6c(%eax),%edx
8010504b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504e:	8b 40 10             	mov    0x10(%eax),%eax
80105051:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105055:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105058:	89 54 24 08          	mov    %edx,0x8(%esp)
8010505c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105060:	c7 04 24 24 8c 10 80 	movl   $0x80108c24,(%esp)
80105067:	e8 3e b3 ff ff       	call   801003aa <cprintf>
    if(p->state == SLEEPING){
8010506c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506f:	8b 40 0c             	mov    0xc(%eax),%eax
80105072:	83 f8 02             	cmp    $0x2,%eax
80105075:	75 50                	jne    801050c7 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105077:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010507d:	8b 40 0c             	mov    0xc(%eax),%eax
80105080:	83 c0 08             	add    $0x8,%eax
80105083:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105086:	89 54 24 04          	mov    %edx,0x4(%esp)
8010508a:	89 04 24             	mov    %eax,(%esp)
8010508d:	e8 02 02 00 00       	call   80105294 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105092:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105099:	eb 1b                	jmp    801050b6 <procdump+0xc6>
        cprintf(" %p", pc[i]);
8010509b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801050a6:	c7 04 24 2d 8c 10 80 	movl   $0x80108c2d,(%esp)
801050ad:	e8 f8 b2 ff ff       	call   801003aa <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801050b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050b6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050ba:	7f 0b                	jg     801050c7 <procdump+0xd7>
801050bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050bf:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050c3:	85 c0                	test   %eax,%eax
801050c5:	75 d4                	jne    8010509b <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801050c7:	c7 04 24 31 8c 10 80 	movl   $0x80108c31,(%esp)
801050ce:	e8 d7 b2 ff ff       	call   801003aa <cprintf>
801050d3:	eb 01                	jmp    801050d6 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801050d5:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050d6:	81 45 f0 98 00 00 00 	addl   $0x98,-0x10(%ebp)
801050dd:	81 7d f0 74 25 11 80 	cmpl   $0x80112574,-0x10(%ebp)
801050e4:	0f 82 18 ff ff ff    	jb     80105002 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801050ea:	c9                   	leave  
801050eb:	c3                   	ret    

801050ec <nice>:

int
nice(void)
{
801050ec:	55                   	push   %ebp
801050ed:	89 e5                	mov    %esp,%ebp
801050ef:	83 ec 08             	sub    $0x8,%esp
  if(proc)
801050f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050f8:	85 c0                	test   %eax,%eax
801050fa:	74 76                	je     80105172 <nice+0x86>
  {
    if(proc->priority == HIGH)		// if the process priority was HIGH we'll now set it to MEDIUM
801050fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105102:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105108:	83 f8 03             	cmp    $0x3,%eax
8010510b:	75 38                	jne    80105145 <nice+0x59>
    {
      proc->priority--;
8010510d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105113:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80105119:	83 ea 01             	sub    $0x1,%edx
8010511c:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      proc->qvalue = proc->ctime;
80105122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105128:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010512f:	8b 52 7c             	mov    0x7c(%edx),%edx
80105132:	89 55 fc             	mov    %edx,-0x4(%ebp)
80105135:	db 45 fc             	fildl  -0x4(%ebp)
80105138:	dd 98 90 00 00 00    	fstpl  0x90(%eax)
      return 0;
8010513e:	b8 00 00 00 00       	mov    $0x0,%eax
80105143:	eb 32                	jmp    80105177 <nice+0x8b>
    }
    else if(proc->priority == MEDIUM)	// if the process priority was MEDIUM we'll now set it to LOW
80105145:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010514b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105151:	83 f8 02             	cmp    $0x2,%eax
80105154:	75 1c                	jne    80105172 <nice+0x86>
    {
      proc->priority--;
80105156:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010515c:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80105162:	83 ea 01             	sub    $0x1,%edx
80105165:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      return 0;
8010516b:	b8 00 00 00 00       	mov    $0x0,%eax
80105170:	eb 05                	jmp    80105177 <nice+0x8b>
    }
    
  }
  return -1;
80105172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105177:	c9                   	leave  
80105178:	c3                   	ret    
80105179:	66 90                	xchg   %ax,%ax
8010517b:	90                   	nop

8010517c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010517c:	55                   	push   %ebp
8010517d:	89 e5                	mov    %esp,%ebp
8010517f:	53                   	push   %ebx
80105180:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105183:	9c                   	pushf  
80105184:	5b                   	pop    %ebx
80105185:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105188:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010518b:	83 c4 10             	add    $0x10,%esp
8010518e:	5b                   	pop    %ebx
8010518f:	5d                   	pop    %ebp
80105190:	c3                   	ret    

80105191 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105191:	55                   	push   %ebp
80105192:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105194:	fa                   	cli    
}
80105195:	5d                   	pop    %ebp
80105196:	c3                   	ret    

80105197 <sti>:

static inline void
sti(void)
{
80105197:	55                   	push   %ebp
80105198:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010519a:	fb                   	sti    
}
8010519b:	5d                   	pop    %ebp
8010519c:	c3                   	ret    

8010519d <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010519d:	55                   	push   %ebp
8010519e:	89 e5                	mov    %esp,%ebp
801051a0:	53                   	push   %ebx
801051a1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801051a4:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801051a7:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801051aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801051ad:	89 c3                	mov    %eax,%ebx
801051af:	89 d8                	mov    %ebx,%eax
801051b1:	f0 87 02             	lock xchg %eax,(%edx)
801051b4:	89 c3                	mov    %eax,%ebx
801051b6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801051b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801051bc:	83 c4 10             	add    $0x10,%esp
801051bf:	5b                   	pop    %ebx
801051c0:	5d                   	pop    %ebp
801051c1:	c3                   	ret    

801051c2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801051c2:	55                   	push   %ebp
801051c3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051c5:	8b 45 08             	mov    0x8(%ebp),%eax
801051c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801051cb:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801051ce:	8b 45 08             	mov    0x8(%ebp),%eax
801051d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801051d7:	8b 45 08             	mov    0x8(%ebp),%eax
801051da:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051e1:	5d                   	pop    %ebp
801051e2:	c3                   	ret    

801051e3 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051e3:	55                   	push   %ebp
801051e4:	89 e5                	mov    %esp,%ebp
801051e6:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051e9:	e8 49 01 00 00       	call   80105337 <pushcli>
  if(holding(lk))
801051ee:	8b 45 08             	mov    0x8(%ebp),%eax
801051f1:	89 04 24             	mov    %eax,(%esp)
801051f4:	e8 14 01 00 00       	call   8010530d <holding>
801051f9:	85 c0                	test   %eax,%eax
801051fb:	74 0c                	je     80105209 <acquire+0x26>
    panic("acquire");
801051fd:	c7 04 24 5d 8c 10 80 	movl   $0x80108c5d,(%esp)
80105204:	e8 3d b3 ff ff       	call   80100546 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105209:	90                   	nop
8010520a:	8b 45 08             	mov    0x8(%ebp),%eax
8010520d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105214:	00 
80105215:	89 04 24             	mov    %eax,(%esp)
80105218:	e8 80 ff ff ff       	call   8010519d <xchg>
8010521d:	85 c0                	test   %eax,%eax
8010521f:	75 e9                	jne    8010520a <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105221:	8b 45 08             	mov    0x8(%ebp),%eax
80105224:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010522b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010522e:	8b 45 08             	mov    0x8(%ebp),%eax
80105231:	83 c0 0c             	add    $0xc,%eax
80105234:	89 44 24 04          	mov    %eax,0x4(%esp)
80105238:	8d 45 08             	lea    0x8(%ebp),%eax
8010523b:	89 04 24             	mov    %eax,(%esp)
8010523e:	e8 51 00 00 00       	call   80105294 <getcallerpcs>
}
80105243:	c9                   	leave  
80105244:	c3                   	ret    

80105245 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105245:	55                   	push   %ebp
80105246:	89 e5                	mov    %esp,%ebp
80105248:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010524b:	8b 45 08             	mov    0x8(%ebp),%eax
8010524e:	89 04 24             	mov    %eax,(%esp)
80105251:	e8 b7 00 00 00       	call   8010530d <holding>
80105256:	85 c0                	test   %eax,%eax
80105258:	75 0c                	jne    80105266 <release+0x21>
    panic("release");
8010525a:	c7 04 24 65 8c 10 80 	movl   $0x80108c65,(%esp)
80105261:	e8 e0 b2 ff ff       	call   80100546 <panic>

  lk->pcs[0] = 0;
80105266:	8b 45 08             	mov    0x8(%ebp),%eax
80105269:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105270:	8b 45 08             	mov    0x8(%ebp),%eax
80105273:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010527a:	8b 45 08             	mov    0x8(%ebp),%eax
8010527d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105284:	00 
80105285:	89 04 24             	mov    %eax,(%esp)
80105288:	e8 10 ff ff ff       	call   8010519d <xchg>

  popcli();
8010528d:	e8 ed 00 00 00       	call   8010537f <popcli>
}
80105292:	c9                   	leave  
80105293:	c3                   	ret    

80105294 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105294:	55                   	push   %ebp
80105295:	89 e5                	mov    %esp,%ebp
80105297:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010529a:	8b 45 08             	mov    0x8(%ebp),%eax
8010529d:	83 e8 08             	sub    $0x8,%eax
801052a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052a3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801052aa:	eb 38                	jmp    801052e4 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801052ac:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801052b0:	74 53                	je     80105305 <getcallerpcs+0x71>
801052b2:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801052b9:	76 4a                	jbe    80105305 <getcallerpcs+0x71>
801052bb:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801052bf:	74 44                	je     80105305 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801052c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ce:	01 c2                	add    %eax,%edx
801052d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052d3:	8b 40 04             	mov    0x4(%eax),%eax
801052d6:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801052d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052db:	8b 00                	mov    (%eax),%eax
801052dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801052e0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052e4:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052e8:	7e c2                	jle    801052ac <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052ea:	eb 19                	jmp    80105305 <getcallerpcs+0x71>
    pcs[i] = 0;
801052ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f9:	01 d0                	add    %edx,%eax
801052fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105301:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105305:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105309:	7e e1                	jle    801052ec <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010530b:	c9                   	leave  
8010530c:	c3                   	ret    

8010530d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010530d:	55                   	push   %ebp
8010530e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105310:	8b 45 08             	mov    0x8(%ebp),%eax
80105313:	8b 00                	mov    (%eax),%eax
80105315:	85 c0                	test   %eax,%eax
80105317:	74 17                	je     80105330 <holding+0x23>
80105319:	8b 45 08             	mov    0x8(%ebp),%eax
8010531c:	8b 50 08             	mov    0x8(%eax),%edx
8010531f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105325:	39 c2                	cmp    %eax,%edx
80105327:	75 07                	jne    80105330 <holding+0x23>
80105329:	b8 01 00 00 00       	mov    $0x1,%eax
8010532e:	eb 05                	jmp    80105335 <holding+0x28>
80105330:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105335:	5d                   	pop    %ebp
80105336:	c3                   	ret    

80105337 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105337:	55                   	push   %ebp
80105338:	89 e5                	mov    %esp,%ebp
8010533a:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010533d:	e8 3a fe ff ff       	call   8010517c <readeflags>
80105342:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105345:	e8 47 fe ff ff       	call   80105191 <cli>
  if(cpu->ncli++ == 0)
8010534a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105350:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105356:	85 d2                	test   %edx,%edx
80105358:	0f 94 c1             	sete   %cl
8010535b:	83 c2 01             	add    $0x1,%edx
8010535e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105364:	84 c9                	test   %cl,%cl
80105366:	74 15                	je     8010537d <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105368:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010536e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105371:	81 e2 00 02 00 00    	and    $0x200,%edx
80105377:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010537d:	c9                   	leave  
8010537e:	c3                   	ret    

8010537f <popcli>:

void
popcli(void)
{
8010537f:	55                   	push   %ebp
80105380:	89 e5                	mov    %esp,%ebp
80105382:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105385:	e8 f2 fd ff ff       	call   8010517c <readeflags>
8010538a:	25 00 02 00 00       	and    $0x200,%eax
8010538f:	85 c0                	test   %eax,%eax
80105391:	74 0c                	je     8010539f <popcli+0x20>
    panic("popcli - interruptible");
80105393:	c7 04 24 6d 8c 10 80 	movl   $0x80108c6d,(%esp)
8010539a:	e8 a7 b1 ff ff       	call   80100546 <panic>
  if(--cpu->ncli < 0)
8010539f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053a5:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801053ab:	83 ea 01             	sub    $0x1,%edx
801053ae:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801053b4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801053ba:	85 c0                	test   %eax,%eax
801053bc:	79 0c                	jns    801053ca <popcli+0x4b>
    panic("popcli");
801053be:	c7 04 24 84 8c 10 80 	movl   $0x80108c84,(%esp)
801053c5:	e8 7c b1 ff ff       	call   80100546 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801053ca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053d0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801053d6:	85 c0                	test   %eax,%eax
801053d8:	75 15                	jne    801053ef <popcli+0x70>
801053da:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053e0:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053e6:	85 c0                	test   %eax,%eax
801053e8:	74 05                	je     801053ef <popcli+0x70>
    sti();
801053ea:	e8 a8 fd ff ff       	call   80105197 <sti>
}
801053ef:	c9                   	leave  
801053f0:	c3                   	ret    
801053f1:	66 90                	xchg   %ax,%ax
801053f3:	90                   	nop

801053f4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053f4:	55                   	push   %ebp
801053f5:	89 e5                	mov    %esp,%ebp
801053f7:	57                   	push   %edi
801053f8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053fc:	8b 55 10             	mov    0x10(%ebp),%edx
801053ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105402:	89 cb                	mov    %ecx,%ebx
80105404:	89 df                	mov    %ebx,%edi
80105406:	89 d1                	mov    %edx,%ecx
80105408:	fc                   	cld    
80105409:	f3 aa                	rep stos %al,%es:(%edi)
8010540b:	89 ca                	mov    %ecx,%edx
8010540d:	89 fb                	mov    %edi,%ebx
8010540f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105412:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105415:	5b                   	pop    %ebx
80105416:	5f                   	pop    %edi
80105417:	5d                   	pop    %ebp
80105418:	c3                   	ret    

80105419 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105419:	55                   	push   %ebp
8010541a:	89 e5                	mov    %esp,%ebp
8010541c:	57                   	push   %edi
8010541d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010541e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105421:	8b 55 10             	mov    0x10(%ebp),%edx
80105424:	8b 45 0c             	mov    0xc(%ebp),%eax
80105427:	89 cb                	mov    %ecx,%ebx
80105429:	89 df                	mov    %ebx,%edi
8010542b:	89 d1                	mov    %edx,%ecx
8010542d:	fc                   	cld    
8010542e:	f3 ab                	rep stos %eax,%es:(%edi)
80105430:	89 ca                	mov    %ecx,%edx
80105432:	89 fb                	mov    %edi,%ebx
80105434:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105437:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010543a:	5b                   	pop    %ebx
8010543b:	5f                   	pop    %edi
8010543c:	5d                   	pop    %ebp
8010543d:	c3                   	ret    

8010543e <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
8010543e:	55                   	push   %ebp
8010543f:	89 e5                	mov    %esp,%ebp
80105441:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105444:	8b 45 08             	mov    0x8(%ebp),%eax
80105447:	83 e0 03             	and    $0x3,%eax
8010544a:	85 c0                	test   %eax,%eax
8010544c:	75 49                	jne    80105497 <memset+0x59>
8010544e:	8b 45 10             	mov    0x10(%ebp),%eax
80105451:	83 e0 03             	and    $0x3,%eax
80105454:	85 c0                	test   %eax,%eax
80105456:	75 3f                	jne    80105497 <memset+0x59>
    c &= 0xFF;
80105458:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010545f:	8b 45 10             	mov    0x10(%ebp),%eax
80105462:	c1 e8 02             	shr    $0x2,%eax
80105465:	89 c2                	mov    %eax,%edx
80105467:	8b 45 0c             	mov    0xc(%ebp),%eax
8010546a:	89 c1                	mov    %eax,%ecx
8010546c:	c1 e1 18             	shl    $0x18,%ecx
8010546f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105472:	c1 e0 10             	shl    $0x10,%eax
80105475:	09 c1                	or     %eax,%ecx
80105477:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547a:	c1 e0 08             	shl    $0x8,%eax
8010547d:	09 c8                	or     %ecx,%eax
8010547f:	0b 45 0c             	or     0xc(%ebp),%eax
80105482:	89 54 24 08          	mov    %edx,0x8(%esp)
80105486:	89 44 24 04          	mov    %eax,0x4(%esp)
8010548a:	8b 45 08             	mov    0x8(%ebp),%eax
8010548d:	89 04 24             	mov    %eax,(%esp)
80105490:	e8 84 ff ff ff       	call   80105419 <stosl>
80105495:	eb 19                	jmp    801054b0 <memset+0x72>
  } else
    stosb(dst, c, n);
80105497:	8b 45 10             	mov    0x10(%ebp),%eax
8010549a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010549e:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801054a5:	8b 45 08             	mov    0x8(%ebp),%eax
801054a8:	89 04 24             	mov    %eax,(%esp)
801054ab:	e8 44 ff ff ff       	call   801053f4 <stosb>
  return dst;
801054b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054b3:	c9                   	leave  
801054b4:	c3                   	ret    

801054b5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801054b5:	55                   	push   %ebp
801054b6:	89 e5                	mov    %esp,%ebp
801054b8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801054bb:	8b 45 08             	mov    0x8(%ebp),%eax
801054be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801054c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801054c7:	eb 32                	jmp    801054fb <memcmp+0x46>
    if(*s1 != *s2)
801054c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054cc:	0f b6 10             	movzbl (%eax),%edx
801054cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054d2:	0f b6 00             	movzbl (%eax),%eax
801054d5:	38 c2                	cmp    %al,%dl
801054d7:	74 1a                	je     801054f3 <memcmp+0x3e>
      return *s1 - *s2;
801054d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054dc:	0f b6 00             	movzbl (%eax),%eax
801054df:	0f b6 d0             	movzbl %al,%edx
801054e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054e5:	0f b6 00             	movzbl (%eax),%eax
801054e8:	0f b6 c0             	movzbl %al,%eax
801054eb:	89 d1                	mov    %edx,%ecx
801054ed:	29 c1                	sub    %eax,%ecx
801054ef:	89 c8                	mov    %ecx,%eax
801054f1:	eb 1c                	jmp    8010550f <memcmp+0x5a>
    s1++, s2++;
801054f3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054f7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ff:	0f 95 c0             	setne  %al
80105502:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105506:	84 c0                	test   %al,%al
80105508:	75 bf                	jne    801054c9 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010550a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010550f:	c9                   	leave  
80105510:	c3                   	ret    

80105511 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105511:	55                   	push   %ebp
80105512:	89 e5                	mov    %esp,%ebp
80105514:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105517:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010551d:	8b 45 08             	mov    0x8(%ebp),%eax
80105520:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105523:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105526:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105529:	73 54                	jae    8010557f <memmove+0x6e>
8010552b:	8b 45 10             	mov    0x10(%ebp),%eax
8010552e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105531:	01 d0                	add    %edx,%eax
80105533:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105536:	76 47                	jbe    8010557f <memmove+0x6e>
    s += n;
80105538:	8b 45 10             	mov    0x10(%ebp),%eax
8010553b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010553e:	8b 45 10             	mov    0x10(%ebp),%eax
80105541:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105544:	eb 13                	jmp    80105559 <memmove+0x48>
      *--d = *--s;
80105546:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010554a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010554e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105551:	0f b6 10             	movzbl (%eax),%edx
80105554:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105557:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105559:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010555d:	0f 95 c0             	setne  %al
80105560:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105564:	84 c0                	test   %al,%al
80105566:	75 de                	jne    80105546 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105568:	eb 25                	jmp    8010558f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010556a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010556d:	0f b6 10             	movzbl (%eax),%edx
80105570:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105573:	88 10                	mov    %dl,(%eax)
80105575:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105579:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010557d:	eb 01                	jmp    80105580 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010557f:	90                   	nop
80105580:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105584:	0f 95 c0             	setne  %al
80105587:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010558b:	84 c0                	test   %al,%al
8010558d:	75 db                	jne    8010556a <memmove+0x59>
      *d++ = *s++;

  return dst;
8010558f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105592:	c9                   	leave  
80105593:	c3                   	ret    

80105594 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105594:	55                   	push   %ebp
80105595:	89 e5                	mov    %esp,%ebp
80105597:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010559a:	8b 45 10             	mov    0x10(%ebp),%eax
8010559d:	89 44 24 08          	mov    %eax,0x8(%esp)
801055a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801055a8:	8b 45 08             	mov    0x8(%ebp),%eax
801055ab:	89 04 24             	mov    %eax,(%esp)
801055ae:	e8 5e ff ff ff       	call   80105511 <memmove>
}
801055b3:	c9                   	leave  
801055b4:	c3                   	ret    

801055b5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801055b5:	55                   	push   %ebp
801055b6:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801055b8:	eb 0c                	jmp    801055c6 <strncmp+0x11>
    n--, p++, q++;
801055ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055c2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801055c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ca:	74 1a                	je     801055e6 <strncmp+0x31>
801055cc:	8b 45 08             	mov    0x8(%ebp),%eax
801055cf:	0f b6 00             	movzbl (%eax),%eax
801055d2:	84 c0                	test   %al,%al
801055d4:	74 10                	je     801055e6 <strncmp+0x31>
801055d6:	8b 45 08             	mov    0x8(%ebp),%eax
801055d9:	0f b6 10             	movzbl (%eax),%edx
801055dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801055df:	0f b6 00             	movzbl (%eax),%eax
801055e2:	38 c2                	cmp    %al,%dl
801055e4:	74 d4                	je     801055ba <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801055e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ea:	75 07                	jne    801055f3 <strncmp+0x3e>
    return 0;
801055ec:	b8 00 00 00 00       	mov    $0x0,%eax
801055f1:	eb 18                	jmp    8010560b <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801055f3:	8b 45 08             	mov    0x8(%ebp),%eax
801055f6:	0f b6 00             	movzbl (%eax),%eax
801055f9:	0f b6 d0             	movzbl %al,%edx
801055fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ff:	0f b6 00             	movzbl (%eax),%eax
80105602:	0f b6 c0             	movzbl %al,%eax
80105605:	89 d1                	mov    %edx,%ecx
80105607:	29 c1                	sub    %eax,%ecx
80105609:	89 c8                	mov    %ecx,%eax
}
8010560b:	5d                   	pop    %ebp
8010560c:	c3                   	ret    

8010560d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010560d:	55                   	push   %ebp
8010560e:	89 e5                	mov    %esp,%ebp
80105610:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105613:	8b 45 08             	mov    0x8(%ebp),%eax
80105616:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105619:	90                   	nop
8010561a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010561e:	0f 9f c0             	setg   %al
80105621:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105625:	84 c0                	test   %al,%al
80105627:	74 30                	je     80105659 <strncpy+0x4c>
80105629:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562c:	0f b6 10             	movzbl (%eax),%edx
8010562f:	8b 45 08             	mov    0x8(%ebp),%eax
80105632:	88 10                	mov    %dl,(%eax)
80105634:	8b 45 08             	mov    0x8(%ebp),%eax
80105637:	0f b6 00             	movzbl (%eax),%eax
8010563a:	84 c0                	test   %al,%al
8010563c:	0f 95 c0             	setne  %al
8010563f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105643:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105647:	84 c0                	test   %al,%al
80105649:	75 cf                	jne    8010561a <strncpy+0xd>
    ;
  while(n-- > 0)
8010564b:	eb 0c                	jmp    80105659 <strncpy+0x4c>
    *s++ = 0;
8010564d:	8b 45 08             	mov    0x8(%ebp),%eax
80105650:	c6 00 00             	movb   $0x0,(%eax)
80105653:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105657:	eb 01                	jmp    8010565a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105659:	90                   	nop
8010565a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010565e:	0f 9f c0             	setg   %al
80105661:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105665:	84 c0                	test   %al,%al
80105667:	75 e4                	jne    8010564d <strncpy+0x40>
    *s++ = 0;
  return os;
80105669:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010566c:	c9                   	leave  
8010566d:	c3                   	ret    

8010566e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010566e:	55                   	push   %ebp
8010566f:	89 e5                	mov    %esp,%ebp
80105671:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105674:	8b 45 08             	mov    0x8(%ebp),%eax
80105677:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010567a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010567e:	7f 05                	jg     80105685 <safestrcpy+0x17>
    return os;
80105680:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105683:	eb 35                	jmp    801056ba <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105685:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105689:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010568d:	7e 22                	jle    801056b1 <safestrcpy+0x43>
8010568f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105692:	0f b6 10             	movzbl (%eax),%edx
80105695:	8b 45 08             	mov    0x8(%ebp),%eax
80105698:	88 10                	mov    %dl,(%eax)
8010569a:	8b 45 08             	mov    0x8(%ebp),%eax
8010569d:	0f b6 00             	movzbl (%eax),%eax
801056a0:	84 c0                	test   %al,%al
801056a2:	0f 95 c0             	setne  %al
801056a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056a9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801056ad:	84 c0                	test   %al,%al
801056af:	75 d4                	jne    80105685 <safestrcpy+0x17>
    ;
  *s = 0;
801056b1:	8b 45 08             	mov    0x8(%ebp),%eax
801056b4:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801056b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056ba:	c9                   	leave  
801056bb:	c3                   	ret    

801056bc <strlen>:

int
strlen(const char *s)
{
801056bc:	55                   	push   %ebp
801056bd:	89 e5                	mov    %esp,%ebp
801056bf:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801056c2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801056c9:	eb 04                	jmp    801056cf <strlen+0x13>
801056cb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056cf:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056d2:	8b 45 08             	mov    0x8(%ebp),%eax
801056d5:	01 d0                	add    %edx,%eax
801056d7:	0f b6 00             	movzbl (%eax),%eax
801056da:	84 c0                	test   %al,%al
801056dc:	75 ed                	jne    801056cb <strlen+0xf>
    ;
  return n;
801056de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056e1:	c9                   	leave  
801056e2:	c3                   	ret    
801056e3:	90                   	nop

801056e4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801056e4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056e8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801056ec:	55                   	push   %ebp
  pushl %ebx
801056ed:	53                   	push   %ebx
  pushl %esi
801056ee:	56                   	push   %esi
  pushl %edi
801056ef:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056f0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056f2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056f4:	5f                   	pop    %edi
  popl %esi
801056f5:	5e                   	pop    %esi
  popl %ebx
801056f6:	5b                   	pop    %ebx
  popl %ebp
801056f7:	5d                   	pop    %ebp
  ret
801056f8:	c3                   	ret    
801056f9:	66 90                	xchg   %ax,%ax
801056fb:	90                   	nop

801056fc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801056fc:	55                   	push   %ebp
801056fd:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801056ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105702:	8b 00                	mov    (%eax),%eax
80105704:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105707:	76 0f                	jbe    80105718 <fetchint+0x1c>
80105709:	8b 45 0c             	mov    0xc(%ebp),%eax
8010570c:	8d 50 04             	lea    0x4(%eax),%edx
8010570f:	8b 45 08             	mov    0x8(%ebp),%eax
80105712:	8b 00                	mov    (%eax),%eax
80105714:	39 c2                	cmp    %eax,%edx
80105716:	76 07                	jbe    8010571f <fetchint+0x23>
    return -1;
80105718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571d:	eb 0f                	jmp    8010572e <fetchint+0x32>
  *ip = *(int*)(addr);
8010571f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105722:	8b 10                	mov    (%eax),%edx
80105724:	8b 45 10             	mov    0x10(%ebp),%eax
80105727:	89 10                	mov    %edx,(%eax)
  return 0;
80105729:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010572e:	5d                   	pop    %ebp
8010572f:	c3                   	ret    

80105730 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80105730:	55                   	push   %ebp
80105731:	89 e5                	mov    %esp,%ebp
80105733:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
80105736:	8b 45 08             	mov    0x8(%ebp),%eax
80105739:	8b 00                	mov    (%eax),%eax
8010573b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010573e:	77 07                	ja     80105747 <fetchstr+0x17>
    return -1;
80105740:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105745:	eb 45                	jmp    8010578c <fetchstr+0x5c>
  *pp = (char*)addr;
80105747:	8b 55 0c             	mov    0xc(%ebp),%edx
8010574a:	8b 45 10             	mov    0x10(%ebp),%eax
8010574d:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
8010574f:	8b 45 08             	mov    0x8(%ebp),%eax
80105752:	8b 00                	mov    (%eax),%eax
80105754:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105757:	8b 45 10             	mov    0x10(%ebp),%eax
8010575a:	8b 00                	mov    (%eax),%eax
8010575c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010575f:	eb 1e                	jmp    8010577f <fetchstr+0x4f>
    if(*s == 0)
80105761:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105764:	0f b6 00             	movzbl (%eax),%eax
80105767:	84 c0                	test   %al,%al
80105769:	75 10                	jne    8010577b <fetchstr+0x4b>
      return s - *pp;
8010576b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010576e:	8b 45 10             	mov    0x10(%ebp),%eax
80105771:	8b 00                	mov    (%eax),%eax
80105773:	89 d1                	mov    %edx,%ecx
80105775:	29 c1                	sub    %eax,%ecx
80105777:	89 c8                	mov    %ecx,%eax
80105779:	eb 11                	jmp    8010578c <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
8010577b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010577f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105782:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105785:	72 da                	jb     80105761 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010578c:	c9                   	leave  
8010578d:	c3                   	ret    

8010578e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010578e:	55                   	push   %ebp
8010578f:	89 e5                	mov    %esp,%ebp
80105791:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105794:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010579a:	8b 40 18             	mov    0x18(%eax),%eax
8010579d:	8b 50 44             	mov    0x44(%eax),%edx
801057a0:	8b 45 08             	mov    0x8(%ebp),%eax
801057a3:	c1 e0 02             	shl    $0x2,%eax
801057a6:	01 d0                	add    %edx,%eax
801057a8:	8d 48 04             	lea    0x4(%eax),%ecx
801057ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801057b4:	89 54 24 08          	mov    %edx,0x8(%esp)
801057b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801057bc:	89 04 24             	mov    %eax,(%esp)
801057bf:	e8 38 ff ff ff       	call   801056fc <fetchint>
}
801057c4:	c9                   	leave  
801057c5:	c3                   	ret    

801057c6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801057c6:	55                   	push   %ebp
801057c7:	89 e5                	mov    %esp,%ebp
801057c9:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801057cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
801057cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801057d3:	8b 45 08             	mov    0x8(%ebp),%eax
801057d6:	89 04 24             	mov    %eax,(%esp)
801057d9:	e8 b0 ff ff ff       	call   8010578e <argint>
801057de:	85 c0                	test   %eax,%eax
801057e0:	79 07                	jns    801057e9 <argptr+0x23>
    return -1;
801057e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e7:	eb 3d                	jmp    80105826 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801057e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ec:	89 c2                	mov    %eax,%edx
801057ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057f4:	8b 00                	mov    (%eax),%eax
801057f6:	39 c2                	cmp    %eax,%edx
801057f8:	73 16                	jae    80105810 <argptr+0x4a>
801057fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057fd:	89 c2                	mov    %eax,%edx
801057ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105802:	01 c2                	add    %eax,%edx
80105804:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010580a:	8b 00                	mov    (%eax),%eax
8010580c:	39 c2                	cmp    %eax,%edx
8010580e:	76 07                	jbe    80105817 <argptr+0x51>
    return -1;
80105810:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105815:	eb 0f                	jmp    80105826 <argptr+0x60>
  *pp = (char*)i;
80105817:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010581a:	89 c2                	mov    %eax,%edx
8010581c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010581f:	89 10                	mov    %edx,(%eax)
  return 0;
80105821:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105826:	c9                   	leave  
80105827:	c3                   	ret    

80105828 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105828:	55                   	push   %ebp
80105829:	89 e5                	mov    %esp,%ebp
8010582b:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010582e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105831:	89 44 24 04          	mov    %eax,0x4(%esp)
80105835:	8b 45 08             	mov    0x8(%ebp),%eax
80105838:	89 04 24             	mov    %eax,(%esp)
8010583b:	e8 4e ff ff ff       	call   8010578e <argint>
80105840:	85 c0                	test   %eax,%eax
80105842:	79 07                	jns    8010584b <argstr+0x23>
    return -1;
80105844:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105849:	eb 1e                	jmp    80105869 <argstr+0x41>
  return fetchstr(proc, addr, pp);
8010584b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010584e:	89 c2                	mov    %eax,%edx
80105850:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105859:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010585d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105861:	89 04 24             	mov    %eax,(%esp)
80105864:	e8 c7 fe ff ff       	call   80105730 <fetchstr>
}
80105869:	c9                   	leave  
8010586a:	c3                   	ret    

8010586b <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010586b:	55                   	push   %ebp
8010586c:	89 e5                	mov    %esp,%ebp
8010586e:	53                   	push   %ebx
8010586f:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105872:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105878:	8b 40 18             	mov    0x18(%eax),%eax
8010587b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010587e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105885:	78 2e                	js     801058b5 <syscall+0x4a>
80105887:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010588b:	7f 28                	jg     801058b5 <syscall+0x4a>
8010588d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105890:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105897:	85 c0                	test   %eax,%eax
80105899:	74 1a                	je     801058b5 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
8010589b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a1:	8b 58 18             	mov    0x18(%eax),%ebx
801058a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a7:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801058ae:	ff d0                	call   *%eax
801058b0:	89 43 1c             	mov    %eax,0x1c(%ebx)
801058b3:	eb 73                	jmp    80105928 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
801058b5:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801058b9:	7e 30                	jle    801058eb <syscall+0x80>
801058bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058be:	83 f8 17             	cmp    $0x17,%eax
801058c1:	77 28                	ja     801058eb <syscall+0x80>
801058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c6:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801058cd:	85 c0                	test   %eax,%eax
801058cf:	74 1a                	je     801058eb <syscall+0x80>
    proc->tf->eax = syscalls[num]();
801058d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d7:	8b 58 18             	mov    0x18(%eax),%ebx
801058da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058dd:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801058e4:	ff d0                	call   *%eax
801058e6:	89 43 1c             	mov    %eax,0x1c(%ebx)
801058e9:	eb 3d                	jmp    80105928 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801058eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f1:	8d 48 6c             	lea    0x6c(%eax),%ecx
801058f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801058fa:	8b 40 10             	mov    0x10(%eax),%eax
801058fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105900:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105904:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105908:	89 44 24 04          	mov    %eax,0x4(%esp)
8010590c:	c7 04 24 8b 8c 10 80 	movl   $0x80108c8b,(%esp)
80105913:	e8 92 aa ff ff       	call   801003aa <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105918:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010591e:	8b 40 18             	mov    0x18(%eax),%eax
80105921:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105928:	83 c4 24             	add    $0x24,%esp
8010592b:	5b                   	pop    %ebx
8010592c:	5d                   	pop    %ebp
8010592d:	c3                   	ret    
8010592e:	66 90                	xchg   %ax,%ax

80105930 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105930:	55                   	push   %ebp
80105931:	89 e5                	mov    %esp,%ebp
80105933:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105936:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105939:	89 44 24 04          	mov    %eax,0x4(%esp)
8010593d:	8b 45 08             	mov    0x8(%ebp),%eax
80105940:	89 04 24             	mov    %eax,(%esp)
80105943:	e8 46 fe ff ff       	call   8010578e <argint>
80105948:	85 c0                	test   %eax,%eax
8010594a:	79 07                	jns    80105953 <argfd+0x23>
    return -1;
8010594c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105951:	eb 50                	jmp    801059a3 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105956:	85 c0                	test   %eax,%eax
80105958:	78 21                	js     8010597b <argfd+0x4b>
8010595a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595d:	83 f8 0f             	cmp    $0xf,%eax
80105960:	7f 19                	jg     8010597b <argfd+0x4b>
80105962:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105968:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010596b:	83 c2 08             	add    $0x8,%edx
8010596e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105972:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105975:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105979:	75 07                	jne    80105982 <argfd+0x52>
    return -1;
8010597b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105980:	eb 21                	jmp    801059a3 <argfd+0x73>
  if(pfd)
80105982:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105986:	74 08                	je     80105990 <argfd+0x60>
    *pfd = fd;
80105988:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010598b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010598e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105990:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105994:	74 08                	je     8010599e <argfd+0x6e>
    *pf = f;
80105996:	8b 45 10             	mov    0x10(%ebp),%eax
80105999:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010599c:	89 10                	mov    %edx,(%eax)
  return 0;
8010599e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a3:	c9                   	leave  
801059a4:	c3                   	ret    

801059a5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801059a5:	55                   	push   %ebp
801059a6:	89 e5                	mov    %esp,%ebp
801059a8:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801059ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801059b2:	eb 30                	jmp    801059e4 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801059b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059bd:	83 c2 08             	add    $0x8,%edx
801059c0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059c4:	85 c0                	test   %eax,%eax
801059c6:	75 18                	jne    801059e0 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801059c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059d1:	8d 4a 08             	lea    0x8(%edx),%ecx
801059d4:	8b 55 08             	mov    0x8(%ebp),%edx
801059d7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801059db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059de:	eb 0f                	jmp    801059ef <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801059e0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059e4:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801059e8:	7e ca                	jle    801059b4 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801059ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059ef:	c9                   	leave  
801059f0:	c3                   	ret    

801059f1 <sys_dup>:

int
sys_dup(void)
{
801059f1:	55                   	push   %ebp
801059f2:	89 e5                	mov    %esp,%ebp
801059f4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801059f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801059fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a05:	00 
80105a06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a0d:	e8 1e ff ff ff       	call   80105930 <argfd>
80105a12:	85 c0                	test   %eax,%eax
80105a14:	79 07                	jns    80105a1d <sys_dup+0x2c>
    return -1;
80105a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1b:	eb 29                	jmp    80105a46 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a20:	89 04 24             	mov    %eax,(%esp)
80105a23:	e8 7d ff ff ff       	call   801059a5 <fdalloc>
80105a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a2f:	79 07                	jns    80105a38 <sys_dup+0x47>
    return -1;
80105a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a36:	eb 0e                	jmp    80105a46 <sys_dup+0x55>
  filedup(f);
80105a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3b:	89 04 24             	mov    %eax,(%esp)
80105a3e:	e8 3d b8 ff ff       	call   80101280 <filedup>
  return fd;
80105a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a46:	c9                   	leave  
80105a47:	c3                   	ret    

80105a48 <sys_read>:

int
sys_read(void)
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
80105a64:	e8 c7 fe ff ff       	call   80105930 <argfd>
80105a69:	85 c0                	test   %eax,%eax
80105a6b:	78 35                	js     80105aa2 <sys_read+0x5a>
80105a6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a70:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a74:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a7b:	e8 0e fd ff ff       	call   8010578e <argint>
80105a80:	85 c0                	test   %eax,%eax
80105a82:	78 1e                	js     80105aa2 <sys_read+0x5a>
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a99:	e8 28 fd ff ff       	call   801057c6 <argptr>
80105a9e:	85 c0                	test   %eax,%eax
80105aa0:	79 07                	jns    80105aa9 <sys_read+0x61>
    return -1;
80105aa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa7:	eb 19                	jmp    80105ac2 <sys_read+0x7a>
  return fileread(f, p, n);
80105aa9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105aac:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ab6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aba:	89 04 24             	mov    %eax,(%esp)
80105abd:	e8 2b b9 ff ff       	call   801013ed <fileread>
}
80105ac2:	c9                   	leave  
80105ac3:	c3                   	ret    

80105ac4 <sys_write>:

int
sys_write(void)
{
80105ac4:	55                   	push   %ebp
80105ac5:	89 e5                	mov    %esp,%ebp
80105ac7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105acd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ad8:	00 
80105ad9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ae0:	e8 4b fe ff ff       	call   80105930 <argfd>
80105ae5:	85 c0                	test   %eax,%eax
80105ae7:	78 35                	js     80105b1e <sys_write+0x5a>
80105ae9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aec:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105af7:	e8 92 fc ff ff       	call   8010578e <argint>
80105afc:	85 c0                	test   %eax,%eax
80105afe:	78 1e                	js     80105b1e <sys_write+0x5a>
80105b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b03:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b07:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b15:	e8 ac fc ff ff       	call   801057c6 <argptr>
80105b1a:	85 c0                	test   %eax,%eax
80105b1c:	79 07                	jns    80105b25 <sys_write+0x61>
    return -1;
80105b1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b23:	eb 19                	jmp    80105b3e <sys_write+0x7a>
  return filewrite(f, p, n);
80105b25:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b28:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b32:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b36:	89 04 24             	mov    %eax,(%esp)
80105b39:	e8 6b b9 ff ff       	call   801014a9 <filewrite>
}
80105b3e:	c9                   	leave  
80105b3f:	c3                   	ret    

80105b40 <sys_close>:

int
sys_close(void)
{
80105b40:	55                   	push   %ebp
80105b41:	89 e5                	mov    %esp,%ebp
80105b43:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105b46:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b49:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b50:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b5b:	e8 d0 fd ff ff       	call   80105930 <argfd>
80105b60:	85 c0                	test   %eax,%eax
80105b62:	79 07                	jns    80105b6b <sys_close+0x2b>
    return -1;
80105b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b69:	eb 24                	jmp    80105b8f <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105b6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b74:	83 c2 08             	add    $0x8,%edx
80105b77:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b7e:	00 
  fileclose(f);
80105b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b82:	89 04 24             	mov    %eax,(%esp)
80105b85:	e8 3e b7 ff ff       	call   801012c8 <fileclose>
  return 0;
80105b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b8f:	c9                   	leave  
80105b90:	c3                   	ret    

80105b91 <sys_fstat>:

int
sys_fstat(void)
{
80105b91:	55                   	push   %ebp
80105b92:	89 e5                	mov    %esp,%ebp
80105b94:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b97:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b9a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ba5:	00 
80105ba6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bad:	e8 7e fd ff ff       	call   80105930 <argfd>
80105bb2:	85 c0                	test   %eax,%eax
80105bb4:	78 1f                	js     80105bd5 <sys_fstat+0x44>
80105bb6:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105bbd:	00 
80105bbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bc5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105bcc:	e8 f5 fb ff ff       	call   801057c6 <argptr>
80105bd1:	85 c0                	test   %eax,%eax
80105bd3:	79 07                	jns    80105bdc <sys_fstat+0x4b>
    return -1;
80105bd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bda:	eb 12                	jmp    80105bee <sys_fstat+0x5d>
  return filestat(f, st);
80105bdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105be6:	89 04 24             	mov    %eax,(%esp)
80105be9:	e8 b0 b7 ff ff       	call   8010139e <filestat>
}
80105bee:	c9                   	leave  
80105bef:	c3                   	ret    

80105bf0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105bf0:	55                   	push   %ebp
80105bf1:	89 e5                	mov    %esp,%ebp
80105bf3:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105bf6:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c04:	e8 1f fc ff ff       	call   80105828 <argstr>
80105c09:	85 c0                	test   %eax,%eax
80105c0b:	78 17                	js     80105c24 <sys_link+0x34>
80105c0d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c10:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c1b:	e8 08 fc ff ff       	call   80105828 <argstr>
80105c20:	85 c0                	test   %eax,%eax
80105c22:	79 0a                	jns    80105c2e <sys_link+0x3e>
    return -1;
80105c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c29:	e9 3c 01 00 00       	jmp    80105d6a <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105c2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c31:	89 04 24             	mov    %eax,(%esp)
80105c34:	e8 f8 ca ff ff       	call   80102731 <namei>
80105c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c40:	75 0a                	jne    80105c4c <sys_link+0x5c>
    return -1;
80105c42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c47:	e9 1e 01 00 00       	jmp    80105d6a <sys_link+0x17a>

  begin_trans();
80105c4c:	e8 fb d8 ff ff       	call   8010354c <begin_trans>

  ilock(ip);
80105c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c54:	89 04 24             	mov    %eax,(%esp)
80105c57:	e8 14 bf ff ff       	call   80101b70 <ilock>
  if(ip->type == T_DIR){
80105c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c63:	66 83 f8 01          	cmp    $0x1,%ax
80105c67:	75 1a                	jne    80105c83 <sys_link+0x93>
    iunlockput(ip);
80105c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6c:	89 04 24             	mov    %eax,(%esp)
80105c6f:	e8 80 c1 ff ff       	call   80101df4 <iunlockput>
    commit_trans();
80105c74:	e8 1c d9 ff ff       	call   80103595 <commit_trans>
    return -1;
80105c79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c7e:	e9 e7 00 00 00       	jmp    80105d6a <sys_link+0x17a>
  }

  ip->nlink++;
80105c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c86:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c8a:	8d 50 01             	lea    0x1(%eax),%edx
80105c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c90:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c97:	89 04 24             	mov    %eax,(%esp)
80105c9a:	e8 15 bd ff ff       	call   801019b4 <iupdate>
  iunlock(ip);
80105c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca2:	89 04 24             	mov    %eax,(%esp)
80105ca5:	e8 14 c0 ff ff       	call   80101cbe <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105caa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105cad:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105cb0:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cb4:	89 04 24             	mov    %eax,(%esp)
80105cb7:	e8 97 ca ff ff       	call   80102753 <nameiparent>
80105cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cc3:	74 68                	je     80105d2d <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc8:	89 04 24             	mov    %eax,(%esp)
80105ccb:	e8 a0 be ff ff       	call   80101b70 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd3:	8b 10                	mov    (%eax),%edx
80105cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd8:	8b 00                	mov    (%eax),%eax
80105cda:	39 c2                	cmp    %eax,%edx
80105cdc:	75 20                	jne    80105cfe <sys_link+0x10e>
80105cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce1:	8b 40 04             	mov    0x4(%eax),%eax
80105ce4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf2:	89 04 24             	mov    %eax,(%esp)
80105cf5:	e8 74 c7 ff ff       	call   8010246e <dirlink>
80105cfa:	85 c0                	test   %eax,%eax
80105cfc:	79 0d                	jns    80105d0b <sys_link+0x11b>
    iunlockput(dp);
80105cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d01:	89 04 24             	mov    %eax,(%esp)
80105d04:	e8 eb c0 ff ff       	call   80101df4 <iunlockput>
    goto bad;
80105d09:	eb 23                	jmp    80105d2e <sys_link+0x13e>
  }
  iunlockput(dp);
80105d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0e:	89 04 24             	mov    %eax,(%esp)
80105d11:	e8 de c0 ff ff       	call   80101df4 <iunlockput>
  iput(ip);
80105d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d19:	89 04 24             	mov    %eax,(%esp)
80105d1c:	e8 02 c0 ff ff       	call   80101d23 <iput>

  commit_trans();
80105d21:	e8 6f d8 ff ff       	call   80103595 <commit_trans>

  return 0;
80105d26:	b8 00 00 00 00       	mov    $0x0,%eax
80105d2b:	eb 3d                	jmp    80105d6a <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105d2d:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d31:	89 04 24             	mov    %eax,(%esp)
80105d34:	e8 37 be ff ff       	call   80101b70 <ilock>
  ip->nlink--;
80105d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d40:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d46:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4d:	89 04 24             	mov    %eax,(%esp)
80105d50:	e8 5f bc ff ff       	call   801019b4 <iupdate>
  iunlockput(ip);
80105d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d58:	89 04 24             	mov    %eax,(%esp)
80105d5b:	e8 94 c0 ff ff       	call   80101df4 <iunlockput>
  commit_trans();
80105d60:	e8 30 d8 ff ff       	call   80103595 <commit_trans>
  return -1;
80105d65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d6a:	c9                   	leave  
80105d6b:	c3                   	ret    

80105d6c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d6c:	55                   	push   %ebp
80105d6d:	89 e5                	mov    %esp,%ebp
80105d6f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d72:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d79:	eb 4b                	jmp    80105dc6 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d85:	00 
80105d86:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d91:	8b 45 08             	mov    0x8(%ebp),%eax
80105d94:	89 04 24             	mov    %eax,(%esp)
80105d97:	e8 e1 c2 ff ff       	call   8010207d <readi>
80105d9c:	83 f8 10             	cmp    $0x10,%eax
80105d9f:	74 0c                	je     80105dad <isdirempty+0x41>
      panic("isdirempty: readi");
80105da1:	c7 04 24 a7 8c 10 80 	movl   $0x80108ca7,(%esp)
80105da8:	e8 99 a7 ff ff       	call   80100546 <panic>
    if(de.inum != 0)
80105dad:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105db1:	66 85 c0             	test   %ax,%ax
80105db4:	74 07                	je     80105dbd <isdirempty+0x51>
      return 0;
80105db6:	b8 00 00 00 00       	mov    $0x0,%eax
80105dbb:	eb 1b                	jmp    80105dd8 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc0:	83 c0 10             	add    $0x10,%eax
80105dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80105dcc:	8b 40 18             	mov    0x18(%eax),%eax
80105dcf:	39 c2                	cmp    %eax,%edx
80105dd1:	72 a8                	jb     80105d7b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105dd3:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105dd8:	c9                   	leave  
80105dd9:	c3                   	ret    

80105dda <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105dda:	55                   	push   %ebp
80105ddb:	89 e5                	mov    %esp,%ebp
80105ddd:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105de0:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105de3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dee:	e8 35 fa ff ff       	call   80105828 <argstr>
80105df3:	85 c0                	test   %eax,%eax
80105df5:	79 0a                	jns    80105e01 <sys_unlink+0x27>
    return -1;
80105df7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfc:	e9 aa 01 00 00       	jmp    80105fab <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105e01:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105e04:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105e07:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e0b:	89 04 24             	mov    %eax,(%esp)
80105e0e:	e8 40 c9 ff ff       	call   80102753 <nameiparent>
80105e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e1a:	75 0a                	jne    80105e26 <sys_unlink+0x4c>
    return -1;
80105e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e21:	e9 85 01 00 00       	jmp    80105fab <sys_unlink+0x1d1>

  begin_trans();
80105e26:	e8 21 d7 ff ff       	call   8010354c <begin_trans>

  ilock(dp);
80105e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2e:	89 04 24             	mov    %eax,(%esp)
80105e31:	e8 3a bd ff ff       	call   80101b70 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e36:	c7 44 24 04 b9 8c 10 	movl   $0x80108cb9,0x4(%esp)
80105e3d:	80 
80105e3e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e41:	89 04 24             	mov    %eax,(%esp)
80105e44:	e8 3b c5 ff ff       	call   80102384 <namecmp>
80105e49:	85 c0                	test   %eax,%eax
80105e4b:	0f 84 45 01 00 00    	je     80105f96 <sys_unlink+0x1bc>
80105e51:	c7 44 24 04 bb 8c 10 	movl   $0x80108cbb,0x4(%esp)
80105e58:	80 
80105e59:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e5c:	89 04 24             	mov    %eax,(%esp)
80105e5f:	e8 20 c5 ff ff       	call   80102384 <namecmp>
80105e64:	85 c0                	test   %eax,%eax
80105e66:	0f 84 2a 01 00 00    	je     80105f96 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e6c:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e73:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e76:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7d:	89 04 24             	mov    %eax,(%esp)
80105e80:	e8 21 c5 ff ff       	call   801023a6 <dirlookup>
80105e85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e8c:	0f 84 03 01 00 00    	je     80105f95 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e95:	89 04 24             	mov    %eax,(%esp)
80105e98:	e8 d3 bc ff ff       	call   80101b70 <ilock>

  if(ip->nlink < 1)
80105e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ea4:	66 85 c0             	test   %ax,%ax
80105ea7:	7f 0c                	jg     80105eb5 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105ea9:	c7 04 24 be 8c 10 80 	movl   $0x80108cbe,(%esp)
80105eb0:	e8 91 a6 ff ff       	call   80100546 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ebc:	66 83 f8 01          	cmp    $0x1,%ax
80105ec0:	75 1f                	jne    80105ee1 <sys_unlink+0x107>
80105ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec5:	89 04 24             	mov    %eax,(%esp)
80105ec8:	e8 9f fe ff ff       	call   80105d6c <isdirempty>
80105ecd:	85 c0                	test   %eax,%eax
80105ecf:	75 10                	jne    80105ee1 <sys_unlink+0x107>
    iunlockput(ip);
80105ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed4:	89 04 24             	mov    %eax,(%esp)
80105ed7:	e8 18 bf ff ff       	call   80101df4 <iunlockput>
    goto bad;
80105edc:	e9 b5 00 00 00       	jmp    80105f96 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105ee1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105ee8:	00 
80105ee9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ef0:	00 
80105ef1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ef4:	89 04 24             	mov    %eax,(%esp)
80105ef7:	e8 42 f5 ff ff       	call   8010543e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105efc:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105eff:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f06:	00 
80105f07:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f15:	89 04 24             	mov    %eax,(%esp)
80105f18:	e8 ce c2 ff ff       	call   801021eb <writei>
80105f1d:	83 f8 10             	cmp    $0x10,%eax
80105f20:	74 0c                	je     80105f2e <sys_unlink+0x154>
    panic("unlink: writei");
80105f22:	c7 04 24 d0 8c 10 80 	movl   $0x80108cd0,(%esp)
80105f29:	e8 18 a6 ff ff       	call   80100546 <panic>
  if(ip->type == T_DIR){
80105f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f31:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f35:	66 83 f8 01          	cmp    $0x1,%ax
80105f39:	75 1c                	jne    80105f57 <sys_unlink+0x17d>
    dp->nlink--;
80105f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f42:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f48:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4f:	89 04 24             	mov    %eax,(%esp)
80105f52:	e8 5d ba ff ff       	call   801019b4 <iupdate>
  }
  iunlockput(dp);
80105f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5a:	89 04 24             	mov    %eax,(%esp)
80105f5d:	e8 92 be ff ff       	call   80101df4 <iunlockput>

  ip->nlink--;
80105f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f65:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f69:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f76:	89 04 24             	mov    %eax,(%esp)
80105f79:	e8 36 ba ff ff       	call   801019b4 <iupdate>
  iunlockput(ip);
80105f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f81:	89 04 24             	mov    %eax,(%esp)
80105f84:	e8 6b be ff ff       	call   80101df4 <iunlockput>

  commit_trans();
80105f89:	e8 07 d6 ff ff       	call   80103595 <commit_trans>

  return 0;
80105f8e:	b8 00 00 00 00       	mov    $0x0,%eax
80105f93:	eb 16                	jmp    80105fab <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105f95:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f99:	89 04 24             	mov    %eax,(%esp)
80105f9c:	e8 53 be ff ff       	call   80101df4 <iunlockput>
  commit_trans();
80105fa1:	e8 ef d5 ff ff       	call   80103595 <commit_trans>
  return -1;
80105fa6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fab:	c9                   	leave  
80105fac:	c3                   	ret    

80105fad <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105fad:	55                   	push   %ebp
80105fae:	89 e5                	mov    %esp,%ebp
80105fb0:	83 ec 48             	sub    $0x48,%esp
80105fb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105fb6:	8b 55 10             	mov    0x10(%ebp),%edx
80105fb9:	8b 45 14             	mov    0x14(%ebp),%eax
80105fbc:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105fc0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105fc4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105fc8:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd2:	89 04 24             	mov    %eax,(%esp)
80105fd5:	e8 79 c7 ff ff       	call   80102753 <nameiparent>
80105fda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe1:	75 0a                	jne    80105fed <create+0x40>
    return 0;
80105fe3:	b8 00 00 00 00       	mov    $0x0,%eax
80105fe8:	e9 7e 01 00 00       	jmp    8010616b <create+0x1be>
  ilock(dp);
80105fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff0:	89 04 24             	mov    %eax,(%esp)
80105ff3:	e8 78 bb ff ff       	call   80101b70 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ff8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ffb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fff:	8d 45 de             	lea    -0x22(%ebp),%eax
80106002:	89 44 24 04          	mov    %eax,0x4(%esp)
80106006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106009:	89 04 24             	mov    %eax,(%esp)
8010600c:	e8 95 c3 ff ff       	call   801023a6 <dirlookup>
80106011:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106014:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106018:	74 47                	je     80106061 <create+0xb4>
    iunlockput(dp);
8010601a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601d:	89 04 24             	mov    %eax,(%esp)
80106020:	e8 cf bd ff ff       	call   80101df4 <iunlockput>
    ilock(ip);
80106025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106028:	89 04 24             	mov    %eax,(%esp)
8010602b:	e8 40 bb ff ff       	call   80101b70 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106030:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106035:	75 15                	jne    8010604c <create+0x9f>
80106037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010603e:	66 83 f8 02          	cmp    $0x2,%ax
80106042:	75 08                	jne    8010604c <create+0x9f>
      return ip;
80106044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106047:	e9 1f 01 00 00       	jmp    8010616b <create+0x1be>
    iunlockput(ip);
8010604c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010604f:	89 04 24             	mov    %eax,(%esp)
80106052:	e8 9d bd ff ff       	call   80101df4 <iunlockput>
    return 0;
80106057:	b8 00 00 00 00       	mov    $0x0,%eax
8010605c:	e9 0a 01 00 00       	jmp    8010616b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106061:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106068:	8b 00                	mov    (%eax),%eax
8010606a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010606e:	89 04 24             	mov    %eax,(%esp)
80106071:	e8 5f b8 ff ff       	call   801018d5 <ialloc>
80106076:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106079:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010607d:	75 0c                	jne    8010608b <create+0xde>
    panic("create: ialloc");
8010607f:	c7 04 24 df 8c 10 80 	movl   $0x80108cdf,(%esp)
80106086:	e8 bb a4 ff ff       	call   80100546 <panic>

  ilock(ip);
8010608b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608e:	89 04 24             	mov    %eax,(%esp)
80106091:	e8 da ba ff ff       	call   80101b70 <ilock>
  ip->major = major;
80106096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106099:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010609d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801060a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a4:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801060a8:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801060ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060af:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801060b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b8:	89 04 24             	mov    %eax,(%esp)
801060bb:	e8 f4 b8 ff ff       	call   801019b4 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801060c0:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801060c5:	75 6a                	jne    80106131 <create+0x184>
    dp->nlink++;  // for ".."
801060c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ca:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060ce:	8d 50 01             	lea    0x1(%eax),%edx
801060d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801060d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060db:	89 04 24             	mov    %eax,(%esp)
801060de:	e8 d1 b8 ff ff       	call   801019b4 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801060e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e6:	8b 40 04             	mov    0x4(%eax),%eax
801060e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801060ed:	c7 44 24 04 b9 8c 10 	movl   $0x80108cb9,0x4(%esp)
801060f4:	80 
801060f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f8:	89 04 24             	mov    %eax,(%esp)
801060fb:	e8 6e c3 ff ff       	call   8010246e <dirlink>
80106100:	85 c0                	test   %eax,%eax
80106102:	78 21                	js     80106125 <create+0x178>
80106104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106107:	8b 40 04             	mov    0x4(%eax),%eax
8010610a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010610e:	c7 44 24 04 bb 8c 10 	movl   $0x80108cbb,0x4(%esp)
80106115:	80 
80106116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106119:	89 04 24             	mov    %eax,(%esp)
8010611c:	e8 4d c3 ff ff       	call   8010246e <dirlink>
80106121:	85 c0                	test   %eax,%eax
80106123:	79 0c                	jns    80106131 <create+0x184>
      panic("create dots");
80106125:	c7 04 24 ee 8c 10 80 	movl   $0x80108cee,(%esp)
8010612c:	e8 15 a4 ff ff       	call   80100546 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106134:	8b 40 04             	mov    0x4(%eax),%eax
80106137:	89 44 24 08          	mov    %eax,0x8(%esp)
8010613b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010613e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106145:	89 04 24             	mov    %eax,(%esp)
80106148:	e8 21 c3 ff ff       	call   8010246e <dirlink>
8010614d:	85 c0                	test   %eax,%eax
8010614f:	79 0c                	jns    8010615d <create+0x1b0>
    panic("create: dirlink");
80106151:	c7 04 24 fa 8c 10 80 	movl   $0x80108cfa,(%esp)
80106158:	e8 e9 a3 ff ff       	call   80100546 <panic>

  iunlockput(dp);
8010615d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106160:	89 04 24             	mov    %eax,(%esp)
80106163:	e8 8c bc ff ff       	call   80101df4 <iunlockput>

  return ip;
80106168:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010616b:	c9                   	leave  
8010616c:	c3                   	ret    

8010616d <sys_open>:

int
sys_open(void)
{
8010616d:	55                   	push   %ebp
8010616e:	89 e5                	mov    %esp,%ebp
80106170:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106173:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106176:	89 44 24 04          	mov    %eax,0x4(%esp)
8010617a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106181:	e8 a2 f6 ff ff       	call   80105828 <argstr>
80106186:	85 c0                	test   %eax,%eax
80106188:	78 17                	js     801061a1 <sys_open+0x34>
8010618a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010618d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106191:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106198:	e8 f1 f5 ff ff       	call   8010578e <argint>
8010619d:	85 c0                	test   %eax,%eax
8010619f:	79 0a                	jns    801061ab <sys_open+0x3e>
    return -1;
801061a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a6:	e9 48 01 00 00       	jmp    801062f3 <sys_open+0x186>
  if(omode & O_CREATE){
801061ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ae:	25 00 02 00 00       	and    $0x200,%eax
801061b3:	85 c0                	test   %eax,%eax
801061b5:	74 40                	je     801061f7 <sys_open+0x8a>
    begin_trans();
801061b7:	e8 90 d3 ff ff       	call   8010354c <begin_trans>
    ip = create(path, T_FILE, 0, 0);
801061bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061c6:	00 
801061c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061ce:	00 
801061cf:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801061d6:	00 
801061d7:	89 04 24             	mov    %eax,(%esp)
801061da:	e8 ce fd ff ff       	call   80105fad <create>
801061df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
801061e2:	e8 ae d3 ff ff       	call   80103595 <commit_trans>
    if(ip == 0)
801061e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061eb:	75 5c                	jne    80106249 <sys_open+0xdc>
      return -1;
801061ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f2:	e9 fc 00 00 00       	jmp    801062f3 <sys_open+0x186>
  } else {
    if((ip = namei(path)) == 0)
801061f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061fa:	89 04 24             	mov    %eax,(%esp)
801061fd:	e8 2f c5 ff ff       	call   80102731 <namei>
80106202:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106209:	75 0a                	jne    80106215 <sys_open+0xa8>
      return -1;
8010620b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106210:	e9 de 00 00 00       	jmp    801062f3 <sys_open+0x186>
    ilock(ip);
80106215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106218:	89 04 24             	mov    %eax,(%esp)
8010621b:	e8 50 b9 ff ff       	call   80101b70 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106223:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106227:	66 83 f8 01          	cmp    $0x1,%ax
8010622b:	75 1c                	jne    80106249 <sys_open+0xdc>
8010622d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106230:	85 c0                	test   %eax,%eax
80106232:	74 15                	je     80106249 <sys_open+0xdc>
      iunlockput(ip);
80106234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106237:	89 04 24             	mov    %eax,(%esp)
8010623a:	e8 b5 bb ff ff       	call   80101df4 <iunlockput>
      return -1;
8010623f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106244:	e9 aa 00 00 00       	jmp    801062f3 <sys_open+0x186>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106249:	e8 d2 af ff ff       	call   80101220 <filealloc>
8010624e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106251:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106255:	74 14                	je     8010626b <sys_open+0xfe>
80106257:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625a:	89 04 24             	mov    %eax,(%esp)
8010625d:	e8 43 f7 ff ff       	call   801059a5 <fdalloc>
80106262:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106265:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106269:	79 23                	jns    8010628e <sys_open+0x121>
    if(f)
8010626b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010626f:	74 0b                	je     8010627c <sys_open+0x10f>
      fileclose(f);
80106271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106274:	89 04 24             	mov    %eax,(%esp)
80106277:	e8 4c b0 ff ff       	call   801012c8 <fileclose>
    iunlockput(ip);
8010627c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627f:	89 04 24             	mov    %eax,(%esp)
80106282:	e8 6d bb ff ff       	call   80101df4 <iunlockput>
    return -1;
80106287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628c:	eb 65                	jmp    801062f3 <sys_open+0x186>
  }
  iunlock(ip);
8010628e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106291:	89 04 24             	mov    %eax,(%esp)
80106294:	e8 25 ba ff ff       	call   80101cbe <iunlock>

  f->type = FD_INODE;
80106299:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801062a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062a8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801062ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ae:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801062b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062b8:	83 e0 01             	and    $0x1,%eax
801062bb:	85 c0                	test   %eax,%eax
801062bd:	0f 94 c0             	sete   %al
801062c0:	89 c2                	mov    %eax,%edx
801062c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801062c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062cb:	83 e0 01             	and    $0x1,%eax
801062ce:	85 c0                	test   %eax,%eax
801062d0:	75 0a                	jne    801062dc <sys_open+0x16f>
801062d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d5:	83 e0 02             	and    $0x2,%eax
801062d8:	85 c0                	test   %eax,%eax
801062da:	74 07                	je     801062e3 <sys_open+0x176>
801062dc:	b8 01 00 00 00       	mov    $0x1,%eax
801062e1:	eb 05                	jmp    801062e8 <sys_open+0x17b>
801062e3:	b8 00 00 00 00       	mov    $0x0,%eax
801062e8:	89 c2                	mov    %eax,%edx
801062ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ed:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801062f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801062f3:	c9                   	leave  
801062f4:	c3                   	ret    

801062f5 <sys_mkdir>:

int
sys_mkdir(void)
{
801062f5:	55                   	push   %ebp
801062f6:	89 e5                	mov    %esp,%ebp
801062f8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801062fb:	e8 4c d2 ff ff       	call   8010354c <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106300:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106303:	89 44 24 04          	mov    %eax,0x4(%esp)
80106307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010630e:	e8 15 f5 ff ff       	call   80105828 <argstr>
80106313:	85 c0                	test   %eax,%eax
80106315:	78 2c                	js     80106343 <sys_mkdir+0x4e>
80106317:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106321:	00 
80106322:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106329:	00 
8010632a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106331:	00 
80106332:	89 04 24             	mov    %eax,(%esp)
80106335:	e8 73 fc ff ff       	call   80105fad <create>
8010633a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010633d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106341:	75 0c                	jne    8010634f <sys_mkdir+0x5a>
    commit_trans();
80106343:	e8 4d d2 ff ff       	call   80103595 <commit_trans>
    return -1;
80106348:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634d:	eb 15                	jmp    80106364 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010634f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106352:	89 04 24             	mov    %eax,(%esp)
80106355:	e8 9a ba ff ff       	call   80101df4 <iunlockput>
  commit_trans();
8010635a:	e8 36 d2 ff ff       	call   80103595 <commit_trans>
  return 0;
8010635f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106364:	c9                   	leave  
80106365:	c3                   	ret    

80106366 <sys_mknod>:

int
sys_mknod(void)
{
80106366:	55                   	push   %ebp
80106367:	89 e5                	mov    %esp,%ebp
80106369:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
8010636c:	e8 db d1 ff ff       	call   8010354c <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80106371:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106374:	89 44 24 04          	mov    %eax,0x4(%esp)
80106378:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010637f:	e8 a4 f4 ff ff       	call   80105828 <argstr>
80106384:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106387:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010638b:	78 5e                	js     801063eb <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010638d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106390:	89 44 24 04          	mov    %eax,0x4(%esp)
80106394:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010639b:	e8 ee f3 ff ff       	call   8010578e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
801063a0:	85 c0                	test   %eax,%eax
801063a2:	78 47                	js     801063eb <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801063a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801063ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801063b2:	e8 d7 f3 ff ff       	call   8010578e <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801063b7:	85 c0                	test   %eax,%eax
801063b9:	78 30                	js     801063eb <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801063bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063be:	0f bf c8             	movswl %ax,%ecx
801063c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063c4:	0f bf d0             	movswl %ax,%edx
801063c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801063ca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801063ce:	89 54 24 08          	mov    %edx,0x8(%esp)
801063d2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801063d9:	00 
801063da:	89 04 24             	mov    %eax,(%esp)
801063dd:	e8 cb fb ff ff       	call   80105fad <create>
801063e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063e9:	75 0c                	jne    801063f7 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801063eb:	e8 a5 d1 ff ff       	call   80103595 <commit_trans>
    return -1;
801063f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f5:	eb 15                	jmp    8010640c <sys_mknod+0xa6>
  }
  iunlockput(ip);
801063f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fa:	89 04 24             	mov    %eax,(%esp)
801063fd:	e8 f2 b9 ff ff       	call   80101df4 <iunlockput>
  commit_trans();
80106402:	e8 8e d1 ff ff       	call   80103595 <commit_trans>
  return 0;
80106407:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010640c:	c9                   	leave  
8010640d:	c3                   	ret    

8010640e <sys_chdir>:

int
sys_chdir(void)
{
8010640e:	55                   	push   %ebp
8010640f:	89 e5                	mov    %esp,%ebp
80106411:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80106414:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106417:	89 44 24 04          	mov    %eax,0x4(%esp)
8010641b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106422:	e8 01 f4 ff ff       	call   80105828 <argstr>
80106427:	85 c0                	test   %eax,%eax
80106429:	78 14                	js     8010643f <sys_chdir+0x31>
8010642b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642e:	89 04 24             	mov    %eax,(%esp)
80106431:	e8 fb c2 ff ff       	call   80102731 <namei>
80106436:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010643d:	75 07                	jne    80106446 <sys_chdir+0x38>
    return -1;
8010643f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106444:	eb 57                	jmp    8010649d <sys_chdir+0x8f>
  ilock(ip);
80106446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106449:	89 04 24             	mov    %eax,(%esp)
8010644c:	e8 1f b7 ff ff       	call   80101b70 <ilock>
  if(ip->type != T_DIR){
80106451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106454:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106458:	66 83 f8 01          	cmp    $0x1,%ax
8010645c:	74 12                	je     80106470 <sys_chdir+0x62>
    iunlockput(ip);
8010645e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106461:	89 04 24             	mov    %eax,(%esp)
80106464:	e8 8b b9 ff ff       	call   80101df4 <iunlockput>
    return -1;
80106469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646e:	eb 2d                	jmp    8010649d <sys_chdir+0x8f>
  }
  iunlock(ip);
80106470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106473:	89 04 24             	mov    %eax,(%esp)
80106476:	e8 43 b8 ff ff       	call   80101cbe <iunlock>
  iput(proc->cwd);
8010647b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106481:	8b 40 68             	mov    0x68(%eax),%eax
80106484:	89 04 24             	mov    %eax,(%esp)
80106487:	e8 97 b8 ff ff       	call   80101d23 <iput>
  proc->cwd = ip;
8010648c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106492:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106495:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106498:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010649d:	c9                   	leave  
8010649e:	c3                   	ret    

8010649f <sys_exec>:

int
sys_exec(void)
{
8010649f:	55                   	push   %ebp
801064a0:	89 e5                	mov    %esp,%ebp
801064a2:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801064a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801064af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b6:	e8 6d f3 ff ff       	call   80105828 <argstr>
801064bb:	85 c0                	test   %eax,%eax
801064bd:	78 1a                	js     801064d9 <sys_exec+0x3a>
801064bf:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801064c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801064d0:	e8 b9 f2 ff ff       	call   8010578e <argint>
801064d5:	85 c0                	test   %eax,%eax
801064d7:	79 0a                	jns    801064e3 <sys_exec+0x44>
    return -1;
801064d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064de:	e9 de 00 00 00       	jmp    801065c1 <sys_exec+0x122>
  }
  memset(argv, 0, sizeof(argv));
801064e3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801064ea:	00 
801064eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801064f2:	00 
801064f3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064f9:	89 04 24             	mov    %eax,(%esp)
801064fc:	e8 3d ef ff ff       	call   8010543e <memset>
  for(i=0;; i++){
80106501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650b:	83 f8 1f             	cmp    $0x1f,%eax
8010650e:	76 0a                	jbe    8010651a <sys_exec+0x7b>
      return -1;
80106510:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106515:	e9 a7 00 00 00       	jmp    801065c1 <sys_exec+0x122>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
8010651a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651d:	c1 e0 02             	shl    $0x2,%eax
80106520:	89 c2                	mov    %eax,%edx
80106522:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106528:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010652b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106531:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
80106537:	89 54 24 08          	mov    %edx,0x8(%esp)
8010653b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010653f:	89 04 24             	mov    %eax,(%esp)
80106542:	e8 b5 f1 ff ff       	call   801056fc <fetchint>
80106547:	85 c0                	test   %eax,%eax
80106549:	79 07                	jns    80106552 <sys_exec+0xb3>
      return -1;
8010654b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106550:	eb 6f                	jmp    801065c1 <sys_exec+0x122>
    if(uarg == 0){
80106552:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106558:	85 c0                	test   %eax,%eax
8010655a:	75 26                	jne    80106582 <sys_exec+0xe3>
      argv[i] = 0;
8010655c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655f:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106566:	00 00 00 00 
      break;
8010656a:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010656b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010656e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106574:	89 54 24 04          	mov    %edx,0x4(%esp)
80106578:	89 04 24             	mov    %eax,(%esp)
8010657b:	e8 64 a8 ff ff       	call   80100de4 <exec>
80106580:	eb 3f                	jmp    801065c1 <sys_exec+0x122>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106582:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106588:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010658b:	c1 e2 02             	shl    $0x2,%edx
8010658e:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106591:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106597:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010659d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801065a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801065a5:	89 04 24             	mov    %eax,(%esp)
801065a8:	e8 83 f1 ff ff       	call   80105730 <fetchstr>
801065ad:	85 c0                	test   %eax,%eax
801065af:	79 07                	jns    801065b8 <sys_exec+0x119>
      return -1;
801065b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b6:	eb 09                	jmp    801065c1 <sys_exec+0x122>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801065b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
801065bc:	e9 47 ff ff ff       	jmp    80106508 <sys_exec+0x69>
  return exec(path, argv);
}
801065c1:	c9                   	leave  
801065c2:	c3                   	ret    

801065c3 <sys_pipe>:

int
sys_pipe(void)
{
801065c3:	55                   	push   %ebp
801065c4:	89 e5                	mov    %esp,%ebp
801065c6:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801065c9:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801065d0:	00 
801065d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065df:	e8 e2 f1 ff ff       	call   801057c6 <argptr>
801065e4:	85 c0                	test   %eax,%eax
801065e6:	79 0a                	jns    801065f2 <sys_pipe+0x2f>
    return -1;
801065e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ed:	e9 9b 00 00 00       	jmp    8010668d <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801065f2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801065f9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065fc:	89 04 24             	mov    %eax,(%esp)
801065ff:	e8 6c d9 ff ff       	call   80103f70 <pipealloc>
80106604:	85 c0                	test   %eax,%eax
80106606:	79 07                	jns    8010660f <sys_pipe+0x4c>
    return -1;
80106608:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010660d:	eb 7e                	jmp    8010668d <sys_pipe+0xca>
  fd0 = -1;
8010660f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106616:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106619:	89 04 24             	mov    %eax,(%esp)
8010661c:	e8 84 f3 ff ff       	call   801059a5 <fdalloc>
80106621:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106624:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106628:	78 14                	js     8010663e <sys_pipe+0x7b>
8010662a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010662d:	89 04 24             	mov    %eax,(%esp)
80106630:	e8 70 f3 ff ff       	call   801059a5 <fdalloc>
80106635:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106638:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010663c:	79 37                	jns    80106675 <sys_pipe+0xb2>
    if(fd0 >= 0)
8010663e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106642:	78 14                	js     80106658 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106644:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010664a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010664d:	83 c2 08             	add    $0x8,%edx
80106650:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106657:	00 
    fileclose(rf);
80106658:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010665b:	89 04 24             	mov    %eax,(%esp)
8010665e:	e8 65 ac ff ff       	call   801012c8 <fileclose>
    fileclose(wf);
80106663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106666:	89 04 24             	mov    %eax,(%esp)
80106669:	e8 5a ac ff ff       	call   801012c8 <fileclose>
    return -1;
8010666e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106673:	eb 18                	jmp    8010668d <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106675:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106678:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010667b:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010667d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106680:	8d 50 04             	lea    0x4(%eax),%edx
80106683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106686:	89 02                	mov    %eax,(%edx)
  return 0;
80106688:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010668d:	c9                   	leave  
8010668e:	c3                   	ret    
8010668f:	90                   	nop

80106690 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106690:	55                   	push   %ebp
80106691:	89 e5                	mov    %esp,%ebp
80106693:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106696:	e8 96 df ff ff       	call   80104631 <fork>
}
8010669b:	c9                   	leave  
8010669c:	c3                   	ret    

8010669d <sys_exit>:

int
sys_exit(void)
{
8010669d:	55                   	push   %ebp
8010669e:	89 e5                	mov    %esp,%ebp
801066a0:	83 ec 08             	sub    $0x8,%esp
  exit();
801066a3:	e8 1e e1 ff ff       	call   801047c6 <exit>
  return 0;  // not reached
801066a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066ad:	c9                   	leave  
801066ae:	c3                   	ret    

801066af <sys_wait>:

int
sys_wait(void)
{
801066af:	55                   	push   %ebp
801066b0:	89 e5                	mov    %esp,%ebp
801066b2:	83 ec 08             	sub    $0x8,%esp
  return wait();
801066b5:	e8 61 e2 ff ff       	call   8010491b <wait>
}
801066ba:	c9                   	leave  
801066bb:	c3                   	ret    

801066bc <sys_wait2>:

int
sys_wait2(void)
{
801066bc:	55                   	push   %ebp
801066bd:	89 e5                	mov    %esp,%ebp
801066bf:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
801066c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
801066c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
801066d0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066d7:	00 
801066d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066db:	89 44 24 04          	mov    %eax,0x4(%esp)
801066df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066e6:	e8 db f0 ff ff       	call   801057c6 <argptr>
  argptr(0,&wtime,sizeof(wtime));
801066eb:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066f2:	00 
801066f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801066fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106701:	e8 c0 f0 ff ff       	call   801057c6 <argptr>
  return wait2((int*)wtime, (int*)rtime);
80106706:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106709:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010670c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106710:	89 04 24             	mov    %eax,(%esp)
80106713:	e8 15 e3 ff ff       	call   80104a2d <wait2>
}
80106718:	c9                   	leave  
80106719:	c3                   	ret    

8010671a <sys_nice>:

int
sys_nice(void)
{
8010671a:	55                   	push   %ebp
8010671b:	89 e5                	mov    %esp,%ebp
8010671d:	83 ec 08             	sub    $0x8,%esp
  return nice();
80106720:	e8 c7 e9 ff ff       	call   801050ec <nice>
}
80106725:	c9                   	leave  
80106726:	c3                   	ret    

80106727 <sys_kill>:
int
sys_kill(void)
{
80106727:	55                   	push   %ebp
80106728:	89 e5                	mov    %esp,%ebp
8010672a:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010672d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106730:	89 44 24 04          	mov    %eax,0x4(%esp)
80106734:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010673b:	e8 4e f0 ff ff       	call   8010578e <argint>
80106740:	85 c0                	test   %eax,%eax
80106742:	79 07                	jns    8010674b <sys_kill+0x24>
    return -1;
80106744:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106749:	eb 0b                	jmp    80106756 <sys_kill+0x2f>
  return kill(pid);
8010674b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010674e:	89 04 24             	mov    %eax,(%esp)
80106751:	e8 1f e8 ff ff       	call   80104f75 <kill>
}
80106756:	c9                   	leave  
80106757:	c3                   	ret    

80106758 <sys_getpid>:

int
sys_getpid(void)
{
80106758:	55                   	push   %ebp
80106759:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010675b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106761:	8b 40 10             	mov    0x10(%eax),%eax
}
80106764:	5d                   	pop    %ebp
80106765:	c3                   	ret    

80106766 <sys_sbrk>:

int
sys_sbrk(void)
{
80106766:	55                   	push   %ebp
80106767:	89 e5                	mov    %esp,%ebp
80106769:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010676c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010676f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106773:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010677a:	e8 0f f0 ff ff       	call   8010578e <argint>
8010677f:	85 c0                	test   %eax,%eax
80106781:	79 07                	jns    8010678a <sys_sbrk+0x24>
    return -1;
80106783:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106788:	eb 24                	jmp    801067ae <sys_sbrk+0x48>
  addr = proc->sz;
8010678a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106790:	8b 00                	mov    (%eax),%eax
80106792:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106798:	89 04 24             	mov    %eax,(%esp)
8010679b:	e8 ec dd ff ff       	call   8010458c <growproc>
801067a0:	85 c0                	test   %eax,%eax
801067a2:	79 07                	jns    801067ab <sys_sbrk+0x45>
    return -1;
801067a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a9:	eb 03                	jmp    801067ae <sys_sbrk+0x48>
  return addr;
801067ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067ae:	c9                   	leave  
801067af:	c3                   	ret    

801067b0 <sys_sleep>:

int
sys_sleep(void)
{
801067b0:	55                   	push   %ebp
801067b1:	89 e5                	mov    %esp,%ebp
801067b3:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801067b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801067bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067c4:	e8 c5 ef ff ff       	call   8010578e <argint>
801067c9:	85 c0                	test   %eax,%eax
801067cb:	79 07                	jns    801067d4 <sys_sleep+0x24>
    return -1;
801067cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d2:	eb 6c                	jmp    80106840 <sys_sleep+0x90>
  acquire(&tickslock);
801067d4:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801067db:	e8 03 ea ff ff       	call   801051e3 <acquire>
  ticks0 = ticks;
801067e0:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
801067e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801067e8:	eb 34                	jmp    8010681e <sys_sleep+0x6e>
    if(proc->killed){
801067ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067f0:	8b 40 24             	mov    0x24(%eax),%eax
801067f3:	85 c0                	test   %eax,%eax
801067f5:	74 13                	je     8010680a <sys_sleep+0x5a>
      release(&tickslock);
801067f7:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801067fe:	e8 42 ea ff ff       	call   80105245 <release>
      return -1;
80106803:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106808:	eb 36                	jmp    80106840 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010680a:	c7 44 24 04 80 25 11 	movl   $0x80112580,0x4(%esp)
80106811:	80 
80106812:	c7 04 24 c0 2d 11 80 	movl   $0x80112dc0,(%esp)
80106819:	e8 50 e6 ff ff       	call   80104e6e <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010681e:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
80106823:	89 c2                	mov    %eax,%edx
80106825:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010682b:	39 c2                	cmp    %eax,%edx
8010682d:	72 bb                	jb     801067ea <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010682f:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106836:	e8 0a ea ff ff       	call   80105245 <release>
  return 0;
8010683b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106840:	c9                   	leave  
80106841:	c3                   	ret    

80106842 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106842:	55                   	push   %ebp
80106843:	89 e5                	mov    %esp,%ebp
80106845:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106848:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
8010684f:	e8 8f e9 ff ff       	call   801051e3 <acquire>
  xticks = ticks;
80106854:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
80106859:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010685c:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106863:	e8 dd e9 ff ff       	call   80105245 <release>
  return xticks;
80106868:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010686b:	c9                   	leave  
8010686c:	c3                   	ret    
8010686d:	66 90                	xchg   %ax,%ax
8010686f:	90                   	nop

80106870 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106870:	55                   	push   %ebp
80106871:	89 e5                	mov    %esp,%ebp
80106873:	83 ec 08             	sub    $0x8,%esp
80106876:	8b 55 08             	mov    0x8(%ebp),%edx
80106879:	8b 45 0c             	mov    0xc(%ebp),%eax
8010687c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106880:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106883:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106887:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010688b:	ee                   	out    %al,(%dx)
}
8010688c:	c9                   	leave  
8010688d:	c3                   	ret    

8010688e <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010688e:	55                   	push   %ebp
8010688f:	89 e5                	mov    %esp,%ebp
80106891:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106894:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010689b:	00 
8010689c:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801068a3:	e8 c8 ff ff ff       	call   80106870 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801068a8:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801068af:	00 
801068b0:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068b7:	e8 b4 ff ff ff       	call   80106870 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801068bc:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801068c3:	00 
801068c4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068cb:	e8 a0 ff ff ff       	call   80106870 <outb>
  picenable(IRQ_TIMER);
801068d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068d7:	e8 1d d5 ff ff       	call   80103df9 <picenable>
}
801068dc:	c9                   	leave  
801068dd:	c3                   	ret    
801068de:	66 90                	xchg   %ax,%ax

801068e0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801068e0:	1e                   	push   %ds
  pushl %es
801068e1:	06                   	push   %es
  pushl %fs
801068e2:	0f a0                	push   %fs
  pushl %gs
801068e4:	0f a8                	push   %gs
  pushal
801068e6:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801068e7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801068eb:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801068ed:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801068ef:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801068f3:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801068f5:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801068f7:	54                   	push   %esp
  call trap
801068f8:	e8 de 01 00 00       	call   80106adb <trap>
  addl $4, %esp
801068fd:	83 c4 04             	add    $0x4,%esp

80106900 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106900:	61                   	popa   
  popl %gs
80106901:	0f a9                	pop    %gs
  popl %fs
80106903:	0f a1                	pop    %fs
  popl %es
80106905:	07                   	pop    %es
  popl %ds
80106906:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106907:	83 c4 08             	add    $0x8,%esp
  iret
8010690a:	cf                   	iret   
8010690b:	90                   	nop

8010690c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010690c:	55                   	push   %ebp
8010690d:	89 e5                	mov    %esp,%ebp
8010690f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106912:	8b 45 0c             	mov    0xc(%ebp),%eax
80106915:	83 e8 01             	sub    $0x1,%eax
80106918:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010691c:	8b 45 08             	mov    0x8(%ebp),%eax
8010691f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106923:	8b 45 08             	mov    0x8(%ebp),%eax
80106926:	c1 e8 10             	shr    $0x10,%eax
80106929:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010692d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106930:	0f 01 18             	lidtl  (%eax)
}
80106933:	c9                   	leave  
80106934:	c3                   	ret    

80106935 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106935:	55                   	push   %ebp
80106936:	89 e5                	mov    %esp,%ebp
80106938:	53                   	push   %ebx
80106939:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010693c:	0f 20 d3             	mov    %cr2,%ebx
8010693f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106942:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106945:	83 c4 10             	add    $0x10,%esp
80106948:	5b                   	pop    %ebx
80106949:	5d                   	pop    %ebp
8010694a:	c3                   	ret    

8010694b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010694b:	55                   	push   %ebp
8010694c:	89 e5                	mov    %esp,%ebp
8010694e:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106958:	e9 c3 00 00 00       	jmp    80106a20 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010695d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106960:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106967:	89 c2                	mov    %eax,%edx
80106969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010696c:	66 89 14 c5 c0 25 11 	mov    %dx,-0x7feeda40(,%eax,8)
80106973:	80 
80106974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106977:	66 c7 04 c5 c2 25 11 	movw   $0x8,-0x7feeda3e(,%eax,8)
8010697e:	80 08 00 
80106981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106984:	0f b6 14 c5 c4 25 11 	movzbl -0x7feeda3c(,%eax,8),%edx
8010698b:	80 
8010698c:	83 e2 e0             	and    $0xffffffe0,%edx
8010698f:	88 14 c5 c4 25 11 80 	mov    %dl,-0x7feeda3c(,%eax,8)
80106996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106999:	0f b6 14 c5 c4 25 11 	movzbl -0x7feeda3c(,%eax,8),%edx
801069a0:	80 
801069a1:	83 e2 1f             	and    $0x1f,%edx
801069a4:	88 14 c5 c4 25 11 80 	mov    %dl,-0x7feeda3c(,%eax,8)
801069ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ae:	0f b6 14 c5 c5 25 11 	movzbl -0x7feeda3b(,%eax,8),%edx
801069b5:	80 
801069b6:	83 e2 f0             	and    $0xfffffff0,%edx
801069b9:	83 ca 0e             	or     $0xe,%edx
801069bc:	88 14 c5 c5 25 11 80 	mov    %dl,-0x7feeda3b(,%eax,8)
801069c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c6:	0f b6 14 c5 c5 25 11 	movzbl -0x7feeda3b(,%eax,8),%edx
801069cd:	80 
801069ce:	83 e2 ef             	and    $0xffffffef,%edx
801069d1:	88 14 c5 c5 25 11 80 	mov    %dl,-0x7feeda3b(,%eax,8)
801069d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069db:	0f b6 14 c5 c5 25 11 	movzbl -0x7feeda3b(,%eax,8),%edx
801069e2:	80 
801069e3:	83 e2 9f             	and    $0xffffff9f,%edx
801069e6:	88 14 c5 c5 25 11 80 	mov    %dl,-0x7feeda3b(,%eax,8)
801069ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f0:	0f b6 14 c5 c5 25 11 	movzbl -0x7feeda3b(,%eax,8),%edx
801069f7:	80 
801069f8:	83 ca 80             	or     $0xffffff80,%edx
801069fb:	88 14 c5 c5 25 11 80 	mov    %dl,-0x7feeda3b(,%eax,8)
80106a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a05:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106a0c:	c1 e8 10             	shr    $0x10,%eax
80106a0f:	89 c2                	mov    %eax,%edx
80106a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a14:	66 89 14 c5 c6 25 11 	mov    %dx,-0x7feeda3a(,%eax,8)
80106a1b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106a1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a20:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a27:	0f 8e 30 ff ff ff    	jle    8010695d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a2d:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a32:	66 a3 c0 27 11 80    	mov    %ax,0x801127c0
80106a38:	66 c7 05 c2 27 11 80 	movw   $0x8,0x801127c2
80106a3f:	08 00 
80106a41:	0f b6 05 c4 27 11 80 	movzbl 0x801127c4,%eax
80106a48:	83 e0 e0             	and    $0xffffffe0,%eax
80106a4b:	a2 c4 27 11 80       	mov    %al,0x801127c4
80106a50:	0f b6 05 c4 27 11 80 	movzbl 0x801127c4,%eax
80106a57:	83 e0 1f             	and    $0x1f,%eax
80106a5a:	a2 c4 27 11 80       	mov    %al,0x801127c4
80106a5f:	0f b6 05 c5 27 11 80 	movzbl 0x801127c5,%eax
80106a66:	83 c8 0f             	or     $0xf,%eax
80106a69:	a2 c5 27 11 80       	mov    %al,0x801127c5
80106a6e:	0f b6 05 c5 27 11 80 	movzbl 0x801127c5,%eax
80106a75:	83 e0 ef             	and    $0xffffffef,%eax
80106a78:	a2 c5 27 11 80       	mov    %al,0x801127c5
80106a7d:	0f b6 05 c5 27 11 80 	movzbl 0x801127c5,%eax
80106a84:	83 c8 60             	or     $0x60,%eax
80106a87:	a2 c5 27 11 80       	mov    %al,0x801127c5
80106a8c:	0f b6 05 c5 27 11 80 	movzbl 0x801127c5,%eax
80106a93:	83 c8 80             	or     $0xffffff80,%eax
80106a96:	a2 c5 27 11 80       	mov    %al,0x801127c5
80106a9b:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106aa0:	c1 e8 10             	shr    $0x10,%eax
80106aa3:	66 a3 c6 27 11 80    	mov    %ax,0x801127c6
  
  initlock(&tickslock, "time");
80106aa9:	c7 44 24 04 0c 8d 10 	movl   $0x80108d0c,0x4(%esp)
80106ab0:	80 
80106ab1:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106ab8:	e8 05 e7 ff ff       	call   801051c2 <initlock>
}
80106abd:	c9                   	leave  
80106abe:	c3                   	ret    

80106abf <idtinit>:

void
idtinit(void)
{
80106abf:	55                   	push   %ebp
80106ac0:	89 e5                	mov    %esp,%ebp
80106ac2:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106ac5:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106acc:	00 
80106acd:	c7 04 24 c0 25 11 80 	movl   $0x801125c0,(%esp)
80106ad4:	e8 33 fe ff ff       	call   8010690c <lidt>
}
80106ad9:	c9                   	leave  
80106ada:	c3                   	ret    

80106adb <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106adb:	55                   	push   %ebp
80106adc:	89 e5                	mov    %esp,%ebp
80106ade:	57                   	push   %edi
80106adf:	56                   	push   %esi
80106ae0:	53                   	push   %ebx
80106ae1:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae7:	8b 40 30             	mov    0x30(%eax),%eax
80106aea:	83 f8 40             	cmp    $0x40,%eax
80106aed:	75 3e                	jne    80106b2d <trap+0x52>
    if(proc->killed)
80106aef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106af5:	8b 40 24             	mov    0x24(%eax),%eax
80106af8:	85 c0                	test   %eax,%eax
80106afa:	74 05                	je     80106b01 <trap+0x26>
      exit();
80106afc:	e8 c5 dc ff ff       	call   801047c6 <exit>
    proc->tf = tf;
80106b01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b07:	8b 55 08             	mov    0x8(%ebp),%edx
80106b0a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106b0d:	e8 59 ed ff ff       	call   8010586b <syscall>
    if(proc->killed)
80106b12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b18:	8b 40 24             	mov    0x24(%eax),%eax
80106b1b:	85 c0                	test   %eax,%eax
80106b1d:	0f 84 78 02 00 00    	je     80106d9b <trap+0x2c0>
      exit();
80106b23:	e8 9e dc ff ff       	call   801047c6 <exit>
    return;
80106b28:	e9 6e 02 00 00       	jmp    80106d9b <trap+0x2c0>
  }

  switch(tf->trapno){
80106b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b30:	8b 40 30             	mov    0x30(%eax),%eax
80106b33:	83 e8 20             	sub    $0x20,%eax
80106b36:	83 f8 1f             	cmp    $0x1f,%eax
80106b39:	0f 87 f0 00 00 00    	ja     80106c2f <trap+0x154>
80106b3f:	8b 04 85 b4 8d 10 80 	mov    -0x7fef724c(,%eax,4),%eax
80106b46:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b48:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b4e:	0f b6 00             	movzbl (%eax),%eax
80106b51:	84 c0                	test   %al,%al
80106b53:	75 65                	jne    80106bba <trap+0xdf>
      acquire(&tickslock);
80106b55:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106b5c:	e8 82 e6 ff ff       	call   801051e3 <acquire>
      ticks++;
80106b61:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
80106b66:	83 c0 01             	add    $0x1,%eax
80106b69:	a3 c0 2d 11 80       	mov    %eax,0x80112dc0
      if(proc)		//make sure proc is not null
80106b6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b74:	85 c0                	test   %eax,%eax
80106b76:	74 2a                	je     80106ba2 <trap+0xc7>
      {
	proc->rtime++;	//increment the running time of the current process
80106b78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b7e:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106b84:	83 c2 01             	add    $0x1,%edx
80106b87:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	proc->quanta--;	//decrement the quanta of the current process
80106b8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b93:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106b99:	83 ea 01             	sub    $0x1,%edx
80106b9c:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
      wakeup(&ticks);
80106ba2:	c7 04 24 c0 2d 11 80 	movl   $0x80112dc0,(%esp)
80106ba9:	e8 9c e3 ff ff       	call   80104f4a <wakeup>
      release(&tickslock);
80106bae:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106bb5:	e8 8b e6 ff ff       	call   80105245 <release>
    }
    lapiceoi();
80106bba:	e8 56 c6 ff ff       	call   80103215 <lapiceoi>
    break;
80106bbf:	e9 41 01 00 00       	jmp    80106d05 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106bc4:	e8 50 be ff ff       	call   80102a19 <ideintr>
    lapiceoi();
80106bc9:	e8 47 c6 ff ff       	call   80103215 <lapiceoi>
    break;
80106bce:	e9 32 01 00 00       	jmp    80106d05 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bd3:	e8 19 c4 ff ff       	call   80102ff1 <kbdintr>
    lapiceoi();
80106bd8:	e8 38 c6 ff ff       	call   80103215 <lapiceoi>
    break;
80106bdd:	e9 23 01 00 00       	jmp    80106d05 <trap+0x22a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106be2:	e8 b9 03 00 00       	call   80106fa0 <uartintr>
    lapiceoi();
80106be7:	e8 29 c6 ff ff       	call   80103215 <lapiceoi>
    break;
80106bec:	e9 14 01 00 00       	jmp    80106d05 <trap+0x22a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106bf1:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bf4:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80106bfa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bfe:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106c01:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c07:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c0a:	0f b6 c0             	movzbl %al,%eax
80106c0d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c11:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c15:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c19:	c7 04 24 14 8d 10 80 	movl   $0x80108d14,(%esp)
80106c20:	e8 85 97 ff ff       	call   801003aa <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106c25:	e8 eb c5 ff ff       	call   80103215 <lapiceoi>
    break;
80106c2a:	e9 d6 00 00 00       	jmp    80106d05 <trap+0x22a>
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c2f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c35:	85 c0                	test   %eax,%eax
80106c37:	74 11                	je     80106c4a <trap+0x16f>
80106c39:	8b 45 08             	mov    0x8(%ebp),%eax
80106c3c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c40:	0f b7 c0             	movzwl %ax,%eax
80106c43:	83 e0 03             	and    $0x3,%eax
80106c46:	85 c0                	test   %eax,%eax
80106c48:	75 46                	jne    80106c90 <trap+0x1b5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c4a:	e8 e6 fc ff ff       	call   80106935 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c4f:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c52:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c55:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c5c:	0f b6 12             	movzbl (%edx),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c5f:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c62:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c65:	8b 52 30             	mov    0x30(%edx),%edx
80106c68:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c6c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c70:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c74:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c78:	c7 04 24 38 8d 10 80 	movl   $0x80108d38,(%esp)
80106c7f:	e8 26 97 ff ff       	call   801003aa <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c84:	c7 04 24 6a 8d 10 80 	movl   $0x80108d6a,(%esp)
80106c8b:	e8 b6 98 ff ff       	call   80100546 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c90:	e8 a0 fc ff ff       	call   80106935 <rcr2>
80106c95:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c97:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c9a:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c9d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ca3:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ca6:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ca9:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cac:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106caf:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cb2:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106cb5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cbb:	83 c0 6c             	add    $0x6c,%eax
80106cbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106cc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cc7:	8b 40 10             	mov    0x10(%eax),%eax
80106cca:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106cce:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106cd2:	89 74 24 14          	mov    %esi,0x14(%esp)
80106cd6:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106cda:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106cde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106ce1:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ce9:	c7 04 24 70 8d 10 80 	movl   $0x80108d70,(%esp)
80106cf0:	e8 b5 96 ff ff       	call   801003aa <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106cf5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cfb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106d02:	eb 01                	jmp    80106d05 <trap+0x22a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106d04:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0b:	85 c0                	test   %eax,%eax
80106d0d:	74 24                	je     80106d33 <trap+0x258>
80106d0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d15:	8b 40 24             	mov    0x24(%eax),%eax
80106d18:	85 c0                	test   %eax,%eax
80106d1a:	74 17                	je     80106d33 <trap+0x258>
80106d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106d1f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d23:	0f b7 c0             	movzwl %ax,%eax
80106d26:	83 e0 03             	and    $0x3,%eax
80106d29:	83 f8 03             	cmp    $0x3,%eax
80106d2c:	75 05                	jne    80106d33 <trap+0x258>
    exit();
80106d2e:	e8 93 da ff ff       	call   801047c6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && proc->quanta <= 0) //added quanta check to yield only after quanta is spent
80106d33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d39:	85 c0                	test   %eax,%eax
80106d3b:	74 2e                	je     80106d6b <trap+0x290>
80106d3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d43:	8b 40 0c             	mov    0xc(%eax),%eax
80106d46:	83 f8 04             	cmp    $0x4,%eax
80106d49:	75 20                	jne    80106d6b <trap+0x290>
80106d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d4e:	8b 40 30             	mov    0x30(%eax),%eax
80106d51:	83 f8 20             	cmp    $0x20,%eax
80106d54:	75 15                	jne    80106d6b <trap+0x290>
80106d56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d5c:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106d62:	85 c0                	test   %eax,%eax
80106d64:	7f 05                	jg     80106d6b <trap+0x290>
    yield();
80106d66:	e8 a5 e0 ff ff       	call   80104e10 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d71:	85 c0                	test   %eax,%eax
80106d73:	74 27                	je     80106d9c <trap+0x2c1>
80106d75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d7b:	8b 40 24             	mov    0x24(%eax),%eax
80106d7e:	85 c0                	test   %eax,%eax
80106d80:	74 1a                	je     80106d9c <trap+0x2c1>
80106d82:	8b 45 08             	mov    0x8(%ebp),%eax
80106d85:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d89:	0f b7 c0             	movzwl %ax,%eax
80106d8c:	83 e0 03             	and    $0x3,%eax
80106d8f:	83 f8 03             	cmp    $0x3,%eax
80106d92:	75 08                	jne    80106d9c <trap+0x2c1>
    exit();
80106d94:	e8 2d da ff ff       	call   801047c6 <exit>
80106d99:	eb 01                	jmp    80106d9c <trap+0x2c1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106d9b:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106d9c:	83 c4 3c             	add    $0x3c,%esp
80106d9f:	5b                   	pop    %ebx
80106da0:	5e                   	pop    %esi
80106da1:	5f                   	pop    %edi
80106da2:	5d                   	pop    %ebp
80106da3:	c3                   	ret    

80106da4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106da4:	55                   	push   %ebp
80106da5:	89 e5                	mov    %esp,%ebp
80106da7:	53                   	push   %ebx
80106da8:	83 ec 14             	sub    $0x14,%esp
80106dab:	8b 45 08             	mov    0x8(%ebp),%eax
80106dae:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106db2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106db6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106dba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106dbe:	ec                   	in     (%dx),%al
80106dbf:	89 c3                	mov    %eax,%ebx
80106dc1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106dc4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106dc8:	83 c4 14             	add    $0x14,%esp
80106dcb:	5b                   	pop    %ebx
80106dcc:	5d                   	pop    %ebp
80106dcd:	c3                   	ret    

80106dce <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106dce:	55                   	push   %ebp
80106dcf:	89 e5                	mov    %esp,%ebp
80106dd1:	83 ec 08             	sub    $0x8,%esp
80106dd4:	8b 55 08             	mov    0x8(%ebp),%edx
80106dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106dda:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106dde:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106de1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106de5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106de9:	ee                   	out    %al,(%dx)
}
80106dea:	c9                   	leave  
80106deb:	c3                   	ret    

80106dec <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106dec:	55                   	push   %ebp
80106ded:	89 e5                	mov    %esp,%ebp
80106def:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106df2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106df9:	00 
80106dfa:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e01:	e8 c8 ff ff ff       	call   80106dce <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106e06:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106e0d:	00 
80106e0e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e15:	e8 b4 ff ff ff       	call   80106dce <outb>
  outb(COM1+0, 115200/9600);
80106e1a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106e21:	00 
80106e22:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e29:	e8 a0 ff ff ff       	call   80106dce <outb>
  outb(COM1+1, 0);
80106e2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e35:	00 
80106e36:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e3d:	e8 8c ff ff ff       	call   80106dce <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e42:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106e49:	00 
80106e4a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e51:	e8 78 ff ff ff       	call   80106dce <outb>
  outb(COM1+4, 0);
80106e56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e5d:	00 
80106e5e:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106e65:	e8 64 ff ff ff       	call   80106dce <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e6a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106e71:	00 
80106e72:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e79:	e8 50 ff ff ff       	call   80106dce <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e7e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e85:	e8 1a ff ff ff       	call   80106da4 <inb>
80106e8a:	3c ff                	cmp    $0xff,%al
80106e8c:	74 6c                	je     80106efa <uartinit+0x10e>
    return;
  uart = 1;
80106e8e:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106e95:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e98:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e9f:	e8 00 ff ff ff       	call   80106da4 <inb>
  inb(COM1+0);
80106ea4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106eab:	e8 f4 fe ff ff       	call   80106da4 <inb>
  picenable(IRQ_COM1);
80106eb0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106eb7:	e8 3d cf ff ff       	call   80103df9 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106ebc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ec3:	00 
80106ec4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ecb:	e8 ce bd ff ff       	call   80102c9e <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ed0:	c7 45 f4 34 8e 10 80 	movl   $0x80108e34,-0xc(%ebp)
80106ed7:	eb 15                	jmp    80106eee <uartinit+0x102>
    uartputc(*p);
80106ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106edc:	0f b6 00             	movzbl (%eax),%eax
80106edf:	0f be c0             	movsbl %al,%eax
80106ee2:	89 04 24             	mov    %eax,(%esp)
80106ee5:	e8 13 00 00 00       	call   80106efd <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106eea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef1:	0f b6 00             	movzbl (%eax),%eax
80106ef4:	84 c0                	test   %al,%al
80106ef6:	75 e1                	jne    80106ed9 <uartinit+0xed>
80106ef8:	eb 01                	jmp    80106efb <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106efa:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106efb:	c9                   	leave  
80106efc:	c3                   	ret    

80106efd <uartputc>:

void
uartputc(int c)
{
80106efd:	55                   	push   %ebp
80106efe:	89 e5                	mov    %esp,%ebp
80106f00:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106f03:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f08:	85 c0                	test   %eax,%eax
80106f0a:	74 4d                	je     80106f59 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f13:	eb 10                	jmp    80106f25 <uartputc+0x28>
    microdelay(10);
80106f15:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106f1c:	e8 19 c3 ff ff       	call   8010323a <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f25:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f29:	7f 16                	jg     80106f41 <uartputc+0x44>
80106f2b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f32:	e8 6d fe ff ff       	call   80106da4 <inb>
80106f37:	0f b6 c0             	movzbl %al,%eax
80106f3a:	83 e0 20             	and    $0x20,%eax
80106f3d:	85 c0                	test   %eax,%eax
80106f3f:	74 d4                	je     80106f15 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106f41:	8b 45 08             	mov    0x8(%ebp),%eax
80106f44:	0f b6 c0             	movzbl %al,%eax
80106f47:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f4b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f52:	e8 77 fe ff ff       	call   80106dce <outb>
80106f57:	eb 01                	jmp    80106f5a <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106f59:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106f5a:	c9                   	leave  
80106f5b:	c3                   	ret    

80106f5c <uartgetc>:

static int
uartgetc(void)
{
80106f5c:	55                   	push   %ebp
80106f5d:	89 e5                	mov    %esp,%ebp
80106f5f:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106f62:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f67:	85 c0                	test   %eax,%eax
80106f69:	75 07                	jne    80106f72 <uartgetc+0x16>
    return -1;
80106f6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f70:	eb 2c                	jmp    80106f9e <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106f72:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f79:	e8 26 fe ff ff       	call   80106da4 <inb>
80106f7e:	0f b6 c0             	movzbl %al,%eax
80106f81:	83 e0 01             	and    $0x1,%eax
80106f84:	85 c0                	test   %eax,%eax
80106f86:	75 07                	jne    80106f8f <uartgetc+0x33>
    return -1;
80106f88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f8d:	eb 0f                	jmp    80106f9e <uartgetc+0x42>
  return inb(COM1+0);
80106f8f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f96:	e8 09 fe ff ff       	call   80106da4 <inb>
80106f9b:	0f b6 c0             	movzbl %al,%eax
}
80106f9e:	c9                   	leave  
80106f9f:	c3                   	ret    

80106fa0 <uartintr>:

void
uartintr(void)
{
80106fa0:	55                   	push   %ebp
80106fa1:	89 e5                	mov    %esp,%ebp
80106fa3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106fa6:	c7 04 24 5c 6f 10 80 	movl   $0x80106f5c,(%esp)
80106fad:	e8 c9 98 ff ff       	call   8010087b <consoleintr>
}
80106fb2:	c9                   	leave  
80106fb3:	c3                   	ret    

80106fb4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $0
80106fb6:	6a 00                	push   $0x0
  jmp alltraps
80106fb8:	e9 23 f9 ff ff       	jmp    801068e0 <alltraps>

80106fbd <vector1>:
.globl vector1
vector1:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $1
80106fbf:	6a 01                	push   $0x1
  jmp alltraps
80106fc1:	e9 1a f9 ff ff       	jmp    801068e0 <alltraps>

80106fc6 <vector2>:
.globl vector2
vector2:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $2
80106fc8:	6a 02                	push   $0x2
  jmp alltraps
80106fca:	e9 11 f9 ff ff       	jmp    801068e0 <alltraps>

80106fcf <vector3>:
.globl vector3
vector3:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $3
80106fd1:	6a 03                	push   $0x3
  jmp alltraps
80106fd3:	e9 08 f9 ff ff       	jmp    801068e0 <alltraps>

80106fd8 <vector4>:
.globl vector4
vector4:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $4
80106fda:	6a 04                	push   $0x4
  jmp alltraps
80106fdc:	e9 ff f8 ff ff       	jmp    801068e0 <alltraps>

80106fe1 <vector5>:
.globl vector5
vector5:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $5
80106fe3:	6a 05                	push   $0x5
  jmp alltraps
80106fe5:	e9 f6 f8 ff ff       	jmp    801068e0 <alltraps>

80106fea <vector6>:
.globl vector6
vector6:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $6
80106fec:	6a 06                	push   $0x6
  jmp alltraps
80106fee:	e9 ed f8 ff ff       	jmp    801068e0 <alltraps>

80106ff3 <vector7>:
.globl vector7
vector7:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $7
80106ff5:	6a 07                	push   $0x7
  jmp alltraps
80106ff7:	e9 e4 f8 ff ff       	jmp    801068e0 <alltraps>

80106ffc <vector8>:
.globl vector8
vector8:
  pushl $8
80106ffc:	6a 08                	push   $0x8
  jmp alltraps
80106ffe:	e9 dd f8 ff ff       	jmp    801068e0 <alltraps>

80107003 <vector9>:
.globl vector9
vector9:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $9
80107005:	6a 09                	push   $0x9
  jmp alltraps
80107007:	e9 d4 f8 ff ff       	jmp    801068e0 <alltraps>

8010700c <vector10>:
.globl vector10
vector10:
  pushl $10
8010700c:	6a 0a                	push   $0xa
  jmp alltraps
8010700e:	e9 cd f8 ff ff       	jmp    801068e0 <alltraps>

80107013 <vector11>:
.globl vector11
vector11:
  pushl $11
80107013:	6a 0b                	push   $0xb
  jmp alltraps
80107015:	e9 c6 f8 ff ff       	jmp    801068e0 <alltraps>

8010701a <vector12>:
.globl vector12
vector12:
  pushl $12
8010701a:	6a 0c                	push   $0xc
  jmp alltraps
8010701c:	e9 bf f8 ff ff       	jmp    801068e0 <alltraps>

80107021 <vector13>:
.globl vector13
vector13:
  pushl $13
80107021:	6a 0d                	push   $0xd
  jmp alltraps
80107023:	e9 b8 f8 ff ff       	jmp    801068e0 <alltraps>

80107028 <vector14>:
.globl vector14
vector14:
  pushl $14
80107028:	6a 0e                	push   $0xe
  jmp alltraps
8010702a:	e9 b1 f8 ff ff       	jmp    801068e0 <alltraps>

8010702f <vector15>:
.globl vector15
vector15:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $15
80107031:	6a 0f                	push   $0xf
  jmp alltraps
80107033:	e9 a8 f8 ff ff       	jmp    801068e0 <alltraps>

80107038 <vector16>:
.globl vector16
vector16:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $16
8010703a:	6a 10                	push   $0x10
  jmp alltraps
8010703c:	e9 9f f8 ff ff       	jmp    801068e0 <alltraps>

80107041 <vector17>:
.globl vector17
vector17:
  pushl $17
80107041:	6a 11                	push   $0x11
  jmp alltraps
80107043:	e9 98 f8 ff ff       	jmp    801068e0 <alltraps>

80107048 <vector18>:
.globl vector18
vector18:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $18
8010704a:	6a 12                	push   $0x12
  jmp alltraps
8010704c:	e9 8f f8 ff ff       	jmp    801068e0 <alltraps>

80107051 <vector19>:
.globl vector19
vector19:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $19
80107053:	6a 13                	push   $0x13
  jmp alltraps
80107055:	e9 86 f8 ff ff       	jmp    801068e0 <alltraps>

8010705a <vector20>:
.globl vector20
vector20:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $20
8010705c:	6a 14                	push   $0x14
  jmp alltraps
8010705e:	e9 7d f8 ff ff       	jmp    801068e0 <alltraps>

80107063 <vector21>:
.globl vector21
vector21:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $21
80107065:	6a 15                	push   $0x15
  jmp alltraps
80107067:	e9 74 f8 ff ff       	jmp    801068e0 <alltraps>

8010706c <vector22>:
.globl vector22
vector22:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $22
8010706e:	6a 16                	push   $0x16
  jmp alltraps
80107070:	e9 6b f8 ff ff       	jmp    801068e0 <alltraps>

80107075 <vector23>:
.globl vector23
vector23:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $23
80107077:	6a 17                	push   $0x17
  jmp alltraps
80107079:	e9 62 f8 ff ff       	jmp    801068e0 <alltraps>

8010707e <vector24>:
.globl vector24
vector24:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $24
80107080:	6a 18                	push   $0x18
  jmp alltraps
80107082:	e9 59 f8 ff ff       	jmp    801068e0 <alltraps>

80107087 <vector25>:
.globl vector25
vector25:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $25
80107089:	6a 19                	push   $0x19
  jmp alltraps
8010708b:	e9 50 f8 ff ff       	jmp    801068e0 <alltraps>

80107090 <vector26>:
.globl vector26
vector26:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $26
80107092:	6a 1a                	push   $0x1a
  jmp alltraps
80107094:	e9 47 f8 ff ff       	jmp    801068e0 <alltraps>

80107099 <vector27>:
.globl vector27
vector27:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $27
8010709b:	6a 1b                	push   $0x1b
  jmp alltraps
8010709d:	e9 3e f8 ff ff       	jmp    801068e0 <alltraps>

801070a2 <vector28>:
.globl vector28
vector28:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $28
801070a4:	6a 1c                	push   $0x1c
  jmp alltraps
801070a6:	e9 35 f8 ff ff       	jmp    801068e0 <alltraps>

801070ab <vector29>:
.globl vector29
vector29:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $29
801070ad:	6a 1d                	push   $0x1d
  jmp alltraps
801070af:	e9 2c f8 ff ff       	jmp    801068e0 <alltraps>

801070b4 <vector30>:
.globl vector30
vector30:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $30
801070b6:	6a 1e                	push   $0x1e
  jmp alltraps
801070b8:	e9 23 f8 ff ff       	jmp    801068e0 <alltraps>

801070bd <vector31>:
.globl vector31
vector31:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $31
801070bf:	6a 1f                	push   $0x1f
  jmp alltraps
801070c1:	e9 1a f8 ff ff       	jmp    801068e0 <alltraps>

801070c6 <vector32>:
.globl vector32
vector32:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $32
801070c8:	6a 20                	push   $0x20
  jmp alltraps
801070ca:	e9 11 f8 ff ff       	jmp    801068e0 <alltraps>

801070cf <vector33>:
.globl vector33
vector33:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $33
801070d1:	6a 21                	push   $0x21
  jmp alltraps
801070d3:	e9 08 f8 ff ff       	jmp    801068e0 <alltraps>

801070d8 <vector34>:
.globl vector34
vector34:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $34
801070da:	6a 22                	push   $0x22
  jmp alltraps
801070dc:	e9 ff f7 ff ff       	jmp    801068e0 <alltraps>

801070e1 <vector35>:
.globl vector35
vector35:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $35
801070e3:	6a 23                	push   $0x23
  jmp alltraps
801070e5:	e9 f6 f7 ff ff       	jmp    801068e0 <alltraps>

801070ea <vector36>:
.globl vector36
vector36:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $36
801070ec:	6a 24                	push   $0x24
  jmp alltraps
801070ee:	e9 ed f7 ff ff       	jmp    801068e0 <alltraps>

801070f3 <vector37>:
.globl vector37
vector37:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $37
801070f5:	6a 25                	push   $0x25
  jmp alltraps
801070f7:	e9 e4 f7 ff ff       	jmp    801068e0 <alltraps>

801070fc <vector38>:
.globl vector38
vector38:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $38
801070fe:	6a 26                	push   $0x26
  jmp alltraps
80107100:	e9 db f7 ff ff       	jmp    801068e0 <alltraps>

80107105 <vector39>:
.globl vector39
vector39:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $39
80107107:	6a 27                	push   $0x27
  jmp alltraps
80107109:	e9 d2 f7 ff ff       	jmp    801068e0 <alltraps>

8010710e <vector40>:
.globl vector40
vector40:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $40
80107110:	6a 28                	push   $0x28
  jmp alltraps
80107112:	e9 c9 f7 ff ff       	jmp    801068e0 <alltraps>

80107117 <vector41>:
.globl vector41
vector41:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $41
80107119:	6a 29                	push   $0x29
  jmp alltraps
8010711b:	e9 c0 f7 ff ff       	jmp    801068e0 <alltraps>

80107120 <vector42>:
.globl vector42
vector42:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $42
80107122:	6a 2a                	push   $0x2a
  jmp alltraps
80107124:	e9 b7 f7 ff ff       	jmp    801068e0 <alltraps>

80107129 <vector43>:
.globl vector43
vector43:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $43
8010712b:	6a 2b                	push   $0x2b
  jmp alltraps
8010712d:	e9 ae f7 ff ff       	jmp    801068e0 <alltraps>

80107132 <vector44>:
.globl vector44
vector44:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $44
80107134:	6a 2c                	push   $0x2c
  jmp alltraps
80107136:	e9 a5 f7 ff ff       	jmp    801068e0 <alltraps>

8010713b <vector45>:
.globl vector45
vector45:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $45
8010713d:	6a 2d                	push   $0x2d
  jmp alltraps
8010713f:	e9 9c f7 ff ff       	jmp    801068e0 <alltraps>

80107144 <vector46>:
.globl vector46
vector46:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $46
80107146:	6a 2e                	push   $0x2e
  jmp alltraps
80107148:	e9 93 f7 ff ff       	jmp    801068e0 <alltraps>

8010714d <vector47>:
.globl vector47
vector47:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $47
8010714f:	6a 2f                	push   $0x2f
  jmp alltraps
80107151:	e9 8a f7 ff ff       	jmp    801068e0 <alltraps>

80107156 <vector48>:
.globl vector48
vector48:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $48
80107158:	6a 30                	push   $0x30
  jmp alltraps
8010715a:	e9 81 f7 ff ff       	jmp    801068e0 <alltraps>

8010715f <vector49>:
.globl vector49
vector49:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $49
80107161:	6a 31                	push   $0x31
  jmp alltraps
80107163:	e9 78 f7 ff ff       	jmp    801068e0 <alltraps>

80107168 <vector50>:
.globl vector50
vector50:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $50
8010716a:	6a 32                	push   $0x32
  jmp alltraps
8010716c:	e9 6f f7 ff ff       	jmp    801068e0 <alltraps>

80107171 <vector51>:
.globl vector51
vector51:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $51
80107173:	6a 33                	push   $0x33
  jmp alltraps
80107175:	e9 66 f7 ff ff       	jmp    801068e0 <alltraps>

8010717a <vector52>:
.globl vector52
vector52:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $52
8010717c:	6a 34                	push   $0x34
  jmp alltraps
8010717e:	e9 5d f7 ff ff       	jmp    801068e0 <alltraps>

80107183 <vector53>:
.globl vector53
vector53:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $53
80107185:	6a 35                	push   $0x35
  jmp alltraps
80107187:	e9 54 f7 ff ff       	jmp    801068e0 <alltraps>

8010718c <vector54>:
.globl vector54
vector54:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $54
8010718e:	6a 36                	push   $0x36
  jmp alltraps
80107190:	e9 4b f7 ff ff       	jmp    801068e0 <alltraps>

80107195 <vector55>:
.globl vector55
vector55:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $55
80107197:	6a 37                	push   $0x37
  jmp alltraps
80107199:	e9 42 f7 ff ff       	jmp    801068e0 <alltraps>

8010719e <vector56>:
.globl vector56
vector56:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $56
801071a0:	6a 38                	push   $0x38
  jmp alltraps
801071a2:	e9 39 f7 ff ff       	jmp    801068e0 <alltraps>

801071a7 <vector57>:
.globl vector57
vector57:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $57
801071a9:	6a 39                	push   $0x39
  jmp alltraps
801071ab:	e9 30 f7 ff ff       	jmp    801068e0 <alltraps>

801071b0 <vector58>:
.globl vector58
vector58:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $58
801071b2:	6a 3a                	push   $0x3a
  jmp alltraps
801071b4:	e9 27 f7 ff ff       	jmp    801068e0 <alltraps>

801071b9 <vector59>:
.globl vector59
vector59:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $59
801071bb:	6a 3b                	push   $0x3b
  jmp alltraps
801071bd:	e9 1e f7 ff ff       	jmp    801068e0 <alltraps>

801071c2 <vector60>:
.globl vector60
vector60:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $60
801071c4:	6a 3c                	push   $0x3c
  jmp alltraps
801071c6:	e9 15 f7 ff ff       	jmp    801068e0 <alltraps>

801071cb <vector61>:
.globl vector61
vector61:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $61
801071cd:	6a 3d                	push   $0x3d
  jmp alltraps
801071cf:	e9 0c f7 ff ff       	jmp    801068e0 <alltraps>

801071d4 <vector62>:
.globl vector62
vector62:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $62
801071d6:	6a 3e                	push   $0x3e
  jmp alltraps
801071d8:	e9 03 f7 ff ff       	jmp    801068e0 <alltraps>

801071dd <vector63>:
.globl vector63
vector63:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $63
801071df:	6a 3f                	push   $0x3f
  jmp alltraps
801071e1:	e9 fa f6 ff ff       	jmp    801068e0 <alltraps>

801071e6 <vector64>:
.globl vector64
vector64:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $64
801071e8:	6a 40                	push   $0x40
  jmp alltraps
801071ea:	e9 f1 f6 ff ff       	jmp    801068e0 <alltraps>

801071ef <vector65>:
.globl vector65
vector65:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $65
801071f1:	6a 41                	push   $0x41
  jmp alltraps
801071f3:	e9 e8 f6 ff ff       	jmp    801068e0 <alltraps>

801071f8 <vector66>:
.globl vector66
vector66:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $66
801071fa:	6a 42                	push   $0x42
  jmp alltraps
801071fc:	e9 df f6 ff ff       	jmp    801068e0 <alltraps>

80107201 <vector67>:
.globl vector67
vector67:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $67
80107203:	6a 43                	push   $0x43
  jmp alltraps
80107205:	e9 d6 f6 ff ff       	jmp    801068e0 <alltraps>

8010720a <vector68>:
.globl vector68
vector68:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $68
8010720c:	6a 44                	push   $0x44
  jmp alltraps
8010720e:	e9 cd f6 ff ff       	jmp    801068e0 <alltraps>

80107213 <vector69>:
.globl vector69
vector69:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $69
80107215:	6a 45                	push   $0x45
  jmp alltraps
80107217:	e9 c4 f6 ff ff       	jmp    801068e0 <alltraps>

8010721c <vector70>:
.globl vector70
vector70:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $70
8010721e:	6a 46                	push   $0x46
  jmp alltraps
80107220:	e9 bb f6 ff ff       	jmp    801068e0 <alltraps>

80107225 <vector71>:
.globl vector71
vector71:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $71
80107227:	6a 47                	push   $0x47
  jmp alltraps
80107229:	e9 b2 f6 ff ff       	jmp    801068e0 <alltraps>

8010722e <vector72>:
.globl vector72
vector72:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $72
80107230:	6a 48                	push   $0x48
  jmp alltraps
80107232:	e9 a9 f6 ff ff       	jmp    801068e0 <alltraps>

80107237 <vector73>:
.globl vector73
vector73:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $73
80107239:	6a 49                	push   $0x49
  jmp alltraps
8010723b:	e9 a0 f6 ff ff       	jmp    801068e0 <alltraps>

80107240 <vector74>:
.globl vector74
vector74:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $74
80107242:	6a 4a                	push   $0x4a
  jmp alltraps
80107244:	e9 97 f6 ff ff       	jmp    801068e0 <alltraps>

80107249 <vector75>:
.globl vector75
vector75:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $75
8010724b:	6a 4b                	push   $0x4b
  jmp alltraps
8010724d:	e9 8e f6 ff ff       	jmp    801068e0 <alltraps>

80107252 <vector76>:
.globl vector76
vector76:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $76
80107254:	6a 4c                	push   $0x4c
  jmp alltraps
80107256:	e9 85 f6 ff ff       	jmp    801068e0 <alltraps>

8010725b <vector77>:
.globl vector77
vector77:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $77
8010725d:	6a 4d                	push   $0x4d
  jmp alltraps
8010725f:	e9 7c f6 ff ff       	jmp    801068e0 <alltraps>

80107264 <vector78>:
.globl vector78
vector78:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $78
80107266:	6a 4e                	push   $0x4e
  jmp alltraps
80107268:	e9 73 f6 ff ff       	jmp    801068e0 <alltraps>

8010726d <vector79>:
.globl vector79
vector79:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $79
8010726f:	6a 4f                	push   $0x4f
  jmp alltraps
80107271:	e9 6a f6 ff ff       	jmp    801068e0 <alltraps>

80107276 <vector80>:
.globl vector80
vector80:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $80
80107278:	6a 50                	push   $0x50
  jmp alltraps
8010727a:	e9 61 f6 ff ff       	jmp    801068e0 <alltraps>

8010727f <vector81>:
.globl vector81
vector81:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $81
80107281:	6a 51                	push   $0x51
  jmp alltraps
80107283:	e9 58 f6 ff ff       	jmp    801068e0 <alltraps>

80107288 <vector82>:
.globl vector82
vector82:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $82
8010728a:	6a 52                	push   $0x52
  jmp alltraps
8010728c:	e9 4f f6 ff ff       	jmp    801068e0 <alltraps>

80107291 <vector83>:
.globl vector83
vector83:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $83
80107293:	6a 53                	push   $0x53
  jmp alltraps
80107295:	e9 46 f6 ff ff       	jmp    801068e0 <alltraps>

8010729a <vector84>:
.globl vector84
vector84:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $84
8010729c:	6a 54                	push   $0x54
  jmp alltraps
8010729e:	e9 3d f6 ff ff       	jmp    801068e0 <alltraps>

801072a3 <vector85>:
.globl vector85
vector85:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $85
801072a5:	6a 55                	push   $0x55
  jmp alltraps
801072a7:	e9 34 f6 ff ff       	jmp    801068e0 <alltraps>

801072ac <vector86>:
.globl vector86
vector86:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $86
801072ae:	6a 56                	push   $0x56
  jmp alltraps
801072b0:	e9 2b f6 ff ff       	jmp    801068e0 <alltraps>

801072b5 <vector87>:
.globl vector87
vector87:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $87
801072b7:	6a 57                	push   $0x57
  jmp alltraps
801072b9:	e9 22 f6 ff ff       	jmp    801068e0 <alltraps>

801072be <vector88>:
.globl vector88
vector88:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $88
801072c0:	6a 58                	push   $0x58
  jmp alltraps
801072c2:	e9 19 f6 ff ff       	jmp    801068e0 <alltraps>

801072c7 <vector89>:
.globl vector89
vector89:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $89
801072c9:	6a 59                	push   $0x59
  jmp alltraps
801072cb:	e9 10 f6 ff ff       	jmp    801068e0 <alltraps>

801072d0 <vector90>:
.globl vector90
vector90:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $90
801072d2:	6a 5a                	push   $0x5a
  jmp alltraps
801072d4:	e9 07 f6 ff ff       	jmp    801068e0 <alltraps>

801072d9 <vector91>:
.globl vector91
vector91:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $91
801072db:	6a 5b                	push   $0x5b
  jmp alltraps
801072dd:	e9 fe f5 ff ff       	jmp    801068e0 <alltraps>

801072e2 <vector92>:
.globl vector92
vector92:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $92
801072e4:	6a 5c                	push   $0x5c
  jmp alltraps
801072e6:	e9 f5 f5 ff ff       	jmp    801068e0 <alltraps>

801072eb <vector93>:
.globl vector93
vector93:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $93
801072ed:	6a 5d                	push   $0x5d
  jmp alltraps
801072ef:	e9 ec f5 ff ff       	jmp    801068e0 <alltraps>

801072f4 <vector94>:
.globl vector94
vector94:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $94
801072f6:	6a 5e                	push   $0x5e
  jmp alltraps
801072f8:	e9 e3 f5 ff ff       	jmp    801068e0 <alltraps>

801072fd <vector95>:
.globl vector95
vector95:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $95
801072ff:	6a 5f                	push   $0x5f
  jmp alltraps
80107301:	e9 da f5 ff ff       	jmp    801068e0 <alltraps>

80107306 <vector96>:
.globl vector96
vector96:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $96
80107308:	6a 60                	push   $0x60
  jmp alltraps
8010730a:	e9 d1 f5 ff ff       	jmp    801068e0 <alltraps>

8010730f <vector97>:
.globl vector97
vector97:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $97
80107311:	6a 61                	push   $0x61
  jmp alltraps
80107313:	e9 c8 f5 ff ff       	jmp    801068e0 <alltraps>

80107318 <vector98>:
.globl vector98
vector98:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $98
8010731a:	6a 62                	push   $0x62
  jmp alltraps
8010731c:	e9 bf f5 ff ff       	jmp    801068e0 <alltraps>

80107321 <vector99>:
.globl vector99
vector99:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $99
80107323:	6a 63                	push   $0x63
  jmp alltraps
80107325:	e9 b6 f5 ff ff       	jmp    801068e0 <alltraps>

8010732a <vector100>:
.globl vector100
vector100:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $100
8010732c:	6a 64                	push   $0x64
  jmp alltraps
8010732e:	e9 ad f5 ff ff       	jmp    801068e0 <alltraps>

80107333 <vector101>:
.globl vector101
vector101:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $101
80107335:	6a 65                	push   $0x65
  jmp alltraps
80107337:	e9 a4 f5 ff ff       	jmp    801068e0 <alltraps>

8010733c <vector102>:
.globl vector102
vector102:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $102
8010733e:	6a 66                	push   $0x66
  jmp alltraps
80107340:	e9 9b f5 ff ff       	jmp    801068e0 <alltraps>

80107345 <vector103>:
.globl vector103
vector103:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $103
80107347:	6a 67                	push   $0x67
  jmp alltraps
80107349:	e9 92 f5 ff ff       	jmp    801068e0 <alltraps>

8010734e <vector104>:
.globl vector104
vector104:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $104
80107350:	6a 68                	push   $0x68
  jmp alltraps
80107352:	e9 89 f5 ff ff       	jmp    801068e0 <alltraps>

80107357 <vector105>:
.globl vector105
vector105:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $105
80107359:	6a 69                	push   $0x69
  jmp alltraps
8010735b:	e9 80 f5 ff ff       	jmp    801068e0 <alltraps>

80107360 <vector106>:
.globl vector106
vector106:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $106
80107362:	6a 6a                	push   $0x6a
  jmp alltraps
80107364:	e9 77 f5 ff ff       	jmp    801068e0 <alltraps>

80107369 <vector107>:
.globl vector107
vector107:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $107
8010736b:	6a 6b                	push   $0x6b
  jmp alltraps
8010736d:	e9 6e f5 ff ff       	jmp    801068e0 <alltraps>

80107372 <vector108>:
.globl vector108
vector108:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $108
80107374:	6a 6c                	push   $0x6c
  jmp alltraps
80107376:	e9 65 f5 ff ff       	jmp    801068e0 <alltraps>

8010737b <vector109>:
.globl vector109
vector109:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $109
8010737d:	6a 6d                	push   $0x6d
  jmp alltraps
8010737f:	e9 5c f5 ff ff       	jmp    801068e0 <alltraps>

80107384 <vector110>:
.globl vector110
vector110:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $110
80107386:	6a 6e                	push   $0x6e
  jmp alltraps
80107388:	e9 53 f5 ff ff       	jmp    801068e0 <alltraps>

8010738d <vector111>:
.globl vector111
vector111:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $111
8010738f:	6a 6f                	push   $0x6f
  jmp alltraps
80107391:	e9 4a f5 ff ff       	jmp    801068e0 <alltraps>

80107396 <vector112>:
.globl vector112
vector112:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $112
80107398:	6a 70                	push   $0x70
  jmp alltraps
8010739a:	e9 41 f5 ff ff       	jmp    801068e0 <alltraps>

8010739f <vector113>:
.globl vector113
vector113:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $113
801073a1:	6a 71                	push   $0x71
  jmp alltraps
801073a3:	e9 38 f5 ff ff       	jmp    801068e0 <alltraps>

801073a8 <vector114>:
.globl vector114
vector114:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $114
801073aa:	6a 72                	push   $0x72
  jmp alltraps
801073ac:	e9 2f f5 ff ff       	jmp    801068e0 <alltraps>

801073b1 <vector115>:
.globl vector115
vector115:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $115
801073b3:	6a 73                	push   $0x73
  jmp alltraps
801073b5:	e9 26 f5 ff ff       	jmp    801068e0 <alltraps>

801073ba <vector116>:
.globl vector116
vector116:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $116
801073bc:	6a 74                	push   $0x74
  jmp alltraps
801073be:	e9 1d f5 ff ff       	jmp    801068e0 <alltraps>

801073c3 <vector117>:
.globl vector117
vector117:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $117
801073c5:	6a 75                	push   $0x75
  jmp alltraps
801073c7:	e9 14 f5 ff ff       	jmp    801068e0 <alltraps>

801073cc <vector118>:
.globl vector118
vector118:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $118
801073ce:	6a 76                	push   $0x76
  jmp alltraps
801073d0:	e9 0b f5 ff ff       	jmp    801068e0 <alltraps>

801073d5 <vector119>:
.globl vector119
vector119:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $119
801073d7:	6a 77                	push   $0x77
  jmp alltraps
801073d9:	e9 02 f5 ff ff       	jmp    801068e0 <alltraps>

801073de <vector120>:
.globl vector120
vector120:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $120
801073e0:	6a 78                	push   $0x78
  jmp alltraps
801073e2:	e9 f9 f4 ff ff       	jmp    801068e0 <alltraps>

801073e7 <vector121>:
.globl vector121
vector121:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $121
801073e9:	6a 79                	push   $0x79
  jmp alltraps
801073eb:	e9 f0 f4 ff ff       	jmp    801068e0 <alltraps>

801073f0 <vector122>:
.globl vector122
vector122:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $122
801073f2:	6a 7a                	push   $0x7a
  jmp alltraps
801073f4:	e9 e7 f4 ff ff       	jmp    801068e0 <alltraps>

801073f9 <vector123>:
.globl vector123
vector123:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $123
801073fb:	6a 7b                	push   $0x7b
  jmp alltraps
801073fd:	e9 de f4 ff ff       	jmp    801068e0 <alltraps>

80107402 <vector124>:
.globl vector124
vector124:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $124
80107404:	6a 7c                	push   $0x7c
  jmp alltraps
80107406:	e9 d5 f4 ff ff       	jmp    801068e0 <alltraps>

8010740b <vector125>:
.globl vector125
vector125:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $125
8010740d:	6a 7d                	push   $0x7d
  jmp alltraps
8010740f:	e9 cc f4 ff ff       	jmp    801068e0 <alltraps>

80107414 <vector126>:
.globl vector126
vector126:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $126
80107416:	6a 7e                	push   $0x7e
  jmp alltraps
80107418:	e9 c3 f4 ff ff       	jmp    801068e0 <alltraps>

8010741d <vector127>:
.globl vector127
vector127:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $127
8010741f:	6a 7f                	push   $0x7f
  jmp alltraps
80107421:	e9 ba f4 ff ff       	jmp    801068e0 <alltraps>

80107426 <vector128>:
.globl vector128
vector128:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $128
80107428:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010742d:	e9 ae f4 ff ff       	jmp    801068e0 <alltraps>

80107432 <vector129>:
.globl vector129
vector129:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $129
80107434:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107439:	e9 a2 f4 ff ff       	jmp    801068e0 <alltraps>

8010743e <vector130>:
.globl vector130
vector130:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $130
80107440:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107445:	e9 96 f4 ff ff       	jmp    801068e0 <alltraps>

8010744a <vector131>:
.globl vector131
vector131:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $131
8010744c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107451:	e9 8a f4 ff ff       	jmp    801068e0 <alltraps>

80107456 <vector132>:
.globl vector132
vector132:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $132
80107458:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010745d:	e9 7e f4 ff ff       	jmp    801068e0 <alltraps>

80107462 <vector133>:
.globl vector133
vector133:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $133
80107464:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107469:	e9 72 f4 ff ff       	jmp    801068e0 <alltraps>

8010746e <vector134>:
.globl vector134
vector134:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $134
80107470:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107475:	e9 66 f4 ff ff       	jmp    801068e0 <alltraps>

8010747a <vector135>:
.globl vector135
vector135:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $135
8010747c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107481:	e9 5a f4 ff ff       	jmp    801068e0 <alltraps>

80107486 <vector136>:
.globl vector136
vector136:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $136
80107488:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010748d:	e9 4e f4 ff ff       	jmp    801068e0 <alltraps>

80107492 <vector137>:
.globl vector137
vector137:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $137
80107494:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107499:	e9 42 f4 ff ff       	jmp    801068e0 <alltraps>

8010749e <vector138>:
.globl vector138
vector138:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $138
801074a0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801074a5:	e9 36 f4 ff ff       	jmp    801068e0 <alltraps>

801074aa <vector139>:
.globl vector139
vector139:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $139
801074ac:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801074b1:	e9 2a f4 ff ff       	jmp    801068e0 <alltraps>

801074b6 <vector140>:
.globl vector140
vector140:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $140
801074b8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801074bd:	e9 1e f4 ff ff       	jmp    801068e0 <alltraps>

801074c2 <vector141>:
.globl vector141
vector141:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $141
801074c4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801074c9:	e9 12 f4 ff ff       	jmp    801068e0 <alltraps>

801074ce <vector142>:
.globl vector142
vector142:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $142
801074d0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801074d5:	e9 06 f4 ff ff       	jmp    801068e0 <alltraps>

801074da <vector143>:
.globl vector143
vector143:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $143
801074dc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801074e1:	e9 fa f3 ff ff       	jmp    801068e0 <alltraps>

801074e6 <vector144>:
.globl vector144
vector144:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $144
801074e8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074ed:	e9 ee f3 ff ff       	jmp    801068e0 <alltraps>

801074f2 <vector145>:
.globl vector145
vector145:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $145
801074f4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074f9:	e9 e2 f3 ff ff       	jmp    801068e0 <alltraps>

801074fe <vector146>:
.globl vector146
vector146:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $146
80107500:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107505:	e9 d6 f3 ff ff       	jmp    801068e0 <alltraps>

8010750a <vector147>:
.globl vector147
vector147:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $147
8010750c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107511:	e9 ca f3 ff ff       	jmp    801068e0 <alltraps>

80107516 <vector148>:
.globl vector148
vector148:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $148
80107518:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010751d:	e9 be f3 ff ff       	jmp    801068e0 <alltraps>

80107522 <vector149>:
.globl vector149
vector149:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $149
80107524:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107529:	e9 b2 f3 ff ff       	jmp    801068e0 <alltraps>

8010752e <vector150>:
.globl vector150
vector150:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $150
80107530:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107535:	e9 a6 f3 ff ff       	jmp    801068e0 <alltraps>

8010753a <vector151>:
.globl vector151
vector151:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $151
8010753c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107541:	e9 9a f3 ff ff       	jmp    801068e0 <alltraps>

80107546 <vector152>:
.globl vector152
vector152:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $152
80107548:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010754d:	e9 8e f3 ff ff       	jmp    801068e0 <alltraps>

80107552 <vector153>:
.globl vector153
vector153:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $153
80107554:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107559:	e9 82 f3 ff ff       	jmp    801068e0 <alltraps>

8010755e <vector154>:
.globl vector154
vector154:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $154
80107560:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107565:	e9 76 f3 ff ff       	jmp    801068e0 <alltraps>

8010756a <vector155>:
.globl vector155
vector155:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $155
8010756c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107571:	e9 6a f3 ff ff       	jmp    801068e0 <alltraps>

80107576 <vector156>:
.globl vector156
vector156:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $156
80107578:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010757d:	e9 5e f3 ff ff       	jmp    801068e0 <alltraps>

80107582 <vector157>:
.globl vector157
vector157:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $157
80107584:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107589:	e9 52 f3 ff ff       	jmp    801068e0 <alltraps>

8010758e <vector158>:
.globl vector158
vector158:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $158
80107590:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107595:	e9 46 f3 ff ff       	jmp    801068e0 <alltraps>

8010759a <vector159>:
.globl vector159
vector159:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $159
8010759c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801075a1:	e9 3a f3 ff ff       	jmp    801068e0 <alltraps>

801075a6 <vector160>:
.globl vector160
vector160:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $160
801075a8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801075ad:	e9 2e f3 ff ff       	jmp    801068e0 <alltraps>

801075b2 <vector161>:
.globl vector161
vector161:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $161
801075b4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801075b9:	e9 22 f3 ff ff       	jmp    801068e0 <alltraps>

801075be <vector162>:
.globl vector162
vector162:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $162
801075c0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801075c5:	e9 16 f3 ff ff       	jmp    801068e0 <alltraps>

801075ca <vector163>:
.globl vector163
vector163:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $163
801075cc:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801075d1:	e9 0a f3 ff ff       	jmp    801068e0 <alltraps>

801075d6 <vector164>:
.globl vector164
vector164:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $164
801075d8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801075dd:	e9 fe f2 ff ff       	jmp    801068e0 <alltraps>

801075e2 <vector165>:
.globl vector165
vector165:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $165
801075e4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801075e9:	e9 f2 f2 ff ff       	jmp    801068e0 <alltraps>

801075ee <vector166>:
.globl vector166
vector166:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $166
801075f0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075f5:	e9 e6 f2 ff ff       	jmp    801068e0 <alltraps>

801075fa <vector167>:
.globl vector167
vector167:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $167
801075fc:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107601:	e9 da f2 ff ff       	jmp    801068e0 <alltraps>

80107606 <vector168>:
.globl vector168
vector168:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $168
80107608:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010760d:	e9 ce f2 ff ff       	jmp    801068e0 <alltraps>

80107612 <vector169>:
.globl vector169
vector169:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $169
80107614:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107619:	e9 c2 f2 ff ff       	jmp    801068e0 <alltraps>

8010761e <vector170>:
.globl vector170
vector170:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $170
80107620:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107625:	e9 b6 f2 ff ff       	jmp    801068e0 <alltraps>

8010762a <vector171>:
.globl vector171
vector171:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $171
8010762c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107631:	e9 aa f2 ff ff       	jmp    801068e0 <alltraps>

80107636 <vector172>:
.globl vector172
vector172:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $172
80107638:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010763d:	e9 9e f2 ff ff       	jmp    801068e0 <alltraps>

80107642 <vector173>:
.globl vector173
vector173:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $173
80107644:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107649:	e9 92 f2 ff ff       	jmp    801068e0 <alltraps>

8010764e <vector174>:
.globl vector174
vector174:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $174
80107650:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107655:	e9 86 f2 ff ff       	jmp    801068e0 <alltraps>

8010765a <vector175>:
.globl vector175
vector175:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $175
8010765c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107661:	e9 7a f2 ff ff       	jmp    801068e0 <alltraps>

80107666 <vector176>:
.globl vector176
vector176:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $176
80107668:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010766d:	e9 6e f2 ff ff       	jmp    801068e0 <alltraps>

80107672 <vector177>:
.globl vector177
vector177:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $177
80107674:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107679:	e9 62 f2 ff ff       	jmp    801068e0 <alltraps>

8010767e <vector178>:
.globl vector178
vector178:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $178
80107680:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107685:	e9 56 f2 ff ff       	jmp    801068e0 <alltraps>

8010768a <vector179>:
.globl vector179
vector179:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $179
8010768c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107691:	e9 4a f2 ff ff       	jmp    801068e0 <alltraps>

80107696 <vector180>:
.globl vector180
vector180:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $180
80107698:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010769d:	e9 3e f2 ff ff       	jmp    801068e0 <alltraps>

801076a2 <vector181>:
.globl vector181
vector181:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $181
801076a4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801076a9:	e9 32 f2 ff ff       	jmp    801068e0 <alltraps>

801076ae <vector182>:
.globl vector182
vector182:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $182
801076b0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801076b5:	e9 26 f2 ff ff       	jmp    801068e0 <alltraps>

801076ba <vector183>:
.globl vector183
vector183:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $183
801076bc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801076c1:	e9 1a f2 ff ff       	jmp    801068e0 <alltraps>

801076c6 <vector184>:
.globl vector184
vector184:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $184
801076c8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801076cd:	e9 0e f2 ff ff       	jmp    801068e0 <alltraps>

801076d2 <vector185>:
.globl vector185
vector185:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $185
801076d4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801076d9:	e9 02 f2 ff ff       	jmp    801068e0 <alltraps>

801076de <vector186>:
.globl vector186
vector186:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $186
801076e0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801076e5:	e9 f6 f1 ff ff       	jmp    801068e0 <alltraps>

801076ea <vector187>:
.globl vector187
vector187:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $187
801076ec:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076f1:	e9 ea f1 ff ff       	jmp    801068e0 <alltraps>

801076f6 <vector188>:
.globl vector188
vector188:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $188
801076f8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076fd:	e9 de f1 ff ff       	jmp    801068e0 <alltraps>

80107702 <vector189>:
.globl vector189
vector189:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $189
80107704:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107709:	e9 d2 f1 ff ff       	jmp    801068e0 <alltraps>

8010770e <vector190>:
.globl vector190
vector190:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $190
80107710:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107715:	e9 c6 f1 ff ff       	jmp    801068e0 <alltraps>

8010771a <vector191>:
.globl vector191
vector191:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $191
8010771c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107721:	e9 ba f1 ff ff       	jmp    801068e0 <alltraps>

80107726 <vector192>:
.globl vector192
vector192:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $192
80107728:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010772d:	e9 ae f1 ff ff       	jmp    801068e0 <alltraps>

80107732 <vector193>:
.globl vector193
vector193:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $193
80107734:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107739:	e9 a2 f1 ff ff       	jmp    801068e0 <alltraps>

8010773e <vector194>:
.globl vector194
vector194:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $194
80107740:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107745:	e9 96 f1 ff ff       	jmp    801068e0 <alltraps>

8010774a <vector195>:
.globl vector195
vector195:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $195
8010774c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107751:	e9 8a f1 ff ff       	jmp    801068e0 <alltraps>

80107756 <vector196>:
.globl vector196
vector196:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $196
80107758:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010775d:	e9 7e f1 ff ff       	jmp    801068e0 <alltraps>

80107762 <vector197>:
.globl vector197
vector197:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $197
80107764:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107769:	e9 72 f1 ff ff       	jmp    801068e0 <alltraps>

8010776e <vector198>:
.globl vector198
vector198:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $198
80107770:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107775:	e9 66 f1 ff ff       	jmp    801068e0 <alltraps>

8010777a <vector199>:
.globl vector199
vector199:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $199
8010777c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107781:	e9 5a f1 ff ff       	jmp    801068e0 <alltraps>

80107786 <vector200>:
.globl vector200
vector200:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $200
80107788:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010778d:	e9 4e f1 ff ff       	jmp    801068e0 <alltraps>

80107792 <vector201>:
.globl vector201
vector201:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $201
80107794:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107799:	e9 42 f1 ff ff       	jmp    801068e0 <alltraps>

8010779e <vector202>:
.globl vector202
vector202:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $202
801077a0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801077a5:	e9 36 f1 ff ff       	jmp    801068e0 <alltraps>

801077aa <vector203>:
.globl vector203
vector203:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $203
801077ac:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801077b1:	e9 2a f1 ff ff       	jmp    801068e0 <alltraps>

801077b6 <vector204>:
.globl vector204
vector204:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $204
801077b8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801077bd:	e9 1e f1 ff ff       	jmp    801068e0 <alltraps>

801077c2 <vector205>:
.globl vector205
vector205:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $205
801077c4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801077c9:	e9 12 f1 ff ff       	jmp    801068e0 <alltraps>

801077ce <vector206>:
.globl vector206
vector206:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $206
801077d0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801077d5:	e9 06 f1 ff ff       	jmp    801068e0 <alltraps>

801077da <vector207>:
.globl vector207
vector207:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $207
801077dc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801077e1:	e9 fa f0 ff ff       	jmp    801068e0 <alltraps>

801077e6 <vector208>:
.globl vector208
vector208:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $208
801077e8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077ed:	e9 ee f0 ff ff       	jmp    801068e0 <alltraps>

801077f2 <vector209>:
.globl vector209
vector209:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $209
801077f4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077f9:	e9 e2 f0 ff ff       	jmp    801068e0 <alltraps>

801077fe <vector210>:
.globl vector210
vector210:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $210
80107800:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107805:	e9 d6 f0 ff ff       	jmp    801068e0 <alltraps>

8010780a <vector211>:
.globl vector211
vector211:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $211
8010780c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107811:	e9 ca f0 ff ff       	jmp    801068e0 <alltraps>

80107816 <vector212>:
.globl vector212
vector212:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $212
80107818:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010781d:	e9 be f0 ff ff       	jmp    801068e0 <alltraps>

80107822 <vector213>:
.globl vector213
vector213:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $213
80107824:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107829:	e9 b2 f0 ff ff       	jmp    801068e0 <alltraps>

8010782e <vector214>:
.globl vector214
vector214:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $214
80107830:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107835:	e9 a6 f0 ff ff       	jmp    801068e0 <alltraps>

8010783a <vector215>:
.globl vector215
vector215:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $215
8010783c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107841:	e9 9a f0 ff ff       	jmp    801068e0 <alltraps>

80107846 <vector216>:
.globl vector216
vector216:
  pushl $0
80107846:	6a 00                	push   $0x0
  pushl $216
80107848:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010784d:	e9 8e f0 ff ff       	jmp    801068e0 <alltraps>

80107852 <vector217>:
.globl vector217
vector217:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $217
80107854:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107859:	e9 82 f0 ff ff       	jmp    801068e0 <alltraps>

8010785e <vector218>:
.globl vector218
vector218:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $218
80107860:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107865:	e9 76 f0 ff ff       	jmp    801068e0 <alltraps>

8010786a <vector219>:
.globl vector219
vector219:
  pushl $0
8010786a:	6a 00                	push   $0x0
  pushl $219
8010786c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107871:	e9 6a f0 ff ff       	jmp    801068e0 <alltraps>

80107876 <vector220>:
.globl vector220
vector220:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $220
80107878:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010787d:	e9 5e f0 ff ff       	jmp    801068e0 <alltraps>

80107882 <vector221>:
.globl vector221
vector221:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $221
80107884:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107889:	e9 52 f0 ff ff       	jmp    801068e0 <alltraps>

8010788e <vector222>:
.globl vector222
vector222:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $222
80107890:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107895:	e9 46 f0 ff ff       	jmp    801068e0 <alltraps>

8010789a <vector223>:
.globl vector223
vector223:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $223
8010789c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801078a1:	e9 3a f0 ff ff       	jmp    801068e0 <alltraps>

801078a6 <vector224>:
.globl vector224
vector224:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $224
801078a8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801078ad:	e9 2e f0 ff ff       	jmp    801068e0 <alltraps>

801078b2 <vector225>:
.globl vector225
vector225:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $225
801078b4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801078b9:	e9 22 f0 ff ff       	jmp    801068e0 <alltraps>

801078be <vector226>:
.globl vector226
vector226:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $226
801078c0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801078c5:	e9 16 f0 ff ff       	jmp    801068e0 <alltraps>

801078ca <vector227>:
.globl vector227
vector227:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $227
801078cc:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801078d1:	e9 0a f0 ff ff       	jmp    801068e0 <alltraps>

801078d6 <vector228>:
.globl vector228
vector228:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $228
801078d8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801078dd:	e9 fe ef ff ff       	jmp    801068e0 <alltraps>

801078e2 <vector229>:
.globl vector229
vector229:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $229
801078e4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801078e9:	e9 f2 ef ff ff       	jmp    801068e0 <alltraps>

801078ee <vector230>:
.globl vector230
vector230:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $230
801078f0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078f5:	e9 e6 ef ff ff       	jmp    801068e0 <alltraps>

801078fa <vector231>:
.globl vector231
vector231:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $231
801078fc:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107901:	e9 da ef ff ff       	jmp    801068e0 <alltraps>

80107906 <vector232>:
.globl vector232
vector232:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $232
80107908:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010790d:	e9 ce ef ff ff       	jmp    801068e0 <alltraps>

80107912 <vector233>:
.globl vector233
vector233:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $233
80107914:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107919:	e9 c2 ef ff ff       	jmp    801068e0 <alltraps>

8010791e <vector234>:
.globl vector234
vector234:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $234
80107920:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107925:	e9 b6 ef ff ff       	jmp    801068e0 <alltraps>

8010792a <vector235>:
.globl vector235
vector235:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $235
8010792c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107931:	e9 aa ef ff ff       	jmp    801068e0 <alltraps>

80107936 <vector236>:
.globl vector236
vector236:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $236
80107938:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010793d:	e9 9e ef ff ff       	jmp    801068e0 <alltraps>

80107942 <vector237>:
.globl vector237
vector237:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $237
80107944:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107949:	e9 92 ef ff ff       	jmp    801068e0 <alltraps>

8010794e <vector238>:
.globl vector238
vector238:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $238
80107950:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107955:	e9 86 ef ff ff       	jmp    801068e0 <alltraps>

8010795a <vector239>:
.globl vector239
vector239:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $239
8010795c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107961:	e9 7a ef ff ff       	jmp    801068e0 <alltraps>

80107966 <vector240>:
.globl vector240
vector240:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $240
80107968:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010796d:	e9 6e ef ff ff       	jmp    801068e0 <alltraps>

80107972 <vector241>:
.globl vector241
vector241:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $241
80107974:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107979:	e9 62 ef ff ff       	jmp    801068e0 <alltraps>

8010797e <vector242>:
.globl vector242
vector242:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $242
80107980:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107985:	e9 56 ef ff ff       	jmp    801068e0 <alltraps>

8010798a <vector243>:
.globl vector243
vector243:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $243
8010798c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107991:	e9 4a ef ff ff       	jmp    801068e0 <alltraps>

80107996 <vector244>:
.globl vector244
vector244:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $244
80107998:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010799d:	e9 3e ef ff ff       	jmp    801068e0 <alltraps>

801079a2 <vector245>:
.globl vector245
vector245:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $245
801079a4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801079a9:	e9 32 ef ff ff       	jmp    801068e0 <alltraps>

801079ae <vector246>:
.globl vector246
vector246:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $246
801079b0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801079b5:	e9 26 ef ff ff       	jmp    801068e0 <alltraps>

801079ba <vector247>:
.globl vector247
vector247:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $247
801079bc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801079c1:	e9 1a ef ff ff       	jmp    801068e0 <alltraps>

801079c6 <vector248>:
.globl vector248
vector248:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $248
801079c8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801079cd:	e9 0e ef ff ff       	jmp    801068e0 <alltraps>

801079d2 <vector249>:
.globl vector249
vector249:
  pushl $0
801079d2:	6a 00                	push   $0x0
  pushl $249
801079d4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801079d9:	e9 02 ef ff ff       	jmp    801068e0 <alltraps>

801079de <vector250>:
.globl vector250
vector250:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $250
801079e0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801079e5:	e9 f6 ee ff ff       	jmp    801068e0 <alltraps>

801079ea <vector251>:
.globl vector251
vector251:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $251
801079ec:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079f1:	e9 ea ee ff ff       	jmp    801068e0 <alltraps>

801079f6 <vector252>:
.globl vector252
vector252:
  pushl $0
801079f6:	6a 00                	push   $0x0
  pushl $252
801079f8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079fd:	e9 de ee ff ff       	jmp    801068e0 <alltraps>

80107a02 <vector253>:
.globl vector253
vector253:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $253
80107a04:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107a09:	e9 d2 ee ff ff       	jmp    801068e0 <alltraps>

80107a0e <vector254>:
.globl vector254
vector254:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $254
80107a10:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107a15:	e9 c6 ee ff ff       	jmp    801068e0 <alltraps>

80107a1a <vector255>:
.globl vector255
vector255:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $255
80107a1c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107a21:	e9 ba ee ff ff       	jmp    801068e0 <alltraps>
80107a26:	66 90                	xchg   %ax,%ax

80107a28 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107a28:	55                   	push   %ebp
80107a29:	89 e5                	mov    %esp,%ebp
80107a2b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a31:	83 e8 01             	sub    $0x1,%eax
80107a34:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a38:	8b 45 08             	mov    0x8(%ebp),%eax
80107a3b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a42:	c1 e8 10             	shr    $0x10,%eax
80107a45:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107a49:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a4c:	0f 01 10             	lgdtl  (%eax)
}
80107a4f:	c9                   	leave  
80107a50:	c3                   	ret    

80107a51 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a51:	55                   	push   %ebp
80107a52:	89 e5                	mov    %esp,%ebp
80107a54:	83 ec 04             	sub    $0x4,%esp
80107a57:	8b 45 08             	mov    0x8(%ebp),%eax
80107a5a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a5e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a62:	0f 00 d8             	ltr    %ax
}
80107a65:	c9                   	leave  
80107a66:	c3                   	ret    

80107a67 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a67:	55                   	push   %ebp
80107a68:	89 e5                	mov    %esp,%ebp
80107a6a:	83 ec 04             	sub    $0x4,%esp
80107a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a70:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a74:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a78:	8e e8                	mov    %eax,%gs
}
80107a7a:	c9                   	leave  
80107a7b:	c3                   	ret    

80107a7c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a7c:	55                   	push   %ebp
80107a7d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a82:	0f 22 d8             	mov    %eax,%cr3
}
80107a85:	5d                   	pop    %ebp
80107a86:	c3                   	ret    

80107a87 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a87:	55                   	push   %ebp
80107a88:	89 e5                	mov    %esp,%ebp
80107a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a8d:	05 00 00 00 80       	add    $0x80000000,%eax
80107a92:	5d                   	pop    %ebp
80107a93:	c3                   	ret    

80107a94 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a94:	55                   	push   %ebp
80107a95:	89 e5                	mov    %esp,%ebp
80107a97:	8b 45 08             	mov    0x8(%ebp),%eax
80107a9a:	05 00 00 00 80       	add    $0x80000000,%eax
80107a9f:	5d                   	pop    %ebp
80107aa0:	c3                   	ret    

80107aa1 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107aa1:	55                   	push   %ebp
80107aa2:	89 e5                	mov    %esp,%ebp
80107aa4:	53                   	push   %ebx
80107aa5:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107aa8:	e8 0c b7 ff ff       	call   801031b9 <cpunum>
80107aad:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107ab3:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107ab8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abe:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107adb:	83 e2 f0             	and    $0xfffffff0,%edx
80107ade:	83 ca 0a             	or     $0xa,%edx
80107ae1:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aeb:	83 ca 10             	or     $0x10,%edx
80107aee:	88 50 7d             	mov    %dl,0x7d(%eax)
80107af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107af8:	83 e2 9f             	and    $0xffffff9f,%edx
80107afb:	88 50 7d             	mov    %dl,0x7d(%eax)
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b05:	83 ca 80             	or     $0xffffff80,%edx
80107b08:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b12:	83 ca 0f             	or     $0xf,%edx
80107b15:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b1f:	83 e2 ef             	and    $0xffffffef,%edx
80107b22:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b28:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b2c:	83 e2 df             	and    $0xffffffdf,%edx
80107b2f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b39:	83 ca 40             	or     $0x40,%edx
80107b3c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b42:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b46:	83 ca 80             	or     $0xffffff80,%edx
80107b49:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b56:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b5d:	ff ff 
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b69:	00 00 
80107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b78:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b7f:	83 e2 f0             	and    $0xfffffff0,%edx
80107b82:	83 ca 02             	or     $0x2,%edx
80107b85:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b95:	83 ca 10             	or     $0x10,%edx
80107b98:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ba8:	83 e2 9f             	and    $0xffffff9f,%edx
80107bab:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bbb:	83 ca 80             	or     $0xffffff80,%edx
80107bbe:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bce:	83 ca 0f             	or     $0xf,%edx
80107bd1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107be1:	83 e2 ef             	and    $0xffffffef,%edx
80107be4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bed:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bf4:	83 e2 df             	and    $0xffffffdf,%edx
80107bf7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c00:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c07:	83 ca 40             	or     $0x40,%edx
80107c0a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c1a:	83 ca 80             	or     $0xffffff80,%edx
80107c1d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c30:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c37:	ff ff 
80107c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c43:	00 00 
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c52:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c59:	83 e2 f0             	and    $0xfffffff0,%edx
80107c5c:	83 ca 0a             	or     $0xa,%edx
80107c5f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c68:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c6f:	83 ca 10             	or     $0x10,%edx
80107c72:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c82:	83 ca 60             	or     $0x60,%edx
80107c85:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c95:	83 ca 80             	or     $0xffffff80,%edx
80107c98:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ca8:	83 ca 0f             	or     $0xf,%edx
80107cab:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cbb:	83 e2 ef             	and    $0xffffffef,%edx
80107cbe:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cce:	83 e2 df             	and    $0xffffffdf,%edx
80107cd1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cda:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ce1:	83 ca 40             	or     $0x40,%edx
80107ce4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ced:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cf4:	83 ca 80             	or     $0xffffff80,%edx
80107cf7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d00:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107d11:	ff ff 
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107d1d:	00 00 
80107d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d22:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d33:	83 e2 f0             	and    $0xfffffff0,%edx
80107d36:	83 ca 02             	or     $0x2,%edx
80107d39:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d49:	83 ca 10             	or     $0x10,%edx
80107d4c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d55:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d5c:	83 ca 60             	or     $0x60,%edx
80107d5f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d68:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d6f:	83 ca 80             	or     $0xffffff80,%edx
80107d72:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d82:	83 ca 0f             	or     $0xf,%edx
80107d85:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d95:	83 e2 ef             	and    $0xffffffef,%edx
80107d98:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107da8:	83 e2 df             	and    $0xffffffdf,%edx
80107dab:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107dbb:	83 ca 40             	or     $0x40,%edx
80107dbe:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107dce:	83 ca 80             	or     $0xffffff80,%edx
80107dd1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dda:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de4:	05 b4 00 00 00       	add    $0xb4,%eax
80107de9:	89 c3                	mov    %eax,%ebx
80107deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dee:	05 b4 00 00 00       	add    $0xb4,%eax
80107df3:	c1 e8 10             	shr    $0x10,%eax
80107df6:	89 c1                	mov    %eax,%ecx
80107df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfb:	05 b4 00 00 00       	add    $0xb4,%eax
80107e00:	c1 e8 18             	shr    $0x18,%eax
80107e03:	89 c2                	mov    %eax,%edx
80107e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e08:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107e0f:	00 00 
80107e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e14:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1e:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e27:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e2e:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e31:	83 c9 02             	or     $0x2,%ecx
80107e34:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3d:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e44:	83 c9 10             	or     $0x10,%ecx
80107e47:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e50:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e57:	83 e1 9f             	and    $0xffffff9f,%ecx
80107e5a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e63:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e6a:	83 c9 80             	or     $0xffffff80,%ecx
80107e6d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e76:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e7d:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e80:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e89:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e90:	83 e1 ef             	and    $0xffffffef,%ecx
80107e93:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ea3:	83 e1 df             	and    $0xffffffdf,%ecx
80107ea6:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaf:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107eb6:	83 c9 40             	or     $0x40,%ecx
80107eb9:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ec9:	83 c9 80             	or     $0xffffff80,%ecx
80107ecc:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ede:	83 c0 70             	add    $0x70,%eax
80107ee1:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107ee8:	00 
80107ee9:	89 04 24             	mov    %eax,(%esp)
80107eec:	e8 37 fb ff ff       	call   80107a28 <lgdt>
  loadgs(SEG_KCPU << 3);
80107ef1:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107ef8:	e8 6a fb ff ff       	call   80107a67 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f00:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107f06:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107f0d:	00 00 00 00 
}
80107f11:	83 c4 24             	add    $0x24,%esp
80107f14:	5b                   	pop    %ebx
80107f15:	5d                   	pop    %ebp
80107f16:	c3                   	ret    

80107f17 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f17:	55                   	push   %ebp
80107f18:	89 e5                	mov    %esp,%ebp
80107f1a:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f20:	c1 e8 16             	shr    $0x16,%eax
80107f23:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f2d:	01 d0                	add    %edx,%eax
80107f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f35:	8b 00                	mov    (%eax),%eax
80107f37:	83 e0 01             	and    $0x1,%eax
80107f3a:	85 c0                	test   %eax,%eax
80107f3c:	74 17                	je     80107f55 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f41:	8b 00                	mov    (%eax),%eax
80107f43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f48:	89 04 24             	mov    %eax,(%esp)
80107f4b:	e8 44 fb ff ff       	call   80107a94 <p2v>
80107f50:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f53:	eb 4b                	jmp    80107fa0 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f59:	74 0e                	je     80107f69 <walkpgdir+0x52>
80107f5b:	e8 c7 ae ff ff       	call   80102e27 <kalloc>
80107f60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f67:	75 07                	jne    80107f70 <walkpgdir+0x59>
      return 0;
80107f69:	b8 00 00 00 00       	mov    $0x0,%eax
80107f6e:	eb 47                	jmp    80107fb7 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f70:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f77:	00 
80107f78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f7f:	00 
80107f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f83:	89 04 24             	mov    %eax,(%esp)
80107f86:	e8 b3 d4 ff ff       	call   8010543e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8e:	89 04 24             	mov    %eax,(%esp)
80107f91:	e8 f1 fa ff ff       	call   80107a87 <v2p>
80107f96:	89 c2                	mov    %eax,%edx
80107f98:	83 ca 07             	or     $0x7,%edx
80107f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9e:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa3:	c1 e8 0c             	shr    $0xc,%eax
80107fa6:	25 ff 03 00 00       	and    $0x3ff,%eax
80107fab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb5:	01 d0                	add    %edx,%eax
}
80107fb7:	c9                   	leave  
80107fb8:	c3                   	ret    

80107fb9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107fb9:	55                   	push   %ebp
80107fba:	89 e5                	mov    %esp,%ebp
80107fbc:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107fca:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fcd:	8b 45 10             	mov    0x10(%ebp),%eax
80107fd0:	01 d0                	add    %edx,%eax
80107fd2:	83 e8 01             	sub    $0x1,%eax
80107fd5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107fdd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107fe4:	00 
80107fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe8:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fec:	8b 45 08             	mov    0x8(%ebp),%eax
80107fef:	89 04 24             	mov    %eax,(%esp)
80107ff2:	e8 20 ff ff ff       	call   80107f17 <walkpgdir>
80107ff7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ffa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ffe:	75 07                	jne    80108007 <mappages+0x4e>
      return -1;
80108000:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108005:	eb 46                	jmp    8010804d <mappages+0x94>
    if(*pte & PTE_P)
80108007:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010800a:	8b 00                	mov    (%eax),%eax
8010800c:	83 e0 01             	and    $0x1,%eax
8010800f:	85 c0                	test   %eax,%eax
80108011:	74 0c                	je     8010801f <mappages+0x66>
      panic("remap");
80108013:	c7 04 24 3c 8e 10 80 	movl   $0x80108e3c,(%esp)
8010801a:	e8 27 85 ff ff       	call   80100546 <panic>
    *pte = pa | perm | PTE_P;
8010801f:	8b 45 18             	mov    0x18(%ebp),%eax
80108022:	0b 45 14             	or     0x14(%ebp),%eax
80108025:	89 c2                	mov    %eax,%edx
80108027:	83 ca 01             	or     $0x1,%edx
8010802a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010802d:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010802f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108032:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108035:	74 10                	je     80108047 <mappages+0x8e>
      break;
    a += PGSIZE;
80108037:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010803e:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108045:	eb 96                	jmp    80107fdd <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108047:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108048:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010804d:	c9                   	leave  
8010804e:	c3                   	ret    

8010804f <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
8010804f:	55                   	push   %ebp
80108050:	89 e5                	mov    %esp,%ebp
80108052:	53                   	push   %ebx
80108053:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108056:	e8 cc ad ff ff       	call   80102e27 <kalloc>
8010805b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010805e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108062:	75 0a                	jne    8010806e <setupkvm+0x1f>
    return 0;
80108064:	b8 00 00 00 00       	mov    $0x0,%eax
80108069:	e9 98 00 00 00       	jmp    80108106 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
8010806e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108075:	00 
80108076:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010807d:	00 
8010807e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108081:	89 04 24             	mov    %eax,(%esp)
80108084:	e8 b5 d3 ff ff       	call   8010543e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108089:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108090:	e8 ff f9 ff ff       	call   80107a94 <p2v>
80108095:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010809a:	76 0c                	jbe    801080a8 <setupkvm+0x59>
    panic("PHYSTOP too high");
8010809c:	c7 04 24 42 8e 10 80 	movl   $0x80108e42,(%esp)
801080a3:	e8 9e 84 ff ff       	call   80100546 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080a8:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
801080af:	eb 49                	jmp    801080fa <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801080b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801080b4:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801080b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801080ba:	8b 50 04             	mov    0x4(%eax),%edx
801080bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c0:	8b 58 08             	mov    0x8(%eax),%ebx
801080c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c6:	8b 40 04             	mov    0x4(%eax),%eax
801080c9:	29 c3                	sub    %eax,%ebx
801080cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ce:	8b 00                	mov    (%eax),%eax
801080d0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801080d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
801080d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801080dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801080e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080e3:	89 04 24             	mov    %eax,(%esp)
801080e6:	e8 ce fe ff ff       	call   80107fb9 <mappages>
801080eb:	85 c0                	test   %eax,%eax
801080ed:	79 07                	jns    801080f6 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801080ef:	b8 00 00 00 00       	mov    $0x0,%eax
801080f4:	eb 10                	jmp    80108106 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080f6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801080fa:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80108101:	72 ae                	jb     801080b1 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108103:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108106:	83 c4 34             	add    $0x34,%esp
80108109:	5b                   	pop    %ebx
8010810a:	5d                   	pop    %ebp
8010810b:	c3                   	ret    

8010810c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010810c:	55                   	push   %ebp
8010810d:	89 e5                	mov    %esp,%ebp
8010810f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108112:	e8 38 ff ff ff       	call   8010804f <setupkvm>
80108117:	a3 18 2e 11 80       	mov    %eax,0x80112e18
  switchkvm();
8010811c:	e8 02 00 00 00       	call   80108123 <switchkvm>
}
80108121:	c9                   	leave  
80108122:	c3                   	ret    

80108123 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108123:	55                   	push   %ebp
80108124:	89 e5                	mov    %esp,%ebp
80108126:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108129:	a1 18 2e 11 80       	mov    0x80112e18,%eax
8010812e:	89 04 24             	mov    %eax,(%esp)
80108131:	e8 51 f9 ff ff       	call   80107a87 <v2p>
80108136:	89 04 24             	mov    %eax,(%esp)
80108139:	e8 3e f9 ff ff       	call   80107a7c <lcr3>
}
8010813e:	c9                   	leave  
8010813f:	c3                   	ret    

80108140 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108140:	55                   	push   %ebp
80108141:	89 e5                	mov    %esp,%ebp
80108143:	53                   	push   %ebx
80108144:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108147:	e8 eb d1 ff ff       	call   80105337 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010814c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108152:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108159:	83 c2 08             	add    $0x8,%edx
8010815c:	89 d3                	mov    %edx,%ebx
8010815e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108165:	83 c2 08             	add    $0x8,%edx
80108168:	c1 ea 10             	shr    $0x10,%edx
8010816b:	89 d1                	mov    %edx,%ecx
8010816d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108174:	83 c2 08             	add    $0x8,%edx
80108177:	c1 ea 18             	shr    $0x18,%edx
8010817a:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108181:	67 00 
80108183:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010818a:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108190:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108197:	83 e1 f0             	and    $0xfffffff0,%ecx
8010819a:	83 c9 09             	or     $0x9,%ecx
8010819d:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081a3:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081aa:	83 c9 10             	or     $0x10,%ecx
801081ad:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081b3:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081ba:	83 e1 9f             	and    $0xffffff9f,%ecx
801081bd:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081c3:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801081ca:	83 c9 80             	or     $0xffffff80,%ecx
801081cd:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801081d3:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081da:	83 e1 f0             	and    $0xfffffff0,%ecx
801081dd:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081e3:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081ea:	83 e1 ef             	and    $0xffffffef,%ecx
801081ed:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081f3:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081fa:	83 e1 df             	and    $0xffffffdf,%ecx
801081fd:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108203:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010820a:	83 c9 40             	or     $0x40,%ecx
8010820d:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108213:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010821a:	83 e1 7f             	and    $0x7f,%ecx
8010821d:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108223:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108229:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010822f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108236:	83 e2 ef             	and    $0xffffffef,%edx
80108239:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
8010823f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108245:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010824b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108251:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108258:	8b 52 08             	mov    0x8(%edx),%edx
8010825b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108261:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108264:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
8010826b:	e8 e1 f7 ff ff       	call   80107a51 <ltr>
  if(p->pgdir == 0)
80108270:	8b 45 08             	mov    0x8(%ebp),%eax
80108273:	8b 40 04             	mov    0x4(%eax),%eax
80108276:	85 c0                	test   %eax,%eax
80108278:	75 0c                	jne    80108286 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010827a:	c7 04 24 53 8e 10 80 	movl   $0x80108e53,(%esp)
80108281:	e8 c0 82 ff ff       	call   80100546 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108286:	8b 45 08             	mov    0x8(%ebp),%eax
80108289:	8b 40 04             	mov    0x4(%eax),%eax
8010828c:	89 04 24             	mov    %eax,(%esp)
8010828f:	e8 f3 f7 ff ff       	call   80107a87 <v2p>
80108294:	89 04 24             	mov    %eax,(%esp)
80108297:	e8 e0 f7 ff ff       	call   80107a7c <lcr3>
  popcli();
8010829c:	e8 de d0 ff ff       	call   8010537f <popcli>
}
801082a1:	83 c4 14             	add    $0x14,%esp
801082a4:	5b                   	pop    %ebx
801082a5:	5d                   	pop    %ebp
801082a6:	c3                   	ret    

801082a7 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801082a7:	55                   	push   %ebp
801082a8:	89 e5                	mov    %esp,%ebp
801082aa:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801082ad:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801082b4:	76 0c                	jbe    801082c2 <inituvm+0x1b>
    panic("inituvm: more than a page");
801082b6:	c7 04 24 67 8e 10 80 	movl   $0x80108e67,(%esp)
801082bd:	e8 84 82 ff ff       	call   80100546 <panic>
  mem = kalloc();
801082c2:	e8 60 ab ff ff       	call   80102e27 <kalloc>
801082c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801082ca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082d1:	00 
801082d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082d9:	00 
801082da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082dd:	89 04 24             	mov    %eax,(%esp)
801082e0:	e8 59 d1 ff ff       	call   8010543e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e8:	89 04 24             	mov    %eax,(%esp)
801082eb:	e8 97 f7 ff ff       	call   80107a87 <v2p>
801082f0:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801082f7:	00 
801082f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082fc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108303:	00 
80108304:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010830b:	00 
8010830c:	8b 45 08             	mov    0x8(%ebp),%eax
8010830f:	89 04 24             	mov    %eax,(%esp)
80108312:	e8 a2 fc ff ff       	call   80107fb9 <mappages>
  memmove(mem, init, sz);
80108317:	8b 45 10             	mov    0x10(%ebp),%eax
8010831a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010831e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108321:	89 44 24 04          	mov    %eax,0x4(%esp)
80108325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108328:	89 04 24             	mov    %eax,(%esp)
8010832b:	e8 e1 d1 ff ff       	call   80105511 <memmove>
}
80108330:	c9                   	leave  
80108331:	c3                   	ret    

80108332 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108332:	55                   	push   %ebp
80108333:	89 e5                	mov    %esp,%ebp
80108335:	53                   	push   %ebx
80108336:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010833c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108341:	85 c0                	test   %eax,%eax
80108343:	74 0c                	je     80108351 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108345:	c7 04 24 84 8e 10 80 	movl   $0x80108e84,(%esp)
8010834c:	e8 f5 81 ff ff       	call   80100546 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108351:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108358:	e9 ad 00 00 00       	jmp    8010840a <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010835d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108360:	8b 55 0c             	mov    0xc(%ebp),%edx
80108363:	01 d0                	add    %edx,%eax
80108365:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010836c:	00 
8010836d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108371:	8b 45 08             	mov    0x8(%ebp),%eax
80108374:	89 04 24             	mov    %eax,(%esp)
80108377:	e8 9b fb ff ff       	call   80107f17 <walkpgdir>
8010837c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010837f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108383:	75 0c                	jne    80108391 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108385:	c7 04 24 a7 8e 10 80 	movl   $0x80108ea7,(%esp)
8010838c:	e8 b5 81 ff ff       	call   80100546 <panic>
    pa = PTE_ADDR(*pte);
80108391:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108394:	8b 00                	mov    (%eax),%eax
80108396:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010839b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010839e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a1:	8b 55 18             	mov    0x18(%ebp),%edx
801083a4:	89 d1                	mov    %edx,%ecx
801083a6:	29 c1                	sub    %eax,%ecx
801083a8:	89 c8                	mov    %ecx,%eax
801083aa:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801083af:	77 11                	ja     801083c2 <loaduvm+0x90>
      n = sz - i;
801083b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b4:	8b 55 18             	mov    0x18(%ebp),%edx
801083b7:	89 d1                	mov    %edx,%ecx
801083b9:	29 c1                	sub    %eax,%ecx
801083bb:	89 c8                	mov    %ecx,%eax
801083bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083c0:	eb 07                	jmp    801083c9 <loaduvm+0x97>
    else
      n = PGSIZE;
801083c2:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801083c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cc:	8b 55 14             	mov    0x14(%ebp),%edx
801083cf:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801083d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083d5:	89 04 24             	mov    %eax,(%esp)
801083d8:	e8 b7 f6 ff ff       	call   80107a94 <p2v>
801083dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
801083e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801083e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801083ec:	8b 45 10             	mov    0x10(%ebp),%eax
801083ef:	89 04 24             	mov    %eax,(%esp)
801083f2:	e8 86 9c ff ff       	call   8010207d <readi>
801083f7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083fa:	74 07                	je     80108403 <loaduvm+0xd1>
      return -1;
801083fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108401:	eb 18                	jmp    8010841b <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108403:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010840a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840d:	3b 45 18             	cmp    0x18(%ebp),%eax
80108410:	0f 82 47 ff ff ff    	jb     8010835d <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108416:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010841b:	83 c4 24             	add    $0x24,%esp
8010841e:	5b                   	pop    %ebx
8010841f:	5d                   	pop    %ebp
80108420:	c3                   	ret    

80108421 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108421:	55                   	push   %ebp
80108422:	89 e5                	mov    %esp,%ebp
80108424:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108427:	8b 45 10             	mov    0x10(%ebp),%eax
8010842a:	85 c0                	test   %eax,%eax
8010842c:	79 0a                	jns    80108438 <allocuvm+0x17>
    return 0;
8010842e:	b8 00 00 00 00       	mov    $0x0,%eax
80108433:	e9 c1 00 00 00       	jmp    801084f9 <allocuvm+0xd8>
  if(newsz < oldsz)
80108438:	8b 45 10             	mov    0x10(%ebp),%eax
8010843b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010843e:	73 08                	jae    80108448 <allocuvm+0x27>
    return oldsz;
80108440:	8b 45 0c             	mov    0xc(%ebp),%eax
80108443:	e9 b1 00 00 00       	jmp    801084f9 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108448:	8b 45 0c             	mov    0xc(%ebp),%eax
8010844b:	05 ff 0f 00 00       	add    $0xfff,%eax
80108450:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108455:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108458:	e9 8d 00 00 00       	jmp    801084ea <allocuvm+0xc9>
    mem = kalloc();
8010845d:	e8 c5 a9 ff ff       	call   80102e27 <kalloc>
80108462:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108465:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108469:	75 2c                	jne    80108497 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
8010846b:	c7 04 24 c5 8e 10 80 	movl   $0x80108ec5,(%esp)
80108472:	e8 33 7f ff ff       	call   801003aa <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108477:	8b 45 0c             	mov    0xc(%ebp),%eax
8010847a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010847e:	8b 45 10             	mov    0x10(%ebp),%eax
80108481:	89 44 24 04          	mov    %eax,0x4(%esp)
80108485:	8b 45 08             	mov    0x8(%ebp),%eax
80108488:	89 04 24             	mov    %eax,(%esp)
8010848b:	e8 6b 00 00 00       	call   801084fb <deallocuvm>
      return 0;
80108490:	b8 00 00 00 00       	mov    $0x0,%eax
80108495:	eb 62                	jmp    801084f9 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108497:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010849e:	00 
8010849f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801084a6:	00 
801084a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084aa:	89 04 24             	mov    %eax,(%esp)
801084ad:	e8 8c cf ff ff       	call   8010543e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801084b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b5:	89 04 24             	mov    %eax,(%esp)
801084b8:	e8 ca f5 ff ff       	call   80107a87 <v2p>
801084bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084c0:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801084c7:	00 
801084c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
801084cc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084d3:	00 
801084d4:	89 54 24 04          	mov    %edx,0x4(%esp)
801084d8:	8b 45 08             	mov    0x8(%ebp),%eax
801084db:	89 04 24             	mov    %eax,(%esp)
801084de:	e8 d6 fa ff ff       	call   80107fb9 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801084e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ed:	3b 45 10             	cmp    0x10(%ebp),%eax
801084f0:	0f 82 67 ff ff ff    	jb     8010845d <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801084f6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084f9:	c9                   	leave  
801084fa:	c3                   	ret    

801084fb <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084fb:	55                   	push   %ebp
801084fc:	89 e5                	mov    %esp,%ebp
801084fe:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108501:	8b 45 10             	mov    0x10(%ebp),%eax
80108504:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108507:	72 08                	jb     80108511 <deallocuvm+0x16>
    return oldsz;
80108509:	8b 45 0c             	mov    0xc(%ebp),%eax
8010850c:	e9 a4 00 00 00       	jmp    801085b5 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108511:	8b 45 10             	mov    0x10(%ebp),%eax
80108514:	05 ff 0f 00 00       	add    $0xfff,%eax
80108519:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010851e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108521:	e9 80 00 00 00       	jmp    801085a6 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108529:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108530:	00 
80108531:	89 44 24 04          	mov    %eax,0x4(%esp)
80108535:	8b 45 08             	mov    0x8(%ebp),%eax
80108538:	89 04 24             	mov    %eax,(%esp)
8010853b:	e8 d7 f9 ff ff       	call   80107f17 <walkpgdir>
80108540:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108543:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108547:	75 09                	jne    80108552 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108549:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108550:	eb 4d                	jmp    8010859f <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108555:	8b 00                	mov    (%eax),%eax
80108557:	83 e0 01             	and    $0x1,%eax
8010855a:	85 c0                	test   %eax,%eax
8010855c:	74 41                	je     8010859f <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
8010855e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108561:	8b 00                	mov    (%eax),%eax
80108563:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108568:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010856b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010856f:	75 0c                	jne    8010857d <deallocuvm+0x82>
        panic("kfree");
80108571:	c7 04 24 dd 8e 10 80 	movl   $0x80108edd,(%esp)
80108578:	e8 c9 7f ff ff       	call   80100546 <panic>
      char *v = p2v(pa);
8010857d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108580:	89 04 24             	mov    %eax,(%esp)
80108583:	e8 0c f5 ff ff       	call   80107a94 <p2v>
80108588:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010858b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010858e:	89 04 24             	mov    %eax,(%esp)
80108591:	e8 f8 a7 ff ff       	call   80102d8e <kfree>
      *pte = 0;
80108596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108599:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010859f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085ac:	0f 82 74 ff ff ff    	jb     80108526 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801085b2:	8b 45 10             	mov    0x10(%ebp),%eax
}
801085b5:	c9                   	leave  
801085b6:	c3                   	ret    

801085b7 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801085b7:	55                   	push   %ebp
801085b8:	89 e5                	mov    %esp,%ebp
801085ba:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801085bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801085c1:	75 0c                	jne    801085cf <freevm+0x18>
    panic("freevm: no pgdir");
801085c3:	c7 04 24 e3 8e 10 80 	movl   $0x80108ee3,(%esp)
801085ca:	e8 77 7f ff ff       	call   80100546 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801085cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085d6:	00 
801085d7:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801085de:	80 
801085df:	8b 45 08             	mov    0x8(%ebp),%eax
801085e2:	89 04 24             	mov    %eax,(%esp)
801085e5:	e8 11 ff ff ff       	call   801084fb <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801085ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085f1:	eb 48                	jmp    8010863b <freevm+0x84>
    if(pgdir[i] & PTE_P){
801085f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108600:	01 d0                	add    %edx,%eax
80108602:	8b 00                	mov    (%eax),%eax
80108604:	83 e0 01             	and    $0x1,%eax
80108607:	85 c0                	test   %eax,%eax
80108609:	74 2c                	je     80108637 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010860b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108615:	8b 45 08             	mov    0x8(%ebp),%eax
80108618:	01 d0                	add    %edx,%eax
8010861a:	8b 00                	mov    (%eax),%eax
8010861c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108621:	89 04 24             	mov    %eax,(%esp)
80108624:	e8 6b f4 ff ff       	call   80107a94 <p2v>
80108629:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010862c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010862f:	89 04 24             	mov    %eax,(%esp)
80108632:	e8 57 a7 ff ff       	call   80102d8e <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108637:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010863b:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108642:	76 af                	jbe    801085f3 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108644:	8b 45 08             	mov    0x8(%ebp),%eax
80108647:	89 04 24             	mov    %eax,(%esp)
8010864a:	e8 3f a7 ff ff       	call   80102d8e <kfree>
}
8010864f:	c9                   	leave  
80108650:	c3                   	ret    

80108651 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108651:	55                   	push   %ebp
80108652:	89 e5                	mov    %esp,%ebp
80108654:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108657:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010865e:	00 
8010865f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108662:	89 44 24 04          	mov    %eax,0x4(%esp)
80108666:	8b 45 08             	mov    0x8(%ebp),%eax
80108669:	89 04 24             	mov    %eax,(%esp)
8010866c:	e8 a6 f8 ff ff       	call   80107f17 <walkpgdir>
80108671:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108674:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108678:	75 0c                	jne    80108686 <clearpteu+0x35>
    panic("clearpteu");
8010867a:	c7 04 24 f4 8e 10 80 	movl   $0x80108ef4,(%esp)
80108681:	e8 c0 7e ff ff       	call   80100546 <panic>
  *pte &= ~PTE_U;
80108686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108689:	8b 00                	mov    (%eax),%eax
8010868b:	89 c2                	mov    %eax,%edx
8010868d:	83 e2 fb             	and    $0xfffffffb,%edx
80108690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108693:	89 10                	mov    %edx,(%eax)
}
80108695:	c9                   	leave  
80108696:	c3                   	ret    

80108697 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108697:	55                   	push   %ebp
80108698:	89 e5                	mov    %esp,%ebp
8010869a:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
8010869d:	e8 ad f9 ff ff       	call   8010804f <setupkvm>
801086a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801086a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086a9:	75 0a                	jne    801086b5 <copyuvm+0x1e>
    return 0;
801086ab:	b8 00 00 00 00       	mov    $0x0,%eax
801086b0:	e9 f1 00 00 00       	jmp    801087a6 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
801086b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086bc:	e9 c0 00 00 00       	jmp    80108781 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801086c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086cb:	00 
801086cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801086d0:	8b 45 08             	mov    0x8(%ebp),%eax
801086d3:	89 04 24             	mov    %eax,(%esp)
801086d6:	e8 3c f8 ff ff       	call   80107f17 <walkpgdir>
801086db:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086de:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086e2:	75 0c                	jne    801086f0 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801086e4:	c7 04 24 fe 8e 10 80 	movl   $0x80108efe,(%esp)
801086eb:	e8 56 7e ff ff       	call   80100546 <panic>
    if(!(*pte & PTE_P))
801086f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f3:	8b 00                	mov    (%eax),%eax
801086f5:	83 e0 01             	and    $0x1,%eax
801086f8:	85 c0                	test   %eax,%eax
801086fa:	75 0c                	jne    80108708 <copyuvm+0x71>
      panic("copyuvm: page not present");
801086fc:	c7 04 24 18 8f 10 80 	movl   $0x80108f18,(%esp)
80108703:	e8 3e 7e ff ff       	call   80100546 <panic>
    pa = PTE_ADDR(*pte);
80108708:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010870b:	8b 00                	mov    (%eax),%eax
8010870d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108712:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
80108715:	e8 0d a7 ff ff       	call   80102e27 <kalloc>
8010871a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010871d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108721:	74 6f                	je     80108792 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108723:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108726:	89 04 24             	mov    %eax,(%esp)
80108729:	e8 66 f3 ff ff       	call   80107a94 <p2v>
8010872e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108735:	00 
80108736:	89 44 24 04          	mov    %eax,0x4(%esp)
8010873a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010873d:	89 04 24             	mov    %eax,(%esp)
80108740:	e8 cc cd ff ff       	call   80105511 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108745:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108748:	89 04 24             	mov    %eax,(%esp)
8010874b:	e8 37 f3 ff ff       	call   80107a87 <v2p>
80108750:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108753:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010875a:	00 
8010875b:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010875f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108766:	00 
80108767:	89 54 24 04          	mov    %edx,0x4(%esp)
8010876b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010876e:	89 04 24             	mov    %eax,(%esp)
80108771:	e8 43 f8 ff ff       	call   80107fb9 <mappages>
80108776:	85 c0                	test   %eax,%eax
80108778:	78 1b                	js     80108795 <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010877a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108784:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108787:	0f 82 34 ff ff ff    	jb     801086c1 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
8010878d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108790:	eb 14                	jmp    801087a6 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108792:	90                   	nop
80108793:	eb 01                	jmp    80108796 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
80108795:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108796:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108799:	89 04 24             	mov    %eax,(%esp)
8010879c:	e8 16 fe ff ff       	call   801085b7 <freevm>
  return 0;
801087a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087a6:	c9                   	leave  
801087a7:	c3                   	ret    

801087a8 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801087a8:	55                   	push   %ebp
801087a9:	89 e5                	mov    %esp,%ebp
801087ab:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087b5:	00 
801087b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801087b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801087bd:	8b 45 08             	mov    0x8(%ebp),%eax
801087c0:	89 04 24             	mov    %eax,(%esp)
801087c3:	e8 4f f7 ff ff       	call   80107f17 <walkpgdir>
801087c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801087cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ce:	8b 00                	mov    (%eax),%eax
801087d0:	83 e0 01             	and    $0x1,%eax
801087d3:	85 c0                	test   %eax,%eax
801087d5:	75 07                	jne    801087de <uva2ka+0x36>
    return 0;
801087d7:	b8 00 00 00 00       	mov    $0x0,%eax
801087dc:	eb 25                	jmp    80108803 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801087de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e1:	8b 00                	mov    (%eax),%eax
801087e3:	83 e0 04             	and    $0x4,%eax
801087e6:	85 c0                	test   %eax,%eax
801087e8:	75 07                	jne    801087f1 <uva2ka+0x49>
    return 0;
801087ea:	b8 00 00 00 00       	mov    $0x0,%eax
801087ef:	eb 12                	jmp    80108803 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801087f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f4:	8b 00                	mov    (%eax),%eax
801087f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087fb:	89 04 24             	mov    %eax,(%esp)
801087fe:	e8 91 f2 ff ff       	call   80107a94 <p2v>
}
80108803:	c9                   	leave  
80108804:	c3                   	ret    

80108805 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108805:	55                   	push   %ebp
80108806:	89 e5                	mov    %esp,%ebp
80108808:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010880b:	8b 45 10             	mov    0x10(%ebp),%eax
8010880e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108811:	e9 89 00 00 00       	jmp    8010889f <copyout+0x9a>
    va0 = (uint)PGROUNDDOWN(va);
80108816:	8b 45 0c             	mov    0xc(%ebp),%eax
80108819:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010881e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108821:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108824:	89 44 24 04          	mov    %eax,0x4(%esp)
80108828:	8b 45 08             	mov    0x8(%ebp),%eax
8010882b:	89 04 24             	mov    %eax,(%esp)
8010882e:	e8 75 ff ff ff       	call   801087a8 <uva2ka>
80108833:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108836:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010883a:	75 07                	jne    80108843 <copyout+0x3e>
      return -1;
8010883c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108841:	eb 6b                	jmp    801088ae <copyout+0xa9>
    n = PGSIZE - (va - va0);
80108843:	8b 45 0c             	mov    0xc(%ebp),%eax
80108846:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108849:	89 d1                	mov    %edx,%ecx
8010884b:	29 c1                	sub    %eax,%ecx
8010884d:	89 c8                	mov    %ecx,%eax
8010884f:	05 00 10 00 00       	add    $0x1000,%eax
80108854:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010885a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010885d:	76 06                	jbe    80108865 <copyout+0x60>
      n = len;
8010885f:	8b 45 14             	mov    0x14(%ebp),%eax
80108862:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108865:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108868:	8b 55 0c             	mov    0xc(%ebp),%edx
8010886b:	29 c2                	sub    %eax,%edx
8010886d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108870:	01 c2                	add    %eax,%edx
80108872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108875:	89 44 24 08          	mov    %eax,0x8(%esp)
80108879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108880:	89 14 24             	mov    %edx,(%esp)
80108883:	e8 89 cc ff ff       	call   80105511 <memmove>
    len -= n;
80108888:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010888b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010888e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108891:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108894:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108897:	05 00 10 00 00       	add    $0x1000,%eax
8010889c:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010889f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801088a3:	0f 85 6d ff ff ff    	jne    80108816 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801088a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088ae:	c9                   	leave  
801088af:	c3                   	ret    
