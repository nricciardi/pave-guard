import { ConflictException, Injectable, Logger, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserService } from '../user/user.service';
import { ConfigService } from '@nestjs/config';
import { CreateUserDto } from '../../dto/create-user.dto';
import { LoginDto } from '../../dto/login.dto';
import { JwtDto } from '../../dto/jwt.dto';

@Injectable()
export class AuthenticationService {

  private readonly logger = new Logger(AuthenticationService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  async signup(input: CreateUserDto) {

    const user = await this.userService.createUser(input);

    const token = this.generateToken({
      userId: user.id,
      email: user.email
    });

    this.logger.log(`new signup: ${input.email} -> token: ${token}`);

    return {
      token
    };
  }

  async login(input: LoginDto) {

    const user = await this.userService.findByEmail(input.email);

    if (!user)
      throw new NotFoundException('User not found');

    if (!(await bcrypt.compare(input.password, user.password)))
      throw new UnauthorizedException('Invalid credentials');

    const token = this.generateToken({
      userId: user.id,
      email: user.email
    });

    return {
      token
    };
  }

  private generateToken(payload: JwtDto) {
    return this.jwtService.sign(payload);
  }
}
