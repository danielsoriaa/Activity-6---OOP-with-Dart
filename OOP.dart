import 'dart:io';

class Library with searchIndex, mainMenuProcesses {
  var allBooks, lentBooks, bookList = [], userList = [];
  List genres = [
    "Computer Science",
    "Philosophy",
    "Pure Science",
    "Art and Recreation",
    "History"
  ];

  Library() {
    allBooks = 0;
    lentBooks = 0;
  }

  int numOfBooks() {
    return allBooks;
  }

  int numOfLent() {
    return lentBooks;
  }

  //adding book collection
  void addBook(String title, String author, String genre, String ISBN) {
    var book = new Books(title, author, genre, ISBN);
    bookList.add(book);
    allBooks++;
  }

  //lending book
  void lendBook(int userIndex) {
    for (var doAddBook = '1'; doAddBook != '2';) {
      stdout.write("\n(1)Add book ISBN\n(2)Finish adding\nType choice:");
      doAddBook = stdin.readLineSync()!;

      if (doAddBook == '1') {
        for (int bookIndex = -1; bookIndex == -1;) {
          stdout.write("\nEnter book ISBN: ");
          String ISBNbyUser = stdin.readLineSync()!;
          bookIndex = findBookIndex(bookList, ISBNbyUser);

          //function findBookIndex returns -1 if ISBN does not match any record in the library's books collection
          if (bookIndex == -1)
            print("Book not found. Please enter ISBN again.");
          else if (bookList[bookIndex].status == 0)
            print("Book is currently borrowed by someone else.");
          else {
            //book is added to the user's borrowed books list
            //book's status in the library is changed to unavailable
            //library's count of lent books increments
            userList[userIndex].borrowedBooks.add(bookList[bookIndex]);
            bookList[bookIndex].status = 0;
            lentBooks++;
          }
        }
      } else if (doAddBook == '2')
        print("\nBooks added to borrow list.\n");
      else
        print("Invalid choice. Please try again.");
    }
  }

  //library accepts returned books from user
  //all books in user's borrow list will be returned
  void acceptReturn(int userIndex) {
    print("\nReturned books: ");
    if (userList[userIndex].borrowedBooks.length != 0) {
      for (int i = 0; i < userList[userIndex].borrowedBooks.length;) {
        int bookIndex =
            findBookIndex(bookList, userList[userIndex].borrowedBooks[i].ISBN);
        userList[userIndex].borrowedBooks.removeAt(0);
        bookList[bookIndex].status = 1;
        lentBooks--;
        print(
            "\t${bookList[bookIndex].title} by ${bookList[bookIndex].author}");
      }
    } else
      print("\nNo borrowed books in your record.");
  }

  //adding new user
  void newUser(String fullName, String address) {
    var user = new User(fullName, address);
    userList.add(user);
  }
}

//class for attributes
class Books {
  late String title;
  late String author;
  late String genre;
  late String ISBN;
  late int status; //0=borrowed, 1=available
  var booksBorrowed = [];

  //constructor to set values of attributes for every book instance
  Books(title, author, genre, ISBN) {
    this.title = title;
    this.author = author;
    this.genre = genre;
    this.ISBN = ISBN;
    status =
        1; //status is immediately given value of 1 since it is available once added to collection
  }
}

//class for attributes
class User {
  late String fullName;
  late String address;
  var borrowedBooks = [];
  User(String fullName, String address) {
    this.fullName = fullName;
    this.address = address;
  }
}

//mixin for index searching algorithms for books and users
mixin searchIndex {
  //method for finding certain book's index in library's users list
  //book is searched based on matching ISBN
  int findBookIndex(var listOfBooks, String ISBN) {
    for (int i = 0; i < listOfBooks.length; i++) {
      if (listOfBooks[i].ISBN == ISBN) return i;
    }
    return -1;
  }

  //method for finding certain user's index in library's users list
  //user is searched based on matching full name and address
  int findUserIndex(var listOfUsers, String fullName, String address) {
    for (int i = 0; i < listOfUsers.length; i++) {
      if (listOfUsers[i].fullName == fullName &&
          listOfUsers[i].address == address) return i;
    }
    return -1;
  }
}

