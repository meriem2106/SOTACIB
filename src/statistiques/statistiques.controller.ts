import { Controller, Get, Query,BadRequestException ,InternalServerErrorException} from '@nestjs/common';
import { StatistiquesService } from './statistiques.service';



@Controller('visites') // Base route: /visites
export class StatistiquesController {
  constructor(private readonly statistiquesService: StatistiquesService) {}

  @Get('statistics/evolution') // Route: /visites/statistics/evolution
  async getPrixEvolution(
    @Query('gouvernoratId') gouvernoratId: string,
    @Query('concurentId') concurentId: string,
    @Query('produitId') produitId: string,
  ) {
    console.log('Received params:', { gouvernoratId, concurentId, produitId });
  
    const filters = { gouvernoratId, concurentId, produitId };
    return await this.statistiquesService.getPrixEvolution(filters);
  }

  
  @Get('statistics/availability')
  async getProductAvailability(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Query('produitId') produitId: string,
  ) {
    console.log('Received params:', { startDate, endDate, produitId });
  
    // Validate dates
    const parsedStartDate = new Date(startDate);
    const parsedEndDate = new Date(endDate);
  
    if (isNaN(parsedStartDate.getTime()) || isNaN(parsedEndDate.getTime())) {
      throw new BadRequestException('Invalid startDate or endDate');
    }
  
    if (parsedStartDate > parsedEndDate) {
      throw new BadRequestException('startDate cannot be later than endDate');
    }
  
    const filters = { startDate, endDate, produitId };
    return await this.statistiquesService.getProductAvailability(filters);
  }

  @Get('statistics/visits-and-sales')
async getVisitAndSalesStats(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Query('gouvernoratId') gouvernoratId: string,
    @Query('commercialId') commercialId: string
) {
    console.log('Received params:', { startDate, endDate, gouvernoratId, commercialId });

    const filters = { startDate, endDate, gouvernoratId, commercialId };
    return await this.statistiquesService.getVisitAndSalesStats(filters);
}

@Get('statistics/sales-evolution')
async getSalesEvolution(
  @Query('startDate') startDate: string,
  @Query('endDate') endDate: string,
  @Query('gouvernoratId') gouvernoratId: string,
  @Query('delegationId') delegationId: string,
  @Query('clientId') clientId: string,
  @Query('produitId') produitId: string,
) {
  console.log('Received params:', {
    startDate,
    endDate,
    gouvernoratId,
    delegationId,
    clientId,
    produitId,
  });

  const filters = { startDate, endDate, gouvernoratId, delegationId, clientId, produitId };
  return await this.statistiquesService.getSalesEvolution(filters);
}


}