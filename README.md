GCUndoManager
=============

## A better Undo manager

Cocoa's built-in Undo is a great component of the framework. Those of us
who have written apps on the Mac under the classic toolbox might recall
just how difficult writing a really good Undo system was, back in the
bad old days. Having the framework take care of the overall management
of Undo with a simple way to register actions with it is a genuinely
pleasant surprise and advantage to Cocoa.

Unfortunately, while for most people NSUndoManager will be more than
adequate, in some kinds of applications it can be somewhat awkward to
use, and when things get complicated or misbehave, the inability to "get
inside" the undo manager black-box to assist with debugging is
problematic. Most Cocoa programmers will run into the dreaded 'Undo
Manager is in an invalid state' messages logged to the console sooner or
later, which, while indicative of a programming error in client code,
can make the entire app cease to remain undoable, as recovering from
such problems appears to be difficult. In addition, NSUndoManager has
some, shall we say, quirks, which make its use in some situations harder
than it might be. When you consider that a well-written app should
implement undo pervasively, it's important that Undo is robust and
reliable, as every part of the app will be affected by it.

The alternative undo manager presented here addresses a number of
concerns with NSUndoManager, while remaining extremely compatible with
it for most normal application use.

## Multiple event handling

One situation where NSUndoManager can be awkward is when dealing with
undoing changes that are the result of a stream of events, rather than
fully handled within a single event. This commonly arises when dragging
is used as means of editing the data model. Dragging breaks down into a
mouse down event, a series of drag events (including the possibility of
no event occurring), and a final mouse up event. On the face of it
NSUndoManager is equipped to deal with this - just open a group at the
start, accumulate changes, then close the group at the end. While that
does work, it has two problems. The first is that the case where no drag
event is sent is not detected, and NSUndoManager still goes ahead and
adds a new, empty Undo action to the stack, resulting in an Undo menu
item that does nothing when chosen. Users tend to consider the 'does
nothing' Undo item a bug, and quite rightly. Unfortunately they'll blame
your app, not Apple's framework, but in any case, proper behaviour is
what we want, not shifting of blame. The second problem is that even
when drag events are sent, all changes arising from each event are
faithfully recorded. That means that when Undoing, you're effectively
'replaying' all of the drag events one by one. In most cases this replay
occurs very quickly and is hardly noticeable, but it represents a waste
of time and memory, since in the vast majority of cases, you'll want to
Undo the entire drag, so only the state at the start of the drag is of
any interest. While the responsibility for this could rest with the
application, depending on its design, putting the responsibility for
handling that into the Undo manager can greatly simplify things, because
it is already aware of how tasks are being grouped, and can readily
coalesce a series of individual actions within a group as needed.
GCUndoManager supports task coalescing if required.

In addition, NSUndoManager strictly requires that groups are carefully
balanced, and the responsibility to ensure this is with the client code.
If an imbalance arises, NSUndoManager effectively shuts down and ceases
to record or replay Undo events. Given the need to take such care,
workarounds for the empty Undo bug become needlessly complicated and
ugly. The problem is made harder by the automatic grouping by event that
NSUndoManager does, which must also be taken into account. A further
problem where invoking -endUndoGrouping appears not to actually close
the group under some circumstances, but leaves the groupingLevel at 1
was the final motivation for this class, because it was impossible to
examine the internal state of NSUndoManager in the debugger to find out
just what the problem was. GCUndoManager still expects you to make a
reasonable effort to maintain correct group nesting - for every open
there should be a close, but is much less precious about it. For
example, you can "over close" a group harmlessly - attempts to close an
already closed top-level group are merely ignored, instead of leading to
an unrecoverable internal state. The general state is also easily reset
if things get hopelessly out-of-kilter, so it makes it easy for your app
to recover from Undo related bugs. It's surely better to 'limit the
damage' of a programming error in one part of your app and have the rest
remain working, rather than have Undo fail across the board.
GCUndoManager has no secrets - it's a straightforward implementation
with no private API and as debuggable as any other part of your app.
When Undo gets complicated, the ability to see exactly what is stored
and to directly examine its state can be a real benefit for debugging
your app.

GCUndoManager is compatible with the public API of NSUndoManager, but it
is not a subclass of NSUndoManager (it inherits from NSObject). It can
be used with document and non-document based applications in exactly the
same way as NSUndoManager, and as far as possible it conforms to the
current documentation for NSUndoManager. Where there are differences
from the documentation, the source operates to follow NSUndoManager by
example. For instance, when used with NSDocument, the document
subscribes to notifications from the Undo manager to maintain its
'dirty' status correctly. GCUndoManager sends the same notifications in
the same places as NSUndoManager (which slightly differs from
documentation) so that the dirty state is correctly maintained. No
modifications to NSDocument are required.

## Using the class

