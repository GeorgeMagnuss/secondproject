from typing import Optional, Any, Dict
from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.core.validators import MinValueValidator, MaxValueValidator, MinLengthValidator
from django.core.exceptions import ValidationError
from django.utils import timezone


class Role(models.Model):
    """
    Role model defining user permission levels in the vacation management system.
    
    Supports two role types: 'admin' for system administrators with full access,
    and 'user' for regular users with limited permissions.
    """
    ROLE_CHOICES = [
        ('admin', 'Admin'),
        ('user', 'User'),
    ]
    
    role_name = models.CharField(
        max_length=10, 
        choices=ROLE_CHOICES, 
        unique=True
    )
    
    def __str__(self) -> str:
        return self.role_name
    
    class Meta:
        db_table = 'roles'


class UserManager(BaseUserManager):
    """
    Custom user manager for the vacation management system.
    
    Provides methods for creating regular users and superusers with
    email-based authentication instead of username.
    """
    def create_user(self, email: str, password: Optional[str] = None, **extra_fields: Any) -> 'User':
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email: str, password: Optional[str] = None, **extra_fields: Any) -> 'User':
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)


class User(AbstractUser):
    """
    Custom user model for the vacation management system.
    
    Uses email as the primary authentication field instead of username.
    Each user is associated with a role (admin or user) that determines
    their permissions within the system.
    """
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    email = models.EmailField(max_length=100, unique=True)
    role = models.ForeignKey(
        Role, 
        on_delete=models.CASCADE,
        related_name='users',
        db_column='role_id'
    )
    
    username = None
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name']
    
    objects = UserManager()
    
    def __str__(self) -> str:
        return f"{self.first_name} {self.last_name}"
    
    @property
    def is_admin(self) -> bool:
        return self.role.role_name == 'admin'
    
    class Meta:
        db_table = 'users'


class Country(models.Model):
    """
    Country model representing vacation destinations.
    
    Stores country information for vacation packages. Each vacation
    package is associated with a specific country destination.
    """
    country_name = models.CharField(max_length=100, unique=True)
    
    def __str__(self) -> str:
        return self.country_name
    
    class Meta:
        db_table = 'countries'
        verbose_name_plural = 'countries'


class Vacation(models.Model):
    """
    Vacation package model containing all vacation details.
    
    Represents individual vacation offerings with country destination,
    dates, pricing, and image information. Includes validation for
    logical date ranges and pricing constraints.
    """
    country = models.ForeignKey(
        Country, 
        on_delete=models.CASCADE,
        related_name='vacations'
    )
    description = models.TextField()
    start_date = models.DateField()
    end_date = models.DateField()
    price = models.DecimalField(
        max_digits=10, 
        decimal_places=2,
        validators=[MinValueValidator(0), MaxValueValidator(10000)]
    )
    image_file = models.CharField(max_length=255)
    
    def clean(self):
        if self.start_date and self.end_date:
            if self.end_date <= self.start_date:
                raise ValidationError("End date must be after start date")
            
            # Don't allow past start dates for new vacations
            if not self.pk and self.start_date < timezone.now().date():
                raise ValidationError("Start date cannot be in the past")
    
    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)
    
    @property
    def like_count(self) -> int:
        return self.likes.count()
    
    def is_liked_by_user(self, user) -> bool:
        if user.is_authenticated:
            return self.likes.filter(user=user).exists()
        return False
    
    def __str__(self) -> str:
        return f"{self.country.country_name} - {self.description[:50]}"
    
    class Meta:
        db_table = 'vacations'
        ordering = ['start_date']


class Like(models.Model):
    """
    Like relationship model between users and vacation packages.
    
    Tracks which users have 'liked' specific vacation packages.
    Enforces unique constraint to prevent duplicate likes from the same user.
    """
    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE,
        related_name='likes'
    )
    vacation = models.ForeignKey(
        Vacation, 
        on_delete=models.CASCADE,
        related_name='likes'
    )
    
    def __str__(self) -> str:
        return f"{self.user} likes {self.vacation.country.country_name}"
    
    class Meta:
        db_table = 'likes'
        unique_together = ['user', 'vacation']