//mixin for processing of library's main menu
//chose to use mixin than defining these methods in the Library class for readability
mixin mainMenuProcesses {
  //method for browse books menu
  void mainBrowseBooks(var testLib) {
    print("\n\n--BROWSE BOOKS--\n");
    //loop does not end until user inputs correct option
    for (;;) {
      stdout.write("(1)View all\n(2)View by genre\nType option: ");
      var viewBooks = stdin.readLineSync();

      //view all books regardless of genre
      if (viewBooks == '1') {
        print("\nAll Books\n");
        for (int i = 0; i < testLib.bookList.length; i++) {
          if (testLib.bookList[i].status == 1) {
            print("Title: ${testLib.bookList[i].title}");
            print("Author: ${testLib.bookList[i].author}");
            print("Genre: ${testLib.bookList[i].genre}");
            print("ISBN: ${testLib.bookList[i].ISBN}\n");
          }
        }
        break;
      }

      //view books based on a certain genre
      else if (viewBooks == '2') {
        stdout.write(
            "\nGenres available:\n(1)Computer Science\n(2)Philosophy\n(3)Pure Science\n(4)Art and Recreation\n(5)History\nType option: ");
        int? viewGenres = int.tryParse(stdin.readLineSync()!);

        if (viewGenres != null && (viewGenres > 0 || viewGenres < 6)) {
          print("\n${testLib.genres[viewGenres - 1]} Books:\n");
          int c = 0;

          //finding and printing books under the genre selected by user
          for (int i = 0; i < testLib.bookList.length; i++) {
            if (testLib.genres[viewGenres - 1] == testLib.bookList[i].genre &&
                testLib.bookList[i].status == 1) {
              print("Title: ${testLib.bookList[i].title}");
              print("Author: ${testLib.bookList[i].author}");
              print("Genre: ${testLib.bookList[i].genre}");
              print("ISBN: ${testLib.bookList[i].ISBN}\n");
              c++; //counter to track number of books in a certain genre
            }
          }
          if (c == 0) print("Genre Unavailable.\n");
          break;
        } else
          print("Invalid choice. Please try again.\n");
      } else
        print("Invalid choice. Please try again.\n");
    }
    print("Redirecting to main menu...\n");
    print("**************************************************************\n");
  }

  //method for borrow books menu
  void mainBorrowBooks(testLib) {
    print("\n\n--BORROW BOOK/S--");
    //loop does not end until user inputs correct option
    for (;;) {
      stdout.write(
          "\n(1)New User\n(2)Old User\nType option: "); //1 for new user, 2 for old user
      var userStat = stdin.readLineSync();
      late int userIndex;

      if (userStat != '1' && userStat != '2')
        print("Invalid choice. Please try again.\n");
      else {
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName = stdin.readLineSync()!;
        stdout.write("Address: ");
        String address = stdin.readLineSync()!;

        //adding new user and taking index of last element in user list
        if (userStat == '1') {
          testLib.newUser(fullName, address);
          userIndex = testLib.userList.length - 1;
          testLib.lendBook(userIndex);
          break;
        }
        //finding existing user and saving the index in userIndex
        else if (userStat == '2') {
          userIndex =
              testLib.findUserIndex(testLib.userList, fullName, address);
          if (userIndex == -1)
            print(
                "Invalid selection. You are not an existing user. Select New User instead.");
          else {
            testLib.lendBook(userIndex);
            break;
          }
        }
      }
    }
    print("Redirecting to main menu...\n");
    print("**************************************************************\n");
  }

  //method for returning of books menu
  void mainReturnBooks(var testLib) {
    print("\n\n--RETURN BOOK/S--");

    //loop does not end until user inputs correct option
    for (;;) {
      stdout.write(
          "\n(1)New User\n(2)Old User\nType option: "); //1 for new user, 2 for old user
      var userStat = stdin.readLineSync();

      if (userStat != '1' && userStat != '2')
        print("Invalid choice. Please try again.");
      else {
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName = stdin.readLineSync()!;
        stdout.write("Address: ");
        String address = stdin.readLineSync()!;

        //adding new user to library's list of users
        if (userStat == '1') {
          testLib.newUser(fullName, address);
          print("\nNo books in your cart.\n");
          break;
        }
        //finding user in library's user list and storing the user's index in userIndex
        else if (userStat == '2') {
          int userIndex =
              testLib.findUserIndex(testLib.userList, fullName, address);

          //findUserIndex returns -1 if user is not found
          if (userIndex != -1) {
            testLib.acceptReturn(userIndex);
            break;
          } else
            print("We cannot find your credentials.");
        }
      }
    }
    print("\nRedirecting to main menu...\n");
    print("**************************************************************\n");
  }

  //method for view cart menu
  void mainViewCart(testLib) {
    print("\n\n--VIEW BOOKS IN CART--");

    //loop does not end until user inputs the correct choice
    for (;;) {
      stdout.write(
          "\n(1)New User\n(2)Old User\nType option: "); //1 for new user, 2 for old user
      var userStat = stdin.readLineSync()!;

      if (userStat != '1' && userStat != '2')
        print("Invalid choice. Please try again.");
      else {
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName = stdin.readLineSync()!;
        stdout.write("Address: ");
        String address = stdin.readLineSync()!;

        //adding new user
        if (userStat == '1') {
          testLib.newUser(fullName, address);
          print("\nNo books in your cart.\n");
          break;
        }
        //finding existing user in the library's list of users
        else if (userStat == '2') {
          int userIndex =
              testLib.findUserIndex(testLib.userList, fullName, address);
          if (userIndex != -1) {
            print("\nBook/s in your cart: ");

            //printing all books in borrow list of user
            for (int i = 0;
                i < testLib.userList[userIndex].borrowedBooks.length;
                i++) {
              print(
                  "\t${testLib.userList[userIndex].borrowedBooks[i].title} by ${testLib.userList[userIndex].borrowedBooks[i].author}");
            }
            break;
          } else
            print(
                "Are you sure you are an old user? We cannot find your name or address. Please try again.");
        }
      }
    }
    print("Redirecting to main menu...\n");
    print("**************************************************************\n");
  }
}

