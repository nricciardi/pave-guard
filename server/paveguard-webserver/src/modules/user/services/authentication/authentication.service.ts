import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserService } from '../user/user.service';
import { ConfigService } from '@nestjs/config';
import { CreateUserDto } from '../../dto/create-user.dto';
import { LoginDto } from '../../dto/login.dto';
import { JwtDto } from '../../dto/jwt.dto';

@Injectable()
export class AuthenticationService {
  constructor(
    private readonly configService: ConfigService,
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  async signup(input: CreateUserDto) {

    const user = await this.userService.createUser(input);

    return this.generateToken({
      userId: user.id,
      email: user.email
    });
  }

  async login(input: LoginDto) {

    const user = await this.userService.findByEmail(input.email);

    if (!user || !(await bcrypt.compare(input.password, user.password)))
      throw new UnauthorizedException('Invalid credentials');

    return this.generateToken({
      userId: user.id,
      email: user.email
    });
  }

  private generateToken(payload: JwtDto) {
    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