The project presented here includes the undo manager and a minimal
application that tests and demonstrates its use. The undo manager is
instantiated as part of the document subclass's -init method, and passed
to its `-setUndoManager:` method, suitably cast. The test application
allows you to switch between NSUndoManager and GCUndoManager to compare
differences. The data model is a very simple one consisting of a single
draggable rectangle with three properties - location, size and colour.
All are undoable. For simplicity the 'data model' is implemented
directly by the view, and this should not be taken as a good example of
MVC design. A direct comparison of the two undo managers with respect to
the empty Undo item bug can be made - merely clicking but not dragging
the object will trigger the bug with NSUndoManager but not with
GCUndoManager.

## Task Coalescing

GCUndoManager supports task coalescing, where a series of identical
tasks within a group are collapsed to a single task. This can be
disabled and is not enabled by default. There are two coalescing
approaches available, set using -setCoalescingKind: The first
`kGCCoalesceLastTask` is just to discard tasks based on the most recent
one accepted. This is good for property changes consisting only of a
single property, for example an object's location, that is repeatedly
changed by a drag. Thus task sequences are coalesced as follows:

-   AAAAAA \> A
-   ABBBBB \> AB
-   ABBBBA \> ABA

However, where property changes do not consist of a single property
change per drag event, but have several parts, the simple coalescing
behaviour will not be able to help, as:

-   ABABABAB \> ABABABAB

For this kind of sequence, the second coalescing kind
`kGCCoalesceAllMatchingTasks` could be used. This coalesces tasks based on
the presence of any match within the group, not just the last one. This
results in the following behaviour:

-   ABABABAB \> AB
-   ABCABCABC \> ABC
-   but ABBBBBA \> AB

The last example shows that this mode is not as general purpose as the
first. Applications can set the coalescing mode as they wish depending
on how property changes are made during a repeated sequence. Or they can
leave it in the first mode and incur some inefficiency for the second
example cases. Note that coalescing is always performed with respect to
the current open group, so can be 'restarted' by opening a subgroup.

## Implementation details

Unlike NSUndoManager, GCUndoManager is not a 'black box'. Internally, it
represents the recorded actions using two kinds of object, GCUndoGroup
and GCConcreteUndoTask. Both are subclasses of the semi-abstract
GCUndoTask class. GCConcreteUndoTask further stores the actual data
change as an NSInvocation which it retains. In turn the invocation
retains its arguments and target, because GCUndoManager calls its 
`-retainArguments` method. Groups can be nested to any depth as
with NSUndoManager. There are no special marker or sentinel objects used
to de-mark the start and end of groups, everything is stored and managed
as a straightforward tree. The Undo and Redo stacks themselves are
NSMutableArray instances, and a group stores its contents also using a
NSMutableArray. Like the NSUndoManager in 10.6, GCUndoManager uses a
proxy object based on NSProxy that is returned by
`-prepareWithInvocationTarget:`. The proxy prevents the situation where a
property defined by the undo manager itself can't be recorded because
the undo manager will not forward methods it already responds to. While
the use of the proxy can be conditionally compiled out, it is
recommended and will work on any version of Mac OS. No API is private
and internal operations are well factored to permit overriding anywhere
that makes sense. You can peek at the current undo and redo tasks, get
the stacks themselves, pop the tasks with and without invoking them, and
many other things. Also for assistance with debugging complex undo
groups consisting of a series of individual tasks, -explodeTopUndoAction
will 'unpack' the current top-level group on the Undo stack into
separate tasks which can be individually undone.

When a top level group is opened, it is immediately pushed onto the
relevant stack. The data member 'mOpenGroupRef' tracks the currently
open group, which might be nested within another if it is not a
top-level group. All task recording is done with reference to this
group. If the top-level group is empty when the top-level is closed, the
empty group is popped and discarded, which addresses the empty group
bug. Note that this automatic removal can be disabled - for applications
that do not submit tasks to the undo manager but merely subscribe to
notifications and manage their own undo stacks, disabling this would be
appropriate. However, in that case replacing NSUndoManager may not be
worthwhile. It is because GCUndoManager adds a top-level group to the
stack when the group is opened rather than when it is closed that it is
able to be far less finicky about strict balance, and makes recovery
from an imbalance much easier.

## Update, 1/1/2009

Updated GCUndoManager has now been tested with Core Data and has been
found to work correctly, after some minor tweaks. This version changes
its memory management policy for retaining of tasks' targets: as per
NSUndoManager and general rules, GCUndoManager no longer retains its
targets by default. The undo manager should not hold stale targets,
because `-removeAllActionsWithTarget:` is required to be called whenever
any such targets are deallocated. However, for some designs retaining
targets may simplify the use of the undo manager quite considerably, so
you can now opt-in to this behaviour using `-setRetainsTargets:` passing an
argument of YES. When targets are retained, clearing the task stacks
must avoid re-entrancy, and GCUndoManager now includes a simple lock to
ensure that.

## Update, 20/7/2011

Updated to include the new notification used by NSDocument in Lion
(10.7). The source is now hosted on Github, so any further changes will
be made to the repository there.