//method to test if system keeps track of books count properly
//only call this when you need to test the system
void systemTest(var testLib) {
  print("---------------------------------------------------------------");
  print("This is a test.");
  print("Number of lent books: ${testLib.numOfLent()}");
  print("Number of books in collection: ${testLib.numOfBooks()}");
  print("---------------------------------------------------------------\n");
}

//method to add mock information to the library
void testAdd(var testLib) {
  testLib.addBook(
      "Hello Dolly", "Amore May", "Philosophy", "978-1-60309-047-6");
  testLib.addBook("At The End of The Universe", "Felix Yongbok", "Pure Science",
      "978-1-891830-85-3");
  testLib.addBook(
      "Are You Alone?", "Annabelle Conjure", "Philosophy", "978-1-60309-016-2");
  testLib.addBook("The Art of Symmetry", "SQ Kim", "Art and Recreation",
      "978-1-60309-265-4");
  testLib.addBook("Introduction to C", "Kevin Steinfield", "Computer Science",
      "978-1-65309-067-1");
  testLib.addBook("The Beginning of Mankind", "Linda Struss", "History",
      "978-1-876830-35-3");
  testLib.addBook("Is The Truth True?", "Sicily Walker", "Philosophy",
      "978-1-51260309-316-2");
  testLib.addBook(
      "Rainbows and Rain", "Milli Smith", "Pure Science", "978-1-40315-645-3");
  testLib.addBook("Curvy Nature", "Pablo Vivaldi", "Art and Recreation",
      "978-1-51339-967-5");
  testLib.addBook("Dart for Dummies", "Hyunjin Fryer", "Computer Science",
      "978-1-12830-05-3");
  testLib.addBook("The French War", "Von Bach", "History", "979-3-41309-096-2");
  testLib.addBook(
      "Road to Happiness", "Happy Baltazar", "Philosophy", "978-1-88809-203-4");
  testLib.addBook("Tardigrades: The Immortals of the Microcosmos", "Paulo Nase",
      "Pure Science", "978-7-61209-817-6");
  testLib.addBook("When To Stop Chasing Your Dreams", "Albert Schmidt",
      "Philosophy", "978-1-543130-14-3");
  testLib.addBook("Smile", "Annalisa Mayer", "Philosophy", "978-1-91409-516-6");
}

//main function starts here
void main() {
  var testLib = new Library();
  testAdd(testLib); //adding mock information of books and users to the library

  //loop does not end unless user inputs any keys other than 1, 2, 3, and 4
  for (bool doExit = false; !doExit;) {
    print("Welcome to the Library!");
    stdout.write(
        "(1)Browse collection of books\n(2)Borrow book/s\n(3)Return book/s\n(4)View book/s in cart\nPress any other key to exit...\nType option: ");
    var mainOption = stdin.readLineSync();
    switch (mainOption) {
      case '1':
        //browse books
        testLib.mainBrowseBooks(testLib);
        break;
      case '2':
        //borrow books
        testLib.mainBorrowBooks(testLib);
        break;
      case '3':
        //return borrowed books
        testLib.mainReturnBooks(testLib);
        break;
      case '4':
        //view books in cart (cart contains currently borrowed books)
        testLib.mainViewCart(testLib);
        break;
      default:
        doExit = true;
        print("Exiting...");

        //next line can be commented out if you do not want to run the system testing for tracking of number of books
        systemTest(testLib);
    }
  }
}
