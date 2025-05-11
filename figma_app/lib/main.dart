// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(RecipeCatalogApp());
}

class User {
  final String email;
  final String name;
  User({required this.email, required this.name});
}

class Recipe {
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  bool isFavorite;

  Recipe({
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
  });
}

class RecipeCatalogApp extends StatefulWidget {
  @override
  _RecipeCatalogAppState createState() => _RecipeCatalogAppState();
}

class _RecipeCatalogAppState extends State<RecipeCatalogApp> {
  User? _user;
  List<Recipe> _recipes = [
    Recipe(
      title: 'Nasi Goreng',
      imageUrl: 'https://example.com/nasigoreng.jpg',
      ingredients: ['Nasi', 'Telur', 'Bawang', 'Kecap', 'Garam'],
      steps: ['Panaskan minyak', 'Tumis bumbu', 'Masukkan nasi', 'Tambahkan kecap', 'Aduk rata'],
    ),
    Recipe(
      title: 'Pancake',
      imageUrl: 'https://example.com/pancake.jpg',
      ingredients: ['Tepung', 'Telur', 'Susu', 'Gula', 'Baking Powder'],
      steps: ['Campur bahan kering', 'Tambahkan telur & susu', 'Aduk', 'Masak di teflon'],
    ),
  ];

  void _login(String email, String name) {
    setState(() {
      setState(() {
        _user = User(email: email, name: name);
      });
    });
  }

  void _logout() {
    setState(() {
      _user = null;
    });
  }

  void _toggleFavorite(Recipe recipe) {
    setState(() {
      recipe.isFavorite = !recipe.isFavorite;
    });
  }

  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipes.add(recipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katalog Resep',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyText2: TextStyle(fontSize: 16),
        ),
      ),
      home: _user == null
          ? AuthScreen(onLogin: _login)
          : MainScreen(
              user: _user!,
              recipes: _recipes,
              onLogout: _logout,
              onToggleFavorite: _toggleFavorite,
              onAdd: _addRecipe,
            ),
    );
  }
}

// AUTH SCREEN (Login/Register)
class AuthScreen extends StatefulWidget {
  final void Function(String email, String name) onLogin;
  AuthScreen({required this.onLogin});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onLogin(_email, _isLogin ? _email.split('@')[0] : _name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'Login' : 'Register',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 16),
                    if (!_isLogin)
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                        onSaved: (val) => _name = val!.trim(),
                      ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (val) => val!.contains('@') ? null : 'Invalid email',
                      onSaved: (val) => _email = val!.trim(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (val) => val!.length < 6 ? 'Min 6 chars' : null,
                      onSaved: (val) => _password = val!.trim(),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Login' : 'Register'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin ? 'Create account' : 'Have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// MAIN SCREEN WITH BOTTOM NAV
class MainScreen extends StatefulWidget {
  final User user;
  final List<Recipe> recipes;
  final VoidCallback onLogout;
  final void Function(Recipe) onToggleFavorite;
  final void Function(Recipe) onAdd;

  MainScreen({required this.user, required this.recipes, required this.onLogout, required this.onToggleFavorite, required this.onAdd});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  List<Recipe> get _filteredRecipes {
    return widget.recipes
        .where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      RecipeListScreen(
        recipes: _filteredRecipes,
        onToggleFavorite: widget.onToggleFavorite,
        onSearch: (q) => setState(() => _searchQuery = q),
      ),
      FavoriteScreen(
        recipes: widget.recipes.where((r) => r.isFavorite).toList(),
        onToggleFavorite: widget.onToggleFavorite,
      ),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddRecipeScreen(onSubmit: widget.onAdd))),
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

// SCREEN: LIST + SEARCH
class RecipeListScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final ValueChanged<String> onSearch;
  final void Function(Recipe) onToggleFavorite;

  RecipeListScreen({required this.recipes, required this.onToggleFavorite, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari resep...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: onSearch,
            ),
          ),
          Expanded(
            child: recipes.isEmpty
                ? Center(child: Text('Resep tidak ditemukan'))
                : GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (ctx, i) {
                      final recipe = recipes[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipe: recipe, onToggleFavorite: onToggleFavorite))),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(recipe.imageUrl, fit: BoxFit.cover),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(recipe.title, style: TextStyle(fontWeight: FontWeight.bold))),
                                    IconButton(
                                      icon: Icon(recipe.isFavorite ? Icons.favorite : Icons.favorite_border),
                                      onPressed: () => onToggleFavorite(recipe),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// DETAIL SCREEN
class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final void Function(Recipe) onToggleFavorite;
  RecipeDetailScreen({required this.recipe, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: Icon(recipe.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => onToggleFavorite(recipe),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(recipe.imageUrl),
            ),
            SizedBox(height: 16),
            Text('Bahan-bahan', style: Theme.of(context).textTheme.headline6),
            ...recipe.ingredients.map((ing) => Text('• $ing')).toList(),
            SizedBox(height: 16),
            Text('Cara Memasak', style: Theme.of(context).textTheme.headline6),
            ...recipe.steps.asMap().entries.map((e) => Text('${e.key + 1}. ${e.value}')).toList(),
          ],
        ),
      ),
    );
  }
}

// FAVORITES SCREEN
class FavoriteScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final void Function(Recipe) onToggleFavorite;
  FavoriteScreen({required this.recipes, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: recipes.isEmpty
          ? Center(child: Text('Belum ada favorit'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (ctx, i) {
                final recipe = recipes[i];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(recipe.imageUrl)),
                  title: Text(recipe.title),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => onToggleFavorite(recipe),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe, onToggleFavorite: onToggleFavorite))),
                );
              },
            ),
    );
  }
}

// PROFILE SCREEN
class ProfileScreen extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;
  ProfileScreen({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
            SizedBox(height: 16),
            Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(user.email),
            Spacer(),
            ElevatedButton.icon(
              onPressed: onLogout,
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ADD RECIPE SCREEN
class AddRecipeScreen extends StatefulWidget {
  final void Function(Recipe) onSubmit;
  AddRecipeScreen({required this.onSubmit});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _imageUrl = '';
  String _ingredients = '';
  String _steps = '';

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final recipe = Recipe(
        title: _title,
        imageUrl: _imageUrl,
        ingredients: _ingredients.split(',').map((e) => e.trim()).toList(),
        steps: _steps.split('.').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      );
      widget.onSubmit(recipe);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Resep')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Judul Resep'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'URL Gambar'),
                validator: (v) => v!.startsWith('http') ? null : 'Enter valid URL',
                onSaved: (v) => _imageUrl = v!.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bahan (pisah koma)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _ingredients = v!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Langkah (pisah titik)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _steps = v!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
